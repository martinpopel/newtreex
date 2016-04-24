package cz.ufal.udapi.block.read;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.io.DocumentReader;
import cz.ufal.udapi.core.io.TreexIOException;
import cz.ufal.udapi.core.io.impl.CoNLLUReader;

import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * Created by mvojtek on 3/26/16.
 */
public class CoNLLU extends Block {

    public CoNLLU(Map<String, String> params) {
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
            DocumentReader coNLLUReader = new CoNLLUReader(new InputStreamReader(System.in, StandardCharsets.UTF_8));
            coNLLUReader.readInDocument(document);
        } else {
            throw new TreexIOException("Expected CoNNLU on the standard input.");
        }
    }
}
