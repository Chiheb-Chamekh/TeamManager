using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace TeamManager.Models
{
    public class MyDBContext : DbContext
    {
        public MyDBContext() : base("name=TasksDB") { }

        public DbSet<User> Users { get; set; }
        public DbSet<Task> Tasks { get; set; }
    }
    
}