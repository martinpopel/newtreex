package cz.cuni.mff.ufal.treex.core;

import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface Document {
    int generate_new_id();

    void addBundle(Bundle bundle);
    List<Bundle> getBundles();
}
