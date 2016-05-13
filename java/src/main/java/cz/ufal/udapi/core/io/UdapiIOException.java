package cz.ufal.udapi.core.io;

/**
 * Created by mvojtek on 12/21/15.
 */
public class UdapiIOException extends RuntimeException {
    public UdapiIOException() {
    }

    public UdapiIOException(String message) {
        super(message);
    }

    public UdapiIOException(String message, Throwable cause) {
        super(message, cause);
    }

    public UdapiIOException(Throwable cause) {
        super(cause);
    }

    public UdapiIOException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
