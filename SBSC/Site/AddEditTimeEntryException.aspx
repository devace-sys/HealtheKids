<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddEditTimeEntryException.aspx.cs" Inherits="Spedmon.AddEditTimeEntryException" 
MaintainScrollPositionOnPostback="true"%>
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
            <asp:HiddenField ID="HiddenFieldExceptionID" runat="server" Value="0" />
            <fieldset>
                <legend><strong style="font-weight: bold">Exception Details</strong></legend>
                <strong style="font-weight: bold">Exception Name : </strong>
                <asp:TextBox ID="TextBoxExceptionName" runat="server" MaxLength="100" Width="830px"></asp:TextBox><br />
                <asp:RequiredFieldValidator ID="RequiredFieldValidatorExceptionName" runat="server" 
                    ErrorMessage="Exception Name is required<br/>"
                    Display="Dynamic"
                    Font-Bold="True" ForeColor="Red" ValidationGroup="CreateUpdateException"
                    ControlToValidate="TextBoxExceptionName"></asp:RequiredFieldValidator><br />
 
                    <table>
                        <tr>
                            <td style="vertical-align: top">
                                <strong style="font-weight">Exception Description : </strong>
                            </td>
                            <td>
                                <asp:TextBox ID="TextBoxExceptionDescription" runat="server" TextMode="MultiLine" Height="122px" Width="788px"></asp:TextBox><br />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidatorExceptionDescription" runat="server" 
                                    ErrorMessage="Exception Description is required<br/>"
                                    Display="Dynamic"
                                    Font-Bold="True" ForeColor="Red" ValidationGroup="CreateUpdateException"
                                    ControlToValidate="TextBoxExceptionName"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                    </table>
                
                    <strong style="font-weight: bold">Type : </strong>
                    <asp:DropDownList ID="DropDownListType" runat="server">
                        <asp:ListItem Text="Warning" Value="0" Selected="True" />
                        <asp:ListItem Text="Error" Value="1" />
                    </asp:DropDownList><br /><br />
                
                    <strong style="font-weight: bold">System : </strong>
                    <asp:DropDownList ID="DropDownListSystem" runat="server">
                        <asp:ListItem Text="Schedule" Value="0"/>
                        <asp:ListItem Text="Time Entry" Value="1" Selected="True" />
                    </asp:DropDownList><br /><br />
                
                    <strong style="font-weight: bold">Does FLSA Apply : </strong>
                    <asp:CheckBox ID="CheckBoxFLSA" runat="server" /><br /><br />
                
                    <strong style="font-weight: bold">Granularity : </strong>
                    <asp:DropDownList ID="DropDownListGranularity" runat="server">
                        <asp:ListItem Text="None Specified" Value="0" Selected="True"/>
                        <asp:ListItem Text="Weekly" Value="1" />
                        <asp:ListItem Text="Daily" Value="2" />
                        <asp:ListItem Text="Record Instnce" Value="3" />
                    </asp:DropDownList><br /><br />

                    <strong style="font-weight">Minutes : </strong>
                    <asp:DropDownList ID="DropDownListMinutes" runat="server">
                        <asp:ListItem Text="None Specified" Value="-1" Selected="True"/>
                        <asp:ListItem Text="0" Value="0" />
                        <asp:ListItem Text="1" Value="1" />
                        <asp:ListItem Text="2" Value="2" />
                        <asp:ListItem Text="3" Value="3" />
                        <asp:ListItem Text="4" Value="4" />
                        <asp:ListItem Text="5" Value="5" />
                        <asp:ListItem Text="6" Value="6" />
                        <asp:ListItem Text="7" Value="7" />
                        <asp:ListItem Text="8" Value="8" />
                        <asp:ListItem Text="9" Value="9" />
                        <asp:ListItem Text="10" Value="10" />
                        <asp:ListItem Text="11" Value="11" />
                        <asp:ListItem Text="12" Value="12" />
                        <asp:ListItem Text="13" Value="13" />
                        <asp:ListItem Text="14" Value="14" />
                        <asp:ListItem Text="15" Value="15" />
                        <asp:ListItem Text="16" Value="16" />
                        <asp:ListItem Text="17" Value="17" />
                        <asp:ListItem Text="18" Value="18" />
                        <asp:ListItem Text="19" Value="19" />
                        <asp:ListItem Text="20" Value="20" />
                        <asp:ListItem Text="21" Value="21" />
                        <asp:ListItem Text="22" Value="22" />
                        <asp:ListItem Text="23" Value="23" />
                        <asp:ListItem Text="24" Value="24" />
                        <asp:ListItem Text="25" Value="25" />
                        <asp:ListItem Text="26" Value="26" />
                        <asp:ListItem Text="27" Value="27" />
                        <asp:ListItem Text="28" Value="28" />
                        <asp:ListItem Text="29" Value="29" />
                        <asp:ListItem Text="30" Value="30" />
                        <asp:ListItem Text="31" Value="31" />
                        <asp:ListItem Text="32" Value="32" />
                        <asp:ListItem Text="33" Value="33" />
                        <asp:ListItem Text="34" Value="34" />
                        <asp:ListItem Text="35" Value="35" />
                        <asp:ListItem Text="36" Value="36" />
                        <asp:ListItem Text="37" Value="37" />
                        <asp:ListItem Text="38" Value="38" />
                        <asp:ListItem Text="39" Value="39" />
                        <asp:ListItem Text="40" Value="40" />
                        <asp:ListItem Text="41" Value="41" />
                        <asp:ListItem Text="42" Value="42" />
                        <asp:ListItem Text="43" Value="43" />
                        <asp:ListItem Text="44" Value="44" />
                        <asp:ListItem Text="45" Value="45" />
                        <asp:ListItem Text="46" Value="46" />
                        <asp:ListItem Text="47" Value="47" />
                        <asp:ListItem Text="48" Value="48" />
                        <asp:ListItem Text="49" Value="49" />
                        <asp:ListItem Text="50" Value="50" />
                        <asp:ListItem Text="51" Value="51" />
                        <asp:ListItem Text="52" Value="52" />
                        <asp:ListItem Text="53" Value="53" />
                        <asp:ListItem Text="54" Value="54" />
                        <asp:ListItem Text="55" Value="55" />
                        <asp:ListItem Text="56" Value="56" />
                        <asp:ListItem Text="57" Value="57" />
                        <asp:ListItem Text="58" Value="58" />
                        <asp:ListItem Text="59" Value="59" />
                        <asp:ListItem Text="60" Value="60" />
                        <asp:ListItem Text="61" Value="61" />
                        <asp:ListItem Text="62" Value="62" />
                        <asp:ListItem Text="63" Value="63" />
                        <asp:ListItem Text="64" Value="64" />
                        <asp:ListItem Text="65" Value="65" />
                        <asp:ListItem Text="66" Value="66" />
                        <asp:ListItem Text="67" Value="67" />
                        <asp:ListItem Text="68" Value="68" />
                        <asp:ListItem Text="69" Value="69" />
                    </asp:DropDownList>                        
                    &nbsp;&nbsp;&nbsp;
                    <asp:DropDownList ID="DropDownListMinutesOperator" runat="server">
                        <asp:ListItem Text="None Specified" Value="-1" Selected="True"/>
                        <asp:ListItem Text="=" Value="=" />
                        <asp:ListItem Text="!=" Value="!=" />
                        <asp:ListItem Text=">" Value=">" />
                        <asp:ListItem Text=">=" Value=">=" />
                        <asp:ListItem Text="<" Value="<" />
                        <asp:ListItem Text="<=" Value="<=" />
                    </asp:DropDownList>
                    <br /><br />
                    <strong style="font-weight">Hours : </strong>
                    <asp:DropDownList ID="DropDownListHours" runat="server">
                        <asp:ListItem Text="None Specified" Value="-1" Selected="True"/>
                        <asp:ListItem Text="0" Value="0" />
                        <asp:ListItem Text="1" Value="1" />
                        <asp:ListItem Text="2" Value="2" />
                        <asp:ListItem Text="3" Value="3" />
                        <asp:ListItem Text="4" Value="4" />
                        <asp:ListItem Text="5" Value="5" />
                        <asp:ListItem Text="6" Value="6" />
                        <asp:ListItem Text="7" Value="7" />
                        <asp:ListItem Text="8" Value="8" />
                        <asp:ListItem Text="9" Value="9" />
                        <asp:ListItem Text="10" Value="10" />
                        <asp:ListItem Text="11" Value="11" />
                        <asp:ListItem Text="12" Value="12" />
                        <asp:ListItem Text="13" Value="13" />
                        <asp:ListItem Text="14" Value="14" />
                        <asp:ListItem Text="15" Value="15" />
                        <asp:ListItem Text="16" Value="16" />
                        <asp:ListItem Text="17" Value="17" />
                        <asp:ListItem Text="18" Value="18" />
                        <asp:ListItem Text="19" Value="19" />
                        <asp:ListItem Text="20" Value="20" />
                        <asp:ListItem Text="21" Value="21" />
                        <asp:ListItem Text="22" Value="22" />
                        <asp:ListItem Text="23" Value="23" />
                        <asp:ListItem Text="24" Value="24" />
                        <asp:ListItem Text="25" Value="25" />
                        <asp:ListItem Text="26" Value="26" />
                        <asp:ListItem Text="27" Value="27" />
                        <asp:ListItem Text="28" Value="28" />
                        <asp:ListItem Text="29" Value="29" />
                        <asp:ListItem Text="30" Value="30" />
                        <asp:ListItem Text="31" Value="31" />
                        <asp:ListItem Text="32" Value="32" />
                        <asp:ListItem Text="33" Value="33" />
                        <asp:ListItem Text="34" Value="34" />
                        <asp:ListItem Text="35" Value="35" />
                        <asp:ListItem Text="36" Value="36" />
                        <asp:ListItem Text="37" Value="37" />
                        <asp:ListItem Text="38" Value="38" />
                        <asp:ListItem Text="39" Value="39" />
                        <asp:ListItem Text="40" Value="40" />
                        <asp:ListItem Text="41" Value="41" />
                        <asp:ListItem Text="42" Value="42" />
                        <asp:ListItem Text="43" Value="43" />
                        <asp:ListItem Text="44" Value="44" />
                        <asp:ListItem Text="45" Value="45" />
                        <asp:ListItem Text="46" Value="46" />
                        <asp:ListItem Text="47" Value="47" />
                        <asp:ListItem Text="48" Value="48" />
                        <asp:ListItem Text="49" Value="49" />
                        <asp:ListItem Text="50" Value="50" />
                        <asp:ListItem Text="51" Value="51" />
                        <asp:ListItem Text="52" Value="52" />
                        <asp:ListItem Text="53" Value="53" />
                        <asp:ListItem Text="54" Value="54" />
                        <asp:ListItem Text="55" Value="55" />
                        <asp:ListItem Text="56" Value="56" />
                        <asp:ListItem Text="57" Value="57" />
                        <asp:ListItem Text="58" Value="58" />
                        <asp:ListItem Text="59" Value="59" />
                    </asp:DropDownList>
                    &nbsp;&nbsp;&nbsp;
                    <asp:DropDownList ID="DropDownListHoursOperator" runat="server">
                        <asp:ListItem Text="None Specified" Value="-1" Selected="True"/>
                        <asp:ListItem Text="=" Value="=" />
                        <asp:ListItem Text="!=" Value="!=" />
                        <asp:ListItem Text=">" Value=">" />
                        <asp:ListItem Text=">=" Value=">=" />
                        <asp:ListItem Text="<" Value="<" />
                        <asp:ListItem Text="<=" Value="<=" />
                    </asp:DropDownList>
                    <br /><br />
                    <strong style="font-weight">Days : </strong>
                    <asp:DropDownList ID="DropDownListDays" runat="server">
                        <asp:ListItem Text="None Specified" Value="-1" Selected="True"/>
                        <asp:ListItem Text="0" Value="0" />
                        <asp:ListItem Text="1" Value="1" />
                        <asp:ListItem Text="2" Value="2" />
                        <asp:ListItem Text="3" Value="3" />
                        <asp:ListItem Text="4" Value="4" />
                        <asp:ListItem Text="5" Value="5" />
                        <asp:ListItem Text="6" Value="6" />
                        <asp:ListItem Text="7" Value="7" />
                        <asp:ListItem Text="8" Value="8" />
                        <asp:ListItem Text="9" Value="9" />
                        <asp:ListItem Text="10" Value="10" />
                        <asp:ListItem Text="11" Value="11" />
                        <asp:ListItem Text="12" Value="12" />
                        <asp:ListItem Text="13" Value="13" />
                        <asp:ListItem Text="14" Value="14" />
                        <asp:ListItem Text="15" Value="15" />
                        <asp:ListItem Text="16" Value="16" />
                        <asp:ListItem Text="17" Value="17" />
                        <asp:ListItem Text="18" Value="18" />
                        <asp:ListItem Text="19" Value="19" />
                        <asp:ListItem Text="20" Value="20" />
                        <asp:ListItem Text="21" Value="21" />
                        <asp:ListItem Text="22" Value="22" />
                        <asp:ListItem Text="23" Value="23" />
                        <asp:ListItem Text="24" Value="24" />
                        <asp:ListItem Text="25" Value="25" />
                        <asp:ListItem Text="26" Value="26" />
                        <asp:ListItem Text="27" Value="27" />
                        <asp:ListItem Text="28" Value="28" />
                        <asp:ListItem Text="29" Value="29" />
                        <asp:ListItem Text="30" Value="30" />
                        <asp:ListItem Text="31" Value="31" />
                    </asp:DropDownList>                        
                    &nbsp;&nbsp;&nbsp;
                    <asp:DropDownList ID="DropDownListDaysOperator" runat="server">
                        <asp:ListItem Text="None Specified" Value="-1" Selected="True"/>
                        <asp:ListItem Text="=" Value="=" />
                        <asp:ListItem Text="!=" Value="!=" />
                        <asp:ListItem Text=">" Value=">" />
                        <asp:ListItem Text=">=" Value=">=" />
                        <asp:ListItem Text="<" Value="<" />
                        <asp:ListItem Text="<=" Value="<=" />
                    </asp:DropDownList>
                    <br /><br />
                    <table>
                        <tr>
                            <td style="vertical-align: top">
                                <strong style="font-weight">Message : </strong>
                            </td>
                            <td>
                                <asp:TextBox ID="TextBoxMessage" runat="server" TextMode="MultiLine" Height="122px" Width="788px" MaxLength="500"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                    <br />
                
                    <strong style="font-weight: bold">Tasks : </strong>
                    <asp:DropDownList ID="DropDownListTask" runat="server">
                    </asp:DropDownList><br /><br />

            </fieldset>
            <br /><br />
                <asp:Button ID="ButtonAddUpdateException" runat="server" Text="Add Exception" ValidationGroup="CreateUpdateException"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                
                    Width="200" Height="30" Font-Bold="True"
                    OnClientClick="Confirm()" OnClick="ButtonAddUpdateException_Click"/>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <asp:Button ID="ButtonBack" runat="server" Text="Back"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonBack_Click"/>
            <br /><br />
            <asp:Panel ID="PanelExclusionList" runat="server">
                <fieldset>
                    <legend><strong style="font-weight: bold">Exclusion List</strong></legend>
                    <strong style="font-weight: bold">Select Employee : </strong>
                    <asp:DropDownList ID="DropDownListEmployee" runat="server">
                    </asp:DropDownList><br /><br />

                    <strong style="font-weight: bold">Action : </strong>
                    <asp:DropDownList ID="DropDownListAction" runat="server">
                        <asp:ListItem Text="No Action" Value="0" />
                        <asp:ListItem Text="Email Supervisor" Value="1" />
                        <asp:ListItem Text="Email Next Level Supervisor" Value="2" />
                    </asp:DropDownList><br /><br />

                <asp:Button ID="ButtonAdd" runat="server" Text="Add Exclusion" Font-Bold="True" 
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                    
                    Height="30" Width="150px" OnClick="ButtonAdd_Click" /><br /><br />

                    <asp:HiddenField ID="HiddenFieldEditRowIndex" runat="server" />
                    <h3>Employees on Exclusion List</h3>
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
                          <asp:TemplateField HeaderText="<strong style='font-weight:bold'>First Name</strong>">
                                 <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                                 <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                <ItemTemplate>
                                    <asp:Label ID="LabelFirstName" runat="server" Text='<%#Eval("firstName") %>'></asp:Label>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:Label ID="LabelEditFirstName" runat="server" Text='<%#Eval("firstName") %>'></asp:Label>
                                </EditItemTemplate>
                          </asp:TemplateField>
                          <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Last Name</strong>">
                                 <HeaderStyle Height="40px" Width="200px" HorizontalAlign="Center"></HeaderStyle>
                                 <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                <ItemTemplate>
                                    <asp:Label ID="LabelDescription" runat="server" Text='<%#Eval("lastName") %>'></asp:Label>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:Label ID="LabelEditDescription" runat="server" Text='<%#Eval("lastName") %>'></asp:Label>
                                </EditItemTemplate>
                          </asp:TemplateField>
                          <asp:TemplateField HeaderText="<strong style='font-weight:bold'>Action</strong>">
                                 <HeaderStyle Height="40px" Width="300px" HorizontalAlign="Center"></HeaderStyle>
                                 <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                <ItemTemplate>
                                    <asp:Label ID="LabelType" runat="server" Text='<%#Eval("action") %>'></asp:Label>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:DropDownList ID="DropDownListAction" runat="server">
                                        <asp:ListItem Text="No Action" Value="0" />
                                        <asp:ListItem Text="Email Supervisor" Value="1" />
                                        <asp:ListItem Text="Email Next Level Supervisor" Value="2" />
                                    </asp:DropDownList>
                                </EditItemTemplate>
                          </asp:TemplateField>
                          <asp:TemplateField>
                                 <HeaderStyle Height="40px" Width="300px" HorizontalAlign="Center"></HeaderStyle>
                                 <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                <ItemTemplate>
                                    <asp:HiddenField ID="HiddenFieldExclusionId" runat="server" Value='<%#Eval("id") %>'/>
                                    <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" Font-Bold="True" 
                                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                    
                                        />
                                    &nbsp;&nbsp;
                                    <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Delete" Width="100" Height="30" Font-Bold="True"
                                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                        OnClientClick="Confirm()" />
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:HiddenField ID="HiddenFieldExclusionIdEdit" runat="server" Value='<%#Eval("id") %>'/>
                                    <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update"  Text="Update" Width="100" Height="30" Font-Bold="True" 
                                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                        
                                        OnClientClick="Confirm()" />
                                    <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel"  Text="Cancel" Width="100" Height="30" Font-Bold="True" 
                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                            />
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
                </fieldset>
            </asp:Panel>
        </div>
    </form>
