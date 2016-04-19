package cz.ufal.udapi.core.io.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Node;
import cz.ufal.udapi.core.Sentence;
import cz.ufal.udapi.core.impl.DefaultBundle;
import cz.ufal.udapi.core.impl.DefaultDocument;
import cz.ufal.udapi.core.impl.DefaultSentence;
import cz.ufal.udapi.core.io.DocumentReader;
import cz.ufal.udapi.core.io.TreexIOException;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by mvojtek on 12/21/15.
 */
public class CoNLLUReader implements DocumentReader {

    private final Reader reader;
    private final Pattern idRangePattern = Pattern.compile("(\\d+)-(\\d+)");

    public CoNLLUReader(Reader reader) {
        this.reader = reader;
    }

    @Override
    public Document readDocument() {
        final Document document = new DefaultDocument();
        final Bundle bundle = new DefaultBundle(document);
        document.addBundle(bundle);

        readInDocument(document);

        return document;
    }

    @Override
    public void readInDocument(Document document) throws TreexIOException {

        //default bundle
        Bundle bundle = document.getBundles().get(0);

        try (BufferedReader bufferedReader = new BufferedReader(reader))
        {
            String currLine;
            List<String> words = new ArrayList<>();

            while ((currLine = bufferedReader.readLine()) != null)
            {
                String trimLine = currLine.trim();
                if ("".equals(trimLine)) {
                    //end of sentence
                    processSentence(document, bundle, words);
                    words.clear();
                } else {
                    words.add(trimLine);
                }
            }
            //process last sentence if there was no empty line after it
            processSentence(document, bundle, words);
        }
        catch (IOException e)
        {
            throw new TreexIOException(e);
        }
    }

    private void processSentence(Document document, Bundle bundle, List<String> words) {
        //ignore empty sentences
        if (0 == words.size()) {
            return;
        }

        Sentence sentence = new DefaultSentence(document, bundle);
        bundle.addSentence(sentence);

        Node root = sentence.getTree().getRoot();

        List<Node> nodes = new ArrayList<>();
        nodes.add(root);
        List<Integer> parents = new ArrayList<>();
        parents.add(0);

        for (String word : words) {
            if (word.startsWith("#")) {
                //comment
                //TODO: process comments, e.g. sent_id
                sentence.addComment(word);
            } else {
                //process word
                processWord(sentence, root, nodes, parents, word);
            }
        }

        //set correct parents
        for (int i = 1; i < nodes.size(); i++) {
            nodes.get(i).setParent(nodes.get(parents.get(i)));
        }

    }

    private void processWord(Sentence sentence, Node root, List<Node> nodes, List<Integer> parents, String word) {
        String[] fields = word.split("\\t", 10);
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

        if (-1 == id.indexOf("-")) {
            Node child = root.createChild();
            child.setOrd(nodes.size());
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
                sentence.addMultiword(word);
            }
        }
    }
}
