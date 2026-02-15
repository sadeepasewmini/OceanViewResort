package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Controller to handle payment status updates across the resort.
 */
@WebServlet("/PaymentController")
public class PaymentController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReservationDAO reservationDAO;

    public void init() {
        reservationDAO = new ReservationDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // 1. Unified Security: Validates session and authorized roles
        if (user == null || (!"ADMIN".equalsIgnoreCase(user.getRole()) && !"STAFF".equalsIgnoreCase(user.getRole()))) {
            response.sendRedirect("index.jsp?error=unauthorized");
            return;
        }

        try {
            // 2. Extract Request Parameters
            int resId = Integer.parseInt(request.getParameter("resId"));
            String source = request.getParameter("source"); // Identifies the origin page
            
            // 3. Database Sync: Call DAO to set status to 'Paid'
            boolean success = reservationDAO.updatePaymentStatus(resId, "Paid");

            if (success) {
                // 4. Dynamic Redirection Logic
                if ("billing".equalsIgnoreCase(source)) {
                    // Returns Staff to the Billing Management portal
                    response.sendRedirect("view_bills.jsp?status=paid");
                } else {
                    // Returns Admin to the Financial Audit logs
                    response.sendRedirect("payment_logs.jsp?status=success");
                }
            } else {
                response.sendRedirect("admin_dashboard.jsp?error=db");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=exception");
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect unauthorized GET attempts to dashboard
        response.sendRedirect("admin_dashboard.jsp");
    }
}