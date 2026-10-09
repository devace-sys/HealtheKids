<%@ Page Language="C#" CodeBehind="user_all_prac_save.aspx.cs" Inherits="Spedmon.UserAllPractitionerSave" %>



<Spedmon:DataEntryRows ID="save" dataURL="practitioners.asmx/save" useBootstrapFluid="true" runat="server" >
    <Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server"/>

<%/************************************* Client **********************************/%>
    
<Spedmon:DataEntryRow ID="clientidDataEntryRow" rowLabel="Select a Client <span class='requiredField'></span>" runat="server">

  <Spedmon:ComboBox 
                ID="clientid" 
                name="clientid" 
                title="Select Client" 
                dataPrivate="true" 
                dataURL="clients.asmx/viewSel" 
                onSelect="checkReqFields()"
                runat="server" />
</Spedmon:DataEntryRow>

<div class="row" >

<%/************************************* Practitioner Name (Req) **********************************/%>


<div class="col-6">
  <div class="ui-spedmon-data-entry-row row">
  <div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label">
    <h5 class="mr-2">Enter Practitioner<br />Name</h5>
  </div>
  <div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry">
    <Spedmon:DataEntryBoxText  ID="lname" name="lname" label="Last Name" title="Please enter the practitioners last name" required="true" runat="server"/>
    <Spedmon:DataEntryBoxText  ID="fname" name="fname" label="First Name" title="Please enter the practitioners first name" required="true" runat="server"/>
  </div>
  </div> <!-- data entry row -->
</div> <!-- col -->

<%/************************************* NPI Lookup **********************************/%>

<div id="npi-searchcol" class="col-6">
  <div class="ui-spedmon-data-entry-row row">
  <div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label">
    <h5 class="mr-2">National Provider<br />Registry Search</h5>
  </div>
  <div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-entry">
    <select class="mx-1" id="npi-search-using" title="Search registry using">
      <option value="name" >Last Name, First Name</option>
      <option value="npi" >NPI Number</option>
    </select>
    <input class="mx-1" id="npi-search-value" type="search"/>
    <button class="btn btn-primary btn-sm mx-1" id="npi-search-start" type="button">Search NPI Registry</button>
  </div>
  </div> 
</div> <!-- col -->
</div> <!-- row -->

