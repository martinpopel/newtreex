package cz.ufal.udapi.core.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.NLPTree;
import cz.ufal.udapi.core.Node;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public class DefaultTree implements NLPTree {

    private final Node rootNode;
    private final Document document;
    private final Bundle bundle;

    private List<String> comments = new ArrayList<>();
    private List<String> multiwords = new ArrayList<>();
    private List<Node> descendants = new ArrayList<>();
    private String text;

    public DefaultTree(Document document, Bundle bundle) {
        this.document = document;
        this.rootNode = createNode();
        this.rootNode.setOrd(0);
        this.bundle = bundle;
    }

    protected Node createNode() {
        return new DefaultNode(this);
    }

    @Override
    public Node getRoot() {
        return rootNode;
    }

    @Override
    public Document getDocument() {
        return document;
    }

    @Override
    public Bundle getBundle() {
        return bundle;
    }

    @Override
    public void normalizeOrder() {
        int newOrder = 1;
        for (Node descendant : rootNode.getDescendants()) {
            descendant.setOrd(newOrder++);
        }
    }

    @Override
    public List<Node> getDescendants() {
        return descendants;
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
    public void setSentence(String sentenceText) {
        this.text = sentenceText;
    }

    @Override
    public String getSentence() {
        return text;
    }
}
