using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using TeamManager.Models;
using Task = TeamManager.Models.Task;
using TaskStatus = TeamManager.Models.TaskStatus;

namespace TeamManager.Views
{
    public partial class Home : System.Web.UI.Page
    {
        public int WeekOffset { get; set; } = 0;
        public DateTime WeekStart { get; set; }
        protected List<Task> Tasks = new List<Task>();
        protected Dictionary<int, string> TaskUsernames = new Dictionary<int, string>();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {

                Response.Redirect("Login.aspx");
            }

            WeekOffset = string.IsNullOrEmpty(Request.QueryString["weekOffset"])
                          ? 0
                          : int.Parse(Request.QueryString["weekOffset"]);


            DateTime today = DateTime.Now;
            int daysToMonday = (int)today.DayOfWeek - 1;
            daysToMonday = daysToMonday < 0 ? 6 : daysToMonday; // Sunday fix

            WeekStart = today.Date.AddDays(-daysToMonday + (7 * WeekOffset));
            LoadTasks();
            User user = (User)Session["User"];
            var role=user.Role;
            bool isAdmin = IsUserAdmin(user);
            PopulateUserDropDown();



        }

        protected void NavigateWeek(object sender, EventArgs e)
        {
            Button clickedButton = (Button)sender;
            int offset = int.Parse(clickedButton.CommandArgument);
            WeekOffset += offset;


            DateTime today = DateTime.Now;
            int daysToMonday = (int)today.DayOfWeek - 1;
            daysToMonday = daysToMonday < 0 ? 6 : daysToMonday; // Sunday fix

            WeekStart = today.Date.AddDays(-daysToMonday + (7 * WeekOffset));

            // Update the query string for future navigation
            Response.Redirect($"Home.aspx?weekOffset={WeekOffset}");
        }

        protected void NavigateToThisWeek(object sender, EventArgs e)
        {

            WeekOffset = 0;

            DateTime today = DateTime.Now;
            int daysToMonday = (int)today.DayOfWeek - 1;
            daysToMonday = daysToMonday < 0 ? 6 : daysToMonday; // Sunday fix

            WeekStart = today.Date.AddDays(-daysToMonday);

            // Update the query string to reflect current week
            Response.Redirect($"Home.aspx?weekOffset={WeekOffset}");
        }

        private void LoadTasks()
        {
            using (var context = new MyDBContext())
            {
                // Get the current logged-in user's username
                User currentUser = (User)Session["User"];  // Get logged-in username
                bool isAdmin = IsUserAdmin(currentUser);  // Check if the user is an admin

                DateTime weekEnd = WeekStart.AddDays(7);

                // Query to join Tasks with Users based on AssignedTo (UserId)
                var taskWithUser = context.Tasks
                    .Where(t => t.DueDate >= WeekStart && t.DueDate < weekEnd)
                    .Join(context.Users,
                          task => task.AssignedTo,
                          user => user.UserId,
                          (task, user) => new
                          {
                              Task = task,
                              AssignedToUsername = user.Username
                          })
                    .Where(t => isAdmin || t.AssignedToUsername == currentUser.Username)  // Admin sees all tasks, others see only their own tasks
                    .ToList();

                // Store tasks and their corresponding user information
                Tasks = taskWithUser.Select(t => t.Task).ToList();
                TaskUsernames = taskWithUser.ToDictionary(t => t.Task.TaskId, t => t.AssignedToUsername);
            }
        }
        public void SaveTask(object sender, EventArgs e)
        {
            try
            {
                string taskName = TaskNameTextBox.Text;
                string taskDescription= TaskDecription.Text;
                string assignedToUsername = AssignedToDropDown.Text;
                string day = SelectedDayHiddenField.Value;
                string time=SelectedTimeHiddenField.Value;
                int duration = int.Parse(TaskDurationTextBox.Text);
                // Convert the date string to a DateTime object
                DateTime dueDate = DateTime.Parse(day + " " + time); // Adjust as necessary

                using (var context = new MyDBContext())
                {
                    // Get the UserId from the database based on the username
                    var user = context.Users.FirstOrDefault(u => u.Username == assignedToUsername);

                    if (user == null)
                    {
                        throw new Exception("Assigned user not found.");
                    }

                    // Insert data into the Tasks table
                    var task = new Task
                    {
                        Title = taskName,
                        Description = taskDescription,
                        DueDate = dueDate,
                        Status = TaskStatus.Pending,
                        Duration = duration,
                        AssignedTo = user.UserId 
                    };

                    context.Tasks.Add(task);
                    context.SaveChanges();

                    TaskNameTextBox.Text = "";
                    TaskDecription.Text = "";
                    AssignedToDropDown.Text = "";
                    TaskDurationTextBox.Text = "";

                    Response.Write("<script>alert('Task saved successfully!');</script>");
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Error: {ex.Message}');", true);

                // Handle exception (you can log the error as well)
                throw new Exception("Error saving task: " + ex.Message);
            }
        }
        private void PopulateUserDropDown()
        {
            using (var context = new MyDBContext()) // Use your DbContext or data access method
            {
                var users = context.Users.Select(u => new { u.UserId, u.Username }).ToList();

                AssignedToDropDown.DataSource = users;
                AssignedToDropDown.DataTextField = "Username";
                AssignedToDropDown.DataValueField = "UserId";
                AssignedToDropDown.DataBind();

                
                AssignedToDropDown.DataBind();
            }

            // Optionally, add a default "Select User" item at the top
            AssignedToDropDown.Items.Insert(0, new ListItem("Select User", "0"));

        }
        public void UpdateTask(object sender, EventArgs e)
        {
            try
            {
                // Get task ID and new status from the UI
                int taskId = int.Parse(SelectedTaskId.Value);
                TaskStatus newStatus = (TaskStatus)Enum.Parse(typeof(TaskStatus), TaskStatusDropdown.SelectedValue);

                using (var context = new MyDBContext())
                {
                    var task = context.Tasks.FirstOrDefault(t => t.TaskId == taskId);

                    if (task == null)
                    {
                        throw new Exception("Task not found.");
                    }
                   
                    // Update the task status
                    task.Status = newStatus;

                    // Save changes to the database
                    context.SaveChanges();

                    // Optionally show success message
                    CalendarUpdatePanel.Update();
                }
            }
            catch (Exception ex)
            {
                // Handle the exception (log it or show an alert)
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Error: {ex.Message}');", true);
                throw new Exception("Error updating task status: " + ex.Message);
            }
        }
        private bool IsUserAdmin(User activeuser)
        {
            // Assuming you have a User table with roles
            using (var context = new MyDBContext())
            {
                var user = context.Users.FirstOrDefault(u => u.UserId == activeuser.UserId);
                return user?.Role.ToString() == "Admin";  // Check if the user's role is Admin
            }
        }
        public string GetTaskStatusColor(string status)
        {
            switch (status)
            {
                case "Pending":
                    return "#caeaf1"; 
                case "Cancelled":
                    return "#d9534f";
                case "Delayed":
                    return "#ffc107"; 
                case "Working":
                    return "#4dbbd3"; 
                case "Completed":
                    return "#28a745"; 
                default:
                    return "#ffffff"; 
            }
        }
    }
}
