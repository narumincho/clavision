package clavision;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.Arrays;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class Index
 */
@WebServlet("/Index")
public class Index extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Index() {
        super();
        // TODO Auto-generated constructor stub
    }

    public static void main(String[] args) {
		System.out.println("データベースの操作サンプル");
		try {
			System.out.println(Class.forName("org.postgresql.Driver"));
			Connection connection = DatabaseAccess.getConnection();
			final PreparedStatement preparedStatement = connection.prepareStatement("insert into \"user\" values(?, ?, ?, ?)");
			preparedStatement.setObject(1, java.util.UUID.randomUUID());
			byte[] bytes = MessageDigest.getInstance("SHA-256").digest("sorena".getBytes());
			System.out.println(Arrays.toString(bytes));
			preparedStatement.setBytes(2,bytes);
			preparedStatement.setString(3, "lineのID");
			preparedStatement.setString(4, "lineの名前");
			preparedStatement.execute();

			final Statement statement = connection.createStatement();
			final ResultSet resultSet = statement.executeQuery("select * from \"user\"");
			while(resultSet.next()){
				System.out.println(resultSet.getObject(1));
				System.out.println(Arrays.toString(resultSet.getBytes(2)));
				System.out.println(resultSet.getString(3));
				System.out.println(resultSet.getString(4));
				System.out.println("=====================================");
			}
		} catch (ClassNotFoundException | SQLException | NoSuchAlgorithmException e) {
			e.printStackTrace();
		}

	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
