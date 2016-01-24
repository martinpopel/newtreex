package cz.cuni.mff.ufal.treex.core;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface NLPTree {
    Node getRoot();
    Document getDocument();
    Bundle getBundle();

    void normalizeOrder();
}
