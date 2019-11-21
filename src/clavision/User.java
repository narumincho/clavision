package clavision;

import java.io.Serializable;
import java.util.UUID;

@SuppressWarnings("serial")
public class User implements Serializable {
  private UUID userId;
  private byte[] accessTokenHash;
  private String lineId;
  private String userNameInLine;

  public User(UUID userId, byte[] accessTokenHash, String lineId, String userNameInLine) {
    this.userId = userId;
    this.accessTokenHash = accessTokenHash;
    this.lineId = lineId;
    this.userNameInLine = userNameInLine;
  }

  public final UUID getUserId() {
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
