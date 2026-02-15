package com.oceanview.model;

public class Reservation {
    private int reservationNumber; // Database internal ID (Auto-increment)
    private String idNumber;       // Guest ID
    private String guestName;
    private String contactNumber;
    private String address;
    private String roomNumber;
    private String roomType;
    private String checkInDate;
    private String checkOutDate;
    private double totalBill;
    private String paymentStatus; // Added to resolve JSP errors

    public Reservation() {}

    // Getters and Setters
    public int getReservationNumber() { return reservationNumber; }
    public void setReservationNumber(int reservationNumber) { this.reservationNumber = reservationNumber; }

    public String getIdNumber() { return idNumber; }
    public void setIdNumber(String idNumber) { this.idNumber = idNumber; }

    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public String getCheckInDate() { return checkInDate; }
    public void setCheckInDate(String checkInDate) { this.checkInDate = checkInDate; }

    public String getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(String checkOutDate) { this.checkOutDate = checkOutDate; }

    public double getTotalBill() { return totalBill; }
    public void setTotalBill(double totalBill) { this.totalBill = totalBill; }

    // New methods for payment tracking
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
}