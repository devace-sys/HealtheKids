<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryReport.aspx.cs" Inherits="Spedmon.TimeEntryReport" %>
    <form id="form1" runat="server">
        <div style="margin-left: 50px">
            <asp:HiddenField ID="hiddenFieldTimeOfTaskSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldNumberMinutesSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldTaskNameSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldTaskTypeSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldNoteSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldIsProjectManagementSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldIsHelpDeskSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldITPM_IDSortOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldHD_ROW_IDOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldDescriptionOrder" runat="server" />
            <asp:HiddenField ID="hiddenFieldFileNameReferenceOrder" runat="server" />
            <asp:RadioButtonList ID="RadioButtonListDateSelection" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="RadioButtonListDateSelection_SelectedIndexChanged">
                <asp:ListItem Text="Specify by pay period&nbsp;&nbsp;&nbsp;" Value="0" Selected="True" />
                <asp:ListItem Text="Specify by date range" Value="1" />
            </asp:RadioButtonList><br />
            <asp:Panel ID="PanelPayPeriod" runat="server">
                <strong style="font-weight:bold">Select Pay Period Week</strong>&nbsp;&nbsp;&nbsp;
                <asp:textbox id="tbSelectedDate" runat="server"></asp:textbox>
                &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="lnkpickdate" runat="server" ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px" OnClick="lnkpickdate_Click"></asp:ImageButton>
                &nbsp;&nbsp;&nbsp;<asp:Button ID="ButtonUpdate" runat="server" Text="Update" Font-Bold="True" 
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                        Height="30" Width="91px" OnClick="ButtonUpdate_Click" />
                &nbsp;&nbsp;<strong style="font-style: italic">Note: End date of report will be Saturday</strong>
                <asp:Calendar ID="datepicker" runat="server" Visible="false" OnSelectionChanged="datepicker_SelectionChanged"></asp:Calendar>
                <asp:label ID="LiteralMessage" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
            </asp:Panel>
            <asp:Panel ID="PanelDateRange" runat="server" Visible="false">
                <table>
                    <tr>
                        <td>
                            <strong style="font-weight:bold">Select Pay Period Week</strong>&nbsp;&nbsp;&nbsp;
                            <asp:textbox id="tbStartDate" runat="server"></asp:textbox>
                            &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="lknPicStartDate" runat="server" ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px" OnClick="lknPicStartDate_Click"></asp:ImageButton>
                        </td>
                        <td>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                        </td>
                        <td>
                            <strong style="font-weight:bold">Select Pay Period Week</strong>&nbsp;&nbsp;&nbsp;
                            <asp:textbox id="tbEndDate" runat="server"></asp:textbox>
                            &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="lnkPicEndDate" runat="server" ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px" OnClick="lnkPicEndDate_Click"></asp:ImageButton>
                        </td>
                        <td>
                            &nbsp;&nbsp;&nbsp;<asp:Button ID="ButtonUpdateDateRange" runat="server" Text="Update" Font-Bold="True" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                    Height="30" Width="91px" OnClick="ButtonUpdate_Click" />
                            &nbsp;&nbsp;<strong style="font-style: italic">Note: End date of report will be Saturday</strong>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Calendar ID="CalendarStart" runat="server" Visible="false" OnSelectionChanged="CalendarStart_SelectionChanged"></asp:Calendar>
                            <asp:label ID="Label2" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
                        </td>
                        <td>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                        </td>
                        <td colspan="2">
                            <asp:Calendar ID="CalendarEnd" runat="server" Visible="false" OnSelectionChanged="CalendarEnd_SelectionChanged"></asp:Calendar>
                            <asp:label ID="Label3" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
                        </td>
                    </tr>
                </table>
            </asp:Panel>
            <br /><br />
            <strong style="font-weight: bold; text-decoration: underline">
                <asp:Label ID="Label1" runat="server" Text="Employee Information"></asp:Label>&nbsp;&nbsp;&nbsp;
            </strong>
            <br /><br />
            <strong style="font-style: italic">
                <asp:Label ID="LabelEmployees" runat="server" Text="Joe Smith<br/>SBSC"></asp:Label>&nbsp;&nbsp;&nbsp;
            </strong>
            <br /><br/>
            <asp:Button ID="ButtonPrintREport" runat="server" Text="Print Report"  
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                style="font-weight: bold; height: 37px; width: 172px;" OnClick="ButtonPrintREport_Click"/>
            &nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonExport" runat="server" Text="Export Report"  
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                style="font-weight: bold; height: 37px; width: 172px;" OnClick="ButtonExport_Click"/>
            <br /><br />
            <asp:Panel ID="PanelReport" runat="server">
                <asp:GridView ID="GridView1" 
                    runat="server" 
                    AutoGenerateColumns="False" 
                    CellPadding="2" CellSpacing="2"
                    ForeColor="#333333" GridLines="None" 
                    OnRowCancelingEdit="GridView1_RowCancelingEdit"
                    OnRowDeleting="GridView1_RowDeleting" 
                    OnRowEditing="GridView1_RowEditing" 
                    OnRowUpdating="GridView1_RowUpdating"
                    OnRowDataBound="GridView1_RowDataBound" 
                    OnRowCommand="GridView1_RowCommand" 
                    OnPageIndexChanging="OnPageIndexChanging"
                    AllowPaging="true"
                    OnSorting="GridView1_Sorting" AllowSorting="true">
                    <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                    <Columns>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Time Of Task</strong>" SortExpression="timeOfTask">
                             <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabeltimeOfTask" runat="server" Text='<%#Eval("timeOfTask") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Number Of Minutes</strong>" SortExpression="numberMinutes">
                             <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelnumberMinutes" runat="server" Text='<%#Eval("numberMinutes") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Task Name</strong>" SortExpression="TaskName">
                             <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelTaskName" runat="server" Text='<%#Eval("TaskName") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Task Type</strong>" SortExpression="TaskType">
                             <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelTaskType" runat="server" Text='<%#Eval("TaskType") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Note</strong>" SortExpression="note">
                             <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelNote" runat="server" Text='<%#Eval("note") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Is Project Management</strong>" SortExpression="IsProjectManagement">
                             <HeaderStyle Height="40px" Width="500px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelIsProjectManagement" runat="server" Text='<%#Eval("IsProjectManagement") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Is Help Desk</strong>" SortExpression="IsHelpDesk">
                             <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelIsHelpDesk" runat="server" Text='<%#Eval("IsHelpDesk") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>ITPM ID</strong>">
                             <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelITPM_ID" runat="server" Text='<%#Eval("ITPM_ID") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>HD ROW ID</strong>">
                             <HeaderStyle Height="40px" Width="600px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelHD_ROW_ID" runat="server" Text='<%#Eval("HD_ROW_ID") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Description</strong>">
                             <HeaderStyle Height="40px" Width="400px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelDescription" runat="server" Text='<%#Eval("Description") %>'></asp:Label>
                            </ItemTemplate>
                      </asp:TemplateField>
                      <asp:TemplateField HeaderText="<strong style='font-weight:bold'>File Name Reference</strong>">
                             <HeaderStyle Height="40px" Width="400px" HorizontalAlign="Center"></HeaderStyle>
                             <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelFileNameReference" runat="server" Text='<%#Eval("FileNameReference") %>'></asp:Label>
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
            </asp:Panel>
        </div>
    </form>
