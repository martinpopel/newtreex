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
import java.util.Random;
import java.util.Set;

/**
 * Created by mvojtek on 12/21/15.
 */
public class Main {
    public static void main(String[] args) {
        String inCoNLL = args[0];
        String outCoNLL = args[1];
        System.out.println("init");

        DocumentReader coNLLUReader = new CoNLLUReader(Paths.get(inCoNLL));
        Document document = coNLLUReader.readDocument();
        System.out.println("load");

        DocumentWriter coNLLUWriter = new CoNLLUWriter(Paths.get(outCoNLL));
        coNLLUWriter.writeDocument(document);
        System.out.println("save");

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

        Random hangRand = new Random();
        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                List<Node> descendants = sentence.getTree().getRoot().getDescendants();
                for (Node node : descendants) {
                    //rehang
                    node.setParent(descendants.get(hangRand.nextInt(descendants.size())));
                }
            }
        }
        System.out.println("rehang");

        Random removedRand = new Random();
        Set<Node> alreadyRemoved = new HashSet<>();
        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getOrderedDescendants()) {
                    if (removedRand.nextInt(10) == 0) {
                        if (!alreadyRemoved.contains(node)) {
                            node.remove();
                            alreadyRemoved.add(node);
                        }
                    }
                }
            }
        }
        System.out.println("remove");

        Random addRand = new Random();
        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                for (Node node : sentence.getTree().getRoot().getOrderedDescendants()) {
                    if (addRand.nextInt(10) == 0) {
                        Node nodeChild = node.createChild();
                        nodeChild.setLemma("x");
                        nodeChild.setForm("x");
                        nodeChild.shiftAfterSubtree(node, false);
                    }
                }
            }
        }
        System.out.println("add");

        Random reorderRand = new Random();
        for (Bundle bundle : document.getBundles()) {
            for (Sentence sentence : bundle.getSentences()) {
                List<Node> nodes = sentence.getTree().getRoot().getOrderedDescendants();
                for (Node node : nodes) {
                    int rand_index = reorderRand.nextInt(nodes.size());
                    if (reorderRand.nextInt(10) == 0) {
                        node.shiftAfterNode(nodes.get(rand_index), false);
                    } else if (reorderRand.nextInt(10) == 0) {
                        node.shiftBeforeSubtree(nodes.get(rand_index), true);
                    }
                }
            }
        }
        System.out.println("reorder");
    }
}
