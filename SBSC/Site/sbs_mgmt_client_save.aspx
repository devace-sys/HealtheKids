<%@ Page Language="C#" CodeBehind="sbs_mgmt_client_save.aspx.cs" Inherits="Spedmon.SBSMGMTClientSave" %>
 

<%-- dialog that contains the additional fee questions (displayed in contract tab) --%>

<div id="feeStructureCont" title="This Service Requires The Selection of a Fee Structure">
    <div class="ui-spedmon-step-instructions">Additional Fee Questions.</div>

    <table id="feeQuestionsCont">
        <tbody>
            <%-- Common Fields --%>

            <tr>
                <td>
                    <p class="boldText">Common Fields</p>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="contractTerms">Contract Terms (years)</label>
                </td>
                <td>
                    <input type="number" id="contractTerms" name="contractTerms">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="evergreen">Evergreen (years)</label>
                </td>
                <td>
                    <input type="number" id="evergreen" name="evergreen">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="terminationDays">Termination Days</label>
                </td>
                <td>
                    <input type="number" id="terminationDays" name="terminationDays">
                </td>
            </tr>
            <tr class="rowSeparator">
                <td colspan="100%"></td>
            </tr>

            <%-- Flat Fee (Full Service) --%>

            <tr>
                <td>
                    <p class="boldText">Flat Fee (Full Service)</p>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="annualFeeFull">Annual Fee</label>
                </td>
                <td>
                    <input type="text" id="annualFeeFull" name="annualFeeFull" class="currencyInput">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="miscFlatFeeFull">CRCS Flat Fee</label>
                </td>
                <td>
                    <input type="text" id="miscFlatFeeFull" name="miscFlatFeeFull" class="currencyInput">
                </td>
            </tr>
            <tr class="rowSeparator">
                <td colspan="100%"></td>
            </tr>

            <%-- Flat Fee (License) --%>

            <tr>
                <td>
                    <p class="boldText">Flat Fee (License)</p>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="annualFeeLicense">Annual Fee</label>
                </td>
                <td>
                    <input type="text" id="annualFeeLicense" name="annualFeeLicense" class="currencyInput">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="managerHourlyRate">Manager Hourly Rate</label>
                </td>
                <td>
                    <input type="text" id="managerHourlyRate" name="managerHourlyRate" class="currencyInput">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="onsiteRate">Onsite Hourly Rate</label>
                </td>
                <td>
                    <input type="text" id="onsiteRate" name="fname" class="currencyInput">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="adminRate">Admin Hourly Rate</label>
                </td>
                <td>
                    <input type="text" id="adminRate" name="adminRate" class="currencyInput">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="numHours">Number of Hours &nbsp;</label>
                    <input type="number" id="numHours" name="numHours">
                </td>
                <td>
                    <label for="hoursPer">Per &nbsp;</label>
                    <select id="hoursPer">
                        <option disabled="" value="" selected="">-- select an option --</option>
                        <option value="1">Annually</option>
                        <option value="2">Term</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="miscFlatFeeLicense">CRCS Flat Fee</label>
                </td>
                <td>
                    <input type="text" id="miscFlatFeeLicense" name="miscFlatFeeLicense" class="currencyInput">
                </td>
            </tr>
            <tr class="rowSeparator">
                <td colspan="100%"></td>
            </tr>

            <%-- Percentage --%>

            <tr>
                <td>
                    <p class="boldText">Percentage</p>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="percentageRate">Percentage Rate</label>
                </td>
                <td>
                    <input type="text" id="percentageRate" name="percentageRate" class="percentageInput">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="miscFlatFeePercentage">CRCS Flat Fee</label>
                </td>
                <td>
                    <input type="text" id="miscFlatFeePercentage" name="miscFlatFeePercentage" class="currencyInput">
                </td>
            </tr>
            <tr class="rowSeparator">
                <td colspan="100%"></td>
            </tr>

            <%-- Units Per Transmission --%>

            <tr>
                <td>
                    <p class="boldText">Units Per Transmission</p>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="unitRate">Unit Rate</label>
                </td>
                <td>
                    <input type="text" id="unitRate" name="unitRate" class="currencyInput">
                </td>
            </tr>
            <tr>
                <td>
                    <label for="miscFlatFeeTransmission">CRCS Flat Fee</label>
                </td>
                <td>
                    <input type="text" id="miscFlatFeeTransmission" name="miscFlatFeeTransmission" class="currencyInput">
                </td>
            </tr>
        </tbody>
    </table>

    <div class="ui-spedmon-step-instructions">
        <div>Click the OK button below when you are done answering the questions above.</div>
        <Spedmon:Button title="OK" ID="feeDetsOK" runat="server">
            OK
        </Spedmon:Button>
    </div>
</div>

<%/****************************
   * Save Client Record
   * for sbs (all)
   ****************************/%>

<Spedmon:DataEntryRows ID="save" dataURL="clients.asmx/save" useBootstrapFluid="true" runat="server">

<Spedmon:HiddenInput ID="clientid" name="clientid" title="record id" runat="server" />

<div id="clienttabs">

<ul>
    <li><a href="#tab-demographics">Demographics</a></li>
    <li><a href="#tab-contact">Contact</a></li>    
    <li><a href="#tab-common-options">Common Options</a></li>
    
    <li><a href="#tab-lea-bop">LEA BOP</a></li>
    <li><a href="#tab-maa">MAA</a></li>
    <li><a href="#tab-cybhi">CYBHI</a></li>
    <li><a href="#tab-cde-compliance">IDEA/CDE</a></li>
    <li><a href="#tab-care-plans">Care Plans</a></li>
    <li><a href="#tab-hyqueue">HyQueue</a></li>
    
    <li><a href="#tab-school-years">School Years</a></li>
    <li><a href="#tab-school-breaks">School Breaks</a></li>
    <li><a href="#tab-special-authorizations">Special Authorizations</a></li>    
    <li><a href="#tab-practice-rules">Practice Rules</a></li>
    
    <li><a href="#tab-domains">Domains</a></li>
    <li><a href="#tab-information-systems">Information Systems</a></li>
    <li><a href="#tab-files-expected">Files Expected</a></li>
    
    <li><a href="#tab-notes">Notes</a></li>  
    
    <li><a href="#tab-contract">Contract</a></li>
    <li><a href="#tab-invoices">Invoices</a></li>
    <li><a href="#tab-partner-distributions">Partner<br/>Distributions</a></li>
    <li><a href="#tab-partner-shares">Partner Shares</a></li>
</ul>

<%/****************************
   * Demographics tab
   ****************************/%>

<div id="tab-demographics">

  <%/************************************* Client Name **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter the client's name" runat="server">
    <Spedmon:Input ID="clientName" name="clientName" title="Name" runat="server" />
  </Spedmon:DataEntryRow>

   <%/************************************* Client CDS **********************************/%>

   <Spedmon:DataEntryRow rowLabel="Enter client's CDS code" runat="server">
     <Spedmon:Input ID="clientCDS" name="clientCDS" title="CDS Code" runat="server" />
   </Spedmon:DataEntryRow>

   <%/************************************* Short Name ************************/%>

   <Spedmon:DataEntryRow rowLabel="Enter client's short name" runat="server">
     <Spedmon:Input ID="shortname" name="shortname" title="Short Name?" runat="server" />
   </Spedmon:DataEntryRow>

   <%/************************************* COE **********************************/%>

   <Spedmon:DataEntryRow rowLabel="Is this client a County Office of Education (COE)?" runat="server">
     <Spedmon:SelectYesOrNo ID="COE" name="COE" title="COE?" renderLabel="false" runat="server" />
   </Spedmon:DataEntryRow>

   <%/************************************* SELPA **********************************/%>

   <Spedmon:DataEntryRow rowLabel="Enter client's SELPA code" runat="server">
     <Spedmon:DataEntryRowSelectSELPA
                    ID="selectClientSELPA"
                    entityControlID="selpaCode"
                    rowLabel="Client SELPA"
                    dataEntryRowRenderAs="FIELD"
                    runat="server">
     </Spedmon:DataEntryRowSelectSELPA>
   </Spedmon:DataEntryRow>
                       
   <%/************************************* Address ************************/%>

   <Spedmon:DataEntryRow rowLabel="Enter client's address" runat="server">
     <Spedmon:FieldSetUSPSAddress ID="clientAddress" includeOKButton="false" includeLegend="false" runat="server" />
   </Spedmon:DataEntryRow>

                         
   <%/************************************* Logo **************************/%>

   <Spedmon:DataEntryRow rowLabel="Please select a logo file" runat="server">
   <div class="d-flex flex-column">
     <Spedmon:HiddenTextArea ID="clientlogofiledata" name="clientlogofiledata" title="clientlogofiledata" runat="server" />

     <input id="clientlogofilepicker" type="file" accept="image/*" />
     <img id="clientlogoimg" src="">
   </div>
   </Spedmon:DataEntryRow>

