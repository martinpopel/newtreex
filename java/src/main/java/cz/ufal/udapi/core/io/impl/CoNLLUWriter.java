package cz.ufal.udapi.core.io.impl;

import cz.ufal.udapi.core.*;
import cz.ufal.udapi.core.io.DocumentWriter;
import cz.ufal.udapi.core.io.TreexIOException;

import java.io.*;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Created by mvojtek on 12/22/15.
 */
public class CoNLLUWriter implements DocumentWriter{

    private static final String TAB = "\t";
    private static final String UNDERSCORE = "_";
    private static final String NEW_LINE = "\n";
    private static final Charset utf8Charset = StandardCharsets.UTF_8;

    private static final int BUFFER = 256 * 1024;

    @Override
    public void writeDocument(Document document, Path path) {

        Set options = new HashSet();
        options.add(StandardOpenOption.CREATE);
        options.add(StandardOpenOption.WRITE);
        options.add(StandardOpenOption.TRUNCATE_EXISTING);

        FileChannel fileChannel;
        try {
            fileChannel = FileChannel.open(path, options);

            StringBuilder sb = new StringBuilder();


            for (Bundle bundle : document.getBundles()) {
                for (NLPTree tree : bundle.getTrees()) {

                    List<Node> descendants = tree.getRoot().getDescendants();

                    //do not write empty sentences
                    if (descendants.size() > 0) {

                        List<String> comments = tree.getComments();

                        for (String comment : comments) {
                            sb.append(comment);
                            sb.append(NEW_LINE);
                        }

                        //TODO: multiword

                        for (Node descendant : descendants) {
                            buildLine(sb, descendant);
                            sb.append(NEW_LINE);
                        }
                        sb.append(NEW_LINE);
                    }
                }
                if (sb.length() > BUFFER) {
                    fileChannel.write(ByteBuffer.wrap(sb.toString().getBytes(utf8Charset)));
                    sb.setLength(0);
                }
            }

            fileChannel.write(ByteBuffer.wrap(sb.toString().getBytes(utf8Charset)));
            fileChannel.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void writeDocument(Document document, Writer writer) {
        try (BufferedWriter bufferedWriter = new BufferedWriter(writer)) {
            for (Bundle bundle : document.getBundles()) {
                for (NLPTree tree : bundle.getTrees()) {

                    List<Node> descendants = tree.getRoot().getDescendants();

                    //do not write empty sentences
                    if (descendants.size() > 0) {

                        List<String> comments = tree.getComments();

                        for (String comment : comments) {
                            bufferedWriter.write(comment, 0, comment.length());
                            bufferedWriter.newLine();
                        }

                        //TODO: multiword


                        for (Node descendant : descendants) {
                            StringBuilder sb = new StringBuilder();
                            buildLine(sb, descendant);
                            String line = sb.toString();
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

    private void buildLine(StringBuilder sb, Node node) {
        sb.append(node.getOrd());
        sb.append(TAB);
        sb.append(getString(node.getForm()));
        sb.append(TAB);
        sb.append(getString(node.getLemma()));
        sb.append(TAB);
        sb.append(getString(node.getUpos()));
        sb.append(TAB);
        sb.append(getString(node.getPostag()));
        sb.append(TAB);
        sb.append(getString(node.getFeats()));
        sb.append(TAB);
        sb.append(node.getParent().get().getOrd());
        sb.append(TAB);
        sb.append(getString(node.getDeprel()));
        sb.append(TAB);
        sb.append(getString(node.getDeps()));
        sb.append(TAB);
        sb.append(getString(node.getMisc()));
    }

    private String getString(String field) {
        if (null == field) return UNDERSCORE;
        return field;
    }
}
