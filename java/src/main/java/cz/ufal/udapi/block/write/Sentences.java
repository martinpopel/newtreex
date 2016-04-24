package cz.ufal.udapi.block.write;

import cz.ufal.udapi.core.Block;
import cz.ufal.udapi.core.NLPTree;
import cz.ufal.udapi.exception.TreexException;

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

    public Sentences(Map<String, String> params) {
        super(params);
        if (!params.containsKey(IF_MISSING)) {
            params.put(IF_MISSING, DETOKENIZE);
        }
    }

    @Override
    public void processTree(NLPTree tree, int bundleNo) {

        //TODO: select correct sentence or refactor
        String sentence = tree.getBundle().getSentences().get(0).getText();
        if (null == sentence) {
            if (getParams().containsKey(IF_MISSING)) {
                String ifMissing = getParams().get(IF_MISSING);
                if (DETOKENIZE.equals(ifMissing)) {
                    // TODO SpaceAfter=No
                    sentence = tree.getRoot().getDescendants().stream().map(node -> node.getForm()).collect(Collectors.joining(" "));
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

        System.out.println(sentence);
    }

}
