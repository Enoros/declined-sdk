package io.declined;

public class DeclinedException extends RuntimeException {
  private final int status;
  private final String code;

  public DeclinedException(int status, String message, String code) {
    super(message);
    this.status = status;
    this.code = code;
  }

  public int getStatus() {
    return status;
  }

  public String getCode() {
    return code;
  }
}
