package com.oceanview.controller;

import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Room;
import com.oceanview.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Controller responsible for managing room inventory.
 * Access is restricted to Admin users.
 */
@WebServlet("/RoomServlet")
public class RoomServlet extends HttpServlet {
    private RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session Validation: Security check before processing any data
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String redirectTarget = "manage_rooms.jsp"; // Default redirect target

        try {
            // 2. Action Routing: Add New Room
            if ("add".equals(action)) {
                String roomNo = request.getParameter("roomNo");
                String type = request.getParameter("roomType");
                String priceStr = request.getParameter("price");

                if (roomNo != null && type != null && priceStr != null) {
                    double price = Double.parseDouble(priceStr);
                    
                    // New rooms are initialized as 'Available' by default
                    Room newRoom = new Room(roomNo, type, price, "Available");
                    roomDAO.addRoom(newRoom);
                    
                    // Redirect back to add_room.jsp to show success message
                    redirectTarget = "add_rooms.jsp";
                }
            } 
            
            // 3. Action Routing: Delete Room
            else if ("delete".equals(action)) {
                String roomNo = request.getParameter("roomNo");
                if (roomNo != null) {
                    roomDAO.deleteRoom(roomNo);
                    redirectTarget = "manage_rooms.jsp";
                }
            }

            // 4. Force UI Sync: Redirecting forces the JSP to re-run its database query scriptlet
            response.sendRedirect(redirectTarget + "?status=success");

        } catch (NumberFormatException e) {
            System.err.println("Pricing format error: " + e.getMessage());
            response.sendRedirect(redirectTarget + "?status=error&msg=invalid_price");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(redirectTarget + "?status=error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to the dashboard to prevent direct URL access to the servlet
        response.sendRedirect("admin_dashboard.jsp");
    }
}