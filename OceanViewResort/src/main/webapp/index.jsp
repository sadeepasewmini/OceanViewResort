<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --brand-primary: #2563eb;
            --brand-dark: #0f172a;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
        }

        body, html { height: 100%; margin: 0; font-family: 'Inter', sans-serif; background-color: #ffffff; overflow: hidden; }

        .main-container { display: flex; height: 100vh; width: 100%; }

        /* Left Side: Professional Branding */
        .image-section {
            flex: 1.3;
            background: linear-gradient(135deg, rgba(15, 23, 42, 0.5) 0%, rgba(15, 23, 42, 0.2) 100%), 
                        url('fcc5b7a0d3c994df27a5199f6d22a5e7.jpg');
            background-size: cover;
            background-position: center;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 80px;
            position: relative;
        }

        /* Glassmorphism Effect for Brand */
        .glass-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 50px;
            border-radius: 24px;
            color: white;
            max-width: 500px;
            text-align: center;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        .glass-card h1 { font-size: 3.5rem; margin: 0 0 10px 0; font-weight: 800; letter-spacing: -2px; line-height: 1; }
        .glass-card p { font-size: 1.1rem; line-height: 1.6; opacity: 0.9; font-weight: 300; }

        /* Right Side: Clean Login UI */
        .login-section {
            flex: 0.7;
            background-color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 60px;
            position: relative;
            z-index: 10;
        }

        .login-box { width: 100%; max-width: 380px; }
        .login-header { margin-bottom: 40px; }
        .login-header h2 { font-size: 2.25rem; font-weight: 700; color: var(--brand-dark); margin: 0; letter-spacing: -0.025em; }
        .login-header p { color: var(--text-muted); margin-top: 12px; font-size: 0.95rem; }

        /* Modern Input Styling */
        .form-group { margin-bottom: 24px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--brand-dark); font-size: 0.85rem; }
        
        input {
            width: 100%;
            padding: 14px 16px;
            border: 1px solid var(--border-color);
            border-radius: 12px;
            box-sizing: border-box;
            font-size: 1rem;
            color: var(--brand-dark);
            background-color: #f8fafc;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        input:focus {
            outline: none;
            border-color: var(--brand-primary);
            background-color: white;
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        }

        .btn-login {
            width: 100%;
            padding: 16px;
            background-color: var(--brand-primary);
            color: white;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 700;
            margin-top: 10px;
            transition: all 0.3s ease;
            box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.3);
        }

        .btn-login:hover { background-color: #1d4ed8; transform: translateY(-2px); box-shadow: 0 20px 25px -5px rgba(37, 99, 235, 0.4); }
        .btn-login:active { transform: translateY(0); }

        /* Professional Alerts */
        .alert {
            padding: 14px 16px;
            border-radius: 10px;
            margin-bottom: 24px;
            font-size: 0.875rem;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .alert-error { background-color: #fef2f2; color: #991b1b; border: 1px solid #fee2e2; }
        .alert-success { background-color: #f0fdf4; color: #166534; border: 1px solid #dcfce7; }

        .footer { text-align: center; margin-top: 48px; font-size: 0.75rem; color: #94a3b8; line-height: 1.5; }
    </style>
</head>
<body>

    <div class="main-container">
        <div class="image-section">
            <div class="glass-card">
                <h1>OCEAN VIEW</h1>
                <p>Advanced Resource Management System. Precision in hospitality, excellence in every detail.</p>
                <div style="margin-top: 30px; font-size: 0.7rem; letter-spacing: 4px; font-weight: 700; opacity: 0.6; text-transform: uppercase;">Galle District • Sri Lanka</div>
            </div>
        </div>

        <div class="login-section">
            <div class="login-box">
                <div class="login-header">
                    <h2>Sign In</h2>
                    <p>Enter your professional credentials to access the resort portal.</p>
                </div>

                <%-- Error Handling --%>
                <% if(request.getAttribute("errorMessage") != null) { %>
                    <div class="alert alert-error"><span>⚠</span> <%= request.getAttribute("errorMessage") %></div>
                <% } %>

                <%-- Success Handling --%>
                <% if("loggedout".equals(request.getParameter("status"))) { %>
                    <div class="alert alert-success"><span>✓</span> Session terminated. Please sign in again.</div>
                <% } %>

                <form action="LoginServlet" method="post">
                    <div class="form-group">
                        <label for="username">Username / ID</label>
                        <input type="text" id="username" name="username" required placeholder="e.g. admin_01" autocomplete="username">
                    </div>
                    <div class="form-group">
                        <label for="password">Security Password</label>
                        <input type="password" id="password" name="password" required placeholder="••••••••" autocomplete="current-password">
                    </div>
                    <button type="submit" class="btn-login">Enter Portal</button>
                </form>
                
                <div class="footer">
                    &copy; 2026 Ocean View Resort & Spa. All Rights Reserved. <br>
                    <span style="font-weight: 500; opacity: 0.7;">Authorized Personnel Only</span>
                </div>
            </div>
        </div>
    </div>

</body>
</html>