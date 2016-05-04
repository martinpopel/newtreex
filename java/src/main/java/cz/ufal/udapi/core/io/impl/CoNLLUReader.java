package cz.ufal.udapi.core.io.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.NLPTree;
import cz.ufal.udapi.core.Node;
import cz.ufal.udapi.core.impl.DefaultDocument;
import cz.ufal.udapi.core.io.DocumentReader;
import cz.ufal.udapi.core.io.TreexIOException;

import java.io.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
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

    public CoNLLUReader(Reader reader) {
        this.reader = reader;
    }

    public CoNLLUReader(String inCoNLL) {
        try {
            reader = new FileReader(Paths.get(inCoNLL).toFile());
        } catch (FileNotFoundException e) {
            throw new TreexIOException("Provided CoNLL file '"+inCoNLL+"' not found.");
        }
    }

    public CoNLLUReader(Path inCoNLL) {
        try {
            reader = new FileReader(inCoNLL.toFile());
        } catch (FileNotFoundException e) {
            throw new TreexIOException("Provided CoNLL file '"+inCoNLL+"' not found.");
        }
    }

    public CoNLLUReader(File inCoNLL) {
        try {
            reader = new FileReader(inCoNLL);
        } catch (FileNotFoundException e) {
            throw new TreexIOException("Provided CoNLL file '"+inCoNLL.getAbsolutePath()+"' not found.");
        }
    }

    @Override
    public Document readDocument() {
        final Document document = new DefaultDocument();
        readInDocument(document);

        return document;
    }

    @Override
    public void readInDocument(final Document document) throws TreexIOException {

        //default bundle

        ExecutorService executor = Executors.newSingleThreadExecutor();

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
                    executor.submit(() -> processSentence(document, finalWords));
                    words = new ArrayList<>();
                } else {
                    words.add(trimLine);
                }
            }
            //process last sentence if there was no empty line after it
            List<String> finalWords = words;
            executor.submit(() -> processSentence(document, finalWords));
        }
        catch (IOException e)
        {
            throw new TreexIOException(e);
        }

        executor.shutdown();
        try {
            executor.awaitTermination(5, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            System.err.println("Wait for executor termination interrupted.");
        }
    }

    private void processSentence(final Document document, List<String> words) {
        //ignore empty sentences
        if (words.isEmpty()) {
            return;
        }
        Bundle bundle = document.addBundle();

        NLPTree tree = bundle.addTree();

        Node root = tree.getRoot();

        List<Node> nodes = new ArrayList<>();
        nodes.add(root);
        List<Integer> parents = new ArrayList<>();
        parents.add(0);

        for (String word : words) {
            if (word.charAt(0) == HASH) {
                //comment
                //TODO: process comments, e.g. sent_id
                tree.addComment(word);
            } else {
                //process word
                processWord(tree, root, nodes, parents, word);
            }
        }

        //set correct parents
        for (int i = 1; i < nodes.size(); i++) {
            nodes.get(i).setParent(nodes.get(parents.get(i)));
        }
    }

    private void processWord(NLPTree tree, Node root, List<Node> nodes, List<Integer> parents, String word) {

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
            child.setPostag(postag);
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
