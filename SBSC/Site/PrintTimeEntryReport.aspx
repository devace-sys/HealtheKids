<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrintTimeEntryReport.aspx.cs" Inherits="Spedmon.PrintTimeEntryReport" %>
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
        <asp:Panel ID="PanelReport" runat="server">
            <asp:Label runat="server" Text="" ID="labelReportContent"></asp:Label>
        </asp:Panel>
        </br></br>
        <button id="ButtonPrint" style="font-weight: bold; height: 37px; width: 172px;" 
            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
            onclick="PrintPage()">Print Report</button>
        &nbsp;&nbsp;&nbsp;
        <asp:Button ID="ButtonCancel" runat="server" Text="Cancel"  
            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
            style="font-weight: bold; height: 37px; width: 172px;" OnClick="ButtonCancel_Click"/>

    </div>
</form>