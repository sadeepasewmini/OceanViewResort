package com.oceanview.service;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class BillingService {
    public double calculateTotalStayCost(String checkIn, String checkOut, String roomType) {
        try {
            LocalDate d1 = LocalDate.parse(checkIn);
            LocalDate d2 = LocalDate.parse(checkOut);
            long nights = ChronoUnit.DAYS.between(d1, d2);
            if (nights <= 0) nights = 1;

            double dailyRate = "Deluxe".equalsIgnoreCase(roomType) ? 15000.0 : 25000.0;
            return nights * dailyRate;
        } catch (Exception e) { return 0.0; }
    }
}