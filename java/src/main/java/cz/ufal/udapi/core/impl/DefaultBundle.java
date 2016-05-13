package cz.ufal.udapi.core.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Root;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by mvojtek on 12/22/15.
 */
public class DefaultBundle implements Bundle {

    private List<Root> trees = new ArrayList<>();
    private Document document;
    private String id;

    public DefaultBundle(Document document) {
        this.document = document;
    }

    public void addTree(Root root) {
        root.setBundle(this);
        trees.add(root);
    }

    @Override
    public Root addTree() {
        Root tree = new DefaultRoot(document, this);
        trees.add(tree);
        return tree;
    }

    @Override
    public List<Root> getTrees() {
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

    public String getId() {
        return id;
    }

    @Override
    public void setId(String id) {
        this.id = id;
    }
}
