package com.oceanview.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordHasher {

    /**
     * Hashes a plain-text password using BCrypt.
     * Use this during User Registration or Password Updates.
     * * @param plainTextPassword The user's raw password string.
     * @return A 60-character secure hash string.
     */
    public static String hashPassword(String plainTextPassword) {
        // gensalt() generates a random salt; 12 is the work factor (complexity)
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(12));
    }

    /**
     * Verifies if a plain-text password matches a stored BCrypt hash.
     * Use this during the Login process in your DAO.
     * * @param plainTextPassword The password entered in the login form.
     * @param storedHash The hashed password retrieved from the database.
     * @return true if they match, false otherwise.
     */
    public static boolean checkPassword(String plainTextPassword, String storedHash) {
        try {
            // BCrypt.checkpw handles extracting the salt from the hash automatically
            return BCrypt.checkpw(plainTextPassword, storedHash);
        } catch (Exception e) {
            // Returns false if the storedHash is null or not a valid BCrypt hash
            return false;
        }
    }
}