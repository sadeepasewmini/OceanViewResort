package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DeleteReservationServlet")
public class DeleteReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReservationDAO resDAO = new ReservationDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String resIdParam = request.getParameter("resId");
        String roomNo = request.getParameter("roomNo");

        // Input validation
        if (resIdParam == null || roomNo == null) {
            response.sendRedirect("admin_dashboard.jsp?error=invalid_params");
            return;
        }

        try {
            int resId = Integer.parseInt(resIdParam);

            // DAO handles deleting reservation and setting room to 'Available'
            if (resDAO.deleteReservation(resId, roomNo)) {
                // Return to dashboard with success message
                response.sendRedirect("admin_dashboard.jsp?status=deleted");
            } else {
                response.sendRedirect("admin_dashboard.jsp?error=delete_failed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("admin_dashboard.jsp?error=invalid_id");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_dashboard.jsp?error=database");
        }
    }
}