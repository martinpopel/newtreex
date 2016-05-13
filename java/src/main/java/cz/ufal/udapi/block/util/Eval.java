package cz.ufal.udapi.block.util;

import cz.ufal.udapi.core.*;
import cz.ufal.udapi.exception.UdapiException;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by mvojtek on 3/27/16.
 *
 * Example usage:
 * Util::Eval node="println doc"
 *
 * cat UD_Czech/cs-ud-dev.conllu | udapi.groovy Read::CoNLLU Util::Eval
 *     node='if (c.self.upos == "ADP" && !c.self.precedes(c.self.parent.get()))
 *     {println c.tree.root.getDescendants().collect{String val = "";
 *     if (it == c.self) { val = "***" } else if (it == c.self.parent.get())
 *     {val = "+++"}; val += it.form}.join(" ")}' | head
 */
public class Eval extends Block {

    private final Method evalMethod;

    private static final String DOC = "doc";
    private static final String BUNDLE = "bundle";
    private static final String TREE = "tree";
    private static final String NODE = "node";
    private static final String START = "start";
    private static final String END = "end";

    private static final String VAR_SELF = "self";
    private static final String VAR_DOCUMENT = "document";
    private static final String VAR_DOC = "doc";
    private static final String VAR_BUNDLE = "bundle";
    private static final String VAR_TREE = "tree";

    public Eval(Map<String, String> params) {
        super(params);
        try {
            evalMethod = Class.forName("groovy.util.Eval").getMethod("me", String.class, Object.class, String.class);
        } catch (Exception e) {
            throw new UdapiException("No groovy.util.Eval.me method available.", e);
        }
    }

    @Override
    public void processDocument(Document document) {
        if (getParams().containsKey(DOC)) {
            Map<String, Object> params = new HashMap<>();
            params.put(VAR_SELF, document);
            params.put(VAR_DOCUMENT, document);
            params.put(VAR_DOC, document);
            evaluate(params, getParams().get(DOC));
        }

        if (getParams().containsKey(BUNDLE) || getParams().containsKey(TREE) || getParams().containsKey(NODE)) {
            int bundleNo = 1;
            for (Bundle bundle : document.getBundles()) {
                if (shouldProcessBundle(bundle, bundleNo)) {
                    processBundle(bundle, bundleNo);
                }
                bundleNo++;
            }
        }
    }

    @Override
    public void processBundle(Bundle bundle, int bundleNo) {
        if (getParams().containsKey(BUNDLE)) {
            Map<String, Object> params = new HashMap<>();
            params.put(VAR_SELF, bundle);
            params.put(VAR_BUNDLE, bundle);
            params.put(VAR_DOCUMENT, bundle.getDocument());
            params.put(VAR_DOC, bundle.getDocument());
            evaluate(params, getParams().get(BUNDLE));
        }

        if (getParams().containsKey(TREE) || getParams().containsKey(NODE)) {
            for (Root tree : bundle.getTrees()) {
                if (shouldProcessTree(tree)) {
                    processTree(tree, bundleNo);
                }
            }
        }

    }

    @Override
    public void processTree(Root tree, int bundleNo) {
        if (getParams().containsKey(TREE)) {
            Map<String, Object> params = new HashMap<>();
            params.put(VAR_SELF, tree);
            params.put(VAR_TREE, tree);
            params.put(VAR_BUNDLE, tree.getBundle());
            params.put(VAR_DOCUMENT, tree.getBundle().getDocument());
            params.put(VAR_DOC, tree.getBundle().getDocument());
            evaluate(params, getParams().get(TREE));
        }

        if (getParams().containsKey(NODE)) {
            for (Node descendant : tree.getDescendants()) {
                Map<String, Object> params = new HashMap<>();
                params.put(VAR_SELF, descendant);
                params.put(VAR_TREE, tree);
                params.put(VAR_BUNDLE, tree.getBundle());
                params.put(VAR_DOCUMENT, tree.getBundle().getDocument());
                params.put(VAR_DOC, tree.getBundle().getDocument());
                evaluate(params, getParams().get(NODE));
            }
        }
    }

    @Override
    public void processStart() {
        if (getParams().containsKey(START)) {
            Map<String, Object> params = new HashMap<>();
            params.put(VAR_SELF, this);
            evaluate(params, getParams().get(START));
        }
    }

    @Override
    public void processEnd() {
        if (getParams().containsKey(END)) {
            Map<String, Object> params = new HashMap<>();
            params.put(VAR_SELF, this);
            evaluate(params, getParams().get(END));
        }
    }

    private void evaluate(Map arguments, String script) {
        try {
            evalMethod.invoke(null, "c", arguments, script);
        } catch (Exception e) {
            throw new UdapiException("Failed to evaluate expression", e);
        }
    }
}
