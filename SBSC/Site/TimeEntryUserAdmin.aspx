<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryUserAdmin.aspx.cs" Inherits="Spedmon.TimeEntryUserAdmin" %>

    <script type = "text/javascript">
         function Confirm() {
              var confirm_value = document.createElement("INPUT");
              confirm_value.type = "hidden";
              confirm_value.name = "confirm_value";
              if (confirm("Do you want to save changes?")) {
                   confirm_value.value = "Yes";
              } else {
                   confirm_value.value = "No";
                   location.reload(true);
              }
              document.forms[0].appendChild(confirm_value);
         }
    </script>

    <form id="form1" runat="server">
        <div style="vertical-align: bottom; margin-left: 50px">
            <strong style="font-weight: bold">
                Select Employee To Manage  :&nbsp;&nbsp;&nbsp;&nbsp;
            </strong>
            <asp:DropDownList ID="DropDownListEmployeeName" runat="server" AutoPostBack="True" OnSelectedIndexChanged="DropDownListEmployeeName_SelectedIndexChanged"></asp:DropDownList>
            <asp:Panel ID="PanelRecordDetails" runat="server" Visible="false">
                <br /><br />

                <strong style="font-weight: bold">
                    Select Organization  :&nbsp;&nbsp;&nbsp;&nbsp;
                </strong>
                <asp:DropDownList ID="DropDownListOrganization" runat="server" AutoPostBack="True" OnSelectedIndexChanged="DropDownListOrganization_SelectedIndexChanged"></asp:DropDownList>
                &nbsp;&nbsp;&nbsp;&nbsp; <asp:Button ID="ButtonManageEmployee" runat="server" Text="Manage Employees"
                     class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                     Font-Bold="True" Height="30px" Width="175px" OnClick="ButtonManageEmployee_Click"/>

                <br /><br />
                <strong style="font-weight: bold">
                    Select Position  :&nbsp;&nbsp;&nbsp;&nbsp;
                </strong>
                <asp:DropDownList ID="DropDownListPosition" runat="server"></asp:DropDownList>
                <br /><br />
                <strong style="font-weight: bold">
                    <%-- 
                    <asp:CheckBox ID="CheckBoxPartTime" runat="server" Text="  Part Time" />
                    &nbsp;&nbsp;&nbsp;
                    <asp:CheckBox ID="CheckBoxExempt" runat="server" Text="  Exempt" />
                    &nbsp;&nbsp;&nbsp;
                    <asp:CheckBox ID="CheckBoxIsSalaried" runat="server" Text="  Salaried" />
                    &nbsp;&nbsp;&nbsp;
                    <asp:CheckBox ID="CheckBoxNotifyScheduleChange" runat="server" Text="  Notify Schedule Change" TextAlign="Left" ToolTip="Send an email if scheduled is modfiedS" />
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    --%>
                    <asp:CheckBox ID="CheckBoxStartTime" runat="server" Text="   <strong style='font-weight: bold'>Specify Start Time When Entering Tasks&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;</strong>" TextAlign="Left" />
                    <br /><br />
                    <asp:CheckBox ID="CheckBoxEndTime" runat="server" Text="  <strong style='font-weight: bold'>Specify End Time&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;</strong>" TextAlign="Left" />
                    <br /><br />
                    <strong style='font-weight: bold'>Employee Status</strong>&nbsp;&nbsp;&nbsp;
                        <asp:DropDownList ID="DropDownListEmployeeStatus" runat="server">
                            <asp:ListItem Text="Active" Value="0" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Terminated" Value="1" />
                            <asp:ListItem Text="Leave Of Absence" Value="1" />
                        </asp:DropDownList>
                    <br /><br />
                </strong>
                <br /><br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <asp:Button ID="ButtonSave" runat="server" Text="Save"
                     OnClientClick = "Confirm()"
                     class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                     Font-Bold="True" Height="50px" Width="150px" OnClick="ButtonSave_Click"/>
            </asp:Panel>
        </div>
    </form>
