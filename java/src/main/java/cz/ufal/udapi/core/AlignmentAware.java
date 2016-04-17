package cz.ufal.udapi.core;

import java.util.LinkedHashMap;
import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface AlignmentAware {
    List<Node> getAlignmentNodes();

    /**
     *
     * @param language
     * @param selector
     * @return map of aligned nodes with mapped type
     */
    LinkedHashMap<Node, String> getAlignedNodesByTree(String language, String selector);

    /**
     *
     * @param language
     * @param selector
     * @param typeRegex
     * @return aligned nodes with given type
     */
    List<Node> getAlignedNodesOfType(String language, String selector, String typeRegex);

    boolean isAlignedTo(Node node, String typeRegex);

    void deleteAlignedNode(Node node, String type);

    void addAlignedNode(Node node, String type);

    /**
     * Remove invalid alignment links (leading to unindexed nodes).
     */
    void updateAlignedNodes();
}
