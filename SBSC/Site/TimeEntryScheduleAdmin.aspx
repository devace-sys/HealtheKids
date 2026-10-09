<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryScheduleAdmin.aspx.cs" Inherits="Spedmon.TimeEntryScheduleAdmin" %>
    <script type = "text/javascript">
        function ConfirmScheduleUpdate()
        {
            var confirm_update = document.createElement("INPUT");
                confirm_update.type = "hidden";
                confirm_update.name = "confirm_update";
                if (confirm("Do you want to update schedule?"))
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

        function ConfirmRunAutoScheduler()
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
        function ConfirmRunAutoTaskTemplate()
        {
            var confirm_run = document.createElement("INPUT");
            confirm_run.type = "hidden";
            confirm_run.name = "confirm_run";
            if (confirm("Do you want to run auto task template (any old tasks for that day will be deleted)?"))
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
    <form id="form1" runat="server">
        <div style="margin-left: 50px">
            <table style="padding: 10px;">
                <tr>
                    <td>
                        <asp:RadioButtonList ID="RadioButtonListSetEmployeeType" runat="server" AutoPostBack="True" OnSelectedIndexChanged="RadioButtonListSetEmployeeType_SelectedIndexChanged"
                            Visible="false">
                            <asp:ListItem Text="Set Schedule Template for a single employee" Value="1" Selected="true"/>
                            <asp:ListItem Text="Set Schedule Template for multiple employees" Value="0" />
                        </asp:RadioButtonList>
                        <br /><br />
                    </td>
                </tr>
                <tr>
                    <td style="vertical-align: top">
                        <asp:Literal ID="LiteralEmployeesPrompt" runat="server"
                            Text="<strong style='font-weight:bold'>Select Employees</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"    ></asp:Literal>
                        <asp:Literal ID="LiteralEmployeePrompt" runat="server" Visible="false"
                            Text="<strong style='font-weight:bold'>Select Employee</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"    ></asp:Literal>
                    </td>
                    <td>
                        <!-- Turn off Auto Post back for multiple employees for now -->
                        <asp:ListBox ID="ListBoxEmployees" runat="server" SelectionMode="Multiple" AutoPostBack="False" OnSelectedIndexChanged="ListBoxEmployees_SelectedIndexChanged" Width="282px" Height="410px"></asp:ListBox>
                        <asp:DropDownList ID="DropDownListEmployee" runat="server" Visible="false" AutoPostBack="True" OnSelectedIndexChanged="DropDownListEmployee_SelectedIndexChanged" Width="282PX"></asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Label ID="LabelError" runat="server" Text="" Font-Bold="True" ForeColor="#CC0000"></asp:Label>
                    </td>
                </tr>
            </table>
            <asp:Panel ID="PanelAutoSchedulingDetails" runat="server">
                <strong style="font-weight:bold">Choose Schedule</strong>&nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:DropDownList ID="DropDownListScheduleTemplate" runat="server" AutoPostBack="True" 
                        OnSelectedIndexChanged="DropDownListScheduleTemplate_SelectedIndexChanged"
                        Enabled="false"></asp:DropDownList>&nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:Button ID="ButtonManageSchedules" runat="server" Text="Manage Template"  Width="200" Height="30" Font-Bold="True" 
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                    
                        OnClick="ButtonManageSchedules_Click" Visible="false" />
                    <asp:Button ID="ButtonAdd" runat="server" Text="Add Schedule and Task Template"  Width="250" Height="30" Font-Bold="True" 
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" Visible="false" OnClick="ButtonAdd_Click" /><br />
                <br />
                &nbsp;&nbsp;&nbsp;
                <asp:GridView ID="GridView1" runat="server"
                     AutoGenerateColumns="False" 
                         CellPadding="2" CellSpacing="2"
                        DataKeyNames="id" ForeColor="#333333" GridLines="None" OnRowCancelingEdit="GridView1_RowCancelingEdit"
                  OnRowDeleting="GridView1_RowDeleting" OnRowEditing="GridView1_RowEditing" OnRowUpdating="GridView1_RowUpdating"
                  OnRowDataBound="GridView1_RowDataBound" OnRowCommand="GridView1_RowCommand" OnSorting="GridView1_Sorting" AllowSorting="true">
                    <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                    <Columns>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Sunday</strong>">
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelSunday" runat="server" Text='<%#Eval("SundayInfo") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Monday</strong>">
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelMonday" runat="server" Text='<%#Eval("MondayInfo") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Tuesday</strong>">
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelTuesday" runat="server" Text='<%#Eval("TuesdayInfo") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Wednesday</strong>">
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelWednesday" runat="server" Text='<%#Eval("WednesdayInfo") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>

                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Thursday</strong>">
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelThursday" runat="server" Text='<%#Eval("ThursdayInfo") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Friday</strong>">
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelFriday" runat="server" Text='<%#Eval("FridayInfo") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Saturday</strong>">
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelSaturday" runat="server" Text='<%#Eval("SaturdayInfo") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField>
                             <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                            <ItemTemplate>
                                <asp:HiddenField ID="HiddenFieldItemTemplateIDEdit" runat="server" Value='<%#Eval("id") %>' />
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" Font-Bold="True" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    />
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
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
                <br />
            </asp:Panel>
            <br /><br />
            <asp:Button ID="ButtonApply" runat="server" Text="Update Employee Template"  Width="400" Height="30" Font-Bold="True"
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                OnClick="ButtonApply_Click"
                OnClientClick="ConfirmScheduleUpdate()" Visible="false"/>
            <asp:Button ID="ButtonAddOrEdit" runat="server" Text="Add Employee Template"  Width="400" Height="30" Font-Bold="True"
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                OnClick="ButtonAddOrEdit_Click"/>
            <br /><br />
            <asp:panel runat="server" ID="PanelRunTaskTemplate">
                <h3>Task Template Run Options</h3>
                <strong style='font-weight:bold;vertical-align:top;'>Run For All Employees</strong>&nbsp&nbsp;&nbsp;            
                <asp:dropdownlist runat="server" ID="DropDownListAllEmployees">
                    <asp:ListItem Selected="True" Value="false">False</asp:ListItem>
                    <asp:ListItem Value="true">True</asp:ListItem>    
                </asp:dropdownlist>                    
                <br />
                <strong style='font-weight:bold;vertical-align:top;'>Date To Run Task Template</strong>&nbsp;&nbsp;&nbsp;<asp:textbox id="tbSelectedDate" runat="server"></asp:textbox>
                &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px" OnClick="lnkpickdate_Click"></asp:ImageButton>
                <br /><strong style='font-weight:bold'>Overwrite Existing Entries</strong>&nbsp;&nbsp;&nbsp;
                <asp:dropdownlist runat="server" ID="DropDownListForceDelete">
                    <asp:ListItem Selected="True" Value="false">False</asp:ListItem>
                    <asp:ListItem Value="true">True</asp:ListItem>    
                </asp:dropdownlist>                    
                <br />
                <asp:Calendar ID="datepicker" runat="server" Visible="false" OnSelectionChanged="datepicker_SelectionChanged"></asp:Calendar>
                <br />
                <asp:label ID="LiteralMessageError" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label><br />
                <asp:Button ID="ButtonRunTaskTemplate" runat="server" Text="Run Task Template"  Width="400" Height="30" Font-Bold="True" 
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                    OnClientClick="ConfirmRunAutoTaskTemplate()" OnClick="ButtonRunTaskTemplate_Click"/>
                &nbsp;&nbsp;&nbsp;
                <asp:Button ID="ButtonRunSchedule" runat="server" Text="Run Auto Scheduler"  Width="400" Height="30" Font-Bold="True" 
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                    OnClick="ButtonRunSchedule_Click"
                    OnClientClick="ConfirmRunAutoScheduler()"/>
            </asp:panel>
        </div>
    </form>
