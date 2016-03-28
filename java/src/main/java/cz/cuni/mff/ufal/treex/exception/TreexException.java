package cz.cuni.mff.ufal.treex.exception;

/**
 * Created by mvojtek on 3/26/16.
 */
public class TreexException extends RuntimeException {
    public TreexException() {
        super();
    }

    public TreexException(String message) {
        super(message);
    }

    public TreexException(String message, Throwable cause) {
        super(message, cause);
    }

    public TreexException(Throwable cause) {
        super(cause);
    }

    protected TreexException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
