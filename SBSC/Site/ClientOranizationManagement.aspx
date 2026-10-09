<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ClientOranizationManagement.aspx.cs" Inherits="Spedmon.ClientOranizationManagement" MaintainScrollPositionOnPostback="true" %>
    <script type = "text/javascript">
        function Confirm() {
            var confirm_value = document.createElement("INPUT");
            confirm_value.type = "hidden";
            confirm_value.name = "confirm_value";
            if (confirm("Are you sure?")) {
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
            <asp:HiddenField ID="HiddenFieldSortOrder" runat="server" Value="ASC" />
            <h2>Clients</h2>
            <asp:Button ID="ButtonAdd" runat="server" Text="Add Clients" Font-Bold="True" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                Height="40" Width="175px" OnClick="ButtonAdd_Click" />
            &nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonSpedmonSync" runat="server" Text="Sync With Spedmon Client" Font-Bold="True" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                Height="40px" Width="321px" OnClick="ButtonSpedmonSync_Click" />
            <br /><br />
            <table>
                <tr>
                    <td style="padding-left: 10px; padding-right:10px">
                        <b>Search For</b>
                    </td>
                    <td style="padding-left: 10px; padding-right:10px">
                        <asp:TextBox ID="TextBoxSearch" runat="server" Width="600"></asp:TextBox>
                    </td>
                    <td style="padding-left: 10px; padding-right:10px">
                        <asp:Button ID="ButtonSearch" runat="server" Text="Search" Font-Bold="True" Height="30" Width="200px" OnClick="ButtonSearch_Click"
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only" />
                        &nbsp;&nbsp;&nbsp;
                        <asp:Button ID="ButtonRemoveSearch" runat="server" Text="Remove Search" Font-Bold="True" 
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                            Height="30" Width="200px" OnClick="ButtonRemoveSearch_Click"/>
                    </td>
                </tr>
            </table>
            <br />
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="id"
                CellPadding="2" CellSpacing="2"
                ForeColor="#333333" GridLines="None" 
                OnRowCancelingEdit="GridView1_RowCancelingEdit"
                OnRowDeleting="GridView1_RowDeleting" 
                OnRowEditing="GridView1_RowEditing" 
                OnRowUpdating="GridView1_RowUpdating"
                OnRowDataBound="GridView1_RowDataBound" 
                OnRowCommand="GridView1_RowCommand" 
                OnSorting="GridView1_Sorting" AllowSorting="true">
                <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                <Columns>
                    <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Clients</strong>" SortExpression="organization">
                            <HeaderStyle Height="40px" Width="600px" HorizontalAlign="Center"></HeaderStyle>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelOrganization" runat="server" Text='<%#Eval("name") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <br />
                            <asp:TextBox ID="TextBoxOrganization" runat="server" Text='<%#Eval("name") %>' Width="600"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidatorOrganization" 
                                runat="server" 
                                ControlToValidate="TextBoxOrganization"
                                ErrorMessage="<br/><font color='Red'>Invalid time format</font>"
                                ValidationGroup="OrganizationEntries"></asp:RequiredFieldValidator>
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderStyle Height="40px" Width="550px" HorizontalAlign="Center"></HeaderStyle>
                        <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:HiddenField ID="OrganizationId" runat="server" Value='<%#Eval("id") %>'/>
                            <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" Font-Bold="True" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"/>
                            &nbsp;&nbsp;
                            <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Make inactive" Width="130" Height="30" Font-Bold="True"
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                OnClientClick="Confirm()" />
                            &nbsp;&nbsp;
                            <asp:Button ID="ButtonACtivate" runat="server" CommandName="Active"  Text="Activate" Width="100" Height="30" Font-Bold="True"
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                OnClientClick="Confirm()" />
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:HiddenField ID="OrganizationEditId" runat="server" Value='<%#Eval("id") %>'/>
                            <asp:Button ID="ButtonInsert" runat="server" CommandName="Add"  Text="Add" Width="100" Height="30" Font-Bold="True" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                                    OnClientClick="Confirm()" ValidationGroup="OrganizationEntries" />
                            <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update"  Text="Update" Width="100" Height="30" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True" OnClientClick="Confirm()" ValidationGroup="OrganizationEntries" />
                            <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel"  Text="Cancel" Width="100" Height="30" Font-Bold="True" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"/>
                        </EditItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <RowStyle BackColor="#E3EAEB" />
                <EditRowStyle BackColor="#8EB5BA" />
                <SelectedRowStyle BackColor="#548B1F" Font-Bold="True" ForeColor="#333333" />
                <PagerStyle BackColor="#666666" ForeColor="White" HorizontalAlign="Center" />
                <HeaderStyle BackColor="#9FC6CB" Font-Bold="True" />
                <AlternatingRowStyle BackColor="White" />
            </asp:GridView>
        </div>
    </form>
