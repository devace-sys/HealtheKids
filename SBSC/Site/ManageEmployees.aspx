<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageEmployees.aspx.cs" Inherits="Spedmon.ManageEmployees" %>
    <script type = "text/javascript">
        function Confirm() {
            var confirm_value = document.createElement("INPUT");
            confirm_value.type = "hidden";
            confirm_value.name = "confirm_value";
            if (confirm("Do you want to remove?")) {
                confirm_value.value = "Yes";
            } else {
                confirm_value.value = "No";
                location.reload(true);
            }
            document.forms[0].appendChild(confirm_value);
        }
    </script>
    <form id="form1" runat="server" defaultbutton="ButtonSearch">
        <div style="margin-left: 50px">
            <asp:HiddenField ID="HiddenFieldFirstNameOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldLastNameOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldSpedMonUserNameOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldRoleOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldStartDateOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldEndDateOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldEmployeeStatusOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldTitleOrder" runat="server" Value="ASC" />
            <asp:HiddenField ID="HiddenFieldOrganizationOrder" runat="server" Value="ASC" />
            <br /><br />
            <asp:Button ID="ButtonAddEmployee" runat="server" Text="Add Employee"  Width="200" Height="30" Font-Bold="True" OnClick="ButtonAddEmployee_Click"  
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                />
            <br /><br />
            <strong style="font-weight: bold">Enter Name To Search&nbsp;&nbsp;&nbsp;&nbsp;</strong>
            <asp:TextBox ID="TextBoxSearch" runat="server" Width="757px"></asp:TextBox>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonSearch" runat="server" Text="Search"  Width="200" Height="30" Font-Bold="True" OnClick="ButtonSearch_Click" 
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
            />
            <br /><br />
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
                     CellPadding="2" CellSpacing="2"
                    DataKeyNames="EmployeeID" ForeColor="#333333" GridLines="None" OnRowCancelingEdit="GridView1_RowCancelingEdit"
              OnRowDeleting="GridView1_RowDeleting" OnRowEditing="GridView1_RowEditing" OnRowUpdating="GridView1_RowUpdating"
              OnRowDataBound="GridView1_RowDataBound" OnRowCommand="GridView1_RowCommand" OnSorting="GridView1_Sorting" AllowSorting="true">
                <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                <Columns>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>First Name</strong>" SortExpression="firstName">
                         <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelTaskTypeId" runat="server" Text='<%#Eval("firstName") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Last Name</strong>" SortExpression="lastName">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelTaskName" runat="server" Text='<%#Eval("lastName") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Spedmon Username</strong>" SortExpression="spedMonUserName">
                         <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelDefaultDuration" runat="server" Text='<%#Eval("spedMonUserName") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Role</strong>" SortExpression="roleName">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelRoleName" runat="server" Text='<%#Eval("roleName") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Start Date</strong>" SortExpression="startDate">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelStartDate" runat="server" Text='<%#Eval("startDate") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>End Date</strong>" SortExpression="endDate">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelEndDate" runat="server" Text='<%#Eval("endDate")%>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Employee Status</strong>" SortExpression="employeeStatus">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelEmployeeStatus" runat="server" Text='<%#Eval("employeeStatus") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Title</strong>" SortExpression="title">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelTitle" runat="server" Text='<%#Eval("title") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Organization</strong>" SortExpression="Organization">
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelOrganization" runat="server" Text='<%#Eval("Organization") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HiddenField ID="HiddenFieldItemPersonID" runat="server" Value='<%#Eval("PersonID") %>' />
                            <asp:HiddenField ID="HiddenFieldroleID" runat="server" Value='<%#Eval("roleID") %>' />
                            <asp:HiddenField ID="HiddenFieldEmployeeID" runat="server" Value='<%#Eval("EmployeeID") %>' />
                            <asp:HiddenField ID="HiddenFieldOrganizationID" runat="server" Value='<%#Eval("OrganizationID") %>' />
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" Font-Bold="True" 
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                            />
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Delete" Width="100" Height="30" Font-Bold="True"
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
