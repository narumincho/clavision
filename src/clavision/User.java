package clavision;

public class User {
  private String userId;
  private byte[] accessTokenHash;
  private String lineId;
  private String userNameInLine;

  public User(String userId, byte[] accessTokenHash, String lineId, String userNameInLine) {
    this.userId = userId;
    this.accessTokenHash = accessTokenHash;
    this.lineId = lineId;
    this.userNameInLine = userNameInLine;
  }

  public final String getUserId() {
    return userId;
  }

  public final byte[] getAccessTokenHash() {
    return accessTokenHash;
  }

  public final String getLineId() {
    return lineId;
  }

  public final String getUserNameInLine() {
    return userNameInLine;
  }
}
