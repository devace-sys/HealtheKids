<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryScheduleAdminStopStart.aspx.cs" Inherits="Spedmon.TimeEntryScheduleAdminStopStart" %>
    <form id="form1" runat="server">
        <asp:HiddenField ID="HiddenFieldStart" runat="server" Value="ASC"/>
        <asp:HiddenField ID="HiddenFieldStop" runat="server" Value="ASC"/>
        <asp:HiddenField ID="HiddenFieldScheduleID" runat="server" />
        <asp:HiddenField ID="HiddenFieldEmployeeID" runat="server" />
        <asp:HiddenField ID ="HiddenFieldPreviousPage" runat="server" />
        <asp:Literal ID="LiteralErrors" runat="server" Text=""></asp:Literal>
        <div style="margin-left: 50px">
            <table>
                <tr>
                    <td>
                        <b>Date Of Entry : </b>
                    </td>
                    <td>
                        <asp:Literal ID="LiteralDateOfEntry" runat="server"></asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td>
                        <br />
                        <asp:Button ID="ButtonAdd" runat="server" 
                            CommandName="AddNew"  
                            Text="Add Start & Stop" 
                             Width="150" OnClick="ButtonAdd_Click"
                            />    
                            &nbsp;&nbsp;&nbsp;
                    </td>
                    <td>
                        <br />
                        <asp:Button ID="ButtonBack" runat="server" Text="Back" Width="150" OnClick="ButtonBack_Click" />
                    </td>
                </tr>
            </table>
            <br />
            <br />            
            <asp:GridView ID="gridView" DataKeyNames="id" runat="server"
                    AutoGenerateColumns="false" ShowFooter="false" HeaderStyle-Font-Bold="true"
                     CellPadding="16" CellSpacing="16"
                    onrowcancelingedit="gridView_RowCancelingEdit"
                    onrowdeleting="gridView_RowDeleting"
                    onrowediting="gridView_RowEditing"
                    onrowupdating="gridView_RowUpdating"
                    onrowcommand="gridView_RowCommand"
                    OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    OnSorting="GridView1_Sorting" 
                >
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:HiddenField ID="lblnameStopStartId" runat="server" Value='<%#Eval("id") %>'/>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:HiddenField ID="HiddenFieldIDEdit" runat="server" Value='<%#Eval("id") %>' />
                        <asp:Button ID="ButtonAddEdit" runat="server" CommandName="AddNew"  Text="Insert" Width="100" ValidationGroup="validaiton" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="<br/>Start<br/><br/>" SortExpression="Start">
                    <ItemTemplate>
                        <asp:Label ID="lblnameStartTime" runat="server"/>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="TextBoxEditStartTime" runat="server" ValidationGroup="TimeEntries"></asp:TextBox>
                        <asp:RegularExpressionValidator 
                              ID="RegularExpressionEditValidatorStartTime" 
                              runat="server" 
                              ControlToValidate="TextBoxEditStartTime"
                              ErrorMessage="<br/><font color='Red'>Valid time must be in hh:mm format&nbsp;&nbsp;&nbsp;<br/>where hh can be 0 to 23<br/>or hh can be 0 to 12 followed by AM/PM<br/>and mm can be 0 to 59<br/>Example: 08:00, 8:00, 8:00 AM, 17:00 or 5:00 PM are valid time formats</font>"
                              ValidationExpression="(^([1-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([1-9]|0[0-9]|1[0-2]):[0-5][0-9] ([Aa][Mm]|[Pp][Mm])$)"
                              ValidationGroup="TimeEntries"
                              Display="Dynamic"></asp:RegularExpressionValidator>
                          <asp:RequiredFieldValidator ID="RequiredFieldEditValidatorStartTime" 
                              runat="server"
                              ControlToValidate="TextBoxEditStartTime"
                              ErrorMessage="<br/><font color='Red'>Start time is required</font>"
                              ValidationGroup="TimeEntries"
                              Display="Dynamic"></asp:RequiredFieldValidator>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="<br/>End<br/><br/>" SortExpression="End">
                    <ItemTemplate>
                        <asp:Label ID="lblnameEndTime" runat="server"/>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="TextBoxEditEndTime" runat="server" ValidationGroup="TimeEntries"></asp:TextBox>
                        <asp:RegularExpressionValidator 
                              ID="RegularExpressionEditValidatorEndTime" 
                              runat="server" 
                              ControlToValidate="TextBoxEditEndTime"
                              ErrorMessage="<br/><font color='Red'>Valid time must be in hh:mm format&nbsp;&nbsp;&nbsp;<br/>where hh can be 0 to 23<br/>or hh can be 0 to 12 followed by AM/PM<br/>and mm can be 0 to 59<br/>Example: 08:00, 8:00, 8:00 AM, 17:00 or 5:00 PM are valid time formats</font>"
                              ValidationExpression="(^([1-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([1-9]|0[0-9]|1[0-2]):[0-5][0-9] ([Aa][Mm]|[Pp][Mm])$)"
                              ValidationGroup="TimeEntries"
                              Display="Dynamic"></asp:RegularExpressionValidator>
                          <asp:RequiredFieldValidator ID="RequiredFieldEditValidatorEndTime" 
                              runat="server"
                              ControlToValidate="TextBoxEditEndTime"
                              ErrorMessage="<br/><font color='Red'>Start time is required</font>"
                              ValidationGroup="TimeEntries"
                              Display="Dynamic"></asp:RequiredFieldValidator>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <EditItemTemplate>
                        <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update"  Text="Update" Width="100" ValidationGroup="validaiton"  />
                        <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel"  Text="Cancel" Width="100" />
                    </EditItemTemplate>
                    <ItemTemplate>
                        <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" />
                        <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Delete" Width="100" />
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
            <br />
            <asp:Label ID="lblmsg" runat="server" ForeColor="Red"></asp:Label>
        </div>
    </form>