<div class="row">  
<div  class="col-12">
    <div id="practabs" >

        <ul>
            <li><a href = "#tab-profile">Profile</a></li>
            <li><a href = "#tab-qualification">Qualifications</a></li>
            <li><a href = "#tab-orp-status">NPI & ORP Status</a></li>
            <li><a href = "#tab-claims-status">Claims Status</a></li>
            <li><a href = "#tab-sites">Sites</a></li>
            <li><a href = "#tab-notes">Notes</a></li>
        </ul>

        <%/****************************
         * Profile tab
         ****************************/%>

        <div id="tab-profile">
            

            <%/************************************* Employment Relationship (Req) **********************************/%>
  
            <Spedmon:DataEntryRow ID="prac_emp_relDataEntryRow" rowLabel="Current/Last Relationship With District" runat="server">
                
                <Spedmon:FieldSetEmploymentRelationship 
                    ID                 = "prac_emp_rel" 
                    parmNameEmployeeId = "clientEmployeeID"
                    parmNameStartDate  = "startDate"
                    parmNameEndDate    = "endDate"
                    includeOKButton    = "false" 
                    includeLegend      = "false" 
                    runat              = "server" /> 
                               
             
            </Spedmon:DataEntryRow>

            <Spedmon:DataEntryRow ID="deptHeadDataEntryRow" rowLabel="" runat="server">


                <Spedmon:SelectYesOrNo 
                    id="currentlyWithClient" 
                    name="currentlywithclient" 
                    title="Currently With District?" 
                    renderLabel="true" 
                    runat="server" />


                <Spedmon:SelectYesOrNo 
                    id="deptHead" 
                    name="deptHead" 
                    title="Department Head?<br><sup>Please Note: Department Heads are Limited to Their Practice Family and Reporting Group</sup> " 
                    renderLabel="true" 
                    onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                    runat="server" />

                <Spedmon:SelectYesOrNo
                    id    = "deptheadcanseeentirepracticefamilyindeptreviewreports"
                    name  = "deptheadcanseeentirepracticefamilyindeptreviewreports"
                    title = "Department Head Can View Entire Practice Family In Department Review Reports?<br><sup>Please Note: By default, Department Heads are limited to their own reporting group.  By selecting YES, they will be able to see all reporting groups in their practice family.</sup>"
                    onSelectValue = "function(oldval,newval){checkReqFields(); return true;}"
                    runat         = "server"/>

                <Spedmon:SelectYesOrNo 
                    id="displaypercent" 
                    name="displaypercent" 
                    title="Display <b>%</b>" 
                    renderLabel="true" 
                    runat="server" />

                <Spedmon:SelectYesOrNo 
                    id="displaymoney" 
                    name="displaymoney" 
                    title="Display <b>$</b>" 
                    renderLabel="true" 
                    runat="server" />

            </Spedmon:DataEntryRow>            
            
             <%/************************************* Previous Employment Relationships **********************************/%>
  
            <Spedmon:DataEntryRow ID="prac_emp_rel_prev_DataEntryRow" rowLabel="Previous Relationships With District" runat="server">

               <div><%=pracEarliestLatestServiceDatesSummary%></div>
               <br />
               <div id="restViewEmploymentRelationships"></div>
            
            </Spedmon:DataEntryRow>

            <%/************************************* Contact **********************************/%>
  
            <Spedmon:DataEntryRow rowLabel="Current Contact Data" runat="server">            
            
              <Spedmon:DataEntryBoxEmail ID="email" name="email" label="Email" title="Enter email adddress" runat="server" />
              <Spedmon:DataEntryBoxPhone ID="phone" name="phone" label="Phone" title="Enter phone Number" runat="server" />
              <Spedmon:DataEntryBoxPhone ID="fax" name="fax" label="Fax" title="Enter fax number" runat="server" />

              <Spedmon:FieldSetUSPSAddress 
                ID                 = "prac_prof_address" 
                includeOKButton    = "false" 
                includeLegend      = "false" 
                runat              = "server" />
             
            </Spedmon:DataEntryRow>
            
                
        </div>

        <%/****************************
         * Qualifications tab
         ****************************/%>

        <div id="tab-qualification">

            <%/************************************* Spedcare Role (Req) **********************************/%>
  
            <Spedmon:DataEntryRow rowLabel="Select the SpEdCare role <span class='requiredField'></span>" runat="server">
                <Spedmon:ComboBox 
                    ID          = "groupdisp" 
                    name        = "groupdisp" 
                    title       = "Select Role" 
                    dataPrivate = "true" 
                    dataURL     = "groups.asmx/viewSelDisp" 
                    dataParms   = "[{}]" 
                    onSelect    ="checkReqFields()"
                    runat       = "server" />
            </Spedmon:DataEntryRow>

            <%/************************************* Qualifications **********************************/%>
  
            <Spedmon:DataEntryRow rowLabel="Select Practitioner Qualification(s)" runat="server">
                <Spedmon:ComboBox 
                    ID          = "qualificationSel" 
                    name        = "qualificationSel" 
                    title       = "Select Type" 
                    dataPrivate = "true" 
                    dataURL     = "groups.asmx/viewSelDisp" 
                    dataParms   = "[{}]" 
                    onSelect    = "addQualification(event,ui)"
                    runat       = "server" />
            </Spedmon:DataEntryRow>

            <div id="qualifDirections">Use the Select Practitioner Qualification(s) field above to add multiple qualifications for this practitioner</div>

            <%//-----------------------------------------------------------------------------%>
            <%// Enter Details %>
            <%//-----------------------------------------------------------------------------%>
                            
           <Spedmon:HiddenTextArea ID="qualificationsJSONData" name="qualificationsJSONData" title="qualificationsJSONData" runat="server" /> 
           
           <table id="tblRecsQualificationJSON">
               <thead>
                 <tr>
                   <th></th>
                   <th>Qualification</th>
                   <th>License Credential Number</th>
                   <th>Issuance Date</th>
                   <th>Expiration Date</th>
                   <th>Full Name</th>
                   <th>Qualification Is Lifetime</th>
                 </tr>
               </thead>
               <tbody id="tblRecsQualificationJSONBody">
               </tbody>
            </table>

            <%/************************************* CPR Training **********************************/%>
  
            <Spedmon:DataEntryRow rowLabel="CPR Training" runat="server">
                <label class="mba-web-ui mba-web-ui-inline" for="cprCertEffectiveDate">Training Date</label>
                <Spedmon:DateBoxHTML5 ID="cprCertEffectiveDate" name="cprCertEffectiveDate" title="Start Date for CPR Training" runat="server" />
                
                <label class="mba-web-ui mba-web-ui-inline" for="cprCertExpirationDate">End Date</label>
                <Spedmon:DateBoxHTML5 ID="cprCertExpirationDate" name="cprCertExpirationDate" title="End Date for CPR Training" runat="server" />
            </Spedmon:DataEntryRow>

            <%/************************************* ACES Certification **********************************/%>
  
            <Spedmon:DataEntryRow rowLabel="ACEs Certification" runat="server">
                <Spedmon:DataEntryBoxDate ID="acescertcompletedon" name="acescertcompletedon" label="Succesfully Completed On" size="15" runat="server" />
            </Spedmon:DataEntryRow>

            <%/************************************* Reporting Group **********************************/%>
  
            <Spedmon:DataEntryRow ID="groupreptDataEntryRow" rowLabel="Select the practitioner's reporting group" runat="server">
                <Spedmon:ComboBox 
                    ID            = "grouprept" 
                    name          = "grouprept" 
                    title         = "Select Reporting Group"
                    displayInline = "true"
                    dataPrivate   = "true" 
                    dataURL       = "groups.asmx/viewSelRept" 
                    dataParms     = "[{id:'clientid'}]" 
                    runat         = "server" />
            </Spedmon:DataEntryRow>

            <Spedmon:DataEntryRow rowLabel="DOB, Gender, and SSN<br><sup>Please note that DOB, Gender, and SSN are required for CYBHI qualifications verification.</sup>" runat="server">

              <div class="d-flex">
                <Spedmon:DataEntryBoxDate ID="dob" name="dob" label="Date of Birth (DOB)" title="Select or Enter Date of Birth" runat="server" />
                <Spedmon:SelectMaleOrFemale ID="gender" name="gender" title="Select Gender" runat="server" />
                <Spedmon:DataEntryBoxText ID="ssn" name="ssn" label="Social Security Number (SSN)" title="Enter SSN" size="13" runat="server"/>
              </div>
            
            </Spedmon:DataEntryRow>
            
            <%/************************************* DOB, Gender and SSN **********************************/%>
            
           <Spedmon:DataEntryRow rowLabel="CYBHI Discipline (Degree) Code and Speciality Code" runat="server">

  <div class="cybhi-degree-grid">

    <div class="cybhi-field">
      <Spedmon:DataEntryBoxSelect ID="cybhidegreecode" name="cybhidegreecode" label="CYBHI Primary Degree" title="Select Code" runat="server"/>
    </div>

    <div class="cybhi-field">
      <Spedmon:DataEntryBoxSelect ID="cybhidegreecode2" name="cybhidegreecode2" label="CYBHI Degree 2" title="Select Code" runat="server"/>
    </div>

    <div class="cybhi-field">
      <Spedmon:DataEntryBoxSelect ID="cybhidegreecode3" name="cybhidegreecode3" label="CYBHI Degree 3" title="Select Code" runat="server"/>
    </div>

  </div>

  <div class="cybhi-specialty-grid">

    <div class="cybhi-field">
      <Spedmon:DataEntryBoxSelect ID="cybhispecialtycode" name="cybhispecialtycode" label="CYBHI Primary Speciality" title="Select Code" runat="server"/>
    </div>

    <div class="cybhi-field">
      <Spedmon:DataEntryBoxSelect ID="cybhispecialtycode2" name="cybhispecialtycode2" label="CYBHI Speciality 2" title="Select Code" runat="server"/>
    </div>

    <div class="cybhi-field">
      <Spedmon:DataEntryBoxSelect ID="cybhispecialtycode3" name="cybhispecialtycode3" label="CYBHI Speciality 3" title="Select Code" runat="server"/>
    </div>

    <div class="cybhi-field">
      <Spedmon:DataEntryBoxSelect ID="cybhispecialtycode4" name="cybhispecialtycode4" label="CYBHI Speciality 4" title="Select Code" runat="server"/>
    </div>

  </div>

