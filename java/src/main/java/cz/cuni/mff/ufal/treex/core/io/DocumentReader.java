package cz.cuni.mff.ufal.treex.core.io;

import cz.cuni.mff.ufal.treex.core.Document;

/**
 * Created by mvojtek on 12/21/15.
 */
public interface DocumentReader {
    Document readDocument() throws TreexIOException;
}
