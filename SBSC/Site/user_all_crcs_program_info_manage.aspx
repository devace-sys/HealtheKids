<%@ Page Language="C#" CodeBehind="user_all_crcs_program_info_manage.aspx.cs" Inherits="Spedmon.userAllCRCSProgramInfoManage"%>

<Spedmon:DataEntryRows ID="save" runat="server" dataURL="crcs_program_info.asmx/save" useBootstrapFluid="true">

    <%//-----------------------------------------------------------------------------%>
    <%// Select Client %>
    <%// (Practi-Cal staff only) %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectClient
        ID                   = "selectClient" 
        entityControlID      = "clientid"                
        rowLabel             = "Client"
        dataEntryRowRenderAs = "FIELD"
        runat                = "server">
    </Spedmon:DataEntryRowSelectClient>
        
    <%//-----------------------------------------------------------------------------%>
    <%// Select Year %>
    <%//-----------------------------------------------------------------------------%>

    <Spedmon:DataEntryRowSelectFiscalYear
        ID                   = "selectFiscalYear" 
        entityControlID      = "fiscalyearid"                
        rowLabel             = "Year"
        dataEntryRowRenderAs = "FIELD"
        onSpedmonInputData   = "userInputCallback()"
        runat                = "server">
    </Spedmon:DataEntryRowSelectFiscalYear>

    <div class="font-weight-bold text-center mb-3">Please verify the top section of this tab</div>

    <div class="row mb-3">
        <div class="col-12 col-md-6 col-xl-3">
            <div class="font-weight-bold">Provider Name:&nbsp;<span><%=providerNameDisplay%></span></div>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <div class="font-weight-bold">Street Address 1:&nbsp;<span><%=providerAddress1Display%></span></div>
            <div class="font-weight-bold">Street Address 2:&nbsp;<span><%=providerAddress2Display%></span></div>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <div class="font-weight-bold">City:      &nbsp;<span><%=providerCityDisplay%></span></div>
            <div class="font-weight-bold">State, Zip:&nbsp;<span><%=providerStateZipDisplay%></span></div>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <div class="font-weight-bold">NPI Number:&nbsp;<span><%=providerNPIDisplay%></span></div>
            <div class="font-weight-bold">CDS Code:  &nbsp;<span><%=providerCDSDisplay%></span></div>
        </div>
    </div>

    <div class="mt-3 mb-3">
        <Spedmon:CheckBox ID="contactinfoverified" name="contactinfoverified" firedataselected="false" title="Review and update the contact information below." defaultValue="false" useDefaultValue="true" runat="server" />
        <span> Review and update the contact information below. Once correct, check this box.</span>
    </div>

    <div class="row">
        <div class="col-12 col-md-6 col-xl-3 d-flex align-items-center">
            <Spedmon:DataEntryRowSelectClientContact
                ID                   = "selectContactName" 
                entityControlID      = "contactid"                
                rowLabel             = "Contact Name"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = "populateContactInfo(e)"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClientContact>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxText ID="contacttitle" name="contacttitle" label="Title" title="Title" size="17" runat="server"/>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxEmail ID="contactemail" name="contactemail" label="Email" title="Email" size="17" runat="server"/>
        </div>
    </div>

    <div class="row">
        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxPhone ID="providerphone" name="providerphone" label="Phone" title="Provider Phone" size="17" runat="server"/>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxPhone ID="providerfax" name="providerfax" label="Fax" title="Provider Fax" size="17" runat="server"/>
        </div>
    </div>

    <div class="mt-3 mb-3">
        <Spedmon:CheckBox ID="personsigninginfoverified" name="personsigninginfoverified" firedataselected="false" title="Review and/or update the person signing the CRCS Report." defaultValue="false" useDefaultValue="true" runat="server" />
        <span> Review and/or update the person signing the CRCS Report. Once correct, check this box.</span>
    </div>

    <div class="row">
        <div class="col-12 col-md-6 col-xl-3 d-flex align-items-center">
            <Spedmon:DataEntryRowSelectClientContact
                ID                   = "selectCrcsBusinessOfficial" 
                entityControlID      = "crcsbusinessofficialid"                
                rowLabel             = "Business Official Signing CRCS"
                dataEntryRowRenderAs = "FIELD"
                onSpedmonInputData   = "populateBusinessOfficialInfo(e)"
                runat                = "server">
            </Spedmon:DataEntryRowSelectClientContact>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxText ID="crcsbusinessofficialtitle" name="crcsbusinessofficialtitle" label="Title" title="Business Official Signing CRCS Title" size="17" runat="server"/>
        </div>
    </div>

    <hr />

    <div class="mt-3">
        <Spedmon:CheckBox ID="consortiumbillinginfoverified" name="consortiumbillinginfoverified" firedataselected="false" title="Check when this section is complete" defaultValue="false" useDefaultValue="true" runat="server" />
        <span> Check when this section is complete.</span>
    </div>

    <div class="row">
        <div class="col-12 col-md-6">

            <Spedmon:DataEntryRow rowLabel="Consortium Billing" runat="server">
    
              <i id="butAddNewLEA" class="fa fa-plus m-2" title="Add New Row" onclick="addLEABOP();"></i>
                  
              <Spedmon:DataGrid 
                 ID             = "leabopconsortium" 
                 name           = "leabopconsortium"
                 title          = "LEA BOP Consortium"
                 classAssembly  = "Spedmon"
                 className      = "Spedmon.CrcsProgramInfoLEABOPConsortium"  
                 sortRowsByKey  = "false" 
                 showControls   = "false"
                 addRemoveButtonForEachBodyRow = "true"
                 runat          = "server"/>
             
            </Spedmon:DataEntryRow>

        </div>
    </div>

    <hr />

    <div class="mt-3 mb-3">
        <Spedmon:CheckBox ID="programinfoverified" name="programinfoverified" firedataselected="false" title="Check when this section is complete" defaultValue="false" useDefaultValue="true" runat="server" />
        <span> Check when this section is complete.</span>
    </div>

    <div class="font-weight-bold mt-2">MER</div>
    <div class="row populationCont">
        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxNumber ID="studentcensuspopulation" name="studentcensuspopulation" label="Student Census Population" title="Student Census Population" size="17" runat="server"/>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxNumber ID="medicaleligiblestudents" name="medicaleligiblestudents" label="Medi-Cal Eligible Students" title="Medi-Cal Eligible Students" size="17" runat="server"/>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <div class="d-flex align-items-center">
                <span class="mr-1">%</span>
                <Spedmon:DataEntryBoxText ID="mer" name="mer" label="MER" title="MER" size="16" runat="server"/>
            </div>
        </div>
    </div>

    <div class="font-weight-bold mt-2">ICR</div>
    <div class="row">
        <div class="col-12 col-md-6 col-xl-3">
            <div class="d-flex align-items-center">
                <span class="mr-1">%</span>
                <Spedmon:DataEntryBoxText ID="indirectcostrate" name="indirectcostrate" label="Indirect Cost Rate" title="Indirect Cost Rate" size="16" runat="server"/>
            </div>     
        </div>
    </div>

    <div class="font-weight-bold mt-2">Transportation</div>
    <div class="row">
        <div class="col-12 col-md-6 col-xl-4">
            <div class="font-weight-bold">Number of One-Way trips for Medi-Cal eligible students:&nbsp;<span><%=oneWayTripsMedicalStudentsDisplay%></span></div>
        </div>

        <div class="col-12 col-md-6 col-xl-4">
            <div class="font-weight-bold">Number of One-Way trips for all students:&nbsp;<span><%=oneWayTripsAllStudentsDisplay%></span></div>
        </div>
    </div>

    <div class="font-weight-bold mt-2">Enhanced FMAP</div>
    <div class="row mt-2">
        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxText ID="fmaptitlexix" name="fmaptitlexix" label="FMAP - Title XIX" title="FMAP - Title XIX" size="17" runat="server"/>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxText ID="fmaptitlexixenhanced" name="fmaptitlexixenhanced" label="FMAP - Title XIX Enhanced" title="FMAP - Title XIX Enhanced" size="17" runat="server"/>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxText ID="fmaptitlexxi" name="fmaptitlexxi" label="FMAP - Title XXI" title="FMAP - Title XXI" size="17" runat="server"/>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryBoxText ID="fmaptitlexxienhanced" name="fmaptitlexxienhanced" label="FMAP - Title XXI Enhanced" title="FMAP - Title XXI Enhanced" size="17" runat="server"/>
        </div>
    </div>

    <div class="font-weight-bold mt-2">RMTS Code 2A</div>
    <div class="row">
        <div class="col-12 col-md-6 col-xl-3">
            <div class="d-flex align-items-center">
                <span class="mr-1">%</span>
                <Spedmon:DataEntryBoxText ID="rmtscode2apercentage" name="rmtscode2apercentage" label="RMTS Code 2A percentage" title="RMTS Code 2A percentage" size="16" runat="server"/>
            </div>
        </div>
        <div class="col-12 col-md-6 col-xl-3 d-flex align-items-center">
            <Spedmon:DataEntryRowSelectLecOrLga
                ID                   = "selectLecOrLga" 
                entityControlID      = "lecorlgaid"                
                rowLabel             = "LEC / LGA"
                dataEntryRowRenderAs = "FIELD"
                runat                = "server">
            </Spedmon:DataEntryRowSelectLecOrLga>
        </div>
    </div>

    <div class="row mt-2">
        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryRow rowLabel="SMAA" runat="server">
                <Spedmon:SelectYesOrNo ID="smaa" name="smaa" title="SMAA?" renderLabel="false" runat="server" />
            </Spedmon:DataEntryRow>
        </div>

        <div class="col-12 col-md-6 col-xl-3">
            <Spedmon:DataEntryRow rowLabel="Costs included for practitioners with zero reimbursement" runat="server">
                <Spedmon:SelectYesOrNo ID="pracswithzeroreimbursementcosts" name="pracswithzeroreimbursementcosts" title="Costs included for practitioners with zero reimbursement?" renderLabel="false" runat="server" />
            </Spedmon:DataEntryRow>
        </div>
    </div>

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        editDelManageLink                = ""
        includeCancelButton              = "false"
        includeSaveAndProceedButton      = "false"
        includeSecondarySaveButton       = "true"
        secondarySaveButtonLabel         = "Save"
        secondarySaveButtonOnClick       = "saveChangesAndCheckCompletionStatus(e)"
        runat                            = "server">

    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//##################################################################################################################%>
