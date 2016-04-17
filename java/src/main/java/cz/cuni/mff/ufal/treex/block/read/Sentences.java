package cz.cuni.mff.ufal.treex.block.read;

import cz.cuni.mff.ufal.treex.core.Block;
import cz.cuni.mff.ufal.treex.core.Bundle;
import cz.cuni.mff.ufal.treex.core.Document;
import cz.cuni.mff.ufal.treex.core.Sentence;
import cz.cuni.mff.ufal.treex.core.impl.DefaultSentence;
import cz.cuni.mff.ufal.treex.core.io.TreexIOException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Map;

/**
 * Created by mvojtek on 4/17/16.
 */
public class Sentences extends Block {
    public Sentences(Map<String, String> params) {
        super(params);
    }

    @Override
    public void processDocument(Document document) {

        boolean inAvailable;

        try {
            inAvailable = System.in.available() > 0;
        } catch (IOException e) {
            throw new TreexIOException("Error when reading input stream.", e);
        }

        if (inAvailable) {
            try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in)))
            {
                //default bundle
                Bundle bundle = document.getBundles().get(0);
                String currLine;

                while ((currLine = bufferedReader.readLine()) != null) {
                    Sentence sentence = new DefaultSentence(document, bundle);
                    bundle.addSentence(sentence);
                    sentence.setText(currLine);
                }
            } catch (IOException e) {
                throw new TreexIOException(e);
            }
        }

    }
}
