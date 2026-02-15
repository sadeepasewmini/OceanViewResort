package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import java.sql.SQLException;
import java.util.List;

/**
 * SOLID Principle: Dependency Inversion
 * The service layer coordinates the business logic for the reservation system.
 */
public class ReservationService {
    private ReservationDAO reservationDAO;
    private BillingService billingService;

    public ReservationService() {
        this.reservationDAO = new ReservationDAO();
        this.billingService = new BillingService();
    }

    // Task 2: Add New Reservation with automatic bill calculation [cite: 23, 28]
    public void createNewReservation(Reservation res) throws SQLException {
        // Business Logic: Calculate bill before saving
        double total = billingService.calculateTotalStayCost(
            res.getCheckInDate(), 
            res.getCheckOutDate(), 
            res.getRoomType()
        );
        res.setTotalBill(total);
        
        // Save to Database
        reservationDAO.insertReservation(res);
    }

    // Task 3: Display Reservation Details [cite: 25]
    public List<Reservation> getAllReservations() {
        return reservationDAO.selectAllReservations();
    }
}