</Spedmon:DataEntryRow>

        </div>

        <%/****************************
         * ORP Status tab
         ****************************/%>

        <div id="tab-orp-status">

            <%/************************************* NPI **********************************/%>
  
            <Spedmon:DataEntryRow rowLabel="Enter National Provider ID (NPI)" runat="server">
                <Spedmon:FieldSetNPI id="prac_npi" includeOKButton="false"  includeLegend="false" runat="server"/>
            </Spedmon:DataEntryRow>

            <%/************************************* Prac is Valid (Req) **********************************/%>
  
            <Spedmon:DataEntryRow rowLabel="Is a Valid Medi-Cal ORP & Date ORP Status Last Validated? <span class='requiredField'></span>" runat="server">
                
                <div class="d-flex">
                    <Spedmon:SelectYesOrNoOrUnknown 
                        ID="is_valid_mcal_orp" 
                        name="is_valid_mcal_orp" 
                        title="Is Valid ORP" 
                        renderLabel="false" 
                        onSelectValue="function(oldval,newval){checkReqFields(); return true;}" 
                        runat="server" />
                    <Spedmon:DateBoxHTML5 ID="is_valid_mcal_orp_last_validated" name="is_valid_mcal_orp_last_validated" title="Date ORP Last Validated" runat="server" />

                    <a class="mba-web-ui-link-external ml-1" title="Click here to open the CalHHS Enrolled Medi-Cal Fee-for-Service (FFS) Providers dataset search and export page." href="https://data.chhs.ca.gov/dataset/profile-of-enrolled-medi-cal-fee-for-service-ffs-providers/resource/d652b210-ec3d-4a92-b7e0-e55c3dcbc7dc" target="_blank">Cal HHS Enrolled Medi-Cal Fee-for-Service (FFS) Providers Search</a>
                </div>

                
            </Spedmon:DataEntryRow>



        </div>

        <%/****************************
         * Claims Status tab
         ****************************/%>

        <div id="tab-claims-status">

            <%/************************************* Financial Reports (Req) **********************************/%>
  
            <Spedmon:DataEntryRow ID="inc_in_fin_reptsDataEntryRow" rowLabel="Include in LEA BOP financial Reports? <span class='requiredField'></span>" runat="server">
                <Spedmon:SelectYesOrNo 
                    id="inc_in_fin_repts" 
                    name="inc_in_fin_repts" 
                    title="inc_in_fin_repts?" 
                    renderLabel="false" 
                    onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                    runat="server" />
            </Spedmon:DataEntryRow>

            <%/************************************* Participates in LEA BOP? (Req) **********************************/%>
              
            <Spedmon:DataEntryRow ID="participatesinleabopDataEntryRow" rowLabel="Show LEA BOP SpEd Services in SpEdCare? <span class='requiredField'></span>" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNo 
                        ID="participatesinleabop" 
                        name="participatesinleabop" 
                        title="participatesinleabop"
                        renderLabel="false" 
                        onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                        runat="server" />
                    
                </div>
            </Spedmon:DataEntryRow>

            <Spedmon:DataEntryRow ID="participatesinleabopnonspedDataEntryRow" rowLabel="Show LEA BOP Non SpEd Services in SpEdCare? <span class='requiredField'></span>" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNo 
                        ID="participatesinleabopnonsped" 
                        name="participatesinleabopnonsped" 
                        title="participatesinleabopnonsped"
                        renderLabel="false" 
                        onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                        runat="server" />                    
                </div>
            </Spedmon:DataEntryRow>

            <%/************************************* Participates in CYBHI? (Req) **********************************/%>
  
            <Spedmon:DataEntryRow ID="participatesincyhbiRow" rowLabel="Show CYBHI Services in SpEdCare? <span class='requiredField'></span>" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNo 
                        ID="participatesincyhbi" 
                        name="participatesincyhbi" 
                        title="participatesincyhbi"
                        renderLabel="false" 
                        onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                        runat="server" />
                    
                </div>
            </Spedmon:DataEntryRow>
           
            <%/************************************* Participates in RU Health? (Req) **********************************/%>
  
            <Spedmon:DataEntryRow ID="participatesinruhealthRow" rowLabel="Show RU Health Services in SpEdCare? <span class='requiredField'></span>" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNo 
                        ID="participatesinruhealth" 
                        name="participatesinruhealth" 
                        title="participatesinruhealth"
                        renderLabel="false" 
                        onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                        runat="server" />
                    
                </div>
            </Spedmon:DataEntryRow>
            <%/************************************* Submit Claims LEA BOP (Req) **********************************/%>
  
            <Spedmon:DataEntryRow ID="submitclaimsDataEntryRow" rowLabel="Submit Claims for the LEA BOP? <span class='requiredField'></span>" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNo 
                        ID="submitclaims" 
                        name="submitclaims" 
                        title="submitclaims"
                        renderLabel="false" 
                        onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                        runat="server" />
                    <Spedmon:DateBoxHTML5 ID="submitClaimsEffectiveDate" name="submitClaimsEffectiveDate" title="Submit Claims Effective Date" runat="server" />
                </div>
            </Spedmon:DataEntryRow>

            <%/************************************* TCM (Req) **********************************/%>
  
    <Spedmon:DataEntryRow ID="claim_TCMDataEntryRow" 
        rowLabel="Submit LEA BOP Claims for TCM? (If YES, enter the date of the agency approved case management training. If NO, select today's date) <span class='requiredField'></span>"
        runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNoOrUnknown 
                        ID="claim_TCM"
                        name="claim_TCM" 
                        title="claim_TCM"
                        renderLabel="false"
                        onSelectValue="function(oldval,newval){checkReqFields(); return true;}"
                        runat="server" />
                    <Spedmon:DateBoxHTML5 ID="claim_TCMEffectiveDate" name="claim_TCMEffectiveDate" title="TCM Effective Date" runat="server" />
                </div>
            </Spedmon:DataEntryRow>

            <%/************************************* CYBHI TPA Approved **********************************/%>
            
             <Spedmon:DataEntryRow ID="cybhiTpaApprovedRow"  rowLabel="CYBHI TPA Approved:" runat="server">
               <Spedmon:SelectYesOrNo ID="cybhitpaapproved" name="cybhitpaapproved" title="CYBHI TPA Approved" renderLabel="false" runat="server" />
             </Spedmon:DataEntryRow>
                
           <%/************************************* CYBHI TPA Approved On **********************************/%>
            <Spedmon:DataEntryRow ID="cybhiTpaApprovedOnRow" rowLabel="CYBHI TPA Approved On:" runat="server">
               <Spedmon:DataEntryBoxDate  ID="cybhitpaapprovedon" name="cybhitpaapprovedon" title="CYBHI TPA Approved On"  runat="server" />
           </Spedmon:DataEntryRow>

            <%/************************************* CYBHI TPA ID **********************************/%>

            <Spedmon:DataEntryRow ID="cybhiTpaIDRow"  rowLabel="CYBHI TPA ID:" runat="server">
               <Spedmon:DataEntryBoxText ID="cybhitpaid" name="cybhitpaid"  title="CYBHI TPA ID" runat="server" />
           </Spedmon:DataEntryRow>

            <%/************************************* CYBHI CLAIMS **********************************/%>

            <Spedmon:DataEntryRow rowLabel="Submit CYBHI Claims? <br><sub>(Only set to No if client is participating in CYBHI and we need to hold all CYBHI claims for this practitioner.</sub>" runat="server">
                <Spedmon:SelectYesOrNo ID="cybhisubmitclaims" name="cybhisubmitclaims" title="Submit CYBHI Claims?" renderLabel="false" runat="server" />
            </Spedmon:DataEntryRow>

        
        </div>


        <%//=============================================================================%>
        <%//                      Sites tab %>
        <%//=============================================================================%>

        <div id="tab-sites">
           <div class="container-fluid">
                <div class="row">
                    <div id="dataManagementRowsForSites" class="col-12">
                        <div id="restViewSites" class="rest-view-display-minimal"></div>
                    </div> <!-- col -->
                </div> <!--row -->
            </div>
        </div>


        <%/****************************
         * Notes tab
         ****************************/%>

        <div id="tab-notes">

            <%/************************************* Notes **********************************/%>
  
            <Spedmon:TextAreaBox ID="notes" name="notes" title="Enter notes" runat="server"></Spedmon:TextAreaBox>

        </div>

     </div> <!-- tabs -->
