package com.oceanview.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;

/**
 * Servlet implementation for User Authentication (Login).
 * Path mapping: /LoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() {
        // Dependency is initialized; UserDAO now handles hashing verification
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Collect inputs from index.jsp
        // Note: The password is still plain text here; it gets verified in the DAO
        String username = request.getParameter("username");
        String password = request.getParameter("password"); 

        // 2. Delegate authentication to the DAO
        // The DAO now fetches the hash from DB and uses PasswordHasher.checkPassword()
        User user = userDAO.authenticate(username, password);

        if (user != null) {
            // 3. Authentication Successful: Create Session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            
            // 4. Access Control: Redirect based on Actor role
            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("admin_dashboard.jsp");
            } else {
                // Default redirect for STAFF or other recognized roles
                response.sendRedirect("staff_dashboard.jsp");
            }
        } else {
            // 5. Authentication Failed: Provide feedback
            request.setAttribute("errorMessage", "Invalid Username or Password. Please try again.");
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Securely redirect GET attempts back to the login page
        response.sendRedirect("index.jsp");
    }
}