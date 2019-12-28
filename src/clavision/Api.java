package clavision;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.StringJoiner;

@WebServlet("/api/*")
public class Api extends HttpServlet {
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.setCharacterEncoding("UTF-8");
    switch (request.getPathInfo()) {
      case "/lineLogInUrl":
        getLineLogInUrl(response);
        return;
    }
    response
        .getWriter()
        .append("error path=")
        .append(request.getPathInfo())
        .append("?")
        .append(request.getQueryString())
        .close();
  }

  private static void getLineLogInUrl(HttpServletResponse response) {
    try {
      URL url =
          new URI(
                  "https",
                  "access.line.me",
                  "/oauth2/v2.1/authorize",
                  URLQueryStringFromMap(
                      Map.of(
                          "response_type",
                          "code",
                          "client_id",
                          "1653666685",
                          "redirect_uri",
                          "http://localhost:8080/clavision/api/callback",
                          "scope",
                          "profile openid",
                          "state",
                          "abcd")),
                  "")
              .toURL();
      URLConnection urlConnection = url.openConnection();
      Object content = urlConnection.getContent();
      System.out.println(content);
      response.getWriter().append(content.toString());
    } catch (URISyntaxException | IOException e) {
      e.printStackTrace();
    }
  }

  private static String URLQueryStringFromMap(Map<String, String> hashMap) {
    StringJoiner stringJoiner = new StringJoiner("&");
    for (Map.Entry<String, String> entry : hashMap.entrySet()) {
      stringJoiner.add(
          URLEncoder.encode(entry.getKey(), StandardCharsets.UTF_8)
              + "="
              + URLEncoder.encode(entry.getValue(), StandardCharsets.UTF_8));
    }
    return stringJoiner.toString();
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