</div> <!-- col -->          
</div> <!-- row -->

  <%/************************************* Save or Edit **********************************/%>

    <Spedmon:DataEntryRowSaveOrEdit 
        ID                               = "saveOrEdit"
        editDelManageLink                = "editdelpracrecslink"
        includeSaveAndProceedButton      = "false"
        includeSecondarySaveButton       = "true"
        secondarySaveButtonLabel         = "Save & Proceed"
        secondarySaveButtonOnClick       = "navigateBasedOnSaveType(e)"
        runat                            = "server">

    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%/****************************
  * Scripts for options
  ****************************/%>
  
<script type="text/javascript">

    var $restViewEmploymentRelationships = null;

    // array of fields that are required
    var requiredFields = ['clientid', 'lname', 'fname', 'groupdisp'
        , 'is_valid_mcal_orp', 'inc_in_fin_repts', 'submitclaims', 'submitClaimsEffectiveDate'
        , 'claim_TCM', 'claim_TCMEffectiveDate'];


    // onClick for the save button: navigate the user based on saveType
    function navigateBasedOnSaveType(e) {
        if ('<%=saveType%>' == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
     
            // if new client, just load the edit screen
            var url = '<%=pracSaveURL%>';

            var fnGoPracEdit = function (rd) {
                // this is the code that launches the authorize record screen
                var pracEditUrl = url
                    + '&recid=' + rd.recordID
                    + '&savetype=' + $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT;
                $.spedmonWebUI.gotoURL(pracEditUrl);
            };
            $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', fnGoPracEdit, true);

        }
        else {

            // if editing prac, stay on the page
            $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', null, false);

        }
    }

    function initRestViewEmployementRelationships() {
        let opts = {};

        opts.sessionTimeOutUrl  = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad  = false;
        opts.enableSortControls = false;
        opts.enableRowNumbers   = false;
        opts.enableRowControls  = true;

        opts.enableRowControlShowAdditionalInfo = false;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit   = true;
        opts.enableRowControlRecDelete = true;

        opts.loadModeView               = 'rest';
        opts.baseUrlView                = '<%=practitionerEmploymentRelationshipUrlView%>';
        opts.baseUrlViewHasParameters   = true;
        opts.defaultPageRowOrder        = '<%=Spedmon.PractitionerEmploymentRelationship.DEFAULT_PAGING_ORDER%>';
        opts.enableReports              = false

        opts.saveModeAddNew             = 'inline';
        opts.baseUrlAddNew              = '<%=practitionerEmploymentRelationshipUrlSave%>';
        opts.baseUrlAddNewHasParameters = true;
        opts.recIDNameForAddNew         = 'recid';
        opts.saveTypeNameForAddNew      = 'savetype';
        opts.saveTypeValueForAddNew     = '1';

        opts.saveModeEdit               = 'inline';
        opts.baseUrlEdit                = '<%=practitionerEmploymentRelationshipUrlSave%>';
        opts.baseUrlEditHasParameters   = true;
        opts.recIDNameForEdit           = 'recid';
        opts.saveTypeNameForEdit        = 'savetype';
        opts.saveTypeValueForEdit       = '2';

        opts.saveModeDelete             = 'inline';
        opts.baseUrlDelete              = '<%=practitionerEmploymentRelationshipUrlDelete%>';
        opts.baseUrlDeleteHasParameters = true;
        opts.recIDNameForDelete         = 'recid';
        opts.saveTypeNameForDelete      = 'savetype';
        opts.saveTypeValueForDelete     = '3';

        opts.additionalInfoFieldDefinitions = [];

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        let employeeRelationshipIDFieldOptions = {};
        employeeRelationshipIDFieldOptions.selections = <%=Spedmon.PractitionerEmploymentRelationships.generateEmploymentRelationshipSelectionNvpString()%>;

        opts.fieldDefinitions.push({
            name: 'employeeRelationshipID'
            , label: 'Previous Employment Relationship'
            , toolTip: 'Previous Employment Relationship'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: employeeRelationshipIDFieldOptions
            , sortUsing: 'clientName'
            , saveUsing: 'employmentrelationshipid'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'startDateYYYYMMDDStr'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , saveUsing:'startdate'
            , dataType: 'date'
        });

        opts.fieldDefinitions.push({
            name: 'endDateYYYYMMDDStr'
            , label: 'End Date'
            , toolTip: 'End Date'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , saveUsing: 'enddate'
            , dataType: 'date'
        });

        opts.fieldDefinitions.push({
              name: 'notes'
            , label: 'Notes or Comments'
            , toolTip: 'Notes or Comments'
            , visible: true
            , editable: true
            , saveable: true
            , sortable: false
            , isRecID: false
            , saveUsing: 'notes'
            , dataType: 'text'
        });


        /* Setup additional row controls */

        opts.additionalControlDefinitionsForBodyRows = new Map();

        /* Create the rest view */

        $($restViewEmploymentRelationships).MBA_RestView(opts);
        
        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>',       '<%=practitionerEmploymentRelationshipClientID%>');
        let NV_PRAC_ID = MBA.RestViewCommon.fnCreateNameValueObject('<%=Constants.PARM_PRACTITIONER_ID%>', '<%=practitionerEmploymentRelationshipPracID%>');

        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForViewSet',   NV_CLIENT_ID);
        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForViewSet',   NV_PRAC_ID);
        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PRAC_ID);
        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForEditSet',   NV_CLIENT_ID);
        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForEditSet',   NV_PRAC_ID);
        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
        $($restViewEmploymentRelationships).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_PRAC_ID);

        $($restViewEmploymentRelationships).MBA_RestView('requestViewFromServer', 1);
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initRestViewPractitionerSites() {

        let optsObj = {};
        optsObj.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        optsObj.PARM_NAME_PRAC_ID = '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>';
        optsObj.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsObj.containerCtrlID = 'dataManagementRowsForSites';
        optsObj.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsObj.baseUrlView = '<%=Spedmon.PractitionerSites.URL_PRACTITIONER_SITES_REST_VIEW_BASE()%>';
        optsObj.defaultPageRowOrder   = '<%=Spedmon.PractitionerSite.DEFAULT_PAGING_ORDER%>';
        optsObj.baseUrlAddNew         = '<%=Spedmon.PractitionerSites.URL_REST_PRACSITES_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlEdit = '<%=Spedmon.PractitionerSites.URL_REST_PRACSITES_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlPracSiteIDSel = '<%=Spedmon.Sites.URL_REST_VIEW_SEL_INLINE()%>';

        optsObj.autoHidePageControls      = true;
        optsObj.enableScrollView          = true;
        optsObj.scrollViewUseCustomHeight = true;
        optsObj.scrollViewCustomHeight    = '20em';

        MBA.PractitionerSitesCommon.fnSetup('restViewSites', optsObj);
   }

    $(function () {


        $( '#npi-search-start' ).on('click', function () {
                
                let reqUrl = '<%=Spedmon.Practitioners.URL_NPI_LOOKUP_BASE() %>';
                let reqData = JSON.stringify({

                    "term": $('#npi-search-value').val() ,
                    "selectmode": $('#npi-search-using').val() 

                });
            let $butNpiSearch = $('#npi-search-start');

            let $butNpiSearchSpinner = MBA.ComponentCommon.fnElemDisableAndAddSpinner($butNpiSearch);
            
                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
                    .then(responseData => {
                        MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNpiSearch, $butNpiSearchSpinner);
                        var prac_rowclick_handler = function (npi, fname, lname, phone, fax, address1, address2, city, state, zip) {

                            $('input#lname').val(lname);
                            $('input#fname').val(fname);
                            $('input#phone').val(phone);
                            $('input#fax').val(fax);
                            $('input#npi_numberprac_npi').val(npi);
                            $('input#cityprac_prof_address').val(city);
                            $('input#stateprac_prof_address').val(state);
                            $('input#street1prac_prof_address').val(address1);
                            $('input#street2prac_prof_address').val(address2);
                            var zip_5 = zip.substr(0, 5);
                            var zip_4 = zip.substr(5, 4);
                            $('input#zip5prac_prof_address').val(zip_5);
                            $('input#zip4prac_prof_address').val(zip_4);                            
                        };
                                              
                      var v_parsed = JSON.parse( responseData.rawData.value ).results ;

                   
                      var thead = $('<thead><tr>' +
                            '<th>NPI</th><th>Last Name</th><th>First Name</th><th>Taxonomies</th>' +
                            '<th>Tel</th><th>Address</th><th></th><th>City</th><th>State</th><th>ZIP</th>' +
                            '<th></th>' +
                            '</tr></thead>');

                      var tbody = $('<tbody></tbody>');
                                                      
                      $.each( v_parsed, function( iter, i_x ) {

                        var taxonomies_str = '';
                        
                        $.each( i_x.taxonomies, function( iter_ii, i_x_taxo ) {                    
                            taxonomies_str = taxonomies_str + '<span class="badge badge-dark p-2 mr-1">' + i_x_taxo.desc + '</span>';
                        });

                          jq_tr_basic = $('<tr class="table-secondary">' +
                            '<td><h4>' + i_x.number + '</h4></td><td><h4>' + i_x.basic.last_name + '</h4></td><td><h4>' + i_x.basic.first_name + '</h4></td>' +
                            '<td colspan="8">' + taxonomies_str + '</td>' +                           
                            '</tr>'  ) ;
                        
                        tbody.append( jq_tr_basic );

                        $.each( i_x.addresses, function( iter_ii, i_x_address ) {

                           jq_tr_ixAddress =  $( '<tr><td colspan="4"></td>' +
                            '<td><i class="fas fa-phone fa-1x mr-2" />' + i_x_address.telephone_number +
                            (  i_x_address.fax_number ?
                               '<br/><i class="fas fa-fax fa-1x mr-2" />' +
                               i_x_address.fax_number
                               : '' ) +
                             '</td><td>' + i_x_address.address_purpose + '</td><td>' + i_x_address.address_1 + '</td><td>' + i_x_address.city + '</td><td>' + i_x_address.state + '</td><td>' + i_x_address.postal_code + '</td>' +
                            '<td>' +
                            '<a href="#"  ' +
                               ' id="fetched-pracs-action-link-' + iter + '" '+
                               ' class="fetched-pracs-action-link" >' +
                               '<i class="fas fa-hand-point-right fa-2x ml-2" title="Click here to copy this information into the appropriate fields"/></a>' +
                            '</td>' +
                            '</tr>');

                            if (i_x_address.state == 'CA') {
                                $(jq_tr_ixAddress).addClass('table-warning');
                            }

                            $( '.fetched-pracs-action-link' , jq_tr_ixAddress ).click(
                              function() {

                                  prac_rowclick_handler(
                                    i_x.number, i_x.basic.first_name , i_x.basic.last_name ,
                                    i_x_address.telephone_number, i_x_address.fax_number, i_x_address.address_1, i_x_address.address_2,
                                    i_x_address.city, i_x_address.state, i_x_address.postal_code
                                  );

                                    $(this.parentNode).mbaHighlight({ color: '#bdffc7', duration: 500 });
                            });
                            
                            tbody.append( jq_tr_ixAddress );

                        });
                      });

                        var innertbl = $('<table class="table table-sm"></table>');
                        innertbl.append(thead);
                        innertbl.append(tbody);

                        var npiResultsContent = $('<div></div>');
                        
                        $(npiResultsContent).append(innertbl);                        
                        MBA.ComponentCommon.fnCreateOneTimeInfoDialog('NPI Lookup Results (CA locations are highlighted)', npiResultsContent, {});

                    })
                    .catch(responseData => {
                        MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($butNpiSearch, $butNpiSearchSpinner);
                        $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
                        return true;
                    });


        });

        <%
        /* Goto a specific tab specified by query string parameter if needed */
        if (!String.IsNullOrWhiteSpace(tabToOpen)) {%>
        $('a[href="#<%=tabToOpen%>"]').click();
        <%}%>

        $restViewEmploymentRelationships = $('#restViewEmploymentRelationships');

        // remove the 'OK' button from the TextAreaBox
        $('#notes_but_ok').remove();

        var opts = {};

        opts.RecsQualificationTextAreaSelector  = '#qualificationsJSONData';
        opts.RecsQualificationTableSelector     = '#tblRecsQualificationJSON';
        opts.RecsQualificationTableBodySelector = '#tblRecsQualificationJSONBody';

        SpEdCare.recPracQualification.init(opts);

        // hide the claims status and notes tabs for providers
        // NOTE: if we later add fields to these tabs, we should
        //  re-evaluate if they should be hidden or not
        if ('<%=userIsProvider%>' == 'true') {
            $('[href="#tab-claims-status"]').closest('li').hide();
            $('[href="#tab-notes"]').closest('li').hide();

            // modify the list of the required fields (as some are hidden now)
            requiredFields = ['clientid', 'lname', 'fname', 'groupdisp', 'is_valid_mcal_orp'];
        }

       <%if (showPractitionerEmploymentRelationships == true) {%>
         initRestViewEmployementRelationships();
       <%}%>

        initRestViewPractitionerSites();

        // Hide sites tab for new records
        
        if ('<%=saveType%>' == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
            $('[href="#tab-sites"]').closest('li').hide();
        }


    });

</script>