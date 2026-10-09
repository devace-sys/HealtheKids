<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AutoTaskStopStart.aspx.cs" Inherits="Spedmon.AutoTaskStopStart" %>
<script type = "text/javascript">
    function ConfirmScheduleUpdate()
    {
        var confirm_update = document.createElement("INPUT");
            confirm_update.type = "hidden";
            confirm_update.name = "confirm_update";
            if (confirm("Do you want to update?"))
            {
                confirm_update.value = "Yes";
            }
            else
            {
                confirm_update.value = "No";
                location.reload(true);
            }
            document.forms[0].appendChild(confirm_update);
    }
</script>
<style>
    tr.alternate {
        background-color: #E3EAEB;
    }
</style>
<form id="form1" runat="server">
    <div style="margin-left: 50px">
        <asp:HiddenField runat="server" ID="HiddenFieldTaskId"></asp:HiddenField>
        <asp:HiddenField runat="server" ID="HiddenFieldDay"></asp:HiddenField>
        <asp:HiddenField runat="server" ID="HiddenFieldEmployeeId"></asp:HiddenField>
        <asp:HiddenField runat="server" ID="HiddenFieldTemplateID"></asp:HiddenField>
        
        <div>
            <h1>Auto Task Start and Stop Hours </h1>
            <br /><br />
            <asp:Button runat="server" ID="ButtonAdd" Width="100" Height="50" Text="Add" OnClick="ButtonAdd_Click"
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"></asp:Button>
            <br/><br/>
            <asp:Repeater runat="server" ID="repeaterTaskStartStopTemplateControl">
                <HeaderTemplate>
                    <table>
                        <thead style="background-color: #9FC6CB">
                            <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <strong style="font-weight: bold">Start Time</strong>
                            </th>
                            <th style="padding-right:10px; padding-top:10px; padding-bottom:10px">
                                <strong style="font-weight: bold">Stop Time</strong>
                            </th>
                            <th style="padding-left:10px; padding-right:10px; padding-top:10px; padding-bottom:10px; font-weight: bold">Action</th>
                        </thead>
                </HeaderTemplate>
                <ItemTemplate>
                    <tbody>
                        <tr class="<%# Container.ItemIndex % 2 == 0 ? "alternate" : "" %>">
                            <td style="vertical-align: top; white-space: nowrap">
                                <asp:Label runat="server" ID="labelBoxStartTime" Text='<%#Eval("startTime") %>'></asp:Label>
                                &nbsp;&nbsp;&nbsp;
                                <asp:ImageButton ID="ImageButtonStartTime" runat="server" 
                                    ImageUrl="~/images/clockkpicker.png" 
                                    OnClick="ImageButtonStartTime_Click" /> 
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
                                                    Font-Bold="True" OnClick="ButtonSelectStartTime_Click"/>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                            <td style="vertical-align: top">
                                <asp:Label runat="server" ID="labelBoxStopTime" Text='<%#Eval("stopTime") %>'></asp:Label>
                                &nbsp;&nbsp;&nbsp;
                                <asp:ImageButton ID="ImageButtonStopTime" runat="server" 
                                    ImageUrl="~/images/clockkpicker.png" 
                                    OnClick="ImageButtonStopTime_Click" /> 
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
                                                <asp:DropDownList ID="DropDownListBoxHoursStop" runat="server">
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
                                                <asp:DropDownList ID="DropDownListMinutesStop" runat="server">
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
                                                <asp:DropDownList ID="DropDownListAMPMStop" runat="server">
                                                    <asp:ListItem Text="AM" Value="AM" Selected="True" />
                                                    <asp:ListItem Text="PM" Value="PM" />
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="padding:10px; text-align:center">
                                                <asp:Button ID="ButtonSelectStopTime" runat="server" Text="Select Time" Height="42px" Width="163px"
                                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                                    Font-Bold="True" OnClick="ButtonSelectStopTime_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                            <td style="vertical-align: top; white-space: nowrap">
                                <asp:Button runat="server" ID="ButtonDelete" Width="100" Text="Delete" 
                                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                                    OnClick="ButtonDelete_Click"></asp:Button>
                            </td>
                        </tr>
                    </tbody>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
            <br/><br/>
            <asp:Button ID="BackToTaskTemplate" runat="server" Text="Back to Task Template" Height="42px"
                class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                Font-Bold="True" OnClick="ButtonBackToTaskTemplate_Click"/>
            <br/><br/>
            <asp:Label runat="server" ID="labelMessage" Text="Label" Font-Bold="True" ForeColor="Red"></asp:Label>
        </div>
    </div>
</form>
