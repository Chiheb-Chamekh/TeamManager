<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserHistory.aspx.cs" Inherits="TeamManager.Views.UserHistory" MasterPageFile="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    User History and Tasks
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
    .table {
    width: 100%;
    border-collapse: collapse;
}

.table th, .table td {
    padding: 10px;
    border: 1px solid #ddd;
    text-align: left;
}

.table th {
    background-color: #f2f2f2;
}

.table tbody tr:hover {
    background-color: #f9f9f9;
}
        </style>
    <h2><asp:Label ID="UsernameLabel" runat="server"></asp:Label> Task History</h2>

    <!-- User History Table -->
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>Task Title</th>
                <th>Description</th>
                <th>Comment</th>
                <th>Status</th>
                <th>Date Assigned</th>
            </tr>
        </thead>
        <tbody>
            <% foreach (var task in userTasks) { %>
                <tr>
                    <td><%= task.Title %></td>
                    <td><%= task.Description %></td>
                    <td> </td>
                    <td style="background-color: <%= GetTaskStatusColor(task.Status.ToString()) %>;" >
                        <%= task.Status %>
                    </td>
                    <td><%= task.DueDate.ToString("MMM dd, yyyy") %></td>
                </tr>
            <% } %>
        </tbody>
    </table>
</asp:Content>
