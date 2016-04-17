package cz.ufal.udapi.core.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.NLPTree;
import cz.ufal.udapi.core.Sentence;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by mvojtek on 12/22/15.
 */
public class DefaultSentence implements Sentence {

    private final NLPTree tree;

    private List<String> comments = new ArrayList<>();
    private List<String> multiwords = new ArrayList<>();
    private String text;

    public DefaultSentence(Document document, Bundle bundle) {
        tree = createTree(document, bundle);
    }

    @Override
    public NLPTree getTree() {
        return tree;
    }

    protected NLPTree createTree(Document document, Bundle bundle) {
        return new DefaultTree(document, bundle);
    }

    public void addComment(String comment) {
        this.comments.add(comment);
    }

    public List<String> getComments() {
        return comments;
    }

    public void addMultiword(String multiword) {
        this.multiwords.add(multiword);
    }

    public List<String> getMultiwords() {
        return multiwords;
    }

    @Override
    public void setText(String sentenceText) {
        this.text = sentenceText;
    }

    @Override
    public String getText() {
        return text;
    }


}
