package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Controller to safely terminate sessions and prevent unauthorized access.
 */
@WebServlet("/LogoutServlet") // This mapping must match your href links exactly
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // Destroys session data to exit the system
        }
        // Redirect back to index with a status for user feedback
        response.sendRedirect("index.jsp?status=loggedout");
    }
}