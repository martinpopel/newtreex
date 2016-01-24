package cz.cuni.mff.ufal.treex.core.io.impl;

import cz.cuni.mff.ufal.treex.core.Bundle;
import cz.cuni.mff.ufal.treex.core.Document;
import cz.cuni.mff.ufal.treex.core.Node;
import cz.cuni.mff.ufal.treex.core.Sentence;
import cz.cuni.mff.ufal.treex.core.io.DocumentWriter;
import cz.cuni.mff.ufal.treex.core.io.TreexIOException;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by mvojtek on 12/22/15.
 */
public class CoNLLUWriter implements DocumentWriter{

    private final Path outPath;

    public CoNLLUWriter(Path outPath) {
        this.outPath = outPath;
    }

    @Override
    public void writeDocument(Document document) {

        Charset charset = Charset.forName("utf-8");
        try (BufferedWriter writer = Files.newBufferedWriter(outPath, charset)) {
            for (Bundle bundle : document.getBundles()) {
                for (Sentence sentence : bundle.getSentences()) {

                    List<Node> descendants = sentence.getTree().getRoot().getOrderedDescendants();

                    //do not write empty sentences
                    if (descendants.size() > 0) {

                        List<String> comments = sentence.getComments();

                        for (String comment : comments) {
                            writer.write(comment, 0, comment.length());
                            writer.newLine();
                        }

                        //TODO: multiword


                        for (Node descendant : descendants) {
                            String line = buildLine(descendant);
                            writer.write(line, 0, line.length());
                            writer.newLine();
                        }
                        writer.newLine();
                    }
                }
            }
        } catch (IOException e) {
            throw new TreexIOException(e);
        }

    }

    private String buildLine(Node node) {
        List<String> fields = new ArrayList<>();
        fields.add(String.valueOf(node.getOrd()));
        fields.add(getString(node.getForm()));
        fields.add(getString(node.getLemma()));
        fields.add(getString(node.getUpos()));
        fields.add(getString(node.getPostag()));
        fields.add(getString(node.getFeats()));

        String parentOrd = String.valueOf(node.getParent().get().getOrd());
        fields.add(parentOrd);

        fields.add(getString(node.getDeprel()));
        fields.add(getString(node.getDeps()));
        fields.add(getString(node.getMisc()));

        return String.join("\t", fields);
    }

    private String getString(String field) {
        if (null == field) return "_";
        return field;
    }
}
