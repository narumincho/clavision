package clavision;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/")
public class Hello extends HttpServlet {
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {

    response.setCharacterEncoding("UTF-8");
    response
        .getWriter()
        .append("<html>")
        .append("<meta charset=\"utf-8\">")
        .append("できたかの確認 これはHello")
        .append("</html>")
        .close();
  }
}
