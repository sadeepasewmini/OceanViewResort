package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
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
 * Controller to handle Guest Checkout.
 * Removes the reservation and frees the room unit for immediate rebooking.
 */
@WebServlet("/CheckoutServlet")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReservationDAO reservationDAO;

    public void init() {
        reservationDAO = new ReservationDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Security Check: Ensure only logged-in staff can process checkout
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            // 2. Extract parameters from the hidden fields in view_reservations.jsp
            String resIdStr = request.getParameter("resId");
            String roomNo = request.getParameter("roomNo");

            if (resIdStr != null && roomNo != null) {
                int resId = Integer.parseInt(resIdStr);

                // 3. Execute the transactional checkout logic
                // This deletes the reservation AND sets room status to 'Available' in one go
                boolean success = reservationDAO.processCheckout(resId, roomNo);

                if (success) {
                    // Redirect back to registry with a success notification
                    response.sendRedirect("view_reservations.jsp?status=checkedout");
                } else {
                    response.sendRedirect("view_reservations.jsp?error=true");
                }
            } else {
                response.sendRedirect("view_reservations.jsp?error=missing_data");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("view_reservations.jsp?error=true");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("view_reservations.jsp?error=true");
        }
    }

    // Protect against direct URL access; checkout should only happen via form submission (POST)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("view_reservations.jsp");
    }
}