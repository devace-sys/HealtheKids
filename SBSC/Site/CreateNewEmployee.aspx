<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateNewEmployee.aspx.cs" Inherits="Spedmon.CreateNewEmployee" 
    MaintainScrollPositionOnPostback="true" %>
    <script type = "text/javascript">
        function Confirm() {
            var confirm_value = document.createElement("INPUT");
            confirm_value.type = "hidden";
            confirm_value.name = "confirm_value";
            if (confirm("Do you want to make the change?")) {
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
            <asp:HiddenField ID="HiddenFieldEmployeeID" runat="server" Value="0" />
            <asp:HiddenField ID="HiddenFieldPersonID" runat="server" Value="0" />
            <fieldset>
                <legend><strong style="font-weight: bold">Personal Information</strong></legend>
                <asp:panel runat="server" ID="PanelViewUserInfo">
                    <br />
                    <strong style="font-weight: bold">First Name : </strong>
                    <asp:Label ID="TextBoxFirstName" runat="server"></asp:Label><br />

                    <strong style="font-weight: bold">Last Name : </strong>
                    <asp:Label ID="TextBoxLastName" runat="server"></asp:Label><br />

                    <strong style="font-weight: bold">Spedmon User Name : </strong>
                    <asp:Label ID="TextBoxSpedMonUserName" runat="server"></asp:Label><br />
                </asp:panel>
                <asp:panel runat="server" ID="PanelAddUser">
                    <br />
                    <strong style="font-weight: bold">Select User to Add : </strong>
                    <asp:DropDownList runat="server" ID="DropDownListUsers"></asp:DropDownList>
                    <asp:Label runat="server" ID="LabelAddUserError" Text="" ForeColor="Red"></asp:Label>
                </asp:panel>
            </fieldset>
            <br /><br />
            <fieldset>
                <legend><strong style="font-weight: bold">Position Information</strong></legend>
                <br />

                <strong style="font-weight: bold">Role : </strong>
                <asp:DropDownList ID="DropDownListRole" runat="server"></asp:DropDownList><br /><br />
                <asp:Label runat="server" ID="LabelErrorAddRole" Text="" ForeColor="Red"></asp:Label>

                <strong style="font-weight: bold">Employee Status : </strong>
                <asp:DropDownList ID="DropDownListEmployeeStatus" runat="server">
                    <asp:ListItem Text="Active" Value="0" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="Terminated" Value="1" />
                    <asp:ListItem Text="Leave Of Absence" Value="1" />
                </asp:DropDownList><br /><br />

                <strong style="font-weight: bold">Organization : </strong>
                <asp:DropDownList ID="DropDownListOrganization" runat="server" AutoPostBack="True" OnSelectedIndexChanged="DropDownListOrganization_SelectedIndexChanged"></asp:DropDownList><br /><br />
                <asp:Label runat="server" ID="LabelAddErrorOrganization" Text="" ForeColor="Red"></asp:Label>

                <strong style="font-weight: bold">Position : </strong>
                <asp:DropDownList ID="DropDownListPosition" runat="server"></asp:DropDownList><br /><br />
                <asp:Label runat="server" ID="LabelAddErrorPosition" Text="" ForeColor="Red"></asp:Label>

                <strong style="font-weight: bold">Part Time : </strong>
                <asp:CheckBox ID="CheckBoxPartTime" runat="server" />
                &nbsp;&nbsp;&nbsp;&nbsp;
                <strong style="font-weight: bold">Exempt : </strong>
                <asp:CheckBox ID="CheckBoxExempt" runat="server" />
                &nbsp;&nbsp;&nbsp;&nbsp;
                <strong style="font-weight: bold">Salaried : </strong>
                <asp:CheckBox ID="CheckBoxSalaried" runat="server" />
                &nbsp;&nbsp;&nbsp;&nbsp;
                <strong style="font-weight: bold">Paid For Holidays : </strong>
                <asp:CheckBox ID="CheckBoxPaidForHolidays" runat="server" />
                <br /><br />


                <strong style="font-weight: bold">Hide From Payroll Report : </strong>
                <asp:CheckBox ID="CheckboxNoPayroll" runat="server" />
                <br /><br />


                <strong style="font-weight: bold">Start Date : </strong>
                <asp:textbox id="TextBoxSelectedStartDate" runat="server"></asp:textbox>
                &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="lnkpickdate" runat="server" OnClick="lnkpickstartdate_Click" ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px"></asp:ImageButton>
                &nbsp;&nbsp;&nbsp;<asp:Calendar ID="datepicker_start" runat="server" Visible="false" OnSelectionChanged="datepickerstart_SelectionChanged"></asp:Calendar>
                <asp:label ID="LiteralMessage" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
                <br />
                <asp:RequiredFieldValidator ID="RequiredFieldValidatorStartDate" runat="server" 
                    Display="Dynamic"
                    ErrorMessage="Start date is required<br/>"
                    Font-Bold="True" ForeColor="Red" ValidationGroup="CreateUpdateEmployee"
                    ControlToValidate="TextBoxSelectedStartDate"></asp:RequiredFieldValidator>

                <asp:Panel ID="PanelEndDate" runat="server">
                    <strong style="font-weight: bold">End Date : </strong>
                    <asp:textbox id="TextBoxSelectedEndDate" runat="server"></asp:textbox>
                    &nbsp;&nbsp;&nbsp;<asp:ImageButton ID="ImageButton1" runat="server" OnClick="lnkpickdateend_Click" ImageUrl="images/Calendar_scheduleHS.png" Height="19px" Width="21px"></asp:ImageButton>
                    &nbsp;&nbsp;&nbsp;<asp:Calendar ID="datepicker_end" runat="server" Visible="false" OnSelectionChanged="datepickerend_SelectionChanged"></asp:Calendar>
                    <asp:label ID="LiteralMessage2" runat="server" ForeColor="Red" Font-Bold="true" Text="" ></asp:label>
                </asp:Panel>
                <br />
                <strong style="font-weight: bold">Preferred personnel email address : </strong>
                <asp:textbox id="TextBoxEMail" runat="server" Width="336px"></asp:textbox>
                <br /><br />
                <strong style="font-weight: bold">Address : </strong>
                <asp:textbox id="TextBoxAddress" runat="server" Width="430px"></asp:textbox>
                <br /><br />
                <strong style="font-weight: bold">City : </strong>
                <asp:textbox id="TextBoxCity" runat="server" Width="430px"></asp:textbox>&nbsp;&nbsp;&nbsp;
                <strong style="font-weight: bold">State : </strong>
                <asp:dropdownlist runat="server" id="dropDownListState">
                    <asp:ListItem Value="AL">AL</asp:ListItem>
                    <asp:ListItem Value="AK">AK</asp:ListItem>
                    <asp:ListItem Value="AZ">AZ</asp:ListItem>
                    <asp:ListItem Value="AR">AR</asp:ListItem>
                    <asp:ListItem Selected="true" Value="CA">CA</asp:ListItem>
                    <asp:ListItem Value="CO">CO</asp:ListItem>
                    <asp:ListItem Value="CT">CT</asp:ListItem>
                    <asp:ListItem Value="DE">DE</asp:ListItem>
                    <asp:ListItem Value="DC">DC</asp:ListItem>
                    <asp:ListItem Value="FL">FL</asp:ListItem>
                    <asp:ListItem Value="GA">GA</asp:ListItem>
                    <asp:ListItem Value="HI">HI</asp:ListItem>
                    <asp:ListItem Value="ID">ID</asp:ListItem>
                    <asp:ListItem Value="IL">IL</asp:ListItem>
                    <asp:ListItem Value="IN">IN</asp:ListItem>
                    <asp:ListItem Value="IA">IA</asp:ListItem>
                    <asp:ListItem Value="KS">KS</asp:ListItem>
                    <asp:ListItem Value="KY">KY</asp:ListItem>
                    <asp:ListItem Value="LA">LA</asp:ListItem>
                    <asp:ListItem Value="ME">ME</asp:ListItem>
                    <asp:ListItem Value="MD">MD</asp:ListItem>
                    <asp:ListItem Value="MA">MA</asp:ListItem>
                    <asp:ListItem Value="MI">MI</asp:ListItem>
                    <asp:ListItem Value="MN">MN</asp:ListItem>
                    <asp:ListItem Value="MS">MS</asp:ListItem>
                    <asp:ListItem Value="MO">MO</asp:ListItem>
                    <asp:ListItem Value="MT">MT</asp:ListItem>
                    <asp:ListItem Value="NE">NE</asp:ListItem>
                    <asp:ListItem Value="NV">NV</asp:ListItem>
                    <asp:ListItem Value="NH">NH</asp:ListItem>
                    <asp:ListItem Value="NJ">NJ</asp:ListItem>
                    <asp:ListItem Value="NM">NM</asp:ListItem>
                    <asp:ListItem Value="NY">NY</asp:ListItem>
                    <asp:ListItem Value="NC">NC</asp:ListItem>
                    <asp:ListItem Value="ND">ND</asp:ListItem>
                    <asp:ListItem Value="OH">OH</asp:ListItem>
                    <asp:ListItem Value="OK">OK</asp:ListItem>
                    <asp:ListItem Value="OR">OR</asp:ListItem>
                    <asp:ListItem Value="PA">PA</asp:ListItem>
                    <asp:ListItem Value="RI">RI</asp:ListItem>
                    <asp:ListItem Value="SC">SC</asp:ListItem>
                    <asp:ListItem Value="SD">SD</asp:ListItem>
                    <asp:ListItem Value="TN">TN</asp:ListItem>
                    <asp:ListItem Value="TX">TX</asp:ListItem>
                    <asp:ListItem Value="UT">UT</asp:ListItem>
                    <asp:ListItem Value="VT">VT</asp:ListItem>
                    <asp:ListItem Value="VA">VA</asp:ListItem>
                    <asp:ListItem Value="WA">WA</asp:ListItem>
                    <asp:ListItem Value="WV">WV</asp:ListItem>
                    <asp:ListItem Value="WI">WI</asp:ListItem>
                    <asp:ListItem Value="WY">WY</asp:ListItem>
                </asp:dropdownlist>&nbsp;&nbsp;&nbsp;
                <strong style="font-weight: bold">ZipCode : </strong>
                <asp:textbox id="TextBoxZipCode" runat="server" Width="152px"></asp:textbox>&nbsp;&nbsp;&nbsp;
                <asp:RegularExpressionValidator 
                        ID="RegularExpressionEditValidatorZipCode" 
                        runat="server" 
                        ControlToValidate="TextBoxZipCode"
                    ErrorMessage="<br/><font color='Red'>Valid Zipcode format is either NNNNN or NNNNN-NNNN</font>"
                    ValidationExpression="(^[0-9][0-9][0-9][0-9][0-9]$)|(^[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]$)|(^$)"
                        ValidationGroup="CreateUpdateEmployee"
                        Display="Dynamic"></asp:RegularExpressionValidator>
                <br /><br />
                <strong style="font-weight: bold">Phone Number : </strong>
                <asp:textbox id="TextBoxPhoneNumber" runat="server" Width="152px"></asp:textbox>&nbsp;&nbsp;&nbsp;
                <asp:RegularExpressionValidator 
                        ID="RegularExpressionValidatorPhoneNumber" 
                        runat="server" 
                        ControlToValidate="TextBoxPhoneNumber"
                    ErrorMessage="<br/><font color='Red'>Invalid Phone number format NNN-NNN-NNNN</font>"
                    ValidationExpression="^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$"
                        ValidationGroup="CreateUpdateEmployee"
                        Display="Dynamic"></asp:RegularExpressionValidator>
            </fieldset>
            <br /><br />
                <asp:Button ID="ButtonUpdate" runat="server" Text="Update Employee" ValidationGroup="CreateUpdateEmployee"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonUpdate_Click"
                    OnClientClick="Confirm()"  />
                <asp:Button ID="ButtonAdd" runat="server" Text="Add Employee" ValidationGroup="CreateUpdateEmployee"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonAdd_Click"
                    OnClientClick="Confirm()"/>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <asp:Button ID="ButtonBack" runat="server" Text="Back"
                    class="ui-spedmon-box-inline-ctrl ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"
                    Width="200" Height="30" Font-Bold="True" OnClick="ButtonBack_Click"/>
        </div>
    </form>
