<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.dao.ReservationDAO" %>
<%
    // AJAX HANDLER: Updates the MySQL database before the receipt is printed
    String action = request.getParameter("action");
    if ("updateStatus".equals(action)) {
        try {
            int resId = Integer.parseInt(request.getParameter("resId"));
            ReservationDAO dao = new ReservationDAO();
            boolean success = dao.updatePaymentStatus(resId, "Paid");
            
            response.setContentType("text/plain");
            response.getWriter().write(success ? "success" : "failure");
            return; // Exit to prevent rendering HTML during background update
        } catch (Exception e) {
            response.getWriter().write("error");
            return;
        }
    }

    // CAPTURING PARAMETERS: Received from the view_bills.jsp dashboard
    String resNumber = request.getParameter("resId"); 
    String guestName = request.getParameter("guestName");
    String payMethod = request.getParameter("payMethod");
    String finalBill = request.getParameter("finalBill");
    String roomNo = request.getParameter("roomNo");
    String stayDates = request.getParameter("stayDates");
    String duration = request.getParameter("duration");
    String hotelEmail = request.getParameter("hotelEmail");
    String hotelPhone = request.getParameter("hotelPhone");
    String hotelAddress = request.getParameter("hotelAddress");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Secure Settlement | Ocean View Resort</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #2563eb; --success: #059669; --dark: #0f172a; --bg: #f8fafc; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; color: #334155; }
        
        .checkout-card { background: white; padding: 48px; border-radius: 24px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.08); width: 100%; max-width: 520px; border: 1px solid #e2e8f0; }
        .checkout-header { text-align: center; margin-bottom: 32px; }
        .checkout-header h2 { margin: 0; font-size: 1.75rem; color: var(--dark); font-weight: 800; }
        
        .summary-box { background: #f1f5f9; padding: 24px; border-radius: 16px; margin-bottom: 32px; border-left: 6px solid var(--primary); }
        .summary-label { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.05em; margin-bottom: 4px; }
        .summary-value { font-size: 1.125rem; font-weight: 700; color: var(--dark); margin-bottom: 12px; }
        .amount-highlight { color: var(--success); font-size: 1.5rem; margin: 4px 0; }

        .form-group { margin-bottom: 24px; }
        label { display: block; font-weight: 700; font-size: 0.875rem; margin-bottom: 10px; color: var(--dark); }
        input { width: 100%; padding: 14px; border: 2px solid #e2e8f0; border-radius: 12px; font-size: 1rem; transition: 0.2s; box-sizing: border-box; }
        input:focus { outline: none; border-color: var(--primary); background: #f0f7ff; }

        .btn-finalize { background: var(--dark); color: white; border: none; width: 100%; padding: 18px; border-radius: 14px; font-weight: 700; cursor: pointer; font-size: 1.05rem; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .btn-finalize:hover { background: #1e293b; transform: translateY(-2px); box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
        
        .status-loading { display: none; text-align: center; color: var(--primary); font-weight: 600; margin-top: 15px; }
    </style>
</head>
<body>

<div class="checkout-card">
    <div class="checkout-header">
        <h2>Complete Settlement</h2>
        <p style="color: #64748b; font-weight: 500;">Reservation Ref: RES-<%= resNumber %></p>
    </div>
    
    <div class="summary-box">
        <div class="summary-label">Guest Information</div>
        <div class="summary-value"><%= guestName %></div>
        <div class="summary-label">Total Outstanding</div>
        <div class="summary-value amount-highlight"><%= finalBill %></div>
        <div style="font-size: 0.85rem; font-weight: 600; color: #475569;">Method: <%= payMethod %></div>
    </div>

    <form id="payForm">
        <% if ("Credit Card".equals(payMethod)) { %>
            <div class="form-group">
                <label>Cardholder Full Name</label>
                <input type="text" id="extra1" placeholder="As displayed on card" required>
            </div>
            <div class="form-group">
                <label>Verification (Last 4 Digits)</label>
                <input type="text" id="extra2" maxlength="4" placeholder="0000" required>
            </div>
        <% } else { %>
            <div class="form-group">
                <label>Actual Cash Received (LKR)</label>
                <input type="number" id="extra1" placeholder="Enter amount" required>
            </div>
            <div class="form-group">
                <label>Billing Annotations</label>
                <input type="text" id="extra2" placeholder="e.g. Received at Reception">
            </div>
        <% } %>

        <button type="button" class="btn-finalize" onclick="initiateSettlement()">
            Authorize & Print Invoice
        </button>
        <div id="loadingStatus" class="status-loading">Synchronizing with server...</div>
    </form>
</div>

<script>
async function initiateSettlement() {
    const val1 = document.getElementById('extra1').value;
    const val2 = document.getElementById('extra2').value;
    
    if(!val1) { alert("Please complete all mandatory settlement fields."); return; }

    document.getElementById('loadingStatus').style.display = 'block';
    
    // 1. ASYNC DATABASE SYNC
    try {
        const response = await fetch('process_payment.jsp?action=updateStatus&resId=<%= resNumber %>');
        const status = await response.text();
        
        if (status.trim() === "success") {
            generateProfessionalReceipt(val1, val2);
        } else {
            alert("Security Alert: Unable to verify transaction status with database.");
        }
    } catch (err) {
        alert("Connectivity error. Please check your terminal connection.");
    } finally {
        document.getElementById('loadingStatus').style.display = 'none';
    }
}

function generateProfessionalReceipt(val1, val2) {
    const printWindow = window.open('', '_blank');
    
    let receiptHtml = '<html><head><title>Invoice_RES-' + '<%= resNumber %>' + '</title>';
    receiptHtml += '<style>';
    receiptHtml += '@import url("https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap");';
    receiptHtml += 'body { font-family: "Plus Jakarta Sans", sans-serif; color: #0f172a; margin: 0; padding: 0; }';
    receiptHtml += '.invoice-wrapper { max-width: 800px; margin: 40px auto; padding: 60px; border: 1px solid #f1f5f9; border-radius: 8px; }';
    receiptHtml += '.header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 60px; border-bottom: 2px solid #f1f5f9; padding-bottom: 30px; }';
    receiptHtml += '.brand-title { color: #2563eb; font-size: 32px; font-weight: 800; margin: 0; letter-spacing: -0.02em; }';
    receiptHtml += '.meta-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 40px; margin-bottom: 50px; }';
    receiptHtml += '.meta-label { font-size: 11px; font-weight: 800; text-transform: uppercase; color: #94a3b8; letter-spacing: 0.05em; margin-bottom: 8px; }';
    receiptHtml += '.meta-value { font-size: 15px; font-weight: 600; color: #1e293b; }';
    receiptHtml += '.table { width: 100%; border-collapse: collapse; margin-bottom: 40px; }';
    receiptHtml += '.table th { text-align: left; padding: 14px 20px; background: #f8fafc; border-bottom: 2px solid #e2e8f0; font-size: 12px; font-weight: 700; }';
    receiptHtml += '.table td { padding: 20px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }';
    receiptHtml += '.total-card { background: #0f172a; color: white; padding: 30px; border-radius: 16px; width: 300px; text-align: right; margin-left: auto; }';
    receiptHtml += '</style></head><body>';

    receiptHtml += '<div class="invoice-wrapper">';
    receiptHtml += '<div class="header"><div><div class="brand-title">OCEAN VIEW</div>';
    receiptHtml += '<p style="font-size:12px; color:#64748b; margin-top:15px;">' + '<%= hotelAddress %>' + '<br>Contact: ' + '<%= hotelPhone %>' + '</p></div>';
    receiptHtml += '<div style="text-align:right;"><h2 style="margin:0; font-weight:800; font-size:20px;">TAX INVOICE</h2><p style="font-size:13px; margin-top:5px;">Date: ' + new Date().toLocaleDateString('en-GB') + '</p></div></div>';

    receiptHtml += '<div class="meta-grid">';
    receiptHtml += '<div><div class="meta-label">Billed To</div><div class="meta-value">' + '<%= guestName %>' + '</div></div>';
    receiptHtml += '<div style="text-align:right;"><div class="meta-label">Booking Reference</div><div class="meta-value">RES-' + '<%= resNumber %>' + '</div><div style="font-size:12px; color:#64748b; margin-top:4px;">Allocated Room: ' + '<%= roomNo %>' + '</div></div></div>';

    receiptHtml += '<table class="table"><thead><tr><th>Service Detail</th><th style="text-align:right;">Reference Info</th></tr></thead><tbody>';
    receiptHtml += '<tr><td>Accommodation & Facility Access</td><td style="text-align:right;">' + '<%= stayDates %>' + ' (' + '<%= duration %>' + ')</td></tr>';
    receiptHtml += '<tr><td>Method of Settlement</td><td style="text-align:right;">' + '<%= payMethod %>' + '</td></tr>';
    
    let detail = ("<%= payMethod %>" === "Credit Card") 
        ? "Auth Trace: " + val1 + " [**** " + val2 + "]" 
        : "Cash Tendered: LKR " + parseFloat(val1).toLocaleString() + " [" + val2 + "]";
        
    receiptHtml += '<tr><td>Transaction Proof</td><td style="text-align:right; font-weight:600;">' + detail + '</td></tr></tbody></table>';

    receiptHtml += '<div class="total-card"><div class="meta-label" style="color:rgba(255,255,255,0.6);">Grand Total Settled</div>';
    receiptHtml += '<div style="font-size:28px; font-weight:800; margin-top:10px;">' + '<%= finalBill %>' + '</div></div>';

    receiptHtml += '<div style="text-align:center; margin-top:80px; padding-top:30px; border-top:1px solid #f1f5f9; font-size:12px; color:#94a3b8;">';
    receiptHtml += '<p>Thank you for choosing Ocean View Resort. We look forward to your next visit.</p></div></div></body></html>';

    printWindow.document.write(receiptHtml);
    printWindow.document.close();
    
    printWindow.onload = function() {
        printWindow.print();
        window.location.href = "view_bills.jsp";
    };
}
</script>
</body>
</html>