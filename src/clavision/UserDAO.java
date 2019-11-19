package clavision;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {
  private static User sampleUser =
      new User("sampleUserId", new byte[256 / 8], "sampleUserLineId", "Sample User");

  static User getByAccessTokenHash(byte[] accessTokenHash) {
    Connection connection = DatabaseAccess.getConnection();
    try {
      PreparedStatement preparedStatement =
          connection.prepareStatement("select * from user where accessTokenHash=?");
      preparedStatement.setBytes(0, accessTokenHash);
      ResultSet resultSet = preparedStatement.executeQuery();
      if (!resultSet.next()) {
        throw new Error("accessToken is invalid");
      }
      ;
      return new User(
          resultSet.getString("user_id"),
          resultSet.getBytes("access_token_hash"),
          resultSet.getString("line_id"),
          resultSet.getString("user_name_in_line"));

    } catch (SQLException e) {
      e.printStackTrace();
    }

    return sampleUser;
  }

  static User getByLineId(String userId) {
    return sampleUser;
  }

  public static void updateAccessTokenHash(String userId, byte[] accessTokenHash) {}

  public static void createUser(User user) {}
}
