package com.oceanview.controller;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/UserManagementServlet")
public class UserManagementServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User u = new User();
        u.setUsername(request.getParameter("newUsername"));
        u.setPassword(request.getParameter("newPassword"));
        u.setRole(request.getParameter("role"));

        try {
            userDAO.registerUser(u);
            response.sendRedirect("admin_dashboard.jsp?status=success");
        } catch (Exception e) {
            response.sendRedirect("manage_users.jsp?status=error");
        }
    }
}