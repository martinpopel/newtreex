package cz.cuni.mff.ufal.treex.core;

import java.util.List;
import java.util.Optional;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface Node {

    /**
     * Remove node from the tree. Only non-root nodes can be removed.
     */
    void remove();

    /**
     * Return all nodes that have a reference of the given type (e.g. 'alignment', 'a/lex.rf') to this node.
     */
    List<Node> getReferencingNodes();

    /**
     * Creates new child of the given node and returns it.
     * @return new child
     */
    Node createChild();

    List<Node> getChildren();

    List<Node> getOrderedChildren();

    /**
     * Returns parent node.
     * @return parent node
     */
    Optional<Node> getParent();

    void setParent(Node node, boolean ...skipCycles);

    Node getRoot();

    boolean isRoot();

    boolean isLeaf();

    List<Node> getDescendants();

    List<Node> getOrderedDescendants();

    List<Node> getSiblings();

    Optional<Node> getPrevSibling();

    Optional<Node> getNextSibling();

    boolean isDescendantOf(Node node);

    int getDepth();

    int getId();

    String getForm();

    void setForm(String form);

    String getLemma();

    void setLemma(String lemma);

    String getUpos();

    void setUpos(String upos);

    String getPostag();

    void setPostag(String postag);

    String getFeats();

    void setFeats(String feats);

    String getHead();

    void setHead(String head);

    String getDeprel();

    void setDeprel(String deprel);

    String getDeps();

    void setDeps(String deps);

    String getMisc();

    void setMisc(String misc);

    int getOrd();

    void setOrd(int ord);

    void shiftAfterNode(Node node, boolean withoutChildren);

    void shiftBeforeNode(Node node, boolean withoutChildren);

    void shiftAfterSubtree(Node node, boolean withoutChildren);

    void shiftBeforeSubtree(Node node, boolean withoutChildren);
}
