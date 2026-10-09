<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebFormTimeEntrySchedule.aspx.cs" Inherits="Spedmon.WebFormSchedule" %>
     <script type="text/javascript" language="javascript">
          function PopupPicker(ctl) {
               var PopupWindow = null;
               PopupWindow = window.open('PopupCalendar.aspx?Ctl=' + ctl, 'PopupWindow', 'width=10,height=250,resizable=yes');
               PopupWindow.focus();
               return false;
          };
     </script>
    <form id="form1" runat="server">
       <div style="margin-left: 50px">
            <asp:literal runat="server" ID="LiteralMenu"></asp:literal>
            <br />
            <asp:HiddenField ID="HiddenFieldEmployeeId" runat="server" />
            <asp:HiddenField ID="HiddenFieldHoursScheduled" runat="server" />
            <asp:HiddenField ID="HiddenFieldMinutesScheduled" runat="server" />
            <strong style="font-weight:bold">Selected Employee</strong>&nbsp;&nbsp;&nbsp;
            <asp:DropDownList ID="DropDownListEmployees" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DropDownListEmployees_SelectedIndexChanged">
            </asp:DropDownList>
            <asp:Label ID="LabelEmployee" runat="server" Text=""></asp:Label>
            <br /><br />
            <strong style="font-weight:bold">Selected Date</strong>&nbsp;&nbsp;&nbsp;
            <asp:textbox id="tbSelectedDate" runat="server"></asp:textbox>
              &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="lnkpickdate" runat="server" OnClick="lnkpickdate_Click" ImageUrl="images/Calendar_scheduleHS.png"></asp:ImageButton>
              &nbsp;&nbsp;&nbsp;
            <asp:Calendar ID="datepicker" runat="server" Visible="false" OnSelectionChanged="datepicker_SelectionChanged"
                TodayDayStyle-BackColor="Red" TodayDayStyle-ForeColor="White"></asp:Calendar>
            <asp:HiddenField ID="HiddenFieldSelectedDate" runat="server" />
            <asp:HiddenField ID="HiddenFieldStartDate" runat="server" />
            <asp:HiddenField ID="HiddenFieldEndDate" runat="server" />
            <asp:HiddenField ID="HiddenFieldReferringPage" runat="server" />
            <br /><br />
            <asp:label runat="server" id="labelWarning" text="<h1>Reminder you cannot modify schedules that are not yours!!</h1>" Font-Bold="True" ForeColor="#CC0000"></asp:label>&nbsp;&nbsp;&nbsp;                
            <br /><br />
            <asp:Label ID="LabelHoursScheduled" runat="server" Text="<strong style='font-weight:bold'>Time Scheduled</strong>"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;
              <asp:Literal ID="LiteralScheduledTime" runat="server"></asp:Literal>
            <br /><br />
            <asp:Button ID="ButtonEdit" runat="server" Text="Details" OnClick="ButtonEdit_Click" Width="100" Font-Bold="True" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
            />
            <br /><br />
        </div>
        <table border="1" cellpadding="10" style="margin-left: 50px">
            <tr>
                <td>
                    <asp:Button ID="ButtonPreviousWeek" runat="server" Text="< Previous" Width="125" Height="50" OnClick="ButtonPreviousWeek_Click" Font-Bold="True"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                    />                
                </td>
                <td>
                    <asp:Literal ID="LiteralSunday" runat="server" Text="<p style='font-size: : medium'>SUNDAY<br />Scheduled : 8<br/><a href=''>1/1/2018</a></p>"></asp:Literal>
                </td>
                <td>
                    <asp:Literal ID="LiteralMonday" runat="server" Text="<p style='font-size: : medium'>MONDAY<br />Scheduled : 8<br/><a href=''>1/2/2018</a></p>"></asp:Literal>
                </td>
                <td>
                    <asp:Literal ID="LiteralTuesday" runat="server" Text="<p style='font-size: : medium'>TUESDAY<br />Scheduled : 8<br/><a href=''>1/3/2018</a></p>"></asp:Literal>
                </td>
                <td>
                    <asp:Literal ID="LiteralWednesday" runat="server" Text="<p style='font-size: : medium'>WEDNESDAY<br />Scheduled : 8<br/><a href=''>1/4/2018</a></p>"></asp:Literal>
                </td>
                <td>
                    <asp:Literal ID="LiteralThursday" runat="server" Text="<p style='font-size: : medium'>THURSDAY<br />Scheduled : 8<br/><a href=''>1/5/2018</a></p>"></asp:Literal>
                </td>
                <td>
                    <asp:Literal ID="LiteralFriday" runat="server" Text="<p style='font-size: : medium'>FRIDAY<br />Scheduled : 8<br/><a href=''>1/5/2018</a></p>"></asp:Literal>
                </td>
                <td>
                    <asp:Literal ID="LiteralSaturday" runat="server" Text="<p style='font-size: : medium'>SATURDAY<br />Scheduled : 8<br/><a href=''>1/5/2018</a></p>"></asp:Literal>
                </td>
                <td>
                    <asp:Button ID="ButtonNextWeek" runat="server" Text="Next >" Width="125" Height="50" OnClick="ButtonNextWeek_Click" Font-Bold="True"
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                    />
                </td>
            </tr>
        </table>
    </form>
