<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InsertOrUpdateTimeEntry.aspx.cs" Inherits="Spedmon.InsertOrUpdateTimeEntry" 
  MaintainScrollPositionOnPostBack="true" %>
    <script type = "text/javascript">
        function Confirm() {
                var confirm_value = document.createElement("INPUT");
                confirm_value.type = "hidden";
                confirm_value.name = "confirm_value";
                if (confirm("Do you want to remove record?")) {
                    confirm_value.value = "Yes";
                } else {
                    confirm_value.value = "No";
                    location.reload(true);
                }
                document.forms[0].appendChild(confirm_value);
                Encode();
            }
    </script>
    <script type = "text/javascript">
        function Encode() {
          var value = (document.getElementById('TextBoxNotes').value);
            value = value.replaceAll('<', "&lt;");
            value = value.replaceAll('>', "&gt;");
            value = value.replaceAll('&', "&amp;");
            value = value.replaceAll('"', "&quot;");
            value = value.replaceAll("'", "&apos;");

            document.getElementById('TextBoxNotes').value = value;
         }
    </script>
      <style type="text/css">
        .GridView1 > tbody > tr > td { border: 2px ridge black; padding: 3px; }
      </style>
    <form id="form1" runat="server">
        <asp:HiddenField ID="HiddenFieldDisplayStartTime" runat="server" Value="false" />
        <asp:HiddenField ID="HiddenFieldDisplayStopTime" runat="server" Value="false" />
        <asp:HiddenField ID="HiddenFieldtimeOfTaskOrder" runat="server" Value="ASC" />
        <asp:HiddenField ID="HiddenFieldTimeSpent" runat="server" Value="ASC" />
        <asp:HiddenField ID="HiddenFieldTask" runat="server" Value="ASC" />
        <asp:HiddenField ID="HiddenFieldClient" runat="server" Value="ASC" />
        <asp:HiddenField ID="HiddenFieldNote" runat="server" Value="ASC" />
          <asp:HiddenField ID="HiddenFieldTimeEntryDayID" runat="server" />
          <asp:HiddenField ID="HiddenFieldTimeEntryID" runat="server" />
          <asp:HiddenField ID="HiddenFieldPreviousPage" runat="server" />
          <asp:HiddenField ID="HiddenFieldEmployeeID" runat="server" />
          <asp:HiddenField ID="HiddenFieldDateTimeEntry" runat="server" />
        <asp:HiddenField ID="HiddenFieldAllClientID" runat="server" />
        <asp:HiddenField ID="HiddenFieldHasMultipleClients" runat="server" />
        <asp:HiddenField ID="HiddenFieldIsHoliday" runat="server" />

          <asp:Panel ID="PanelDateEntry" runat="server" Visible="false" style="margin-left: 50px">
              <asp:Panel ID="PanelEmployeeOnly" runat="server" Visible="true" style="margin-left: 50px">
                <h1 style="margin-left: 40px"><asp:Label runat="server" Text="Employee Name" ID="LabelEmployeeName" Font-Bold="True"></asp:Label></h1><br />
                <asp:label runat="server" ID="labelWeeklyHourCount" Font-Bold="True" Font-Size="Large" ForeColor="Blue"></asp:label>
              </asp:Panel>
              <asp:panel runat="server" ID="PanelVerifyHours" Visible="false">
                  <asp:HiddenField runat="server" ID="HiddenFieldVerifyId"></asp:HiddenField>
                  <asp:HiddenField runat="server" ID="HiddenFieldLastDayOfSchedule"></asp:HiddenField>
                  <asp:HiddenField runat="server" ID="HiddenFieldComments"></asp:HiddenField>
                  <h1>
                      <asp:Label runat="server" ID="LabelVerifyHours" Font-Bold="True" Text="You Need to Verify Hours"></asp:Label>
                  </h1>
                  <asp:CheckBox ID="CheckBoxVerifyHours" runat="server" AutoPostBack="True" OnCheckedChanged="CheckBoxVerifyHours_CheckedChanged"></asp:CheckBox>
                  &nbsp;&nbsp;<asp:Label runat="server" ID="LabelVerifyPrompt" Font-Bold="True"></asp:Label>
                  <br /><br /><br />
              </asp:panel>
              <asp:Panel ID="PanelAdminEmployees" runat="server" Visible="false">
                <asp:Label runat="server" ID="LabelAdminEmployee" Font-Bold="True" Text="<h1>Read Only</h1>" Visible="False" ForeColor="Red"></asp:Label>
                <asp:Label runat="server" Text="Select Employee " ID="Label1" Font-Bold="True"></asp:Label>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <asp:DropDownList runat="server" ID="DropDownListEmployees" AutoPostBack="True" OnSelectedIndexChanged="DropDownListEmployees_SelectedIndexChanged"></asp:DropDownList>
                <br /><br />
              </asp:Panel>
              <strong style="font-weight:bold">Date For Time Entry</strong>&nbsp;&nbsp;&nbsp;
              <asp:Label runat="server" id="tbSelectedDate" Text="Label"></asp:Label>
              &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="lnkpickdate" runat="server" OnClick="lnkpickdate_Click" OnClientClick="Encode()"
                  ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px"></asp:ImageButton>
              <asp:Calendar ID="datepicker" runat="server" Visible="false" OnSelectionChanged="datepicker_SelectionChanged"
                   TodayDayStyle-BackColor="Red" TodayDayStyle-ForeColor="White"></asp:Calendar>
              <asp:label ID="LiteralMessage" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
          </asp:Panel>
          <asp:Panel ID="PanelRecord" runat="server" Visible="false" style="margin-left: 50px">
              <table>
                   <tr>
                        <td><strong style="font-weight:bold">Employee Name</strong></td>
                        <td>
                             <asp:Literal ID="LiteralEmployeeName" runat="server"></asp:Literal>
                        </td>
                   </tr>
                  <tr>
                      <td><br /></td>
                      <td></td>
                  </tr>
                   <tr>
                        <td style="vertical-align:top">
                             <strong style="font-weight:bold">Select Employer</strong>
                        </td>
                        <td>
                             <asp:DropDownList ID="DropDownListEmployer" runat="server">
                             </asp:DropDownList>
                        </td>
                   </tr>
                  <tr>
                      <td><br /></td>
                      <td></td>
                  </tr>
                   <tr>
                        <td style="vertical-align:top">
                             <strong style="font-weight:bold">Select Task</strong>
                             <asp:RadioButtonList ID="RadioButtonListTaskType" runat="server" 
                                 AutoPostBack="true" 
                                 OnSelectedIndexChanged="RadioButtonListTaskType_SelectedIndexChanged">
                                <asp:ListItem Text="All Types" Value="0" Selected="true" />
                                <asp:ListItem Text="Single Client Tasks" Value="1" />
                                <asp:ListItem Text="Multiple Client Tasks" Value="2"/>
                             </asp:RadioButtonList>
                        </td>
                        <td>
                             <asp:ListBox ID="ListBoxFavoriteTaskTimeEntry" 
                                 runat="server" 
                                 Height="131px" 
                                 Width="900px"
                                OnSelectedIndexChanged="ListBoxFavoriteTaskTimeEntry_SelectedIndexChanged" 
                                AutoPostBack="true"                                 >

                             </asp:ListBox><br />
                             <br />

                        </td>
                   </tr>
                   <tr>
                        <td style="vertical-align:top">
                             <strong style="font-weight:bold">Select Client</strong>
                        </td>
                        <td>
                            <asp:ListBox ID="ListBoxFavoriteClientTimeEntry" 
                                runat="server" 
                                Width="900px" 
                                Height="131px"
                             ></asp:ListBox>
                            <asp:Literal ID="ListBoxLineBreak" runat="server" Text="<br/><br/>" Visible="true" />
                        </td>
                   </tr>
                   <tr>
                        <td class="auto-style1">
                             <asp:Literal ID="LiteralDateOfEntryLabel" runat="server"
                                Text="<strong style='font-weight:bold'>Date Of Entry</strong>">

                             </asp:Literal>
                        </td>
                        <td class="auto-style1">
                             <asp:Literal ID="LiteralDateOfEntry" runat="server"></asp:Literal>
                        </td>
                   </tr>
                  <tr>
                      <td><br /></td>
                      <td></td>
                  </tr>
                   <tr>
                        <td>
                             <strong style="font-weight:bold">
                                 <asp:Literal ID="LiteralStartTime" runat="server" Text="Select Start Time"></asp:Literal>
                             </strong>
                        </td>
                        <td>
                            <asp:Panel ID="PanelStartTime" runat="server">
                                <table>
                                    <tr>
                                        <td style="vertical-align:top">
                                             <asp:TextBox ID="TextBoxStartTime" runat="server" ValidationGroup="TimeEntries" Enabled="true"></asp:TextBox>
                                              <asp:RegularExpressionValidator 
                                                  ID="RegularExpressionValidatorStartTime" 
                                                  runat="server" 
                                                   ControlToValidate="TextBoxStartTime"
                                                  ErrorMessage="<br/><font color='Red'>Invalid time format</font>"
                                                  ValidationExpression="(^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([0-9]|0[0-9]|1[0-9]):[0-5][0-9] ([pP][mM]|[aA][mM])$)"
                                                  ValidationGroup="TimeEntries"
                                                  Display="Dynamic"></asp:RegularExpressionValidator>
                                              <asp:RequiredFieldValidator ID="RequiredFieldValidatorStartTime" 
                                                  runat="server"
                                                  ControlToValidate="TextBoxStartTime"
                                                  ErrorMessage="<br/><font color='Red'>Start time is required</font>"
                                                  ValidationGroup="TimeEntries"
                                                  Display="Dynamic"></asp:RequiredFieldValidator>
                                        </td>
                                        <td style="vertical-align:top; text-align:left">
                                            <asp:ImageButton ID="ImageButtonStartTimeInfo" runat="server" ImageUrl="~/images/clockkpicker.png" OnClick="ImageButtonStartTimeInfo_Click" />
                                            <asp:Panel ID="PanelPickStartTime" runat="server" Visible="false">
                                                <table>
                                                    <tr>
                                                        <th style="padding:10px">
                                                            <strong style="font-weight:bold">Hours</strong><br />
                                                        </th>
                                                        <th style="padding:10px">
                                                            <strong style="font-weight:bold">Minutes</strong><br />
                                                        </th>
                                                        <th style="padding:10px">
                                                            <strong style="font-weight:bold">AM/PM</strong><br />
                                                        </th>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding:10px">
                                                            <asp:DropDownList ID="ListBoxHoursStart" runat="server">
                                                                <asp:ListItem Text="1" Value="1" />
                                                                <asp:ListItem Text="2" Value="2" />
                                                                <asp:ListItem Text="3" Value="3" />
                                                                <asp:ListItem Text="4" Value="4" />
                                                                <asp:ListItem Text="5" Value="5" />
                                                                <asp:ListItem Text="6" Value="6" />
                                                                <asp:ListItem Text="7" Value="7" />
                                                                <asp:ListItem Text="8" Value="8" />
                                                                <asp:ListItem Text="9" Value="9" />
                                                                <asp:ListItem Text="10" Value="10" />
                                                                <asp:ListItem Text="11" Value="11" />
                                                                <asp:ListItem Text="12" Value="12" Selected="True" />
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td style="padding:10px">
                                                            <asp:DropDownList ID="DropDownListMinutesStart" runat="server">
                                                                <asp:ListItem Text="00" Value="00" Selected="True" />
                                                                <asp:ListItem Text="01" Value="01" />
                                                                <asp:ListItem Text="02" Value="02" />
                                                                <asp:ListItem Text="03" Value="03" />
                                                                <asp:ListItem Text="04" Value="04" />
                                                                <asp:ListItem Text="05" Value="05" />
                                                                <asp:ListItem Text="06" Value="06" />
                                                                <asp:ListItem Text="07" Value="07" />
                                                                <asp:ListItem Text="08" Value="08" />
                                                                <asp:ListItem Text="09" Value="09" />
                                                                <asp:ListItem Text="10" Value="10" />
                                                                <asp:ListItem Text="11" Value="11" />
                                                                <asp:ListItem Text="12" Value="12" />
                                                                <asp:ListItem Text="13" Value="13" />
                                                                <asp:ListItem Text="14" Value="14" />
                                                                <asp:ListItem Text="15" Value="15" />
                                                                <asp:ListItem Text="16" Value="16" />
                                                                <asp:ListItem Text="17" Value="17" />
                                                                <asp:ListItem Text="18" Value="18" />
                                                                <asp:ListItem Text="19" Value="19" />
                                                                <asp:ListItem Text="20" Value="20" />
                                                                <asp:ListItem Text="21" Value="21" />
                                                                <asp:ListItem Text="22" Value="22" />
                                                                <asp:ListItem Text="23" Value="23" />
                                                                <asp:ListItem Text="24" Value="24" />
                                                                <asp:ListItem Text="25" Value="25" />
                                                                <asp:ListItem Text="26" Value="26" />
                                                                <asp:ListItem Text="27" Value="27" />
                                                                <asp:ListItem Text="28" Value="28" />
                                                                <asp:ListItem Text="29" Value="29" />
                                                                <asp:ListItem Text="30" Value="30" />
                                                                <asp:ListItem Text="31" Value="31" />
                                                                <asp:ListItem Text="32" Value="32" />
                                                                <asp:ListItem Text="33" Value="33" />
                                                                <asp:ListItem Text="34" Value="34" />
                                                                <asp:ListItem Text="35" Value="35" />
                                                                <asp:ListItem Text="36" Value="36" />
                                                                <asp:ListItem Text="37" Value="37" />
                                                                <asp:ListItem Text="38" Value="38" />
                                                                <asp:ListItem Text="39" Value="39" />
                                                                <asp:ListItem Text="40" Value="40" />
                                                                <asp:ListItem Text="41" Value="41" />
                                                                <asp:ListItem Text="42" Value="42" />
                                                                <asp:ListItem Text="43" Value="43" />
                                                                <asp:ListItem Text="44" Value="44" />
                                                                <asp:ListItem Text="45" Value="45" />
                                                                <asp:ListItem Text="46" Value="46" />
                                                                <asp:ListItem Text="47" Value="47" />
                                                                <asp:ListItem Text="48" Value="48" />
                                                                <asp:ListItem Text="49" Value="49" />
                                                                <asp:ListItem Text="50" Value="50" />
                                                                <asp:ListItem Text="51" Value="51" />
                                                                <asp:ListItem Text="52" Value="52" />
                                                                <asp:ListItem Text="53" Value="53" />
                                                                <asp:ListItem Text="54" Value="54" />
                                                                <asp:ListItem Text="55" Value="55" />
                                                                <asp:ListItem Text="56" Value="56" />
                                                                <asp:ListItem Text="57" Value="57" />
                                                                <asp:ListItem Text="58" Value="58" />
                                                                <asp:ListItem Text="59" Value="59" />
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td style="padding:10px">
                                                            <asp:DropDownList ID="DropDownListAMPMStart" runat="server">
                                                                <asp:ListItem Text="AM" Value="AM" Selected="True" />
                                                                <asp:ListItem Text="PM" Value="PM" />
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3" style="padding:10px; text-align:center">
                                                            <asp:Button ID="ButtonSelectStartTime" runat="server" Text="Select Time" Height="42px" Width="163px"
                                                                OnClick="ButtonSelectStartTime_Click"  
                                                            Font-Bold="True" OnClientClick="Encode()"
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                                                            />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                  </tr>
                   <tr>
                        <td>
                             <strong style="font-weight:bold">
                                 <asp:Literal ID="LiteralStopTime" runat="server" Text="Select Stop Time"></asp:Literal>
                             </strong>
                        </td>
                        <td>
                            <asp:Panel ID="PanelStopTime" runat="server">
                                <table>
                                    <tr>
                                        <td style="vertical-align:top">
                                             <asp:TextBox ID="TextBoxStopTime" runat="server" ValidationGroup="TimeEntries" Enabled="true"></asp:TextBox>
                                              <asp:RegularExpressionValidator 
                                                  ID="RegularExpressionValidatorStopTime" 
                                                  runat="server" 
                                                   ControlToValidate="TextBoxStopTime"
                                                  ErrorMessage="<br/><font color='Red'>Invalid time format</font>"
                                                  ValidationExpression="(^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([0-9]|0[0-9]|1[0-9]):[0-5][0-9] ([pP][mM]|[aA][mM])$)"
                                                  ValidationGroup="TimeEntries"
                                                  Display="Dynamic"></asp:RegularExpressionValidator>
                                              <asp:RequiredFieldValidator ID="RequiredFieldValidatorStopTime" 
                                                  runat="server"
                                                  ControlToValidate="TextBoxStopTime"
                                                  ErrorMessage="<br/><font color='Red'>Stop time is required</font>"
                                                  ValidationGroup="TimeEntries"
                                                  Display="Dynamic"></asp:RequiredFieldValidator>
                                        </td>
                                        <td style="vertical-align:top; text-align:left">
                                            <asp:ImageButton ID="ImageButtonStopTime" runat="server" ImageUrl="~/images/clockkpicker.png" OnClick="ImageButtonStopTimeInfo_Click" />
                                            <asp:Panel ID="PanelPickStopTime" runat="server" Visible="false">
                                                <table>
                                                    <tr>
                                                        <th style="padding:10px">
                                                            <strong style="font-weight:bold">Hours</strong><br />
                                                        </th>
                                                        <th style="padding:10px">
                                                            <strong style="font-weight:bold">Minutes</strong><br />
                                                        </th>
                                                        <th style="padding:10px">
                                                            <strong style="font-weight:bold">AM/PM</strong><br />
                                                        </th>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding:10px">
                                                            <asp:DropDownList ID="DropDownListStopHour" runat="server">
                                                                <asp:ListItem Text="1" Value="1" />
                                                                <asp:ListItem Text="2" Value="2" />
                                                                <asp:ListItem Text="3" Value="3" />
                                                                <asp:ListItem Text="4" Value="4" />
                                                                <asp:ListItem Text="5" Value="5" />
                                                                <asp:ListItem Text="6" Value="6" />
                                                                <asp:ListItem Text="7" Value="7" />
                                                                <asp:ListItem Text="8" Value="8" />
                                                                <asp:ListItem Text="9" Value="9" />
                                                                <asp:ListItem Text="10" Value="10" />
                                                                <asp:ListItem Text="11" Value="11" />
                                                                <asp:ListItem Text="12" Value="12" Selected="True" />
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td style="padding:10px">
                                                            <asp:DropDownList ID="DropDownListStopMinutes" runat="server">
                                                                <asp:ListItem Text="00" Value="00" Selected="True" />
                                                                <asp:ListItem Text="01" Value="01" />
                                                                <asp:ListItem Text="02" Value="02" />
                                                                <asp:ListItem Text="03" Value="03" />
                                                                <asp:ListItem Text="04" Value="04" />
                                                                <asp:ListItem Text="05" Value="05" />
                                                                <asp:ListItem Text="06" Value="06" />
                                                                <asp:ListItem Text="07" Value="07" />
                                                                <asp:ListItem Text="08" Value="08" />
                                                                <asp:ListItem Text="09" Value="09" />
                                                                <asp:ListItem Text="10" Value="10" />
                                                                <asp:ListItem Text="11" Value="11" />
                                                                <asp:ListItem Text="12" Value="12" />
                                                                <asp:ListItem Text="13" Value="13" />
                                                                <asp:ListItem Text="14" Value="14" />
                                                                <asp:ListItem Text="15" Value="15" />
                                                                <asp:ListItem Text="16" Value="16" />
                                                                <asp:ListItem Text="17" Value="17" />
                                                                <asp:ListItem Text="18" Value="18" />
                                                                <asp:ListItem Text="19" Value="19" />
                                                                <asp:ListItem Text="20" Value="20" />
                                                                <asp:ListItem Text="21" Value="21" />
                                                                <asp:ListItem Text="22" Value="22" />
                                                                <asp:ListItem Text="23" Value="23" />
                                                                <asp:ListItem Text="24" Value="24" />
                                                                <asp:ListItem Text="25" Value="25" />
                                                                <asp:ListItem Text="26" Value="26" />
                                                                <asp:ListItem Text="27" Value="27" />
                                                                <asp:ListItem Text="28" Value="28" />
                                                                <asp:ListItem Text="29" Value="29" />
                                                                <asp:ListItem Text="30" Value="30" />
                                                                <asp:ListItem Text="31" Value="31" />
                                                                <asp:ListItem Text="32" Value="32" />
                                                                <asp:ListItem Text="33" Value="33" />
                                                                <asp:ListItem Text="34" Value="34" />
                                                                <asp:ListItem Text="35" Value="35" />
                                                                <asp:ListItem Text="36" Value="36" />
                                                                <asp:ListItem Text="37" Value="37" />
                                                                <asp:ListItem Text="38" Value="38" />
                                                                <asp:ListItem Text="39" Value="39" />
                                                                <asp:ListItem Text="40" Value="40" />
                                                                <asp:ListItem Text="41" Value="41" />
                                                                <asp:ListItem Text="42" Value="42" />
                                                                <asp:ListItem Text="43" Value="43" />
                                                                <asp:ListItem Text="44" Value="44" />
                                                                <asp:ListItem Text="45" Value="45" />
                                                                <asp:ListItem Text="46" Value="46" />
                                                                <asp:ListItem Text="47" Value="47" />
                                                                <asp:ListItem Text="48" Value="48" />
                                                                <asp:ListItem Text="49" Value="49" />
                                                                <asp:ListItem Text="50" Value="50" />
                                                                <asp:ListItem Text="51" Value="51" />
                                                                <asp:ListItem Text="52" Value="52" />
                                                                <asp:ListItem Text="53" Value="53" />
                                                                <asp:ListItem Text="54" Value="54" />
                                                                <asp:ListItem Text="55" Value="55" />
                                                                <asp:ListItem Text="56" Value="56" />
                                                                <asp:ListItem Text="57" Value="57" />
                                                                <asp:ListItem Text="58" Value="58" />
                                                                <asp:ListItem Text="59" Value="59" />
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td style="padding:10px">
                                                            <asp:DropDownList ID="DropDownListStopAMPM" runat="server">
                                                                <asp:ListItem Text="AM" Value="AM" Selected="True" />
                                                                <asp:ListItem Text="PM" Value="PM" />
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3" style="padding:10px; text-align:center">
                                                            <asp:Label ID="LabelStopTimeError" runat="server" ForeColor="#CC0000"></asp:Label>
                                                            <asp:Button ID="ButtonSelectStopTime" runat="server" Text="Select Time" Height="42px" Width="163px" 
                                                                OnClick="ButtonSelectStopTime_Click"   OnClientClick="Encode()"
                                                            Font-Bold="True" 
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                                                            />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                  </tr>
                  <tr>
                      <td><br /></td>
                      <td></td>
                  </tr>
                  <tr>
                        <td>
                             <strong style="font-weight:bold">Enter Hours Spent</strong>                         
                        </td>
                        <td>
                             <asp:Literal ID="LiteralHours" runat="server"></asp:Literal>
                             <asp:TextBox ID="TextBoxHours" runat="server" ValidationGroup="TimeEntries" Text="0"  ClientIDMode="Static"></asp:TextBox>
                              <asp:RegularExpressionValidator 
                                  ID="RegularExpressionValidatorHours" 
                                  runat="server" 
                                   ControlToValidate="TextBoxHours"
                                  ErrorMessage="<br/><font color='Red'>Valid Hours are 0 to 23</font>"
                                  ValidationExpression="(^([0-9]|[01][0-9]|2[0-4])$)|(^$)|(^ *$)"
                                  ValidationGroup="TimeEntries"
                                  Display="Dynamic"></asp:RegularExpressionValidator>
                        </td>
                   </tr>
                  <tr>
                      <td><br /></td>
                      <td></td>
                  </tr>
                   <tr>
                        <td>
                             <strong style="font-weight:bold">Enter Minutes Spent</strong>
                        </td>
                        <td>
                             <asp:Literal ID="LiteralMinutes" runat="server"></asp:Literal>
                             <asp:TextBox ID="TextBoxMinutes" runat="server" ValidationGroup="TimeEntries" Text="0" ClientIDMode="Static"></asp:TextBox>
                              <asp:RegularExpressionValidator 
                                  ID="RegularExpressionValidatorMinutes" 
                                  runat="server" 
                                   ControlToValidate="TextBoxMinutes"
                                  ErrorMessage="<br/><font color='Red'>Valid Minutes are 0 to 59</font>"
                                  ValidationExpression="(^([0-9]|[0-5][0-9])$)|(^$)|(^ *$)"
                                  ValidationGroup="TimeEntries"
                                  Display="Dynamic"></asp:RegularExpressionValidator>
                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align: top"">
                            <strong style="font-weight:bold">Enter Smartsheet ID #<br />Leave blank if not applicable</strong>
                        </td>
                        <td>
                            <asp:TextBox ID="TextBoxSmartSheetID" runat="server" Width="323px"></asp:TextBox>
                        </td>
                   </tr>
                    <tr>
                        <td style="vertical-align: top"">
                            <strong style="font-weight:bold">Reference Document Filename<br />(For Production staff)<br />Leave blank if not required or applicable</strong>
                        </td>
                        <td>
                            <asp:TextBox ID="TextBoxReferenceDocumentFileName" runat="server" Width="323px"></asp:TextBox>
                        </td>
                   </tr>
                  <tr>
                      <td><br /></td>
                      <td></td>
                  </tr>
                   <tr>
                        <td style="vertical-align:top">
                             <strong style="font-weight:bold">Note</strong>
                        </td>
                        <td>
                             <asp:TextBox ID="TextBoxNotes" runat="server" TextMode="MultiLine" Width="900" Height="150"></asp:TextBox>
                        </td>
                   </tr>
                  <tr>
                      <td style="vertical-align:top">
                             <strong style="font-weight:bold">File (Comments)</strong>
                        </td>
                        <td>
                             <asp:TextBox ID="TextBoxFile" runat="server" Width="400"></asp:TextBox>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:CheckBox runat="server" ID="CheckboxComplete" Text="Complete &nbsp;&nbsp;" TextAlign="Left"></asp:CheckBox>
                        </td>
                  </tr>
                   <tr>
                      <td><br /></td>
                      <td></td>
                   </tr>
                   <tr style="vertical-align:top">
                        <td style="text-align:right">
                             <asp:Button ID="ButtonSave" runat="server" Text="Save" OnClick="Save" ValidationGroup="TimeEntries"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                                        Font-Bold="True" Height="30px" Width="106px" OnClientClick="Encode()"/>
                             &nbsp;&nbsp;&nbsp;
                        </td>
                        <td style="text-align:left">
                             &nbsp;&nbsp;&nbsp;
                             <asp:Button ID="ButtonCancel" runat="server" Text="Cancel" OnClick="Back"  Font-Bold="True" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                                        Height="30px" Width="106px"  OnClientClick="Encode()"/>
                             &nbsp;
                             <asp:Label ID="LabelProblem" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                        </td>
                    </tr>
              </table>
          </asp:Panel>
          <asp:Panel ID="PanelInsert" runat="server" Visible="true" style="margin-left: 50px">
              <table>
                <tr>
                    <td>
                        <asp:Button ID="ButtonInsert" runat="server" Text="Create New Entry" Width="221px" OnClick="ButtonInsert_Click"
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                              Font-Bold="True" Height="45px"  OnClientClick="Encode()"/>
                    </td>
                    <td>
                        &nbsp;&nbsp;&nbsp;
                    </td>
                    <td>
                        <asp:Button ID="ButtonBack" runat="server" Text="Back" Width="221" OnClick="ButtonBack_Click" Font-Bold="True"
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                              Height="45px"  OnClientClick="Encode()" />
                    </td>
                </tr>
              </table>
          </asp:Panel>
          <br />
        <div style="margin-left: 50px">
            <asp:HiddenField runat="server" ID="HiddenFieldTotalTime" Value="0"></asp:HiddenField>
              <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" CellPadding="1" CellSpacing="1"
                  DataKeyNames="id" OnRowCancelingEdit="GridView1_RowCancelingEdit" GridLines="none"
                  OnRowDeleting="GridView1_RowDeleting" OnRowEditing="GridView1_RowEditing" OnRowUpdating="GridView1_RowUpdating"
                  OnRowDataBound="GridView1_RowDataBound" OnRowCommand="GridView1_RowCommand" OnSorting="GridView1_Sorting" AllowSorting="true"
                   Width="2500px" CssClass="GridView1">
                  <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                  <Columns>
                      <asp:TemplateField>
                          <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                          <ItemStyle HorizontalAlign="Center"></ItemStyle>                    
                          <ItemTemplate>
                              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                              <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" 
                                Font-Bold="True"
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                                  OnClientClick="Encode()"/>
                              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                              <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Delete" Width="100" Height="30" 
                                Font-Bold="True" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                                  OnClientClick="Confirm()" />
                          </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Start and<br/> Stop Time</strong><br/><br/>" SortExpression="timeOfTask" >
                          <HeaderStyle Height="40px" Width="100px"></HeaderStyle>
                          <ItemStyle></ItemStyle>                    
                            <ItemTemplate>
                                <asp:HiddenField ID="HiddenFieldItemTemplateIDEdit" runat="server" Value='<%#Eval("id") %>' />
                                <asp:HiddenField ID="HiddenFieldTimeEntryDayTableID" runat="server" Value='<%#Eval("timeEntryDayID") %>' />
                                <asp:HiddenField ID="HiddenFieldClientID" runat="server" Value='<%#Eval("client_id") %>' />
                                <asp:HiddenField ID="HiddenFieldTaskID" runat="server" Value='<%#Eval("task_id") %>' />
                                <asp:HiddenField ID="HiddenFieldHolidayID" runat="server" Value='<%#Eval("holidayTaskID") %>' />
                                <asp:HiddenField ID="HiddenFieldNumberMinutes" runat="server" Value='<%#Eval("numberMinutes") %>' />
                                Start : <asp:Label ID="LabelTimeOfTask" runat="server" Text=""></asp:Label><br />
                                Stop : <asp:Label ID="LabelTimeTaskEnded" runat="server" Text=""></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Time Spent</strong><br/><br/>" SortExpression="TimeSpent">
                          <HeaderStyle Height="40px" Width="125px"></HeaderStyle>
                          <ItemStyle></ItemStyle>                    
                          <ItemTemplate>
                              <asp:Literal ID="LiteralHours" runat="server"></asp:Literal>
                              &nbsp;&nbsp;
                              <asp:Literal ID="LiteralMinutes" runat="server"></asp:Literal>
                          </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Task</strong><br/><br/>" SortExpression="Task" >
                          <HeaderStyle Height="40px" Width="225px"></HeaderStyle>
                          <ItemStyle></ItemStyle>                    
                          <ItemTemplate>
                              <asp:Label ID="LabelTask" runat="server" Text='<%#Eval("task") %>'></asp:Label>
                              <asp:Label ID="LabelHoliday" runat="server" Text='<%#Eval("holiday") %>'></asp:Label>
                          </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Client</strong><br/><br/>" SortExpression="Client" >
                          <HeaderStyle Height="40px" Width="225px"></HeaderStyle>
                          <ItemStyle></ItemStyle>                    
                          <ItemTemplate>
                              <asp:Label ID="LabelClient" runat="server" Text='<%#Eval("client") %>'></asp:Label>
                          </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>File Name Reference</strong><br/><br/>" >
                          <HeaderStyle Height="40px" Width="250px"></HeaderStyle>
                          <ItemStyle></ItemStyle>                    
                          <ItemTemplate>
                              <asp:Label ID="LabelFileNameReference" runat="server" Text='<%#Eval("FileNameReference") %>'></asp:Label>
                          </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Note</strong><br/><br/>" SortExpression="Note" >
                          <HeaderStyle Height="40px" Width="250px"></HeaderStyle>
                          <ItemStyle></ItemStyle>                    
                          <ItemTemplate>
                              <asp:Label ID="LabelNote" runat="server" Text='<%#Eval("note") %>'></asp:Label>
                          </ItemTemplate>
                      </asp:TemplateField>
                  </Columns>
                  <RowStyle BackColor="#E3EAEB" />
                  <EditRowStyle BackColor="#C6D8DA" />
                  <SelectedRowStyle BackColor="#C6D8DA" Font-Bold="True" ForeColor="#333333" />
                  <PagerStyle BackColor="#666666" ForeColor="White" HorizontalAlign="Center" />
                  <HeaderStyle BackColor="#9FC6CB" Font-Bold="True" />
                  <AlternatingRowStyle BackColor="White" />
              </asp:GridView>  
              <br /><br />
              <div style="margin-left: 50px">
                  <div style="color:red; font-weight:bold"><asp:label ID="LabelEnterBreakInfo" runat="server" Text="You worked more than 3 hours please enter when you took a break<br/><br/>" visible="false" ></asp:label></div>
                  <div style="color:red; font-weight:bold"><asp:label ID="LabelError" runat="server" Text="No Schedule information available<br/><br/>" visible="false" ></asp:label></div>
                  <strong style='font-weight:bold'>Hours Scheduled: <asp:label ID="labelScheduleForDay" runat="server" Text="0 Hours 0 Minutes " ></asp:label></strong><br />         
                  <strong style='font-weight:bold'>Hours Entered: <asp:label ID="labelHoursEntered" runat="server" Text="0 Hours 0 Minutes " ></asp:label></strong>          
              </div>
            <br />
            <table style="border: 1px solid black; padding: 20px">
                <thead style="border: 1px solid black; padding: 20px">
                    <th style="border: 1px solid black; padding: 20px">
                        Length of Shift
                    </th>
                    <th style="border: 1px solid black; padding: 20px">
                        SBSC & MBA Required Rest & Meal Breaks (REQUIRED, not suggested)
                    </th>
                </thead>
                <tr style="border: 1px solid black; padding: 20px">
                    <td style="border: 1px solid black; padding: 20px">
                        3:00 or Less
                    </td>
                    <td style="border: 1px solid black; padding: 20px">
                        No break
                    </td>
                </tr>
                <tr style="border: 1px solid black; padding: 20px">
                    <td style="border: 1px solid black; padding: 20px">
                        3:01 - 5:00
                    </td>
                    <td style="border: 1px solid black; padding: 20px">
                        15 minute paid rest
                    </td>
                </tr>
                <tr style="border: 1px solid black; padding: 20px">
                    <td style="border: 1px solid black; padding: 20px">
                        5:01 – 6:59
                    </td>
                    <td style="border: 1px solid black; padding: 20px">
                        30 minute unpaid meal* + 15 minute paid rest
                    </td>
                </tr>
                <tr style="border: 1px solid black; padding: 20px">
                    <td style="border: 1px solid black; padding: 20px">
                        7:00 - 9:59
                    </td>
                    <td style="border: 1px solid black; padding: 20px">
                        30 or 60 minute unpaid meal* + (2) 15 minute paid rest***
                    </td>
                </tr>
                <tr style="border: 1px solid black; padding: 20px">
                    <td style="border: 1px solid black; padding: 20px">
                        10:00 - 12:00
                    </td>
                    <td style="border: 1px solid black; padding: 20px">
                        (2) 30 or 60 minute unpaid meal** + (3) 15 minute paid rest***
                    </td>
                </tr>
            </table>
            <br />
            <p>
                <span style="font-weight: bold">Footnotes:</span><br /><br />
                * Meal break must be STARTED before the 5th hour of work is COMPLETED.<br /><br />
                ** First meal break must be STARTED before the 5th hour of work is COMPLETED and second<br />
                meal break must be STARTED before the 10th hour of work is COMPLETED.<br /><br />
                *** If you are allowed to take more than one 15 minute paid rest break, you cannot combine your<br />
                paid rest breaks into one 30 minute or one 45 minute paid rest break.<br /><br />
                
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                ***If you get (2) 15 minute paid rests, one 15 minute break should be taken<br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                before your unpaid meal and the other 15 minute break after your unpaid meal.<br /><br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                ***If you get (3) 15 minute paid rests, one 15 minute break should be taken<br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                before your first unpaid meal, one 15 minute break after your first unpaid meal<br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                and the one 15 minute break after your second unpaid meal.<br /><br />
                
                Please DO NOT take more than 60 minutes for the unpaid meal break. If you need to take more than 60<br />
                minutes in a day, please e-mail a request to manager.<br />
                Please DO NOT take your 15 minute paid rest breaks within the first or last 30 minutes of your shift or your<br />
                unpaid meal.<br />
                <span style="font-weight: bold">Reminders: </span>You are not allowed to work over 8 hours in a day or 40 hours in a week without prior approval<br />
                from manager.<br /><br />

                <span style="font-weight: bold; text-decoration: underline">Here are a few examples:</span><br /><br />
                1. If you schedule yourself for 7:00 AM - 3:30 PM, the length of your shift is 8 hours and 30 minutes. Based on<br />
                the new break schedule, you are required to take 2 - 15 minute paid rests and a 30 or 60 minute unpaid meal<br />
                break. Let’s say that you take a 30 minute unpaid meal break. At the end of the day, you should have recorded<br />
                2 - 15 minute paid breaks, 30 minutes of unpaid lunch and a total of 7 hours and 30 minutes of work tasks.<br /><br />

                2. If you schedule yourself for 10:30 AM - 4:30 PM, the length of your shift is 6 hours. Based on the new<br />
                break schedule, you are required to take a 15 minute paid rest and a 30 minute unpaid meal break. At the end of<br />
                the day, you should have recorded a 15 minute paid break, 30 minutes of unpaid lunch, and 5 hours and 15<br /><br />
                minutes of work tasks.

                3. If you schedule yourself for 7:00 AM - 12:00PM, the length of your shift is 5 hours. Based on the new break<br />
                schedule, you are required to take a 15 minute paid rest. At the end of the day, you should have recorded a 15<br />
                minute paid breaks and a total of 4 hours and 45 minutes of work tasks.<br />
            </p>
        </div>
    </form>