</div> <!-- tab -->

<%/****************************
   * Common Options 
   ****************************/%>

<div id="tab-common-options">
  
   <%/************************************* Email Notification **************************/%>

   <Spedmon:DataEntryRow rowLabel="Send Email Notifications to Users" runat="server">
     <Spedmon:SelectYesOrNo ID="sendUsersEmailNotifications" name="sendUsersEmailNotifications" title="sendUsersEmailNotifications?" renderLabel="false" runat="server" />
   </Spedmon:DataEntryRow>
   
   <%/************************************* Approval System **************************/%>

   <Spedmon:DataEntryRow rowLabel="Does This Client Use Electronic Approval Of Service Records?" runat="server">
     <Spedmon:SelectYesOrNo ID="svcrecapprovalsystem" name="svcrecapprovalsystem" title="svcrecapprovalsystem?" renderLabel="false" runat="server" />
   </Spedmon:DataEntryRow>

   <%/************************************* Parent Consent **************************/%>

   <Spedmon:DataEntryRow rowLabel="Client agrees that student names submitted to Practi-Cal via student database will be marked as YES and parental consent will be assumed. Client must edit or inform Practi-Cal of students where consent has been denied." runat="server">
     <div class="d-flex">
       <Spedmon:SelectYesOrNoOrUnknown ID="parentConsentAgreement" name="parentConsentAgreement" title="parentConsentAgreement?" renderLabel="false" runat="server" />
       <input type="date" id="parentConsentAgreementEffectiveDate" name="parentConsentAgreementEffectiveDate" class="data-entry-row-input">
     </div>
   </Spedmon:DataEntryRow>
    
   <%/************************************* Implied FERPA Consent **************************/%>

   <Spedmon:DataEntryRow rowLabel="Client agrees that FERPA consent is implied for all students. Client must edit or inform Practi-Cal of students where consent has been denied." runat="server">
     <Spedmon:SelectYesOrNo ID="impliedferpaconsent" name="impliedferpaconsent" title="Implied FERPA Consent?" renderLabel="false" runat="server" />
   </Spedmon:DataEntryRow>

</div> <!-- tab -->

<%/****************************
   * LEA BOP tab
   ****************************/%>

<div id="tab-lea-bop">
  
  <%/************************************* LEA **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Does this client participate in the LEA BOP or is this client considered active?" runat="server">
    <Spedmon:SelectYesOrNo ID="LEA" name="LEA" title="LEA?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

   <%/************************************* NPI **********************************/%>

   <Spedmon:DataEntryRow rowLabel="Enter clients National Provider ID (NPI) (Optional)" runat="server">
     <Spedmon:Input ID="NPI" name="NPI" title="NPI" runat="server" />
   </Spedmon:DataEntryRow>

   <%/************************************* Tax ID **********************************/%>

   <Spedmon:DataEntryRow rowLabel="Enter the client's tax ID" runat="server">
     <Spedmon:Input ID="tax_ID" name="tax_ID" title="Tax ID" runat="server" />
   </Spedmon:DataEntryRow>
    
   <%/************************************* EIN **********************************/%>

   <Spedmon:DataEntryRow rowLabel="Enter client's Employer Identification Number (EIN) (Optional)" runat="server">
     <Spedmon:Input ID="EIN" name="EIN" title="EIN" runat="server" />
   </Spedmon:DataEntryRow>
   
  <%/************************************* Client Rep LEA **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter client's Rep LEA" runat="server">
    <Spedmon:ComboBox ID="clrepidLEA" name="clrepidLEA" title="Client Rep ID LEA?" maxlen="50" dataPrivate="true" dataURL="clientReps.asmx/viewSel" dataParms="[{}]" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* Approved LEA BOP 837 **********************************/%>

  <Spedmon:DataEntryRow ID="leabopconsortiumbillingRow"  rowLabel="Consortium Billing?:" runat="server">
    <Spedmon:SelectYesOrNo ID="leabopconsortiumbilling" name="leabopconsortiumbilling" title="leaBopConsortiumBilling" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <Spedmon:DataEntryRow rowLabel="Consortium Billing Lead Client:" runat="server">
      <Spedmon:DataEntryRowSelectClient
                ID                   = "selectleabopconsortiumLeadClientID" 
                entityControlID      = "leabopconsortiumLeadClientID"
                dataEntryRowRenderAs = "FIELD"
                selectTitle          = "Enter Name"
                runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
   </Spedmon:DataEntryRow>

  <%/************************************* Approved LEA BOP 837 **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Is this client approved for the LEA BOP 837?" runat="server">
    <Spedmon:SelectYesOrNo ID="approved_837" name="approved_837" title="Approved 837?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* Approved LEA BOP 835 **********************************/%>
  
  <Spedmon:DataEntryRow rowLabel="Is this client approved for the LEA BOP 835?" runat="server">
    <Spedmon:SelectYesOrNo ID="approved_835" name="approved_835" title="Approved 835?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>
  
  <%/************************************* namercgbyDHCS_EDS ************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter the Client Name Officially recognized by DHCS & EDS (Optional)" runat="server">
    <Spedmon:Input ID="namercgbyDHCS_EDS" name="namercgbyDHCS_EDS" title="Name Officially recognized by DHCS & EDS" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* TCM **************************/%>

  <Spedmon:DataEntryRow rowLabel='Answer yes to this question if the client has chosen to seek reimbursement for TCM AND meets the "Agency Approved" case management training compliance standard. Otherwise select NO and add a reason in the client notes below.' runat="server">
    <Spedmon:SelectYesOrNoOrUnknown ID="claim_TCM" name="claim_TCM" title="claim_TCM?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* TCM Effective Date **************************/%>
  
  <Spedmon:DataEntryRow rowLabel="Select or enter the effective date of TCM claims" runat="server">
    <input type="date" id="claim_TCMEffectiveDate" name="claim_TCMEffectiveDate" class="data-entry-row-input">
  </Spedmon:DataEntryRow>

  <%/************************************* Generate 837 File **************************/%>

  <Spedmon:DataEntryRow rowLabel="For LEA BOP Transmission<br>Yes = 837 files for the LEA BOP will be automatically generated as part of our nightly batch tasks.  No = 837 files will need to be manually generated" runat="server">
    <Spedmon:SelectYesOrNo ID="autoGenerate837File" name="autoGenerate837File" title="autoGenerate837File?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* Days to Hold Claims ***********************/%>

  <Spedmon:DataEntryRow rowLabel="For LEA BOP Transmission<br>Hold Client Entered Claims for x Days from Date of Entry" runat="server">
     <Spedmon:NumberBox ID="numDaysToHoldClientEnteredClaims" name="numDaysToHoldClientEnteredClaims" title="Number of Days (0 = none)" maxlen="3" useDefaultValue="true" defaultValue="3" showOK="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* First Check for LEA BOP **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Select or enter the first check date for the LEA BOP" runat="server">
    <input type="date" id="firstcheck" name="firstcheck" class="data-entry-row-input">
  </Spedmon:DataEntryRow>

  <%/************************************* Owned By Company name LEA ************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter client's Owned By Company name LEA" runat="server">
     <Spedmon:ComboBox ID="owndbycompidLEA" name="owndbycompidLEA" title="Owned By Company ID LEA?" maxlen="50" dataPrivate="true" dataURL="companies.asmx/viewSel" dataParms="[{}]" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* rvnsharectgLEA **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter client's Revenue Sharing category LEA Current" runat="server">
                <datalist id="revenue-sharing-codes-for-lea">
                    <option>LEA-A1</option>
                    <option>LEA-A2</option>
                    <option>LEA-E</option>
                    <option>LEA-F1</option>
                    <option>LEA-H</option>
                    <option>LEA-J1</option>
                    <option>MBA</option>
                </datalist>
  
      <Spedmon:DataEntryBoxText ID="rvnsharectgLEA" name="rvnsharectgLEA" title="Revenue Sharing category LEA Current?" label="Revenue Sharing Category for LEA" list="revenue-sharing-codes-for-lea" runat="server" />

  </Spedmon:DataEntryRow>

</div> <!-- tab -->


<%/****************************
   * MAA tab
   ****************************/%>

