package clavision;

import java.sql.*;

public class UserDAO {
  private static User sampleUser =
      new User("sampleUserId", new byte[256 / 8], "sampleUserLineId", "Sample User");
  private static final String tableName = "user";
  private static final String userIdLabel = "user_id";
  private static final String accessTokenHashLabel = "access_token_hash";
  private static final String lineIdLabel = "line_id";
  private static final String userNameInLineLabel = "user_name_in_line";

  static void createTable() {
//    System.out.println("ok...");
        Connection connection = DatabaseAccess.getConnection();

    //    try {
    //      final Statement statement = connection.createStatement();
    //      statement.executeUpdate("select * from \"user\"");
    //      statement.executeUpdate(
    //          "create table \""
    //              + tableName
    //              + "\" ("
    //              + userIdLabel
    //              + " uuid, "
    //              + accessTokenHashLabel
    //              + " bit(256), "
    //              + lineIdLabel
    //              + " text,"
    //              + userNameInLineLabel
    //              + " text)");
    //    } catch (SQLException e) {
    //      e.printStackTrace();
    //    }
  }

  static User getByAccessTokenHash(byte[] accessTokenHash) {
    Connection connection = DatabaseAccess.getConnection();
    try {
      final PreparedStatement preparedStatement =
          connection.prepareStatement("select * from user where accessTokenHash=?");
      preparedStatement.setBytes(0, accessTokenHash);
      final ResultSet resultSet = preparedStatement.executeQuery();
      if (!resultSet.next()) {
        throw new Error("accessToken is invalid");
      }

      return new User(
          resultSet.getString(userIdLabel),
          resultSet.getBytes(accessTokenHashLabel),
          resultSet.getString(lineIdLabel),
          resultSet.getString(userNameInLineLabel));

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
