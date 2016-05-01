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
    private final AtomicInteger uniqueId = new AtomicInteger();

    private List<Bundle> bundles = new ArrayList<>();

    @Override
    public int generate_new_id() {
        return uniqueId.incrementAndGet();
    }

    public DefaultDocument() {
        Bundle bundle = new DefaultBundle(this);
        bundles.add(bundle);
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

}
