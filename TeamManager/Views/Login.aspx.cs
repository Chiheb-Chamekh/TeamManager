using System;
using System.Linq;
using System.Security.Cryptography;
using TeamManager.Models;

namespace TeamManager.Views
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
       

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtLoginUsername.Text;
            string enteredPassword = txtLoginPassword.Text;

            using (var context = new MyDBContext())
            {
                var user = context.Users.FirstOrDefault(u => u.Username == username);

                if (user != null && VerifyPassword(enteredPassword, user.PasswordHash))
                {
                    // Password is correct; set session variables and redirect
                    Session["User"] = user;
                    Session["UserId"] = user.UserId;
                    Session["Role"] = user.Role;
                    Response.Redirect("Home.aspx");
                }
                else
                {
                    lblMessage.Text = "Invalid username or password.";
                }
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
        public bool VerifyPassword(string enteredPassword, string storedHash)
        {
            // Convert Base64 string back to byte array
            byte[] hashBytes = Convert.FromBase64String(storedHash);

            // Extract the salt from the stored hash
            byte[] salt = new byte[16];
            Array.Copy(hashBytes, 0, salt, 0, 16);

            // Hash the entered password with the extracted salt
            using (var pbkdf2 = new Rfc2898DeriveBytes(enteredPassword, salt, 10000))
            {
                byte[] hash = pbkdf2.GetBytes(32); // Generate hash for entered password

                // Compare the computed hash with the stored hash
                for (int i = 0; i < 32; i++)
                {
                    if (hashBytes[i + 16] != hash[i]) // Compare only the hashed part
                    {
                        return false; // Passwords do not match
                    }
                }
            }

            return true; // Passwords match
        }
    }
}