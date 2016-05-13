package cz.ufal.udapi.core;

import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface Root {
    String DEFAULT_ZONE = "und";

    Node getNode();
    Document getDocument();
    void setBundle(Bundle bundle);
    Bundle getBundle();
    void addComment(String comment);
    List<String> getComments();
    void addMultiword(String multiword);
    List<String> getMultiwords();
    void setSentence(String sentenceText);
    String getSentence();
    void normalizeOrder();
    List<Node> getDescendants();
    void setZone(String zone);
    String getZone();
    Root copyTree();
    String getId();
    void setId(String id);
    void validateZone();
}
