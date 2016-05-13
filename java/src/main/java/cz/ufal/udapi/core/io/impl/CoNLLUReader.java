package cz.ufal.udapi.core.io.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Root;
import cz.ufal.udapi.core.Node;
import cz.ufal.udapi.core.impl.DefaultDocument;
import cz.ufal.udapi.core.impl.DefaultRoot;
import cz.ufal.udapi.core.io.DocumentReader;
import cz.ufal.udapi.core.io.UdapiIOException;

import java.io.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by mvojtek on 12/21/15.
 */
public class CoNLLUReader implements DocumentReader {

    private final Reader reader;
    private static final Pattern idRangePattern = Pattern.compile("(\\d+)-(\\d+)");
    private static final String EMPTY_STRING = "";
    private static final String TAB = "\\t";
    private static final String DASH = "-";
    private static final char HASH = '#';
    private static final Pattern tabPattern = Pattern.compile(TAB);
    private static final Pattern sentIdPattern = Pattern.compile("^#\\s*sent_id\\s+(\\S+)");

    public CoNLLUReader(Reader reader) {
        this.reader = reader;
    }

    public CoNLLUReader(String inCoNLL) {
        try {
            reader = new FileReader(Paths.get(inCoNLL).toFile());
        } catch (FileNotFoundException e) {
            throw new UdapiIOException("Provided CoNLL file '"+inCoNLL+"' not found.");
        }
    }

    public CoNLLUReader(Path inCoNLL) {
        try {
            reader = new FileReader(inCoNLL.toFile());
        } catch (FileNotFoundException e) {
            throw new UdapiIOException("Provided CoNLL file '"+inCoNLL+"' not found.");
        }
    }

    public CoNLLUReader(File inCoNLL) {
        try {
            reader = new FileReader(inCoNLL);
        } catch (FileNotFoundException e) {
            throw new UdapiIOException("Provided CoNLL file '"+inCoNLL.getAbsolutePath()+"' not found.");
        }
    }

    @Override
    public Document readDocument() {
        final Document document = new DefaultDocument();
        readInDocument(document);

        return document;
    }

