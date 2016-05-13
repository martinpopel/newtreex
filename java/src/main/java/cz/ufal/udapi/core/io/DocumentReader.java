package cz.ufal.udapi.core.io;

import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Root;

import java.io.BufferedReader;
import java.util.Optional;

/**
 * Created by mvojtek on 12/21/15.
 */
public interface DocumentReader {
    Document readDocument() throws UdapiIOException;
    void readInDocument(Document document) throws UdapiIOException;
    Optional<Root> readTree(final Document document) throws UdapiIOException;
    Optional<Root> readTree(BufferedReader bufferedReader, final Document document) throws UdapiIOException;
}
