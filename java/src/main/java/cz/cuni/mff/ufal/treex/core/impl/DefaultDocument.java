package cz.cuni.mff.ufal.treex.core.impl;

import cz.cuni.mff.ufal.treex.core.Bundle;
import cz.cuni.mff.ufal.treex.core.Document;

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

    @Override
    public void addBundle(Bundle bundle) {
        bundles.add(bundle);
    }

    @Override
    public List<Bundle> getBundles() {
        return bundles;
    }

}
