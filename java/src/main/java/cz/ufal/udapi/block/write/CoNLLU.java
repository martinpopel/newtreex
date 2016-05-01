package cz.ufal.udapi.block.write;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.io.impl.CoNLLUWriter;

import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * Created by mvojtek on 3/27/16.
 */
public class CoNLLU extends Block {

    @Override
    public void processDocument(Document document) {
        CoNLLUWriter coNLLUWriter = new CoNLLUWriter();
        coNLLUWriter.writeDocument(document, new OutputStreamWriter(System.out, StandardCharsets.UTF_8));
    }

}
