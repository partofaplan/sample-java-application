package com.example.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.Instant;

@WebServlet(name = "helloServlet", urlPatterns = {"/"})
public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");

        try (PrintWriter writer = resp.getWriter()) {
            writer.println("<!DOCTYPE html>");
            writer.println("<html lang=\"en\">");
            writer.println("<head>");
            writer.println("<meta charset=\"UTF-8\">");
            writer.println("<title>Sample Java EE Application</title>");
            writer.println("</head>");
            writer.println("<body>");
            writer.println("<h1>Hello from the Sample Java EE application!</h1>");
            writer.println("<p>The current server time is " + Instant.now().toString() + ".</p>");
            writer.println("</body>");
            writer.println("</html>");
        }
    }
}
