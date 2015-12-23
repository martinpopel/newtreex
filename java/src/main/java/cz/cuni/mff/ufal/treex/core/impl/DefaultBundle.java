package cz.cuni.mff.ufal.treex.core.impl;

import cz.cuni.mff.ufal.treex.core.Bundle;
import cz.cuni.mff.ufal.treex.core.Sentence;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by mvojtek on 12/22/15.
 */
public class DefaultBundle implements Bundle {

    private List<Sentence> sentences = new ArrayList<>();

    @Override
    public void addSentence(Sentence sentence) {
        sentences.add(sentence);
    }

    @Override
    public List<Sentence> getSentences() {
        return sentences;
    }
}
