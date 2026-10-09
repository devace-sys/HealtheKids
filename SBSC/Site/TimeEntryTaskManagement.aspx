<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryTaskManagement.aspx.cs" Inherits="Spedmon.TimeEntryTaskManagement" %>
    <script type = "text/javascript">
        function Confirm() {
            var confirm_value = document.createElement("INPUT");
            confirm_value.type = "hidden";
            confirm_value.name = "confirm_value";
            if (confirm("Do you want to make change?")) {
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
            <asp:Button ID="ButtonAddTask" runat="server" Text="Add Task"  Width="200" Height="30" Font-Bold="True" OnClick="ButtonAddTask_Click"  
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" />
            <br /><br />
            <asp:Label ID="LabelTaskType" runat="server" Text="Select Task To Filter On :" Font-Bold="true"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <asp:DropDownList ID="DropDownListTaskType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DropDownListTaskType_SelectedIndexChanged"></asp:DropDownList>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonTaskType" runat="server" Text="Manage Task Types" Width="200" Height="30" Font-Bold="True" OnClick="ButtonTaskType_Click" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" />
            <br /><br />
            <asp:RadioButton ID="RadioButtonActive" runat="server" Text="Display Active" AutoPostBack="true" GroupName="TaskType" Checked="true" OnCheckedChanged="RadioButtonActive_CheckedChanged"/>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:RadioButton ID="RadioButtonInActive" runat="server" Text="Display In-Active" AutoPostBack="true" GroupName="TaskType" OnCheckedChanged="RadioButtonInActive_CheckedChanged"/>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:RadioButton ID="RadioButtonAll" runat="server" Text="Display All" AutoPostBack="true" GroupName="TaskType" OnCheckedChanged="RadioButtonAll_CheckedChanged"/>
            <br /><br />
            <asp:HiddenField ID="HiddenFieldTaskTypeOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldTaskNameOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldDefaultDurationOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldDefaultClientOrder" runat="server" Value="ASC" />
            <strong style="font-weight: bold">Enter Name To Search&nbsp;&nbsp;&nbsp;&nbsp;</strong>
            <asp:TextBox ID="TextBoxSearch" runat="server" Width="757px"></asp:TextBox>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonSearch" runat="server" Text="Search"  Width="200" Height="30" Font-Bold="True" OnClick="ButtonSearch_Click" 
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
            />
            <br /><br />
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
                     CellPadding="2" CellSpacing="2"
                    DataKeyNames="id" ForeColor="#333333" GridLines="None" OnRowCancelingEdit="GridView1_RowCancelingEdit"
              OnRowDeleting="GridView1_RowDeleting" OnRowEditing="GridView1_RowEditing" OnRowUpdating="GridView1_RowUpdating"
              OnRowDataBound="GridView1_RowDataBound" OnRowCommand="GridView1_RowCommand" OnSorting="GridView1_Sorting" 
                AllowSorting="true" Width="1200px">
                <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                <Columns>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Task Type</strong>" SortExpression="TaskType">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelTaskTypeId" runat="server" Text='<%#Eval("taskType") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Task Name</strong>" SortExpression="TaskName">
                         <ItemStyle HorizontalAlign="Left"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelTaskName" runat="server" Text='<%#Eval("taskName") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Default Duration</strong>" SortExpression="DefaultDuration">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelDefaultDuration" runat="server" Text='<%#Eval("defaultDuration") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Default Client</strong>" SortExpression="DefaultClient">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelDefaultClient" runat="server" Text='<%#Eval("defaultClient") %>'></asp:Label>
                            <asp:HiddenField ID="HiddenFieldDefaultClientId" runat="server" Value='<%#Eval("defaultClientId")%>' />
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField>
                         <HeaderStyle Height="40px" Width="350px" HorizontalAlign="Center"></HeaderStyle>
                        <ItemTemplate>
                            <asp:HiddenField ID="HiddenFieldItemTemplateIDEdit" runat="server" Value='<%#Eval("id") %>' />
                            <asp:HiddenField ID="HiddenFieldActive" runat="server" Value='<%#Eval("IsActive") %>' />
                            &nbsp;&nbsp;
                            <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="150" Height="30" Font-Bold="True"
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"/>
                            &nbsp;&nbsp;
                            <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Deactivate" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Width="150" Height="30" Font-Bold="True"
                                OnClientClick="Confirm()" />
                            &nbsp;&nbsp;
                            <asp:Button ID="ButtonUnDelete" runat="server" CommandName="UnDelete"  Text="Make Active" Width="150" Height="30" Font-Bold="True"
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                OnClientClick="Confirm()" />
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
        </div>
    </form>
