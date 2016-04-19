package cz.ufal.udapi.core.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Sentence;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by mvojtek on 12/22/15.
 */
public class DefaultBundle implements Bundle {

    private List<Sentence> sentences = new ArrayList<>();
    private Document document;

    public DefaultBundle(Document document) {
        this.document = document;
    }

    @Override
    public void addSentence(Sentence sentence) {
        sentences.add(sentence);
    }

    @Override
    public List<Sentence> getSentences() {
        return sentences;
    }

    @Override
    public void setDocument(Document document) {
        this.document = document;
    }

    @Override
    public Document getDocument() {
        return document;
    }
}
