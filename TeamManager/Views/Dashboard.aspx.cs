using System;
using System.Data;
using System.Linq;
using System.Security.Cryptography;
using System.Web.UI.WebControls;
using TeamManager.Models;

namespace TeamManager.Views
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {

                Response.Redirect("Login.aspx");
            }
            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        //private void LoadDashboardData()
        //{
        //    using (var context = new MyDBContext())
        //    {
        //        // Load Dashboard Counts
        //        lblTotalTasks.Text = context.Tasks.Count().ToString();
        //        lblPendingTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Pending").ToString();
        //        lblInProgressTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Working").ToString();
        //        lblCompletedTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Completed").ToString();
        //        lblDelayedTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Delayed").ToString();
        //        lbCancelledTasks.Text=context.Tasks.Count(t => t.Status.ToString() == "Cancelled").ToString();
        //        lblTotalUsers.Text = context.Users.Count().ToString();
        //        // Load Recent Tasks with Assigned User
        //        var recentTasks = context.Tasks
        //            .OrderByDescending(t => t.DueDate)
        //            .Join(context.Users,
        //                  task => task.AssignedTo,
        //                  user => user.UserId,
        //                  (task, user) => new
        //                  {
        //                      task.Title,
        //                      AssignedTo = user.Username,
        //                      task.Status,
        //                      task.DueDate,
        //                  })
        //            .Take(10)
        //            .ToList();

        //        gvRecentTasks.DataSource = recentTasks;
        //        gvRecentTasks.DataBind();


        //    }
        //} 
        private void LoadDashboardData()
        {
            using (var context = new MyDBContext())
            {
                // Load Dashboard Counts
                LoadDashboardCounts(context);
                LoadTasks(string.Empty);

                // Load Recent Tasks with Assigned User
                LoadRecentTasks(context);
            }
        }
        protected void LoadTasks(string statusFilter)
        {
            using (var context = new MyDBContext())
            {
                // Get tasks with optional status filter
                var tasks = context.Tasks
                    .Where(t => string.IsNullOrEmpty(statusFilter) || t.Status.ToString() == statusFilter)
                    .OrderBy(t => t.DueDate)
                    .ToList();

                // Bind tasks to GridView
                gvRecentTasks.DataSource = tasks;
                gvRecentTasks.DataBind();

                // Update pagination label
                lblPageCount.Text = $"Page {gvRecentTasks.PageIndex + 1} of {gvRecentTasks.PageCount}";
            }
        }

        protected void gvRecentTasks_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvRecentTasks.PageIndex = e.NewPageIndex;
            LoadTasks(statusFilter.SelectedValue); // Reload tasks with the current filter
        }

        protected void statusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTasks(statusFilter.SelectedValue); // Reload tasks when a new filter is selected
        }
        private void LoadDashboardCounts(MyDBContext context)
        {
            lblTotalTasks.Text = context.Tasks.Count().ToString();
            lblPendingTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Pending").ToString();
            lblCompletedTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Completed").ToString();
            lblTotalUsers.Text = context.Users.Count().ToString();
            lblInProgressTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "InProgress").ToString();
            lblDelayedTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Delayed").ToString();
            lbCancelledTasks.Text = context.Tasks.Count(t => t.Status.ToString() == "Cancelled").ToString();

            // Load Member with the Most Pending Tasks
            lblMostPendingTasks.Text = GetMemberWithMostPendingTasks(context);

            // Load Member with the Most Completed Tasks
            lblMostCompletedTasks.Text = GetMemberWithMostCompletedTasks(context);
        }

        private string GetMemberWithMostPendingTasks(MyDBContext context)
        {
            var memberWithMostPendingTasks = context.Tasks
                .Where(t => t.Status.ToString() == "Pending")
                .GroupBy(t => t.AssignedTo)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            if (memberWithMostPendingTasks != null)
            {
                var mostPendingMember = context.Users
                    .FirstOrDefault(u => u.UserId == memberWithMostPendingTasks.Key);
                return mostPendingMember != null ? mostPendingMember.Username : "N/A";
            }

            return "N/A";
        }

        private string GetMemberWithMostCompletedTasks(MyDBContext context)
        {
            var memberWithMostCompletedTasks = context.Tasks
                .Where(t => t.Status.ToString() == "Completed")
                .GroupBy(t => t.AssignedTo)
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();

            if (memberWithMostCompletedTasks != null)
            {
                var mostCompletedMember = context.Users
                    .FirstOrDefault(u => u.UserId == memberWithMostCompletedTasks.Key);
                return mostCompletedMember != null ? mostCompletedMember.Username : "N/A";
            }

            return "N/A";
        }
        protected void btnRegister_Click(object sender, EventArgs e)
        {

            using (var context = new MyDBContext())
            {
                var user = new User
                {
                    UserId = Guid.NewGuid(),
                    Username = txtUsername.Text,
                    PasswordHash = HashPassword(txtPassword.Text),
                    Role = UserRole.User,
                };
                context.Users.Add(user);
                context.SaveChanges();
                lblMessage.Text = "registration successful!";

            }
        }
        public string HashPassword(string password)
        {
            // Generate a random salt
            byte[] salt = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            // Generate the hash using PBKDF2
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 10000))
            {
                byte[] hash = pbkdf2.GetBytes(32); // 32 bytes = 256-bit hash
                byte[] hashBytes = new byte[48];
                Array.Copy(salt, 0, hashBytes, 0, 16);
                Array.Copy(hash, 0, hashBytes, 16, 32);

                // Convert to Base64 for storage
                return Convert.ToBase64String(hashBytes);
            }
        }
        private void LoadRecentTasks(MyDBContext context)
        {
            var recentTasks = context.Tasks
                .OrderByDescending(t => t.DueDate)
                .Join(context.Users,
                      task => task.AssignedTo,
                      user => user.UserId,
                      (task, user) => new
                      {
                          task.Title,
                          AssignedTo = user.Username,
                          task.Status,
                          task.DueDate,
                      })
                .Take(10)
                .ToList();

            gvRecentTasks.DataSource = recentTasks;
            gvRecentTasks.DataBind();
        }
    }
}

