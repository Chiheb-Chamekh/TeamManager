<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="TeamManager.Views.Home" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Teams Calendar Layout
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }

        .navigation {
            text-align: center;
            margin: 10px 0;
        }

        .calendar-container {
            display: grid;
            grid-template-columns: 80px repeat(7, 1fr);
            grid-template-rows: auto;
            width: calc(100% - 250px); 
            height: 90vh; 
            border-collapse: collapse;
            margin-top: 0; 
        }

        .calendar-header {
            background-color: #dff0f4;
            font-weight: bold;
            text-align: center;
            border: 1px solid #ddd;
            padding: 10px 0;
        }

        .calendar-header.today {
            background-color: #bfe7f0;
            border: 2px solid #ff7777;
        }

        .time-column {
            font-weight: bold;
            text-align: right;
            border: 1px solid #ddd;
            padding: 5px;
            background-color: #dff4f9;
        }

        .calendar-cell {
            border: 1px solid #ddd;
            height: 60px; 
            position: relative;
            background-color: #fff;
            overflow-y: auto; 
            display: flex;
            flex-direction: column; 
            justify-content: flex-start;
            padding: 5px; 
        }

        .calendar-cell:hover {
            background-color: #f9f9f9;
            cursor: pointer;
        }

        .event {
            padding: 5px;
            background-color: #28a745; 
            color: white;
            border-radius: 4px;
            font-size: 12px;
            text-align: center;
            font-weight: bold;
            margin-bottom: 5px; 
            flex-shrink: 0; 
            word-wrap: break-word; 
            position: relative;
        }

        .time-column:nth-child(odd) {
            background-color: #f0f0f0; 
        }

.modal {
    display: none;
    position: fixed; 
    z-index: 1;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto; 
    background-color: rgb(0,0,0);
    background-color: rgba(0,0,0,0.4); 
    padding-top: 60px;
}

.modal-content {
    background-color: #fff;
    margin: 5% auto;
    padding: 20px;
    border: 1px solid #888;
    width: 40%;
    max-width: 600px;
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.close {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
    cursor: pointer;
}

.close:hover,
.close:focus {
    color: black;
    text-decoration: none;
    cursor: pointer;
}

.modal-content h3 {
    font-size: 1.5rem;
    margin-bottom: 15px;
    color: #333;
}

label {
    font-size: 1rem;
    color: #555;
    margin-bottom: 5px;
    display: inline-block;
}

input[type="text"], input[type="number"], select {
    width: 100%;
    padding: 8px;
    margin: 8px 0 20px 0;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 1rem;
}

input[type="text"]:focus, input[type="number"]:focus, select:focus {
    border-color: #4CAF50;
    outline: none;
}

button, .btn {
    background-color: #4CAF50;
    color: white;
    border: none;
    padding: 10px 20px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 1rem;
    cursor: pointer;
    border-radius: 4px;
    transition: background-color 0.3s;
}

button:hover, .btn:hover {
    background-color: #45a049;
}

.btn-primary {
    background-color: #007bff;
}

.btn-primary:hover {
    background-color: #0056b3;
}

input[readonly] {
    background-color: #f4f4f4;
    border: 1px solid #ddd;
}


        .close {
            float: right;
            cursor: pointer;
        }
    </style>

    <script>

        function openUpdateTaskModal(taskId, taskTitle, taskDescription, assignedTo, taskStatus) {
            document.getElementById("updateTaskModal").style.display = "flex";

            // Set values in the modal fields
            document.getElementById("<%= TaskTitleTextBox.ClientID %>").value = taskTitle;
            document.getElementById("<%= TaskDescriptionTextBox.ClientID %>").value = taskDescription;
            document.getElementById("<%= AssignedToTextBox.ClientID %>").value = assignedTo;


            // Set the task ID in the hidden field
            document.getElementById("<%= SelectedTaskId.ClientID %>").value = taskId;
        }

        // Function to close the update modal
        function closeUpdateModal() {
            setTimeout(function () {
                document.getElementById("updateTaskModal").style.display = "none";
            }, 100); 
        }
        function openTaskModal(date, time) {
            document.getElementById("taskModal").style.display = "flex";

            document.getElementById("<%= SelectedDayHiddenField.ClientID %>").value = date;
            document.getElementById("<%= SelectedTimeHiddenField.ClientID %>").value = time;
        }

        // Function to close the add task modal
        function closeModal() {
            setTimeout(function () {
                document.getElementById("taskModal").style.display = "none";
            }, 100); // Small delay ensures update completes before hiding
        }

        // Attach event after AJAX update
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
            closeModal();
        });
    </script>

    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <asp:UpdatePanel ID="CalendarUpdatePanel" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <!-- Navigation Buttons -->
            <div class="navigation">
                <asp:Button ID="PreviousWeekButton" runat="server" Text="Previous week" OnClick="NavigateWeek" CommandArgument="-1" />
                <span>Week of <%= WeekStart.ToString("MMMM dd, yyyy") %></span>
                <asp:Button ID="NextWeekButton" runat="server" Text="Next Week" OnClick="NavigateWeek" CommandArgument="1" />
                <asp:Button ID="ThisWeekButton" runat="server" Text="This Week" OnClick="NavigateToThisWeek" />
            </div>

            <!-- Calendar Grid -->
            <div class="calendar-container">
                <!-- Header for Days -->
                <div class="time-column"></div>
                <% for (int i = 0; i < 7; i++) { %>
                    <% 
                        var currentDate = WeekStart.AddDays(i); 
                        var isToday = currentDate.Date == DateTime.Now.Date;
                    %>
                    <div class="calendar-header <%= isToday ? "today" : "" %>">
                        <%= currentDate.ToString("dddd<br>MMM dd") %>
                    </div>
                <% } %>

                <% for (int hour = 8; hour <= 18; hour++) { %>
                    <% string time = hour.ToString("00") + ":00"; %>
                    <div class="time-column"><%= time %></div>
                    <% for (int i = 0; i < 7; i++) { %>
                        <% 
                            var tasksAtThisTime = Tasks.Where(t => t.DueDate.Date == WeekStart.AddDays(i).Date && t.DueDate.ToString("HH:mm") == time).ToList();
                        %>

                      <div class="calendar-cell" onclick="openTaskModal('<%= WeekStart.AddDays(i).ToString("yyyy-MM-dd") %>', '<%= time %>')">
    <% foreach(var task in tasksAtThisTime) { %>
        <div class="event" style="background-color: <%= GetTaskStatusColor(task.Status.ToString()) %>;" 
             onclick="event.stopPropagation(); openUpdateTaskModal('<%= task.TaskId %>', '<%= task.Title %>', '<%= task.Description %>', 
                                                                  '<%= TaskUsernames.ContainsKey(task.TaskId) ? TaskUsernames[task.TaskId] : "Unknown" %>', 
                                                                  '<%= task.Status %>')">
            <%= task.Title %> - <%= task.Status %> 
            <%= TaskUsernames.ContainsKey(task.TaskId) ? TaskUsernames[task.TaskId] : "Unknown" %>
        </div>
    <% } %>
</div>

                    <% } %>
                <% } %>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Modal for Adding Tasks -->
    <div id="taskModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <h3>Add Task</h3>
        <label for="TaskNameTextBox">Task Name:</label>
        <asp:TextBox ID="TaskNameTextBox" runat="server" placeholder="Enter task name"></asp:TextBox><br />
        
        <label for="TaskDecription">Description:</label>
        <asp:TextBox ID="TaskDecription" runat="server" placeholder="Enter task description"></asp:TextBox><br />
        
        <label for="Assignedto">Assigned To:</label>
       <asp:DropDownList ID="AssignedToDropDown" runat="server" >
    <asp:ListItem Text="Select User" Value="0" />
