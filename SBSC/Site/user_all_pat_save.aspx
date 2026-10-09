<%@ Page Language="C#" CodeBehind="user_all_pat_save.aspx.cs" Inherits="Spedmon.UserAllPatientSave" %>

<Spedmon:HiddenInput ID="pracid"   name="pracid"   title="pracid"   runat="server" />
<Spedmon:HiddenInput ID="groupid"  name="groupid"  title="groupid"  runat="server" />
<Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
<Spedmon:HiddenInput ID="dos" name="dos" title="dos" runat="server" />
<Spedmon:HiddenInput ID="practitionerpatientcaseloadexpectedserviceid" name="practitionerpatientcaseloadexpectedserviceid"  title="Select Plan from IEP" runat="server" />
<Spedmon:HiddenInput ID="active" name="active" title="active" value="1" noClear="true" runat="server" />

<Spedmon:DataEntryRows ID="save" useBootstrapFluid="true" runat="server" dataURL="patients.asmx/save" >
    
    <Spedmon:HiddenInput ID="patid" name="patid" title="record id" runat="server"/>
    
    <%//#####################################################################################################%>
    <%//                                       Select Client                                                 %>
    <%//#####################################################################################################%>

    <Spedmon:DataEntryRowSelectClient
        ID              = "selectClient" 
        entityControlID = "clientid"                
        rowLabel        = "Client" 
        runat           = "server">
    </Spedmon:DataEntryRowSelectClient> 

    <%//#####################################################################################################%>
    <%//                                  Basic Patient Info Rows                                             %>
    <%//#####################################################################################################%>

    <div id="patNameCont" class="row basic-info">

      <%/************************************* Name **********************************/%>
       
       <div class="col-2">
         <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Patient's Name" runat="server">
            <Spedmon:Input ID="lname" name="lname" cssInline="width:5em" title="Last Name"   runat="server" />
            <Spedmon:Input ID="fname" name="fname" cssInline="width:5em;" title="First Name"  runat="server" />
            <Spedmon:Input ID="mname" name="mname" cssInline="width:2em;" title="Middle Name" runat="server" />
          </Spedmon:DataEntryRow>
       </div> <!-- col -->

        <%/************************************* Nickname **********************************/%>
        
        <div class="col-2">
          <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Preferred/Nickname" runat="server">
            <Spedmon:Input ID="p_nickname" name="p_nickname" cssInline="width:7em" title="Preferred Name or Nickname" runat="server" />
          </Spedmon:DataEntryRow>
        </div> <!-- col -->

       <%/************************************* Date of Birth **********************************/%>

       <div class="col-2">
          <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Date of Birth" runat="server">
             <Spedmon:DateBoxHTML5 ID="dob" name="dob" title="Select or Enter Date of Birth" runat="server"/>
          </Spedmon:DataEntryRow>
       </div> <!-- col -->
  
        <%/************************************* Gender **********************************/%>
        
        <div class="col-2">     
          <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Gender" runat="server">
             <Spedmon:SelectMaleOrFemale id="sex" name="sex" title="Select Gender" renderLabel="false" runat="server" />
          </Spedmon:DataEntryRow>        
        </div> <!-- col -->  

       <%/************************************* SSID **********************************/%>

       <div class="col-2">
         <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Statewide Student Identifier (SSID)" runat="server">
            <Spedmon:TextBox ID="csis" name="csis" title="Enter SSID" maxlen="10" showOK="false" cssInline="width:10em;" runat="server" />
          </Spedmon:DataEntryRow>
       </div> <!-- col -->

     <%//---------------------------------%>
     <%// Referr Patient                  %>
     <%//---------------------------------%>
     
    <div class="col-2">
     <div class="d-flex d-flex justify-content-end">
     <%if(canReferPatient ==true){%>
       <Spedmon:DataEntryButton ID="btn_for_pat_ref" style="PRIMARY" iconOnly="false" faIcon="fas fa-people-arrows" label="Create/Manage Referrals" onclick="doReferrPatient()" runat="server" />
     <%}%>
     </div>
     </div>


    </div> <!-- row -->

 
    <%//#####################################################################################################%>
    <%//                                                Tabs                                                 %>
    <%//#####################################################################################################%>

    <div class="row mt-5">
    <div class="col-12">
    <div id="pattabs">
        <ul>
            <li><a href = "#tab-profile">Profile</a></li>
            <li><a href = "#tab-medical-history">Medical History</a></li>
            <li><a href = "#tab-contacts">Contacts</a></li>
            <li><a href = "#tab-insurance-carriers">Insurance Carriers</a></li>
            <li><a href = "#tab-services">Orders & Prescriptions</a></li>
            <li><a href = "#tab-promised-services">Related Services</a></li>
            <li><a href = "#tab-goals">Goals</a></li>
            <li><a href = "#tab-transportation">Transportation</a></li>
            <li><a href = "#tab-documentation">Documentation</a></li>
            <li><a href = "#tab-files">Files</a></li>
            <li><a href = "#tab-sped-iep">SpEd</a></li>
        </ul>

        <%//=============================================================================%>
        <%//                                  Profile %>
        <%//=============================================================================%>

        <div id="tab-profile">
   
        <div class="container-fluid">
        
        <div id="patNameCont2" class="row basic-info">

         <%/************************************* School Site **********************************/%>
       
          <div class="col-3">
            <Spedmon:DataEntryRow rowLabel="School Site" useBootstrapGrid="false" runat="server">
              <Spedmon:ComboBox ID="siteid" name="siteid" title="Select Site" dataPrivate="true" dataURL="sites.asmx/viewSel" dataParms="[{id:'clientid'}]" runat="server" />
            </Spedmon:DataEntryRow>
          </div> <!-- col -->

         <%/************************************* Grade **********************************/%>
       
         <div class="col-1">
           <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Grade" runat="server">
             <Spedmon:TextBox ID="grade" name="grade" title="Enter grade" maxlen="2" cssInline="width:3em" showOK="false" runat="server" />
           </Spedmon:DataEntryRow>
         </div> <!-- col -->

       
         <%/************************************* Student ID **********************************/%>
       
         <div class="col-2">
           <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Student ID" runat="server">
             <Spedmon:TextBox ID="studentid" name="studentid" title="Enter Student ID" maxlen="50" cssInline="width:10em" showOK="false" runat="server" />
          </Spedmon:DataEntryRow>
         </div> <!-- col -->

        <%/************************************* Teacher or Counselors Name **********************************/%>
       
         <div class="col-3">
         <Spedmon:DataEntryRow rowLabel="Teacher Or Counselor's Name" useBootstrapGrid="false" runat="server">
          <Spedmon:Input ID="teacher_name" name="teacherorcounselorname" title="Teacher or Counselor Name" runat="server" />
         </Spedmon:DataEntryRow>
         </div> <!-- col -->
           
        <%/************************************* IEP/IFSP **********************************/%>
       
        <div class="col-3">
          <Spedmon:DataEntryRow rowLabel="Does this patient have an IFSP/IEP?" useBootstrapGrid="false" runat="server">
            <Spedmon:SelectYesOrNo ID="hasplan" name="hasplan" title="Has Plan" renderLabel="false" runat="server" />
          </Spedmon:DataEntryRow>
        </div> <!-- col -->

       </div> <!-- row -->

       <div class="row">
       
       <%/************************************* FERPA Consent **********************************/%>
       
       <div class="col-4">
            <Spedmon:DataEntryRow ID="ferpaConsentRow" useBootstrapGrid="false" rowLabel="Has the district received FERPA Consent for this patient?" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNoOrUnknown ID="ferpaconsent" name="ferpaconsent" title="FERPA Consent" renderLabel="false" runat="server" />
                    <Spedmon:DataEntryBoxDate ID="ferpaconsenteffectivedate" name="ferpaconsenteffectivedate" title="FERPA Consent Effective Date" runat="server" />
                </div>
            </Spedmon:DataEntryRow>
       </div> <!-- col -->
       
       <%/************************************* Treatment Consent **********************************/%>
       
       <div class="col-4">
            <Spedmon:DataEntryRow ID="treatmentConsentRow" useBootstrapGrid="false" rowLabel="Has the district received consent to treat for this patient?" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNoOrUnknown ID="treatmentconsent" name="treatmentconsent" title="Treatment Consent" renderLabel="false" runat="server" />
                    <Spedmon:DataEntryBoxDate ID="treatmentconsenteffectivedate" name="treatmentconsenteffectivedate" title="Treatment Consent Effective Date" runat="server" />
                </div>
            </Spedmon:DataEntryRow>
       </div> <!-- col -->
      
       <%/************************************* LEA BOP Parent Consent **********************************/%>
       
       <div class="col-4">

            <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Has the district received parental consent to bill Medi-Cal for this patient for the LEA BOP?" runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNoOrUnknown ID="parentConsentMCAL" name="parentConsentMCAL" title="Medi-cal parental consent" renderLabel="false" runat="server" />
                    <Spedmon:DateBoxHTML5 ID="parentConsentMCALEffectiveDate" name="parentConsentMCALEffectiveDate" title="parentConsentMCAL Effective Date" runat="server" />
                </div>
            </Spedmon:DataEntryRow>
       </div>

       </div> <!-- row -->

       <div class="row">
       
        
      
       </div> <!-- row -->
             

       

       <div class="row">

        
       <%/************************************* Language **********************************/%>
        
       <div class="col-3">
        <Spedmon:DataEntryRowSelectSpEdLanguage
             ID                   = "dataEntryRowSelectStudentLanguageCode" 
             entityControlID      = "spedstudentlanguagecodeid"             
             rowLabel             = "Language"
             useBootstrapGrid     = "false"
             runat                = "server">
         </Spedmon:DataEntryRowSelectSpEdLanguage>
        </div> <!-- col -->

        <%/************************************* Race **********************************/%>

        <div class="col-3">
        <Spedmon:DataEntryRow id="dataEntryRowSelectStudentRace" rowLabel="Race" useBootstrapGrid="false" runat="server">
            <Spedmon:ComboBox 
              ID          = "spedstudentracecode" 
	          name        = "spedstudentracecode" 	
	          title       = "Race" 
	          dataPrivate = "true" 
	          dataURL     = "sped_races.asmx/viewSel"
	          runat       = "server" />     
        </Spedmon:DataEntryRow>
        </div> <!-- col -->
        
        <%/************************************* SSN **********************************/%>

        <div class="col-3">
          <Spedmon:DataEntryRow useBootstrapGrid="false" rowLabel="Social Security Number (SSN)" runat="server">
          <Spedmon:TextBox ID="ssn" name="ssn" title="Enter With No Dashes" maxlen="9" showOK="false" runat="server" />            
          </Spedmon:DataEntryRow>
        </div> <!-- col -->

        <%/************************************* In Transitional Housing **********************************/%>
    
        <div class="col-3">
           <Spedmon:DataEntryRow ID="DataEntryRowTransHousing" useBootstrapGrid="false" rowLabel="In Transistional Housing?" runat="server">      
             <Spedmon:SelectYesOrNo ID="inTransitionalHousingStatus" name="intransitionalhousingstatus" title="In Transitional Housing?" renderLabel="false" runat="server" />
           </Spedmon:DataEntryRow>
        </div> <!-- col -->

       </div> <!-- row -->


      <div class="row">
   
      <%/************************************* Submit LEA BOP Claims **********************************/%>

         <div class="col-6">
            <Spedmon:DataEntryRow ID="submitclaimsDataEntryRow" useBootstrapGrid="false" rowLabel="Do you want to submit claims for this patient for the LEA BOP? If you are NOT sure ANSWER Yes." runat="server">
                <div class="d-flex">
                    <Spedmon:SelectYesOrNo ID="submitclaims" name="submitclaims" title="Submit Claims for LEA BOP" renderLabel="false" runat="server" />
                    <Spedmon:DateBoxHTML5 ID="submitClaimsEffectiveDate" name="submitClaimsEffectiveDate" title="Submit Claims for LEA BOP Effective Date" runat="server" />
                </div>
            </Spedmon:DataEntryRow>
        </div> <!-- col -->

        <%/************************************* BIC **********************************/%>

        <div class="col-6">
             <Spedmon:DataEntryRow ID="bicDataEntryRow" useBootstrapGrid="false" rowLabel="Medi-Cal Benefits Identification Card Number (BIC)" runat="server">
                <Spedmon:TextBox ID="bic" name="bic" title="Enter BIC" maxlen="14" showOK="false" runat="server" />
            </Spedmon:DataEntryRow>
        </div> <!-- col -->

        
        </div> <!-- row -->
        
      <div class="row">
       
       <%/************************************* CYBHI Claims **********************************/%>

       <div class="col-3">
            <Spedmon:DataEntryRow id="cybhiTpaSubmitClaimsRow" useBootstrapGrid="false" rowLabel="Submit CYBHI Claims? <br><sub>Only set to No if client is participating in CYBHI and we need to hold all CYBHI claims for this patient.</sub>" runat="server">
                <Spedmon:SelectYesOrNo ID="cybhisubmitclaims" name="cybhisubmitclaims" title="Submit CYBHI Claims?" renderLabel="false" runat="server" />
            </Spedmon:DataEntryRow>
       </div><!-- col -->

      <%/************************************* CYBHI TPA Approved **********************************/%>

       <div class="col-3">
          <Spedmon:DataEntryRow ID="cybhiTpaApprovedRow" useBootstrapGrid="false" rowLabel="CYBHI TPA Approved:" runat="server">
           <div class="d-flex">
               <Spedmon:SelectYesOrNo ID="cybhitpaapproved" name="cybhitpaapproved" title="CYBHI TPA Approved" renderLabel="false" runat="server" />
           </div>
         </Spedmon:DataEntryRow>
       </div> <!-- col -->
 
       
     <%/************************************* CYBHI TPA Approved On **********************************/%>
     <div class="col-3">
       <Spedmon:DataEntryRow ID="cybhiTpaApprovedOnRow" useBootstrapGrid="false" rowLabel="CYBHI TPA Approved On:" runat="server">
          <div class="d-flex">
               <Spedmon:DataEntryBoxDate  ID="cybhitpaapprovedon" name="cybhitpaapprovedon" title="CYBHI TPA Approved On"  runat="server" />
          </div>
       </Spedmon:DataEntryRow>
     </div> <!-- col -->
       
      <%/************************************* CYBHI TPA ID **********************************/%>
      <div class="col-3">
         <Spedmon:DataEntryRow ID="cybhiTpaIDRow" useBootstrapGrid="false" rowLabel="CYBHI TPA ID:" runat="server">
           <div class="d-flex">
             <Spedmon:DataEntryBoxText ID="cybhitpaid" name="cybhitpaid"  title="CYBHI TPA ID" runat="server" />
          </div>
         </Spedmon:DataEntryRow>
       </div> <!-- col -->

     </div> <!-- row -->
      
      <%/************************************* Notes (PCAL Staff Only) **********************************/%>
      
      <div class="row">
        <div class="col-12">
        <Spedmon:DataEntryRow ID="notesDataEntryRow" useBootstrapGrid="false" runat="server">
        <div class="ui-spedmon-data-entry-col ui-spedmon-data-entry-col-label text-center"><h5>Notes<br><sub>Practi-Cal Staff Only</sub></h5></div> 
        <Spedmon:TextAreaBox ID="notes" name="notes" title="Enter notes" runat="server"></Spedmon:TextAreaBox>
        </Spedmon:DataEntryRow>
        </div> <!-- col -->
      </div> <!-- row -->
      
        </div> <!-- container -->
      </div> <!-- tab -->

        <%//=============================================================================%>
        <%//                            Medical History %>
        <%//=============================================================================%>

       <div id="tab-medical-history">      
       <div class="container-fluid">

       <div class="row">

      <%//---------------------------------%>
      <%// Known Health Problems           %>
      <%//---------------------------------%>

     <div id="datamanagerowsrestviewpatientknownhealthproblems" class="col-3">
       <div id="restviewpatientknownhealthproblems" class="rest-view-display-minimal"></div> <!-- rest view -->
     </div> <!-- col -->

    <%//---------------------------------%>
    <%// Allergies                       %>
    <%//---------------------------------%>

   <div id="datamanagerowsrestviewpatientallergies" class="col-3">
     <div id="restviewpatientallergies" class="rest-view-display-minimal"></div> <!-- rest view -->
  </div> <!-- col -->

   <%//---------------------------------%>
   <%// Diagnoses                       %>
   <%//---------------------------------%>

   <div id="datamanagerowsrestviewpatientdiagnoses" class="col-6">
    <div id="restviewpatientdiagnoses" class="rest-view-display-minimal"></div> <!-- rest view -->
  </div> <!-- col -->
  </div> <!-- row -->

