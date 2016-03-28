package cz.cuni.mff.ufal.treex.block.util;

import cz.cuni.mff.ufal.treex.core.Block;
import cz.cuni.mff.ufal.treex.core.Document;
import cz.cuni.mff.ufal.treex.exception.TreexException;

import java.lang.reflect.Method;
import java.util.Map;

/**
 * Created by mvojtek on 3/27/16.
 *
 * Example usage:
 * Util::Eval expression="println doc"
 */
public class Eval extends Block {

    private final Map<String, String> params;

    public Eval(Map<String, String> params) {
        super(params);
        this.params = params;
        if (!params.containsKey("expression")) {
            throw new TreexException("No expression parameter specified.");
        }
    }

    @Override
    public void processDocument(Document document) {

        String expression = params.get("expression");
        try {
            Method evalMethod = Class.forName("groovy.util.Eval").getMethod("me", String.class, Object.class, String.class);
            evalMethod.invoke(null, "doc", document, expression);
        } catch (Exception e) {
            throw new TreexException("Failed to evaluate expression", e);
        }
    }
}
