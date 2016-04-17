package cz.ufal.udapi.core.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.NLPTree;
import cz.ufal.udapi.core.Node;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public class DefaultTree implements NLPTree {

    private final Node rootNode;
    private final Document document;
    private final Bundle bundle;

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
        for (Node descendant : rootNode.getOrderedDescendants()) {
            descendant.setOrd(newOrder++);
        }
    }
}
