package cz.cuni.mff.ufal.treex.core.impl;

import cz.cuni.mff.ufal.treex.core.Bundle;
import cz.cuni.mff.ufal.treex.core.Document;
import cz.cuni.mff.ufal.treex.core.NLPTree;
import cz.cuni.mff.ufal.treex.core.Node;

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
