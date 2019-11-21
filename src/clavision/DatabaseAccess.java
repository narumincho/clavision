package clavision;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.DriverManager;

class DatabaseAccess {
  private static final String dbName = "tutorial";
  private static final String sqlHostname = "localhost";
  private static final String url = "jdbc:postgresql://" + sqlHostname + "/" + dbName;
  private static Connection connection;

  static Connection getConnection() {
    if (connection == null) {
      try {
        Class.forName("org.postgresql.Driver");
        connection = DriverManager.getConnection(url, "postgres", Key.postgresPassword);
        return connection;
      } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
      }
    }
    return connection;
  }
}
