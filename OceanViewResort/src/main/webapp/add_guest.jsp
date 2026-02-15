<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.model.User" %>
<%
    // 1. Session Security Check: Only logged-in users can access this page
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register New Guest | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { 
            --primary: #2563eb; 
            --primary-hover: #1d4ed8;
            --success: #059669; 
            --dark: #1e293b; 
            --bg: #f1f5f9; 
            --card-bg: #ffffff;
            --text-main: #334155;
            --text-muted: #64748b;
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background-color: var(--bg); 
            margin: 0; 
            color: var(--text-main); 
            -webkit-font-smoothing: antialiased;
        }

        /* Top Navigation Bar */
        .nav { 
            background: var(--dark); 
            color: white; 
            padding: 1rem 5%; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); 
        }

        /* Centralized Card Structure */
        .container { 
            max-width: 600px; 
            margin: 60px auto; 
            background: var(--card-bg); 
            padding: 40px; 
            border-radius: 16px; 
            box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1); 
        }

        .header-flex {
            margin-bottom: 32px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 24px;
            text-align: center;
        }

        h2 { color: var(--dark); font-size: 1.875rem; font-weight: 700; margin: 0; }
        p.subtitle { color: var(--text-muted); margin: 8px 0 0 0; font-size: 0.95rem; }

        .form-group { margin-bottom: 24px; text-align: left; }
        
        label { 
            display: block; 
            font-weight: 600; 
            margin-bottom: 8px; 
            color: var(--dark);
            font-size: 0.875rem;
        }

        input[type="text"] { 
            width: 100%; 
            padding: 12px 16px; 
            border: 1px solid #cbd5e1; 
            border-radius: 8px; 
            box-sizing: border-box; 
            font-size: 1rem; 
            font-family: inherit;
            transition: all 0.2s;
            background-color: #fff;
        }

        input[type="text"]:focus { 
            border-color: var(--primary); 
            outline: none; 
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1); 
        }

        /* Action Button Styling */
        .btn-submit { 
            width: 100%; 
            padding: 14px; 
            background-color: var(--primary); 
            color: white; 
            border: none; 
            border-radius: 8px; 
            font-size: 1rem; 
            font-weight: 600; 
            cursor: pointer; 
            transition: all 0.2s; 
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }

        .btn-submit:hover { 
            background-color: var(--primary-hover); 
            box-shadow: 0 4px 6px -1px rgba(37, 99, 235, 0.2);
            transform: translateY(-1px);
        }

        .back-btn { 
            display: inline-block;
            text-decoration: none; 
            color: var(--primary); 
            font-weight: 600; 
            font-size: 0.875rem;
            padding: 8px 16px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            margin-top: 24px;
            transition: background 0.2s;
        }

        .back-btn:hover { background-color: #f8fafc; }
        .footer-links { text-align: center; }
    </style>
</head>
<body>

    <nav class="nav">
        <strong>OCEAN VIEW RESORT - GUEST MANAGEMENT</strong>
        <span style="font-size: 0.875rem;">Terminal Access: <%= user.getUsername() %></span>
    </nav>

    <div class="container">
        <header class="header-flex">
            <h2>Guest Registration</h2>
            <p class="subtitle">Securely onboard new guests into the resort ecosystem.</p>
        </header>
        
        <form action="GuestServlet" method="post">
            <div class="form-group">
                <label for="idNumber">Identification Number (NIC or Passport)</label>
                <input type="text" id="idNumber" name="idNumber" placeholder="Enter unique ID number" required>
            </div>

            <div class="form-group">
                <label for="name">Legal Full Name</label>
                <input type="text" id="name" name="name" placeholder="Enter legal full name" required>
            </div>

            <div class="form-group">
                <label for="contact">Primary Contact Number</label>
                <input type="text" id="contact" name="contact" placeholder="e.g. 0771234567" required>
            </div>

            <div class="form-group">
                <label for="address">Permanent Residential Address</label>
                <input type="text" id="address" name="address" placeholder="Enter city or full address" required>
            </div>

            <button type="submit" class="btn-submit">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="8.5" cy="7" r="4"></circle><line x1="20" y1="8" x2="20" y2="14"></line><line x1="17" y1="11" x2="23" y2="11"></line></svg>
                Register Guest
            </button>
        </form>

        <div class="footer-links">
            <a href="<%= "ADMIN".equals(user.getRole()) ? "admin_dashboard.jsp" : "staff_dashboard.jsp" %>" class="back-btn">
                &larr; Return to Dashboard
            </a>
        </div>
    </div>

</body>
</html>