package clavision;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.*;
import java.nio.charset.StandardCharsets;

@WebServlet("/api/*")
public class Api extends HttpServlet {
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.setCharacterEncoding("UTF-8");
    switch (request.getPathInfo()) {
      case "/logInUrl":
        getLineLogInUrl();
    }
    response.getWriter().append("パスは").append(request.getPathInfo()).close();
  }

  private static void getLineLogInUrl() {
    try {
      String query =
          URLEncoder.encode("response_type", StandardCharsets.UTF_8)
              + "="
              + URLEncoder.encode("code", StandardCharsets.UTF_8);
      URL url = new URI("https", "access.line.me", "/oauth2/v2.1/authorize", query, "").toURL();
      URLConnection urlConnection = url.openConnection();
      Object content = urlConnection.getContent();
      System.out.println(content);
    } catch (URISyntaxException | IOException e) {
      e.printStackTrace();
    }
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
