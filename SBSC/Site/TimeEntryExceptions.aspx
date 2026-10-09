<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TimeEntryExceptions.aspx.cs" Inherits="Spedmon.TimeEntryExceptions" MaintainScrollPositionOnPostback="true" %>
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
            <asp:Button ID="ButtonAdd" runat="server" Text="Add Exception" Font-Bold="True" 
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                Height="30" Width="150px" OnClick="ButtonAdd_Click" /><br /><br />
            <div>
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
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>View Exclusions</strong>">
                                <HeaderStyle Height="40px" Width="400px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Button ID="ButtonViewExclusions" runat="server" CommandName="Exclusions"  Text="Exclusions" Width="125px" Height="30" Font-Bold="True" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                                 />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Name Of Exception</strong>">
                                <HeaderStyle Height="40px" Width="800px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelNameOfException" runat="server" Text='<%#Eval("name") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Description</strong>">
                                <HeaderStyle Height="40px" Width="1200px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelDescription" runat="server" Text='<%#Eval("description") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Exception Type</strong>">
                                <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelType" runat="server" Text='<%#Eval("type") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Apply Rule Against</strong>">
                                <HeaderStyle Height="40px" Width="250px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelSystem" runat="server" Text='<%#Eval("system") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>FLSA Apply</strong>">
                                <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelDoesFLSApply" runat="server" Text='<%#Eval("doesFLSAapply") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Granulartiy</strong>">
                                <HeaderStyle Height="40px" Width="300px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelGranularity" runat="server" Text='<%#Eval("granularity") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Minutes</strong>">
                                <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelMinutes" runat="server" Text='<%#Eval("minutes") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Hours</strong>">
                                <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelHours" runat="server" Text='<%#Eval("hours") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Days</strong>">
                                <HeaderStyle Height="40px" Width="100px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelDays" runat="server" Text='<%#Eval("days") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Message</strong>">
                                <HeaderStyle Height="40px" Width="1000px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelMessage" runat="server" Text='<%#Eval("message") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Associated Task</strong>">
                                <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelTaskName" runat="server" Text='<%#Eval("TaskName") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                                <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:HiddenField ID="HiddenFieldTaskTypeId" runat="server" Value='<%#Eval("timeEntryTaskId") %>'/>
                                <asp:HiddenField ID="HiddenFieldTimeEntryId" runat="server" Value='<%#Eval("id") %>'/>
                                <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" Font-Bold="True" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                                />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                                <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
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
            <br /><br />
            <div>
                <h3>
                    <asp:Label ID="LabelExceptionName" runat="server" Text=""></asp:Label>
                </h3>
                <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" 
                    CellPadding="2" CellSpacing="2"
                    ForeColor="#333333" GridLines="None" 
                    OnRowCancelingEdit="GridView2_RowCancelingEdit"
                    OnRowDeleting="GridView2_RowDeleting" 
                    OnRowEditing="GridView2_RowEditing" 
                    OnRowUpdating="GridView2_RowUpdating"
                    OnRowDataBound="GridView2_RowDataBound" 
                    OnRowCommand="GridView2_RowCommand" 
                    OnSorting="GridView2_Sorting" AllowSorting="true">
                    <FooterStyle BackColor="#1C5E55" Font-Bold="True" ForeColor="White"/>
                    <Columns>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>First Name</strong>">
                                <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelFirstName" runat="server" Text='<%#Eval("firstName") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Last Name</strong>">
                                <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelDescription" runat="server" Text='<%#Eval("lastName") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Action</strong>">
                                <HeaderStyle Height="40px" Width="300px" HorizontalAlign="Center"></HeaderStyle>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            <ItemTemplate>
                                <asp:Label ID="LabelType" runat="server" Text='<%#Eval("action") %>'></asp:Label>
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
        </div>
    </form>
