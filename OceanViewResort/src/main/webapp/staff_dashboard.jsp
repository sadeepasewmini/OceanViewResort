<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Room, com.oceanview.dao.RoomDAO, java.util.List" %>
<%
    // 1. SESSION & ACCESS CONTROL
    // Ensures only logged-in STAFF (or ADMIN) can view this page
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. FRESH DATA RETRIEVAL
    // This executes on every page load to ensure the table reflects the latest MySQL data
    RoomDAO roomDAO = new RoomDAO();
    List<Room> allRooms = null;
    try {
        allRooms = roomDAO.getAllRooms();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // 3. ANALYTICS CALCULATION
    int availableCount = 0;
    int totalCount = (allRooms != null) ? allRooms.size() : 0;
    
    if (allRooms != null) {
        for (Room r : allRooms) {
            if ("Available".equalsIgnoreCase(r.getStatus())) {
                availableCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Portal | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-primary: #2563eb;
            --brand-dark: #0f172a;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --bg-canvas: #f1f5f9;
            --status-available: #10b981;
            --status-occupied: #ef4444;
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg-canvas); 
            margin: 0; 
            display: flex; 
            color: var(--text-main); 
        }

        /* Sidebar Navigation */
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
        
        /* Main Layout */
        .content-area { 
            margin-left: 280px; 
            padding: 50px; 
            width: calc(100% - 280px); 
            box-sizing: border-box; 
        }

        /* Metrics Grid */
        .metrics-grid { 
            display: grid; 
            grid-template-columns: repeat(3, 1fr); 
            gap: 25px; 
            margin-bottom: 40px; 
        }
        .metric-card { 
            background: white; 
            padding: 25px; 
            border-radius: 16px; 
            border: 1px solid #e2e8f0; 
            position: relative; 
            overflow: hidden; 
        }
        .metric-card::after { 
            content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 4px; background: var(--brand-primary); 
        }
        .metric-title { color: var(--text-muted); font-size: 0.8rem; font-weight: 600; text-transform: uppercase; }
        .metric-value { font-size: 1.5rem; font-weight: 700; margin-top: 10px; }

        /* Table Container */
        .table-container { 
            background: white; 
            border-radius: 16px; 
            border: 1px solid #e2e8f0; 
            overflow: hidden; 
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }
        table { width: 100%; border-collapse: collapse; }
        thead th { 
            background: #f8fafc; 
            padding: 18px 24px; 
            text-align: left; 
            font-size: 0.75rem; 
            color: #64748b; 
            border-bottom: 1px solid #e2e8f0; 
            text-transform: uppercase;
        }
        tbody td { padding: 20px 24px; border-bottom: 1px solid #f1f5f9; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
        .badge-available { background: #dcfce7; color: #166534; }
        .badge-occupied { background: #fee2e2; color: #991b1b; }

        .logout-link { 
            margin-top: auto;
            padding: 20px 30px; 
            color: #fca5a5; 
            text-decoration: none; 
            font-weight: 600; 
            font-size: 0.9rem;
            border-top: 1px solid rgba(255,255,255,0.05);
        }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <h2 style="margin:0;">OCEAN VIEW</h2>
            <small style="color: var(--brand-primary);">STAFF OPERATION</small>
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
        <header style="margin-bottom: 40px; display: flex; justify-content: space-between; align-items: center;">
            <div>
                <h1 style="margin:0; font-size: 1.875rem;">Staff Dashboard</h1>
                <p style="color: var(--text-muted);">Logged in as: <strong><%= user.getUsername() %></strong></p>
            </div>
            <div style="text-align: right;">
                <div style="font-weight: 600;"><%= new java.util.Date().toString().substring(0, 10) %></div>
                <div style="font-size: 0.8rem; color: var(--status-available);">● System Online</div>
            </div>
        </header>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-title">Available for Check-In</div>
                <div class="metric-value"><%= availableCount %> Rooms</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Occupancy Status</div>
                <div class="metric-value"><%= totalCount - availableCount %> Occupied</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Total Inventory</div>
                <div class="metric-value"><%= totalCount %> Units</div>
            </div>
        </div>

        <div class="table-container">
            <div style="padding: 24px; border-bottom: 1px solid #e2e8f0;">
                <h2 style="margin:0; font-size: 1.1rem;">Live Room Availability Monitor</h2>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Room Unit</th>
                        <th>Classification</th>
                        <th>Current Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (allRooms != null && !allRooms.isEmpty()) { 
                        for(Room r : allRooms) { %>
                    <tr>
                        <td style="font-weight: 600;">Unit <%= r.getRoomNumber() %></td>
                        <td><%= r.getRoomType() %></td>
                        <td>
                            <span class="badge <%= "Available".equalsIgnoreCase(r.getStatus()) ? "badge-available" : "badge-occupied" %>">
                                <%= r.getStatus() %>
                            </span>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="3" style="text-align: center; padding: 40px; color: var(--text-muted);">
                            No data found in MySQL 'rooms' table.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>

</body>
</html>