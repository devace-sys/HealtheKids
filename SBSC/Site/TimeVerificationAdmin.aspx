<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeVerificationAdmin.aspx.cs" Inherits="Spedmon.TimeVerificationAdmin" %>

<%@ Register Assembly="EAW.Web.UI" Namespace="EAW.Web.UI.Controls" TagPrefix="cc1" %>
<script type = "text/javascript">
        function ConfirmVerification()
        {
            var confirm_update = document.createElement("INPUT");
                confirm_update.type = "hidden";
                confirm_update.name = "confirm_update";
                if (confirm("Are you sure?"))
                {
                    confirm_update.value = "Yes";
                }
                else
                {
                    confirm_update.value = "No";
                    location.reload(true);
                }
                document.forms[0].appendChild(confirm_update);
        }

        function ConfirmRunTimeVerification()
        {
            var confirm_run = document.createElement("INPUT");
            confirm_run.type = "hidden";
            confirm_run.name = "confirm_run";
            if (confirm("Do you want to run auto scheduler (any old schedules will be deleted)?"))
            {
                confirm_run.value = "Yes";
            }
            else
            {
                confirm_run.value = "No";
                location.reload(true);
            }
            document.forms[0].appendChild(confirm_run);
        }
    </script>
<style>
     tr.alternate {
         background-color: #E3EAEB;
     }
     th {
         padding-left: 10px;
         padding-right:10px; 
         padding-top:10px; 
         padding-bottom:10px;
     }
     td {
         vertical-align: top; 
         white-space: nowrap;
     }
</style>

