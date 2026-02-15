package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ReservationServlet")
public class ReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReservationDAO reservationDAO;
    private RoomDAO roomDAO;

    public void init() {
        reservationDAO = new ReservationDAO();
        roomDAO = new RoomDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            // 1. Extract parameters
            String idNumber = request.getParameter("idNumber");
            String guestName = request.getParameter("guestName");
            String contactNumber = request.getParameter("contactNumber");
            String address = request.getParameter("address");
            String roomNo = request.getParameter("roomNo");
            String roomType = request.getParameter("roomType");
            String checkInStr = request.getParameter("checkIn");
            String checkOutStr = request.getParameter("checkOut");
            
            // --- NEW: AVAILABILITY CHECK ---
            // Verify if the room is available for the selected date range
            boolean isAvailable = reservationDAO.isRoomAvailable(roomNo, checkInStr, checkOutStr);
            
            if (!isAvailable) {
                // If the room is taken, stop and alert the user
                response.sendRedirect("add_reservation.jsp?error=room_taken");
                return;
            }
            // -------------------------------

            // 2. Dynamic Bill Calculation
            double pricePerNight = roomDAO.getPriceByRoomNumber(roomNo);
            LocalDate d1 = LocalDate.parse(checkInStr);
            LocalDate d2 = LocalDate.parse(checkOutStr);
            long daysBetween = ChronoUnit.DAYS.between(d1, d2);
            
            if (daysBetween <= 0) daysBetween = 1; 

            double totalBill = pricePerNight * daysBetween;

            // 3. Populate the Model
            Reservation res = new Reservation();
            res.setIdNumber(idNumber);
            res.setGuestName(guestName);
            res.setContactNumber(contactNumber);
            res.setAddress(address);
            res.setRoomNumber(roomNo);
            res.setRoomType(roomType);
            res.setCheckInDate(checkInStr);
            res.setCheckOutDate(checkOutStr);
            res.setTotalBill(totalBill);
            res.setPaymentStatus("Pending"); // Defaulting to Pending as per your recent updates

            // 4. Execute Database Save
            boolean success = reservationDAO.insertReservation(res);

            if (success) {
                response.sendRedirect("view_reservations.jsp?status=success");
            } else {
                response.sendRedirect("add_reservation.jsp?error=database");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("add_reservation.jsp?error=database");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("add_reservation.jsp?error=system");
        }
    }
}