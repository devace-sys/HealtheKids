<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryTaskTypeManagement.aspx.cs" Inherits="Spedmon.TimeEntryTaskTypeManagement" %>
    <script type = "text/javascript">
         function Confirm() {
              var confirm_value = document.createElement("INPUT");
              confirm_value.type = "hidden";
              confirm_value.name = "confirm_value";
              if (confirm("Do you want to make the change?")) {
                   confirm_value.value = "Yes";
              } else {
                   confirm_value.value = "No";
                   location.reload(true);
              }
              document.forms[0].appendChild(confirm_value);
         }
    </script>
    <form id="form1" runat="server">
        <div style="margin-left: 50px">
            <br /><br />
            <asp:Button ID="ButtonAddTask" runat="server" Text="Add Task Type" OnClick="ButtonAddTask_Click1" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                Width="200" Height="30" Font-Bold="True"/>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonBack" runat="server" Text="Back" Width="200" Height="30"
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                Font-Bold="True" OnClick="ButtonBack_Click"/>
            <br /><br />
            <asp:RadioButton ID="RadioButtonActive" runat="server" Text="Display Active" AutoPostBack="true" GroupName="TaskType" Checked="true" OnCheckedChanged="RadioButtonActive_CheckedChanged"/>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:RadioButton ID="RadioButtonInActive" runat="server" Text="Display In-Active" AutoPostBack="true" GroupName="TaskType" OnCheckedChanged="RadioButtonInActive_CheckedChanged"/>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:RadioButton ID="RadioButtonAll" runat="server" Text="Display All" AutoPostBack="true" GroupName="TaskType" OnCheckedChanged="RadioButtonAll_CheckedChanged"/>
            <br /><br />
            <asp:HiddenField ID="HiddenFieldEditRowIndex" runat="server" />
            <asp:HiddenField ID="HiddenFieldSortDirection" runat="server" Value="ASC" />
            <asp:GridView ID="gridView" DataKeyNames="id" runat="server"
                    AutoGenerateColumns="false" ShowFooter="false" HeaderStyle-Font-Bold="true"
                     CellPadding="2" CellSpacing="2"
                    AllowSorting="true"
                    onrowcancelingedit="gridView_RowCancelingEdit"
                    onrowdeleting="gridView_RowDeleting"
                    onrowediting="gridView_RowEditing"
                    onrowupdating="gridView_RowUpdating"
                    onrowcommand="gridView_RowCommand"
                    OnRowDataBound="gridView_RowDataBound"
                    OnSorting="GridView1_Sorting" 
                     Width="1200px"
                >
                <Columns>
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; margin-left:20px'>Name</strong>" SortExpression="Name">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>                    
                        <ItemTemplate>
                            <asp:Label ID="lblTaskName" runat="server"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TextBoxEditTaskName" runat="server" ValidationGroup="TaskTypeEntries"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="RequiredFieldEditValidatorStartTime" 
                                    runat="server"
                                    ControlToValidate="TextBoxEditTaskName"
                                    ErrorMessage="<br/><font color='Red'>Task Name is requried</font>"
                                    ValidationGroup="TimeEntries"
                                    Display="Dynamic"></asp:RequiredFieldValidator>
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; margin-left:30px'>Scheduled</strong>">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>                    
                        <ItemTemplate>
                            <asp:Label ID="lblScheduled" runat="server"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="CheckBoxScheduled" runat="server" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; margin-left:30px'>Paid Work</strong>">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>                    
                        <ItemTemplate>
                            <asp:Label ID="lblPaidWork" runat="server"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="CheckBoxPaidWork" runat="server" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; margin-left:30px'>Paid Not<br/><div style='font-weight:bold; margin-left:30px'>To Work</div></strong><br/>">
                         <HeaderStyle Height="50px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="lblPaidNotToWork" runat="server"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="CheckBoxPaidNotToWork" runat="server" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; margin-left:40px'>Breaks</strong>">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="lblBreaks" runat="server"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="CheckBoxBreaks" runat="server" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; margin-left:30px'>Vacation</strong>">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="lblVacation" runat="server"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="CheckBoxVacation" runat="server" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; margin-left:50px'>Sick</strong>">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="lblSick" runat="server"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="CheckBoxSick" runat="server" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:HiddenField ID="lblnameTaskTypeId" runat="server" Value='<%#Eval("id") %>'/>
                            <asp:HiddenField ID="HiddenFieldIsActive" runat="server" Value='<%#Eval("active") %>'/>
                            <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="150" Height="30" Font-Bold="True" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                />
                            <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="In-Activate" Width="150" Height="30" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True"
                                 OnClientClick="Confirm()"/>
                            <asp:Button ID="ButtonUnDelete" runat="server" CommandName="UnDelete"  Text="Activate" Width="150" Height="30" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True"
                                 OnClientClick="Confirm()"/>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:HiddenField ID="HiddenFieldIDEdit" runat="server" Value='<%#Eval("id") %>' />
                            <asp:Button ID="ButtonAddEdit" runat="server" CommandName="AddNew"  Text="Save" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Width="100" Height="30" ValidationGroup="TimeEntries" Font-Bold="True" />
                            <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update"  
                                Text="Save" Width="100" Height="30" ValidationGroup="TimeEntries" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True"
                                />
                            <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel"  Text="Cancel" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Width="100" Height="30" Font-Bold="True" />
                        </EditItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <RowStyle BackColor="#E3EAEB" />
                <EditRowStyle BackColor="#C6D8DA" />
                <SelectedRowStyle BackColor="#C6D8DA" Font-Bold="True" ForeColor="#333333" />
                <PagerStyle BackColor="#666666" ForeColor="White" HorizontalAlign="Center" />
                <HeaderStyle BackColor="#9FC6CB" Font-Bold="True" />
                <AlternatingRowStyle BackColor="White" />
            </asp:GridView>
        </div>
    </form>