<%//---------------------------------%>
<%// Care Notes Component            %>
<%//---------------------------------%>

<% if (canUsePreCareNotes == true) { %>
<div class="row tab-subsection-divider">
    <div id="manageviewpatientcarenotes" class="col-12 my-4 p-4">

        <div id="patientcarenotescomponent"></div>
    </div>
</div><!-- care notes row -->
<%} %>

<%//---------------------------------%>
<%// Practice Office Visits          %>
<%//---------------------------------%>

<% if (canViewVisitHistory == true) { %>                        
<div class="row tab-subsection-divider">   
    <div class="col-12">        
    <%if (canStartNewVisit == true) {%>
        <Spedmon:DataEntryButton ID="mgn_pat_butStartVisit" cssClass="btn btn-success btn_create_new_visit mb-3" iconOnly="false" faIcon="fa fa-plus-circle fa-2x newvisiticon" title="Start A New Visit" runat="server" />
    <%}%>
        <div class="manage-patient-label">Visit History</div>
    </div>
    <div id="manageviewvisitscontainer" class="col-12 my-4 p-4">
        <div id="visitscomponentview" >                                    
        </div>
    </div>
</div><!-- practice office visits row -->
<%} %>

<%//---------------------------------%>
<%// Medication Adminstration        %>
<%//---------------------------------%>

<%if (canAdministerOrdersOrPx == true) { %>                        
<div class="row tab-subsection-divider">  
    <div class="manage-patient-label">Order or Prescriptions </div>
    <div id="managevieworderorpxcontainer" class="col-12 my-4 p-4">                                
        <div id="orderorpxcomponentview">                                    
        </div>
    </div>
</div>
<!-- orders or px row -->
<%}%>

<%//---------------------------------%>
<%// Record Scheduled Services       %>
<%//---------------------------------%>

<%if (canRecordScheduledServices == true) { %>
<div class="row tab-subsection-divider">    
    <div id="scheduledservicesforpracandpatondoscont" class="col-12 my-2 p-2">    
        <div id="scheduledservicesforpracandpatondosview">                                    
        </div>
    </div>
</div> <!-- scheduled service record row-->
<%}%>

<%//---------------------------------%>
<%// Vital Signs                     %>
<%//---------------------------------%>

