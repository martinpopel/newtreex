package cz.ufal.udapi.block.read;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Sentence;
import cz.ufal.udapi.core.impl.DefaultSentence;
import cz.ufal.udapi.core.io.TreexIOException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
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
            try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8)))
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
