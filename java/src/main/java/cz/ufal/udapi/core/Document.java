package cz.ufal.udapi.core;

import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface Document {
    int getUniqueNodeId();

    void addBundle(Bundle bundle);
    Bundle addBundle();
    List<Bundle> getBundles();
    Bundle getDefaultBundle();
}
