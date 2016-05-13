package cz.ufal.udapi.block.write;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Root;
import cz.ufal.udapi.core.io.UdapiIOException;
import cz.ufal.udapi.core.io.impl.CoNLLUWriter;
import cz.ufal.udapi.exception.UdapiException;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * Created by mvojtek on 3/27/16.
 */
public class CoNLLU extends Block {

    private BufferedWriter bufferedWriter;
    private CoNLLUWriter coNLLUWriter;

    @Override
    public void processStart() {
        bufferedWriter = new BufferedWriter(new OutputStreamWriter(System.out, StandardCharsets.UTF_8));
        coNLLUWriter = new CoNLLUWriter();
    }

    @Override
    public void processDocument(Document document) {

        coNLLUWriter.writeDocument(document, new OutputStreamWriter(System.out, StandardCharsets.UTF_8));
    }

    @Override
    public void processTree(Root tree, int bundleNo) {
        try {
            coNLLUWriter.processTree(bufferedWriter, tree);
        } catch (IOException e) {
            throw new UdapiException("Failed to process tree "+tree.getId()+".", e);
        }
    }

    @Override
    public void processEnd() {
        if (null != bufferedWriter) {
            try {
                bufferedWriter.close();
            } catch (IOException e) {
                throw new UdapiIOException("Failed to close writer.", e);
            }
        }
    }
}
