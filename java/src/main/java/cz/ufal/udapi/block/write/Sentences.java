package cz.ufal.udapi.block.write;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.NLPTree;
import cz.ufal.udapi.exception.TreexException;

import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by mvojtek on 4/17/16.
 */
public class Sentences extends Block {

    public static final String IF_MISSING = "if_missing";

    public static final String DETOKENIZE = "detokenize";

    public static final String EMPTY = "empty";

    public static final String FATAL = "fatal";

    private final PrintStream ps;

    public Sentences(Map<String, String> params) {
        super(params);
        if (!params.containsKey(IF_MISSING)) {
            params.put(IF_MISSING, DETOKENIZE);
        }

        try {
            ps = new PrintStream(System.out, true, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            throw new TreexException(e);
        }
    }

    @Override
    public void processTree(NLPTree tree, int bundleNo) {

        String sentence = tree.getSentence();
        if (null == sentence) {
            if (getParams().containsKey(IF_MISSING)) {
                String ifMissing = getParams().get(IF_MISSING);
                if (DETOKENIZE.equals(ifMissing)) {
                    // TODO SpaceAfter=No
                    sentence = tree.getRoot().getOrderedDescendants().stream().map(node -> node.getForm()).collect(Collectors.joining(" "));
                } else  if (EMPTY.equals(ifMissing)) {
                    sentence = "";
                } else {
                    if (FATAL.equals(ifMissing)) {
                        throw new TreexException("Sentence " + bundleNo + " is undefined");
                    }
                }
            } else {
                System.err.println("Sentence " + bundleNo + " is undefined");
            }
        }

        ps.println(sentence);
    }

}
