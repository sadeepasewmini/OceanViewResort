<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Reservation, com.oceanview.dao.ReservationDAO, com.oceanview.dao.RoomDAO, java.util.List, java.time.LocalDate, java.time.temporal.ChronoUnit" %>
<%
    // 1. Session Access Control
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Data Synchronization
    ReservationDAO resDAO = new ReservationDAO();
    List<Reservation> allReservations = resDAO.selectAllReservations();
    
    // Hotel Metadata for Receipts
    String hotelEmail = "info@oceanviewresort.com";
    String hotelPhone = "+94 11 234 5678";
    String hotelAddress = "123 Galle Road, Hikkaduwa, Sri Lanka";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Billing Center | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-primary: #2563eb;
            --brand-dark: #0f172a;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --bg-canvas: #f1f5f9;
            --white: #ffffff;
            --border: #e2e8f0;
            --success: #10b981;
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg-canvas); 
            margin: 0; 
            display: flex; 
            color: var(--text-main); 
        }

        /* Sidebar Navigation - Shared Design */
        .sidebar { 
            width: 280px; 
            height: 100vh; 
            background: var(--brand-dark); 
            color: white; 
            position: fixed; 
            display: flex; 
            flex-direction: column; 
        }
        .sidebar-brand { padding: 40px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .nav-menu { padding: 20px 0; flex-grow: 1; }
        .nav-item { 
            display: flex; 
            align-items: center; 
            padding: 14px 30px; 
            color: #94a3b8; 
            text-decoration: none; 
            transition: 0.2s; 
            border-left: 4px solid transparent; 
        }
        .nav-item:hover, .nav-item.active { 
            background: #1e293b; 
            color: white; 
            border-left-color: var(--brand-primary); 
        }
        
        /* Main Layout Content Area */
        .content-area { 
            margin-left: 280px; 
            padding: 40px; 
            width: 100%; 
            box-sizing: border-box; 
        }

        /* Billing Section Styling */
        .billing-section { 
            background: var(--white); 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            overflow: hidden; 
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); 
        }
        .billing-header { padding: 20px; border-bottom: 1px solid var(--border); background: #f8fafc; }

        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 18px 20px; text-align: left; font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; border-bottom: 1px solid var(--border); }
        td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; }

        .res-number { font-family: monospace; color: var(--brand-primary); font-weight: 700; }
        .total-bill { color: var(--success); font-weight: 700; font-size: 1rem; }
        .btn-pay { background: var(--brand-primary); color: white; border: none; padding: 10px 18px; border-radius: 8px; cursor: pointer; font-weight: 600; transition: 0.2s; }
        .btn-pay:hover { opacity: 0.9; }

        .badge { padding: 6px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
        .badge-paid { background: #dcfce7; color: #166534; }
        .badge-pending { background: #fff7ed; color: #9a3412; }

        .logout-link { padding: 20px 30px; color: #fca5a5; text-decoration: none; font-weight: 600; font-size: 0.9rem; }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <h2 style="margin:0;">OCEAN VIEW</h2>
            <small style="color: var(--brand-primary);">RESOURCE MANAGEMENT</small>
        </div>
        <nav class="nav-menu">
            <a href="staff_dashboard.jsp" class="nav-item active">Operational Overview</a>
            <a href="staff_guest.jsp" class="nav-item">Guest Registration</a> 
            <a href="add_reservation.jsp" class="nav-item">New Booking</a> 
            <a href="view_reservations.jsp" class="nav-item">Guest Registry</a>
            <a href="view_bills.jsp" class="nav-item">Billing Center</a>
            
            <div style="margin-top: 20px; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 10px;">
                <a href="help.jsp" class="nav-item">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 12px;">
                        <circle cx="12" cy="12" r="10"></circle>
                        <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path>
                        <line x1="12" y1="17" x2="12.01" y2="17"></line>
                    </svg>
                    Help & Support
                </a>
        </nav>
        <a href="LogoutServlet" class="logout-link">Sign Out</a>
    </aside>

    <main class="content-area">
        <header style="margin-bottom: 30px;">
            <h1 style="margin:0; font-size: 1.875rem;">Guest Billing Portal</h1>
            <p style="color: var(--text-muted);">Manage guest settlements and finalize financial records.</p>
        </header>

        <div class="billing-section">
            <div class="billing-header">
                <h3 style="margin:0; font-size: 1.1rem; color: var(--brand-dark);">Account Settlement Monitor</h3>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Res. #</th>
                        <th>Guest / Room</th>
                        <th>Stay Dates</th>
                        <th>Final Total</th>
                        <th>Status</th>
                        <th>Method</th>
                        <th style="text-align: right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (allReservations != null) { 
                        for(Reservation res : allReservations) { 
                            LocalDate d1 = LocalDate.parse(res.getCheckInDate());
                            LocalDate d2 = LocalDate.parse(res.getCheckOutDate());
                            long nights = ChronoUnit.DAYS.between(d1, d2);
                            if(nights <= 0) nights = 1;
                            
                            boolean isPaid = "Paid".equalsIgnoreCase(res.getPaymentStatus());
                    %>
                    <tr>
                        <td class="res-number">RES-<%= res.getReservationNumber() %></td>
                        <td>
                            <strong><%= res.getGuestName() %></strong><br>
                            <small style="color: var(--text-muted);">Unit <%= res.getRoomNumber() %></small>
                        </td>
                        <td><%= res.getCheckInDate() %> &rarr; <%= res.getCheckOutDate() %></td>
                        <td class="total-bill">LKR <%= String.format("%.2f", res.getTotalBill()) %></td>
                        <td>
                            <span class="badge <%= isPaid ? "badge-paid" : "badge-pending" %>">
                                <%= isPaid ? "Paid" : "Pending" %>
                            </span>
                        </td>
                        <form action="process_payment.jsp" method="POST">
                            <input type="hidden" name="resId" value="<%= res.getReservationNumber() %>">
                            <input type="hidden" name="guestName" value="<%= res.getGuestName() %>">
                            <input type="hidden" name="finalBill" value="LKR <%= String.format("%.2f", res.getTotalBill()) %>">
                            <input type="hidden" name="roomNo" value="<%= res.getRoomNumber() %>">
                            <input type="hidden" name="stayDates" value="<%= res.getCheckInDate() %> to <%= res.getCheckOutDate() %>">
                            <input type="hidden" name="duration" value="<%= nights %> Night(s)">
                            <input type="hidden" name="hotelEmail" value="<%= hotelEmail %>">
                            <input type="hidden" name="hotelPhone" value="<%= hotelPhone %>">
                            <input type="hidden" name="hotelAddress" value="<%= hotelAddress %>">

                            <td>
                                <% if (!isPaid) { %>
                                    <select name="payMethod" style="padding: 8px; border-radius: 8px; border: 1px solid var(--border); font-family: inherit;" required>
                                        <option value="Cash">Cash</option>
                                        <option value="Credit Card">Credit Card</option>
                                    </select>
                                <% } else { %>
                                    <span style="font-size: 0.85rem; color: var(--text-muted);">Settled</span>
                                <% } %>
                            </td>
                            <td style="text-align: right;">
                                <% if (!isPaid) { %>
                                    <button type="submit" class="btn-pay">💳 Process</button>
                                <% } else { %>
                                    <div style="color: var(--success); font-weight: 700; font-size: 0.8rem;">✓ CLEARED</div>
                                <% } %>
                            </td>
                        </form>
                    </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>