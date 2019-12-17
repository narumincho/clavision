package clavision;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class Hello extends HttpServlet {
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {

    response.setCharacterEncoding("UTF-8");
    PrintWriter out = response.getWriter();
    out.println("<html>");
    out.println("<meta charset=\"UTF-8\">");
    out.println("できたかの確認!!!! どうだ?");
    out.println("</html>");
    out.close();
  }
}
