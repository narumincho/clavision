package clavision;

import org.jetbrains.annotations.NotNull;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class Api extends HttpServlet {
  private static final long serialVersionUID = 1L;

  public Api() {
    super();
  }

  @Override
  protected void doGet(@NotNull HttpServletRequest request, @NotNull HttpServletResponse response)
      throws ServletException, IOException {
    response.getWriter().append("APIサーバにようこそ");
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    doGet(request, response);
  }

  @Override
  protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    doGet(req, resp);
  }
}
