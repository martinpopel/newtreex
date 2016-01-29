package cz.cuni.mff.ufal.treex.main;

import cz.cuni.mff.ufal.treex.core.Bundle;
import cz.cuni.mff.ufal.treex.core.Document;
import cz.cuni.mff.ufal.treex.core.Node;
import cz.cuni.mff.ufal.treex.core.Sentence;
import cz.cuni.mff.ufal.treex.core.io.DocumentReader;
import cz.cuni.mff.ufal.treex.core.io.DocumentWriter;
import cz.cuni.mff.ufal.treex.core.io.impl.CoNLLUReader;
import cz.cuni.mff.ufal.treex.core.io.impl.CoNLLUWriter;

import java.nio.file.Paths;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Created by mvojtek on 12/21/15.
 */
public class Main {
    private static long seed = 42;
    private static long maxseed = (long)Math.pow(2, 32);
    private static int myrand(long modulo) {
        seed = (1103515245L * seed + 12345L) % maxseed;
        return (int)(seed % modulo);
    }

    public static void main(String[] args) {
        boolean debug = false;

        String inCoNLL;
        String outCoNLL;
        int iterations = 1;
        int startIndex = 0;
        if ("-d".equals(args[startIndex])) {
            debug = true;
            startIndex++;
        }
        if ("-n".equals(args[startIndex])) {
            iterations = Integer.parseInt(args[startIndex+1]);
            startIndex += 2;
        }
        inCoNLL = args[startIndex];
        outCoNLL = args[startIndex+1];

        System.out.println("init");

        for (int i=1; i <= iterations; i++) {
            test(inCoNLL, outCoNLL, debug);
        }
    }

    public static void test(String inCoNLL, String outCoNLL, boolean debug) {
        DocumentReader coNLLUReader = new CoNLLUReader(Paths.get(inCoNLL));
        Document document = coNLLUReader.readDocument();
        System.out.println("load");
        if (debug) {
            writeDoc("java-load.conllu", document);
        }

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getOrderedDescendants()) {
                    //noop
                }
            }
        }
        System.out.println("iter");

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getDescendants()) {
                    //noop
                }
            }
        }
        System.out.println("iterF");

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node child : sentence.getTree().getRoot().getOrderedChildren()) {
                    for (Node node : child.getDescendants()) {
                        //noop
                    }
                }
            }
        }
        System.out.println("iterS");


        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getOrderedDescendants()) {
                    String form_lemma_tag = node.getForm() + node.getLemma();
                }
            }
        }
        System.out.println("read");

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getOrderedDescendants()) {
                    node.setDeprel("dep");
                }
            }
        }
        System.out.println("write");
        if (debug) {
            writeDoc("java-write.conllu", document);
        }

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                List<Node> descendants = sentence.getTree().getRoot().getOrderedDescendants();
                for (Node node : descendants) {
                    int rand_index = myrand(descendants.size());
                    node.setParent(descendants.get(rand_index), true);
                }
            }
        }
        System.out.println("rehang");
        if (debug) {
            writeDoc("java-rehang.conllu", document);
        }

        Set<Node> alreadyRemoved = new HashSet<>();
        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getOrderedDescendants()) {
                    if (myrand(10) == 0) {
                        if (!alreadyRemoved.contains(node)) {
                            node.remove();
                            alreadyRemoved.add(node);
                        }
                    }
                }
            }
        }
        System.out.println("remove");
        if (debug) {
            writeDoc("java-remove.conllu", document);
        }

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getOrderedDescendants()) {
                    if (myrand(10) == 0) {
                        Node nodeChild = node.createChild();
                        nodeChild.setLemma("x");
                        nodeChild.setForm("x");
                        nodeChild.shiftAfterSubtree(node, false);
                    }
                }
            }
        }
        System.out.println("add");
        if (debug) {
            writeDoc("java-add.conllu", document);
        }

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                List<Node> nodes = sentence.getTree().getRoot().getOrderedDescendants();
                for (Node node : nodes) {
                    int rand_index = myrand(nodes.size());
                    if (myrand(10) == 0) {
                        node.shiftAfterNode(nodes.get(rand_index), false);
                    } else if (myrand(10) == 0) {
                        node.shiftBeforeSubtree(nodes.get(rand_index), true);
                    }
                }
            }
        }
        System.out.println("reorder");
        if (debug) {
            writeDoc("java-reorder.conllu", document);
        }

        DocumentWriter coNLLUWriter = new CoNLLUWriter(Paths.get(outCoNLL));
        coNLLUWriter.writeDocument(document);
        System.out.println("save");

        document = null;
        System.gc(); // suggestion for garbage collection (In Java, it is difficult to force gc).
        System.out.println("free");
    }

    private static void writeDoc(String fileName, Document document) {
        DocumentWriter coNLLUWriter = new CoNLLUWriter(Paths.get(fileName));
        coNLLUWriter.writeDocument(document);
    }
}