<form id="form1" runat="server">
    <div style="margin-left: 50px">
        <h1>Time Verifications</h1>
        <table>
            <tr>
                <td style="vertical-align: top">
                    <asp:Label runat="server" Text="Select Employee " ID="LabelStartDate" Font-Bold="True"></asp:Label>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:DropDownList runat="server" ID="DropDownListEmployees" AutoPostBack="False"></asp:DropDownList>
                    &nbsp;&nbsp;&nbsp;
                </td>
                <td style="vertical-align: top">
                    &nbsp;&nbsp;&nbsp;
                    <strong style="font-weight:bold">Start Date</strong>&nbsp;&nbsp;&nbsp;
                    <asp:Label runat="server" id="labelSelectedStartDate" Text="LabelEndDate"></asp:Label>
                    &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="imageButtonStartDate" runat="server"
                        ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px" OnClick="imageButtonStartDate_Click"></asp:ImageButton>
                    <asp:Calendar ID="datepickerStartDate" runat="server" Visible="false"
                         TodayDayStyle-BackColor="Red" TodayDayStyle-ForeColor="White" OnSelectionChanged="datepickerStartDate_SelectionChanged"></asp:Calendar>
                </td>
                <td style="vertical-align: top">
                    &nbsp;&nbsp;&nbsp;
                    <strong style="font-weight:bold">End Date</strong>&nbsp;&nbsp;&nbsp;
                    <asp:Label runat="server" id="labelSelectedEndDate" Text="Label"></asp:Label>
                    &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="ImageButtonEndDate" runat="server"
                        ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px" OnClick="ImageButtonEndDate_Click"></asp:ImageButton>
                    <asp:Calendar ID="datepickerEndDate" runat="server" Visible="false"
                         TodayDayStyle-BackColor="Red" TodayDayStyle-ForeColor="White" OnSelectionChanged="datepickerEndDate_SelectionChanged"></asp:Calendar>
                </td>
                <td style="vertical-align: top">
                    &nbsp;&nbsp;&nbsp;
                    <asp:Button ID="ButtonUpdate" runat="server" Text="Search" Height="42px" Width="163px" 
                    Font-Bold="True" 
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" OnClick="ButtonUpdate_Click" 
                    />
                </td>
                <td style="vertical-align: top">
                    &nbsp;&nbsp;&nbsp;
                    <asp:Button ID="ButtonClearDateFilter" runat="server" Text="Clear Time" Height="42px" Width="163px" 
                    Font-Bold="True" 
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" 
                        OnClick="ButtonClearDateFilter_Click" 
                    />
                </td>
            </tr>
            <tr>
                <td>
                    <strong style="font-weight: bold">
                        Select Pay Week To Run Verification Generator&nbsp;&nbsp;&nbsp
                    </strong>
                </td>
                <td style="vertical-align: top">
                    <asp:Label runat="server" id="labelVerificationDate" Text="LabelEndDate"></asp:Label>
                    &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="imageButtonDateToRunVerification" runat="server"
                        ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px" OnClick="imageButtonDateToRunVerification_Click" 
                        ></asp:ImageButton>
                    <asp:Calendar ID="CalendarCalendarVerification" runat="server" Visible="false"
                        OnSelectionChanged="datepicker_SelectionChanged" 
                        OnDayRender="Calendar_DayRender"
                         TodayDayStyle-BackColor="Red" 
                        TodayDayStyle-ForeColor="White" 
                        ></asp:Calendar>
                </td>
            </tr>
        </table>
        <br /><br />
        <asp:Repeater runat="server" ID="repeaterVerification">
            <HeaderTemplate>
                <table>
                    <thead style="background-color: #9FC6CB">
                        <th>
                            <strong style="font-weight: bold">Last Name</strong>
                        </th>
                        <th>
                            <strong style="font-weight: bold">First Name</strong>
                        </th>
                        <th>
                            <strong style="font-weight: bold">Last Day of Schedule</strong>
                        </th>
                        <th>
                            <strong style="font-weight: bold">Date Verified</strong>
                        </th>
                        <th>
                            <string style="font-weight: bold">Comments</string>
                        </th>
                        <th>
                            <strong style="font-weight: bold">Action</strong>
                        </th>
                    </thead>
            </HeaderTemplate>
            <ItemTemplate>
                    <tbody>
                        <tr class="<%# Container.ItemIndex % 2 == 0 ? "alternate" : "" %>">
                            <td>
                                &nbsp;<asp:Label ID="labelLastName" runat="server"
                                     Text='<%#Eval("lastName") %>'></asp:Label>
                                <asp:HiddenField ID="HiddenFieldId"
                                    Value='<%#Eval("id") %>'
                                    runat="server"></asp:HiddenField>
                                <asp:HiddenField ID="HiddenFieldEmployeeId"
                                    Value='<%#Eval("employeeId") %>'
                                    runat="server"></asp:HiddenField>
                            </td>
                            <td>
                                &nbsp;<asp:Label ID="labelFirstName" runat="server"
                                     Text='<%#Eval("firstName") %>'></asp:Label>
                            </td>
                            <td>
                                &nbsp;<asp:Label ID="labellastDayOfSchedule" runat="server"
                                    Text='<%#Eval("lastDayOfSchedule") %>'></asp:Label>
                            </td>
                            <td>
                                &nbsp;<asp:Label ID="labelDateVerified" runat="server"
                                    Text='<%#Eval("dateVerified") %>'></asp:Label>
                            </td>
                            <td>
                                &nbsp;<asp:TextBox ID="textBoxComments" runat="server" Height="47px" 
                                    TextMode="MultiLine" Width="313px"
                                    Text='<%#Eval("comments") %>'></asp:TextBox>
                            </td>
                            <td>
                                <asp:Button ID="ButtonVerify" runat="server" Text="Verify" Height="42px" Width="100px" 
                                    Font-Bold="True" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" 
                                    OnClientClick="ConfirmVerification()"
                                    OnClick="ButtonVerify_Click" 
                                />
                                <asp:Button ID="ButtonRemoveVerify" runat="server" Text="Unverify" Height="42px" 
                                    Width="100  px" 
                                    Font-Bold="True" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" 
                                    OnClientClick="ConfirmVerification()"
                                    OnClick="ButtonRemoveVerify_Click" 
                                />
                            </td>
                        </tr>
                    </tbody>
            </ItemTemplate>
            <FooterTemplate>
                </table>
            </FooterTemplate>
        </asp:Repeater>

    </div>
</form>
