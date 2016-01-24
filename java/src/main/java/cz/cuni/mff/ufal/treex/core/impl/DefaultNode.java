package cz.cuni.mff.ufal.treex.core.impl;

import cz.cuni.mff.ufal.treex.core.NLPTree;
import cz.cuni.mff.ufal.treex.core.Node;

import java.util.*;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public class DefaultNode implements Node {

    private final NLPTree tree;

    private final int id;
    private int ord = -1;

    private String form;
    private String lemma;
    private String upos;
    private String postag;
    private String feats;
    private String head;
    private String deprel;
    private String deps;
    private String misc;

    private final List children = new ArrayList<>(0);

    private Optional<Node> parent;

    public DefaultNode(NLPTree tree, Node parent) {
        this.parent = Optional.ofNullable(parent);
        this.tree = tree;
        this.id = tree.getDocument().generate_new_id();
    }

    public DefaultNode(NLPTree tree, Node parent, int id) {
        this.parent = Optional.ofNullable(parent);
        this.tree = tree;
        this.id = id;
    }

    public DefaultNode(NLPTree tree) {
        this(tree, null);
    }

    @Override
    public void remove() {
        getParent().ifPresent(node -> node.getChildren().remove(this));
        getTree().normalizeOrder();
    }

    @Override
    public List<Node> getReferencingNodes() {
        //TODO: implement
        return null;
    }

    @Override
    public Node createChild() {
        Node newChild = createNode();
        newChild.setParent(this);
        return newChild;
    }

    protected Node createNode() {
        return new DefaultNode(tree);
    }

    protected NLPTree getTree() {
        return tree;
    }

    @Override
    public List<Node> getChildren() {
        return children;
    }

    @Override
    public Optional<Node> getParent() {
        return parent;
    }

    @Override
    public void setParent(Node node, boolean ...skipCyles) {

        //check cycle
        if (skipCyles.length == 1 && skipCyles[0] == true &&
                (this.equals(node) || node.isDescendantOf(this))) {
            //skip cycle
            return;
        }

        //fix children of my parent
        if (parent.isPresent()) {
            parent.get().getChildren().remove(this);
        }

        //add self as the last child of my new parent
        this.parent = Optional.of(node);
        node.getChildren().add(this);
    }

    @Override
    public Node getRoot() {
        return tree.getRoot();
    }

    @Override
    public boolean isRoot() {
        return tree.getRoot().equals(this);
    }

    @Override
    public boolean isLeaf() {
        return 0 == getChildren().size();
    }

    @Override
    public List<Node> getDescendants() {
        List<Node> descendants = new ArrayList<>();
        for (Node child : getChildren()) {
            descendants.add(child);
            descendants.addAll(child.getDescendants());
        }
        return descendants;
    }

    @Override
    public List<Node> getOrderedDescendants() {
        List<Node> descendants = getDescendants();
        descendants.sort((o1, o2) -> o1.getOrd() - o2.getOrd());
        return descendants;
    }

    @Override
    public List<Node> getSiblings() {
        if (parent.isPresent()) {
            List siblings = new ArrayList<>(parent.get().getChildren());
            siblings.remove(this);
            return siblings;
        } else return new ArrayList<>();
    }

    @Override
    public Optional<Node> getPrevSibling() {
        if (parent.isPresent()) {
            List<Node> parentChildren = parent.get().getChildren();

            int index = parentChildren.indexOf(this);
            if (index != -1 && index > 0) {
                return Optional.of(parentChildren.get(index - 1));
            }
        }

        return Optional.empty();
    }

    @Override
    public Optional<Node> getNextSibling() {
        if (parent.isPresent()) {
            List<Node> parentChildren = parent.get().getChildren();

            int index = parentChildren.indexOf(this);
            if (index != -1 && index < parentChildren.size() - 1) {
                return Optional.of(parentChildren.get(index + 1));
            }
        }

        return Optional.empty();
    }

    @Override
    public boolean isDescendantOf(Node node) {
        Optional<Node> pathParent = parent;
        while (pathParent.isPresent()) {
            if (pathParent.get().equals(node)) {
                return true;
            } else {
                pathParent = pathParent.get().getParent();
            }
        }
        return false;
    }

    public void shiftAfterNode(Node node, boolean withoutChildren) {
        if (this.equals(node)) return;
        if (node.isDescendantOf(this)) return;

        shiftToNode(node, true, withoutChildren);
    }

    public void shiftBeforeNode(Node node, boolean withoutChildren) {
        if (this.equals(node)) return;
        if (node.isDescendantOf(this)) return;

        shiftToNode(node, false, withoutChildren);
    }

    public void shiftAfterSubtree(Node node, boolean withoutChildren) {
        //get last descendants according to ord
        List<Node> descendants = node.getDescendants();
        descendants.add(node);
        descendants.remove(this);
        descendants.sort((o1, o2) -> o1.getOrd() - o2.getOrd());


        if (0 == descendants.size()) {
            //nothing to do
            return;
        } else {
            Node lastDescendant = descendants.get(descendants.size()-1);
            shiftToNode(lastDescendant, true, withoutChildren);
        }
    }

    public void shiftBeforeSubtree(Node node, boolean withoutChildren) {
        //get last descendants according to ord
        List<Node> descendants = node.getDescendants();
        descendants.add(node);
        descendants.remove(this);
        descendants.sort((o1, o2) -> o1.getOrd() - o2.getOrd());

        if (0 == descendants.size()) {
            //nothing to do
            return;
        } else {
            Node firstDescendant = descendants.get(0);
            shiftToNode(firstDescendant, false, withoutChildren);
        }
    }

    private void shiftToNode(Node node, boolean after, boolean withoutChildren) {
        List<Node> allNodes = getRoot().getDescendants();

        int maxOrd = 10000;
        for (Node descendant : allNodes) {
            if (descendant.getOrd() == -1) {
                descendant.setOrd(maxOrd++);
            }
        }

        List<Node> nodesToMove;

        if (withoutChildren) {
            nodesToMove = new ArrayList<>(1);
            nodesToMove.add(this);
        } else {
            nodesToMove = this.getDescendants();
            nodesToMove.add(this);
            nodesToMove.sort((o1, o2) -> o1.getOrd() - o2.getOrd());
        }
        //order them
        allNodes.sort((o1, o2) -> o1.getOrd() - o2.getOrd());

        Set<Node> isMoving = new HashSet<>(nodesToMove);

        int counter = 1;
        boolean nodesMoved = false;

        for (Node aNode : allNodes) {
            if (isMoving.contains(aNode)) {
                //skip nodes which are moving
                continue;
            }

            if (after) {
                aNode.setOrd(counter++);
            }

            if (aNode.equals(node)) {
                for (Node nodeToMove : nodesToMove) {
                    (nodeToMove).setOrd(counter++);
                }
                nodesMoved = true;
            }

            if (!after) {
                aNode.setOrd(counter++);
            }
        }

        if (!nodesMoved) {
            for (Node nodeToMove : nodesToMove) {
                nodeToMove.setOrd(counter++);
            }
        }
    }

    @Override
    public int getDepth() {
        int depth = 0;
        Optional<Node> pathParent = parent;
        while (pathParent.isPresent()) {
            depth++;
            pathParent = parent.get().getParent();
        }
        return depth;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        DefaultNode that = (DefaultNode) o;

        return id == that.id;
    }

    @Override
    public int hashCode() {
        return id;
    }

    public int getOrd() {
        return ord;
    }

    public void setOrd(int ord) {
        this.ord = ord;
    }

    public int getId() {
        return id;
    }

    public String getForm() {
        return form;
    }

    public void setForm(String form) {
        this.form = form;
    }

    public String getLemma() {
        return lemma;
    }

    public void setLemma(String lemma) {
        this.lemma = lemma;
    }

    public String getUpos() {
        return upos;
    }

    public void setUpos(String upos) {
        this.upos = upos;
    }

    public String getPostag() {
        return postag;
    }

    public void setPostag(String postag) {
        this.postag = postag;
    }

    public String getFeats() {
        return feats;
    }

    public void setFeats(String feats) {
        this.feats = feats;
    }

    public String getHead() {
        return head;
    }

    public void setHead(String head) {
        this.head = head;
    }

    public String getDeprel() {
        return deprel;
    }

    public void setDeprel(String deprel) {
        this.deprel = deprel;
    }

    public String getDeps() {
        return deps;
    }

    public void setDeps(String deps) {
        this.deps = deps;
    }

    public String getMisc() {
        return misc;
    }

    public void setMisc(String misc) {
        this.misc = misc;
    }
}