<div id="tab-maa">

  <%/************************************* MAA **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Does this Client participate in MAA?" runat="server">
    <Spedmon:SelectYesOrNo ID="MAA" name="MAA" title="MAA?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* Client Rep MAA **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter client's Rep MAA" runat="server">
    <Spedmon:ComboBox ID="clrepidMAA" name="clrepidMAA" title="Client Rep ID MAA?" maxlen="50" dataPrivate="true" dataURL="clientReps.asmx/viewSel" dataParms="[{}]" runat="server" />
  </Spedmon:DataEntryRow>
  
  <%/************************************* LEC / LGA ************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter LEC / LGA" runat="server">
     <Spedmon:DataEntryRowSelectLecOrLga
                    ID="selectLecOrLga"
                    entityControlID="lecorlgaid"
                    rowLabel="LEC / LGA"
                    dataEntryRowRenderAs="FIELD"
                    runat="server">
     </Spedmon:DataEntryRowSelectLecOrLga>
   </Spedmon:DataEntryRow>

  <%/************************************* Owned By Company name MAA ************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter client's Owned By Company name MAA" runat="server">
    <Spedmon:ComboBox ID="owndbycompidMAA" name="owndbycompidMAA" title="Owned By Company ID MAA?" maxlen="50" dataPrivate="true" dataURL="companies.asmx/viewSel" dataParms="[{}]" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* rvnsharectgMAA **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Enter client's Revenue Sharing category MAA Current" runat="server">
    <Spedmon:Input ID="rvnsharectgMAA" name="rvnsharectgMAA" title="Revenue Sharing category MAA Current?" runat="server" />
  </Spedmon:DataEntryRow>

  
</div> <!-- tab -->

<%/****************************
   * CYBHI tab
   ****************************/%>

<div id="tab-cybhi">

  <%/************************************* CYBHI Use **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Does this client use our CYBHI module?" runat="server">
    <Spedmon:SelectYesOrNo ID="cybhi" name="cybhi" title="CYBHI?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/*********************** CYBHI Specific Client Name, NPI, Tax ID, Address ***********************/%>
  
  <Spedmon:DataEntryRow rowLabel="CYBHI Provider" runat="server">
    
    <Spedmon:DataEntryBoxText ID="cybhiclientname" name="cybhiclientname"  title="CYBHI Client Name" label="CYBHI Client Name" runat="server" />
    <Spedmon:DataEntryBoxText ID="cybhinpi"        name="cybhinpi"         title="CYBHI NPI"         label="CYBHI NPI"         runat="server" />
    <Spedmon:DataEntryBoxText ID="cybhitaxid"      name="cybhitaxid"       title="CYBHI Tax ID"      label="CYBHI Tax ID"      runat="server" />
    
    <Spedmon:FieldSetUSPSAddress
              ID              = "cybhiAddressData"
              includeOKButton = "false"
              includeLegend   = "false"                            
              title           = "Address data to use for TPA registration and claim submission"
              parmNameStreet1 = "cybhiaddress1"
              parmNameStreet2 = "cybhiaddress2"
              parmNameCity    = "cybhicity"
              parmNameState   = "cybhistate"
              parmNameZip5    = "cybhizip5"
              parmNameZip4    = "cybhizip4"                
              runat           = "server" />
  
  </Spedmon:DataEntryRow>
  
  <%/************************************* CYBHI Add On Missing Info **************************/%>

  <Spedmon:DataEntryRow rowLabel="CYBHI Add On - Electronic Missing Information Requests To Parents" runat="server">
    <Spedmon:SelectYesOrNo ID="cybhiaddonmissinginforequeststopatientpersons" name="cybhiaddonmissinginforequeststopatientpersons" title="CYBHI Add On Missing Info?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* Submit CYBHI Claims **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Submit CYBHI Claims? (Only set to No if client is participating in CYBHI but we need to hold all CYBHI claims for this client." runat="server">
    <Spedmon:SelectYesOrNo ID="cybhisubmitclaims" name="cybhisubmitclaims" title="Submit CYBHI Claims?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/*************************************** CYBHI Do Not Claim Overlapping **************************************/%>
            
  <Spedmon:DataEntryRow rowLabel="CYBI - Do Not Claim Overlapping LEA BOP Services?" runat="server">
    <Spedmon:SelectYesOrNo ID="cybhidonotclaimoverappingleabopsvcs" name="cybhidonotclaimoverappingleabopsvcs" title="CYBHI Do Not Claim?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* CYBHI TPA Client Code ************************/%>

  <Spedmon:DataEntryRow rowLabel="CYBHI Client Code (Short Name Provided by TPA)" runat="server">
    <Spedmon:DataEntryBoxText ID="cybhiclientcode" name="cybhiclientcode" title="Client Code" runat="server" />
  </Spedmon:DataEntryRow>

  <%/************************************* CYBHI Consortium Billing **********************************/%>
    
  <Spedmon:DataEntryRow ID="CYBHIConsortiumBillingRow"  rowLabel="Consortium Billing?" runat="server">
    <Spedmon:SelectYesOrNo ID="cybhiconsortiumbilling" name="cybhiconsortiumbilling" title="CYBHI Consortium Billing" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

  <Spedmon:DataEntryRow rowLabel="Consortium Billing Lead Client:" runat="server">
      <Spedmon:DataEntryRowSelectClient
                ID                   = "selectcybhiconsortiumleadClientID" 
                entityControlID      = "cybhiconsortiumleadClientID"        
                dataEntryRowRenderAs = "FIELD"
                selectTitle          = "Enter Name"
                runat                = "server">
      </Spedmon:DataEntryRowSelectClient>
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
 
  <%/************************************* CYBHI Generate 837 **********************************/%>
 
  <Spedmon:DataEntryRow ID="cybhiGenerate837Row"  rowLabel="CYBHI Generate 837?" runat="server">
     <Spedmon:SelectYesOrNo ID="cybhigenerate837" name="cybhigenerate837" title="CYBHI Generate 837" renderLabel="false" runat="server"/>    
  </Spedmon:DataEntryRow>

  <%/******************************** CYBHI Auto Generate 837 **********************************/%> 

  <Spedmon:DataEntryRow ID="cybhiAutoGenerate837Row"  rowLabel="CYBHI Auto Generate 837?" runat="server">
    <Spedmon:SelectYesOrNo ID="cybhiautogenerate837" name="cybhiautogenerate837" title="CYBHI Auto Generate 837" renderLabel="false" runat="server"/>
  </Spedmon:DataEntryRow>

  <%/******************** CYBHI Hold Claims For N Days from Date of Entry  *********************/%> 

  <Spedmon:DataEntryRow ID="cybhiHoldClaimsForNDaysFromDateOfEntry"  rowLabel="CYBHI Hold Claims For n Days From Date of Entry" runat="server">
    <Spedmon:DataEntryBoxNumber ID="cybhinumdaystoholdenteredclaims" name="cybhinumdaystoholdenteredclaims" label="Number of Days" title="Enter days" min="0" max="14" runat="server" />
  </Spedmon:DataEntryRow>

</div> <!-- cybhi tab -->

<%/****************************
   * CDE Compliance
   ****************************/%>

<div id="tab-cde-compliance">
  
  <%/************************************* CDE Compliance **********************************/%>

  <Spedmon:DataEntryRow rowLabel="Does this client use our CDE compliance module?" runat="server">
    <Spedmon:SelectYesOrNo ID="cdecomplianceclient" name="cdecomplianceclient" title="CDE Compliance?" renderLabel="false" runat="server" />
  </Spedmon:DataEntryRow>

