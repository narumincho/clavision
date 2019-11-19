package clavision;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.DriverManager;

public class DatabaseAccess {
  private static final String dbName = "tutorial";
  private static final String sqlHostname = "localhost";
  private static final String url = "jdbc:postgresql://" + sqlHostname + "/" + dbName;
  private static Connection connection;

  public static Connection getConnection() {
    if (connection == null) {
      try {
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(url, "postgres", Key.postgresPassword);
      } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
      }
    }
    return connection;
  }
}
