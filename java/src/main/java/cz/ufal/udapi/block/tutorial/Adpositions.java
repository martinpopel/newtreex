package cz.ufal.udapi.block.tutorial;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.Node;

import java.util.Map;

/**
 * Created by mvojtek on 4/17/16.
 *
 * Example usage:
 * <code>
 *     for a in *&#47;*dev*.conllu; do
 *         printf '%50s ' $a;
 *         cat $a | udapi.groovy Read::CoNLLU Tutorial::Adpositions;
 *     done | tee ~/results.txt
 *
 *     # https://lindat.mff.cuni.cz/services/pmltq/#!/treebank/ud_cs/help
 *     a-node $A:= [
 *       child a-node [
 *         conll/cpos = 'ADP',
 *         ord > $A.ord,
 *       ]
 *     ]
 * </code>
 */
public class Adpositions extends Block {

    private int prepositions;
    private int postpositions;

    private static final String ADP = "ADP";

    @Override
    public void processNode(Node node, int bundleNo) {
        // TODO: Your task: distinguish prepositions and postpositions
        if (ADP.equals(node.getUpos())) {
            prepositions++;
        }
    }

    @Override
    public void processEnd() {
        int all = prepositions + postpositions;
        System.out.printf("prepositions %5.1f%%, postpositions %5.1f%%\n",
                prepositions*100 / (float)all, postpositions*100 / (float)all);
    }
}
