package com.oceanview.dao;

import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.util.DatabaseConfig; 
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Ocean View Resort.
 * Manages the lifecycle of reservations, room availability, and payment status.
 */
public class ReservationDAO {

    /**
     * READ SINGLE: Fetches a specific reservation for the Edit Form.
     */
    public Reservation getReservationById(int resId) {
        String sql = "SELECT * FROM reservations WHERE reservation_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, resId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToReservation(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * UPDATES general reservation details (Admin functionality).
     */
    public boolean updateReservation(Reservation res) {
        String sql = "UPDATE reservations SET id_number = ?, guest_name = ?, " +
                     "contact_number = ?, address = ?, check_in = ?, " +
                     "check_out = ?, total_bill = ? WHERE reservation_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, res.getIdNumber());
            ps.setString(2, res.getGuestName());
            ps.setString(3, res.getContactNumber());
            ps.setString(4, res.getAddress());
            ps.setString(5, res.getCheckInDate());
            ps.setString(6, res.getCheckOutDate());
            ps.setDouble(7, res.getTotalBill());
            ps.setInt(8, res.getReservationNumber());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * UPDATES payment status specifically (Staff billing feature).
     */
    public boolean updatePaymentStatus(int resId, String status) throws SQLException {
        String sql = "UPDATE reservations SET payment_status = ? WHERE reservation_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status); 
            ps.setInt(2, resId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * AVAILABILITY CHECK: Prevents double-booking for overlapping dates.
     */
    public boolean isRoomAvailable(String roomNumber, String checkIn, String checkOut) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE room_number = ? " +
                     "AND check_in < ? AND check_out > ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, roomNumber);
            ps.setString(2, checkOut); 
            ps.setString(3, checkIn);  
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * CREATE: Inserts a reservation and sets room to 'Occupied'.
     */
    public boolean insertReservation(Reservation res) throws SQLException {
        String sqlInsert = "INSERT INTO reservations (id_number, guest_name, contact_number, address, room_number, room_type, check_in, check_out, total_bill, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlUpdateRoom = "UPDATE rooms SET status = 'Occupied' WHERE room_number = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false); 

            try (PreparedStatement ps1 = conn.prepareStatement(sqlInsert)) {
                ps1.setString(1, res.getIdNumber());
                ps1.setString(2, res.getGuestName());
                ps1.setString(3, res.getContactNumber());
                ps1.setString(4, res.getAddress());
                ps1.setString(5, res.getRoomNumber());
                ps1.setString(6, res.getRoomType());
                ps1.setString(7, res.getCheckInDate());
                ps1.setString(8, res.getCheckOutDate());
                ps1.setDouble(9, res.getTotalBill());
                ps1.setString(10, "Pending"); 
                ps1.executeUpdate();
            }

            try (PreparedStatement ps2 = conn.prepareStatement(sqlUpdateRoom)) {
                ps2.setString(1, res.getRoomNumber());
                ps2.executeUpdate();
            }

            conn.commit(); 
            return true;
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    /**
     * PROCESS CHECKOUT / DELETE: Transactional removal and room release.
     */
    public boolean processCheckout(int resId, String roomNo) throws SQLException {
        String sqlDelete = "DELETE FROM reservations WHERE reservation_id = ?";
        String sqlUpdateRoom = "UPDATE rooms SET status = 'Available' WHERE room_number = ?";

        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(sqlDelete)) {
                ps1.setInt(1, resId);
                ps1.executeUpdate();
            }

            try (PreparedStatement ps2 = conn.prepareStatement(sqlUpdateRoom)) {
                ps2.setString(1, roomNo);
                ps2.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public boolean deleteReservation(int resId, String roomNo) throws SQLException {
        return processCheckout(resId, roomNo);
    }

    /**
     * RETRIEVE ALL: Used for summary tables and analytics.
     */
    public List<Reservation> selectAllReservations() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT * FROM reservations ORDER BY reservation_id DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * INTERNAL MAPPING: Bridges MySQL ResultSets to Java Model objects.
     */
    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation res = new Reservation();
        res.setReservationNumber(rs.getInt("reservation_id")); 
        res.setIdNumber(rs.getString("id_number"));
        res.setGuestName(rs.getString("guest_name"));
        res.setContactNumber(rs.getString("contact_number"));
        res.setAddress(rs.getString("address"));
        res.setRoomNumber(rs.getString("room_number"));
        res.setRoomType(rs.getString("room_type"));
        res.setCheckInDate(rs.getString("check_in"));
        res.setCheckOutDate(rs.getString("check_out"));
        res.setTotalBill(rs.getDouble("total_bill"));
        res.setPaymentStatus(rs.getString("payment_status"));
        
        return res;
    }
}