<%//#                                         Data Management Scripts   %>
<%//##################################################################################################################%>

<script type="text/javascript">

    var keyCounter = 1;

    function populateContactInfo(e) {
        $('#contacttitle').val(e.dataitem.recData1);
        $('#contactemail').val(e.dataitem.recData2);
    }

    function populateBusinessOfficialInfo(e) {
        $('#crcsbusinessofficialtitle').val(e.dataitem.recData1);
    }

    function saveChangesAndCheckCompletionStatus(e) {
        $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', null, true);

        // invoke parent window's method to refresh the CRCS completion status
        try {
            parent.refreshCompletionStatus();
        } catch (e) { }
    }

    function generateNewKey() {
        var newKey = keyCounter;
        keyCounter = keyCounter + 1;
        return '' + newKey;
    }

    function addLEABOP() {
        var obj = $('#leabopconsortium').data('spedmondatagrid');

        var numRows = obj.getData().leabopconsortium.length;
        if (numRows != 0) {
            // update key counter (index of last row + 1)
            var lastRow = obj.getData().leabopconsortium[numRows - 1];
            keyCounter = parseInt(lastRow.idx) + 1;
        }
        var newKey = generateNewKey();

        obj.addRowByKey(newKey);
    }

    $(document).ready(function () {

        /* %MER = 100 * ( Medi-Cal eligible / All students ) */
        $('.populationCont').on('change', 'input', function (e) {

            let studentCensusPopulation = parseInt($('#studentcensuspopulation').val());
            let mediCalEligibleStudents = parseInt($('#medicaleligiblestudents').val());
            
            if (Number.isInteger(studentCensusPopulation) && Number.isInteger(mediCalEligibleStudents)
                && studentCensusPopulation != 0
                && studentCensusPopulation >= mediCalEligibleStudents) {
                let merVal = Math.round(100 * (mediCalEligibleStudents / studentCensusPopulation));
                $('#mer').val(merVal);
            }
        });

        // invoke parent window's method to refresh the CRCS completion status
        try {
            parent.refreshCompletionStatus();
        } catch (e) { }
    });

</script>