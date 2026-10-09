<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ClientManagement.aspx.cs" Inherits="Spedmon.ClientManagement" MaintainScrollPositionOnPostBack="true" %>
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
            <asp:HiddenField ID="HiddenFieldOrganizationId" runat="server" />
            <asp:HiddenField ID="HiddenFieldSortOrder" runat="server" value="ASC"/>
            <h2>
                <asp:Label ID="LabelOrganization" runat="server" Text="Label"></asp:Label>
            </h2>

            <asp:Button ID="ButtonAdd" runat="server" Text="Add Client" Font-Bold="True" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                Height="40" Width="175px" OnClick="ButtonAdd_Click"/>
            &nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonSpedmonSync" runat="server" Text="Sync With Spedmon Client" Font-Bold="True" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                Height="40px" Width="321px" OnClick="ButtonSpedmonSync_Click" />
            &nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonBack" runat="server" Text="Back" Font-Bold="True" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                Height="40" Width="175px" OnClick="ButtonBack_Click" />
            <br /><br />

            <table>
                <tr>
                    <td style="padding-left: 10px; padding-right:10px">
                        <b>Search For</b>
                    </td>
                    <td style="padding-left: 10px; padding-right:10px">
                        <asp:TextBox ID="TextBoxSearch" runat="server" Width="399px"></asp:TextBox>
                    </td>
                    <td style="padding-left: 10px; padding-right:10px">
                        <asp:Button ID="ButtonSearch" runat="server" Text="Search" Font-Bold="True"
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                            Height="30" Width="150px" OnClick="ButtonSearch_Click"/>
                        &nbsp;&nbsp;&nbsp;
                        <asp:Button ID="ButtonRemoveSearch" runat="server" Text="Remove Search" Font-Bold="True"
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                            Height="30" Width="200px" OnClick="ButtonRemoveSearch_Click"/>
                    </td>
                </tr>
            </table>
            <br />
        
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
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
                    <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold;vertical-align:middle;text-align:center;margin-left:250px'>Organization</strong>" SortExpression="organization">
                            <HeaderStyle Height="40px" Width="600px" HorizontalAlign="Center"></HeaderStyle>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelClient" runat="server" Text='<%#Eval("client") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:DropDownList ID="DropDownListOrganizations" runat="server"></asp:DropDownList>
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderStyle Height="40px" Width="400px" HorizontalAlign="Center"></HeaderStyle>
                        <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:HiddenField ID="ClientOrganizationId" runat="server" Value='<%#Eval("clientOrganizationID") %>'/>
                            &nbsp;&nbsp;
                            <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Delete" Width="100" Height="30" Font-Bold="True"
                                OnClientClick="Confirm()" />
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:HiddenField ID="ClientOrganizationEditId" runat="server" Value='<%#Eval("clientOrganizationID") %>'/>
                            <asp:Button ID="ButtonInsert" runat="server" CommandName="Add"  Text="Add" Width="100" Height="30" Font-Bold="True" OnClientClick="Confirm()" ValidationGroup="OrganizationEntries" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                            />
                            <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update"  Text="Update" Width="100" Height="30" Font-Bold="True" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                OnClientClick="Confirm()" ValidationGroup="OrganizationEntries" />
                            <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel"  Text="Cancel" Width="100" Height="30" Font-Bold="True" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                            />
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
