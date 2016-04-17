package cz.ufal.udapi.core.io.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;
import cz.ufal.udapi.core.Node;
import cz.ufal.udapi.core.Sentence;
import cz.ufal.udapi.core.io.DocumentWriter;
import cz.ufal.udapi.core.io.TreexIOException;

import java.io.*;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by mvojtek on 12/22/15.
 */
public class CoNLLUWriter implements DocumentWriter{

    public void writeDocument(Document document, Writer writer) {
        try (BufferedWriter bufferedWriter = new BufferedWriter(writer)) {
            for (Bundle bundle : document.getBundles()) {
                for (Sentence sentence : bundle.getSentences()) {

                    List<Node> descendants = sentence.getTree().getRoot().getOrderedDescendants();

                    //do not write empty sentences
                    if (descendants.size() > 0) {

                        List<String> comments = sentence.getComments();

                        for (String comment : comments) {
                            bufferedWriter.write(comment, 0, comment.length());
                            bufferedWriter.newLine();
                        }

                        //TODO: multiword


                        for (Node descendant : descendants) {
                            String line = buildLine(descendant);
                            bufferedWriter.write(line, 0, line.length());
                            bufferedWriter.newLine();
                        }
                        bufferedWriter.newLine();
                    }
                }
            }
        } catch (IOException e) {
            throw new TreexIOException(e);
        }
    }

    @Override
    public void writeDocument(Document document, Path outPath) {
        try {
            writeDocument(document, new FileWriter(outPath.toFile()));
        } catch (IOException e) {
            throw new TreexIOException("Failed to open file '"+outPath+"'.", e);
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
