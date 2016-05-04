package cz.ufal.udapi.core.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.NLPTree;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by mvojtek on 12/22/15.
 */
public class DefaultBundle implements Bundle {

    private List<NLPTree> trees = new ArrayList<>();
    private Document document;
    private int id;

    public DefaultBundle(Document document) {
        this.document = document;
        id = document.getUniqueBundleId();
    }

    @Override
    public NLPTree addTree() {
        NLPTree tree = new DefaultTree(document, this);
        trees.add(tree);
        return tree;
    }

    @Override
    public List<NLPTree> getTrees() {
        return trees;
    }

    @Override
    public void setDocument(Document document) {
        this.document = document;
    }

    @Override
    public Document getDocument() {
        return document;
    }

    public int getId() {
        return id;
    }
}
