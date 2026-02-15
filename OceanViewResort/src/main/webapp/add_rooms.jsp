<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    // 1. Session Access Control: Strict Admin validation
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("index.jsp?error=unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Unit | Ocean View Resort</title>
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
            --error: #ef4444;
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background: var(--bg-canvas); 
            margin: 0; 
            display: flex; 
            color: var(--text-main); 
            min-height: 100vh;
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

        /* Form Card Styling */
        .form-section { 
            background: var(--white); 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            max-width: 650px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); 
            overflow: hidden;
        }

        .form-header {
            padding: 24px 30px;
            border-bottom: 1px solid var(--border);
            background: #f8fafc;
        }

        .form-body { padding: 30px; }
        .form-group { margin-bottom: 24px; }
        
        label { 
            display: block; 
            font-weight: 600; 
            margin-bottom: 8px; 
            font-size: 0.875rem;
            color: var(--brand-dark);
        }

        .form-control { 
            width: 100%; 
            padding: 12px 16px; 
            border: 1px solid #cbd5e1; 
            border-radius: 8px; 
            box-sizing: border-box; 
            font-size: 0.95rem; 
            font-family: inherit;
            transition: all 0.2s;
        }

        .form-control:focus { 
            border-color: var(--brand-primary); 
            outline: none; 
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1); 
        }

        .btn-submit { 
            background-color: var(--brand-primary); 
            color: white; 
            border: none; 
            padding: 14px 24px;
            border-radius: 8px; 
            font-size: 0.95rem; 
            font-weight: 600; 
            cursor: pointer; 
            transition: 0.2s; 
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .btn-submit:hover { 
            background-color: #1d4ed8; 
            transform: translateY(-1px);
        }

        .logout-link {
            padding: 20px 30px;
            color: #fca5a5;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            border-top: 1px solid rgba(255,255,255,0.05);
        }

        /* Status Alerts */
        .alert {
            padding: 14px 20px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 0.9rem;
            font-weight: 500;
        }
        .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <h2 style="margin:0;">OCEAN VIEW</h2>
            <small style="color: var(--brand-primary); font-weight: 700;">RESOURCE MANAGEMENT</small>
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
            <h1 style="margin:0; font-size: 1.875rem;">Inventory Expansion</h1>
            <p style="color: var(--text-muted);">Register new room units into the Ocean View Resort database.</p>
        </header>

        <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="alert alert-success">
                ✓ Success: The room unit has been added and is now live on all dashboards.
            </div>
        <% } else if ("error".equals(request.getParameter("status"))) { %>
            <div class="alert alert-error">
                ⚠ Error: Could not add room. Ensure the Room Number is unique.
            </div>
        <% } %>

        <div class="form-section">
            <div class="form-header">
                <h3 style="margin:0; font-size: 1.1rem; color: var(--brand-dark);">New Unit Specification</h3>
            </div>
            <div class="form-body">
                <form action="RoomServlet" method="post">
                    <input type="hidden" name="action" value="add">

                    <div class="form-group">
                        <label>Room Number / Unit Identifier</label>
                        <input type="text" name="roomNo" class="form-control" placeholder="e.g. 101, A-102" required autofocus>
                    </div>

                    <div class="form-group">
                        <label>Classification Category</label>
                        <select name="roomType" class="form-control" required>
                            <option value="" disabled selected>Select Classification...</option>
                            <option value="Luxury Suite">Luxury Suite</option>
                            <option value="Deluxe Room">Deluxe Room</option>
                            <option value="Standard Room">Standard Room</option>
                            <option value="Family Suite">Family Suite</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Nightly Rate (LKR)</label>
                        <input type="number" step="0.01" name="price" class="form-control" placeholder="0.00" required>
                    </div>

                    <button type="submit" class="btn-submit">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                        Add Room to Inventory
                    </button>
                </form>
            </div>
        </div>
    </main>

</body>
</html>