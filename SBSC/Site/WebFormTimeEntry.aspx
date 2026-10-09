<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebFormTimeEntry.aspx.cs" Inherits="Spedmon.WebFormTimeEntry" %>

     <script type="text/javascript" language="javascript">
         function PopupPicker(url) {
             var PopupWindow = null;
             PopupWindow = window.open(url + 'Ctl=tbSelectedDate', 'PopupWindow', 'width=10,height=250,resizable=yes');
             PopupWindow.focus();
             return false;
         };
     </script>
      <script type="text/javascript">
          function callAlert(msg) {
              alert(msg);
          }
      </script>
      <script type="text/javascript" src="http://ajax.microsoft.com/ajax/jquery/jquery-1.4.2.js">
          $(#ButtonUpdate).click(function () {
              if ($('#ButtonUpdate').is('ui-button-text')) {
                  $('#ButtonUpdate').removeClass('ui-button-text');
                  $('#ButtonUpdate').addClass('ui-spedmon-box-inline-ctrl');
                  $('#ButtonUpdate').addClass('ui-button ui-widget');
                  $('#ButtonUpdate').addClass('ui-state-default');
                  $('#ButtonUpdate').addClass('ui-corner-all');
                  $('#ButtonUpdate').addClass('ui-button-text-only');
              }
              else {
                  $('#ButtonUpdate').addClass('ui-button-text');
                  $('#ButtonUpdate').removeClass('ui-spedmon-box-inline-ctrl');
                  $('#ButtonUpdate').removeClass('ui-button ui-widget');
                  $('#ButtonUpdate').removeClass('ui-state-default');
                  $('#ButtonUpdate').removeClass('ui-corner-all');
                  $('#ButtonUpdate').removeClass('ui-button-text-only');
              }
          });
    </script>  
    <style>
        tr.alternate {
            background-color: #E3EAEB;
        }
    </style>
    <form id="form1" runat="server">
        <asp:literal runat="server" ID="LiteralMenu"></asp:literal>
        <br />
        <asp:HiddenField ID="HiddenFieldDisplayStartTime" runat="server" Value="false" />
        <asp:HiddenField ID="HiddenFieldDisplayStopTime" runat="server" Value="false" />

        <asp:HiddenField ID="HiddenFieldEmployeeId" runat="server" />
        <asp:HiddenField ID="HiddenFieldHoursScheduled" runat="server" />
        <asp:HiddenField ID="HiddenFieldMinutesScheduled" runat="server" />
        <asp:HiddenField ID="HiddenFieldHoursRecorded" runat="server" />
        <asp:HiddenField ID="HiddenFieldMinutesRecorded" runat="server" />
        <!-- Hide these controls for now, next release remove and refractor the code -->
        <table  style="margin-left: 50px">
            <tr>
                <td>
                    <asp:panel runat="server" ID="PanelRegularEmploeyee" Visible="true">
                        <h1><asp:literal runat="server" id="literalEmployee" text=""></asp:literal></h1>
                    </asp:panel>
                    <asp:panel runat="server" ID="PanelAdmin" Visible="false">
                        <asp:Label runat="server" ID="LabelAdminEmployee" Font-Bold="True" Text="<h1>Read Only</h1>" Visible="False" ForeColor="Red"></asp:Label>
                        <asp:Label runat="server" Text="Select Employee " ID="Label1" Font-Bold="True"></asp:Label>
                        &nbsp;&nbsp;&nbsp;&nbsp;
                        <asp:DropDownList runat="server" ID="DropDownListEmployees" AutoPostBack="True" OnSelectedIndexChanged="DropDownListEmployees_SelectedIndexChanged"></asp:DropDownList>
                    </asp:panel>
                    <br /><br />
                    <asp:panel runat="server" ID="PanelVerifyHours" Visible="false">
                        <asp:HiddenField runat="server" ID="HiddenFieldVerifyId"></asp:HiddenField>
                        <asp:HiddenField runat="server" ID="HiddenFieldLastDayOfSchedule"></asp:HiddenField>
                        <asp:HiddenField runat="server" ID="HiddenFieldComments"></asp:HiddenField>
                        <h1>
                            <asp:Label runat="server" ID="LabelVerifyHours" Font-Bold="True" Text="You Need to Verify Hours"></asp:Label>
                        </h1>
                        <asp:CheckBox ID="CheckBoxVerifyHours" runat="server" AutoPostBack="True" OnCheckedChanged="CheckBoxVerifyHours_CheckedChanged"></asp:CheckBox>
                        &nbsp;&nbsp;<asp:Label runat="server" ID="LabelVerifyPrompt" Font-Bold="True"></asp:Label>
                        <br /><br />
                    </asp:panel>
                    <asp:label runat="server" ID="labelWeeklyHourCount" Font-Bold="True" Font-Size="Large" ForeColor="Blue"></asp:label>
                </td>
            </tr>
        </table>
        <asp:HiddenField ID="HiddenFieldSelectedDate" runat="server" />
        <br />
        <div style="margin-left: 50px">
            <asp:Button ID="ButtonPreviousWeek" runat="server" Text="< Previous" Width="125" Height="50" OnClick="ButtonPreviousWeek_Click" Font-Bold="True" 
            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"/>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonNextWeek" runat="server" Text="Next >" Width="125" Height="50" OnClick="ButtonNextWeek_Click" Font-Bold="True"
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"/>
            <br /><br /><br />
            <asp:Repeater runat="server" ID="repeaterTaskTemplateControl">
               <HeaderTemplate>
                    <table>
                        <thead style="background-color: #9FC6CB">
                            <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <strong style="font-weight: bold">Task or Holiday</strong>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px;">
                                <asp:Literal ID="LiteralSunday" runat="server" Text="<p style='font-size: : medium; font-weight: bold' >SUNDAY<br />Scheduled : 8<br/>Recorded : 8<br/><a href=''>1/1/2018</a></p>"></asp:Literal>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <asp:Literal ID="LiteralMonday" runat="server" Text="<p style='font-size: : medium; font-weight: bold'>MONDAY<br />Scheduled : 8<br/>Recorded : 8<br/><a href=''>1/2/2018</a></p>"></asp:Literal>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <asp:Literal ID="LiteralTuesday" runat="server" Text="<p style='font-size: : medium; font-weight: bold'>TUESDAY<br />Scheduled : 8<br/>Recorded : 8<br/><a href=''>1/3/2018</a></p>"></asp:Literal>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <asp:Literal ID="LiteralWednesday" runat="server" Text="<p style='font-size: : medium; font-weight: bold'>WEDNESDAY<br />Scheduled : 8<br/>Recorded : 8<br/><a href=''>1/4/2018</a></p>"></asp:Literal>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <asp:Literal ID="LiteralThursday" runat="server" Text="<p style='font-size: : medium; font-weight: bold'>THURSDAY<br />Scheduled : 8<br/>Recorded : 8<br/><a href=''>1/5/2018</a></p>"></asp:Literal>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <asp:Literal ID="LiteralFriday" runat="server" Text="<p style='font-size: : medium; font-weight: bold'>FRIDAY<br />Scheduled : 8<br/>Recorded : 8<br/><a href=''>1/5/2018</a></p>"></asp:Literal>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <asp:Literal ID="LiteralSaturday" runat="server" Text="<p style='font-size: : medium; font-weight: bold'>SATURDAY<br />Scheduled : 8<br/>Recorded : 8<br/><a href=''>1/5/2018</a></p>"></asp:Literal>
                            </th>
                        </thead>
                </HeaderTemplate>
                <ItemTemplate>
                    <tbody>
                        <tr class="<%# Container.ItemIndex % 2 == 0 ? "alternate" : "" %>">
                            <td style="vertical-align: top; white-space: nowrap">
                                <asp:Label runat="server" ID="labelTaskName" Text='<%#Eval("TaskName") %>'></asp:Label>
                                <asp:Label runat="server" ID="labelHolidayName" Text='<%#Eval("HolidayName") %>'></asp:Label>
                                <asp:HiddenField runat="server" ID="HiddenFieldTaskId" Value='<%#Eval("timeEntrytaskID") %>'></asp:HiddenField>
                                <asp:HiddenField runat="server" ID="HiddenFieldHolidayId" Value='<%#Eval("holidayTaskID") %>'></asp:HiddenField>
                                <asp:HiddenField runat="server" ID="HiddenFieldCanHaveMultipleClients" Value='<%#Eval("CanHaveMultipleClients") %>'></asp:HiddenField>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="labelSundayDisabledMessage" Text="This field is read only<br/>You must click the day<br/>link to modify<br/>" ForeColor="Blue" Font-Bold="true" Visible="false"></asp:Label>
                                            Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <asp:TextBox runat="server" ID="textBoxHoursSunday" 
                                                Text='<%#Eval("numberHoursSunday") %>' 
                                                MaxLength="2" Width="50"></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorSunday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 23" 
                                                ControlToValidate="textBoxHoursSunday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] $|^[0-9]$|^1[0-9]$|^2[0-3]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryIDSunday" Value='<%#Eval("timeEntryIDSunday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldDateForTimeEntrySunday" Value='<%#Eval("dateForTimeEntrySunday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryDayIDSunday" Value='<%#Eval("timeEntryDayIDSunday") %>'></asp:HiddenField>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Minutes&nbsp;&nbsp;
                                            <asp:TextBox runat="server" ID="textBoxMinutesSunday" 
                                                Text='<%#Eval("numberMinutesSunday") %>'
                                                MaxLength="2" Width="50"></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMinutesSunday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 59" 
                                                ControlToValidate="textBoxMinutesSunday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] |^[0-9]$|^1[0-9]$|^2[0-9]$|^3[0-9]$|^4[0-9]$|^5[0-9]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top">
                                            Clients<br/>
                                            <asp:ListBox runat="server" id="listBoxClientsSunday" width="225" height="65">
                                            </asp:ListBox>
                                            <asp:DropDownList runat="server" id="DropDownListClientsSunday" width="225"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="labelMondayDisabledMessage" Text="This field is read only<br/>You must click the day<br/>link to modify<br/>" ForeColor="Blue" Font-Bold="true" Visible="false"></asp:Label>
                                            Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursMonday" Text='<%#Eval("numberHoursMonday") %>'  MaxLength="2" Width="50" ></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMonday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 23" 
                                                ControlToValidate="textBoxHoursMonday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] $|^[0-9]$|^1[0-9]$|^2[0-3]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryIDMonday" Value='<%#Eval("timeEntryIDMonday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldDateForTimeEntryMonday" Value='<%#Eval("dateForTimeEntryMonday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryDayIDMonday" Value='<%#Eval("timeEntryDayIDMonday") %>'></asp:HiddenField>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesMonday" Text='<%#Eval("numberMinutesMonday") %>'  MaxLength="2" Width="50" ></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMinutesMonday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 59" 
                                                ControlToValidate="textBoxMinutesMonday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] |^[0-9]$|^1[0-9]$|^2[0-9]$|^3[0-9]$|^4[0-9]$|^5[0-9]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top">
                                            Clients<br/>
                                            <asp:ListBox runat="server" id="listBoxClientsMonday" width="225" height="65">
                                            </asp:ListBox>
                                            <asp:DropDownList runat="server" id="DropDownListClientsMonday" width="225"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="labelTuesdayDisabledMessage" Text="This field is read only<br/>You must click the day<br/>link to modify<br/>" ForeColor="Blue" Font-Bold="true" Visible="false"></asp:Label>
                                            Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursTuesday" Text='<%#Eval("numberHoursTuesday") %>'  MaxLength="2" Width="50" ></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorTuesday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 23" 
                                                ControlToValidate="textBoxHoursTuesday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] $|^[0-9]$|^1[0-9]$|^2[0-3]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryIDTuesday" Value='<%#Eval("timeEntryIDTuesday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldDateForTimeEntryTuesday" Value='<%#Eval("dateForTimeEntryTuesday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryDayIDTuesday" Value='<%#Eval("timeEntryDayIDTuesday") %>'></asp:HiddenField>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesTuesday" Text='<%#Eval("numberMinutesTuesday") %>'  MaxLength="2" Width="50" ></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMinutesTuesday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 59" 
                                                ControlToValidate="textBoxMinutesTuesday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] |^[0-9]$|^1[0-9]$|^2[0-9]$|^3[0-9]$|^4[0-9]$|^5[0-9]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top">
                                            Clients<br/>
                                            <asp:ListBox runat="server" id="listBoxClientsTuesday" width="225" height="65">
                                            </asp:ListBox>
                                            <asp:DropDownList runat="server" id="DropDownListClientsTuesday" width="225"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="labelWednesdayDisabledMessage" Text="This field is read only<br/>You must click the day<br/>link to modify<br/>" ForeColor="Blue" Font-Bold="true" Visible="false"></asp:Label>
                                            Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursWednesday" Text='<%#Eval("numberHoursWednesday") %>' MaxLength="2" Width="50" ></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorWednesday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 23" 
                                                ControlToValidate="textBoxHoursWednesday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] $|^[0-9]$|^1[0-9]$|^2[0-3]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryIDWednesday" Value='<%#Eval("timeEntryIDWednesday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldDateForTimeEntryWednesday" Value='<%#Eval("dateForTimeEntryWednesday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryDayIDWednesday" Value='<%#Eval("timeEntryDayIDWednesday") %>'></asp:HiddenField>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesWednesday" Text='<%#Eval("numberMinutesWednesday") %>'  MaxLength="2" Width="50" ></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMinutesWednesday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 59" 
                                                ControlToValidate="textBoxMinutesWednesday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] |^[0-9]$|^1[0-9]$|^2[0-9]$|^3[0-9]$|^4[0-9]$|^5[0-9]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top">
                                            Clients<br/>
                                            <asp:ListBox runat="server" id="listBoxClientsWednesday" width="225" height="65">
                                            </asp:ListBox>
                                            <asp:DropDownList runat="server" id="DropDownListClientsWednesday" width="225"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="labelThursdayDisabledMessage" Text="This field is read only<br/>You must click the day<br/>link to modify<br/>" ForeColor="Blue" Font-Bold="true" Visible="false"></asp:Label>
                                            Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursThursday" Text='<%#Eval("numberHoursThursday") %>' MaxLength="2" Width="50" ></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorThursday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 23" 
                                                ControlToValidate="textBoxHoursThursday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] $|^[0-9]$|^1[0-9]$|^2[0-3]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryIDThursday" Value='<%#Eval("timeEntryIDThursday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldDateForTimeEntryThursday" Value='<%#Eval("dateForTimeEntryThursday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryDayIDThursday" Value='<%#Eval("timeEntryDayIDThursday") %>'></asp:HiddenField>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesThursday" 
                                                Text='<%#Eval("numberMinutesThursday") %>' MaxLength="2" Width="50"></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMinuesThursday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 59" 
                                                ControlToValidate="textBoxMinutesThursday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] |^[0-9]$|^1[0-9]$|^2[0-9]$|^3[0-9]$|^4[0-9]$|^5[0-9]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top">
                                            Clients<br/>
                                            <asp:ListBox runat="server" id="listBoxClientsThursday" width="225" height="65">
                                            </asp:ListBox>
                                            <asp:DropDownList runat="server" id="DropDownListClientsThursday" width="225"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="labelFridayDisabledMessage" Text="This field is read only<br/>You must click the day<br/>link to modify<br/>" ForeColor="Blue" Font-Bold="true" Visible="false"></asp:Label>
                                            Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursFriday" 
                                                Text='<%#Eval("numberHoursFriday") %>' MaxLength="2" Width="50"></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorFriday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 23" 
                                                ControlToValidate="textBoxHoursFriday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] $|^[0-9]$|^1[0-9]$|^2[0-3]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryIDFriday" Value='<%#Eval("timeEntryIDFriday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldDateForTimeEntryFriday" Value='<%#Eval("dateForTimeEntryFriday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryDayIDFriday" Value='<%#Eval("timeEntryDayIDFriday") %>'></asp:HiddenField>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesFriday" 
                                                Text='<%#Eval("numberMinutesFriday") %>' MaxLength="2" Width="50"></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMinutesFriday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 59" 
                                                ControlToValidate="textBoxMinutesFriday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] |^[0-9]$|^1[0-9]$|^2[0-9]$|^3[0-9]$|^4[0-9]$|^5[0-9]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top">
                                            Clients<br/>
                                            <asp:ListBox runat="server" id="listBoxClientsFriday" width="225" height="65">
                                            </asp:ListBox>
                                            <asp:DropDownList runat="server" id="DropDownListClientsFriday" width="225"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="labelSaturdayDisabledMessage" Text="This field is read only<br/>You must click the day<br/>link to modify<br/>" ForeColor="Blue" Font-Bold="true" Visible="false"></asp:Label>
                                            Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursSaturday" 
                                                Text='<%#Eval("numberHoursSaturday") %>' MaxLength="2" Width="50"></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorSaturday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 23" 
                                                ControlToValidate="textBoxHoursSaturday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] $|^[0-9]$|^1[0-9]$|^2[0-3]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryIDSaturday" Value='<%#Eval("timeEntryIDSaturday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldDateForTimeEntrySaturday" Value='<%#Eval("dateForTimeEntrySaturday") %>'></asp:HiddenField>
                                            <asp:HiddenField runat="server" ID="HiddenFieldTimeEntryDayIDSaturday" Value='<%#Eval("timeEntryDayIDSaturday") %>'></asp:HiddenField>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesSaturday" 
                                                Text='<%#Eval("numberMinutesSaturday") %>' MaxLength="2" Width="50"></asp:TextBox>
                                            <asp:RegularExpressionValidator runat="server" 
                                                ID="regularExpressionValidatorMinutesSaturday"                                   
                                                ErrorMessage="<br/>Valid values are between 0 to 59" 
                                                ControlToValidate="textBoxMinutesSaturday" Font-Bold="True" ForeColor="#CC0000" 
                                                ValidationExpression="^ [0-9]|^[0-9] |^[0-9]$|^1[0-9]$|^2[0-9]$|^3[0-9]$|^4[0-9]$|^5[0-9]$|^$|^  $|^ $|^0$|^ 0$|^00$" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top">
                                            Clients<br/>
                                            <asp:ListBox runat="server" id="listBoxClientsSaturday" width="225" height="65">
                                            </asp:ListBox>
                                            <asp:DropDownList runat="server" id="DropDownListClientsSaturday" width="225"></asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
            <br /><br />
            <asp:Button ID="ButtonSaveTaskInfo" runat="server" Text="Save Tasks"
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                Width="175" Height="30" Font-Bold="True" OnClick="ButtonSaveTaskInfo_Click" /><br />
            <asp:hiddenfield runat="server" ID="SaveCompleted"></asp:hiddenfield>
            <asp:Label runat="server" ID="LabelProblem" Font-Bold="True" ForeColor="Red" 
                Text=""></asp:Label>
        </div>

    </form>