</div> <!-- div -->

<%/****************************
   * Care Plans
   ****************************/%>

<div id="tab-care-plans">
  
    <%/************************************* Plan Writer Access **************************/%>

    <Spedmon:DataEntryRow rowLabel="Plan Writer Access Granted" runat="server">
        <Spedmon:SelectYesOrNo ID="planWriterAccessGranted" name="planWriterAccessGranted" title="planWriterAccessGranted?" renderLabel="false" runat="server" />
    </Spedmon:DataEntryRow>

    <%/************************************* Plan Writer Access Ends On ***********************/%>

    <Spedmon:DataEntryRow rowLabel="Plan Writer Access Ends On (Optional)" runat="server">
        <input type="date" id="planWriterAccessEndDate" name="planWriterAccessEndDate" class="data-entry-row-input">
    </Spedmon:DataEntryRow>

    <%/************************************* Care Plan Legal Language ***********************/%>

    <Spedmon:DataEntryRow rowLabel="Enter the care plan legal language" runat="server">
      <Spedmon:TextAreaBox ID="carePlanLegalLang" name="carePlanLegalLang" title="Care Plan Legal Language" runat="server" />
    </Spedmon:DataEntryRow>

</div> <!-- tab -->

<%/****************************
   * HyQueue
   ****************************/%>

<div id="tab-hyqueue">

<%/************************************* Telehealth Access **************************/%>

            <Spedmon:DataEntryRow rowLabel="TeleHealth Module Access Granted" runat="server">
                <Spedmon:SelectYesOrNo ID="teleCommTeleHealthAccessGranted" name="teleCommTeleHealthAccessGranted" title="teleCommTeleHealthAccessGranted?" renderLabel="false" runat="server" />
            </Spedmon:DataEntryRow>

            <%/************************************* Telehealth Ends On **************************/%>

            <Spedmon:DataEntryRow rowLabel="TeleHealth Module Access Ends On (Optional)" runat="server">
                <input type="date" id="teleCommTeleHealthAccessEndDate" name="teleCommTeleHealthAccessEndDate" class="data-entry-row-input">
            </Spedmon:DataEntryRow>

            <%/************************************* TeleIEP Access **************************/%>

            <Spedmon:DataEntryRow rowLabel="TeleIEP Module Access Granted" runat="server">
                <Spedmon:SelectYesOrNo ID="teleCommTeleIEPAccessGranted" name="teleCommTeleIEPAccessGranted" title="teleCommTeleIEPAccessGranted?" renderLabel="false" runat="server" />
            </Spedmon:DataEntryRow>

            <%/************************************* TeleIEP Ends On **************************/%>

            <Spedmon:DataEntryRow rowLabel="TeleIEP Module Access Ends On (Optional)" runat="server">
                <input type="date" id="teleCommTeleIEPAccessEndDate" name="teleCommTeleIEPAccessEndDate" class="data-entry-row-input">
            </Spedmon:DataEntryRow>

</div> <!-- tab -->

<%/****************************
   * Contact 
   ****************************/%>

<div id="tab-contact">

<%/************************************* Contact Name ************************/%>

<Spedmon:DataEntryRow rowLabel="Enter client's contact name (Optional)" runat="server">
                <Spedmon:Group ID="contactname"
                    title="Name"
                    fnControlValue="var vl  = $('#lname').val() + ',' + $('#fname').val(); return vl;"
                    fnControlLabel="var lbl = $('#lname').val() + ',' + $('#fname').val(); return lbl;"
                    okButton="false"
                    runat="server">
                    <Spedmon:Input ID="lname" name="lname" inlineLabel="" cssInline="width:150px;" title="Enter Last Name" runat="server" />
                    <Spedmon:Input ID="fname" name="fname" inlineLabel="" cssInline="width:150px;" title="Enter First Name" runat="server" />
                </Spedmon:Group>
</Spedmon:DataEntryRow>

<%/************************************* Contact Title ************************/%>

<Spedmon:DataEntryRow rowLabel="Enter client's contact title (Optional)" runat="server">
   <Spedmon:Input ID="title" name="title" title="Title" runat="server" />
</Spedmon:DataEntryRow>

<%/************************************* Contact Area Code and Phone Number ***********/%>

<Spedmon:DataEntryRow rowLabel="Enter the client's contact area code and phone number (Optional)" runat="server">
   <Spedmon:PhoneBox ID="phone" name="phone" title="Phone Number" maxlen="14" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%/************************************* Contact Fax Number **************************/%>

<Spedmon:DataEntryRow rowLabel="Enter the client's contact fax number (with area code) (Optional)" runat="server">
  <Spedmon:PhoneBox ID="fax" name="fax" title="Fax Number" maxlen="14" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%/************************************* Contact Email **************************/%>

<Spedmon:DataEntryRow rowLabel="Enter the client's contact email address (Optional)" runat="server">
   <Spedmon:EmailBox ID="email" name="email" title="Email Address" maxlen="50" showOK="false" runat="server" />
</Spedmon:DataEntryRow>

<%//-----------------------------------------------------------------------------%>
<%// Contact Table %>
<%//-----------------------------------------------------------------------------%>

            <Spedmon:HiddenTextArea ID="recContactJSON" name="recContactJSON" title="recContactJSON" runat="server" />

            <i id="addNewContact" class="fa fa-plus" title="Add New Record"></i>

            <table id="tblRecsContactJSON" class="tblRecsJSON">
                <thead>
                    <tr>
                        <th></th>
                        <th></th>
                        <th>Name</th>
                        <th>Role</th>
                        <th>Email</th>
                        <th>Phone</th>
                    </tr>
                </thead>
                <tbody id="tblRecsContactJSONBody" class="tblRecsJSONBody">
                </tbody>
            </table>
</div> <!-- tab -->


<%/****************************
   * School Years 
   ****************************/%>

<div id="tab-school-years">
  <div id="restviewschoolyears"></div>
</div> <!-- tab -->

<%/****************************
   * School Breaks 
   ****************************/%>

<div id="tab-school-breaks">
    <datalist id="common-break-names">
        <option value="Labor Day"></option>
        <option value="Thanksgiving"></option>
        <option value="Christmas"></option>
        <option value="President's Day"></option>
        <option value="Lincoln's Birthday"></option>
        <option value="Veteran's Day"></option>
        <option value="Spring Break"></option>
        <option value="Memorial Day"></option>
        <option value="4th of July"></option>
        <option value="Snow Day"></option>
        <option value="Teacher Day"></option>
        <option value="School Site Year"></option>
    </datalist>
    <div id="restviewschoolbreaks">
    </div>
</div> <!-- tab -->


<%/****************************
   * Special Authorizations 
   ****************************/%>

<div id="tab-special-authorizations">

            <%//-----------------------------------------------------------------------------%>
            <%// CYBHI Clinical Supervisor PracID %>
            <%//-----------------------------------------------------------------------------%>
             
           <div>
           
           <h5>Select a licensed practitioner below that will be this clients clinical supervisor for the CYBHI program</h5>          

           <Spedmon:DataEntryRowSelectPractitioner
              ID        = "cybhiSelectClinicalSupervisorPracID" 
              rowLabel  = "CYBHI Clinical Supervisor Practitioner?" 
              dataEntryRowRenderAs    = "FIELD"
              showDataSourceSelection = "false"            
              preSelectedDataSource   = "ALL_PRACTITIONERS"
              saveDataSourceSelectedAsPreference = "false"
              showClearSelection                 = "false"
              entityControlID                     = "cybhiclinicalsupervisorpracid"              
              runat                               = "server">
            </Spedmon:DataEntryRowSelectPractitioner>

            </div>

            <%//-----------------------------------------------------------------------------%>
            <%// Special Authorizations Table %>
            <%//-----------------------------------------------------------------------------%>

            <div class="mt-3">
            
            <h5>Manage special authorizations for the LEA BOP program below</h5>

            <Spedmon:HiddenTextArea ID="recSpecAuthJSON" name="recSpecAuthJSON" title="recSpecAuthJSON" runat="server" />

            <i id="addNewSpecAuth" class="fa fa-plus" title="Add New Record"></i>

            <table id="tblRecsSpecAuthJSON" class="tblRecsJSON">
                <thead>
                    <tr>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th>Type of Document</th>
                        <th>ORP</th>
                        <th>Start Date</th>
                        <th>End Date</th>
                    </tr>
                </thead>
                <tbody id="tblRecsSpecAuthJSONBody" class="tblRecsJSONBody">
                </tbody>
            </table>
            </div>

