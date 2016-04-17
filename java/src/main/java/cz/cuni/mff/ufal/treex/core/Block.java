package cz.cuni.mff.ufal.treex.core;

import java.util.Map;

/**
 * Created by mvojtek on 3/25/16.
 */
public class Block {

    private final Map<String, String> params;

    public Block(Map<String, String> params) {
        this.params = params;
    }

    protected Map<String, String> getParams() {
        return params;
    }

    public void processStart() {

    }

    public void processDocument(Document document) {
        int bundleNo = 1;
        for (Bundle bundle : document.getBundles()) {
            if (shouldProcessBundle(bundle, bundleNo)) {
                processBundle(bundle, bundleNo);
            }
        }
    }

    protected boolean shouldProcessBundle(Bundle bundle, int bundleNo) {
        //TODO: implement
        return true;
    }

    protected boolean shouldProcessTree(NLPTree tree) {
        //TODO: implement
        return true;
    }

    public void processBundle(Bundle bundle, int bundleNo) {
        for (Sentence sentence : bundle.getSentences()) {
            NLPTree tree = sentence.getTree();
            if (shouldProcessTree(tree)) {
                processTree(tree, bundleNo);
            }
        }
    }

    public void processTree(NLPTree tree, int bundleNo) {
        for (Node node : tree.getRoot().getDescendants()) {
            processNode(node, bundleNo);
        }
    }

    public void processNode(Node node, int bundleNo) {
        throw new RuntimeException("Block doesn't implement or override any of process* methods.");
    }
}
