/**
 * Ocean View Resort - Professional Help Section Logic
 * Optimized for Functionality 5 (Help Section) & Functionality 6 (Safe Exit)
 */

document.addEventListener("DOMContentLoaded", function() {
    const helpData = [
        {
            category: "Security",
            title: "User Authentication",
            desc: "Log in with your assigned credentials. Admin roles manage inventory, while Staff focus on guest services."
        },
        {
            category: "Operations",
            title: "Adding Reservations",
            desc: "Input Name, Address, and Contact. Select a room from the Admin inventory to ensure data integrity."
        },
        {
            category: "Information",
            title: "Displaying Details",
            desc: "Navigate to 'Guest Records' to view all logs. Use the reservation number for quick front-desk lookups."
        },
        {
            category: "Billing",
            title: "Billing & Printing",
            desc: "The system calculates the total bill based on room rate and nights stayed. Verify all dates before finalizing."
        },
        {
            category: "Privacy",
            title: "Exiting Safely",
            desc: "Protect guest privacy by using 'Exit System'. This clears your session and prevents unauthorized access."
        }
    ];

    const container = document.getElementById("help-container");
    const searchInput = document.getElementById("help-search");

    // Function to render help items
    function displayHelp(data) {
        if (!container) return;
        container.innerHTML = ""; // Clear existing
        
        data.forEach(item => {
            const section = document.createElement("div");
            section.className = "help-item card";
            section.innerHTML = `
                <span class="badge">${item.category}</span>
                <h3>${item.title}</h3>
                <p>${item.desc}</p>
            `;
            container.appendChild(section);
        });
    }

    // Initial render
    displayHelp(helpData);

    // Search Filter Logic
    if (searchInput) {
        searchInput.addEventListener("keyup", (e) => {
            const term = e.target.value.toLowerCase();
            const filtered = helpData.filter(item => 
                item.title.toLowerCase().includes(term) || 
                item.desc.toLowerCase().includes(term)
            );
            displayHelp(filtered);
        });
    }
});

/**
 * Handles Functionality 6: Safe Exit
 * Redirects to the LogoutServlet to invalidate the session.
 */
function confirmExit() {
    const userChoice = confirm("Are you sure you want to exit the Ocean View Resort System?");
    if (userChoice) {
        // Redirects to the LogoutServlet mapped in your Java backend
        window.location.href = "logout"; 
    }
}