</div> <!-- tab -->

<%/****************************
   * Practice Specific Rules 
   ****************************/%>

<div id="tab-practice-rules">
  <div id="restviewpracticerules"></div>
</div> <!-- tab -->

<%/****************************
   * Domains
   ****************************/%>

<div id="tab-domains">

<div id="restviewdomains"></div>

</div> <!-- tab -->

<%/****************************
   * Information Systems 
   ****************************/%>

<div id="tab-information-systems">
    
  <div class="mb-2">
    <Spedmon:LinkInternal ID="btnAriesApiTest" title="Aries API Test Tool" faClass="fa fa-cog" openNew="true" url="user_all_aries_api_test.aspx" label="Aries API Test Tool" urlPrivate="true" runat="server"/>
  </div>
    
   <div id="restviewclientstudentinfosystems"></div>

</div> <!-- tab -->

<%/****************************
   * Files Expected
   ****************************/%>

<div id="tab-files-expected">

    <Spedmon:DataEntryRow rowLabel="Total Student Population" runat="server">
        <Spedmon:SelectYesOrNo ID="sendRequestsForTotPop" name="sendRequestsForTotPop" title="Send Requests?" renderLabel="true" runat="server" />
        <Spedmon:SelectCronTabOccurance ID="cronTabExpectedTotPop" name="cronTabExpectedTotPop" title="When To Send Requests?" includeDaily="false" includeWeekly="false" includeYearly="false" renderLabel="true" runat="server" />
    </Spedmon:DataEntryRow>

    <Spedmon:DataEntryRow rowLabel="Special Education Services" runat="server">
        <Spedmon:SelectYesOrNo ID="sendRequestsForSpEd" name="sendRequestsForSpEd" title="Send Requests?" renderLabel="true" runat="server" />
        <Spedmon:SelectCronTabOccurance ID="cronTabExpectedSpecEdSvcs" name="cronTabExpectedSpecEdSvcs" title="When To Send Requests?" includeDaily="false" includeWeekly="false" includeYearly="false" renderLabel="true" runat="server" />
    </Spedmon:DataEntryRow>

    <Spedmon:DataEntryRow rowLabel="DHCS Eligibility Data Matches" runat="server">
        <Spedmon:SelectYesOrNo ID="sendElibilityDataMatchRequestsToDHCS" name="sendElibilityDataMatchRequestsToDHCS" title="Send Eligibility Data Match Requests?" renderLabel="true" runat="server" />
    </Spedmon:DataEntryRow>

    <%/*************************************** fuzzyMatchSitesByNameAndCode  **************************************/%>

   <Spedmon:DataEntryRow rowLabel="Does this client use our fuzzy Match Sites By Name And Code For School Sites?" runat="server">
     <Spedmon:SelectYesOrNo ID="fuzzymatchsitesbynameandcode" name="fuzzymatchsitesbynameandcode" title="Fuzzy Matching By Name and Code?" renderLabel="false" runat="server" />
   </Spedmon:DataEntryRow>

</div> <!-- tab -->

<%/****************************
   * Notes 
   ****************************/%>

<div id="tab-notes">
  <Spedmon:TextAreaBox ID="notes" name="notes" title="Notes" runat="server"></Spedmon:TextAreaBox>
</div> <!-- tab -->

<%/****************************
   * Contract tab
   ****************************/%>

<div id="tab-contract">

            <%/************************************* HyQueue Fee **********************************/%>

            <Spedmon:DataEntryRow rowLabel="Enter HyQueue Fee" runat="server">
                <input type="text" id="hyQueueFee" name="hyQueueFee" title="HyQueue Fee?" class="currencyInput">
            </Spedmon:DataEntryRow>

            <%/************************************* Plan Writer Fee **********************************/%>

            <Spedmon:DataEntryRow rowLabel="Enter Plan Writer Fee" runat="server">
                <input type="text" id="planWriterFee" name="planWriterFee" title="Plan Writer Fee?" class="currencyInput">
            </Spedmon:DataEntryRow>

            <%/************************************* LEA Recovery Budget ************************/%>

            <Spedmon:DataEntryRow rowLabel="Annual Reimbursement Goal" runat="server">
                <input type="text" id="LEARecoveryBudget" name="LEARecoveryBudget" title="LEA Recovery Budget?" class="currencyInput">
            </Spedmon:DataEntryRow>

            <%/************************************* Baseline Reimbursement Projection **********************************/%>

            <Spedmon:DataEntryRow rowLabel="Enter Baseline Reimbursement Projection" runat="server">
                <input type="text" id="baselineReimbursement" name="baselineReimbursement" title="Baseline Reimbursement Projection?" class="currencyInput">
            </Spedmon:DataEntryRow>

            <%//-----------------------------------------------------------------------------%>
            <%// Contract Table %>
            <%//-----------------------------------------------------------------------------%>

            <Spedmon:HiddenTextArea ID="recContractJSON" name="recContractJSON" title="recContractJSON" runat="server" />

            <i id="addNewContract" class="fa fa-plus" title="Add New Record"></i>

            <table id="tblRecsContractJSON" class="tblRecsJSON">
                <thead>
                    <tr>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th>Contract Number</th>
                        <th>Start Date</th>
                        <th>End Date</th>
                        <th>Type of Agreement</th>
                        <th>Fee Structure</th>
                    </tr>
                </thead>
                <tbody id="tblRecsContractJSONBody" class="tblRecsJSONBody">
                </tbody>
            </table>

        </div>


<%/****************************
   * Invoices tab
   ****************************/%>

<div id="tab-invoices">

            <%/************************************* Flat Invoice **********************************/%>

            <Spedmon:DataEntryRow rowLabel="Enter Flat Invoice Amount" runat="server">
                <Spedmon:Input ID="flatinvoiceamt" name="flatinvoiceamt" title="Flat Invoice Amount" runat="server" />
            </Spedmon:DataEntryRow>

            <%//-----------------------------------------------------------------------------%>
            <%// Invoices Table %>
            <%//-----------------------------------------------------------------------------%>

            <div class="mt-5" id="restviewinvoices"></div>

</div> <!-- tab -->

        <%/****************************
           * Partner Distributions tab
        ****************************/%>

        <div id="tab-partner-distributions">
            <%//-----------------------------------------------------------------------------%>
            <%// Invoices Table %>
            <%//-----------------------------------------------------------------------------%>

            <div class="mt-5" id="restviewpartnerdistributions"></div>

        </div>


<%/****************************
   * Partner Shares Tab
   ****************************/%>

