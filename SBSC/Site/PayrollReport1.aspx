<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayrollReport1.aspx.cs" Inherits="Spedmon.PayrollReport1" %>



<form id="form1" runat="server">

    <div class="container-fluid">
        <div runat="server" id="DollarsAdjustmentWarning" class="alert-warning" style="font-size:21px;line-height:22px;">Please note the dollar amount adjustments listed.</div>
        <table>
            <tr>
                <td colspan="4">
                    <strong style="font-weight:bold">Select Company</strong>&nbsp;&nbsp;&nbsp;
                    <asp:dropdownlist runat="server" id="DropDownListCompanies" OnSelectedIndexChanged="DropDownListCompanies_SelectedIndexChanged">
                      <asp:ListItem Text="All Companies" Selected="selected"></asp:ListItem>
                      <asp:ListItem Text="Practi-cal" Value="Practi-cal"></asp:ListItem>
                      <asp:ListItem Text="MBA" Value="MBA"></asp:ListItem>
                    </asp:dropdownlist>
                </td>
            </tr>
            <tr>
                <td colspan="4">
                    <strong style="font-weight:bold">Select Employee</strong>&nbsp;&nbsp;&nbsp;
                    <asp:dropdownlist runat="server" id="DropDownListEmployees" OnSelectedIndexChanged="DropDownListEmployees_SelectedIndexChanged"></asp:dropdownlist>
                </td>
            </tr>
            <tr>
                <td>
                    <strong style="font-weight:bold">Select Start Date</strong>&nbsp;&nbsp;&nbsp;
                    <asp:textbox id="tbStartDate" runat="server"></asp:textbox>
                    &nbsp;&nbsp;&nbsp;
                    <asp:ImageButton ID="lknPicStartDate" runat="server" ImageUrl="images/Calendar_scheduleHS.png" 
                        Height="19px" Width="21px" OnClick="lknPicStartDate_Click"></asp:ImageButton>
                </td>
                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                </td>
                <td>
                    <strong style="font-weight:bold">Select End Date</strong>&nbsp;&nbsp;&nbsp;
                    <asp:textbox id="tbEndDate" runat="server"></asp:textbox>
                    &nbsp;&nbsp;&nbsp;
                    <asp:ImageButton ID="lnkPicEndDate" runat="server" ImageUrl="images/Calendar_scheduleHS.png" 
                        Height="19px" Width="21px" OnClick="lnkPicEndDate_Click"></asp:ImageButton>
                </td>
                <td>
                    &nbsp;&nbsp;&nbsp;
                    <asp:Button ID="ButtonUpdateDateRange" runat="server" Text="Update" Font-Bold="True" 
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                            Height="30" Width="91px" OnClick="ButtonUpdateDateRange_Click" />
                    &nbsp;&nbsp;
                    <strong style="font-style: italic">Note: End date of report will be Saturday</strong>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Calendar ID="CalendarStart" runat="server" Visible="false" OnSelectionChanged="CalendarStart_SelectionChanged"></asp:Calendar>
                    <asp:label ID="Label2" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
                </td>
                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                </td>
                <td colspan="2">
                    <asp:Calendar ID="CalendarEnd" runat="server" Visible="false" OnSelectionChanged="CalendarEnd_SelectionChanged"></asp:Calendar>
                    <asp:label ID="Label3" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
                </td>
            </tr>
        </table>
      
        <ul id="fourstate-navtab" class="nav nav-tabs nav-fill">
              <li class="nav-item" id="tab-req-review">
                <a runat="server" id="SummaryTab" onServerClick="SummaryTab_Click">Payroll Summary</a>
              </li>
              <li class="nav-item" id="tab-referred">
                <a runat="server" id="ByDateTab" onServerClick="ByDateTab_Click">By Date</a>
              </li>
              <li class="nav-item" id="tab-released">
                <a runat="server" id="ByTaskTab" onServerClick="ByTaskTab_Click">Recorded Tasks</a>
              </li>   
              <li class="nav-item" id="tab-invoices">
                <a runat="server" id="InvoicesTab" onServerClick="InvoicesTab_Click">Invoices Collected Last Month</a>
              </li>
        </ul>
        <asp:Panel ID="PanelReport" runat="server">
            <asp:Label runat="server" Text="" ID="labelReportContent"></asp:Label>
        </asp:Panel>
        <br /><br />

        <button id="ButtonPrint" style="font-weight: bold; height: 37px; width: 172px;" 
            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
            onclick="PrintPage()">Print Report</button>
        &nbsp;&nbsp;&nbsp;
        <asp:Button ID="ButtonExport" runat="server" Text="Export Report"  
            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
            style="font-weight: bold; height: 37px; width: 172px;" OnClick="ButtonExport_Click"/>
        <br /><br />        

    </div>

</form>