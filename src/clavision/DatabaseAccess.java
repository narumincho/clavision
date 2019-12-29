package clavision;

import org.jetbrains.annotations.NotNull;

import java.sql.SQLException;
import java.sql.Connection;
import java.util.Properties;

class DatabaseAccess {
  private static final String dbName = "tutorial";
  private static final String sqlHostname = "localhost";
  private static final String url = "jdbc:postgresql://" + sqlHostname + "/" + dbName;
  private static Connection connection;

  static @NotNull Connection getConnection() {
    System.out.println("always call in getConnection");
    if (connection == null) {
      try {
        Properties properties = new Properties();
        properties.setProperty("user", "postgres");
        properties.setProperty("password", Key.postgresPassword);
        connection = new org.postgresql.Driver().connect(url, properties);
        if (connection == null) {
          System.out.println("cannot get connection using DriverManager.getConnection");
        }
        return connection;
      } catch (SQLException e) {
        System.out.println("エラー説明開始");
        System.out.println(e.toString());
        System.out.println("エラー説明終了");
      }
    }
    return connection;
  }
}
