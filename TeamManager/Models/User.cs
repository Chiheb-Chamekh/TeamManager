using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TeamManager.Models
{
    public class User
    {

        public Guid UserId { get; set; }
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public UserRole Role { get; set; } // Use enum for role
    }

    public enum UserRole
    {
        Admin = 0,
        User = 1
    }

}
