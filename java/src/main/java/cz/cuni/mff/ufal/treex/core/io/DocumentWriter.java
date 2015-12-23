package cz.cuni.mff.ufal.treex.core.io;

import cz.cuni.mff.ufal.treex.core.Document;

/**
 * Created by mvojtek on 12/22/15.
 */
public interface DocumentWriter {
    void writeDocument(Document document) throws TreexIOException;
}
