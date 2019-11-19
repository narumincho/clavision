package clavision;

import clavision.User;

public class UserDAO {
  private static User sampleUser =
      new User("sampleUserId", new byte[256 / 8], "sampleUserLineId", "Sample User");

  public static User getByAccessTokenHash(byte[] accessTokenHash) {
    return sampleUser;
  }

  public static User getByUserId(String userId) {
    return sampleUser;
  }

  public static void updateAccessTokenHash(String userId, byte[] accessTokenHash) {}

  public static void createUser(User user) {}
}
