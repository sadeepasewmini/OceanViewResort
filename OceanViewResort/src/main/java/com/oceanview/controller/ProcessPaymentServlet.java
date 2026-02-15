package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.oceanview.model.User;

@WebServlet("/ProcessPaymentServlet")
public class ProcessPaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReservationDAO resDAO = new ReservationDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Security Check: Ensure only logged-in Admins can process payments
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }

        try {
            // 2. Capture the Reservation ID from the payment management form
            String resIdStr = request.getParameter("resId");
            
            if (resIdStr != null && !resIdStr.isEmpty()) {
                int resId = Integer.parseInt(resIdStr);

                // 3. Call the DAO to update the status to 'Paid' in MySQL
                if (resDAO.updatePaymentStatus(resId, "Paid")) {
                    // Success: Return to the payment page with a success flag
                    response.sendRedirect("payment_management.jsp?status=payment_success");
                } else {
                    // Fail: Could not find the record
                    response.sendRedirect("payment_management.jsp?error=not_found");
                }
            } else {
                response.sendRedirect("payment_management.jsp?error=invalid_id");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("payment_management.jsp?error=format");
        } catch (SQLException e) {
            // This catches database-level errors (e.g., connection lost)
            e.printStackTrace();
            response.sendRedirect("payment_management.jsp?error=database");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("payment_management.jsp?error=unknown");
        }
    }

    // Block direct URL access via GET for security
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("payment_management.jsp");
    }
}