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
    private static long maxseed = 1 << 32;
    private static int myrand(long modulo) {
        seed = (1103515245 * seed + 12345) % maxseed;
        return (int)(seed % modulo);
    }

    public static void main(String[] args) {
        String inCoNLL = args[0];
        String outCoNLL = args[1];
        System.out.println("init");

        DocumentReader coNLLUReader = new CoNLLUReader(Paths.get(inCoNLL));
        Document document = coNLLUReader.readDocument();
        System.out.println("load");

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

        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                List<Node> descendants = sentence.getTree().getRoot().getDescendants();
                for (Node node : descendants) {
                    // TODO: catch exception if a cycle would be created
                    int rand_index = myrand(descendants.size());
                    node.setParent(descendants.get(rand_index));
                }
            }
        }
        System.out.println("rehang");

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

        DocumentWriter coNLLUWriter = new CoNLLUWriter(Paths.get(outCoNLL));
        coNLLUWriter.writeDocument(document);
        System.out.println("save");
    }
}
