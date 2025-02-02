using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using TeamManager.Models;
using Task = TeamManager.Models.Task;

namespace TeamManager.Views
{
    public partial class UserHistory : Page
    {
        protected List<Task> userTasks; // Store the list of tasks for the user

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                // Redirect to the login page if the user is not logged in
                Response.Redirect("Login.aspx");
            }
            User user = (User)Session["User"];

            if (!IsPostBack)
            {
                // You would retrieve tasks from your database here
                Guid userId = user.UserId;  // Replace with the actual user ID
                userTasks = GetUserTasks(userId); // This should fetch tasks from your data source
                UsernameLabel.Text = user.Username.ToString();
                // You could apply filtering based on logged-in user (if using session/cookies)
            }
        }

        private List<Task> GetUserTasks(Guid userId)
        {
            using (var context = new MyDBContext())
            { 
                var tasks = context.Tasks.Where(u=>u.AssignedTo==userId).ToList();
                return tasks;

            }
        }
        
        // Helper method to get task color based on status
        public string GetTaskStatusColor(string status)
        {
            switch (status)
            {
                case "Pending":
                    return "#caeaf1"; // Orange
                case "Cancelled":
                    return "#d9534f"; // Red
                case "Delayed":
                    return "#ffc107"; // Yellow
                case "Working":
                    return "#4dbbd3"; // Blue
                case "Completed":
                    return "#28a745"; // Green
                default:
                    return "#ffffff"; // Default (white)
            }
        }
    }

    // Sample Task Model for demonstration
   
}
