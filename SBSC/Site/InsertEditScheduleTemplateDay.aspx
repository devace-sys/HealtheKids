<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InsertEditScheduleTemplateDay.aspx.cs" Inherits="Spedmon.InsertEditScheduleTemplateDay" %>
    <form id="form1" runat="server">
        <asp:HiddenField ID="HiddenFieldScheduleTemplateId" runat="server" />
        <asp:HiddenField ID="HiddenFieldScheduleTemplateDayId" runat="server" />
        <asp:HiddenField ID="HiddenFieldEditRowIndex" runat="server" />
        <asp:HiddenField ID="HiddenFieldDayId" runat="server" />
        <asp:HiddenField ID="HiddenFieldStop" runat="server" />
        <asp:HiddenField ID="HiddenFieldStart" runat="server" />
        <asp:HiddenField ID="HiddenFieldEmployeeID" runat="server" />
        <div style="margin-left: 50px">
            <table>
                <tr>
                    <td>
                        <br />
                        <asp:Button ID="ButtonAdd" runat="server" 
                            CommandName="AddNew"  
                            Text="Add Start & Stop" 
                            Width="200" Height="30"
                            Font-Bold="True" OnClick="ButtonAdd_Click"
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"                                
                            />    
                            &nbsp;&nbsp;&nbsp;
                    </td>
                    <td>
                        <br />
                        <asp:Button ID="ButtonBack" runat="server" Text="Back" 
                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                            Width="200" Height="30"
                            Font-Bold="True" OnClick="ButtonBack_Click" />
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
                <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>Start</strong><br/><br/>" SortExpression="Start">
                      <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                      <ItemStyle HorizontalAlign="Center"></ItemStyle>                                    
                    <ItemTemplate>
                        <asp:Label ID="lblnameStartTime" runat="server"/>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <br />
                        <table>
                            <tr>
                                <td style="vertical-align:top">
                                    <asp:TextBox ID="TextBoxEditStartTime" runat="server" ValidationGroup="TimeEntries"></asp:TextBox>
                                    <asp:RegularExpressionValidator 
                                          ID="RegularExpressionEditValidatorStartTime" 
                                          runat="server" 
                                          ControlToValidate="TextBoxEditStartTime"
                                        ErrorMessage="<br/><font color='Red'>Invalid time format</font>"
                                        ValidationExpression="(^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([0-9]|0[0-9]|1[0-9]):[0-5][0-9] ([pP][mM]|[aA][mM])$)"
                                          ValidationGroup="TimeEntries"
                                          Display="Dynamic"></asp:RegularExpressionValidator>
                                      <asp:RequiredFieldValidator ID="RequiredFieldEditValidatorStartTime" 
                                          runat="server"
                                          ControlToValidate="TextBoxEditStartTime"
                                          ErrorMessage="<br/><font color='Red'>Start time is required</font>"
                                          ValidationGroup="TimeEntries"
                                          Display="Dynamic"></asp:RequiredFieldValidator>
                                </td>
                                <td style="vertical-align:top">
                                    <asp:ImageButton ID="ImageButtonStartTimeInfo" runat="server" ImageUrl="~/images/clockkpicker.png" CommandName="StartTimePickerToggle" />
                                </td>
                            </tr>
                        </table>
                        <br />
                        <asp:Panel ID="PanelPickStartTime" runat="server" Visible="false">
                            <table>
                                <tr>
                                    <th style="padding:10px">
                                        <strong style="font-weight:bold">Hours</strong><br />
                                    </th>
                                    <th style="padding:10px">
                                        <strong style="font-weight:bold">Minutes</strong><br />
                                    </th>
                                    <th style="padding:10px">
                                        <strong style="font-weight:bold">AM/PM</strong><br />
                                    </th>
                                </tr>
                                <tr>
                                    <td style="padding:10px">
                                        <asp:DropDownList ID="DropDownListBoxHoursStart" runat="server">
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
                                            <asp:ListItem Text="12" Value="12" Selected="True" />
                                        </asp:DropDownList>
                                    </td>
                                    <td style="padding:10px">
                                        <asp:DropDownList ID="DropDownListMinutesStart" runat="server">
                                            <asp:ListItem Text="00" Value="00" Selected="True" />
                                            <asp:ListItem Text="01" Value="01" />
                                            <asp:ListItem Text="02" Value="02" />
                                            <asp:ListItem Text="03" Value="03" />
                                            <asp:ListItem Text="04" Value="04" />
                                            <asp:ListItem Text="05" Value="05" />
                                            <asp:ListItem Text="06" Value="06" />
                                            <asp:ListItem Text="07" Value="07" />
                                            <asp:ListItem Text="08" Value="08" />
                                            <asp:ListItem Text="09" Value="09" />
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
                                    </td>
                                    <td style="padding:10px">
                                        <asp:DropDownList ID="DropDownListAMPMStart" runat="server">
                                            <asp:ListItem Text="AM" Value="AM" Selected="True" />
                                            <asp:ListItem Text="PM" Value="PM" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="padding:10px; text-align:center">
                                        <asp:Button ID="ButtonSelectStartTime" runat="server" Text="Select Time" Height="42px" Width="163px"
                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                            CommandName="SaveStartTime" Font-Bold="True" />

                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="<br/><strong style='font-weight:bold'>End</strong><br/><br/>" SortExpression="End">
                      <HeaderStyle Height="40px" Width="150px" HorizontalAlign="Center"></HeaderStyle>
                      <ItemStyle HorizontalAlign="Center"></ItemStyle>                                    
                    <ItemTemplate>
                        <asp:Label ID="lblnameEndTime" runat="server"/>
                    </ItemTemplate>
                    <EditItemTemplate>
                       <br />
                        <table>
                            <tr>
                                <td style="vertical-align:middle">
                                    <asp:TextBox ID="TextBoxEditEndTime" runat="server" ValidationGroup="TimeEntries"></asp:TextBox>
                                    <asp:RegularExpressionValidator 
                                        ID="RegularExpressionEditValidatorEndTime" 
                                        runat="server" 
                                        ControlToValidate="TextBoxEditEndTime"
                                        ErrorMessage="<br/><font color='Red'>Invalid time format</font>"
                                        ValidationExpression="(^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$)|(^([0-9]|0[0-9]|1[0-9]):[0-5][0-9] ([pP][mM]|[aA][mM])$)"
                                        ValidationGroup="TimeEntries"
                                        Display="Dynamic"></asp:RegularExpressionValidator>
                                  <asp:RequiredFieldValidator ID="RequiredFieldEditValidatorEndTime" 
                                      runat="server"
                                      ControlToValidate="TextBoxEditEndTime"
                                      ErrorMessage="<br/><font color='Red'>Start time is required</font>"
                                      ValidationGroup="TimeEntries"
                                      Display="Dynamic"></asp:RequiredFieldValidator>   
                                </td>
                                <td style="vertical-align:middle">
                                    <asp:ImageButton ID="ImageButtonStopTime" runat="server" ImageUrl="~/images/clockkpicker.png" CommandName="StopTimePickerToggle" />
                                </td>
                            </tr>
                        </table>
                        <br />
                        <asp:Panel ID="PanelPickStopTime" runat="server" Visible="false">
                            <table>
                                <tr>
                                    <th style="padding:10px">
                                        <strong style="font-weight:bold">Hours</strong><br />
                                    </th>
                                    <th style="padding:10px">
                                        <strong style="font-weight:bold">Minutes</strong><br />
                                    </th>
                                    <th style="padding:10px">
                                        <strong style="font-weight:bold">AM/PM</strong><br />
                                    </th>
                                </tr>
                                <tr>
                                    <td style="padding:10px">
                                        <asp:DropDownList ID="DropDownListStopHour" runat="server">
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
                                            <asp:ListItem Text="12" Value="12" Selected="True" />
                                        </asp:DropDownList>
                                    </td>
                                    <td style="padding:10px">
                                        <asp:DropDownList ID="DropDownListStopMinutes" runat="server">
                                            <asp:ListItem Text="00" Value="00" Selected="True" />
                                            <asp:ListItem Text="01" Value="01" />
                                            <asp:ListItem Text="02" Value="02" />
                                            <asp:ListItem Text="03" Value="03" />
                                            <asp:ListItem Text="04" Value="04" />
                                            <asp:ListItem Text="05" Value="05" />
                                            <asp:ListItem Text="06" Value="06" />
                                            <asp:ListItem Text="07" Value="07" />
                                            <asp:ListItem Text="08" Value="08" />
                                            <asp:ListItem Text="09" Value="09" />
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
                                    </td>
                                    <td style="padding:10px">
                                        <asp:DropDownList ID="DropDownListStopAMPM" runat="server">
                                            <asp:ListItem Text="AM" Value="AM" Selected="True" />
                                            <asp:ListItem Text="PM" Value="PM" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="padding:10px; text-align:center">
                                        <asp:Label ID="LabelStopTimeError" runat="server" ForeColor="#CC0000"></asp:Label>
                                        <asp:Button ID="ButtonSelectStopTime" runat="server" Text="Select Time" Height="42px" Width="163px"
                                            class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                            CommandName="SaveStopTime" Font-Bold="True" />
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <EditItemTemplate>
                         <br />
                         <table>
                              <tr>
                                   <td>
                                       <asp:HiddenField ID="HiddenFieldIDEdit" runat="server" Value='<%#Eval("id") %>' />
                                       <asp:Button ID="ButtonAddEdit" runat="server" CommandName="AddNew"  Text="Save" Width="100" Height="30" ValidationGroup="validaiton" Font-Bold="True"
                                       class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"/>
                                       <asp:Button ID="ButtonUpdate" runat="server" CommandName="Update"  Text="Update" Width="100" Height="30" ValidationGroup="validaiton" Font-Bold="True"
                                       class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                       />
                                       <asp:Button ID="ButtonCancel" runat="server" CommandName="Cancel"  Text="Cancel" Width="100" Height="30" Font-Bold="True"
                                       class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                       />
                                   </td>
                              </tr>
                        </table>
                    </EditItemTemplate>
                    <ItemTemplate>
                        <asp:HiddenField ID="lblnameStopStartId" runat="server" Value='<%#Eval("id") %>'/>
                        <asp:Button ID="ButtonEdit" runat="server" CommandName="Edit"  Text="Edit" Width="100" Height="30" Font-Bold="True" 
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                        />
                        <asp:Button ID="ButtonDelete" runat="server" CommandName="Delete"  Text="Delete" Width="100" Height="30" Font-Bold="True" 
                        class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                        />
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
        </div>
    </form>
