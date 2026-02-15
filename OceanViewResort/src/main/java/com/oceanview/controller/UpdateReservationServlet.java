package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Controller responsible for updating existing reservation records.
 * Synchronizes Admin Dashboard modifications with the MySQL database.
 */
@WebServlet("/UpdateReservationServlet")
public class UpdateReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L; 
    private ReservationDAO resDAO = new ReservationDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 1. Capture primary keys and financial strings for validation
            String idStr = request.getParameter("reservationId");
            String billStr = request.getParameter("totalBill");
            String idNumStr = request.getParameter("idNumber");

            // 2. Structural Validation: Ensure critical data isn't missing
            if (idStr == null || billStr == null || idNumStr == null) {
                response.sendRedirect("admin_dashboard.jsp?error=missing_fields");
                return;
            }

            // 3. Populate Model with validated data
            Reservation res = new Reservation();
            res.setReservationNumber(Integer.parseInt(idStr));
            res.setIdNumber(idNumStr); // Required for Foreign Key integrity
            res.setGuestName(request.getParameter("guestName"));
            res.setContactNumber(request.getParameter("contactNumber"));
            res.setAddress(request.getParameter("address"));
            res.setCheckInDate(request.getParameter("checkIn"));
            res.setCheckOutDate(request.getParameter("checkOut"));
            res.setTotalBill(Double.parseDouble(billStr));

            // 4. Execute the update via the unified DAO
            if (resDAO.updateReservation(res)) {
                // Return to dashboard with a success status
                response.sendRedirect("admin_dashboard.jsp?status=updated");
            } else {
                response.sendRedirect("admin_dashboard.jsp?error=update_failed");
            }

        } catch (NumberFormatException e) {
            // Handles cases where numeric fields (ID or Bill) are malformed
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?error=invalid_format");
        } catch (Exception e) {
            // Catch-all for database connectivity or unexpected system issues
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?error=system");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Direct GET access redirects to the dashboard to maintain security
        response.sendRedirect("admin_dashboard.jsp");
    }
}