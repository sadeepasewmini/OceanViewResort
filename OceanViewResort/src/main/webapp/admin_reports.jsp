<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.dao.ReservationDAO, com.oceanview.model.Reservation, java.util.List, com.oceanview.model.User" %>
<%
    // Access Control: Admin only
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }

    ReservationDAO dao = new ReservationDAO();
    List<Reservation> reports = dao.selectAllReservations(); 

    // Business Logic for Executive Summary
    double totalRevenue = 0;
    int totalBookings = (reports != null) ? reports.size() : 0;
    if (reports != null) {
        for(Reservation res : reports) {
            totalRevenue += res.getTotalBill();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Executive Reports | Ocean View Resort</title>
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

        /* Sidebar Navigation - Synchronized with dashboard */
        .sidebar { 
            width: 280px; 
            height: 100vh; 
            background: var(--brand-dark); 
            color: white; 
            position: fixed; 
            display: flex; 
            flex-direction: column; 
        }
        .sidebar-brand { 
            padding: 40px 20px; 
            text-align: center; 
            border-bottom: 1px solid rgba(255,255,255,0.05); 
        }
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
        
        /* Layout Structure */
        .content-area { 
            margin-left: 280px; 
            padding: 40px; 
            width: 100%; 
            box-sizing: border-box; 
        }

        /* Stats Cards - Refined style */
        .stats-grid { 
            display: grid; 
            grid-template-columns: repeat(3, 1fr); 
            gap: 20px; 
            margin-bottom: 30px; 
        }
        .stat-card { 
            background: var(--white); 
            padding: 25px; 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            position: relative;
            overflow: hidden;
        }
        .stat-card::after {
            content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 4px; background: var(--brand-primary);
        }
        .stat-title { color: var(--text-muted); font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
        .stat-value { font-size: 1.5rem; font-weight: 700; margin-top: 10px; }

        /* Report Table Section - Matching reservations_management.jsp */
        .table-section { 
            background: var(--white); 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            overflow: hidden; 
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); 
        }
        .table-header {
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
            background: #f8fafc;
        }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 18px 20px; text-align: left; font-size: 0.75rem; color: #64748b; text-transform: uppercase; border-bottom: 1px solid var(--border); }
        td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.95rem; }
        
        .btn-print { 
            background: var(--brand-dark); 
            color: white; 
            padding: 10px 18px; 
            border-radius: 8px; 
            text-decoration: none; 
            font-size: 0.85rem; 
            font-weight: 600;
            transition: 0.2s;
        }
        .btn-print:hover { opacity: 0.9; }

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
            <a href="admin_dashboard.jsp" class="nav-item active">Dashboard Overview</a>
            <a href="reservations_management.jsp" class="nav-item">Reservations Management</a>
            <a href="payment_logs.jsp" class="nav-item">Financial Management</a> 
            <a href="admin_guest.jsp" class="nav-item">Guest Registration</a> 
            <a href="manage_users.jsp" class="nav-item">Staff Management</a> 
            <a href="admin_reports.jsp" class="nav-item">Reports</a>
            <a href="add_rooms.jsp" class="nav-item">Room Inventory</a>
        </nav>
        <a href="LogoutServlet" class="logout-link">Sign Out</a>
    </aside>

    <main class="content-area">
        <header style="margin-bottom: 30px;">
            <h1 style="margin:0; font-size: 1.875rem;">Executive Reports</h1>
            <p style="color: var(--text-muted);">Audited revenue and occupancy metrics for <%= currentUser.getUsername() %>.</p>
        </header>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-title">Gross Revenue</div>
                <div class="stat-value" style="color: var(--success);">LKR <%= String.format("%,.2f", totalRevenue) %></div>
            </div>
            <div class="stat-card">
                <div class="stat-title">Occupancy Count</div>
                <div class="stat-value"><%= totalBookings %> Bookings</div>
            </div>
            <div class="stat-card">
                <div class="stat-title">Avg. Yield / Guest</div>
                <div class="stat-value">LKR <%= (totalBookings > 0) ? String.format("%,.2f", totalRevenue/totalBookings) : "0.00" %></div>
            </div>
        </div>

        <div class="table-section">
            <div class="table-header">
                <h3 style="margin:0; font-size: 1.1rem; color: var(--brand-dark);">Revenue & Occupancy Audit</h3>
                <a href="#" class="btn-print" onclick="window.print()">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 8px;"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                    Export to PDF
                </a>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Booking Ref</th>
                        <th>Guest Name</th>
                        <th>Room Type</th>
                        <th>Arrival Date</th>
                        <th style="text-align: right;">Total Bill (LKR)</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (reports != null && !reports.isEmpty()) { 
                        for(Reservation res : reports) { %>
                    <tr>
                        <td style="font-family: monospace; font-weight: 700; color: var(--brand-primary);">
                            #<%= res.getReservationNumber() %>
                        </td>
                        <td><strong><%= res.getGuestName() %></strong></td>
                        <td><%= res.getRoomType() %></td>
                        <td><%= res.getCheckInDate() %></td>
                        <td style="text-align: right; font-weight: 700; color: var(--text-main);">
                            <%= String.format("%,.2f", res.getTotalBill()) %>
                        </td>
                    </tr>
                    <% } } else { %>
                        <tr><td colspan="5" style="text-align:center; padding: 50px; color:var(--text-muted);">No data records found for the current audit period.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</body>
</html>