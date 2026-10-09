<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryHolidayAdmin.aspx.cs" Inherits="Spedmon.TimeEntryHolidayAdmin" %>
<script type = "text/javascript">
    function Confirm()
    {
        var confirm_update = document.createElement("INPUT");
            confirm_update.type = "hidden";
            confirm_update.name = "confirm_update";
            if (confirm("Do you want to save your changes?"))
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
</script>
<form id="form1" runat="server">
    <asp:HiddenField ID="HiddenFieldDateTimeEntry" runat="server" />

    <div style="margin-left: 50px">
        <h1>Time Keeper Holiday Admin</h1><br />
        <asp:panel runat="server" ID="PanelCreateEntry" Visible="false">
              <strong style="font-weight:bold">Date Of Holiday</strong>&nbsp;&nbsp;&nbsp;
              <strong style="font-weight:bold; color: red">*</strong>&nbsp;&nbsp;&nbsp;
              <asp:Label runat="server" id="tbSelectedDate" Text="Label"></asp:Label>
              &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="lnkpickdate" runat="server" OnClick="lnkpickdate_Click" OnClientClick="Encode()"
                  ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px"></asp:ImageButton>
              <asp:Calendar ID="datepicker" runat="server" Visible="false" OnSelectionChanged="datepicker_SelectionChanged"
                   TodayDayStyle-BackColor="Red" TodayDayStyle-ForeColor="White"></asp:Calendar>
              <br /><br />
              <strong style="font-weight:bold">Name of Holiday</strong>&nbsp;&nbsp;&nbsp;
              <strong style="font-weight:bold; color: red">*</strong>&nbsp;&nbsp;&nbsp;
              <asp:TextBox runat="server" ID="TextBoxNameOfHoliday" Width="462px"></asp:TextBox><br /><br />
              <asp:RequiredFieldValidator 
                  runat="server" 
                  ID="RequiredNameOfHoliday" 
                  ErrorMessage="Holiday Name is required<br/>"
                  Display="Dynamic"
                    Font-Bold="True" ForeColor="Red" ValidationGroup="CreateException"
                    ControlToValidate="TextBoxNameOfHoliday"></asp:RequiredFieldValidator>
                <strong style="font-weight:bold">Description</strong><br />
                <asp:TextBox runat="server" ID="TextBoxDescrption" Width="1004px" Height="151px" TextMode="MultiLine"></asp:TextBox><br /><br />
                <asp:Button runat="server" Text="Save" ID="ButtonSaveHoliday"
                    ValidationGroup="CreateException"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                    Width="200" Height="30" Font-Bold="True"
                    OnClientClick="Confirm()" OnClick="ButtonSaveHoliday_Click"></asp:Button>&nbsp;&nbsp;&nbsp;
                <asp:Button runat="server" Text="Cancel" ID="ButtonCancel"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonCancel_Click"
                    ></asp:Button>
        </asp:panel>
        <asp:panel runat="server" ID="PanelViewModifyDeleteCurrent" Visible="true">
              <asp:Button runat="server" Text="Add Holiday" ID="ButtonCreateNew"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonCreateNew_Click"></asp:Button><br /><br />
              <asp:Repeater runat="server" ID="repeaterHolidays">
                    <HeaderTemplate>
                        <table>
                            <thead style="background-color: #9FC6CB">
                                <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                </th>
                                <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                    <strong style="font-weight: bold">
                                        Date Of Holiday                         
                                    </strong>
                                </th>
                                <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px;">
                                    <strong style="font-weight: bold">
                                        Name
                                    </strong>
                                </th>
                                <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px">
                                    <strong style="font-weight: bold">
                                        Description
                                    </strong>
                                </th>
                            </thead>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tbody>
                            <tr class="<%# Container.ItemIndex % 2 == 0 ? "alternate" : "" %>">
                                <td style="vertical-align: top; white-space: nowrap">
                                   <asp:Button runat="server" Text="Delete" ID="ButtonDelete"
                                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                                        Width="75" Height="30" Font-Bold="True" OnClick="ButtonDelete_Click"
                                        OnClientClick="Confirm()"
                                        ></asp:Button>
                                </td>
                                <td style="vertical-align: top; white-space: nowrap">
                                    <asp:Label runat="server" id="LabelDateOfHolidayObserved" Text='<%#Eval("DateOfHolidayObserved", "{0: MM/dd/yyyy}") %>'></asp:Label>
                                    &nbsp;&nbsp;&nbsp;
                                    <asp:HiddenField runat="server" id="HiddenFieldDateOfHoliday" Value='<%#Eval("DateOfHolidayObserved", "{0: MM/dd/yyyy}") %>'></asp:HiddenField>
                                    <asp:HiddenField runat="server" id="HiddenFieldId" Value='<%#Eval("ID") %>'></asp:HiddenField>
                                    <asp:ImageButton ID="ImageButtonRepeater" runat="server" OnClick="lnkPickDateRepeater_Click"
                                        ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px"></asp:ImageButton>
                                    &nbsp;&nbsp;&nbsp;
                                    <asp:Calendar ID="CalendarRepeaterPicker" runat="server" Visible="false"
                                            TodayDayStyle-BackColor="Red" TodayDayStyle-ForeColor="White" 
                                        OnSelectionChanged="CalendarRepeaterPicker_SelectionChanged"></asp:Calendar>                                
                                </td>
                                <td style="vertical-align: top; white-space: nowrap">
                                    <asp:TextBox runat="server" ID="TextBoxRepeaterHolidayName" Width="462px" Text='<%#Eval("Name") %>'></asp:TextBox>
                                    <asp:HiddenField runat="server" id="HiddenFieldHolidayName" Value='<%#Eval("Name") %>'></asp:HiddenField>
                                    <br />
                                    <asp:RequiredFieldValidator 
                                          runat="server" 
                                          ID="RequiredFieldValidatorTextBoxHolidayName" 
                                          ErrorMessage="Holiday Name is required<br/>"
                                          Display="Dynamic"
                                            Font-Bold="True" ForeColor="Red" ValidationGroup="CreateExceptionPicker"
                                            ControlToValidate="TextBoxRepeaterHolidayName"></asp:RequiredFieldValidator>
                                </td>
                                <td style="vertical-align: top; white-space: nowrap">
                                    <asp:TextBox runat="server" ID="TextBoxDescription" 
                                        Width="750px" Height="50px" TextMode="MultiLine" 
                                        Text='<%#Eval("Description") %>'></asp:TextBox>
                                    <asp:HiddenField runat="server" id="HiddenFieldDescription" Value='<%#Eval("Description") %>'></asp:HiddenField>
                                </td>
                            </tr>
                        </tbody>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
              </asp:Repeater>
              <br /><br />
            <asp:Button runat="server" Text="Save" ID="ButtonUpdateGridInfo"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                    Width="200" Height="30" Font-Bold="True"
                    ValidationGroup="CreateExceptionPicker"
                    OnClientClick="Confirm()" OnClick="ButtonUpdateGridInfo_Click"></asp:Button>
        </asp:panel>
    </div>
</form>
