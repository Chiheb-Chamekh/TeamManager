<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="TeamManager.Views.About" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Teams Calendar Layout
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <main aria-labelledby="title">
        <asp:Label ID="UsernameLabel" runat="server"></asp:Label>
        <h3>Your application description page.</h3>
        <p>Use this area to provide additional information.</p>
    </main>
</asp:Content>
