package clavision;

import org.jetbrains.annotations.NotNull;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/api")
public class Api extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public Api() {
    super();
  }

  public static  void main(String[] args) {
    System.out.println("sorena");
  }

  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.setCharacterEncoding("UTF-8");
    response.getWriter().append("APIサーバにようこそ");
  }

  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    doGet(request, response);
  }

  @Override
  public void doDelete(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    doGet(req, resp);
  }
}
