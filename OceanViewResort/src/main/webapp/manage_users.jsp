<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    // Access Control: Only System Admins should access this page
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
    <title>Staff Management | Ocean View Resort</title>
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

        /* Form Section - Matching Table Section Style */
        .form-section { 
            background: var(--white); 
            border-radius: 12px; 
            border: 1px solid var(--border); 
            max-width: 600px;
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
            overflow: hidden;
        }

        .form-header {
            padding: 24px 30px;
            border-bottom: 1px solid var(--border);
            background: #f8fafc;
            font-weight: 700;
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
            transition: all 0.2s;
            font-family: inherit;
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
            padding: 12px 24px;
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
        }

        .alert {
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 0.9rem;
            border: 1px solid transparent;
        }
        .alert-success { background: #dcfce7; color: #166534; border-color: #bbf7d0; }
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
        <div style="padding: 20px;"><a href="LogoutServlet" style="color:#fca5a5; text-decoration:none; font-weight:600;">Sign Out</a></div>
    </aside>
    <main class="content-area">
        <header style="margin-bottom: 30px;">
            <h1 style="margin:0; font-size: 1.875rem;">Account Provisioning</h1>
            <p style="color: var(--text-muted);">Configure system access for new staff members and administrators.</p>
        </header>

        <% if ("success".equals(request.getParameter("status"))) { %>
            <div class="alert alert-success">
                <strong>Success!</strong> User credentials have been securely provisioned.
            </div>
        <% } %>

        <div class="form-section">
            <div class="form-header">
                Credential Configuration
            </div>
            <div class="form-body">
                <form action="UserManagementServlet" method="post">
                    <div class="form-group">
                        <label>Unique Username</label>
                        <input type="text" name="newUsername" class="form-control" placeholder="e.g. jdoe_staff" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Initial System Password</label>
                        <input type="password" name="newPassword" class="form-control" placeholder="••••••••" required>
                    </div>

                    <div class="form-group">
                        <label>Access Level (Role)</label>
                        <select name="role" class="form-control" required>
                            <option value="" disabled selected>Select permissions level...</option>
                            <option value="STAFF">Staff Member (Operational Access)</option>
                            <option value="ADMIN">System Admin (Full Control)</option>
                        </select>
                    </div>

                    <button type="submit" class="btn-submit">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="17" y1="11" x2="23" y2="11"></line></svg>
                        Provision Account
                    </button>
                </form>
            </div>
        </div>
    </main>

</body>
</html>