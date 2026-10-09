<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ApproveSchedule.aspx.cs" Inherits="Spedmon.ApproveSchedule" %>
    <form id="form1" runat="server">
        <div style="margin-left: 50px">
            <asp:HiddenField ID="HiddenFieldSelectedDate" runat="server" />
            <asp:HiddenField ID="HiddenFieldStartDate" runat="server" />
            <asp:HiddenField ID="HiddenFieldEndDate" runat="server" />
            <asp:HiddenField ID="HiddenFieldEmployeeId" runat="server" />
            <asp:HiddenField ID="HiddenFieldReferringPage" runat="server" />
            <h1>
                <asp:Literal ID="Literal1Message" runat="server" Text="Please approve schedule for date 1/1/001 to 1/6/001"></asp:Literal>
            </h1>
            <br/>
            <br/>
            <asp:label runat="server" text="Scheduled Approved" Font-Bold="True" ></asp:label>&nbsp;&nbsp;&nbsp;
            <asp:CheckBox ID="CheckBoxApproveSchedule" runat="server" AutoPostBack="True" OnCheckedChanged="CheckBoxApproveSchedule_CheckedChanged"/>
        </div>
    </form>
