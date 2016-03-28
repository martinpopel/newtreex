package cz.cuni.mff.ufal.treex.core.io;

import cz.cuni.mff.ufal.treex.core.Document;

import java.io.Writer;
import java.nio.file.Path;

/**
 * Created by mvojtek on 12/22/15.
 */
public interface DocumentWriter {
    void writeDocument(Document document, Writer writer) throws TreexIOException;
    void writeDocument(Document document, Path outPath) throws TreexIOException;
}