<div id="tab-partner-shares">
      <div class="container-fluid">
          
              <div class="row">
                  <div class="col-12">
                    <div class="d-flex justify-content-center">
                      <Spedmon:DataEntryBoxDate ID="initialContractStartDate" name="initialContractStartDate" label="Initial Contract Start Date" size="20" runat="server" />
                    </div>
                  </div> <!-- col -->                  
              </div> <!-- row -->

              <div class="row">
                <div class="col-12">
                  <h5 class="text-muted">Percent of Revenue From Non LEA BOP Services</h5>
                </div> <!-- col -->
              </div> <!-- row -->

              <div class="row partner-shares-pcal-services-percents-of-revenue">

                <div class="col-2">
                  <Spedmon:DataEntryBoxNumber ID="healtheKids_percent" name="healtheKids_percent" label="Health E Kids %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                </div> <!-- col -->

                <div class="col-2">
                     <Spedmon:DataEntryBoxNumber ID="cybhi_percent" name="cybhi_percent" label="CYBHI %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                </div> <!-- col -->

                <div class="col-2">
                  <Spedmon:DataEntryBoxNumber ID="crcs_percent" name="crcs_percent" label="CRCS %" size="10" min="0" max="100" title="Enter number without percent" fireSpedmonInput="true"  runat="server" />
                </div> <!-- col -->

                <div class="col-2">
                  <Spedmon:DataEntryBoxNumber ID="cdeReporting_percent" name="cdeReporting_percent" label="CDE Reporting %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                </div> <!-- col -->
                
               <div class="col-2">
                      <Spedmon:DataEntryBoxNumber ID="planImplementation_percent" name="planImplementation_percent" label="Plan Implementation %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-2">
                       <Spedmon:DataEntryBoxNumber ID="ruHealth_percent" name="ruHealth_percent" label="RU Health %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-2">
                       <Spedmon:DataEntryBoxNumber ID="newProduct2_percent" name="newProduct2_percent" label="New Product 2 %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-2">
                     <Spedmon:DataEntryBoxNumber ID="newProduct3_percent" name="newProduct3_percent" label="New Product 3 %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-8">
                  <div class="d-flex justify-content-end">                                  
                    <Spedmon:DataEntryBoxNumber ID="total_percent" name="total_percent" label="Total %" size="10" min="0" max="100" title="Enter number without percent" fireSpedmonInput="false" runat="server" />
                  </div> 
                 </div> <!-- col -->

              </div> <!-- row -->
                            
              <div class="row">
                <div class="col-12">
                  <h5 class="text-muted">Costs</h5>
                </div> <!-- col -->
              </div> <!-- row -->
           
              <div class="row partner-shares-pcal-services-percents-of-revenue" >
                  <div class="col-2">
                       <Spedmon:DataEntryBoxNumber ID="accounting_percent" name="accounting_percent" label="Accounting %" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-2">
                      <Spedmon:DataEntryBoxNumber ID="flatFee_amount" name="flatFee_amount" label="Flat Fee Amount $" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->
                 
                  <div class="col-2">
                      <Spedmon:DataEntryBoxNumber ID="clientRetention" name="clientRetention" label=" Client Retention $" size="10" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->          
              </div> <!-- row-->
          
              <div class="row">
                <div class="col-12">
                  <h5 class="text-muted">Partner Shares</h5>
                </div> <!-- col -->
              </div> <!-- row -->
              
              <div class="row partner-shares-pcal-services-percents-of-revenue" >
                  
                  <div class="col-md-1" style="max-width:10%;">
                        <Spedmon:DataEntryBoxNumber ID="csba_percent" name="csba_percent" label="CSBA %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-md-1" style="max-width:10%;">
                        <Spedmon:DataEntryBoxNumber ID="lba_percent" name="lba_percent" label="LBA %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-1" style="max-width:10%;">
                       <Spedmon:DataEntryBoxNumber ID="partner1_percent" name="partner1_percent" label=" Partner 1 %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-1" style="max-width:10%;">
                      <Spedmon:DataEntryBoxNumber ID="partner1E_percent" name="partner1E_percent" label=" Partner 1E %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                   <div class="col-1" style="max-width:10%;">
                       <Spedmon:DataEntryBoxNumber ID="partner2_percent" name="partner2_percent" label=" Partner 2 %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->
                  
              </div> <!-- row-->
               <div class="row">
                <div class="col-12">
                  <h5 class="text-muted">Custom Shares</h5>
                </div> <!-- col -->
              </div> <!-- row --> 
               <div class="row partner-shares-pcal-services-percents-of-revenue" >
                   
                  <div class="col-1" style="max-width:10%;">
                       <Spedmon:DataEntryBoxNumber ID="mba_bba_percent" name="mba_bba_percent" label="MBA BBA/DG %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-1" style="max-width:10%;">
                       <Spedmon:DataEntryBoxNumber ID="spEdCare_bba_percent" name="spEdCare_bba_percent" label="SpEdCare BBA/DG %" size="7" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                   <div class="col-1" style="max-width:10%;">
                       <Spedmon:DataEntryBoxNumber ID="smaa_1_percent" name="smaa_1_percent" label=" SMAA 1 %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-1" style="max-width:10%;">
                       <Spedmon:DataEntryBoxNumber ID="smaa_2_percent" name="smaa_2_percent" label=" SMAA 2 %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->

                  <div class="col-1" style="max-width:10%;">
                       <Spedmon:DataEntryBoxNumber ID="smaa_3_percent" name="smaa_3_percent" label=" SMAA 3 %" size="6" min="0" max="100" title="Enter number without percent" runat="server" />
                  </div> <!-- col -->
                </div>
                  
                  
               
      </div> <!-- container -->
</div> <!-- tab -->

</div> <!--tabs -->

<Spedmon:DataEntryRowSaveOrEdit
        ID="saveOrEdit"
        includeSaveAndProceedButton="false"
        editDelManageLink=""
        includeSecondarySaveButton="true"
        secondarySaveButtonLabel="Save & Proceed"
        secondarySaveButtonOnClick="navigateBasedOnSaveType(e)"
        runat="server">
</Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%/****************************
   * Scripts for options
   ****************************/%>

