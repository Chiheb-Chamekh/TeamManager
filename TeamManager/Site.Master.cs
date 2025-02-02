using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using TeamManager.Models;

namespace TeamManager
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (Session["User"] == null)
            {
                Response.Redirect("Views/Login.aspx");
            }

            User user = (User)Session["User"];

            if (user != null && user.Role.ToString()=="Admin")
            {
                adminSection.Visible = true;  
            }
            else
            {
                adminSection.Visible = false;  
            }
            if (Request.Url.AbsolutePath.EndsWith("Login.aspx"))
            {
                BodyClass = "no-sidebar";
            }
            else
            {
                BodyClass = "";
            }
        }
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();

            Session.Clear();
            Session.Abandon();

            Response.Redirect("Login.aspx");
        }
        public string BodyClass { get; set; }
    }
}