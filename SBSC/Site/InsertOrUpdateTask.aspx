<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InsertOrUpdateTask.aspx.cs" Inherits="Spedmon.InsertOrUpdateTask" %>
    <form id="form1" runat="server">
        <asp:HiddenField ID="HiddenFieldTaskID" runat="server" />
        <asp:HiddenField ID="HiddenFieldTaskType" runat="server" />
        <asp:HiddenField ID="HiddenFieldDuration" runat="server" />
        <asp:HiddenField ID="HiddenFieldClient" runat="server" />
        <div style="margin-left: 50px">
            <asp:Label ID="LabelTaskName" runat="server" Text="Task Name :" Font-Bold="true"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:TextBox ID="TextBoxTaskName" runat="server" Width="428px"></asp:TextBox>
            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" 
                ErrorMessage="<br/><font color='Red'>Must provide a name</font>"
                 ControlToValidate="TextBoxTaskName"
                 ValidationGroup="TimeTask"
                Display="Dynamic"></asp:RequiredFieldValidator>
            <br /><br />
            <asp:Label ID="LabelTaskDescription" runat="server" Text="Description" Font-Bold="true"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:TextBox ID="TextBoxTaskDescription" TextMode="MultiLine" Rows="3" width="218" runat="server"></asp:TextBox>
            <br /><br />
            <asp:Label ID="LabelTaskType" runat="server" Text="Task Type :" Font-Bold="true"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:DropDownList ID="DropDownListTaskType" runat="server"></asp:DropDownList>
            <br /><br />
            <asp:Label ID="LabelMinDuration" runat="server" Text="Minimum Duration :" Font-Bold="true"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:TextBox ID="TextBoxDuration" runat="server"></asp:TextBox>
            <asp:RegularExpressionValidator 
                ID="RegularExpressionValidatorDuration" 
                runat="server" 
                ControlToValidate="TextBoxDuration"
                ErrorMessage="<br/><font color='Red'>Invalid duration</font>"
                ValidationExpression="(^$)|(^ *$)|^[0-9]*$|(^[1-9][0-9]*$)"
                ValidationGroup="TimeTask"
                Display="Dynamic"></asp:RegularExpressionValidator>
            <br /><br />

            <asp:Label ID="LabelTtfnCode" runat="server" Text="TTFN Code :" Font-Bold="true"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:TextBox ID="TextBoxTaskTtfnCode" runat="server"></asp:TextBox>
            <br /><br /> 

            <asp:Label ID="Label1" runat="server" Text="Client (if applicable) :" Font-Bold="true"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:DropDownList ID="DropDownListClient" runat="server"></asp:DropDownList>
            <br /><br /><br />
            <table>
                <tr>
                    <th>
                        &nbsp;&nbsp;&nbsp;<strong style="font-weight: bold">Project Management Options</strong>
                    </th>
                    <th>
                        &nbsp;&nbsp;&nbsp;<strong style="font-weight: bold">ITM or HD Options</strong>
                    </th>
                    <th>
                        &nbsp;&nbsp;&nbsp;<strong style="font-weight: bold">Other Options</strong>
                    </th>
                </tr>
                <tr>
                    <td colspan="3">
                        <br />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:RadioButtonList ID="RadioButtonListProjectManagementOrHelpDesk" runat="server">
                            <asp:ListItem Text="Project Management Required" Value="0" />
                            <asp:ListItem Text="Help Desk Required" Value="1" />
                            <asp:ListItem Text="None" Value="2" Selected="true"/>
                        </asp:RadioButtonList>
                    </td>
                    <td>
                        <asp:RadioButtonList ID="RadioButtonListITPMorHDRow" runat="server">
                            <asp:ListItem Text="ITPM ID Required" Value="0" />
                            <asp:ListItem Text="HD ROW ID Required" Value="1" />
                            <asp:ListItem Text="None" Value="2" Selected="true"/>
                        </asp:RadioButtonList>
                    </td>
                    <td style="vertical-align: top; padding-left: 20px; padding-right: 20px">
                        <asp:CheckBox ID="CheckBoxFileNameReference" runat="server" Text="File name reference Required"/>
                        <br />
                        <asp:CheckBox ID="CheckBoxTaskScheduleInFuture" runat="server" Text="Task Can Be Scheduled in the Future"/>
                        <br />
                        <asp:CheckBox ID="CheckBoxMultipleClients" runat="server" Text="Task can be associated with multiple clients"/>
                        <br />
                        <asp:CheckBox ID="CheckBoxSpecifyStartStopTime" runat="server" Text="Specify Start and Stop Time"/>
                    </td>
                </tr>
            </table>
            <br /><br />
            <asp:Button ID="ButtonSave" runat="server" Text="Save" Width="200" Height="30" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                Font-Bold="True" ValidationGroup="TimeTask" OnClick="ButtonSave_Click"/>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonCancel" runat="server" Text="Cancel" Width="200" Height="30" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                Font-Bold="True" OnClick="ButtonCancel_Click"/>
            <asp:Label ID="LabelErrMsg" runat="server" ForeColor="#CC0000"></asp:Label>

        </div>
    </form>
