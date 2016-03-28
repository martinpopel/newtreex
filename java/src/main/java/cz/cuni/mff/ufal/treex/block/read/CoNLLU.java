package cz.cuni.mff.ufal.treex.block.read;

import cz.cuni.mff.ufal.treex.core.Block;
import cz.cuni.mff.ufal.treex.core.Document;
import cz.cuni.mff.ufal.treex.core.io.DocumentReader;
import cz.cuni.mff.ufal.treex.core.io.TreexIOException;
import cz.cuni.mff.ufal.treex.core.io.impl.CoNLLUReader;

import java.io.IOException;
import java.io.InputStreamReader;
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
            DocumentReader coNLLUReader = new CoNLLUReader(new InputStreamReader(System.in));
            coNLLUReader.readInDocument(document);
        } else {
            throw new TreexIOException("Expected CoNNLU on the standard input.");
        }
    }
}
