<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="TeamManager.Views.Dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Team Management Dashboard
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .dashboard-container {
            width: 80%;
            margin: auto;
            font-family: Arial, sans-serif;
        }
        .dashboard-header {
            text-align: center;
            font-size: 24px;
            margin-bottom: 20px;
        }
        .stats {
            display: flex;
            justify-content: space-around;
            margin-bottom: 20px;
        }
        .stat-box {
            padding: 15px;
            background: #f4f4f4;
            border-radius: 8px;
            text-align: center;
            margin:5px;
            width: 150px;
        }
        .grid-container {
            margin-top: 20px;
        }
        .grid-container h3 {
            margin-bottom: 10px;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.4);
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

        /* Grid Styles */
        .task-grid {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .task-grid th, .task-grid td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: center;
        }

        .task-grid th {
            background-color: #f4f4f4;
            font-weight: bold;
        }

        .task-grid tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .task-grid tr:hover {
            background-color: #f1f1f1;
        }

        .pagination-label {
            text-align: center;
            font-size: 14px;
            margin-top: 10px;
        }

        .filter-dropdown {
            padding: 8px;
            font-size: 14px;
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

    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <asp:UpdatePanel ID="DashboardUpdatePanel" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="dashboard-container">
                <div class="dashboard-header">
                    <h2>Team Management Dashboard</h2>
                </div>

                <!-- Dashboard Statistics -->
                <div class="stats">
                    <div class="stat-box">
                        <h3>Total Tasks</h3>
                        <asp:Label ID="lblTotalTasks" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Pending Tasks</h3>
                        <asp:Label ID="lblPendingTasks" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Tasks In Progress</h3>
                        <asp:Label ID="lblInProgressTasks" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Delayed Tasks</h3>
                        <asp:Label ID="lblDelayedTasks" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Cancelled Tasks</h3>
                        <asp:Label ID="lbCancelledTasks" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Completed Tasks</h3>
                        <asp:Label ID="lblCompletedTasks" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Total Users</h3>
                        <asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Most Pending Tasks</h3>
                        <asp:Label ID="lblMostPendingTasks" runat="server" Text="N/A"></asp:Label>
                    </div>
                    <div class="stat-box">
                        <h3>Most Completed Tasks</h3>
                        <asp:Label ID="lblMostCompletedTasks" runat="server" Text="N/A"></asp:Label>
                    </div>
                </div>

                <!-- Filter Section -->
                <div class="grid-container">
                    <label for="statusFilter">Filter by Status:</label>
                    <asp:DropDownList ID="statusFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true" OnSelectedIndexChanged="statusFilter_SelectedIndexChanged">
                        <asp:ListItem Text="All" Value="" />
                        <asp:ListItem Text="Pending" Value="Pending" />
                        <asp:ListItem Text="In Progress" Value="In Progress" />
                        <asp:ListItem Text="Completed" Value="Completed" />
                    </asp:DropDownList>
                </div>

                <!-- Button to Open Modal -->
                <div class="grid-container">
                    <asp:Button ID="btnOpenModal" runat="server" Text="Create New User" OnClientClick="openModal(); return false;" CssClass="btn btn-primary" />
                </div>

                <!-- Recent Tasks Grid -->
                <div class="grid-container">
                    <h3>Recent Tasks</h3>
                    <asp:GridView ID="gvRecentTasks" runat="server" AutoGenerateColumns="false" CssClass="task-grid" AllowPaging="true" PageSize="5" OnPageIndexChanging="gvRecentTasks_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="Title" HeaderText="Task Name" />
                            <asp:BoundField DataField="AssignedTo" HeaderText="Assigned To" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                            <asp:BoundField DataField="DueDate" HeaderText="Created Date" DataFormatString="{0:yyyy-MM-dd}" />
                        </Columns>
                    </asp:GridView>

                    <!-- Pagination Display -->
                    <asp:Label ID="lblPageCount" runat="server" CssClass="pagination-label"></asp:Label>
                </div>

                <!-- Modal for Adding User -->
                <div id="userModal" class="modal">
                    <div class="modal-content">
                        <span class="close" onclick="closeModal()">&times;</span>
                        <h3>Create User</h3>
                        <label for="txtUsername">Username:</label>
                        <asp:TextBox ID="txtUsername" runat="server" placeholder="Enter username"></asp:TextBox><br />

                        <label for="txtPassword">Password:</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Enter password"></asp:TextBox><br />

                        <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" CssClass="btn btn-success" />
                        <asp:Label ID="lblMessage" runat="server" Text="" ForeColor="Green"></asp:Label>
                    </div>
                </div>

            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
        // Open Modal
        function openModal() {
            document.getElementById('userModal').style.display = 'block';
        }

        // Close Modal
        function closeModal() {
            document.getElementById('userModal').style.display = 'none';
        }
    </script>

</asp:Content>