<script type="text/javascript">

    // onClick for the save button: navigate the user based on saveType
    function navigateBasedOnSaveType(e) {
        if ('<%=saveType%>' == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {

            // if new client, just load the edit screen
            var url = '<%=clientSaveURL%>';

            var fnGoClientEdit = function (rd) {
                // this is the code that launches the authorize record screen
                var clientEditUrl = url
                    + '&recid=' + rd.recordID
                    + '&savetype=' + $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT
                $.spedmonWebUI.gotoURL(clientEditUrl)
            };
            $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', fnGoClientEdit, true);

        }
        else {

            // if editing client, go to the home page
            $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('gohome', null, true);

        }
        
        setTimeout(
            
            function () {

            <%  //NOTE: setTimeout implementation is less than ideal %>

                MBA.RestViewCommon.fnRefreshCurrentViewFromServer($('#' + 'restviewinvoices'));
                MBA.RestViewCommon.fnRefreshCurrentViewFromServer($('#' + 'restviewpartnerdistributions'));

            },1000);   // TODO: i dont remember what this timer/timeout was for... don't remember if the other dev put it or if it was me
    }



    // Manage Spec Auth Doc Files

    function managePBSFiles() {

        var cid = $('#clientid').val();
        var fileAdditionalDataJSONStr = '{clientid:' + cid + '}';

        $.spedmonWebUI.fileList('PBS Files Associated With This Client'
            , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
            , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
            , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
            , 3
            , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
            , '<%=Spedmon.ClientPBSDocumentation.VAL_FILE_CLASS_PBS%>'
            , ''
            , 'client_management'
            , 'pbs'
            , fileAdditionalDataJSONStr
            , true
            , true);
    }

    /* Contract file management */

    function manageContractFiles() {

        var cid = $('#clientid').val();
        var fileAdditionalDataJSONStr = '{clientid:' + cid + '}';

        $.spedmonWebUI.fileList('Contract Files Associated With This Client'
            , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
            , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
            , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
            , 3
            , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
            , '<%=Spedmon.ClientContracts.VAL_FILE_CLASS_CONTRACT%>'
            , ''
            , 'client_management'
            , 'contract'
            , fileAdditionalDataJSONStr
            , true
            , true);
    }

    function calculateTotalPercentage() {
        var total = parseFloat($('#healtheKids_percent').val()) + parseFloat($('#cybhi_percent').val()) + parseFloat($('#crcs_percent').val())
            + parseFloat($('#cdeReporting_percent').val()) + parseFloat($('#planImplementation_percent').val());
        $('#total_percent').val(total);
    }
    // Init

    $(function () {

        // if recording new client: hide the tabs that require the clientID

        if ('<%=saveType%>' == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
            $('[href="#tab-contact"]').closest('li').hide();
            $('[href="#tab-contract"]').closest('li').hide();
            $('[href="#tab-invoices"]').closest('li').hide();
            $('[href="#tab-partner-shares"]').closest('li').hide();
            $('[href="#tab-special-authorizations"]').closest('li').hide();
            $('[href="#tab-school-years"]').closest('li').hide();
            $('[href="#tab-school-breaks"]').closest('li').hide();
            $('[href="#tab-practice-rules"]').closest('li').hide();
            $('[href="#tab-domains"]').closest('li').hide();
            $('[href="#tab-information-systems"]').closest('li').hide();
        }

        
        /* Only show partner shares for SpEdCare admins */

        <%if (userCanSeePartnerData == false) {%> 

            $('[href="#tab-partner-shares"]').closest('li').hide();
            $('[href="#tab-partner-distributions"]').closest('li').hide();

        <%}%>

        $('.partner-shares-pcal-services-percents-of-revenue').on('spedmoninput', function (e) {
            setTimeout(

                function () {

                    <%  //NOTE: setTimeout implementation is less than ideal %>

                    MBA.RestViewCommon.fnRefreshCurrentViewFromServer($('#' + 'restviewinvoices'));
                    MBA.RestViewCommon.fnRefreshCurrentViewFromServer($('#' + 'restviewpartnerdistributions'));

                },1000);

            calculateTotalPercentage();
            //alert("changed");
        });
        // Load values from the code-behind into the input fields.  This is because the input fields are native html5 and not server side controls
        // TODO: Refactor to use newly added DateBoxHTML5 server side control

        $('#firstcheck').val("<%=firstcheckVal%>");
        $('#claim_TCMEffectiveDate').val("<%=claim_TCMEffectiveDateVal%>");
        $('#parentConsentAgreementEffectiveDate').val("<%=parentConsentAgreementEffectiveDateVal%>");
        $('#planWriterAccessEndDate').val(_dateFormatter("<%=planWriterAccessEndDateVal%>"));
        $('#teleCommTeleHealthAccessEndDate').val(_dateFormatter("<%=TeleHealthAccessEndDateVal%>"));
        $('#teleCommTeleIEPAccessEndDate').val(_dateFormatter("<%=TeleIEPAccessEndDateVal%>"));
        $('#LEARecoveryBudget').val("<%=LEARecoveryBudgetVal%>");
        $('#hyQueueFee').val("<%=hyQueueFeeVal%>");
        $('#planWriterFee').val("<%=planWriterFeeVal%>");
        $('#baselineReimbursement').val("<%=baselineReimbursementVal%>");

        // remove the 'OK' button from the TextAreaBox
        $('#notes_but_ok').remove();
        $('#carePlanLegalLang_but_ok').remove();

        var optsSpecAuth = {};
        var optsContact = {};
        var optsContract = {};

        optsSpecAuth.RecsSpecAuthTextAreaSelector = '#recSpecAuthJSON';
        optsSpecAuth.RecsSpecAuthTableSelector = '#tblRecsSpecAuthJSON';
        optsSpecAuth.RecsSpecAuthTableBodySelector = '#tblRecsSpecAuthJSONBody';

        optsContact.RecsContactTextAreaSelector = '#recContactJSON';
        optsContact.RecsContactTableSelector = '#tblRecsContactJSON';
        optsContact.RecsContactTableBodySelector = '#tblRecsContactJSONBody';

        optsContract.RecsContractTextAreaSelector = '#recContractJSON';
        optsContract.RecsContractTableSelector = '#tblRecsContractJSON';
        optsContract.RecsContractTableBodySelector = '#tblRecsContractJSONBody';

        optsSpecAuth.clientID = $('#clientid').val();
        optsSpecAuth.tkn = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';

        optsContact.clientID = $('#clientid').val();
        optsContact.tkn = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';

        optsContract.clientID = $('#clientid').val();
        optsContract.tkn = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';

        // additional fee structure fields
        optsContract.$feeStructureCont = $('#feeStructureCont');
        optsContract.$feeDetsOK = $('#feeDetsOK');
        optsContract.$contractTerms = $('#contractTerms');
        optsContract.$evergreen = $('#evergreen');
        optsContract.$terminationDays = $('#terminationDays');
        optsContract.$annualFeeFull = $('#annualFeeFull');
        optsContract.$miscFlatFeeFull = $('#miscFlatFeeFull');
        optsContract.$annualFeeLicense = $('#annualFeeLicense');
        optsContract.$managerHourlyRate = $('#managerHourlyRate');
        optsContract.$onsiteRate = $('#onsiteRate');
        optsContract.$adminRate = $('#adminRate');
        optsContract.$numHours = $('#numHours');
        optsContract.$hoursPer = $('#hoursPer');
        optsContract.$miscFlatFeeLicense = $('#miscFlatFeeLicense');
        optsContract.$percentageRate = $('#percentageRate');
        optsContract.$miscFlatFeePercentage = $('#miscFlatFeePercentage');
        optsContract.$unitRate = $('#unitRate');
        optsContract.$miscFlatFeeTransmission = $('#miscFlatFeeTransmission');
        $('#total_percent').prop('readonly', true).attr('readonly', 'readonly');
        calculateTotalPercentage();
        // initial set-ups
        optsContract.$feeStructureCont.hide();

        SpEdCare.recSpecAuth.init(optsSpecAuth);
        SpEdCare.recContact.init(optsContact);
        SpEdCare.recContract.init(optsContract);

        /* Setup school years */

        let optsForSchoolSessionAcademicYears = {};

        optsForSchoolSessionAcademicYears.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; /* There is a hidden input for clientID defined on this page, otherwise we would use recid. */
        optsForSchoolSessionAcademicYears.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsForSchoolSessionAcademicYears.containerCtrlID = 'tab-school-years';
        optsForSchoolSessionAcademicYears.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForSchoolSessionAcademicYears.baseUrlView = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_VIEW()%>';
        optsForSchoolSessionAcademicYears.defaultPageRowOrder = '<%=Spedmon.ClientSchoolSessionAcademicYear.DEFAULT_PAGING_ORDER%>';
        optsForSchoolSessionAcademicYears.baseUrlAddNew = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_SAVE_INLINE()%>';
        optsForSchoolSessionAcademicYears.baseUrlEdit = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_SAVE_INLINE()%>'
        optsForSchoolSessionAcademicYears.baseUrlDelete = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_DELETE_INLINE()%>';
        optsForSchoolSessionAcademicYears.baseURLCompanyFiscalYearsViewSel = '<%=Spedmon.CompanyFiscalYears.URL_REST_VIEW_SEL2()%>';
        MBA.ClientSchoolSessionAcademicYearsCommon.fnSetup('restviewschoolyears', optsForSchoolSessionAcademicYears);

        /* Setup breaks */

        let optsForSchoolSessionBreaks = {};

        optsForSchoolSessionBreaks.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; /* There is a hidden input for clientID defined on this page, otherwise we would use recid. */
        optsForSchoolSessionBreaks.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsForSchoolSessionBreaks.containerCtrlID = 'tab-school-breaks';
        optsForSchoolSessionBreaks.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForSchoolSessionBreaks.baseUrlView = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_VIEW()%>';
        optsForSchoolSessionBreaks.defaultPageRowOrder = '<%=Spedmon.ClientSchoolSessionBreak.DEFAULT_PAGING_ORDER%>';
        optsForSchoolSessionBreaks.baseUrlAddNew = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_SAVE_INLINE()%>';
        optsForSchoolSessionBreaks.baseUrlEdit = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_SAVE_INLINE()%>'
        optsForSchoolSessionBreaks.baseUrlDelete = '<%=Spedmon.ClientSchoolSessionBreaks.URL_REST_DELETE_INLINE()%>';
        optsForSchoolSessionBreaks.baseURLSchoolSessionAcademicYearSel = '<%=Spedmon.ClientSchoolSessionAcademicYears.URL_REST_VIEW_SEL_INLINE()%>';
        optsForSchoolSessionBreaks.baseURLClientSiteSel = '<%=Spedmon.Sites.URL_REST_VIEW_SEL_INLINE()%>';

        MBA.ClientSchoolSessionBreaksCommon.fnSetup('restviewschoolbreaks', optsForSchoolSessionBreaks);

        /* Setup client domains */

        let optsForClientDomains = {};

        optsForClientDomains.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; /* There is a hidden input for clientID defined on this page, otherwise we would use recid. */
        optsForClientDomains.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsForClientDomains.containerCtrlID = 'tab-domains';
        optsForClientDomains.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForClientDomains.baseUrlView = '<%=Spedmon.ClientDomains.URL_REST_VIEW()%>';
        optsForClientDomains.defaultPageRowOrder = '<%=Spedmon.ClientDomain.DEFAULT_PAGING_ORDER%>';
        optsForClientDomains.baseUrlAddNew = '<%=Spedmon.ClientDomains.URL_REST_SAVE_INLINE()%>';
        optsForClientDomains.baseUrlEdit = '<%=Spedmon.ClientDomains.URL_REST_SAVE_INLINE()%>'
        optsForClientDomains.baseUrlDelete = '<%=Spedmon.ClientDomains.URL_REST_DELETE_INLINE()%>';
        optsForClientDomains.baseUrlReport = '<%=Spedmon.ClientDomains.URL_WEB_REPORT()%>';
        optsForClientDomains.defaultReportNumber = '<%=Spedmon.ClientDomainsViw.REPT_NUM_VIEW%>';

        MBA.ClientDomainsCommon.fnSetup('restviewdomains', optsForClientDomains);

        /* Setup practice family rules */

        let optsForPracticeFamilyRules = {};
        optsForPracticeFamilyRules.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; /* There is a hidden input for clientID defined on this page, otherwise we would use recid. */
        optsForPracticeFamilyRules.containerCtrlID = 'tab-practice-rules';
        optsForPracticeFamilyRules.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForPracticeFamilyRules.baseUrlView = '<%=Spedmon.ClientGroupServiceClassNameSpecificPracticeRuleSets.URL_REST_VIEW()%>';
        optsForPracticeFamilyRules.defaultPageRowOrder = '<%=Spedmon.ClientGroupServiceClassNameSpecificPracticeRuleSet.DEFAULT_PAGING_ORDER%>';
        optsForPracticeFamilyRules.baseUrlEdit = '<%=Spedmon.ClientGroupServiceClassNameSpecificPracticeRuleSets.URL_SVC_UPDATE_RULE_SET()%>';

        MBA.ClientGroupServiceClassNameSpecificPracticeRuleSetsCommon.fnSetup('restviewpracticerules', optsForPracticeFamilyRules);

        /* Setup invocies */

        let optsForInvocies = {};  // TODO: type, find/replace and fix

        optsForInvocies.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; /* There is a hidden input for clientID defined on this page, otherwise we would use recid. */

        optsForInvocies.PARM_NAME_INVOICE_INDEX = '<%=Spedmon.Constants.PARM_MANAGE_INVOICE_INDEX%>';

        optsForInvocies.containerCtrlID = 'tab-invoices';
        optsForInvocies.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForInvocies.baseUrlView = '<%=Spedmon.ClientInvoices.URL_REST_VIEW_BASE()%>';
        optsForInvocies.defaultPageRowOrder = '<%=Spedmon.ClientInvoice.DEFAULT_PAGING_ORDER%>';
        optsForInvocies.baseUrlAddNew = '';



        optsForInvocies.baseUrlEdit = '<%=Spedmon.ClientInvoices.URL_SAVE_NOTES_BASE()%>';
        optsForInvocies.baseUrlDelete = '';

        optsForInvocies.depositInfoUrl  =   '<%=Spedmon.ClientInvoices.URL_SAVE_DEPOSIT_INFO_BASE()%>';
        optsForInvocies.pmtInfoUrl      =   '<%=Spedmon.ClientInvoices.URL_SAVE_PMT_INFO_BASE()%>';

        optsForInvocies.reportBaseUrl         = '<%=Spedmon.ClientInvoices.URL_WEB_REPORT_BASE()%>';
        optsForInvocies.isPcalStaff           = true;
        optsForInvocies.userCanSeePartnerData = <%=userCanSeePartnerDataJSBoolStr%>;

        optsForInvocies.showClientName = false;

        optsForInvocies.showConsultantName= true;

        optsForInvocies.isManageInvoiceScreen = true;

        optsForInvocies.inclPartner1Col      =    false;
        optsForInvocies.inclCybhiRows        =    false;

        optsForInvocies.inclRetentionCol     =    false;

        MBA.ClientInvoicesCommon.fnSetup('restviewinvoices', optsForInvocies);


        let optsForpartnerdistributions = {};
          // TODO: odd capitalization, find/replace to fix


        optsForpartnerdistributions.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; /* There is a hidden input for clientID defined on this page, otherwise we would use recid. */


        optsForpartnerdistributions.containerCtrlID = 'tab-invoices';
        optsForpartnerdistributions.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForpartnerdistributions.baseUrlView = '<%=Spedmon.ClientInvoices.URL_REST_VIEW_BASE()%>';
        optsForpartnerdistributions.defaultPageRowOrder = '<%=Spedmon.ClientInvoice.DEFAULT_PAGING_ORDER%>';
        optsForpartnerdistributions.baseUrlAddNew = '';

        optsForpartnerdistributions.calcShares = true;

///

        optsForpartnerdistributions.baseUrlEdit = '<%=Spedmon.ClientInvoices.URL_SAVE_NOTES_BASE()%>';
        optsForpartnerdistributions.baseUrlDelete = '';

        optsForpartnerdistributions.depositInfoUrl  =   '<%=Spedmon.ClientInvoices.URL_SAVE_DEPOSIT_INFO_BASE()%>';
        optsForpartnerdistributions.pmtInfoUrl      =   '<%=Spedmon.ClientInvoices.URL_SAVE_PMT_INFO_BASE()%>';

        optsForpartnerdistributions.reportBaseUrl         = '<%=Spedmon.ClientInvoices.URL_WEB_REPORT_BASE()%>';
        optsForpartnerdistributions.isPcalStaff           = true;
        optsForpartnerdistributions.userCanSeePartnerData = <%=userCanSeePartnerDataJSBoolStr%>;

        optsForpartnerdistributions.showConsultantName= false;
        optsForpartnerdistributions.showBasicInvoiceData = false;

        optsForpartnerdistributions.showDistBreakdownsDollarAmounts = true;

        optsForpartnerdistributions.inclPartner1Col      =    false;
        optsForpartnerdistributions.inclCybhiRows        =    false;

        optsForpartnerdistributions.inclRetentionCol     =    false;


///
        MBA.ClientInvoicesCommon.fnSetup('restviewpartnerdistributions', optsForpartnerdistributions);

        /* Setup Client Student Information Systems */

        let optsForClientStudentInfoSystems = {};

        optsForClientStudentInfoSystems.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>'; /* There is a hidden input for clientID defined on this page, otherwise we would use recid. */
        optsForClientStudentInfoSystems.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsForClientStudentInfoSystems.PARM_NAME_API_URL     = '<%=Spedmon.Constants.PARM_API_URL%>';
        optsForClientStudentInfoSystems.PARM_NAME_API_TOKEN = '<%=Spedmon.Constants.PARM_API_TOKEN%>';

        optsForClientStudentInfoSystems.containerCtrlID = 'tab-information-systems';
        optsForClientStudentInfoSystems.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForClientStudentInfoSystems.baseUrlView = '<%=Spedmon.ClientStudentInformationSystems.URL_REST_VIEW_BASE()%>';
        optsForClientStudentInfoSystems.defaultPageRowOrder = '<%=Spedmon.ClientStudentInformationSystem.DEFAULT_PAGING_ORDER%>';
        optsForClientStudentInfoSystems.baseUrlAddNew = '<%=Spedmon.ClientStudentInformationSystems.URL_SVC_SAVE_INLINE_BASE()%>';  
        optsForClientStudentInfoSystems.baseUrlEdit = '<%=Spedmon.ClientStudentInformationSystems.URL_SVC_SAVE_INLINE_BASE()%>'
        optsForClientStudentInfoSystems.baseUrlDelete = '<%=Spedmon.ClientStudentInformationSystems.URL_SVC_DELETE_INLINE_BASE()%>';
        optsForClientStudentInfoSystems.baseURLStudentInfoSystemsViewSel = '<%=Spedmon.StudentInformationSystems.URL_SVC_VIEW_SEL_BASE()%>';
        optsForClientStudentInfoSystems.clientShortName = '<%=clientShortName%>';
        optsForClientStudentInfoSystems.baseURLAriesTestPage = '<%=baseUrlAriesTestPage%>';
        
        MBA.ClientStudentInformationSystemsCommon.fnSetup('restviewclientstudentinfosystems', optsForClientStudentInfoSystems);
    });

</script>
