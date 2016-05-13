package cz.ufal.udapi.core;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by mvojtek on 3/25/16.
 */
public class Block {

    private final Map<String, String> params;

    public Block() {
        this(new HashMap<>());
    }

    public Block(Map<String, String> params) {
        this.params = params;
    }

    protected Map<String, String> getParams() {
        return params;
    }

    public void processStart() {}

    public void processEnd() {}

    public void beforeProcessDocument(Document document) {}

    public void processDocument(Document document) {
        int bundleNo = 1;
        for (Bundle bundle : document.getBundles()) {
            if (shouldProcessBundle(bundle, bundleNo)) {
                beforeProcessBundle(bundle, bundleNo);
                processBundle(bundle, bundleNo);
                afterProcessBundle(bundle, bundleNo);
            }
            bundleNo++;
        }
    }

    public void afterProcessDocument(Document document) {}

    protected boolean shouldProcessBundle(Bundle bundle, int bundleNo) {
        return true;
    }

    protected boolean shouldProcessTree(Root tree) {
        return true;
    }

    public void beforeProcessBundle(Bundle bundle, int bundleNo) {}

    public void processBundle(Bundle bundle, int bundleNo) {
        for (Root tree : bundle.getTrees()) {
            if (shouldProcessTree(tree)) {
                processTree(tree, bundleNo);
            }
        }
    }

    public void afterProcessBundle(Bundle bundle, int bundleNo) {}

    public void processTree(Root tree, int bundleNo) {
        //wrap with ArrayList to prevent ConcurrentModificationException
        for (Node node : new ArrayList<>(tree.getDescendants())) {
            processNode(node, bundleNo);
        }
    }

    public void processNode(Node node, int bundleNo) {
        throw new RuntimeException("Block doesn't implement or override any of process* methods.");
    }
}
