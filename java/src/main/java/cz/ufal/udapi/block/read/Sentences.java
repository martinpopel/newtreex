package cz.ufal.udapi.block.read;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.NLPTree;
import cz.ufal.udapi.core.impl.DefaultTree;
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
                Bundle bundle = document.getDefaultBundle();
                String currLine;

                while ((currLine = bufferedReader.readLine()) != null) {
                    bundle.addTree().setText(currLine);
                }
            } catch (IOException e) {
                throw new TreexIOException(e);
            }
        }

    }
}
