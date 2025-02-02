using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace TeamManager.Models
{
    public class Task
    {
        public int TaskId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime DueDate { get; set; }
        public TaskStatus Status { get; set; } // e.g., "Pending", "Completed"
        public int Duration { get; set; }
        public Guid AssignedTo { get; set; } // UserId of the assigned user
    }
    public enum TaskStatus
    {
        Pending = 0,
        Working = 1,
        Cancelled = 2,
        Delayed = 3,
        Completed = 4
    }
}