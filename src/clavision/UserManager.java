package clavision;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class UserManager {
  static void initial() {
    UserDAO.createTable();
  }

  public static User logInWithAccessToken(String accessToken) {
    try {
      final byte[] accessTokenHash =
          MessageDigest.getInstance("SHA-256").digest(accessToken.getBytes());
      return UserDAO.getByAccessTokenHash(accessTokenHash);

    } catch (NoSuchAlgorithmException e) {
      e.printStackTrace();
    }
    return null;
  }

  public static User logInWithLineCode(String code) {
    return UserDAO.getByLineId(code);
  }
}
