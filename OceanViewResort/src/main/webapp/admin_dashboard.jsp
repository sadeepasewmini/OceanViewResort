<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User, com.oceanview.model.Reservation, com.oceanview.model.Room, com.oceanview.dao.ReservationDAO, com.oceanview.dao.RoomDAO, java.util.List" %>
<%
    // 1. FORCED REFRESH HEADERS: Prevents the browser from showing a cached version
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // 2. SESSION SECURITY: Only logged-in ADMINS can access this portal
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }

    // 3. FRESH DATA RETRIEVAL: Triggered on every page refresh
    ReservationDAO resDAO = new ReservationDAO();
    RoomDAO roomDAO = new RoomDAO();
    
    List<Reservation> allReservations = resDAO.selectAllReservations();
    List<Room> allRooms = roomDAO.getAllRooms(); 

    // 4. ANALYTICS ENGINE: Recalculates metrics from fresh database lists
    int totalRooms = (allRooms != null) ? allRooms.size() : 0;
    int occupiedRooms = 0;
    double totalRevenue = 0;

    if (allRooms != null) {
        for (Room r : allRooms) {
            if ("Occupied".equalsIgnoreCase(r.getStatus())) {
                occupiedRooms++;
            }
        }
    }

    if (allReservations != null) {
        for (Reservation res : allReservations) {
            totalRevenue += res.getTotalBill();
        }
    }
    
    int availableRooms = totalRooms - occupiedRooms;
    int occupancyRate = (totalRooms > 0) ? (occupiedRooms * 100 / totalRooms) : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Executive Dashboard | Ocean View Resort</title>
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

        /* Sidebar Navigation Container */
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
        
        /* Main Layout Content Area */
        .content-area { 
            margin-left: 280px; 
            padding: 40px; 
            width: calc(100% - 280px); 
            box-sizing: border-box; 
        }
        
        /* Dashboard Metrics Grid */
        .metrics-grid { 
            display: grid; 
            grid-template-columns: repeat(3, 1fr); 
            gap: 20px; 
            margin-bottom: 40px; 
        }
        .metric-card { 
            background: white; 
            padding: 25px; 
            border-radius: 12px; 
            border: 1px solid #e2e8f0; 
            position: relative; 
            overflow: hidden; 
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .metric-card::after { 
            content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 4px; background: var(--brand-primary); 
        }
        .metric-title { color: var(--text-muted); font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
        .metric-value { font-size: 1.5rem; font-weight: 700; margin-top: 8px; }

        /* Table Monitor Styling */
        .table-section { 
            background: white; 
            border-radius: 12px; 
            border: 1px solid #e2e8f0; 
            margin-bottom: 30px; 
            overflow: hidden; 
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }
        table { width: 100%; border-collapse: collapse; }
        th { 
            background: #f8fafc; 
            padding: 15px 20px; 
            text-align: left; 
            font-size: 0.75rem; 
            color: #64748b; 
            border-bottom: 1px solid #e2e8f0; 
            text-transform: uppercase;
        }
        td { padding: 15px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; }
        
        /* Status Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
        .badge-available { background: #dcfce7; color: #166534; }
        .badge-occupied { background: #fee2e2; color: #991b1b; }

        .logout-link { padding: 20px 30px; color: #fca5a5; text-decoration: none; font-weight: 600; border-top: 1px solid rgba(255,255,255,0.05); }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <h2 style="margin:0;">OCEAN VIEW</h2>
            <small style="color: var(--brand-primary); font-weight: 700;">EXECUTIVE PORTAL</small>
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
        <header style="margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center;">
            <div>
                <h1 style="margin:0;">Executive Overview</h1>
                <p style="color: var(--text-muted);">Welcome back, <strong><%= user.getUsername() %></strong></p>
            </div>
            <div style="text-align: right;">
                <div style="font-weight: 600;"><%= new java.util.Date().toString().substring(0, 10) %></div>
                <div style="font-size: 0.8rem; color: var(--status-available);">● System Online</div>
            </div>
        </header>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-title">Occupancy Rate</div>
                <div class="metric-value"><%= occupancyRate %>%</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Total Revenue</div>
                <div class="metric-value">LKR <%= String.format("%,.2f", totalRevenue) %></div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Available Inventory</div>
                <div class="metric-value"><%= availableRooms %> Rooms</div>
            </div>
        </div>

        <div class="table-section">
            <div style="padding: 18px 20px; font-weight: 700; border-bottom: 1px solid #e2e8f0; background: #fff;">
                Live Room Status Monitor
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
                        <td><strong>Unit <%= r.getRoomNumber() %></strong></td>
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
                            No room units found in database.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>

</body>
</html>