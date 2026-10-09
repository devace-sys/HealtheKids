<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetUpFavorites.aspx.cs" Inherits="Spedmon.SetUpFavorites" %>
    <form id="form1" runat="server">
        <div style="margin-left: 50px">
            <asp:HiddenField ID="HiddenFieldEmployeeID" runat="server" />
            <strong style=""font-weight: bold">Employee Name &nbsp&nbsp;&nbsp;</strong><asp:Label ID="LabelEmployeeName" runat="server" Text="Employee Name"></asp:Label><br /><br />
            <asp:RadioButtonList ID="RadioButtonListDiplayOptions" runat="server" AutoPostBack="true" OnSelectedIndexChanged="RadioButtonListDiplayOptions_SelectedIndexChanged">
                <asp:ListItem Text="Display Clients and Tasks" Value="0" Selected="True"></asp:ListItem>
                <asp:ListItem Text="Display Clients" Value="1"></asp:ListItem>
                <asp:ListItem Text="Display Tasks" Value="2"></asp:ListItem>
            </asp:RadioButtonList><br />
            <asp:Panel ID="PanelClientFavorites" runat="server">
                <table>
                    <tr>
                        <td style="vertical-align:top" colspan="2">
                                <strong style="font-weight:bold">Select Employer</strong>
                                &nbsp;&nbsp;
                                <asp:DropDownList ID="DropDownListEmployer" runat="server">
                                </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <strong style="font-weight:bold">Clients Available</strong>
                        </td>
                        <td>

                        </td>
                        <td>
                            <strong style="font-weight:bold">Favorites Clients List</strong>
                            <br />Note: 'All Clients' cannot be removed off favorites
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align:center">
                            <asp:ListBox ID="ListBoxAvailableClients" runat="server" Height="553px" Width="396px" SelectionMode="Multiple"></asp:ListBox>
                        </td>
                        <td style="vertical-align:middle">
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonMoveToFavorites" runat="server" Text=">" Height="50px" Width="53px" Font-Size="Large" OnClick="ButtonMoveToFavorites_Click" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True" />
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <br />
                            <br />
                            <br />
                            <br />
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonMoveToAvailableClients" runat="server" Text="<"  Height="50px" Width="53px" Font-Size="Large" OnClick="ButtonMoveToAvailableClients_Click" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True"/>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                        </td>
                        <td style="text-align:center">
                            <asp:ListBox ID="ListBoxFavoritesClientSetUp" runat="server"  Height="553" Width="396px" SelectionMode="Multiple"></asp:ListBox>
                        </td>
                    </tr>
                </table>              
            </asp:Panel> 
            <asp:Panel ID="PanelTaskFavorites" runat="server">
                <table>
                    <tr>
                        <td>
                            <strong style="font-weight:bold">Tasks Available</strong>
                        </td>
                        <td>

                        </td>
                        <td>
                            <strong style="font-weight:bold">Favorites Tasks List</strong>
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align:center">
                            <asp:ListBox ID="ListBoxAvailableTasks" runat="server" Height="553px" Width="396px" SelectionMode="Multiple"></asp:ListBox>
                        </td>
                        <td style="vertical-align:middle">
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonMoveToFavoriteTask" runat="server" Text=">" Height="50px" Width="53px" Font-Size="Large" OnClick="ButtonMoveToFavoriteTask_Click"  
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True"/>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <br />
                            <br />
                            <br />
                            <br />
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonMoveToAvailableTask" runat="server" Text="<"  Height="50px" Width="53px" Font-Size="Large" OnClick="ButtonMoveToAvailableTask_Click" 
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                Font-Bold="True"/>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                        </td>
                        <td style="text-align:center">
                            <asp:ListBox ID="ListBoxSelectedFavoriteTaskSetUp" runat="server"  Height="553" Width="396px" SelectionMode="Multiple"></asp:ListBox>
                        </td>
                    </tr>
                </table>              
            </asp:Panel> 
        </div>
    </form>
