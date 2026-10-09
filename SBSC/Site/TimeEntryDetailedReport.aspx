<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryDetailedReport.aspx.cs" Inherits="Spedmon.TimeEntryDetailedReport" %>
<script type="text/javascript">
        function PrintPage() {
            var printContent = document.getElementById
            ('<%= PanelReport.ClientID %>');
            var printWindow = window.open("All Records", 
                "Print Panel", 'left=50000,top=50000,width=0,height=0');
            printWindow.document.write(printContent.innerHTML);
            printWindow.document.close();
            printWindow.focus();
            printWindow.print();
        }
</script>
<form id="form1" runat="server">
    <div style="margin-left: 50px">
        <table>
            <tr>
                <td colspan="4">
                    <strong style="font-weight:bold">Select Employee</strong>&nbsp;&nbsp;&nbsp;
                    <asp:dropdownlist runat="server" id="DropDownListEmployees" AutoPostBack="True" OnSelectedIndexChanged="DropDownListEmployees_SelectedIndexChanged"></asp:dropdownlist>
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
        <br /><br/>
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