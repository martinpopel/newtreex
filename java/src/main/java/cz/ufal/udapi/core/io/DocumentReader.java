package cz.ufal.udapi.core.io;

import cz.ufal.udapi.core.Document;

/**
 * Created by mvojtek on 12/21/15.
 */
public interface DocumentReader {
    Document readDocument() throws TreexIOException;
    void readInDocument(Document document) throws TreexIOException;
}