    @Override
    public void readInDocument(final Document document) throws UdapiIOException {

        ExecutorService executor = Executors.newSingleThreadExecutor();

        int sentenceId = 1;

        try (BufferedReader bufferedReader = new BufferedReader(reader))
        {
            String currLine;
            List<String> words = new ArrayList<>();

            while ((currLine = bufferedReader.readLine()) != null)
            {
                String trimLine = currLine.trim();
                if (EMPTY_STRING.equals(trimLine)) {
                    //end of sentence
                    List<String> finalWords = words;
                    final int finalSentenceId = sentenceId++;
                    executor.submit(() -> processSentenceWithBundle(finalSentenceId, document, finalWords));
                    words = new ArrayList<>();
                } else {
                    words.add(trimLine);
                }
            }
            //process last sentence if there was no empty line after it
            List<String> finalWords = words;
            final int finalSentenceId = sentenceId++;
            executor.submit(() -> processSentenceWithBundle(finalSentenceId,document, finalWords));
        }
        catch (IOException e)
        {
            throw new UdapiIOException(e);
        }

        executor.shutdown();
        try {
            executor.awaitTermination(5, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            System.err.println("Wait for executor termination interrupted.");
        }
    }

    @Override
    public Optional<Root> readTree(BufferedReader bufferedReader, final Document document) throws UdapiIOException {
        try {
            String currLine;
            List<String> words = new ArrayList<>();

            while ((currLine = bufferedReader.readLine()) != null)
            {
                String trimLine = currLine.trim();
                if (EMPTY_STRING.equals(trimLine)) {
                    //end of sentence
                    List<String> finalWords = words;
                    Root root = processSentence(document, finalWords);
                    if (null != root) {
                        return Optional.of(root);
                    }
                    words = new ArrayList<>();
                } else {
                    words.add(trimLine);
                }
            }
            //process last sentence if there was no empty line after it
            List<String> finalWords = words;
            Root root = processSentence(document, finalWords);
            if (null == root) {
                return Optional.empty();
            }
            return Optional.of(root);
        }
        catch (IOException e)
        {
            throw new UdapiIOException(e);
        }
    }

    @Override
    public Optional<Root> readTree(final Document document) throws UdapiIOException {
        try (BufferedReader bufferedReader = new BufferedReader(reader))
        {
            return readTree(bufferedReader, document);
        }
        catch (IOException e)
        {
            throw new UdapiIOException(e);
        }
    }

    private void processSentenceWithBundle(int sentenceId, final Document document, List<String> words) {

        Root tree = processSentence(document, words);

        String treeId = tree.getId();
        //add tree to correct bundle
        // Based on treeId the tree is added either to the last existing bundle or to a new bundle.
        // treeId should contain bundleId/zone.
        // The "/zone" part is optional. If missing, zone='und' is used for the new tree.
        if (null == treeId) {
            Bundle newBundle = document.addBundle();
            newBundle.addTree(tree);
            newBundle.setId(String.valueOf(sentenceId));
        } else {
            String bundleId;
            int slashIndex = treeId.indexOf("/");

            if (-1 != slashIndex) {
                bundleId = treeId.substring(0, slashIndex);
                if (slashIndex < treeId.length()-1) {
                    tree.setZone(treeId.substring(slashIndex+1));
                    tree.validateZone();
                }
            } else {
                bundleId = treeId;
            }

            if (document.getBundles().isEmpty()) {
                Bundle newBundle = document.addBundle();
                newBundle.setId(bundleId);
                newBundle.addTree(tree);
            } else {
                Bundle lastBundle = document.getBundles().get(document.getBundles().size() - 1);
                if (null != bundleId && !bundleId.equals(lastBundle)) {
                    Bundle newBundle = document.addBundle();
                    newBundle.setId(bundleId);
                    newBundle.addTree(tree);
                } else {
                    lastBundle.addTree(tree);
                }
            }
        }
        tree.setId(null);
    }

    private Root processSentence(final Document document, List<String> words) {

        //ignore empty sentences
        if (words.isEmpty()) {
            return null;
        }

        Root tree = new DefaultRoot(document);

        Node root = tree.getNode();

        List<Node> nodes = new ArrayList<>();
        nodes.add(root);
        List<Integer> parents = new ArrayList<>();
        parents.add(0);

        for (String word : words) {
            if (word.charAt(0) == HASH) {
                Matcher sentIdMatcher = sentIdPattern.matcher(word);
                if (sentIdMatcher.matches()) {
                    tree.setId(sentIdMatcher.group(1));
                } else {
                    //comment
                    if (word.length() > 1) {
                        tree.addComment(word.substring(1));
                    } else {
                        tree.addComment(EMPTY_STRING);
                    }
                }
            } else {
                //process word
                processWord(tree, root, nodes, parents, word);
            }
        }

        //set correct parents
        for (int i = 1; i < nodes.size(); i++) {
            nodes.get(i).setParent(nodes.get(parents.get(i)));
        }

        return tree;
    }

    private void processWord(Root tree, Node root, List<Node> nodes, List<Integer> parents, String word) {

        String[] fields = tabPattern.split(word, 10);
        String     id = fields[0];
        String   form = fields[1];
        String  lemma = fields[2];
        String   upos = fields[3];
        String postag = fields[4];
        String  feats = fields[5];
        String   head = fields[6];
        String deprel = fields[7];
        String   deps = fields[8];
        String   misc = null;
        if (10 == fields.length) {
            misc = fields[9];
        }

        if (-1 == id.indexOf(DASH)) {
            Node child = root.createChild();
            child.setForm(form);
            child.setLemma(lemma);
            child.setUpos(upos);
            child.setXpos(postag);
            child.setFeats(feats);
            child.setHead(head);
            child.setDeprel(deprel);
            child.setDeps(deps);
            child.setMisc(misc);

            nodes.add(child);
            parents.add(Integer.parseInt(head));
        } else {
            Matcher m = idRangePattern.matcher(id);
            if (m.matches()) {
                //TODO: multiword
                tree.addMultiword(word);
            }
        }
    }
}