<% if (canAdministerVitalSigns == true)
    { %>
<div class="row tab-subsection-divider">  
    <div class="manage-patient-label">Vital Signs</div>
    <div id="manageviewvitalsignscontainer" class="col-12 my-4 p-4">                               
        <div id="vitalsignscomponentview">                                     
        </div>
    </div>
</div>
<!-- vital signs row -->
<%} %>


  </div> <!-- container -->
       </div> <!-- tab -->
  
        <%//=============================================================================%>
        <%//                               Contacts %>
        <%//=============================================================================%>

        <div id="tab-contacts">      
        <div class="container-fluid">
        <div id="datamanagerowsrestviewpatientpersons" class="row">
        <div class="col-12">
        <div id="restviewpatientpersons"></div>
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
        </div> <!-- contacts -->

        <%//=============================================================================%>
        <%//                      Insurance Carriers %>
        <%//=============================================================================%>

        <div id="tab-insurance-carriers">
           <div id="dataManagementRowsForInsuranceCarriers" class="container-fluid">
                <div id="restViewOrdersInsuranceCarriers" class="row mt-2">
                    <div class="col-12">
                        <div id="insuranceCarriersRestView"></div>
                    </div> <!-- col -->
                </div> <!--row -->
            </div>
        </div>

        <%//=============================================================================%>
        <%//                      Orders and Prescriptions %>
        <%//=============================================================================%>

        <div id="tab-services">
     <!--   <Spedmon:HiddenTextArea ID="recServiceJSON" name="recServiceJSON" title="recServiceJSON" runat="server" /> -->
        <div class="container-fluid">
        <div id="datamanagerowsrestviewordersorprescriptions" class="row">
        <div class="col-12">
        <div id="restviewordersorprescriptions"></div> <!-- restview -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
        </div> <!-- orders and prescriptions -->
        
        <%//=============================================================================%>
        <%//             IEP Related Services (Promised Services) %>
        <%//=============================================================================%>

        <div id="tab-promised-services">      
        <div class="container-fluid">
        <div id="datamanagerowsrestviewpatientpromisedservices" class="row">
        <div class="col-12">
        <div id="restviewpatientpromisedservices"></div><!-- rest view -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
        </div> <!-- iep related services -->

        <%//=============================================================================%>
        <%//                             Transportation %>
        <%//=============================================================================%>

        <div id="tab-transportation">

            <Spedmon:HiddenTextArea ID="recTransportationJSON" name="recTransportationJSON" title="recTransportationJSON" runat="server" />

            <div id="transportationFieldsCont">
                <div>
                    <Spedmon:CheckBox ID="speciallyAdaptedVehicleForTransportation" name="speciallyAdaptedVehicleForTransportation" firedataselected="false" title="speciallyAdaptedVehicleForTransportation" defaultValue="false" useDefaultValue="true" runat="server" />
                    <span> Student receives medically necessary transportation on a specially adapted vehicle</span>
                </div>

                <Spedmon:Button title="Add a New Stop" ID="addNewStopBut" runat="server">
                    <i class="fas fa-building fa-2x fa-stack-1x"></i>
                    <i class="fa fa-plus fa-2x fa-stack-1x fa-sm"></i>
                </Spedmon:Button>
            </div>

            <i id="addNewTransportation" class="fa fa-plus" title="Add New Record"></i>

            <table id="tblRecsTransportationJSON" class="tblRecsJSON">
                <thead>
                <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th>Pick Up Location</th>
                    <th>Drop Off Location</th>
                    <th>Route Name</th>
                    <th>Miles</th>
                    <th>Days</th>
                </tr>
                </thead>
                <tbody id="tblRecsTransportationJSONBody" class="tblRecsJSONBody">
                </tbody>
            </table>

        </div>

        <%//=============================================================================%>
        <%//                                  Goals  %>
        <%//=============================================================================%>

        <div id="tab-goals">


           <div id="dataManagementRowsForGoals" class="container-fluid">

                <%//-----------------------------------------------------------------------------%>
                <%// Instructions %>
                <%//-----------------------------------------------------------------------------%>

                <div class="mb-3 font-weight-bold">Any edits to an existing goal will update all previously recorded service records. If you do not want the goal updated for saved records, create a new goal. Deleting a goal will not affect saved service records.</div>

                <%//-----------------------------------------------------------------------------%>
                <%// Rest View %>
                <%//-----------------------------------------------------------------------------%>

                <div id="restViewOrdersPrescriptionsRow" class="row mt-2">
                    <div class="col-12">
                        <div id="goalsRestView"></div>
                    </div> <!-- col -->
                </div> <!--row -->

        </div>

        </div>

        <%//=============================================================================%>
        <%//                               Service Records %>
        <%//=============================================================================%>

        <div id ="tab-documentation">
        <div id="datamanagerowsrestviewservicerecords" class="container-fluid">
        <div class="row">
        <div class="col-12">
        <div id="restviewservicerecords"></div> <!-- rest view -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
        </div> <!-- services and documentation -->

        <%//=============================================================================%>
        <%//                                    Files %>
        <%//=============================================================================%>

        <div id ="tab-files">
        <div id="datamanagerowsrestviewstoredfiles" class="container-fluid">
        <div class="row">
        <div class="col-12">
        <!-- <Spedmon:HiddenTextArea ID="recFileJSON" name="recFileJSON" title="recFileJSON" runat="server" /> -->
        <div id="restviewstoredfiles"></div><!-- rest view -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
        </div> <!-- files -->

        <%//=============================================================================%>
        <%//                                  SpEd Tabs %>
        <%//=============================================================================%>

        <div id="tab-sped-iep">

            <div id="patspedtabs"> 
                <ul>
                    <li><a href = "#tab-sped-iep-overview">Overview</a></li>
                    <li><a href = "#tab-sped-iep-meeting-purpose">Meeting Purpose</a></li>
                    <li><a href = "#tab-sped-iep-team-members">Team Members</a></li>
                    <li><a href = "#tab-sped-iep-schedule-meeting">Schedule Meeting</a></li>
                    <li><a href = "#tab-sped-iep-present-levels">Present Levels</a></li>
                    <li><a href = "#tab-sped-iep-eligibility-information">Eligibility Information</a></li>
                    <li><a href = "#tab-sped-iep-special-considerations-and-behavior">Special Considerations & Behavior</a></li>
                    <li><a href = "#tab-sped-iep-transition">Transition</a></li>
                    <li><a href = "#tab-sped-iep-accommodations">Accommodations</a></li>
                    <li><a href = "#tab-sped-iep-goals">Goals</a></li>
                    <li><a href = "#tab-sped-iep-provisions">Provisions</a></li>
                    <li><a href = "#tab-sped-iep-lre-placement">LRE Placement</a></li>
                    <li><a href = "#tab-sped-iep-summary-of-performance">Summary of Performance</a></li>
                    <li><a href = "#tab-sped-iep-create-iep">Create IEP</a></li>
                    <li><a href = "#tab-sped-iep-student-history">Student History</a></li>
                </ul>

                <div class="row mb-2"> <%-- row --%>
                	
                    <div class="col">                 
                  		<Spedmon:DataEntryBoxText ID="spedcasemanagername" name="spedcasemanagername" label="SpEd Case Manager" title="Enter name of current case manager" runat="server" />            
                	</div>
                
                    <div class="col">
                        <span style="display:flex">               
                        <Spedmon:DataEntryBoxDate ID="spedlastevaldate" name="spedlastevaldate" label="Last Evaluation" title="Date of Last Evaluation" size="7" runat="server"/>
                        <Spedmon:DataEntryBoxDate ID="spednextevaldate" name="spednextevaldate" label="Next Evaluation" title="Date of Next Evaluation" size="7" runat="server"/>
                        </span>
                    </div>                    
                    <div class="col">
                        <span style="display:flex">
                        <Spedmon:DataEntryBoxDate ID="spedlastannualiepdate" name="spedlastannualiepdate" label="Last Annual IEP" title="Date of Last Annual IEP" size="7" runat="server"/>
                        <Spedmon:DataEntryBoxDate ID="spedcuriepdate" name="spedcuriepdate" label="Current IEP" title="Current IEP Date" size="7" runat="server"/>
                        <Spedmon:DataEntryBoxDate ID="spednextannualiepdate" name="spednextannualiepdate" label="Next Annual IEP" title="Date of Next Annual IEP" size="7" runat="server"/>
                        </span>
                   </div>
                    <div class="col">    
                        <span style="display:flex">
                        <Spedmon:DataEntryBoxDate ID="spedenteredspeddate" name="spedenteredspeddate" size="7" required="false" label="Entered SpEd On" title="Enter date that this patient initially entered Special Ed" runat="server" />                                        	
                        <Spedmon:DataEntryBoxDate ID="spedexitedspeddate" name="spedexitedspeddate" size="7" required="false" label="Exited SpEd On" title="Enter date that this patient exited Special Ed" runat="server" />
                        </span>
                	</div>
                	
                </div> <%-- end of row --%>
                
                <hr />

                <div id="tab-sped-iep-overview">                    

                    <div class="row"> <%-- row --%>

                        <div class="col-12 col-md-6 col-xl-3 d-flex align-items-center mt-3">

                            <%/************************************* Disability 1 Code **********************************/%>

                            <Spedmon:DataEntryRowSelectSpEdDisabilityCode
                                ID                   = "SelectDisability1Code" 
                                entityControlID      = "speddisability1code"                
                                rowLabel             = "Disability 1 Code"
                                dataEntryRowRenderAs = "FIELD"
                                onSpedmonInputData   = "updateOtherTabsDisability1(e.dataitem)"
                                runat                = "server">
                            </Spedmon:DataEntryRowSelectSpEdDisabilityCode>

                        </div>

                        <div class="col-12 col-md-6 col-xl-3 d-flex align-items-center mt-3">

                            <%/************************************* Disability 2 Code **********************************/%>

                            <Spedmon:DataEntryRowSelectSpEdDisabilityCode
                                ID                   = "SelectDisability2Code" 
                                entityControlID      = "speddisability2code"                
                                rowLabel             = "Disability 2 Code"
                                dataEntryRowRenderAs = "FIELD"
                                onSpedmonInputData   = "updateOtherTabsDisability2(e.dataitem)"
                                runat                = "server">
                            </Spedmon:DataEntryRowSelectSpEdDisabilityCode>

                        </div>

                        <div class="col-12 col-md-6 col-xl-3">

                            <%/************************************* Special Trans (SpEd) **********************************/%>

                            <Spedmon:DataEntryRow rowLabel="Special Transportation" runat="server">
                                <Spedmon:SelectYesOrNo ID="spedspecialtransportation" name="spedspecialtransportation" title="Special Transportation" renderLabel="false" runat="server" />
                            </Spedmon:DataEntryRow>

                        </div>

                        <div class="col-12 col-md-6 col-xl-3">

                            <%/************************************* Specialy Adapted Vehicle **********************************/%>

                            <div class="pt-3 mt-2">
                                <Spedmon:CheckBox ID="speciallyAdaptedVehicleForTransportation_copy" name="speciallyAdaptedVehicleForTransportation_copy" firedataselected="false" title="speciallyAdaptedVehicleForTransportation" defaultValue="false" useDefaultValue="true" runat="server" />
                                <span> Student receives medically necessary transportation on a specially adapted vehicle</span>
                            </div>

                        </div>
                    </div> <%-- end of row --%>
                    
                    <div id="dataManagementRowsForSpEdIepServices" class="container-fluid">

                    <div class="row mt-3">
                    <div class="col-12">
 
                        <Spedmon:HiddenTextArea ID="spedservicesdatajson" name="spedservicesdatajson" title="spedservicesdatajson" runat="server"/>

                        <div id="restViewSpEdIepServices">                   
                        </div>
 
                   </div> <!-- col -->
                   </div> <!-- row -->

                  </div>

                    <hr />

                    <fieldset class="mba-data-entry-box">
                    <legend class="text-center py-2"><h5>Language Information</h5></legend>
                    <div class="d-flex flex-wrap justify-content-center align-items-center" >
                        <div class="col-auto">
                            <Spedmon:SelectYesOrNo ID="spedstudentlanguageenglishlearner" name="spedstudentlanguageenglishlearner" title="English Learner" renderLabel="true" runat="server" />
                        </div>
                        <div class="col-auto">
                            <span>
                            <Spedmon:CheckBox ID="spedstudentlanguageinforeclassified" name="spedstudentlanguageinforeclassified" firedataselected="false" title="spedstudentlanguageinforeclassified" defaultValue="false" useDefaultValue="true" runat="server" />
                            <span> Reclassified</span>
                            </span>
                        </div>
                        <div class="col-auto">
                            <Spedmon:SelectYesOrNo ID="spedstudentlanguageenglishlearnerundesignatedpreschool" name="spedstudentlanguageenglishlearnerundesignatedpreschool" title="English Learner-Undesignated (preschool)" renderLabel="true" runat="server" />
                        </div>
                        <div class="col-auto">
                            <Spedmon:SelectYesOrNo ID="spedstudentlanguageinterpreterneeded" name="spedstudentlanguageinterpreterneeded" title="Interpreter" renderLabel="true" runat="server" />
                        </div>
                        <div class="col-auto">
                            <Spedmon:SelectYesOrNo ID="spedstudentlanguagetranslationrequested" name="spedstudentlanguagetranslationrequested" title="Translation Requested" renderLabel="true" runat="server" />

                        </div>
                    </div>
                    </fieldset>

                  

                </div>

                <div id="tab-sped-iep-meeting-purpose">
                    <div class="row">
                        <div class="col-12 col-md-6 col-xl-3">
                            <Spedmon:DataEntryBoxDate ID="spedinitrefdate" name="spedinitrefdate" label="Initial Referral Date" title="Initial Referral Date" size="20" runat="server"/>
                        </div>
                        
                        <div class="col-12 col-md-6 col-xl-4 d-flex flex-column align-items-center justify-content-center mt-1">
                            <Spedmon:DataEntryRowSelectSpEdReferringParty
                                ID                   = "DataEntryRowSelectSpEdReferringParty" 
                                entityControlID      = "spedreferringpartycode"                
                                rowLabel             = "Person Initiating Referral"
                                dataEntryRowRenderAs = "FIELD"
                                onSpedmonInputData   = "fnShowOrHideOtherTxtForReferringPerson(e.dataitem.id);"
                                runat                = "server">
                            </Spedmon:DataEntryRowSelectSpEdReferringParty>

                            <div id="divSpedReferringPersonOtherTxt">
                                <Spedmon:DataEntryBoxText ID="spedreferringpartyotheroption" name="spedreferringpartyotheroption" label="Other referring person" title="Other referring person" size="18" runat="server" />
                            </div>
                            
                        </div>

                        <div class="col-12 col-md-6 col-xl-4">
                            <Spedmon:DataEntryBoxDate ID="speddistrictreceivedparentconsentdate" name="speddistrictreceivedparentconsentdate" label="Date District Received Parent Consent (Ages 3-22)" title="Date District Received Parent Consent (Ages 3-22)" size="20" runat="server"/>
                        </div>
                    </div>

                    <Spedmon:HiddenTextArea ID="spedmeetingpurposedatajson" name="spedmeetingpurposedatajson" title="spedmeetingpurposedatajson" runat="server"/>
                    <div class="row">
                        <div class="col-12 col-md-6 col-xl-4">
                            <Spedmon:DataEntryRow rowLabel="Please Select the Purpose of the Meeting" runat="server">
                                <div>
                                    <Spedmon:CheckBox ID="partBInitEvalCheckbox" name="initEvalCheckbox" firedataselected="false" title="10 - Part B initial Evaluation" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> 10 - Part B initial Evaluation (Age 3-22)</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="partCInitEvalCheckbox" name="partCInitEvalCheckbox" firedataselected="false" title="15 – Part C Initial Evaluation" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> 15 - Part C Initial Evaluation (Ages 0-2)</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="annMeetingCheckbox" name="annMeetingCheckbox" firedataselected="false" title="20 – Annual Meeting / Plan Review" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> 20 - Annual Meeting / Plan Review</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="pendingInitEvalCheckbox" name="pendingInitEvalCheckbox" firedataselected="false" title="30 – Pending Initial Evaluation" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> 30 - Pending Initial Evaluation</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="triennialEvalCheckbox" name="triennialEvalCheckbox" firedataselected="false" title="40 – Triennial Evaluation / Eligibility Evaluation" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> 40 - Triennial Evaluation / Eligibility Evaluation</span>
                                </div>
                            </Spedmon:DataEntryRow>

                            <div class="mt-5">
                                <Spedmon:DataEntryRowSelectSpEdPlanType
                                    ID                   = "DataEntryRowSelectSpEdPlanType" 
                                    entityControlID      = "spedplantypecode"                
                                    rowLabel             = "Plan Type"
                                    runat                = "server">
                                </Spedmon:DataEntryRowSelectSpEdPlanType>
                            </div>

                        </div>

                        <Spedmon:HiddenTextArea ID="spedadditionalmeetingpurposedatajson" name="spedadditionalmeetingpurposedatajson" title="spedadditionalmeetingpurposedatajson" runat="server"/>
                        <div class="col-12 col-md-6 col-xl-4">
                            <Spedmon:DataEntryRow rowLabel="Additional Purpose of Meeting (If Needed)" runat="server">
                                <div>
                                    <Spedmon:CheckBox ID="transitionCheckbox" name="transitionCheckbox" firedataselected="false" title="Transition" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Transition</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="preExpulsionCheckbox" name="preExpulsionCheckbox" firedataselected="false" title="Pre-Expulsion" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Pre-Expulsion</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="interimCheckbox" name="interimCheckbox" firedataselected="false" title="Interim" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Interim</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="requestAmendCheckbox" name="requestAmendCheckbox" firedataselected="false" title="Interim" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Request Amendment / Change of Service or Placement</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="otherMeetingPurposeCheckbox" name="otherMeetingPurposeCheckbox" firedataselected="false" title="Other" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Other</span>
                                </div>
                                <Spedmon:DataEntryBoxTextArea ID="spedmeetingpurposeotheroption" name="spedmeetingpurposeotheroption" label="Other meeting purpose" title="Other meeting purpose" size="25" runat="server"/>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="col-12 col-md-6 col-xl-4">
                            <Spedmon:HiddenTextArea ID="spedamendmentreasonsdatajson" name="spedamendmentreasonsdatajson" title="recTransportationJSON" runat="server" /> 
                            <div id="spedAmendmentReasonsCont">
                                <Spedmon:DataEntryRow rowLabel="Reasons for Amendment" runat="server">
                                    <div>
                                        <Spedmon:CheckBox ID="continuationMeetingsCheckbox" name="continuationMeetingsCheckbox" firedataselected="false" title="Continuation meetings" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> Continuation meetings</span>
                                    </div>
                                    <div>
                                        <Spedmon:CheckBox ID="iepChangesMadeCheckbox" name="iepChangesMadeCheckbox" firedataselected="false" title="Change(s) made to the IEP" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> Change(s) made to the IEP</span>
                                    </div>
                                    <div>
                                        <Spedmon:CheckBox ID="iepCorrectionsMadeCheckbox" name="iepCorrectionsMadeCheckbox" firedataselected="false" title="Correction(s) made to the IEP" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> Correction(s) made to the IEP</span>
                                    </div>
                                    <div>
                                        <Spedmon:CheckBox ID="transitionMeetingCheckbox" name="transitionMeetingCheckbox" firedataselected="false" title="Transition meeting" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> Transition meeting</span>
                                    </div>
                                    <div>
                                        <Spedmon:CheckBox ID="interimPlacementCheckbox" name="interimPlacementCheckbox" firedataselected="false" title="Interim Placement" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> Interim Placement</span>
                                    </div>
                                    <div>
                                        <Spedmon:CheckBox ID="thirtyDayReviewCheckbox" name="thirtyDayReviewCheckbox" firedataselected="false" title="30-day Review" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> 30-day Review</span>
                                    </div>
                                    <div>
                                        <Spedmon:CheckBox ID="exitMeetingCheckbox" name="exitMeetingCheckbox" firedataselected="false" title="Exit meeting" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> Exit meeting</span>
                                    </div>

                                    <div>
                                        <Spedmon:CheckBox ID="otherAmendReasonCheckbox" name="otherAmendReasonCheckbox" firedataselected="false" title="Other" defaultValue="false" useDefaultValue="true" runat="server" />
                                        <span> Other</span>
                                    </div>
                                    <Spedmon:DataEntryBoxTextArea ID="spedamendmentreasonsotheroption" name="spedamendmentreasonsotheroption" label="Other amendment reason" title="Other amendment reason" size="25" runat="server"/>
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>
                    </div>      
                 
                </div>
                
                <div id="tab-sped-iep-team-members">

                    <Spedmon:DataEntryRowSelectUser 
                        ID              = "selectFacilitator" 
                        entityControlID = "spedfacilitatoruserid"                
                        rowLabel        = "Select an IEP Meeting Contact" 
                        runat           = "server">
                    </Spedmon:DataEntryRowSelectUser>

                    <Spedmon:HiddenTextArea ID="spedparticipantdetails" name="spedparticipantdetails" title="spedparticipantdetails" runat="server" />

                    <div id="dataManagementRowsForSpEdTeamMembers" class="container-fluid">

                        <div class="row mt-4">
                          <div class="col-12">
 
                            <div id="spEdTeamMembersRestView">
                            </div>
 
                          </div> <!-- col -->
                        </div> <!-- row -->

                    </div>

                    <div class="row mt-3">
                        <div class="col">
                            <Spedmon:DataEntryBoxText ID="spedmeetingtitle" name="spedmeetingtitle" label="IEP Meeting Title" title="Title" size="17" runat="server"/>
                            <Spedmon:DataEntryBoxDate ID="spedmeetingdate" name="spedmeetingdate" label="IEP Meeting Date" title="IEP Meeting Date" size="17" runat="server"/>
                            <Spedmon:DataEntryBoxTime ID="spedmeetingtime" name="spedmeetingtime" label="IEP Meeting Time" title="IEP Meeting Time" size="17" runat="server"/>
                            <Spedmon:DataEntryBoxNumber ID="spedmeetingdurationinmins" name="spedmeetingdurationinmins" label="IEP Meeting Duration (in minutes)" title="IEP Meeting Duration (in minutes)" size="17" runat="server"/>
                        </div>
                    </div>

                    <Spedmon:DataEntryRowSelectStoredFile
                       ID                              = "selectFiles"  
                       rowLabel                        = "Files to Share During Meeting (Note: ONLY PDF files are supported at this time)"
                       entityControlID                 = "filestoshareuploadids"
                       multiSelect                     = "true"
                       multiSelectListTitle            = "Files to Share During Meeting (PDF files only please)"
                       runat                           = "server">
                    
                      <Spedmon:Button ID="butmanagefiles" title="Click here To Add New Files" runat="server">Manage Library</Spedmon:Button>
                    
                    </Spedmon:DataEntryRowSelectStoredFile>

                    <div class="text-center">
                        <i id="createiepmeetingicon" class="fas fa-users mr-3" title="Create IEP Meeting" style="font-size: 2em;"></i>
                    </div>

                    <div id="dataManagementRowsForSpEdTeamMembersHyQueue" class="container-fluid">

                        <div class="row mt-5">
                          <div class="col-12">
 
                            <div id="spEdTeamMembersHyQueueRestView">
                            </div>
 
                          </div> <!-- col -->
                        </div> <!-- row -->

                    </div>

                </div>

                <div id="tab-sped-iep-schedule-meeting"></div>

                <div id="tab-sped-iep-present-levels">



                    

                    <Spedmon:DataEntryRow rowLabel="Describe the student's strengths" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "spedstudentstrengths" 
                            name  = "spedstudentstrengths" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                    <Spedmon:DataEntryRow rowLabel="Describe the concerns of the parent for enhancing education of the student" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "spedparentconcerns" 
                            name  = "spedparentconcerns" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>



                                        <!-- James Project -->

                    <h4>Development/Academic/Function Skill</h4>

                    <Spedmon:DataEntryRow rowLabel="Reading" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillsreading" 
                            name  = "speddevacafunskillsreading" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                                        <Spedmon:DataEntryRow rowLabel="Writing" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillswriting" 
                            name  = "speddevacafunskillswriting" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                                        <Spedmon:DataEntryRow rowLabel="Math" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillsmath" 
                            name  = "speddevacafunskillsmath" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                                        <Spedmon:DataEntryRow rowLabel="Communication Development" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillscommunicationdev" 
                            name  = "speddevacafunskillscommunicationdev" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                                        <Spedmon:DataEntryRow rowLabel="Gross/Fine Motor Development" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillsgrossfinemotordev" 
                            name  = "speddevacafunskillsgrossfinemotordev" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                                        <Spedmon:DataEntryRow rowLabel="Health" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillshealth" 
                            name  = "speddevacafunskillshealth" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                                        <Spedmon:DataEntryRow rowLabel="Vocational" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillsvocational" 
                            name  = "speddevacafunskillsvocational" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                                        <Spedmon:DataEntryRow rowLabel="Adaptive/Daily Living Skills" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillsadaptivedailyliving" 
                            name  = "speddevacafunskillsadaptivedailyliving" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                      <Spedmon:DataEntryRow rowLabel="Areas of Neccessity Explained in terms of goals and objectives in order that the student receives educational benefits" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "speddevacafunskillsareasofneccessity" 
                            name  = "speddevacafunskillsareasofneccessity" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>
                    <!--James Project -->



                    <Spedmon:DataEntryRow rowLabel="Enter Progress Monitoring Data" runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "spedprogressmonitoringdata" 
                            name  = "spedprogressmonitoringdata" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>


                    <div class="mt-5">
                        <span>View progress monitoring data: </span>
                        <i class="fas fa-chart-line ml-2" title="View Current Progress for All Goals" onClick="opnPatGoalProgress()"></i>
                    </div>

                    <Spedmon:DataEntryRow rowLabel="Based on the evaluation data, provide a statement of the student’s present levels of academic achievement and functional performance, including how the student’s disability affects the student’s involvement and progress in the general education curriculum or for children in early childhood, participation in appropriate activities." runat="server">
                        <Spedmon:RichTextAreaBox 
                            id    = "spedstudentpresentlevelsstatement" 
                            name  = "spedstudentpresentlevelsstatement" 
                            title = "Enter content"
                            showControls = "false"
                            runat = "server">
                        </Spedmon:RichTextAreaBox> 
                    </Spedmon:DataEntryRow>

                </div>

                <div id="tab-sped-iep-eligibility-information">

                    <div class="row">
                        <div class="col-12 col-md-6 col-xl-4">
                            <Spedmon:DataEntryRow rowLabel="The IEP Team has determined that the student's disability adversely affects the student’s educational performance" runat="server">
                                <Spedmon:SelectYesOrNo ID="spedstudentdisabilityaffectsperformance" name="spedstudentdisabilityaffectsperformance" title="Select an option" renderLabel="false" runat="server" />
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="col-12 col-md-6 col-xl-4">
                            <Spedmon:DataEntryBoxDate ID="spedcureligibilitydate" name="spedcureligibilitydate" label="Current Eligibility Date" title="Current Eligibility Date" size="15" runat="server"/>
                        </div>

                        <div class="col-12 col-xl-4">
                            <Spedmon:DataEntryBoxDate ID="spediniteligibilitydate" name="spediniteligibilitydate" label="Initial Eligibility Date" title="Initial Eligibility Date" size="15" runat="server"/>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-12 col-xl-4">
                            <Spedmon:DataEntryRow rowLabel="I confirm that I have identified the IEP Team attendees in the IEP" runat="server">
                                <Spedmon:SelectYesOrNo ID="spediepattendeesidentified" name="spediepattendeesidentified" title="Select an option" renderLabel="false" runat="server" />
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="col-12 col-xl-8">
                          <Spedmon:DataEntryRow ID="enterEligReasons" useBootstrapGrid="false" rowLabel="Describe the reasons for eligibility determination including the other options considered and reasons these options were rejected" runat="server">
                            
                            <Spedmon:RichTextAreaBox 
                             ID            = "spedeligibilityreasons" 
                             name          = "spedeligibilityreasons" 
                             title         = "Enter reasons"
                             showControls  = "false"                            
                             runat         = "server">
                            </Spedmon:RichTextAreaBox> 
                          </Spedmon:DataEntryRow>
                        </div>
                    </div>

                    <div class="mt-4 mb-5">
                        <h6 class="font-weight-bold">Disabilities</h6>
                        <div>Primary:&nbsp;<span id="spedDisability1Display"><%=spedDisability1Text%></span></div>
                        <div>Secondary:&nbsp;<span id="spedDisability2Display"><%=spedDisability2Text%></span></div>
                    </div>
                    
                    
                    <Spedmon:DataEntryRowSelectSpEdLanguage
                        ID                   = "selectSpEdLangaugeToTranslatePlanTo" 
                        entityControlID      = "spedplantranslatetolanguagecodeid"                
                        rowLabel             = "Select a language if you would like this document translated"
                        runat                = "server">
                    </Spedmon:DataEntryRowSelectSpEdLanguage>

                </div>

                <div id="tab-sped-iep-special-considerations-and-behavior"></div>
                <div id="tab-sped-iep-transition"></div>
                <div id="tab-sped-iep-accommodations"></div>
                <div id="tab-sped-iep-goals">
                    <div class="col-auto">
                        <Spedmon:DataEntryRow rowLabel="Transition Goal:" runat="server">
                            <div>
                                    <Spedmon:CheckBox ID="spedtransitiongoaleducation" name="spedtransitiongoaleducation" firedataselected="false" title="Education" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Education</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="spedtransitiongoaltraining" name="spedtransitiongoaltraining" firedataselected="false" title="Training" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Training</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="spedtransitiongoalemployment" name="spedtransitiongoalemployment" firedataselected="false" title="Employment" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Employment</span>
                                </div>
                                <div>
                                    <Spedmon:CheckBox ID="spedtransitiongoalindependentliving" name="spedtransitiongoalindependentliving" firedataselected="false" title="Independent Living" defaultValue="false" useDefaultValue="true" runat="server" />
                                    <span> Independent Living</span>
                                </div>
                        </Spedmon:DataEntryRow> 
                    </div>
                </div>
                <div id="tab-sped-iep-provisions"></div>
                <div id="tab-sped-iep-lre-placement"></div>
                <div id="tab-sped-iep-summary-of-performance"></div>

                <div id="tab-sped-iep-create-iep">

                <script type="text/javascript">
                   function doGenerateIepPreview () {
                      let urlGenerateIepPreview = '<%=Spedmon.SpEdDocumentTemplates.URL_SPED_DOCUMENT_OUTPUT(Spedmon.SpEdDocumentTemplates.SPED_DOCUMENT_DATA_SOURCE_PATIENT_CURRENT_OR_WIP_SPED_DATA,this.clientID, this.patID)%>';
                        MBA.ComponentCommon.fnOpenWindow(urlGenerateIepPreview, 'ieppreview');
                    };
                </script>
                
                <Spedmon:DataEntryButton ID="generateIepPreview" style="PRIMARY" onclick="doGenerateIepPreview()" label="Generate Preview of Current or Work In Progress IEP" runat="server" />
                    
                </div>
                <div id="tab-sped-iep-student-history"></div>
            </div>

        </div>
    
    </div> <!-- tabs -->
    </div> <!-- col-12 -->
    </div> <!-- row -->

    <%//#####################################################################################################%>
    <%//                                        Save or Edit                                                 %>
    <%//#####################################################################################################%>

    <Spedmon:DataEntryRowSaveOrEdit
        ID                               = "saveOrEdit"
        includeSaveAndProceedButton      = "false"
        editDelManageLink                = ""
        includeSecondarySaveButton       = "true"
        secondarySaveButtonLabel         = "Save"
        secondarySaveButtonOnClick       = "navigateBasedOnSaveType(e)"
        runat                            = "server">
    </Spedmon:DataEntryRowSaveOrEdit>

