package cz.ufal.udapi.exception;

/**
 * Created by mvojtek on 3/26/16.
 */
public class UdapiException extends RuntimeException {
    public UdapiException() {
        super();
    }

    public UdapiException(String message) {
        super(message);
    }

    public UdapiException(String message, Throwable cause) {
        super(message, cause);
    }

    public UdapiException(Throwable cause) {
        super(cause);
    }

    protected UdapiException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}