</asp:DropDownList><br />
        
        <label for="TaskDurationTextBox">Durée (en heures):</label>
        <asp:TextBox ID="TaskDurationTextBox" runat="server" Text="1" placeholder="Task duration in hours"></asp:TextBox><br />

        <asp:HiddenField ID="SelectedDayHiddenField" runat="server" />
        <asp:HiddenField ID="SelectedTimeHiddenField" runat="server" />
        
        <asp:Button ID="Save_task" runat="server" Text="Add Task" CssClass="btn btn-success" OnClick="SaveTask" />
    </div>
</div>

<!--Modals -->
<div id="updateTaskModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeUpdateModal()">&times;</span>
        <h3>Update Task Status</h3>
        <label for="TaskTitleTextBox">Task Name:</label>
        <asp:TextBox ID="TaskTitleTextBox" runat="server" ReadOnly="true" placeholder="Task name will appear here"></asp:TextBox><br />

        <label for="TaskDescriptionTextBox">Description:</label>
        <asp:TextBox ID="TaskDescriptionTextBox" runat="server" ReadOnly="true" placeholder="Task description"></asp:TextBox><br />

        <label for="AssignedToTextBox">Assigned To:</label>
        <asp:TextBox ID="AssignedToTextBox" runat="server" ReadOnly="true" placeholder="Task name will appear here"></asp:TextBox><br />

        <label for="TaskStatusDropdown">Status:</label>
        <asp:DropDownList ID="TaskStatusDropdown" runat="server">
            <asp:ListItem Value="Pending">Pending</asp:ListItem>
            <asp:ListItem Value="Delayed">Delayed</asp:ListItem>
            <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
            <asp:ListItem Value="Working">In Progress</asp:ListItem>
            <asp:ListItem Value="Completed">Completed</asp:ListItem>
        </asp:DropDownList><br />

        <asp:HiddenField ID="SelectedTaskId" runat="server" />
        
        <asp:Button ID="UpdateTaskButton" runat="server" Text="Update Task" CssClass="btn btn-primary" OnClick="UpdateTask" />
    </div>
</div>

</asp:Content>