</Spedmon:DataEntryRows>

<%//#####################################################################################################%>
<%//                                           Scripts                                                   %>
<%//#####################################################################################################%>

<script type="text/javascript">

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    let $dataManagementRowsSpEd      = null;
    let $restViewCtrlSpEd            = null;
    let $restViewCtrlSpEdIepServices = null;
    let $restViewCtrlSpEdTeamMembers = null;

    const PARM_NAME_CLIENT_ID             = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PAT_ID                = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_ACTIVE                = '<%=Constants.PARM_ACTIVE%>';
    const PARM_NAME_PAT_GOAL_ID           = '<%=Constants.PARM_PATIENT_GOAL_ID%>';
    const PARM_NAME_GRP_SVC_CLASS_NAME_ID = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';
    const PARM_PERSON_ROLE_ID             = '<%=Constants.PARM_PERSON_ROLE_ID%>';
    const PARM_MIDDLE_NAME                = '<%=Constants.PARM_MIDDLE_NAME%>';
    const PARM_VALIDATE_REC               = '<%=Constants.PARM_VALIDATE_REC%>';
    const PARM_EDIT_DEL_REASON            = '<%=Constants.PARM_EDIT_DEL_REASON%>';

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    // onClick for the save button: navigate the user based on saveType

   function navigateBasedOnSaveType(e) {
        if ('<%=saveType%>' == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {

            // if new client, just load the edit screen
           var url = '<%=patientSaveURL%>';

           var fnGoPatientEdit = function (rd) {
               // this is the code that launches the screen
               var patientEditUrl = url
                   + '&recid=' + rd.recordID
                   + '&savetype=' + $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT
               $.spedmonWebUI.gotoURL(patientEditUrl)
           };
           $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', fnGoPatientEdit, true);

       }
       else {
           // we stay on the page
           $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', null, true);
       }
   }

   <%//=============================================================================%>
   <%// External Rest View Setups For Various Tabs %>
   <%//=============================================================================%>

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

   function initKnownHealthProblemsRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
          , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
          , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
          , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
          , containerCtrlID: 'datamanagerowsrestviewpatientknownhealthproblems'
          , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
          , baseUrlView:'<%=Spedmon.PatientKnownHealthProblems.URL_REST_VIEW_BASE()%>'
          , defaultPageRowOrder:'<%=Spedmon.PatientKnownHealthProblem.DEFAULT_PAGING_ORDER%>'
          , baseUrlAddNew:'<%=Spedmon.PatientKnownHealthProblems.URL_SAVE_NEW_BASE()%>'
          , baseUrlEdit:'<%=Spedmon.PatientKnownHealthProblems.URL_EDIT_BASE()%>'
          , baseUrlDelete:'<%=Spedmon.PatientKnownHealthProblems.URL_DELETE_INLINE_BASE()%>'
          , baseUrlKnownHealthProblemIDSel: '<%=Spedmon.KnownHealthProblems.URL_VIEW_SEL_BASE()%>'
            , showAddNew: true
            , showEdit: true
            , showDelete: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '10em'
            , autoHidePageControls: true

        };

        MBA.PatientKnownHealthProblemsCommon.fnSetup('restviewpatientknownhealthproblems', optsObj);
        return;
    };

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

   function initAllergiesRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientallergies'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView:'<%=Spedmon.PatientAllergies.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder:'<%=Spedmon.PatientAllergy.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew:'<%=Spedmon.PatientAllergies.URL_SAVE_NEW_BASE()%>'
            , baseUrlEdit:'<%=Spedmon.PatientAllergies.URL_EDIT_BASE()%>'
            , baseUrlDelete:'<%=Spedmon.PatientAllergies.URL_DELETE_INLINE_BASE()%>'
            , baseUrlAllergyIDSel: '<%=Spedmon.Allergies.URL_VIEW_SEL_BASE()%>'            
            , showAddNew: true
            , showEdit: true
            , showDelete: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '10em'
            , autoHidePageControls: true

        };

    MBA.PatientAllergiesCommon.fnSetup('restviewpatientallergies', optsObj);
    return;
};

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

   function initDiagnosesRestView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
          , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
          , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
          , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
          , containerCtrlID: 'datamanagerowsrestviewpatientdiagnoses'
          , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
          , baseUrlView:'<%=Spedmon.PatientDiagnoses.URL_REST_VIEW_BASE()%>'
          , defaultPageRowOrder:'<%=Spedmon.PatientDiagnosis.DEFAULT_PAGING_ORDER%>'
          , baseUrlAddNew:'<%=Spedmon.PatientDiagnoses.URL_SAVE_INLINE_BASE()%>'
          , baseUrlEdit:'<%=Spedmon.PatientDiagnoses.URL_SAVE_INLINE_BASE()%>'
          , baseUrlDelete:'<%=Spedmon.PatientDiagnoses.URL_DELETE_INLINE_BASE()%>'
            , baseUrlDiagnosisIDSel: '<%=Spedmon.ICD10CMCodes.URL_VIEW_SEL_BASE()%>'
            , showAddNew: true
            , showEdit: false
            , showDelete: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '10em'
            , autoHidePageControls: true

        };

        MBA.PatientDiagnosesCommon.fnSetup('restviewpatientdiagnoses', optsObj);
        return;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPatientCareNotes() {

        let optsForPatientCareNotes = {};

        optsForPatientCareNotes.PARM_NAME_CLIENT_ID = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();
        optsForPatientCareNotes.PARM_NAME_GROUP_SVC_CLASS_NAME_ID = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
        optsForPatientCareNotes.PARM_NAME_PAT_ID = $('#<%=Spedmon.Constants.PARM_PATIENT_ID%>').val();
        optsForPatientCareNotes.containerCtrlID = 'manageviewpatientcarenotes';
        optsForPatientCareNotes.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForPatientCareNotes.baseUrlView = '<%=Spedmon.PatientCareNotes.URL_REST_VIEW_BASE()%>';
        optsForPatientCareNotes.defaultPageRowOrder = '<%=Spedmon.PatientCareNote.DEFAULT_PAGING_ORDER%>';
        optsForPatientCareNotes.baseUrlSave = '<%=Spedmon.PatientCareNotes.URL_SAVE_NOTE_BASE()%>';
        optsForPatientCareNotes.baseUrlLoad = '<%=Spedmon.PatientCareNotes.URL_LOAD_NOTE_BASE()%>';

        MBA.PatientCareNotesCommon.fnSetup('patientcarenotescomponent', optsForPatientCareNotes);

    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPracticeOfficeRestView() {


        let $currentRecCtrlEditStart = null;

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_COMPLETED: '<%=Spedmon.Constants.PARM_COMPLETED%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_DATA_SOURCE: '<%=Spedmon.Constants.PARM_DATA_SOURCE%>'
            , dataSourceValueForVisits: '1' /* Default all.  1= all , 2 = waiting room only */
            , containerCtrlID: 'manageviewvisitscontainer'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.PracticeOfficeVisits.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.PracticeOfficeVisit.DEFAULT_PAGING_ORDER%>'
            , whatPage: 3
            , baseUrlAddNew: ''
            , baseUrlEdit: '<%=Spedmon.PracticeOfficeVisits.URL_SVC_END_VISIT_BASE()%>'
            , baseUrlDelete: ''
            , baseUrlPatIDSel: '<%=Spedmon.Patients.URL_SVC_VIEW_SEL_BASE()%>'
            , baseUrlPracticeOfficeVisitReasonIDSel: '<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>'
            , baseUrlPracIDSel: '<%=Spedmon.Practitioners.URL_VIEW_SEL2_BASE()%>'
            , baseUrlPatientVisitManage: '<%=Spedmon.PracticeOfficeCommon.URL_PATIENT_VISIT_MANAGE()%>'
            , baseUrlPracticeOfficeVisitResolutionIDSel:'<%=Spedmon.PracticeOfficeVisitResolutions.URL_VIEW_SEL_BASE()%>'
            , baseUrlReport: 'URL_WEB_LOAD_BASEURL_WEB_REPORT_BASE()%>'
            , defaultReportNumber: '<%=Spedmon.PracticeOfficeVisitsView.REPT_NUM_VIEW%>'
            , ATTEST_STATEMENT: '<%=MBA.Messages.ATTEST_STATEMENT%>'
            , tkn: '<%=rd.wu.usr.token%>'
            , baseUrlLoadVisit: '<%=Spedmon.PracticeOfficeVisits.URL_SVC_LOAD_BASE()%>'
            , formDataJSON: ''
            , showAddNew: false
            , showStartVisit: false
            , showEdit: true
            , completedValue: 'Y'
            , showCaption: false
            , caption: 'Visits'
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '15em'
            , autoHidePageControls: true
            , enableSortControls: false
            , showPatientRelatedColumns: false
            , showWaitingRelatedFields: false
            , showVisitRelatedFields: true
            , canEditPat: false
            , canEditPrac: false
            , canEditVisitReason: false
            , canEditVisitResolution: true
        };

        MBA.PracticeOfficeVisitsCommon.fnSetup('visitscomponentview', optsObj);
        return;
    };
    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initOrderOrPrescriptionForHSDelivery() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_DOS: '<%=Spedmon.Constants.PARM_DOS%>'
            , PARM_NAME_GROUP_ID: '<%=Spedmon.Constants.PARM_GROUP_ID%>'
            , PARM_NAME_TERM: '<%=Spedmon.Constants.PARM_SEARCH_TERM%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'managevieworderorpxcontainer'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ServiceJournalRecentProcedureEntries.URL_REST_VIEW_OPEN_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.ServiceJournalRecentProcedureEntry.DEFAULT_PAGING_ORDER%>'
            , baseUrlViewSelPatOrdersForDOS: '<%=Spedmon.ServiceJournalsJournalEventSelections.URL_VIEW_SEL_JOURNAL_PAT_ORDERS_ONLY_BASE()%>'
            , baseUrlSaveJournalJournal: '<%=Spedmon.ServiceJournalsJournals.URL_SVC_SAVE_INLINE_BASE()%>'
            , baseUrlSaveJournalEntry: '<%=Spedmon.ServiceJournalsJournalEntries.URL_SVC_SAVE_INLINE_BASE()%>'
            , tkn: '<%=this.rd.wu.usr.token%>'
        };
        MBA.OrdersOrPrescriptionsProvideHSForPatOnDOSCommon.fnSetup('orderorpxcomponentview', optsObj);
        return;
    };

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initVitalsMeasurementsForPatOnDOS() {

        let optsForPatientVitalSigns = {};

        optsForPatientVitalSigns.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        optsForPatientVitalSigns.PARM_NAME_PAT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
        optsForPatientVitalSigns.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsForPatientVitalSigns.containerCtrlID = 'manageviewvitalsignscontainer';
        optsForPatientVitalSigns.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsForPatientVitalSigns.baseUrlView = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_VIEW_BASE()%>';
        optsForPatientVitalSigns.defaultPageRowOrder = '<%=Spedmon.PatientVitalsMeasurement.DEFAULT_PAGING_ORDER%>';
        optsForPatientVitalSigns.baseUrlAddNew = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_SAVE_INLINE_BASE()%>';
        optsForPatientVitalSigns.baseUrlEdit = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_SAVE_INLINE_BASE()%>';
        optsForPatientVitalSigns.baseUrlDelete = '<%=Spedmon.PatientVitalsMeasurements.URL_REST_DELETE_INLINE_BASE()%>';
        optsForPatientVitalSigns.baseUrlReport = '<%=Spedmon.PatientVitalsMeasurements.URL_WEB_REPORT_BASE()%>';
        optsForPatientVitalSigns.defaultReportNumber = '<%=Spedmon.PatientVitalsMeasurementView.REPT_NUM_VIEW%>';

        MBA.PatientVitalSignsMeasurementCommon.fnSetup('vitalsignscomponentview', optsForPatientVitalSigns);

    };

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

   function initInsuranceCoverageView() {

        let optsObj = {};

        optsObj.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        optsObj.PARM_NAME_PAT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
        optsObj.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsObj.containerCtrlID = 'restViewOrdersInsuranceCarriers';
        optsObj.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsObj.baseUrlView = '<%=Spedmon.PatientInsuranceCarriers.URL_PATIENT_CARRIERS_REST_VIEW_BASE()%>';
        optsObj.defaultPageRowOrder   = '<%=Spedmon.PatientInsuranceCarrier.DEFAULT_PAGING_ORDER%>';
        optsObj.baseUrlAddNew         = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlEdit           = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlInsuranceCarrierIDSel = '<%=Spedmon.InsuranceCarriers.URL_VIEW_SEL_BASE()%>';
        optsObj.autoHidePageControls = true;
        optsObj.enableScrollView = true;
        optsObj.scrollViewUseCustomHeight = true;
        optsObj.scrollViewCustomHeight = '20em';

        MBA.PatientInsuranceCommon.fnSetup('insuranceCarriersRestView', optsObj);

        return;
    }

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPatientGoalsView() {

        let optsObj = {};

        optsObj.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        optsObj.PARM_NAME_PAT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
        optsObj.PARM_NAME_PAT_GOAL_ID = '<%=Spedmon.Constants.PARM_PATIENT_GOAL_ID%>';
        optsObj.PARM_NAME_ACTIVE = '<%=Spedmon.Constants.PARM_ACTIVE%>';
        optsObj.PARM_NAME_GROUP_SVC_CLASS_NAME_ID = '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>';
        optsObj.PARAM_ROLE_LEA_PROVIDER_ID = '<%=Spedmon.Constants.ROLE_LEA_PROVIDER_ID%>';
        optsObj.containerCtrlID = 'dataManagementRowsForGoals';
        optsObj.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        optsObj.baseUrlView = '<%=Spedmon.PatientGoals.URL_REST_VIEW_BASE()%>';
        optsObj.defaultPageRowOrder = '<%=Spedmon.PatientGoal.DEFAULT_PAGING_ORDER%>';
        optsObj.baseUrlAddNew = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlEdit = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlDelete = '<%=Spedmon.PatientGoals.URL_REST_DELETE_INLINE_BASE()%>'
        optsObj.groupSvcClassNameIDOpts = '<%=Spedmon.GroupsServiceClasses.URL_REST_VIEWSEL_FOR_ORP_DOCS_BASE()%>';
        optsObj.patientGoalsDefaultDates = '<%=Spedmon.PatientGoalsDefaultDates.URL_SVC_VIEW_DEFAULT_DATES_BASE()%>';
        optsObj.baseUrlIndividualGoal = '<%=Spedmon.PatientGoalsProgressIndividualGoals.URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS_BASE()%>';
        optsObj.roleID = '<%=rd.wu.usr.roleID%>';
        optsObj.baseUrlViewProgress = '<%=urlViewAllPatientGoalsProgress%>';
        optsObj.pracGrpSvcClassNameID = '<%=pracGrpSvcClassNameID%>';
        optsObj.autoHidePageControls = true;
        optsObj.enableScrollView = true;
        optsObj.scrollViewUseCustomHeight = true;
        optsObj.scrollViewCustomHeight = '20em';

        MBA.PatientGoalsCommon.fnSetup('goalsRestView', optsObj);

        return;
    }

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPatientPersonsView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_PERSON_ROLE_ID: '<%=Spedmon.Constants.PARM_PERSON_ROLE_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientpersons'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.PatientPersons.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.PatientPerson.DEFAULT_PAGING_ORDER%>'
            , baseUrlAddNew: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
            , baseUrlEdit: '<%=Spedmon.PatientPersons.URL_SAVE_INLINE_BASE()%>'
            , baseUrlDelete: '<%=Spedmon.PatientPersons.URL_DELETE_INLINE_BASE()%>'
            , baseUrlReport: ''
            , defaultReportNumber: '1'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '20em'
            , isPcalStaff:<%=isPcalStaffJSBoolStr%>
            , currentPage: 1
    };

        MBA.PatientPersonsCommon.fnSetup('restviewpatientpersons', optsObj);
        return;
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initOrdersOrPrescriptionsRestView() {
        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_GROUP_SVC_CLASS_NAME_ID: '<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_NAME_ORP_APR_STATE:'<%=Spedmon.Constants.PARM_ORP_APPROVAL_STATE%>'
            , containerCtrlID: 'datamanagerowsrestviewordersorprescriptions'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ORPDocuments.URL_REST_VIEW_ORP_DOCS_ORDERS_AND_PROFILES()%>'
            , defaultPageRowOrder: 'id desc'
            , baseUrlAddNew: '<%=Spedmon.ORPDocuments.URL_ADD_NEW_ORDER_PRESCRIPTION()%>'
            , baseUrlEdit: '<%=Spedmon.ORPDocuments.URL_EDIT_ORDER_PRESCRIPTION_BASE()%>'
            , baseUrlDelete: '<%=Spedmon.ORPDocuments.URL_DELETE_ORDER_PRESCRIPTION_BASE()%>'
            , baseUrlReport: '<%=Spedmon.ORPDocuments.URL_WEB_REPORT_ORP_DOCS_ORDERS_AND_PROFILES()%>'
            , defaultReportNumber: '<%=Spedmon.ORPDocumentsViw.REPT_NUM_VIEW_ORDERS_AND_PROFILES%>'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '20em'
            , showActive: false
            , showPatientName: false
            , showPracticeName: false
            , showSiteName: false
            , hasCarePlanAccess: true
            , editCarePlanUrl: '<%=Spedmon.PlanWriterPlans.GEN_URL_ASPX_SAVE()%>'
            , svcAuthReqOrderOrPrescriptionUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_ORDER_PRESCRIPTION_BASE()%>'
            , svcAuthReqPatProfileUrl: '<%=Spedmon.ORPDocuments.URL_REQUEST_SVC_AUTH_PATIENT_PROFILE_BASE()%>'
            , autoHidePageControls: true
            , fnGetActiveValue: function (dataObj) { return '1'; }
            , fnGetOrpApprovalStateValue: function (dataObj) { return ''; }
        };

        MBA.OrdersOrPrescriptionsCommon.fnSetup('restviewordersorprescriptions', optsObj);
        return;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPromisedServicesView() {

        let optsObj = {
          PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
        , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
        , containerCtrlID: 'datamanagerowsrestviewpatientpromisedservices'
        , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , baseUrlView: '<%=Spedmon.PatientPromisedServices.URL_REST_VIEW()%>'
        , defaultPageRowOrder: '<%=Spedmon.PatientPromisedService.DEFAULT_PAGING_ORDER%>'
        , baseUrlAddNew: '<%=Spedmon.PatientPromisedServices.URL_ADD_NEW_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlEdit: '<%=Spedmon.PatientPromisedServices.URL_EDIT_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlDelete: '<%=Spedmon.PatientPromisedServices.URL_REST_DELETE_INLINE()%>'
        , baseUrlReport: ''
        , defaultReportNumber: '1'
        , autoHidePageControls: true
        , enableScrollView: true
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight: '20em'
        };

        MBA.PatientPromisedServicesCommon.fnSetup('restviewpatientpromisedservices', optsObj);
        return;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initStoredFilesView() {

    let optsObj = {
        PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
      , PARM_NAME_DATE_RANGE: '<%=Constants.PARM_DATE_RANGE%>'
      , PARM_NAME_FILE_CLASS: '<%=Constants.PARM_FILE_CLASS%>'
      , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
      , PARM_NAME_FILE_ID: '<%=Spedmon.StoredFiles.PARAM_FILE_ID%>'
      , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
      , containerCtrlID: 'datamanagerowsrestviewstoredfiles'
      , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
      , baseUrlView: '<%=Spedmon.StoredFiles.URL_REST_VIEW_BASE()%>'
      , defaultPageRowOrder: '<%=Spedmon.StoredFile.DEFAULT_PAGING_ORDER%>'
      , baseUrlDelete: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DELETE()%>'
      , baseUrlReport: '<%=Spedmon.StoredFiles.URL_WEB_REPORT_BASE()%>'
      , defaultReportNumber: '<%=Spedmon.StoredFilesRpt.REPT_NUM_VIEW%>'
      , autoHidePageControls: true
      , enableScrollView: true
      , scrollViewUseCustomHeight: true
      , scrollViewCustomHeight: '20em'    
      , isPcalStaff:<%=isPcalStaffJSBoolStr%>
      , showPatientName: false
      , webSvcFlagAsNonConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_NON_CONFIDENTIAL()%>'
      , webSvcFlagAsConfidentialUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_CONFIDENTIAL()%>'
      , webSvcEnableSharingWithPatientUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT()%>'
      , webSvcDisableSharingWithPatientUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT()%>'
      , webSvcEnableSharingWithParentUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT()%>'
      , webSvcDisableSharingWithParentUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT()%>'
      , currUserID: <%=rd.wu.usr.id%>
      , downloadHandlerPrivateBaseUrl: '<%=Spedmon.StoredFiles.URL_DOWNLOAD_HANDLER_PRIVATE_BASE()%>'
      , fnGetFileClassValue: function (dataObj) { return ''; }
      , fnGetDateRangeValue: function (dataObj) { return ''; }
      , showOKToShareWithPatient: true
      , showOKToShareWithParentGuardian: true
       };

        MBA.StoredFilesCommon.fnSetup('restviewstoredfiles', optsObj);
        return;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initServiceRecordsView() {

        let optsObj = {
              PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PATIENT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewservicerecords'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: 'dos desc'
            , baseUrlReport: ''
            , defaultReportNumber: '1'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '20em'
        };

        MBA.PatientServiceRecordsCommon.fnSetup('restviewservicerecords', optsObj);

        return;
    };

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

   <%//=============================================================================%>
   <%// Inline Rest Views For SpEd Tabs %>
   <%//=============================================================================%>

   function eventListenerForSpeciallyAdaptedVehicleCheckbox() {
        let checkboxID     = 'speciallyAdaptedVehicleForTransportation'      + '_checkbox_ctrl';
        let checkboxCopyID = 'speciallyAdaptedVehicleForTransportation_copy' + '_checkbox_ctrl';

        // make sure the same value is preloaded for both checkboxes
        let checkboxVal = <%=speciallyAdaptedVehicleForTransportationVal%>;
        $('#' + checkboxCopyID).prop('checked', checkboxVal);

        // event listeners
        $('#' + checkboxID).on('change', function (e) {
            let newVal = $(e.currentTarget).prop('checked');
            $('#' + checkboxCopyID).prop('checked', newVal);
        });

        $('#' + checkboxCopyID).on('change', function (e) {
            let newVal = $(e.currentTarget).prop('checked');
            $('#speciallyAdaptedVehicleForTransportation').val(newVal);
            $('#' + checkboxID).prop('checked', newVal);
        });
    }

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function opnPatGoalProgress() {
        let reqUrl = '<%=urlViewAllPatientGoalsProgress%>'

        let fnEntryTest = function () { return true; };
        let fnExitTest = function () { return true; };
        let fnResume = function () { return true; };

        $.spedmonWebUI.popupThenResume(fnEntryTest
            , fnExitTest
            , fnResume
            , reqUrl
            , 'Popups Not Supported'
            , 'Please allow popups for SpEdCare'
            , 'Waiting'
            , 'Waiting for you to finish with patient goals');
    }

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

   function manageTeleIEPFileLibrary() {

        let cid = $('#clientid').val();
        let pid = $('#patid').val();
        if ((cid != '') && (pid != '')) {
            var fileAdditionalDataJSONStr = '{clientid:' + cid + ', patid:' + pid + '}';
            $.spedmonWebUI.fileList( '<%=Spedmon.TeleIEPSessions.SEL_LABEL%>'
                              , '<%=MBA.StoredFiles.LIST_HANDLER_PRIVATE()%>'
                              , '<%=MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE()%>'
                              , '<%=MBA.StoredFiles.PARAM_FILE_ID%>'
                              , 3 /* Record id position */
                              , '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>'
                              , '<%=Spedmon.TeleIEPSessions.VAL_FILE_CLASS%>'
                              , '' /* File subclass */
                              , '<%=Spedmon.TeleIEPSessions.VAL_FILE_NAMESPACE%>'
                              , '<%=Spedmon.TeleIEPSessions.VAL_FILE_SOURCE%>'
                              , fileAdditionalDataJSONStr
                              , true
                              , true);
        }
    }

   <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function fnCreateIEPMeeting() {

        let participantdetailsVal = JSON.stringify({
            "participantdetails": JSON.parse($('#spedparticipantdetails').val())
            });
        
        let reqUrl = '<%=Spedmon.TeleIEPSessions.URL_SAVE_IEP()%>';
        let reqData = JSON.stringify({
            "clientid": $('#' + PARM_NAME_CLIENT_ID).val()
            , "facilitatoruserid": $('#spedfacilitatoruserid').val()
            , "patid": $('#' + PARM_NAME_PAT_ID).val()
            , "iepformtype": "1" // SEIS
            , "meetingdate": $('#spedmeetingdate').val()
            , "meetingtime": $('#spedmeetingtime').val()
            , "meetingdurationinmins": $('#spedmeetingdurationinmins').val()
            , "title": $('#spedmeetingtitle').val()
            , "participantdetails": participantdetailsVal
            , "filestoshareuploadids": $('#filestoshareuploadids').val()
            , "savetype": "1"
            , "validaterec": "0"
            , "editDelReason": ""
            , "recid": ""
        });
        
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                // refresh hyQueue history rest view
                $('#spEdTeamMembersHyQueueRestView').MBA_RestView('requestViewFromServer', 1);

                $.spedmonWebUI.dialogMessage('Success', "IEP meeting successfully created.", null, 400, 200, null, null, null);
                return true;
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('Error', responseData.message, null, 400, 200, null, null, null);
            });

        return;
    }
   
    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function updateAdditionalViewParameterValuesAndRequestViewFromServerSpEdTeamMembers(e) {

        let VALUE_CLIENT_ID       = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID          = $('#' + PARM_NAME_PAT_ID).val();
        let VALUE_PERSON_ROLE_ID  = '1';
        let VALUE_MIDDLE_NAME     = '';
        let VALUE_ACTIVE          = '1';
        let VALUE_VALIDATE_REC    = '0';
        let VALUE_EDIT_DEL_REASON = '';

        let NV_CLIENT_ID       = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_PATIENT_ID      = MBA.RestViewCommon.fnCreateNameValueObject('patientid', VALUE_PAT_ID);
        let NV_PERSON_ROLE_ID  = MBA.RestViewCommon.fnCreateNameValueObject(PARM_PERSON_ROLE_ID, VALUE_PERSON_ROLE_ID);
        let NV_MIDDLE_NAME     = MBA.RestViewCommon.fnCreateNameValueObject(PARM_MIDDLE_NAME, VALUE_MIDDLE_NAME);
        let NV_ACTIVE          = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);
        let NV_VALIDATE_REC    = MBA.RestViewCommon.fnCreateNameValueObject(PARM_VALIDATE_REC, VALUE_VALIDATE_REC);
        let NN_EDIT_DEL_REASON = MBA.RestViewCommon.fnCreateNameValueObject(PARM_EDIT_DEL_REASON, VALUE_EDIT_DEL_REASON);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        /* We need these for the add new */


        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_CLIENT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PATIENT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PERSON_ROLE_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_MIDDLE_NAME);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_VALIDATE_REC);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForAddNewSet', NN_EDIT_DEL_REASON);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForEditSet', NV_CLIENT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PATIENT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PERSON_ROLE_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForEditSet', NV_MIDDLE_NAME);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForEditSet', NV_VALIDATE_REC);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForEditSet', NN_EDIT_DEL_REASON);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_CLIENT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_PATIENT_ID);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForDeleteSet', NV_VALIDATE_REC);
        $($restViewCtrlSpEdTeamMembers).MBA_RestView('additionalParameterDefinitionForDeleteSet', NN_EDIT_DEL_REASON);

        $($restViewCtrlSpEdTeamMembers).MBA_RestView('requestViewFromServer', 1);

    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initViewSpEdTeamMembers() {

        let opts = {};
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = true;
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;
        opts.refreshViewAfterInlineEditProceed = true;

        opts.saveModeAddNew = 'inline';
        opts.baseUrlAddNew = '<%=Spedmon.PatientPersons.URL_SAVE_BASE()%>';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'inline';
        opts.baseUrlEdit = '<%=Spedmon.PatientPersons.URL_SAVE_BASE()%>';
        opts.baseUrlEditHasParameters = true;

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '<%=Spedmon.PatientPersons.URL_DELETE_BASE()%>'
        opts.baseUrlDeleteHasParameters = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.PatientPersons.URL_REST_VIEW_BASE()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.PatientPerson.DEFAULT_PAGING_ORDER%>';

        opts.enableReports = false;
        opts.enableReportHtml = false;
        opts.enableReportXls = false;
        opts.enableReportPdf = false;

        opts.fieldDefinitions = [];

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'lastName'
            , label: 'Last Name'
            , toolTip: 'Last Name'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'lastName'
            , saveUsing: 'lastname'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'firstName'
            , label: 'First Name'
            , toolTip: 'First Name'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'firstName'
            , saveUsing: 'firstname'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Has Role Details (Additional Cell in Role Selection) %>
        <%//-----------------------------------------------------------------------------%>

        let roleIDAdditionalCellValueFieldDefinitions = [];

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'hasRoleDetBut'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: ''
            , showMore: false
        });

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'fax'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'fax'
            , showMore: false
        });

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'additionalData1'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'additionaldata1'
            , showMore: false
        });

        roleIDAdditionalCellValueFieldDefinitions.push({
            name: 'additionalData2'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'additionaldata2'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Role Dropdown %>
        <%//-----------------------------------------------------------------------------%>

        let roleFieldOptions = {};

        roleFieldOptions.selections = [
            { name: 'Mother', value: '1000' }
            , { name: 'Father', value: '1001' }
            , { name: 'Guardian / Surrogate', value: '1002' }
            , { name: 'School Nurse', value: '5000' }
            , { name: 'Mental Health Provider', value: '5001' }
            , { name: 'General Ed Teacher', value: '5002' }
            , { name: 'Physician', value: '2000' }
            , { name: 'Other School Staff', value: '3003' }
            , { name: 'Outside Agency Representative', value: '6000' }
            , { name: 'Outside School Representative', value: '6001' }
            , { name: 'Parent Representative', value: '6002' }
        ];

        opts.fieldDefinitions.push({
            name: 'classID2'
            , label: 'Role'
            , toolTip: 'Role'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'selectoption'
            , dataTypeOptions: roleFieldOptions
            , sortUsing: 'classID2'
            , saveUsing: 'personrelationshipid'
            , showMore: false
            , handlerFn: function (uiActionObj) {
                roleSelHandlerFn(uiActionObj);
                return uiActionObj;
            }
            , additionalCellValueFieldDefinitions: roleIDAdditionalCellValueFieldDefinitions
        });

        opts.fieldDefinitions.push({
            name: 'email'
            , label: 'Email'
            , toolTip: 'Email'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'email'
            , saveUsing: 'email'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'phone'
            , label: 'Phone'
            , toolTip: 'Phone'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'phone'
            , saveUsing: 'phone'
            , showMore: false
        });

        <%//-----------------------------------------------------------------------------%>
        <%// Address Details (Additional Cell in Address Col) %>
        <%//-----------------------------------------------------------------------------%>

        let addressAdditionalCellValueFieldDefinitions = [];

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'address1'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'address1'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'address2'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'address2'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'city'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'city'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'state'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'state'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'zip5'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'zip5'
            , showMore: false
        });

        addressAdditionalCellValueFieldDefinitions.push({
            name: 'zip4'
            , label: ''
            , toolTip: ''
            , visible: true
            , sortable: false
            , editable: true
            , saveable: true
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'zip4'
            , showMore: false
        });

        /* Address column */

        opts.fieldDefinitions.push({
            name: 'address'
            , label: 'Address'
            , toolTip: 'Address'
            , visible: true
            , editable: false
            , saveable: false
            , sortable: false
            , isRecID: false
            , dataType: 'hidden'
            , saveUsing: ''
            , sortUsing: ''
            , additionalCellValueFieldDefinitions: addressAdditionalCellValueFieldDefinitions
        });

        <%//*************************************** Cell (Column) Creation Hooks ***************************************************%>

        opts.fnCreateNewCellAfter = function (newCell, subsection, rowtype, dataObj, rowIdxCtr, colIdxCtr, fieldDefinition, fieldValue, newRow, rowData, newCellValueElem, addCellValRefs, addCellValRefsMap) {

            <%//-----------------------------------------------------------------------------%>
            <%// Role Selection Column %>
            <%//-----------------------------------------------------------------------------%>

            if (fieldDefinition.name === 'classID2') {
                let hasRoleDetButVal = (rowData.classID2 == 2000) ? 'true' : 'false';

                let $rowRef = $(newRow)[0];
                let $dsDetails = $('<details class="physician-details" title="This Role Requires More Information"></details>');
                $dsDetails.append('<summary class="physician-details">Show Details</summary>');
                $(newCell).append($dsDetails);

                /* Setup hasRoleDetBut */

                let hasRoleDetButCellRef = addCellValRefsMap.get('hasRoleDetBut');
                $(hasRoleDetButCellRef).on(MBA.RestViewCommon.EVENT_NAME_EDIT_CANCEL + ' ' + MBA.RestViewCommon.EVENT_NAME_EDIT_PROCEED, function (e) {
                    showOrHidePhysicianDetails(hasRoleDetButVal, $dsDetails, false);
                });

                /* Setup input for fax */

                let faxCellRef = addCellValRefsMap.get('fax');
                $(faxCellRef).attr('type', 'text');
                if ($(faxCellRef).val() == 'null' || $(faxCellRef).val() == 'undefined') {
                    $(faxCellRef).val('');
                }
                let $faxDiv = $('<div class="mb-2"></div>');
                $($faxDiv).append('<span class="mr-2">Fax</span>').append($(faxCellRef));
                
                /* Setup input for NPI */

                let npiCellRef = addCellValRefsMap.get('additionalData1');
                $(npiCellRef).attr('type', 'text');
                if ($(npiCellRef).val() == 'null' || $(npiCellRef).val() == 'undefined') {
                    $(npiCellRef).val('');
                }
                let $npiDiv = $('<div class="mb-2"></div>');
                $($npiDiv).append('<span class="mr-2">NPI</span>').append($(npiCellRef));
                
                /* Setup input for Medi-Cal Provider */

                let mediCalProviderCellRef = addCellValRefsMap.get('additionalData2');
                $(mediCalProviderCellRef).attr('type', 'text');
                if ($(mediCalProviderCellRef).val() == 'null' || $(mediCalProviderCellRef).val() == 'undefined') {
                    $(mediCalProviderCellRef).val('');
                }
                let $mediCalProviderDiv = $('<div class="mb-2"></div>');
                $($mediCalProviderDiv).append('<span class="mr-2">Medi-Cal Provider ID</span>').append($(mediCalProviderCellRef));
                
                $($dsDetails).append($faxDiv);
                $($dsDetails).append($npiDiv);
                $($dsDetails).append($mediCalProviderDiv);

                /* Create an object we can reference if there are changes made to the nameID (autocomplete) */

                let physicianDetailsRefObj = {};
                physicianDetailsRefObj.rowRef = $rowRef;
                physicianDetailsRefObj.hasRoleDetBut = hasRoleDetButVal;
                physicianDetailsRefObj.dsDetails = $dsDetails;
                physicianDetailsRefObj.addCellValRefs = addCellValRefs;
                physicianDetailsRefObj.addCellValRefsMap = addCellValRefsMap;

                /* Save this object */

                $(newCellValueElem).data(CONST_PHYSICIAN_DETAILS_REF, physicianDetailsRefObj);

                /* Show or hide service details based on initial data loaded from server */

                showOrHidePhysicianDetails(hasRoleDetButVal, $dsDetails, false);
            }

            <%//-----------------------------------------------------------------------------%>
            <%// Address Column %>
            <%//-----------------------------------------------------------------------------%>

            else if (fieldDefinition.name === 'address') {
                let $rowRef = $(newRow)[0];
                let $dsDetails = $('<details class="address-details" title="This Column Requires More Information"></details>');
                $dsDetails.append('<summary class="address-details">Show Details</summary>');
                $(newCell).append($dsDetails);

                /* Setup inputs */
                
                let address1CellRef = addCellValRefsMap.get('address1');
                $(address1CellRef).attr('type', 'text');
                if ($(address1CellRef).val() == 'null' || $(address1CellRef).val() == 'undefined') {
                    $(address1CellRef).val('');
                }
                let $address1Div = $('<div class="mb-2"></div>');
                $($address1Div).append('<span class="mr-2">Street Address 1</span>').append($(address1CellRef));
                
                let address2CellRef = addCellValRefsMap.get('address2');
                $(address2CellRef).attr('type', 'text');
                if ($(address2CellRef).val() == 'null' || $(address2CellRef).val() == 'undefined') {
                    $(address2CellRef).val('');
                }
                let $address2Div = $('<div class="mb-2"></div>');
                $($address2Div).append('<span class="mr-2">Street Address 2</span>').append($(address2CellRef));

                let cityCellRef = addCellValRefsMap.get('city');
                $(cityCellRef).attr('type', 'text');
                if ($(cityCellRef).val() == 'null' || $(cityCellRef).val() == 'undefined') {
                    $(cityCellRef).val('');
                }
                let $cityDiv = $('<div class="mb-2"></div>');
                $($cityDiv).append('<span class="mr-2">City</span>').append($(cityCellRef));

                let stateCellRef = addCellValRefsMap.get('state');
                $(stateCellRef).attr('type', 'text');
                if ($(stateCellRef).val() == 'null' || $(stateCellRef).val() == 'undefined') {
                    $(stateCellRef).val('');
                }
                let $stateDiv = $('<div class="mb-2"></div>');
                $($stateDiv).append('<span class="mr-2">State</span>').append($(stateCellRef));

                let zip5CellRef = addCellValRefsMap.get('zip5');
                $(zip5CellRef).attr('type', 'text');
                if ($(zip5CellRef).val() == 'null' || $(zip5CellRef).val() == 'undefined') {
                    $(zip5CellRef).val('');
                }
                let $zip5Div = $('<div class="mb-2"></div>');
                $($zip5Div).append('<span class="mr-2">Zip (First 5)</span>').append($(zip5CellRef));

                let zip4CellRef = addCellValRefsMap.get('zip4');
                $(zip4CellRef).attr('type', 'text');
                if ($(zip4CellRef).val() == 'null' || $(zip4CellRef).val() == 'undefined') {
                    $(zip4CellRef).val('');
                }
                let $zip4Div = $('<div class="mb-2"></div>');
                $($zip4Div).append('<span class="mr-2">Zip (Last 4)</span>').append($(zip4CellRef));

                $($dsDetails).append($address1Div);
                $($dsDetails).append($address2Div);
                $($dsDetails).append($cityDiv);
                $($dsDetails).append($stateDiv);
                $($dsDetails).append($zip5Div);
                $($dsDetails).append($zip4Div);
            }

            /* Return cell new as required */

            return newCell;
        };

        opts.fnOnResponseViewFromServer = function (elem, responseData, $me, dataObj) {
            let rowsArr = [];
            let idxCounter = 1;
            
            $.each(responseData.data, function (idx, obj) {
                // get the correct roleID to match hyQueue
                let roleIDVal = "88"; // 88 - Additional Participant
                switch (obj.classID2) {
                    case 1000:
                    case 1001:
                    case 1002:
                        roleIDVal = "12"; // Parent / Guardian / Surrogate
                        break;
                    case 5002:
                        roleIDVal = "7"; // General Education Teacher
                        break;
                    default:
                        roleIDVal = "88";
                }

                // create the object and put it in our array
                
                let participantObj = {
                    "idx": "" + idxCounter
                    , "name": obj.name
                    , "title": obj.className2
                    , "email": obj.email
                    , "phone": obj.phone
                    , "pin": ""
                    , "userID": ""
                    , "roleID": roleIDVal
                    , "entityID": ""
                };

                rowsArr.push(participantObj);
                idxCounter++;
            });

            $('#spedparticipantdetails').val(JSON.stringify(rowsArr));

            return;
        }

        /* Create the rest view(s) */
        $($restViewCtrlSpEdTeamMembers).MBA_RestView(opts);

    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function updateAdditionalViewParameterValuesAndRequestViewFromServerSpEd(e) {

        let VALUE_CLIENT_ID = $('#' + PARM_NAME_CLIENT_ID).val();
        let VALUE_PAT_ID = $('#' + PARM_NAME_PAT_ID).val();
        let VALUE_ACTIVE = '1';

        let NV_CLIENT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_CLIENT_ID, VALUE_CLIENT_ID);
        let NV_PAT_ID = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_PAT_ID, VALUE_PAT_ID);
        let NV_ACTIVE = MBA.RestViewCommon.fnCreateNameValueObject(PARM_NAME_ACTIVE, VALUE_ACTIVE);

        /* Note: Don't use a loop here, keep it unrolled for performance reasons */

        $($restViewCtrlSpEd).MBA_RestView('additionalParameterDefinitionForViewSet', NV_CLIENT_ID);
        $($restViewCtrlSpEd).MBA_RestView('additionalParameterDefinitionForViewSet', NV_PAT_ID);
        $($restViewCtrlSpEd).MBA_RestView('additionalParameterDefinitionForViewSet', NV_ACTIVE);

        /* We need these for the add new / edit */

        $($restViewCtrlSpEd).MBA_RestView('additionalParameterDefinitionForAddNewSet', NV_PAT_ID);
        $($restViewCtrlSpEd).MBA_RestView('additionalParameterDefinitionForEditSet', NV_PAT_ID);

        $($restViewCtrlSpEd).MBA_RestView('requestViewFromServer', 1);
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initViewSpEd() {

        <%//-----------------------------------------------------------------------------%>
        <%// Setup Rest View - Basics %>
        <%//-----------------------------------------------------------------------------%>

        let opts = {};

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false; /* Turn off row numbers */
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.enableRowControlRecEdit = true;
        opts.enableRowControlRecDelete = true;

        opts.loadModeView = 'rest';
        opts.baseUrlView = '<%=Spedmon.PatientPromisedServices.URL_REST_VIEW()%>';
        opts.baseUrlViewHasParameters = true;
        opts.defaultPageRowOrder = '<%=Spedmon.PatientPromisedService.DEFAULT_PAGING_ORDER%>';

        opts.saveModeAddNew = 'inwindow';
        opts.baseUrlAddNew = '<%=Spedmon.PatientPromisedServices.URL_ADD_NEW_PATIENT_PROMISED_SERVICE()%>';
        opts.baseUrlAddNewHasParameters = true;

        opts.saveModeEdit = 'custom';
        opts.baseUrlEdit = '<%=Spedmon.PatientPromisedServices.URL_EDIT_PATIENT_PROMISED_SERVICE()%>';
        opts.baseUrlEditHasParameters = true;
        opts.handlerFnEditCustom = function (uiActionObj) {
            let nvpObjs = [];

            uiActionObj.dataObj.opts.additionalParameterDefinitionsForEdit.forEach(function (value, key) {
                nvpObjs.push(MBA.RestViewCommon.fnCreateNameValueObject(key, value));
            });

            let rid = uiActionObj.recordID;
            let baseUrl = uiActionObj.dataObj.opts.baseUrlEdit + rid; // add recid to parameters

            let url = MBA.RestViewCommon.fnBuildUrl(baseUrl
                , uiActionObj.dataObj.opts.baseUrlEditHasParameters
                , nvpObjs);

            let newWindowName = 'edit-' + rid;
            let newWindow = MBA.RestViewCommon.fnOpenWindow(uiActionObj.elem, url, newWindowName, true);
            uiActionObj.newWindow = newWindow;

            return uiActionObj;
        };

        opts.saveModeDelete = 'inline';
        opts.baseUrlDelete = '<%=Spedmon.PatientPromisedServices.URL_REST_DELETE_INLINE()%>';
        opts.baseUrlDeleteHasParameters = true;

        opts.enableReports = false;

        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();


        <%//*************************************** Field Definitions ************************************%>

        <%//-----------------------------------------------------------------------------%>
        <%// Service Record ID %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        opts.fieldDefinitions.push({
            name: 'spEdServiceCodeAndName'
            , label: 'Service'
            , toolTip: 'The service to be provided'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdServiceCodeAndName'
            , saveUsing: 'spEdServiceCodeAndName'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'spEdProviderCodeAndName'
            , label: 'Provider'
            , toolTip: 'Who is the service provider'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdProviderCodeAndName'
            , saveUsing: 'spEdProviderCodeAndName'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'spEdFreqCodeAndName'
            , label: 'Frequency'
            , toolTip: 'Service frequency'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdFreqCodeAndName'
            , saveUsing: 'spEdFreqCodeAndName'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'spEdLocationCodeAndName'
            , label: 'Location'
            , toolTip: 'Service location'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'text'
            , sortUsing: 'spEdLocationCodeAndName'
            , saveUsing: 'spEdLocationCodeAndName'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'startDateStr'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'startDate'
            , saveUsing: 'startDate'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'endDateStr'
            , label: 'End Date'
            , toolTip: 'End Date'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'endDate'
            , saveUsing: 'endDate'
            , showMore: false
        });


        opts.fieldDefinitions.push({
            name: 'minsPerFreq'
            , label: 'Total Minutes<br/>(Recurring)'
            , toolTip: 'Minutes per frequency interval'
            , visible: true
            , sortable: true
            , saveable: false
            , editable: false
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'minsPerFreq'
            , saveUsing: 'minsPerFreq'
            , showMore: false
        });

        /* Create the rest view */

        $($restViewCtrlSpEd).MBA_RestView(opts);
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initDataGridSpEd() {

        <%//-----------------------------------------------------------------------------%>
        <%// Setup Rest View - Basics %>
        <%//-----------------------------------------------------------------------------%>

        let opts = {};

        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestViewOnLoad = false; /*This is so we can set the initial filters */
        opts.enableSortControls = true;
        opts.enableRowNumbers = false; /* Turn off row numbers */
        opts.enableRowControls = true;
        opts.enableRowControlRecAddNew = true;
        opts.saveModeAddNew = 'inlineunlockedfields';
        opts.enableRowControlRecEdit = false;
        opts.saveModeEdit = 'inline';
        opts.enableRowControlRecDelete = true;
        opts.saveModeDelete = 'inlineunlockedfields';
        opts.jsonInputHtml = '<textarea id="spEdServicesDataGridTextArea" name="spEdServicesDataGridTextArea" class="d-none"></textarea>';

        opts.fieldDefinitions = [];
        opts.additionalControlDefinitionsForBodyRows = new Map();


        <%//*************************************** Field Definitions ************************************%>

        <%//-----------------------------------------------------------------------------%>
        <%// Record ID %>
        <%//-----------------------------------------------------------------------------%>

        opts.fieldDefinitions.push({
            name: 'id'
            , isRecID: true
            , saveable: true
            , saveUsing: 'recid'
        });

        <%/* Setup autocomplete - Basics */%>

        let serviceOpts = {};
        serviceOpts.baseUrl = '<%=Spedmon.SpEdServices.URL_VIEW_SEL_BASE()%>';
        serviceOpts.loadMode = 'mbaviewsel';
        serviceOpts.getInitialSelectedNameFrom = 'spEdServiceCodeAndName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        serviceOpts.fnOnSelect = function (event, ui) {
            // save the label
            let $svcSel = $(event.target)[0];
            let $svcNameTd = $($svcSel).parents('td').siblings('td[data-mba-rest-view-field-name="spEdServiceCodeAndName"]');
            let $svcNameInput = $($svcNameTd).find('input[data-mba-rest-view-field-name="spEdServiceCodeAndName"]');

            // remove code value
            let lblStr = ui.item.label;
            let formattedStr = '';
            if (lblStr) {
                formattedStr = lblStr.substring(lblStr.indexOf(' ') + 1);
            }

            $($svcNameInput).val(formattedStr); 
            $($svcNameInput).trigger('change');
            return;
        };

        <%/* Setup autocomplete - Customization Hooks  */%>

        serviceOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        serviceOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        serviceOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li;};
        serviceOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'spEdServiceCode'
            , label: 'Service'
            , toolTip: 'The service to be provided'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'spEdServiceCode'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: serviceOpts
            , sortUsing: 'spEdServiceCode'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'spEdServiceCodeAndName'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'spEdServiceCodeAndName'
            , showMore: false
        });

        <%/* Setup autocomplete - Basics */%>

        let providerOpts = {};
        providerOpts.baseUrl = '<%=Spedmon.SpEdServiceProviders.URL_VIEW_SEL_BASE()%>';
        providerOpts.loadMode = 'mbaviewsel';
        providerOpts.getInitialSelectedNameFrom = 'spEdProviderCodeAndName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        providerOpts.fnOnSelect = function (event, ui) {
            // save the label
            let $providerSel = $(event.target)[0];
            let $providerNameTd = $($providerSel).parents('td').siblings('td[data-mba-rest-view-field-name="spEdProviderCodeAndName"]');
            let $providerNameInput = $($providerNameTd).find('input[data-mba-rest-view-field-name="spEdProviderCodeAndName"]');

            // remove code value
            let lblStr = ui.item.label;
            let formattedStr = '';
            if (lblStr) {
                formattedStr = lblStr.substring(lblStr.indexOf(' ') + 1);
            }

            $($providerNameInput).val(formattedStr); 
            $($providerNameInput).trigger('change');
            return;
        };

        <%/* Setup autocomplete - Customization Hooks  */%>

        providerOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        providerOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        providerOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li;};
        providerOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'spEdProviderCode'
            , label: 'Provider'
            , toolTip: 'Who is the service provider'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'spEdProviderCode'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: providerOpts
            , sortUsing: 'spEdProviderCode'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'spEdProviderCodeAndName'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'spEdProviderCodeAndName'
            , showMore: false
        });

        <%/* Setup autocomplete - Basics */%>

        let freqOpts = {};
        freqOpts.baseUrl = '<%=Spedmon.SpEdServiceFrequencies.URL_VIEW_SEL_BASE()%>';
        freqOpts.loadMode = 'mbaviewsel';
        freqOpts.getInitialSelectedNameFrom = 'spEdFreqCodeAndName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        freqOpts.fnOnSelect = function (event, ui) {
            // save the label
            let $freqSel = $(event.target)[0];
            let $freqNameTd = $($freqSel).parents('td').siblings('td[data-mba-rest-view-field-name="spEdFreqCodeAndName"]');
            let $freqNameInput = $($freqNameTd).find('input[data-mba-rest-view-field-name="spEdFreqCodeAndName"]');

            // remove code value
            let lblStr = ui.item.label;
            let formattedStr = '';
            if (lblStr) {
                formattedStr = lblStr.substring(lblStr.indexOf(' ') + 1);
            }

            $($freqNameInput).val(formattedStr);
            $($freqNameInput).trigger('change');
            return;
        };

        <%/* Setup autocomplete - Customization Hooks  */%>

        freqOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        freqOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        freqOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li;};
        freqOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'spEdFreqCode'
            , label: 'Frequency'
            , toolTip: 'Service frequency'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'spEdFreqCode'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: freqOpts
            , sortUsing: 'spEdFreqCode'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'spEdFreqCodeAndName'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'spEdFreqCodeAndName'
            , showMore: false
        });

        <%/* Setup autocomplete - Basics */%>

        let locOpts = {};
        locOpts.baseUrl = '<%=Spedmon.SpEdServiceLocations.URL_VIEW_SEL_BASE()%>';
        locOpts.loadMode = 'mbaviewsel';
        locOpts.getInitialSelectedNameFrom = 'spEdLocationCodeAndName';

        <%/* Setup autocomplete - Handle Changes in Selection */%>

        locOpts.fnOnSelect = function (event, ui) {
            // save the label
            let $locSel = $(event.target)[0];
            let $locNameTd = $($locSel).parents('td').siblings('td[data-mba-rest-view-field-name="spEdLocationCodeAndName"]');
            let $locNameInput = $($locNameTd).find('input[data-mba-rest-view-field-name="spEdLocationCodeAndName"]');

            // remove code value
            let lblStr = ui.item.label;
            let formattedStr = '';
            if (lblStr) {
                formattedStr = lblStr.substring(lblStr.indexOf(' ') + 1);
            }

            $($locNameInput).val(formattedStr);
            $($locNameInput).trigger('change');
            return;
        };

        <%/* Setup autocomplete - Customization Hooks  */%>

        locOpts.fnModifyRequestNvps     = function (nvpsIn) {return nvpsIn;};
        locOpts.fnModifyResponseSelRecs = function (requestNvps, SelRecs) { return SelRecs;};
        locOpts.fnModifyRenderItem = function ($ul, item, $li) { return $li;};
        locOpts.fnHandleCellValueAction = function (uiActionObj) { return uiActionObj;};

        <%/* Finally add field def  */%>

        opts.fieldDefinitions.push({
            name: 'spEdLocationCode'
            , label: 'Location'
            , toolTip: 'Service location'
            , visible: true
            , sortable: true
            , editable: true
            , saveable: true
            , saveUsing: 'spEdLocationCode'
            , isRecID: false
            , dataType: 'autocomplete'
            , dataTypeOptions: locOpts
            , sortUsing: 'spEdLocationCode'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'spEdLocationCodeAndName'
            , visible: false
            , sortable: false
            , saveable: true
            , editable: false
            , isRecID: false
            , dataType: 'hidden'
            , sortUsing: ''
            , saveUsing: 'spEdLocationCodeAndName'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'startDate'
            , label: 'Start Date'
            , toolTip: 'Start Date'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'startDate'
            , saveUsing: 'startDate'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'endDate'
            , label: 'End Date'
            , toolTip: 'End Date'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'date'
            , sortUsing: 'endDate'
            , saveUsing: 'endDate'
            , showMore: false
        });
        
        opts.fieldDefinitions.push({
            name: 'minsPerFreq'
            , label: 'Total Minutes<br/>(Recurring)'
            , toolTip: 'Minutes per frequency interval'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'number'
            , sortUsing: 'minsPerFreq'
            , saveUsing: 'minsPerFreq'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'individualDelivery'
            , label: 'Individual<br/>Delivery'
            , toolTip: 'Individual Delivery'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: 'individualDelivery'
            , saveUsing: 'individualDelivery'
            , showMore: false
        });

        opts.fieldDefinitions.push({
            name: 'groupDelivery'
            , label: 'Group<br/>Delivery'
            , toolTip: 'Group Delivery'
            , visible: true
            , sortable: true
            , saveable: true
            , editable: true
            , isRecID: false
            , dataType: 'checkbox'
            , sortUsing: 'groupDelivery'
            , saveUsing: 'groupDelivery'
            , showMore: false
        });

        // put the value of the grid's hidden textarea into our own
        // (we do not save the grid's hidden textarea value)

        opts.fnSaveDataAfter = function (dataAsMap, dataAsArr, dataAsJSON, okToWorkWithData) {
            $('#spedservicesdatajson').val(JSON.stringify(dataAsArr));
        };
        
        // preload data if nothing is currently saved for this patient

        <%if(hasSpEdServiceData == true){%>
        opts.tblDataArr = JSON.parse($('#spedservicesdatajson').val());
        <%}%>

        /* Create the data grid */

        $($restViewCtrlSpEdIepServices).MBA_DataGrid(opts);
    }

    

    function _fnLoadReasonForVisit() {
        let valueGrpSvcClsNmeID = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
        let requestObj = {};
        $('#mgn_pat_practiceofficevisitreasonid').empty();

        requestObj['<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'] = valueGrpSvcClsNmeID;
        requestObj['<%=Spedmon.Constants.PARM_SEARCH_TERM%>'] = "";

        let requestJSON = JSON.stringify(requestObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>', requestJSON, null)
            .then(responseData => {
                $.each(responseData.rawData.SelRecs, function (index, option) {
                    $('#mgn_pat_practiceofficevisitreasonid').append(
                        $('<option>', {
                            value: option.id,  // Asignamos el id como value
                            text: option.value // Asignamos el label como el texto
                        })
                    );
                });
                
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
            });
    };   

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initScheduledServicesForPracAndPatOnDos() {
        
        let optsIn = {
              PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PRACTITIONER_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PATIENT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'            
            , PARM_NAME_ACTIVE: '<%=Constants.PARM_ACTIVE%>'
            , PARM_NAME_DOS: '<%=Constants.PARM_DOS%>'
            , PARM_NAME_SAVE_TYPE: '<%=Spedmon.Constants.PARM_SAVE_TYPE%>'
            , PARM_NAME_REC_ID: '<%=Constants.PARM_REC_ID%>'
            , PARM_NAME_PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICE_ID:  '<%=Constants.PARM_PRAC_PAT_CASELOAD_EXPECTED_SVC_ID%>'
            , PARM_SVC_NOTES_FB_QUESTIONS: '<%=Constants.PARM_SVC_NOTES_FB_QUESTIONS%>'
            , PARM_SVC_NOTES_FB_ANSWERS: '<%=Constants.PARM_SVC_NOTES_FB_ANSWERS%>'
            , PARM_REF_DATE: '<%=Constants.PARM_REF_DATE%>'
            , PARM_SVC_NAME: '<%=Constants.PARM_SVC_NAME%>'
            , PARM_NOTES: '<%=Constants.PARM_NOTES%>'
            , PARM_HAS_PAT_GOAL_TRACKING_DATA:'<%=Constants.PARM_HAS_PAT_GOAL_TRACKING_DATA%>'
            , PARM_PAT_GOAL_PROGRESS: '<%=Constants.PARM_PAT_GOAL_PROGRESS%>'
            , PARM_GROUP_ID: '<%=Constants.PARM_GROUP_ID%>'
            , PARM_NAME_ID: '<%=Constants.PARM_NAME_ID%>'
            , PARM_VIA_TELEHEALTH: '<%=Constants.PARM_VIA_TELEHEALTH%>'
            , PARM_NAME_TERM: '<%=Constants.PARM_SEARCH_TERM%>'
            , PARM_NAME_SITE_ID: '<%=Spedmon.Constants.PARM_SITE_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_SVC_NAMES_LIST_DATA_SOURCE_ID: '<%=Constants.PARM_SVC_NAMES_LIST_DATA_SOURCE_ID%>'
            , PARM_GRP_SVC_NAME_ID: '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>'
            , PARM_NAME_ORP_APR_STATE: '<%=Spedmon.Constants.PARM_ORP_APPROVAL_STATE%>'
            , baseUrlViewOrderAndPx: '<%=urlManageOrderAndPx%>'
            , containerCtrlID: 'scheduledservicesforpracandpatondoscont'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.ServiceRecords.URL_REST_VIEW_BASE()%>'
            , defaultPageRowOrder: 'dos desc'
            , baseUrlAddNew: '<%=Spedmon.PractitionerPatientScheduledServices.URL_ADD_NEW_BASE()%>'
            , baseUrlEditServiceRec: '<%=Spedmon.PractitionerPatientScheduledServices.URL_EDIT_BASE()%>'
            , baseUrlViewScheduledSvcsOnDosForPat: '<%=Spedmon.ServiceRecordsExpectedEntryRows.URL_ASMX_VIEW_LIST_EXP_TMT_SVCS_ON_DOS_FOR_PAT_BASE()%>'
            , baseUrlSaveNewServiceRec: '<%=Spedmon.ServiceRecords.URL_SVC_ADD_NEW_INLINE_BASE()%>'
            , svcSelName: '<%=Spedmon.Services.URL_VIEW_SEL2_BASE()%>'
            , baseUrlViewAllPatientGoalsProgress: '<%=urlViewAllPatientGoalsProgress%>'
            , baseUrlViewPatientGoalsProgress: '<%=urlViewPatientGoalsProgress%>'
            , baseUrlNoteLibExport: '<%=Spedmon.NoteLibrarySavedNotes.URL_EXPORT_NOTE_BASE()%>'
            , saveTypeValueForNew: '<%=Constants.SAVE_TYPE_NEW%>'
            , saveTypeValueForEdit: '<%=Constants.SAVE_TYPE_EDIT%>'
            , tkn: '<%=this.rd.wu.usr.token%>'
            , attendanceSelections: <%=attendanceSelectionsJSON%>   
            , svcPlanTypeSelections: <%=serviceNamesListPlanTypesJSON%>   

        };

        MBA.ScheduledServicesProvidedByPracForPatOnDOSCommon.fnSetup('scheduledservicesforpracandpatondosview', optsIn);

    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>
    <%if (canReferPatient == true) { %>
    function doReferrPatient() {
         MBA.ComponentCommon.fnOpenWindow('<%=urlPracPatReferal%>', 'managereferral');    
    };
    <%}%>

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>
   
    $(document).ready(function () {

        <%/* ---------- Setup tabs ---------- */%>

        /*$("#pattabs").tabs();
        $('#pattabs').addClass('data-entry-row-tabs');

        $("#patspedtabs").tabs();
        $('#patspedtabs').addClass('data-entry-row-tabs');
        */

        $("#pattabs").MBA_Tabs({});
        $("#patspedtabs").MBA_Tabs({});

        <%/* Goto a specific tab specified by query string parameter if needed */
        if (!String.IsNullOrWhiteSpace(tabToOpen)) {%>
        $('a[href="#<%=tabToOpen%>"]').click();
        <%}%>

        <%/* ---------- Goto a specific tab if needed ---------- */%>

        var tabID = sessionStorage.getItem("tabToClickOnLoad");
        if (tabID) {
            sessionStorage.removeItem("tabToClickOnLoad");
            $('a[href="#' + tabID + '"]').click();
        }


        // remove the 'OK' button from the TextAreaBox
        $('#notes_but_ok').remove();
        $('#patspedtabs').find('.ui-icon-arrowreturnthick-1-e').parent('button').remove();
        
        // remove the DataEntryRow label for the notes
        $('#notesDataEntryRow > div:nth-child(1)').hide();
 
        // set the value of the validaterec field
        $("#validaterec").val("0");

        // Event listener for adding a new Transportation record
        $('#addNewTransportation').click(function () {
            SpEdCare.recPatTransportation.addRec();
        });

        // Event listener for adding a new stop in the Transportation tab

        $('#addNewStopBut').click(function () {
            var tkn = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';
            var url = 'user_all_patient_places_save.aspx';
            var cid = $('#clientid').val();
            var pid = $('#patid').val();

            var reqUrl = $.spedmonWebUI.createPrivateURL(tkn, url)
                + '&amd=uidbssub'
                + '&clientid=' + cid
                + '&patid='    + pid;

            var fnEntryTest = function () { return true; };
            var fnExitTest = function () { return true; };
            var fnResume = function () {
                return true;
            };

            $.spedmonWebUI.popupThenResume(fnEntryTest
                , fnExitTest
                , fnResume
                , reqUrl
                , 'Popups Not Supported'
                , 'Please allow popups for SpEdCare'
                , 'Waiting'
                , 'Waiting for you  to finish with patient places');
        });

        // event listener for our 2 "specially adapted vehicle" checkboxes
        // we have 2 of the same field so we can have them in different tabs
        eventListenerForSpeciallyAdaptedVehicleCheckbox();

        // event listeners in SpEd meeting purpose tab
        spEdMeetingPurposeCheckboxesHandler();
        spEdAdditionalMeetingPurposeCheckboxesHandler();
        spEdAmendmentReasonCheckboxesHandler();
        fnShowOrHideOtherTxtForReferringPerson($('#spedreferringpartycode').val());

        // if recording new patient: hide the tabs that require the patientID

        if ('<%=saveType%>' == $.spedmonWebUI.RECORD_SAVE_TYPE_NEW) {
            $('[href="#tab-medical-history"]').closest('li').hide();
            $('[href="#tab-contacts"]').closest('li').hide();
            $('[href="#tab-services"]').closest('li').hide();
            $('[href="#tab-promised-services"]').closest('li').hide();
            $('[href="#tab-goals"]').closest('li').hide();
            $('[href="#tab-sped-iep"]').closest('li').hide();
            $('[href="#tab-transportation"]').closest('li').hide();
            $('[href="#tab-documentation"]').closest('li').hide();
            $('[href="#tab-files"]').closest('li').hide();
            $('[href="#tab-insurance-carriers"]').closest('li').hide();            
        }

        // hide the IEP tabs for non-pcal users
        <% if (!isPCalStaff) {%>
            $('[href="#tab-sped-iep"]').closest('li').hide();
        <%}%>

        /* Init rest views that require a patient id  */

        if ('<%=saveType%>' == $.spedmonWebUI.RECORD_SAVE_TYPE_EDIT) {
            initOrdersOrPrescriptionsRestView();
            initPatientPersonsView();
            initPromisedServicesView();
            initServiceRecordsView();
            initStoredFilesView();
            initKnownHealthProblemsRestView();
            initAllergiesRestView();
            initDiagnosesRestView();            
            initInsuranceCoverageView();            
            initPatientGoalsView();

            <%if (canUsePreCareNotes == true) { %>
                initPatientCareNotes();
            <%}%>

            <%if (canViewVisitHistory == true) { %>
                initPracticeOfficeRestView();
            <%}%>

            <%if (canAdministerOrdersOrPx == true) { %>
                initOrderOrPrescriptionForHSDelivery();            
            <%}%>

            <%if (canRecordScheduledServices == true) { %>
              initScheduledServicesForPracAndPatOnDos(); /* scheduledservicesforpracandpatondoscont*/            
            <%}%>

            <%if (canAdministerVitalSigns == true) { %>
                initVitalsMeasurementsForPatOnDOS();
            <%}%>

            $('#mgn_pat_butStartVisit').click(function () {
                
                let vw = MBA.ComponentCommon.fnComputePercentOfViewportWidthInPx(50);
                let vh = MBA.ComponentCommon.fnComputePercentOfViewportHeightInPx(90);
                let $newvisitform = $('<form id="mgn_pat_startnewvisit">');
                let $div = $('<div class="form-group">');
                let $labelVisitReasion = $('<label class="mr-2" for="mgn_pat_practiceofficevisitreasonid">Reason for Visit</label>');
                let $selectVisitReason = $('<select class="form-control" id="mgn_pat_practiceofficevisitreasonid" name="mgn_pat_practiceofficevisitreasonid"></select>');
                let $labelReasonNotes = $('<label class="mr-2" for="mgn_pat_practiceofficevisitreasonnotes">Reason For Visit Notes:</label>');
                let $txtareaReasonNotes = $('<textarea class="form-control" id="mgn_pat_practiceofficevisitreasonnotes" name="mgn_pat_practiceofficevisitreasonnotes" placeholder="Notes here..."></textarea>');
               
                $div.append($labelVisitReasion, $selectVisitReason, '<br/>', $labelReasonNotes, $txtareaReasonNotes);
                $($newvisitform).append($div);

                let objGoalChartDiaOpts = {
                    modal: true
                    , width: (vw)
                    , height: (vh)
                    , open: function (event, ui) {

                        let valueGrpSvcClsNmeID = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
                        let requestObj = {};                       

                        requestObj['<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'] = valueGrpSvcClsNmeID;
                        requestObj['<%=Spedmon.Constants.PARM_SEARCH_TERM%>'] = "";

                        let requestJSON = JSON.stringify(requestObj);

                        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PracticeOfficeVisitReasons.URL_VIEW_SEL_BASE()%>', requestJSON, null)
                            .then(responseData => {
                                $.each(responseData.rawData.SelRecs, function (index, option) {
                                    $('#mgn_pat_practiceofficevisitreasonid').append(
                                        $('<option>', {
                                            value: option.id,  
                                            text: option.value 
                                        })
                                    );
                                });

                            })
                            .catch(err => {
                                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                            });
                    }
                    , buttons: [
                        {
                            text: "Close", click: function () {
                                $(this).dialog("close");
                            }
                        },
                        {
                            text: "Start Visit", click: function () {

                                let valueClientID = $('#<%=Spedmon.Constants.PARM_CLIENT_ID%>').val();
                        let valuePracID = $('#<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>').val();
                        let valueGrpSvcClsNmeID = $('#<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>').val();
                        let valuePatID = $('#<%=Spedmon.Constants.PARM_PATIENT_ID%>').val();
                        let valueSiteID = $('#<%=Spedmon.Constants.PARM_SITE_ID%>').val();
                        let valueReasonNotesID = $('#mgn_pat_practiceofficevisitreasonid').val();
                        let valueReasonForVisitNotes = $('#mgn_pat_practiceofficevisitreasonnotes').val();
                        let valueRecID = $('#<%=Spedmon.Constants.PARM_REC_ID%>').val();

                        let requestObj = {};

                        requestObj['<%=Spedmon.Constants.PARM_CLIENT_ID%>'] = valueClientID;
                        requestObj['<%=Spedmon.Constants.PARM_GRP_SVC_CLS_NME_ID%>'] = valueGrpSvcClsNmeID;
                        requestObj['<%=Spedmon.Constants.PARM_SITE_ID%>'] = valueSiteID;
                        requestObj['<%=Spedmon.Constants.PARM_PATIENT_ID%>'] = valuePatID;
                        requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_ID%>'] = valueReasonNotesID;
                        requestObj['<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_REASON_NOTES%>'] = valueReasonForVisitNotes;
                        requestObj['<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'] = valuePracID;
                        requestObj['<%=Spedmon.Constants.PARM_SAVE_TYPE%>'] = "1";
                        requestObj['<%=Spedmon.Constants.PARM_REC_ID%>'] = valueRecID;

                        let requestJSON = JSON.stringify(requestObj);
    
                        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PracticeOfficeVisits.URL_SVC_CHECK_IN_FROM_WAITING_ROOM_BASE()%>', requestJSON, null)
                            .then(responseData => {
                                let _parms = [];
                                _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_CLIENT_ID%>', valueClientID));
                                _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_REC_ID%>', responseData.rawData.recordID));
                             
                                <%if(isSubPage == true){%>
                                  _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_APP_MODE%>', '<%=Spedmon.Constants.AMD_UI_DBS_SUB_PAGE%>'));
                                <%}%>

                                <%if(contentOnly == false){%>
                                  _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_SOURCE%>', '<%=Spedmon.PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE%>'));  /* Patient profile */
                                <%} else {%>
                                _parms.push(MBA.RestViewCommon.fnCreateNameValueObject('<%=Spedmon.Constants.PARM_PRACTICE_OFFICE_VISIT_SOURCE%>', '<%=Spedmon.PracticeOfficeCommon.PRACTICE_OFFICE_VISIT_SOURCE_PATIENT_PROFILE_MANAGE_PATIENTS%>'));  /* Patient profile iframe */
                                <%}%>
                                 
                                let _url = MBA.RestViewCommon.fnBuildUrl('<%=Spedmon.PracticeOfficeCommon.URL_PATIENT_VISIT_MANAGE()%>', true, _parms);
                                MBA.ComponentCommon.fnGotoURL(_url);
                            })
                                .catch(err => {
                                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                                });
                            }
                        }
                    ]
                };

                MBA.ComponentCommon.fnCreateOneTimeDialog("<b>Create New Visit</b>", $newvisitform, objGoalChartDiaOpts);
            });

            /* Transportation */

            var optsTransportation = {};

            optsTransportation.RecsTransportationTextAreaSelector = '#recTransportationJSON';
            optsTransportation.RecsTransportationTableSelector = '#tblRecsTransportationJSON';
            optsTransportation.RecsTransportationTableBodySelector = '#tblRecsTransportationJSONBody';

            optsTransportation.patID = $('#patid').val();
            optsTransportation.clientID = $('#clientid').val();
            optsTransportation.tkn = '<%=((this.rd.loggedIn) ? this.rd.wu.usr.token : "")%>';

            SpEdCare.recPatTransportation.init(optsTransportation);

            // SpEd Team Members (identical rest views in both tabs)
            
            $dataManagementRowsSpEdTeamMembers = $('#dataManagementRowsForSpEdTeamMembers');
            $restViewCtrlSpEdTeamMembers = $('#spEdTeamMembersRestView');

            $($dataManagementRowsSpEdTeamMembers).on('spedmoninputdata', function (e) {
                updateAdditionalViewParameterValuesAndRequestViewFromServerSpEdTeamMembers(e);                
            });

            initViewSpEdTeamMembers();
            updateAdditionalViewParameterValuesAndRequestViewFromServerSpEdTeamMembers(null);
                                  
            // SpEd Service

            $dataManagementRowsSpEd = $('#dataManagementRowsForSpEd');
            $restViewCtrlSpEd = $('#restviewpatientpromisedservices');
            $restViewCtrlSpEdIepServices = $('#restViewSpEdIepServices');

            initViewSpEd();
            initDataGridSpEd();

            $($dataManagementRowsSpEd).on('spedmoninputdata', function (e) {
                updateAdditionalViewParameterValuesAndRequestViewFromServerSpEd(e);
            });

            updateAdditionalViewParameterValuesAndRequestViewFromServerSpEd(null);

            // SpEd HyQueue IEP
            let optsHyQueue = {};

            optsHyQueue.PARM_NAME_CLIENT_ID  = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
            optsHyQueue.PARM_NAME_PATIENT_ID = '<%=Spedmon.Constants.PARM_PATIENT_ID%>';
            optsHyQueue.PARM_NAME_ACTIVE     = '<%=Spedmon.Constants.PARM_ACTIVE%>';
            optsHyQueue.containerCtrlID      = 'dataManagementRowsForSpEdTeamMembersHyQueue';
            optsHyQueue.sessionTimeOutUrl    = '<%=MBA.Credential.generateSessionExpiredLink()%>';
            optsHyQueue.baseUrlView          = '<%=Spedmon.TeleIEPSessions.URL_REST_VIEW_IEP()%>'
            optsHyQueue.defaultPageRowOrder  = 'meetingDate desc';
            optsHyQueue.baseUrlAddNew        = '';
            optsHyQueue.baseUrlEdit          = '';
            optsHyQueue.baseUrlDelete        = '';
            optsHyQueue.baseUrlJoinSession   = '';
            optsHyQueue.activeFlag           = ''; // previous and upcoming meetings
            optsHyQueue.enableRowControls    = false;

            MBA.TeleIEPSessionsCommon.fnSetup('spEdTeamMembersHyQueueRestView', optsHyQueue);

            /* SpEd */

            $('#butmanagefiles').on('click', manageTeleIEPFileLibrary);
            $('#createiepmeetingicon').on('click', fnCreateIEPMeeting);

        }       
    });

</script>
