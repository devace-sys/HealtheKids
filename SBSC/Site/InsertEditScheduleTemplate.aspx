<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InsertEditScheduleTemplate.aspx.cs" Inherits="Spedmon.InsertEditScheduleTemplate"
     MaintainScrollPositionOnPostback="true" %>
    <script type = "text/javascript">
        function ConfirmScheduleUpdate()
        {
            var confirm_update = document.createElement("INPUT");
                confirm_update.type = "hidden";
                confirm_update.name = "confirm_update";
                if (confirm("Do you want to update?"))
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
    <style>
        tr.alternate {
            background-color: #E3EAEB;
        }
        .modalDialog {
            position: fixed;
            font-family: Arial, Helvetica, sans-serif;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background: rgba(0,0,0,0.8);
            z-index: 99999;
            -webkit-transition: opacity 400ms ease-in;
            -moz-transition: opacity 400ms ease-in;
            transition: opacity 400ms ease-in;
        }
        .modalDialog > div {
            width: 450px;
            position: relative;
            margin: 10% auto;
            margin-left:20%;
            padding: 5px 20px 13px 20px;
            border-radius: 10px;
            background: #fff;
            background: -moz-linear-gradient(#fff, #999);
            background: -webkit-linear-gradient(#fff, #999);
            background: -o-linear-gradient(#fff, #999);
        }
        .close {
            background: #606061;
            color: #FFFFFF;
            line-height: 25px;
            position: absolute;
            right: -12px;
            text-align: center;
            top: -10px;
            width: 24px;
            text-decoration: none;
            font-weight: bold;
            -webkit-border-radius: 12px;
            -moz-border-radius: 12px;
            border-radius: 12px;
            -moz-box-shadow: 1px 1px 3px #000;
            -webkit-box-shadow: 1px 1px 3px #000;
            box-shadow: 1px 1px 3px #000;
        }
        .close:hover { background: #00d9ff; }
    </style>
     <form id="form1" runat="server">
        <div style="margin-left: 50px">
            <asp:HiddenField ID="HiddenFieldTemplateID" runat="server" />
            <asp:HiddenField ID="HiddenFieldTemplateName" runat="server" />
            <asp:HiddenField ID="HiddenFieldEmployeeID" runat="server" />
            <asp:HiddenField ID="HiddenFieldAutoPopulateTaskTemplateId" runat="server" />
            <asp:HiddenField ID="HiddenFieldAutoPopulateTaskTemplateName" runat="server" />
            <asp:HiddenField ID="HiddenFieldStopStartTaskId" runat="server" />
            <asp:HiddenField ID="HiddenFieldTaskStartStop" runat="server" />
            <asp:HiddenField ID="HiddenFieldTaskStartStopDay" runat="server" />
            <div>
                <strong style="font-weight:bold">Template Name</strong>&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox ID="TextBoxTemplateName" runat="server" MaxLength="50" Width="736px"></asp:TextBox><br /><br />
                <asp:RequiredFieldValidator ID="RequiredFieldValidatorTemplateName" 
                        runat="server" ErrorMessage="Template Name is Required<br/><br/>" 
                    Font-Bold="True" ForeColor="Red" ValidationGroup="CreateUpdateTemplate"
                    ControlToValidate="TextBoxTemplateName"></asp:RequiredFieldValidator>
                <br /><br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <asp:Button ID="ButtonAdd" runat="server" Text="Add Template" ValidationGroup="CreateUpdateTemplate"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonSave_Click"/>
                <asp:Button ID="ButtonUpdate" runat="server" Text="Update Template Name" ValidationGroup="CreateUpdateTemplate"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                    Width="200" Height="30" Font-Bold="True" Visible="false" OnClick="ButtonUpdate_Click"
                     OnClientClick="ConfirmScheduleUpdate()"/>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <asp:Button ID="ButtonBack" runat="server" Text="Back"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonBack_Click"/>
                <br /><br />
                <asp:Panel ID="PanelWeekDetails" runat="server" Visible="false">
                    <h1>Schedule</h1>
                    <table>
                        <tr style="background-color: #9FC6CB">
                            <th style="font-weight: bold; padding-left:70px; padding-right:70px; padding-top:10px; padding-bottom:10px">Sunday</th>
                            <th style="font-weight: bold; padding-left:70px; padding-right:70px; padding-top:10px; padding-bottom:10px">Monday</th>
                            <th style="font-weight: bold; padding-left:70px; padding-right:70px; padding-top:10px; padding-bottom:10px">Tuesday</th>
                            <th style="font-weight: bold; padding-left:70px; padding-right:70px; padding-top:10px; padding-bottom:10px">Wednesday</th>
                            <th style="font-weight: bold; padding-left:70px; padding-right:70px; padding-top:10px; padding-bottom:10px">Thursday</th>
                            <th style="font-weight: bold; padding-left:70px; padding-right:70px; padding-top:10px; padding-bottom:10px">Friday</th>
                            <th style="font-weight: bold; padding-left:70px; padding-right:70px; padding-top:10px; padding-bottom:10px">Saturday</th>
                        </tr>
                        <tr>
                            <td style="text-align:center">
                                <asp:HiddenField ID="HiddenFieldSundayID" runat="server" Value="0" />
                                <asp:Literal ID="LiteralSundayDetail" runat="server" Text="08:00 AM&nbsp;&nbsp;&nbsp;&nbsp;12:00 AM<br/>01:00 PM&nbsp;&nbsp;&nbsp;&nbsp;05:00 PM<br/>40 Hours&nbsp;&nbsp;&nbsp;&nbsp;59 Minutes"></asp:Literal>
                            </td>
                            <td style="text-align:center">
                                <asp:HiddenField ID="HiddenFieldMondayID" runat="server" Value="0" />
                                <asp:Literal ID="LiteralMondayDetail" runat="server" Text="08:00 AM&nbsp;&nbsp;&nbsp;&nbsp;12:00 AM<br/>01:00 PM&nbsp;&nbsp;&nbsp;&nbsp;05:00 PM<br/>40 Hours&nbsp;&nbsp;&nbsp;&nbsp;59 Minutes"></asp:Literal>
                            </td>
                            <td style="text-align:center">
                                <asp:HiddenField ID="HiddenFieldTuesdayID" runat="server" Value="0" />
                                <asp:Literal ID="LiteralTuesdayDetail" runat="server" Text="08:00 AM&nbsp;&nbsp;&nbsp;&nbsp;12:00 AM<br/>01:00 PM&nbsp;&nbsp;&nbsp;&nbsp;05:00 PM<br/>40 Hours&nbsp;&nbsp;&nbsp;&nbsp;59 Minutes"></asp:Literal>
                            </td>
                            <td style="text-align:center">
                                <asp:HiddenField ID="HiddenFieldWednesdayID" runat="server" Value="0" />
                                <asp:Literal ID="LiteralWednesdayDetail" runat="server" Text="08:00 AM&nbsp;&nbsp;&nbsp;&nbsp;12:00 AM<br/>01:00 PM&nbsp;&nbsp;&nbsp;&nbsp;05:00 PM<br/>40 Hours&nbsp;&nbsp;&nbsp;&nbsp;59 Minutes"></asp:Literal>
                            </td>
                            <td style="text-align:center">
                                <asp:HiddenField ID="HiddenFieldThursdayID" runat="server" Value="0" />
                                <asp:Literal ID="LiteralThursdayDetail" runat="server" Text="08:00 AM&nbsp;&nbsp;&nbsp;&nbsp;12:00 AM<br/>01:00 PM&nbsp;&nbsp;&nbsp;&nbsp;05:00 PM<br/>40 Hours&nbsp;&nbsp;&nbsp;&nbsp;59 Minutes"></asp:Literal>
                            </td>
                            <td style="text-align:center">
                                <asp:HiddenField ID="HiddenFieldFridayID" runat="server" Value="0" />
                                <asp:Literal ID="LiteralFridayDetail" runat="server" Text="08:00 AM&nbsp;&nbsp;&nbsp;&nbsp;12:00 AM<br/>01:00 PM&nbsp;&nbsp;&nbsp;&nbsp;05:00 PM<br/>40 Hours&nbsp;&nbsp;&nbsp;&nbsp;59 Minutes"></asp:Literal>
                            </td>
                            <td style="text-align:center">
                                <asp:HiddenField ID="HiddenFieldSaturdayID" runat="server" Value="0" />
                                <asp:Literal ID="LiteralSaturdayDetail" runat="server" Text="08:00 AM&nbsp;&nbsp;&nbsp;&nbsp;12:00 AM<br/>01:00 PM&nbsp;&nbsp;&nbsp;&nbsp;05:00 PM<br/>40 Hours&nbsp;&nbsp;&nbsp;&nbsp;59 Minutes"></asp:Literal>
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align:center">
                                <asp:Button ID="ButtonSunday" runat="server" Text="Modify Sunday"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonSunday_Click"/>
                                <br />
                                <br />
                                <table>
                                    <tr>
                                        <td style="text-align: left">
                                            <strong style="font-weight: bold">Copy  Time To</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            <asp:CheckBox runat="server" ID="CheckBoxSundayToMonday" Text="Monday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSundayToTuesday" Text="Tuesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSundayToWednesday" Text="Wednesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSundayToThursday" Text="Thursday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSundayToFriday" Text="Friday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSundayToSaturday" Text="Saturday"></asp:CheckBox><br />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="ButtonCopyFromSunday" runat="server" Text="Copy"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonCopyFromSunday_Click" />
                                <br />
                                <br />
                                <asp:Button ID="ButtonDeleteSunday" runat="server" Text="Delete"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonDeleteSunday_Click" OnClientClick="ConfirmScheduleUpdate()"/>
                            </td>
                            <td style="text-align:center">
                                <asp:Button ID="ButtonMonday" runat="server" Text="Modify Monday"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonMonday_Click"/>
                                <br />
                                <br />
                                <table>
                                    <tr>
                                        <td style="text-align: left">
                                            <strong style="font-weight: bold">Copy  Time To</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            <asp:CheckBox runat="server" ID="CheckBoxMondayToSunday" Text="Sunday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxMondayToTuesday" Text="Tuesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxMondayToWednesday" Text="Wednesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxMondayToThursday" Text="Thursday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxMondayToFriday" Text="Friday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxMondayToSaturday" Text="Saturday"></asp:CheckBox><br />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="ButtonCopyFromMonday" runat="server" Text="Copy"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonCopyFromMonday_Click"/>
                                <br />
                                <br />
                                <asp:Button ID="ButtonDeleteMonday" runat="server" Text="Delete"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClientClick="ConfirmScheduleUpdate()" OnClick="ButtonDeleteMonday_Click"/>
                            </td>
                            <td style="text-align:center">
                                <asp:Button ID="ButtonTuesday" runat="server" Text="Modify Tuesday"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonTuesday_Click"/>
                                <br />
                                <br />
                                <table>
                                    <tr>
                                        <td style="text-align: left">
                                            <strong style="font-weight: bold">Copy  Time To</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            <asp:CheckBox runat="server" ID="CheckBoxTuesdayToSunday" Text="Sunday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxTuesdayToMonday" Text="Monday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxTuesdayToWednesday" Text="Wednesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxTuesdayToThursday" Text="Thursday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxTuesdayToFriday" Text="Friday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxTuesdayToSaturday" Text="Saturday"></asp:CheckBox><br />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="ButtonCopyFromTuesday" runat="server" Text="Copy"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonCopyFromTuesday_Click"/>
                                <br />
                                <br />
                                <asp:Button ID="ButtonDeleteTuesday" runat="server" Text="Delete"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClientClick="ConfirmScheduleUpdate()" OnClick="ButtonDeleteTuesday_Click"/>
                            </td>
                            <td style="text-align:center">
                                <asp:Button ID="ButtonWednesday" runat="server" Text="Modify Wednesday"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonWednesday_Click"/>
                                <br />
                                <br />
                                <table>
                                    <tr>
                                        <td style="text-align: left">
                                            <strong style="font-weight: bold">Copy  Time To</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            <asp:CheckBox runat="server" ID="CheckBoxWednesdayToSunday" Text="Sunday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxWednesdayToMonday" Text="Monday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxWednesdayToTuesday" Text="Tuesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxWednesdayToThursday" Text="Thursday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxWednesdayToFriday" Text="Friday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxWednesdayToSaturday" Text="Saturday"></asp:CheckBox><br />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="ButtonCopyFromWednesday" runat="server" Text="Copy"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonCopyFromWednesday_Click"/>
                                <br />
                                <br />
                                <asp:Button ID="ButtonDeleteWednesday" runat="server" Text="Delete"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClientClick="ConfirmScheduleUpdate()" OnClick="ButtonDeleteWednesday_Click"/>
                            </td>
                            <td style="text-align:center">
                                <asp:Button ID="ButtonThursday" runat="server" Text="Modify Thursday"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonThursday_Click"/>
                                <br />
                                <br />
                                <table>
                                    <tr>
                                        <td style="text-align: left">
                                            <strong style="font-weight: bold">Copy  Time To</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            <asp:CheckBox runat="server" ID="CheckBoxThursdayToSunday" Text="Sunday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxThursdayToMonday" Text="Monday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxThursdayToTuesday" Text="Tuesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxThursdayToWednesday" Text="Wednesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxThursdayToFriday" Text="Friday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxThursdayToSaturday" Text="Saturday"></asp:CheckBox><br />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="ButtonCopyFromThursday" runat="server" Text="Copy"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonCopyFromThursday_Click"/>
                                <br />
                                <br />
                                <asp:Button ID="ButtonDeleteThursday" runat="server" Text="Delete"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClientClick="ConfirmScheduleUpdate()" OnClick="ButtonDeleteThursday_Click"/>
                            </td>
                            <td style="text-align:center">
                                <asp:Button ID="ButtonFriday" runat="server" Text="Modify Friday"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                                                    
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonFriday_Click"/>
                                <br />
                                <br />
                                <table>
                                    <tr>
                                        <td style="text-align: left">
                                            <strong style="font-weight: bold">Copy  Time To</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            <asp:CheckBox runat="server" ID="CheckBoxFridayToSunday" Text="Sunday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxFridayToMonday" Text="Monday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxFridayToTuesday" Text="Tuesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxFridayToWednesday" Text="Wednesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxFridayToThursday" Text="Thursday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxFridayToSaturday" Text="Saturday"></asp:CheckBox><br />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="ButtonCopyFromFriday" runat="server" Text="Copy"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonCopyFromFriday_Click"/>
                                <br />
                                <br />
                                <asp:Button ID="ButtonDeleteFriday" runat="server" Text="Delete"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClientClick="ConfirmScheduleUpdate()" OnClick="ButtonDeleteFriday_Click"/>
                            </td>
                            <td style="text-align:center">
                                <asp:Button ID="ButtonSaturday" runat="server" Text="Modify Saturday"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                                                    
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonSaturday_Click"/>
                                <br />
                                <br />
                                <table>
                                    <tr>
                                        <td style="text-align: left">
                                            <strong style="font-weight: bold">Copy  Time To</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: left">
                                            <asp:CheckBox runat="server" ID="CheckBoxSaturdayToSunday" Text="Sunday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSaturdayToMonday" Text="Monday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSaturdayToTuesday" Text="Tuesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSaturdayToWednesday" Text="Wednesday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSaturdayToThursday" Text="Thursday"></asp:CheckBox><br />
                                            <asp:CheckBox runat="server" ID="CheckBoxSaturdayToFriday" Text="Friday"></asp:CheckBox><br />
                                        </td>
                                    </tr>
                                </table>
                                <br />
                                <asp:Button ID="ButtonCopyFromSaturday" runat="server" Text="Copy"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClick="ButtonCopyFromSaturday_Click"/>
                                <br />
                                <br />
                                <asp:Button ID="ButtonDeleteSaturday" runat="server" Text="Delete"
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    Width="175" Height="30" Font-Bold="True" OnClientClick="ConfirmScheduleUpdate()" OnClick="ButtonDeleteSaturday_Click"/>
                            </td>
                        </tr>
                    </table>
                    <h1>Tasks</h1>
                    <asp:Label runat="server" ID="LabelWarningMessage" Font-Bold="True" ForeColor="Red" 
                        Text="<h1>Please select task favorites</h1>" Visible="false"></asp:Label>
                    <asp:Repeater runat="server" ID="repeaterTaskTemplateControl">
                       <HeaderTemplate>
                            <table>
                                <thead style="background-color: #9FC6CB">
                                    <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                        <strong style="font-weight: bold">Task</strong>
                                    </th>
                                    <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                        <strong style="font-weight: bold">Client(s)</strong>
                                    </th>
                                    <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Sunday</th>
                                    <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Monday</th>
                                    <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Tuesday</th>
                                    <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Wednesday</th>
                                    <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Thursday</th>
                                    <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Friday</th>
                                    <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Saturday</th>
                                </thead>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tbody>
                                <tr class="<%# Container.ItemIndex % 2 == 0 ? "alternate" : "" %>">
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:Label runat="server" ID="labelTaskName" Text='<%#Eval("name") %>'></asp:Label>
                                        <asp:HiddenField runat="server" ID="HiddenFieldTaskId" Value='<%#Eval("id") %>'></asp:HiddenField>
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateTaskDetailsId" Value="0"></asp:HiddenField>
                                        <asp:HiddenField runat="server" ID="HiddenFieldCanHaveMultipleClients" Value='<%#Eval("CanHaveMultipleClients") %>'></asp:HiddenField>
                                        <asp:HiddenField runat="server" ID="HiddenFieldSpecifyStartStopTime" Value='<%#Eval("SpecifyStartStopTime") %>'></asp:HiddenField>
                                    </td>
                                    <td style="vertical-align: top">
                                        <table>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox runat="server" ID="checkBoxAllClients" Text="All Clients" AutoPostBack="True" OnCheckedChanged="checkBoxAllClients_CheckedChanged"></asp:CheckBox>          
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:ListBox runat="server" id="listBoxClients" width="300" height="65">
                                                    </asp:ListBox>
                                                </td>
                                            </tr>
                                        </table>
                                        <asp:HiddenField runat="server" ID="HiddenFieldSelectedClient" Value='<%#Eval("id") %>'></asp:HiddenField>
                                    </td>
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateSundayTaskDaysId" Value="0"></asp:HiddenField>
                                        <asp:Panel runat="server" ID="panelHoursMinutesSunday" visible="false">
                                            <table>
                                                <tr>
                                                    <td>
                                                        Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursSunday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesSunday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                        <asp:Panel runat="server" ID="panelStartStopSunday" visible="true">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ListBox runat="server" ID="listBoxStartStopSunday" 
                                                            width="175">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <asp:Button runat="server" ID="ButtonStartStopSunday" Text="Edit Time" 
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                                            OnClick="ButtonStartStopSunday_Click"></asp:Button>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateMondayTaskDaysId" Value="0"></asp:HiddenField>
                                        <asp:Panel runat="server" ID="panelHoursMinutesMonday" visible="false">
                                            <table>
                                            <tr>
                                                <td>
                                                    Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursMonday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesMonday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                        </asp:Panel>
                                        <asp:Panel runat="server" ID="panelStartStopMonday" visible="true">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ListBox runat="server" ID="listBoxStartStopMonday" 
                                                            width="175">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <asp:Button runat="server" ID="ButtonStartStopMonday" Text="Edit Time"
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                                             OnClick="ButtonStartStopMonday_Click"></asp:Button>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateTuesdayTaskDaysId" Value="0"></asp:HiddenField>
                                        <asp:Panel runat="server" ID="panelHoursMinutesTuesday" visible="false">
                                            <table>
                                                <tr>
                                                    <td>
                                                        Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursTuesday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesTuesday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                        <asp:Panel runat="server" ID="panelStartStopTuesday" visible="true">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ListBox runat="server" ID="listBoxStartStopTuesday" 
                                                            width="175">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <asp:Button runat="server" ID="ButtonStartStopTuesday" 
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                                            Text="Edit Time" OnClick="ButtonStartStopTuesday_Click"></asp:Button>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateWednesdayTaskDaysId" Value="0"></asp:HiddenField>
                                        <asp:Panel runat="server" ID="panelHoursMinutesWednesday" visible="false">
                                            <table>
                                                <tr>
                                                    <td>
                                                        Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursWednesday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesWednesday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                        <asp:Panel runat="server" ID="panelStartStopWednesday" visible="true">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ListBox runat="server" ID="listBoxStartStopWednesday" 
                                                            width="175">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <asp:Button runat="server" ID="ButtonStartStopWednesday" 
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                                            Text="Edit Time" 
                                                             OnClick="ButtonStartStopWednesday_Click"></asp:Button>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateThursdayTaskDaysId" Value="0"></asp:HiddenField>
                                        <asp:Panel runat="server" ID="panelHoursMinutesThursday" visible="false">
                                            <table>
                                            <tr>
                                                <td>
                                                    Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursThursday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesThursday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                        </asp:Panel>
                                        <asp:Panel runat="server" ID="panelStartStopThursday" visible="true">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ListBox runat="server" ID="listBoxStartStopThursday" 
                                                            width="175">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <asp:Button runat="server" ID="ButtonStartStopThursday" 
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                                            Text="Edit Time"
                                                            OnClick="ButtonStartStopThursday_Click"></asp:Button>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateFridayTaskDaysId" Value="0"></asp:HiddenField>
                                        <asp:Panel runat="server" ID="panelHoursMinutesFriday" visible="false">
                                            <table>
                                            <tr>
                                                <td>
                                                    Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursFriday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesFriday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                        </asp:Panel>
                                        <asp:Panel runat="server" ID="panelStartStopFriday" visible="true">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ListBox runat="server" ID="listBoxStartStopFriday" 
                                                            width="175">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <asp:Button runat="server" ID="ButtonStartStopFriday" 
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                                            Text="Edit Time"
                                                            OnClick="ButtonStartStopFriday_Click"></asp:Button>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                    <td style="vertical-align: top; white-space: nowrap">
                                        <asp:HiddenField runat="server" ID="HiddenFieldAutoPopulateSaturdayTaskDaysId" Value="0"></asp:HiddenField>
                                        <asp:Panel runat="server" ID="panelHoursMinutesSaturday" visible="false">
                                            <table>
                                            <tr>
                                                <td>
                                                    Hours&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxHoursSaturday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    Minutes&nbsp;&nbsp;<asp:TextBox runat="server" ID="textBoxMinutesSaturday"  MaxLength="2" Width="50" Text="0"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                        </asp:Panel>
                                        <asp:Panel runat="server" ID="panelStartStopSaturday" visible="true">
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:ListBox runat="server" ID="listBoxStartStopSaturday" 
                                                            width="175">
                                                        </asp:ListBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center">
                                                        <asp:Button runat="server" ID="ButtonStartStopSaturday" 
                                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                                            Text="Edit Time"
                                                            OnClick="ButtonStartStopSaturday_Click"></asp:Button>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
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
                    <asp:Label runat="server" ID="LabelProblem" Font-Bold="True" ForeColor="Red" 
                        Text=""></asp:Label>
                    <br />
                    <div id="divModal" runat="server" class ="modalDialog" visible="false">
                        <div>
                            <asp:LinkButton ID="lbtnModalClose" runat="server"  CssClass="close" Text="X" OnClick="CloseModal" ValidationGroup="TimeEntries" />
                            <h2>Task Start and Stop Hours</h2>
                            <br /><br />
                            <asp:Button runat="server" ID="Button1" Width="100" Height="35" Text="Add" OnClick="ButtonAdd_Click"
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"></asp:Button>
                            <br/><br/>
                            <asp:Repeater runat="server" ID="repeaterTaskStartStopTemplateControl">
                                <HeaderTemplate>
                                    <table>
                                        <thead style="background-color: #9FC6CB">
                                            <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                                <strong style="font-weight: bold">Start Time</strong>
                                            </th>
                                            <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                                <strong style="font-weight: bold">Stop Time</strong>
                                            </th>
                                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Action</th>
                                        </thead>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tbody>
                                        <tr class="<%# Container.ItemIndex % 2 == 0 ? "alternate" : "" %>">
                                            <td style="vertical-align: top; white-space: nowrap">
                                                <asp:HiddenField runat="server" ID="HiddenFieldDialogStopStartTimeId" Value='<%#Eval("id") %>'></asp:HiddenField>
                                                <asp:TextBox runat="server" ID="labelBoxStartTime" Text='<%#Eval("startTime") %>' ValidationGroup="TimeEntries" Width="75"></asp:TextBox>
                                                &nbsp;&nbsp;&nbsp;
                                                <asp:ImageButton ID="ImageButtonStartTime" runat="server" 
                                                    ImageUrl="~/images/clockkpicker.png" 
                                                    OnClick="ImageButtonStartTime_Click" /> 
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
                                                                <asp:DropDownList ID="DropDownListBoxHoursStart" runat="server">
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
                                                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                                                    Font-Bold="True" OnClick="ButtonSelectStartTime_Click"/>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </td>
                                            <td style="vertical-align: top; white-space: nowrap">
                                                <asp:TextBox runat="server"  ID="labelBoxStopTime" Text='<%#Eval("stopTime") %>' ValidationGroup="TimeEntries" Width="75"></asp:TextBox>
                                                &nbsp;&nbsp;&nbsp;
                                                <asp:ImageButton ID="ImageButtonStopTime" runat="server" 
                                                    ImageUrl="~/images/clockkpicker.png" 
                                                    OnClick="ImageButtonStopTime_Click" /> 
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
                                                                <asp:DropDownList ID="DropDownListBoxHoursStop" runat="server">
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
                                                                <asp:DropDownList ID="DropDownListMinutesStop" runat="server">
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
                                                                <asp:DropDownList ID="DropDownListAMPMStop" runat="server">
                                                                    <asp:ListItem Text="AM" Value="AM" Selected="True" />
                                                                    <asp:ListItem Text="PM" Value="PM" />
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3" style="padding:10px; text-align:center">
                                                                <asp:Button ID="ButtonSelectStopTime" runat="server" Text="Select Time" Height="42px" Width="163px"
                                                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                                                    Font-Bold="True" OnClick="ButtonSelectStopTime_Click" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </td>
                                            <td style="vertical-align: top; white-space: nowrap">
                                                <asp:Button runat="server" ID="ButtonDelete" Width="100" Text="Delete" 
                                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                                    OnClick="ButtonDelete_Click"></asp:Button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:RegularExpressionValidator 
                                                      ID="RegularExpressionEditValidatorStartTime" 
                                                      runat="server" 
                                                      ControlToValidate="labelBoxStartTime"
                                                    ErrorMessage="<br/><font color='Red'>Invalid time format</font>"
                                                    ValidationExpression="(^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([0-9]|0[0-9]|1[0-9]):[0-5][0-9] ([pP][mM]|[aA][mM])$)"
                                                      ValidationGroup="TimeEntries"
                                                      Display="Dynamic"></asp:RegularExpressionValidator>
                                                  <asp:RequiredFieldValidator ID="RequiredFieldEditValidatorStartTime" 
                                                      runat="server"
                                                      ControlToValidate="labelBoxStartTime"
                                                      ErrorMessage="<br/><font color='Red'>Start time is required</font>"
                                                      ValidationGroup="TimeEntries"
                                                      Display="Dynamic"></asp:RequiredFieldValidator>

                                            </td>
                                            <td>
                                                <asp:RegularExpressionValidator 
                                                      ID="RegularExpressionValidatorStopTime" 
                                                      runat="server" 
                                                      ControlToValidate="labelBoxStopTime"
                                                    ErrorMessage="<br/><font color='Red'>Invalid time format</font>"
                                                    ValidationExpression="(^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([0-9]|0[0-9]|1[0-9]):[0-5][0-9] ([pP][mM]|[aA][mM])$)"
                                                      ValidationGroup="TimeEntries"
                                                      Display="Dynamic"></asp:RegularExpressionValidator>
                                                  <asp:RequiredFieldValidator ID="RequiredFieldValidatorStopTime" 
                                                      runat="server"
                                                      ControlToValidate="labelBoxStopTime"
                                                      ErrorMessage="<br/><font color='Red'>Start time is required</font>"
                                                      ValidationGroup="TimeEntries"
                                                      Display="Dynamic"></asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                    </tbody>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                            <br/><br/>
                            <asp:Button ID="btnClose" runat="server" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Text="Add Stop and Start Time(s)" OnClick="CloseModal" ValidationGroup="TimeEntries"/>
                            <br />
                            <asp:Label runat="server" ID="labelMessage" Text="Label" Font-Bold="True" ForeColor="Red"></asp:Label>
                        </div>
                    </div>
                </asp:Panel>
                <br /><br />            

            </div>
        </div>
    </form>
