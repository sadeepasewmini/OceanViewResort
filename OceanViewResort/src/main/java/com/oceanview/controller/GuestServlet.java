package com.oceanview.controller;

import com.oceanview.dao.GuestDAO;
import com.oceanview.model.Guest;
import com.oceanview.model.User;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller for handling Guest Registration for Ocean View Resort.
 * Redirects back to role-specific dashboards with success status.
 */
@WebServlet("/GuestServlet")
public class GuestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private GuestDAO guestDAO;

    public void init() {
        guestDAO = new GuestDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session & Role Validation
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");
        
        if (loggedInUser == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Data Extraction
        String idNumber = request.getParameter("idNumber");
        String name = request.getParameter("name");
        String contact = request.getParameter("contact");
        String address = request.getParameter("address");

        // 3. Mapping to Model
        Guest guest = new Guest();
        guest.setIdNumber(idNumber);
        guest.setName(name);
        guest.setContactNumber(contact);
        guest.setAddress(address);

        try {
            // 4. Persistence via DAO
            boolean success = guestDAO.addGuest(guest);

            if (success) {
                // Determine target dashboard based on User Role (ADMIN vs STAFF)
                String targetDashboard = "ADMIN".equalsIgnoreCase(loggedInUser.getRole()) 
                                        ? "admin_dashboard.jsp" 
                                        : "staff_dashboard.jsp";
                
                // Redirect with the 'registered' status for the dashboard success alert
                response.sendRedirect(targetDashboard + "?status=registered");
            } else {
                response.sendRedirect("add_guest.jsp?error=failed");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Redirect back to form if ID already exists or DB connection fails
            response.sendRedirect("add_guest.jsp?error=duplicate_id");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Prevent direct URL access via GET
        response.sendRedirect("add_guest.jsp");
    }
}