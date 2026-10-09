<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeKeeperEmployeeScheduleViewer.aspx.cs" Inherits="Spedmon.TimeKeeperEmployeeScheduleViewer" MaintainScrollPositionOnPostBack="true" %>
    <script type = "text/javascript">
    </script>
   <style>
        tr.alternate {
            background-color: #E3EAEB;
        }
    </style>
    <form id="form1" runat="server">
    <div style="margin-left: 50px">
        <h1>Employee Schedules</h1>
        <asp:hiddenfield runat="server" ID="HiddenFieldEmployeeID"></asp:hiddenfield>
        <table>
            <tr>
                <td>
                    <strong style="font-weight: bold">Start Date of the Week</strong>&nbsp;&nbsp;&nbsp;&nbsp;
                </td>
                <td>
                    <strong style="font-weight: bold">Day of the Week</strong>&nbsp;&nbsp;&nbsp;&nbsp;
                </td>
                <td>
                    <strong style="font-weight: bold">Staff</strong>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label runat="server" ID="labelSelectedDate"></asp:Label>
                    &nbsp;&nbsp;&nbsp;
                    <asp:ImageButton ID="lnkpickdate" runat="server" OnClick="lnkpickdate_Click" ImageUrl="images/Calendar_scheduleHS.png"></asp:ImageButton>
                    <asp:Calendar ID="datepicker" runat="server" Visible="false" OnSelectionChanged="datepicker_SelectionChanged" 
                        OnDayRender="Calendar_DayRender" TodayDayStyle-BackColor="Red" TodayDayStyle-ForeColor="White"></asp:Calendar>
                </td>
                <td style="vertical-align: top">
                    <asp:dropdownlist runat="server" runat="server" ID="DropDownListDayOfWeek" AutoPostBack="True" 
                        OnSelectedIndexChanged="DropDownListDayOfWeek_SelectedIndexChanged">
                        <asp:ListItem Selected="True" Value="-1">All Days Of The Week</asp:ListItem>
                        <asp:ListItem Value="0">Sunday</asp:ListItem>
                        <asp:ListItem Value="1">Monday</asp:ListItem>
                        <asp:ListItem Value="2">Tuesday</asp:ListItem>
                        <asp:ListItem Value="3">Wednesday</asp:ListItem>
                        <asp:ListItem Value="4">Thursday</asp:ListItem>
                        <asp:ListItem Value="5">Friday</asp:ListItem>
                        <asp:ListItem Value="6">Saturday</asp:ListItem>
                    </asp:dropdownlist>
                </td>
                <td style="vertical-align: top">
                    <asp:dropdownlist runat="server" runat="server" ID="DropDownListEmployees" AutoPostBack="True" 
                        OnSelectedIndexChanged="DropDownListEmployees_SelectedIndexChanged">
                        <asp:ListItem Selected="True" Value="-1">All Employees</asp:ListItem>
                    </asp:dropdownlist>
                </td>
            </tr>
        </table>
        <br /><br />
        <asp:Repeater runat="server" ID="repeaterEmployeesSchedule">
            <HeaderTemplate>
                <table>
                    <thead style="background-color: #9FC6CB">
                        <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                            <strong style="font-weight: bold">
                                Name                         
                            </strong>
                        </th>
                        <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px;">
                            <strong style="font-weight: bold">
                                Week Start
                            </strong>
                        </th>
                        <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                            <strong style="font-weight: bold">
                                Day
                            </strong>
                        </th>
                        <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                            <strong style="font-weight: bold">
                                Date of Day
                            </strong>
                        </th>
                        <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                            <strong style="font-weight: bold">
                                Scheduled Times
                            </strong>
                        </th>
                        <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                            <strong style="font-weight: bold">
                                Hours For Day
                            </strong>
                        </th>
                        <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                            <strong style="font-weight: bold">
                                Hours For The Week
                            </strong>
                        </th>
                    </thead>
            </HeaderTemplate>
            <ItemTemplate>
                <tbody>
                    <tr class="<%# Container.ItemIndex % 2 == 0 ? "alternate" : "" %>">
                        <td style="vertical-align: top; white-space: nowrap">
                            <asp:Label runat="server" ID="labelName" Text='<%#Eval("Name") %>'></asp:Label>
                            <asp:HiddenField runat="server" ID="HiddenFieldScheduleId" Value='<%#Eval("ScheduleId") %>'></asp:HiddenField>
                            <asp:HiddenField runat="server" ID="HiddenFieldScheduleStartAndStopTimeId" Value='<%#Eval("ScheduleStartAndStopTimeIds") %>'></asp:HiddenField>
                            <asp:HiddenField runat="server" ID="HiddenFieldPersonId" Value='<%#Eval("PersonId") %>'></asp:HiddenField>
                            <asp:HiddenField runat="server" ID="HiddenFieldEmployeeId" Value='<%#Eval("EmployeeId") %>'></asp:HiddenField>
                        </td>
                        <td style="vertical-align: top; white-space: nowrap">
                            <asp:Label runat="server" ID="labelWeekStart" Text='<%#Eval("WeekStart") %>'></asp:Label>
                        </td>
                        <td style="vertical-align: top; white-space: nowrap">
                            <asp:Label runat="server" ID="labelDay" Text='<%#Eval("Day") %>'></asp:Label>
                        </td>
                        <td style="vertical-align: top; white-space: nowrap">
                            <asp:Label runat="server" ID="labelDateOfDay" Text='<%#Eval("DateOfDay") %>'></asp:Label>
                        </td>
                        <td style="vertical-align: top; white-space: nowrap">
                            <asp:Label runat="server" ID="labelScheduledTimes" Text='<%#Eval("ScheduledTimes") %>'></asp:Label>
                        </td>
                        <td style="vertical-align: top; white-space: nowrap; text-align:center">
                            <asp:Label runat="server" ID="labelDayHours" Text='<%#Eval("DayHours") %>'></asp:Label>
                        </td>
                        <td style="vertical-align: top; white-space: nowrap; text-align:center">
                            <asp:Label runat="server" ID="labelWeekHours" Text='<%#Eval("WeekHours") %>'></asp:Label>
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