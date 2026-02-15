package com.oceanview.model;

public class Room {
    private String roomNumber;
    private String roomType;
    private double price; 
    private String status;

    public Room() {}

    // 3-parameter constructor for adding rooms
    public Room(String roomNumber, String roomType, double price) {
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.price = price;
    }

    // 4-parameter constructor for retrieving rooms
    public Room(String roomNumber, String roomType, double price, String status) {
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.price = price;
        this.status = status;
    }

    public String getRoomNumber() { return roomNumber; }
    public String getRoomType() { return roomType; }
    public double getPrice() { return price; } 
    public String getStatus() { return status; }
}