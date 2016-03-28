package cz.cuni.mff.ufal.treex.block.write;

import cz.cuni.mff.ufal.treex.core.Block;
import cz.cuni.mff.ufal.treex.core.Document;
import cz.cuni.mff.ufal.treex.core.io.impl.CoNLLUWriter;

import java.io.OutputStreamWriter;
import java.util.Map;

/**
 * Created by mvojtek on 3/27/16.
 */
public class CoNLLU extends Block {
    public CoNLLU(Map<String, String> params) {
        super(params);
    }

    @Override
    public void processDocument(Document document) {
        CoNLLUWriter coNLLUWriter = new CoNLLUWriter();
        coNLLUWriter.writeDocument(document, new OutputStreamWriter(System.out));
    }

}
