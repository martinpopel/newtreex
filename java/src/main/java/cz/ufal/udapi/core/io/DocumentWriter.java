package cz.ufal.udapi.core.io;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Root;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.Writer;
import java.nio.file.Path;

/**
 * Created by mvojtek on 12/22/15.
 */
public interface DocumentWriter {
    void writeDocument(Document document, Writer writer) throws UdapiIOException;
    void writeDocument(Document document, Path outPath) throws UdapiIOException;
    void processTree(BufferedWriter bufferedWriter, Root tree) throws IOException;
}
