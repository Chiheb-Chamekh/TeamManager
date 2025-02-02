using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TeamManager.Models;

namespace TeamManager.Views
{
    public partial class About : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                // Redirect to the login page if the user is not logged in
                Response.Redirect("Login.aspx");
            }
            User user = (User)Session["User"];

            UsernameLabel.Text = $"Welcome, {user.Username}!";
        }
    }
}