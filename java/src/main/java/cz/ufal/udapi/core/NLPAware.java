package cz.ufal.udapi.core;

/**
 * Created by martin.vojtek on 13. 12. 2015.
 */
public interface NLPAware {

    Attribute getAttribute(String attributeName);

    void setAttribute(String attributeName, Attribute attribute);

    /**
     *
     * @return Bundle associated with the given node.
     */
    Bundle getBundle();

    /**
     *
     * @return Document associated with the given node.
     */
    Document getDocument();

    void setSentence(Sentence sentence);

    Sentence getSentence();

    //TODO: is it String?
    String getLanguage();

    //TODO: is it String?
    String getSelector();

    /**
     *
     * @return address of given node in terms of file and position.
     */
    String getAddress();
}
