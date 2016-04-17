package cz.ufal.udapi.core;

import java.util.List;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface Bundle {
    void addSentence(Sentence sentence);
    List<Sentence> getSentences();
}
