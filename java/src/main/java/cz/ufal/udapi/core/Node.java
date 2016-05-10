package cz.ufal.udapi.core;

import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface Node {

    enum RemoveArg {
        REHANG, WARN
    }

    enum ChildrenArg {
        ADD_SELF, FIRST_ONLY, LAST_ONLY
    }

    enum DescendantsArg {
        ADD_SELF, FIRST_ONLY, LAST_ONLY
    }

    enum ShiftArg {
        WITHOUT_CHILDREN, SKIP_IF_DESCENDANT
    }

    /**
     * Remove node from the tree. Only non-root nodes can be removed.
     */
    void remove();

    /**
     * Creates new child of the given node and returns it.
     * @return new child
     */
    Node createChild();

    List<Node> getChildren();

    List<Node> getChildren(EnumSet<ChildrenArg> args);

    /**
     * Returns parent node.
     * @return parent node
     */
    Optional<Node> getParent();

    void setParent(Node node);

    void setParent(Node node, boolean skipCycles);

    Node getRoot();

    boolean isRoot();

    List<Node> getDescendants();

    List<Node> getDescendants(EnumSet<DescendantsArg> args, Optional<Node> except);

    List<Node> getSiblings();

    Optional<Node> getPrevSibling();

    Optional<Node> getNextSibling();

    void setNextSibling(Optional<Node> newNextSibling);

    Optional<Node> getPrevNode();

    Optional<Node> getNextNode();

    boolean isDescendantOf(Node node);

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

    void shiftAfterNode(Node node);

    void shiftAfterNode(Node node, EnumSet<ShiftArg> args);

    void shiftBeforeNode(Node node);

    void shiftBeforeNode(Node node, EnumSet<ShiftArg> args);

    void shiftAfterSubtree(Node node);

    void shiftAfterSubtree(Node node, EnumSet<ShiftArg> args);

    void shiftBeforeSubtree(Node node);

    void shiftBeforeSubtree(Node node, EnumSet<ShiftArg> args);

    boolean precedes(Node anotherNode);

    Optional<Node> getFirstChild();

    void remove(EnumSet<RemoveArg> args);

    NLPTree getTree();

    Bundle getBundle();
}
