package cz.ufal.udapi.core;

import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface Bundle {
    void addTree(Root root);
    Root addTree();
    List<Root> getTrees();
    void setDocument(Document document);
    Document getDocument();
    String getId();
    void setId(String id);
}
