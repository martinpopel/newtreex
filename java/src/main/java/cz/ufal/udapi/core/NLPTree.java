package cz.ufal.udapi.core;

import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface NLPTree {
    Node getRoot();
    Document getDocument();
    Bundle getBundle();
    void addComment(String comment);
    List<String> getComments();
    void addMultiword(String multiword);
    List<String> getMultiwords();
    void setText(String sentenceText);
    String getText();
    void normalizeOrder();
}
