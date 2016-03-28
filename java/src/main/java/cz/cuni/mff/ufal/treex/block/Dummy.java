package cz.cuni.mff.ufal.treex.block;

import cz.cuni.mff.ufal.treex.core.Block;
import cz.cuni.mff.ufal.treex.core.NLPTree;
import cz.cuni.mff.ufal.treex.core.Node;

import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by mvojtek on 3/26/16.
 */
public class Dummy extends Block {

    public Dummy(Map<String, String> params) {
        super(params);
    }

    @Override
    public void processTree(NLPTree tree, int bundleNo) {
        System.out.println(tree.getRoot().getDescendants().stream().map(node -> node.getForm()).collect(Collectors.joining(" ")));
    }

    @Override
    public void processNode(Node node, int bundleNo) {
        System.out.println(node.getLemma());
    }
}
