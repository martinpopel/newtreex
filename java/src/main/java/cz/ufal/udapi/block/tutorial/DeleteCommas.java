package cz.ufal.udapi.block.tutorial;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.Node;

/**
 * Created by mvojtek on 4/17/16.
 *
 * Example usage:
 * <code>
 *     for a in *&#47;*dev*.conllu; do
 *         printf '%50s ' $a;
 *         cat $a | udapi.pl Read::CoNLLU Tutorial::ToPositions;
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
public class DeleteCommas extends Block {

    @Override
    public void processNode(Node node, int bundleNo) {
        if (",".equals(node.getLemma())) {
            node.remove();
        }
    }

}
