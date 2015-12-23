package cz.cuni.mff.ufal.treex.core.io;

/**
 * Created by mvojtek on 12/21/15.
 */
public class TreexIOException extends RuntimeException {
    public TreexIOException() {
    }

    public TreexIOException(String message) {
        super(message);
    }

    public TreexIOException(String message, Throwable cause) {
        super(message, cause);
    }

    public TreexIOException(Throwable cause) {
        super(cause);
    }

    public TreexIOException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
