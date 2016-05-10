package cz.ufal.udapi.core.impl;

import cz.ufal.udapi.core.Bundle;
import cz.ufal.udapi.core.Document;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public class DefaultDocument implements Document {
    private final AtomicInteger nodeUniqueId = new AtomicInteger();
    private final AtomicInteger bundleUniqueId = new AtomicInteger();

    private List<Bundle> bundles = new ArrayList<>();

    @Override
    public int getUniqueNodeId() {
        return nodeUniqueId.incrementAndGet();
    }

    @Override
    public int getUniqueBundleId() {
        return bundleUniqueId.incrementAndGet();
    }

    public DefaultDocument() {
    }

    @Override
    public void addBundle(Bundle bundle) {
        bundles.add(bundle);
    }

    @Override
    public Bundle addBundle() {
        Bundle bundle = new DefaultBundle(this);
        bundles.add(bundle);
        return bundle;
    }

    @Override
    public List<Bundle> getBundles() {
        return bundles;
    }

    @Override
    public Bundle getDefaultBundle() {
        return bundles.get(0);
    }

}
