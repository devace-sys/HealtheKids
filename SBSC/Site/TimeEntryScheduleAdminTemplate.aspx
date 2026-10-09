<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryScheduleAdminTemplate.aspx.cs" Inherits="Spedmon.TimeEntryScheduleAdminTemplate" %>
    <script type = "text/javascript">
            function Confirm() {
                var confirm_value = document.createElement("INPUT");
                confirm_value.type = "hidden";
                confirm_value.name = "confirm_value";
                if (confirm("Do you want to delete this Schedule template?")) {
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
            <asp:Button ID="ButtonAddTask" runat="server" Text="Add New Template" OnClick="ButtonAddTask_Click1" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                Width="250" Height="30" Font-Bold="True" style="width: 250px"/>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <asp:Button ID="ButtonBack" runat="server" Text="Back" Width="200" Height="30"
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                Font-Bold="True" OnClick="ButtonBack_Click"/>
            <br /><br />
            <asp:GridView ID="GridView1" runat="server"
                 AutoGenerateColumns="False" 
                     CellPadding="2" CellSpacing="2"
                    DataKeyNames="id" ForeColor="#333333" GridLines="None" OnRowCancelingEdit="GridView1_RowCancelingEdit"
              OnRowDeleting="GridView1_RowDeleting" OnRowEditing="GridView1_RowEditing" OnRowUpdating="GridView1_RowUpdating"
              OnRowDataBound="GridView1_RowDataBound" OnRowCommand="GridView1_RowCommand" OnSorting="GridView1_Sorting" AllowSorting="true">
                <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                <Columns>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:65px'>Template Name</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelName" runat="server" Text='<%#Eval("TemplateName") %>'></asp:Label>
                            <asp:HiddenField ID="HiddenFieldTemplateId" runat="server" Value='<%#Eval("id") %>' />
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>Sunday</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelSunday" runat="server" Text='<%#Eval("SundayInfo") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>Monday</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelMonday" runat="server" Text='<%#Eval("MondayInfo") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>Tuesday</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelTuesday" runat="server" Text='<%#Eval("TuesdayInfo") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>Wednesday</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelWednesday" runat="server" Text='<%#Eval("WednesdayInfo") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>Thursday</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelThursday" runat="server" Text='<%#Eval("ThursdayInfo") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>Friday</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelFriday" runat="server" Text='<%#Eval("FridayInfo") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold; text-align: center; vertical-align: middle; padding-left:85px'>Saturday</strong>">
                         <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                         <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        <ItemTemplate>
                            <asp:Label ID="LabelSaturday" runat="server" Text='<%#Eval("SaturdayInfo") %>'></asp:Label>
                        </ItemTemplate>
                  </asp:TemplateField>
                  <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HiddenField ID="HiddenFieldItemTemplateIDEdit" runat="server" Value='<%#Eval("id") %>' />
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" Font-Bold="True"  
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                            
                            />
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Delete" Width="100" Height="30" Font-Bold="True"
                                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                OnClientClick="Confirm()"/>
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
