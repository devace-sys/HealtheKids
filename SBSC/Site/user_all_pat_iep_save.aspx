<%@ Page Language="C#" CodeBehind="user_all_pat_iep_save.aspx.cs" Inherits="Spedmon.UserAllPatientIEPSave" %>

<%//#####################################################################################################%>
<%//                                           Markup                                                    %>
<%//#####################################################################################################%>

<%//#############################################################################%>
<%//                              Main Container                                 %>
<%//#############################################################################%>

<div class="container-fluid">

<div class="row">

<%//#############################################################################%>
<%//                                 Col Left                                    %>
<%//#############################################################################%>

<div id="r1-cl">

<%//#############################################################################%>
<%//                             Profile                                         %>
<%//#############################################################################%>

<section id="profile"></section>

</div> <!-- col -->

<%//#############################################################################%>
<%//                            Col Right (IEP Fields)                           %>
<%//#############################################################################%>

<div id="r1-cr">

<Spedmon:DataEntryRows ID="save" useBootstrapFluid="true" runat="server" dataURL="patients.asmx/saveiep">

<%//#############################################################################%>
<%//                        Disability Codes and Save                            %>
<%//#############################################################################%>

<div class="row">

<div class="col-9">
  <Spedmon:HiddenInput ID="patid" name="patid" title="Patient ID" runat="server" />
  <Spedmon:HiddenInput ID="clientid" name="clientid" title="Client ID" runat="server" />
  <Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server" />
  <Spedmon:HiddenInput ID="groupid" name="groupid" title="groupid" runat="server" />
  <Spedmon:HiddenInput ID="groupserviceclassnameid" name="groupserviceclassnameid" title="groupserviceclassnameid" runat="server"/>
  <Spedmon:HiddenInput ID="active" name="active" title="active" value="1" noClear="true" runat="server" />
  <Spedmon:HiddenInput ID="siteid" name="siteid" title="siteid" runat="server" />
  <Spedmon:HiddenInput ID="practitionerpatientcaseloadexpectedserviceid" name="practitionerpatientcaseloadexpectedserviceid" title="practitionerpatientcaseloadexpectedserviceid" runat="server" />
  <Spedmon:HiddenInput ID="sendmeetinginvitesflag" name="sendmeetinginvitesflag" title="sendmeetinginvitesflag" noClear="true" runat="server" />
  <Spedmon:HiddenInput ID="resendparticipantemail" name="resendparticipantemail" title="resendparticipantemail" noClear="true" runat="server" />
  <Spedmon:HiddenInput ID="resendparticipantname" name="resendparticipantname" title="resendparticipantname" noClear="true" runat="server" />
  <Spedmon:HiddenInput ID="resendparticipantrole" name="resendparticipantrole" title="resendparticipantrole" noClear="true" runat="server" />
  <Spedmon:HiddenInput ID="meetingstatusoverrides" name="meetingstatusoverrides" title="meetingstatusoverrides" noClear="true" runat="server" />

  <Spedmon:DataEntryRowSelectSpEdDisabilityCode
                            ID                   = "SelectDisability1Code"
                            entityControlID      = "speddisability1code"
                            rowLabel             = "Disability 1 Code"
                            dataEntryRowRenderAs = "FIELD"
                            onSpedmonInputData   = "updateOtherTabsDisability1(e.dataitem)"
                            runat                = "server">
  </Spedmon:DataEntryRowSelectSpEdDisabilityCode>
  
  <Spedmon:DataEntryRowSelectSpEdDisabilityCode
                            ID                   = "SelectDisability2Code"
                            entityControlID      = "speddisability2code"
                            rowLabel             = "Disability 2 Code"
                            dataEntryRowRenderAs = "FIELD"
                            onSpedmonInputData   = "updateOtherTabsDisability2(e.dataitem)"
                            runat                = "server">
  </Spedmon:DataEntryRowSelectSpEdDisabilityCode>

  <Spedmon:DataEntryRowSelectSpEdLanguage
                            ID                   = "dataEntryRowSelectPreferredLanguage" 
                            entityControlID      = "spedpreferredlanguagecodeid"             
                            rowLabel             = "Preferred Language"
                            dataEntryRowRenderAs = "FIELD"
                            runat                = "server">
  </Spedmon:DataEntryRowSelectSpEdLanguage>
  
  
</div> <!-- col -->

<div class="col-3">
    <div class="d-flex align-items-end justify-content-end">
   <Spedmon:DataEntryRowSaveOrEdit
     ID                           = "saveOrEdit"
     dataEntryRowRenderAs         = "FIELD"
     includeSaveAndProceedButton  = "false"
     attestStatement              = ""
     useDefaultAdditionalRowClass = "false"
     useBootstrapGrid             = "false"
     includeCancelButton          = "false"
     editDelManageLink            = ""
     includeSecondarySaveButton   = "true"     
     secondarySaveButtonLabel     = "Save IEP Information"
     secondarySaveButtonOnClick   = "saveIEPData()"
     runat                        = "server">
  </Spedmon:DataEntryRowSaveOrEdit>
</div> <!-- layout -->
</div> <!-- col -->
</div> <!-- row -->

<%//#############################################################################%>
<%//                             Various Dates                                   %>
<%//#############################################################################%>

<div class="row">

<div class="col-12">
    <Spedmon:DataEntryBoxDate ID="spedenteredspeddate"    name="spedenteredspeddate"    size="7" required="false" label="Entered SpEd On"  title="Enter date that this patient initially entered Special Ed" runat="server" />
    <Spedmon:DataEntryBoxDate ID="spedexitedspeddate"     name="spedexitedspeddate"     size="7" required="false" label="Exited SpEd On"   title="Enter date that this patient exited Special Ed"            runat="server" />
    <Spedmon:DataEntryBoxDate ID="spedlastevaldate"       name="spedlastevaldate"       size="7"                  label="Last Evaluation"  title="Date of Last Evaluation"                                  runat="server"/>
    <Spedmon:DataEntryBoxDate ID="spednextevaldate"       name="spednextevaldate"       size="7"                  label="Next Evaluation"  title="Date of Next Evaluation"                                  runat="server"/>
    <Spedmon:DataEntryBoxDate ID="spedlastannualiepdate"  name="spedlastannualiepdate"  size="7"                  label="Last Annual IEP"  title="Date of Last Annual IEP"                                  runat="server"/>
    <Spedmon:DataEntryBoxDate ID="spedcuriepdate"         name="spedcuriepdate"         size="7"                  label="Current IEP"      title="Current IEP Date"                                         runat="server"/>
    <Spedmon:DataEntryBoxDate ID="spednextannualiepdate"  name="spednextannualiepdate"  size="7"                  label="Next Annual IEP"  title="Date of Next Annual IEP"                                  runat="server"/>
</div> <!-- col -->

</div> <!-- row -->

<%//#############################################################################%>
<%//                               IEP Tabs                                      %>
<%//#############################################################################%>

<div class="row">
<div class="col-12">
<div id="patspedtabs" class="patient-tabs-container">
<ul>         
  <li><a href="#tab-sped-iep-overview">Overview</a></li>
  <li><a href="#tab-sped-iep-meeting-purpose">Meeting Purpose</a></li>
  <li><a href="#tab-sped-iep-team-members">Meetings & Participants</a></li>
  <li><a href="#tab-sped-iep-present-levels">Present Levels</a></li>
  <li><a href="#tab-sped-iep-special-considerations-and-behavior">Special Considerations & Behavior</a></li>
  <li><a href="#tab-sped-iep-transition">Transition</a></li>
  <li><a href="#tab-sped-iep-accommodations">Accommodations</a></li>
  <li><a href="#tab-sped-iep-goals">Goals</a></li>
  <li><a href="#tab-sped-iep-related-services">Related Services</a></li>
  <li><a href="#tab-sped-iep-provisions">Provisions</a></li>
  <li><a href="#tab-sped-iep-lre-placement">LRE Placement</a></li>
  <li><a href="#tab-sped-iep-summary-of-performance">Summary of Performance</a></li>
  <li><a href="#tab-sped-iep-create-iep">Create IEP</a></li>
  <li><a href="#tab-sped-iep-student-history">Student History</a></li>
</ul>

<%//=============================================================================%>
<%//                              Overview Tab                                   %>
<%//=============================================================================%>

<div id="tab-sped-iep-overview">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="row">
                    <div class="col-12 col-md-6 col-xl-3 align-items-center mt-3">
                      <!-- <Spedmon:DataEntryBoxText ID="spedcasemanagername" name="spedcasemanagername" label="SpEd Case Manager" title="Enter name of current case manager" runat="server" /> -->
                        <div>
                            <h6>SpEd Case Manager</h6>
                        </div>
                        <div>
                            <Spedmon:DataEntryRowSelectUser
                                ID                  = "selectspedcasemanager"
                                entityControlID     = "spedcasemanageruserid"
                                onEditClose         = "updateCaseMangerNameInput();"
                                selectCtrlOnSelect  = "updateCaseMangerNameInput();"
                                dataEntryRowRenderAs = "FIELD"
                                runat               = "server">
                            </Spedmon:DataEntryRowSelectUser>
                        </div>
                    </div>

                    <div class="col-12 col-md-6 col-xl-3 align-items-center mt-3">
                        <div>
                            <h6>Race</h6>
                        </div>
                        <div>
                                <Spedmon:ComboBox 
                                    ID          = "spedstudentracecode" 
                                    name        = "spedstudentracecode" 	
                                    title       = "Race" 
                                    dataPrivate = "true" 
                                    dataURL     = "sped_races.asmx/viewSel"
                                    runat       = "server" />    
                        </div>
                    </div>

                    
                        <div class="col-12 col-md-6 col-xl-3">
                            <Spedmon:SelectYesOrNo ID="spedspecialtransportation" name="spedspecialtransportation" title="Special Transportation" renderLabel="true" runat="server" />
                        </div>

                        <div class="col-12 col-md-6 col-xl-3">
                            <div class="pt-3 mt-2">
                               <Spedmon:CheckBox ID="speciallyAdaptedVehicleForTransportation" name="speciallyadaptedvehiclefortransportation" firedataselected="false" title="speciallyAdaptedVehicleForTransportation" defaultValue="false" useDefaultValue="true" runat="server" />                            <span> Student receives medically necessary transportation on a specially adapted vehicle</span>
                            </div>
                        </div>

                        <div class="col-12 col-md-6 col-xl-3 d-flex align-items-center">
                            <Spedmon:DataEntryBoxDate ID="spedproceduralsafeguardssentdate" name="spedproceduralsafeguardssentdate" label="Procedural Safeguards sent on (Date)" title="Date Procedural Safeguards were sent" size="7" runat="server"/>
                        </div>

                        <div class="col-12 col-md-6 col-xl-3">
                            <Spedmon:DataEntryRow rowLabel="Type of vehicle adaptation" useBootstrapGrid="false" runat="server">
                                <Spedmon:ComboBox 
                                    ID          = "spedvehicleadaptationtype" 
                                    name        = "spedvehicleadaptationtype"
                                    title       = "Select type of vehicle adaptation"
                                    dataPrivate = "true"
                                    dataURL     = "sped_vehicle_adaptations.asmx/viewSel"
                                    runat       = "server" />
                            </Spedmon:DataEntryRow>
                        </div> 

                        <div class="col-12 col-md-6 col-xl-6">
                            <Spedmon:DataEntryRow rowLabel="Specialized Transportation Comments" useBootstrapGrid="false" runat="server">
                                <Spedmon:DataEntryBoxTextArea 
                                    ID    = "spedspecialtransportationcomments" 
                                    name  = "spedspecialtransportationcomments" 
                                    title = "Enter specialized transportation comments" 
                                    size  = "30" 
                                    runat = "server"/>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="col-12 col-md-6 col-xl-3">
                            <Spedmon:DataEntryRowSelectSpEdLanguage
                                ID               = "dataEntryRowSelectStudentLanguageCode" 
                                entityControlID  = "spedstudentlanguagecodeid"             
                                rowLabel         = "Language"
                                useBootstrapGrid = "false"
                                runat            = "server">
                            </Spedmon:DataEntryRowSelectSpEdLanguage>
                        </div>

                        <div class="col-12 col-xl-4">
                            <Spedmon:DataEntryRow rowLabel="I confirm that I have identified the IEP Team attendees in the IEP" useBootstrapGrid="false" runat="server">
                                <Spedmon:SelectYesOrNo ID="spediepattendeesidentified" name="spediepattendeesidentified" title="Select an option" renderLabel="false" runat="server" />
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="col-12 mt-4 mb-5">
                            <h6 class="font-weight-bold">Disabilities</h6>
                            <div>Primary:&nbsp;<span id="spedDisability1Display"><%=spedDisability1Text%></span></div>
                            <div>Secondary:&nbsp;<span id="spedDisability2Display"><%=spedDisability2Text%></span></div>
                        </div>

                        <div class="col-12">
                            <Spedmon:DataEntryRowSelectSpEdLanguage
                                ID               = "selectSpEdLangaugeToTranslatePlanTo"
                                entityControlID  = "spedplantranslatetolanguagecodeid"
                                rowLabel         = "Select a language if you would like this document translated"
                                useBootstrapGrid = "false"
                                runat            = "server">
                            </Spedmon:DataEntryRowSelectSpEdLanguage>
                        </div>

                        <div id="dataManagementRowsForSpEdIepServices" class="col-12">
                            <div class="row mt-3">
                                <div class="col-12">
                                    <Spedmon:HiddenTextArea ID="spedservicesdatajson" name="spedservicesdatajson" title="spedservicesdatajson" runat="server"/>
                                    <div id="restViewSpEdIepServices"></div>
                                </div>
                            </div>
                        </div>
                    

                    <div class="col-12 col-md-6 col-xl-6">
                        <fieldset class="mba-data-entry-box">
                            <legend class="text-center py-2"><h5>Language Information</h5></legend>
                            <div class="d-flex flex-wrap justify-content-center align-items-center">
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
                </div> 

                <div class="row">
                    <div class="col-12 col-md-6 col-xl-8">
                        <div class="row align-items-center">
                            <div class="col-10" style="padding-right:0;">
                                <h6>The IEP Team has determined that the student's disability adversely affects the student's educational performance</h6>
                            </div>
                            <div class="col-2" style="padding-left:0;">
                                <Spedmon:SelectYesOrNo ID="spedstudentdisabilityaffectsperformance" name="spedstudentdisabilityaffectsperformance" title="Select an option" renderLabel="false" runat="server" />
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-md-6 col-xl-2">
                        <Spedmon:DataEntryBoxDate ID="spedcureligibilitydate" name="spedcureligibilitydate" label="Current Eligibility Date" title="Current Eligibility Date" size="10" runat="server"/>
                    </div>

                    <div class="col-12 col-xl-2">
                        <Spedmon:DataEntryBoxDate ID="spediniteligibilitydate" name="spediniteligibilitydate" label="Initial Eligibility Date" title="Initial Eligibility Date" size="10" runat="server"/>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12 col-xl-12">
                        <Spedmon:DataEntryRow ID="enterEligReasons" useBootstrapGrid="false" rowLabel="Describe the reasons for eligibility determination including the other options considered and reasons these options were rejected" runat="server">
                            <Spedmon:RichTextAreaBox 
                                ID           = "spedeligibilityreasons" 
                                name         = "spedeligibilityreasons" 
                                title        = "Enter reasons"
                                showControls = "false"                            
                                runat        = "server">
                            </Spedmon:RichTextAreaBox> 
                        </Spedmon:DataEntryRow>
                    </div>
                </div>

                <hr />

                
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                           Meeting Purpose Tab                              %>
<%//=============================================================================%>

<div id="tab-sped-iep-meeting-purpose">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
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

                <div class="row mt-3">
                    <div class="col-12 col-md-6 col-xl-4">
                        <Spedmon:DataEntryRow rowLabel="Please Select the Purpose of the Meeting" useBootstrapGrid="false" runat="server">
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
                                ID               = "DataEntryRowSelectSpEdPlanType" 
                                entityControlID  = "spedplantypecode"                
                                rowLabel         = "Plan Type"
                                useBootstrapGrid = "false"
                                runat            = "server">
                            </Spedmon:DataEntryRowSelectSpEdPlanType>
                        </div>
                    </div>

                    <Spedmon:HiddenTextArea ID="spedadditionalmeetingpurposedatajson" name="spedadditionalmeetingpurposedatajson" title="spedadditionalmeetingpurposedatajson" runat="server"/>

                    <div class="col-12 col-md-6 col-xl-4">
                        <Spedmon:DataEntryRow rowLabel="Additional Purpose of Meeting (If Needed)" useBootstrapGrid="false" runat="server">
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
                        <Spedmon:HiddenTextArea ID="spedamendmentreasonsdatajson" name="spedamendmentreasonsdatajson" title="spedamendmentreasonsdatajson" runat="server" />
                        <div id="spedAmendmentReasonsCont">
                            <Spedmon:DataEntryRow rowLabel="Reasons for Amendment" useBootstrapGrid="false" runat="server">
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

                <div class="row mt-3">
                
                    
                    <div class="col-12 col-md-6">
                        <Spedmon:DataEntryRow rowLabel="Reason for correction Details" useBootstrapGrid="false" runat="server">
                            <Spedmon:DataEntryBoxTextArea 
                                ID    = "spedcorrectiondetails" 
                                name  = "spedcorrectiondetails" 
                                title = "Enter correction details" 
                                size  = "30" 
                                runat = "server"/>
                        </Spedmon:DataEntryRow>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>


<%//=============================================================================%>
<%//                           Team Members Tab                                 %>
<%//=============================================================================%>
  <div id="tab-sped-iep-team-members">

    <div class="container-fluid">

        <div class="row">

            <div class="col-12">

                <div class="gridlines-layout-meeting-section">

                    <div class="gridlines-layout-meeting-left">

                        <div class="gridlines-layout-meeting-details">
                            <div class="gridlines-layout-meeting-details__header"><i class="fas fa-calendar-check mr-2"></i>Meeting Details</div>
                            <div class="gridlines-layout-meeting-details__body">

                                <div class="gridlines-layout-meeting-details__field">
                                    <Spedmon:DataEntryBoxDate ID="spedmeetingdate" name="spedmeetingdate" label="Proposed Meeting Date" title="IEP Meeting Date" size="17" runat="server"/>
                                </div>

                                <div class="gridlines-layout-meeting-details__field">
                                    <Spedmon:DataEntryBoxTime ID="spedmeetingtime" name="spedmeetingtime" label="Meeting Time" title="IEP Meeting Time" size="17" runat="server"/>
                                </div>

                                <div class="gridlines-layout-meeting-details__field">
                                    <Spedmon:DataEntryBoxNumber ID="spedmeetingdurationinmins" name="spedmeetingdurationinmins" label="Meeting Duration" title="IEP Meeting Duration (in minutes)" size="17" runat="server"/>
                                </div>

                            </div>
                        </div>

                        <div class="gridlines-layout-meeting-contact">
                            <div class="gridlines-layout-meeting-contact__header"><i class="fas fa-user-friends mr-2"></i>Meeting Contact</div>
                            <div class="gridlines-layout-meeting-contact__body">
                                <Spedmon:DataEntryRowSelectUser
                                    ID               = "selectFacilitator"
                                    entityControlID  = "spedfacilitatoruserid"
                                    rowLabel         = "Select an IEP Meeting Contact"
                                    useBootstrapGrid = "false"
                                    runat            = "server">
                                </Spedmon:DataEntryRowSelectUser>
                            </div>
                        </div>

                    </div>

                    <div class="gridlines-layout-meeting-info">
                        <div class="gridlines-layout-meeting-info__header"><i class="fas fa-info-circle mr-2"></i>Meeting Information</div>
                        <div class="gridlines-layout-meeting-info__body">

                            <div class="gridlines-layout-meeting-info__field gridlines-layout-meeting-info__field--full">
                                <Spedmon:DataEntryBoxText ID="spedmeetingtitle" name="spedmeetingtitle" label="Meeting Title" title="Title" size="17" runat="server"/>
                            </div>

                            <div class="gridlines-layout-meeting-info__field-row">
                                <div class="gridlines-layout-meeting-info__field">
                                    <Spedmon:DataEntryRowSelectStoredFile
                                        ID                     = "selectFiles"
                                        rowLabel               = "Files to Share During Meeting (Note: ONLY PDF files are supported at this time)"
                                        entityControlID        = "filestoshareuploadids"
                                        multiSelect            = "true"
                                        multiSelectListTitle   = "Files to Share During Meeting (PDF files only please)"
                                        useBootstrapGrid       = "false"
                                        runat                  = "server">

                                        <Spedmon:Button ID="butmanagefiles" title="Click here To Add New Files" runat="server">Manage Library</Spedmon:Button>

                                    </Spedmon:DataEntryRowSelectStoredFile>
                                </div>

                                <div class="gridlines-layout-meeting-info__field gridlines-layout-meeting-info__field--checkbox">
                                    <input type="checkbox" id="spedGridlinesLayout_include_parent_portal" />
                                    <label for="spedGridlinesLayout_include_parent_portal">Check to Include Files Parent Portal</label>
                                </div>
                            </div>

                        </div>
                    </div>

                </div>

                <div class="gridlines-layout-unified-toolbar">
                    <div class="gridlines-layout-unified-toolbar__left">
                        <button type="button" id="spedGridlinesLayout_add_row" class="gridlines-layout-btn gridlines-layout-btn--sm" title="Add a new participant row">
                            <i class="fas fa-plus mr-1"></i>Add Participant
                        </button>
                        <button type="button" id="spedGridlinesLayout_refresh" class="gridlines-layout-btn gridlines-layout-btn--sm" title="Refresh participant confirmations">
                            <i class="fas fa-sync-alt mr-1"></i>Refresh
                        </button>
                    </div>
                    <div class="gridlines-layout-unified-toolbar__center">
                        <i class="fas fa-users"></i>
                        <span>IEP Participants</span>
                        <span class="gridlines-layout-participants-header__count">(<span id="spedGridlinesLayout_participant_count">0</span>)</span>
                    </div>
                    <div class="gridlines-layout-unified-toolbar__right" id="spedGridlinesLayout_toolbar_right"></div>
                </div>

                <div id="dataManagementRowsForSpEdGridlinesLayout" class="row">
                    <div class="col-12">
                        <div id="restViewSpEdGridlinesLayout" class="mt-1"></div>
                    </div>
                </div>

                <div class="gridlines-layout-history">
                    <button type="button" id="spedGridlinesLayout_view_history" class="gridlines-layout-history__btn">
                        <i class="fas fa-history mr-2"></i><span>Shows a rest view of past meeting dates and details</span>
                    </button>
                </div>

                <div id="dataManagementRowsForSpEdTeamMembersHyQueue" class="container-fluid">
                    <div class="row mt-3">
                        <div class="col-12">
                            <div id="spEdMeetingHistoryRestView"></div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>
<%//=============================================================================%>
<%//                           Present Levels Tab                               %>
<%//=============================================================================%>

<div id="tab-sped-iep-present-levels">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">

                <%-- Hidden fields for data storage --%>
                <Spedmon:HiddenTextArea ID="spedpresentlevelsdatajson"     name="spedpresentlevelsdatajson"     title="spedpresentlevelsdatajson"     runat="server"/>
                <Spedmon:HiddenInput    ID="spedpresentlevelspreparedby"   name="spedpresentlevelspreparedby"   title="spedpresentlevelspreparedby"   runat="server"/>
                <Spedmon:HiddenInput    ID="spedpresentlevelspreparedbyname" name="spedpresentlevelspreparedbyname" title="spedpresentlevelspreparedbyname" runat="server"/>
                                <%-- Source Names --%>
                <Spedmon:HiddenInput ID="spedstudentstrengthssourcenames"         name="spedstudentstrengthssourcenames"         title="spedstudentstrengthssourcenames"         runat="server"/>
                <Spedmon:HiddenInput ID="spedparentconcernssourcenames"           name="spedparentconcernssourcenames"           title="spedparentconcernssourcenames"           runat="server"/>
                <Spedmon:HiddenInput ID="spedreadingsourcenames"                  name="spedreadingsourcenames"                  title="spedreadingsourcenames"                  runat="server"/>
                <Spedmon:HiddenInput ID="spedwritingsourcenames"                  name="spedwritingsourcenames"                  title="spedwritingsourcenames"                  runat="server"/>
                <Spedmon:HiddenInput ID="spedmathsourcenames"                     name="spedmathsourcenames"                     title="spedmathsourcenames"                     runat="server"/>
                <Spedmon:HiddenInput ID="spedcommunicationdevsourcenames"         name="spedcommunicationdevsourcenames"         title="spedcommunicationdevsourcenames"         runat="server"/>
                <Spedmon:HiddenInput ID="spedgrossfinemotorsourcenames"           name="spedgrossfinemotorsourcenames"           title="spedgrossfinemotorsourcenames"           runat="server"/>
                <Spedmon:HiddenInput ID="spedhealthsourcenames"                   name="spedhealthsourcenames"                   title="spedhealthsourcenames"                   runat="server"/>
                <Spedmon:HiddenInput ID="spedvocationalsourcenames"               name="spedvocationalsourcenames"               title="spedvocationalsourcenames"               runat="server"/>
                <Spedmon:HiddenInput ID="spedadaptivedailylivingsourcenames"      name="spedadaptivedailylivingsourcenames"      title="spedadaptivedailylivingsourcenames"      runat="server"/>
                <Spedmon:HiddenInput ID="spedsocialemotionalbehavioralsourcenames" name="spedsocialemotionalbehavioralsourcenames" title="spedsocialemotionalbehavioralsourcenames" runat="server"/>

                <%-- Baseline Unit Names --%>
                <Spedmon:HiddenInput ID="spedreadingbaselineunitnames"                  name="spedreadingbaselineunitnames"                  title="spedreadingbaselineunitnames"                  runat="server"/>
                <Spedmon:HiddenInput ID="spedwritingbaselineunitnames"                  name="spedwritingbaselineunitnames"                  title="spedwritingbaselineunitnames"                  runat="server"/>
                <Spedmon:HiddenInput ID="spedmathbaselineunitnames"                     name="spedmathbaselineunitnames"                     title="spedmathbaselineunitnames"                     runat="server"/>
                <Spedmon:HiddenInput ID="spedcommunicationdevbaselineunitnames"         name="spedcommunicationdevbaselineunitnames"         title="spedcommunicationdevbaselineunitnames"         runat="server"/>
                <Spedmon:HiddenInput ID="spedgrossfinemotorbaselineunitnames"           name="spedgrossfinemotorbaselineunitnames"           title="spedgrossfinemotorbaselineunitnames"           runat="server"/>
                <Spedmon:HiddenInput ID="spedhealthbaselineunitnames"                   name="spedhealthbaselineunitnames"                   title="spedhealthbaselineunitnames"                   runat="server"/>
                <Spedmon:HiddenInput ID="spedvocationalbaselineunitnames"               name="spedvocationalbaselineunitnames"               title="spedvocationalbaselineunitnames"               runat="server"/>
                <Spedmon:HiddenInput ID="spedadaptivedailylivingbaselineunitnames"      name="spedadaptivedailylivingbaselineunitnames"      title="spedadaptivedailylivingbaselineunitnames"      runat="server"/>
                <Spedmon:HiddenInput ID="spedsocialemotionalbehavioralbaselineunitnames" name="spedsocialemotionalbehavioralbaselineunitnames" title="spedsocialemotionalbehavioralbaselineunitnames" runat="server"/>

                    <%-- Tools Used Names --%>
                <Spedmon:HiddenInput    ID="spedreadingtoolsusednames"                       name="spedreadingtoolsusednames"                       title="spedreadingtoolsusednames"                       runat="server"/>
                <Spedmon:HiddenInput    ID="spedwritingtoolsusednames"                       name="spedwritingtoolsusednames"                       title="spedwritingtoolsusednames"                       runat="server"/>
                <Spedmon:HiddenInput    ID="spedmathtoolsusednames"                          name="spedmathtoolsusednames"                          title="spedmathtoolsusednames"                          runat="server"/>
                <Spedmon:HiddenInput    ID="spedcommunicationdevtoolsusednames"              name="spedcommunicationdevtoolsusednames"              title="spedcommunicationdevtoolsusednames"              runat="server"/>
                <Spedmon:HiddenInput    ID="spedgrossfinemotortoolsusednames"                name="spedgrossfinemotortoolsusednames"                title="spedgrossfinemotortoolsusednames"                runat="server"/>
                <Spedmon:HiddenInput    ID="spedhealthtoolsusednames"                        name="spedhealthtoolsusednames"                        title="spedhealthtoolsusednames"                        runat="server"/>
                <Spedmon:HiddenInput    ID="spedvocationaltoolsusednames"                    name="spedvocationaltoolsusednames"                    title="spedvocationaltoolsusednames"                    runat="server"/>
                <Spedmon:HiddenInput    ID="spedadaptivedailylivingtoolsusednames"           name="spedadaptivedailylivingtoolsusednames"           title="spedadaptivedailylivingtoolsusednames"           runat="server"/>
                <Spedmon:HiddenInput    ID="spedsocialemotionalbehavioraltoolsusednames"     name="spedsocialemotionalbehavioraltoolsusednames"     title="spedsocialemotionalbehavioraltoolsusednames"     runat="server"/>
                <Spedmon:HiddenTextArea ID="spedreadingtoolsusedjson"                        name="spedreadingtoolsusedjson"                        title="spedreadingtoolsusedjson"                        runat="server"/>
                <Spedmon:HiddenTextArea ID="spedwritingtoolsusedjson"                        name="spedwritingtoolsusedjson"                        title="spedwritingtoolsusedjson"                        runat="server"/>
                <Spedmon:HiddenTextArea ID="spedmathtoolsusedjson"                           name="spedmathtoolsusedjson"                           title="spedmathtoolsusedjson"                           runat="server"/>
                <Spedmon:HiddenTextArea ID="spedcommunicationdevtoolsusedjson"               name="spedcommunicationdevtoolsusedjson"               title="spedcommunicationdevtoolsusedjson"               runat="server"/>
                <Spedmon:HiddenTextArea ID="spedgrossfinemotortoolsusedjson"                 name="spedgrossfinemotortoolsusedjson"                 title="spedgrossfinemotortoolsusedjson"                 runat="server"/>
                <Spedmon:HiddenTextArea ID="spedhealthtoolsusedjson"                         name="spedhealthtoolsusedjson"                         title="spedhealthtoolsusedjson"                         runat="server"/>
                <Spedmon:HiddenTextArea ID="spedvocationaltoolsusedjson"                     name="spedvocationaltoolsusedjson"                     title="spedvocationaltoolsusedjson"                     runat="server"/>
                <Spedmon:HiddenTextArea ID="spedadaptivedailylivingtoolsusedjson"            name="spedadaptivedailylivingtoolsusedjson"            title="spedadaptivedailylivingtoolsusedjson"            runat="server"/>
                <Spedmon:HiddenTextArea ID="spedsocialemotionalbehavioraltoolsusedjson"      name="spedsocialemotionalbehavioraltoolsusedjson"      title="spedsocialemotionalbehavioraltoolsusedjson"      runat="server"/>

                <Spedmon:HiddenInput    ID="spedfacilitatorusername"    name="spedfacilitatorusername"    title="spedfacilitatorusername"    runat="server"/>
                <Spedmon:HiddenInput    ID="spedcasemanagerusername"    name="spedcasemanagerusername"    title="spedcasemanagerusername"    runat="server"/>
                <Spedmon:HiddenTextArea ID="spedparticipantdetailsjson" name="spedparticipantdetailsjson" title="spedparticipantdetailsjson" runat="server" />
                <Spedmon:HiddenTextArea ID="spedgridlineslayoutjson"    name="spedgridlineslayoutjson"    title="spedgridlineslayoutjson"    runat="server" />



                <%//=============================================================================%>
                <%//                     Expand/Collapse Controls                               %>
                <%//=============================================================================%>

                <div class="iep-present-tab-accordion-controls">
                    <button type="button" class="iep-present-tab-accordion-controls__btn" onclick="fnExpandAllIEPPresentTabAccordions(); return false;">
                        <i class="fas fa-expand-alt"></i> Expand All
                    </button>
                    <button type="button" class="iep-present-tab-accordion-controls__btn" onclick="fnCollapseAllIEPPresentTabAccordions(); return false;">
                        <i class="fas fa-compress-alt"></i> Collapse All
                    </button>
                </div>

                <h4>Source of Information (Roll-up)</h4>

                <%//=============================================================================%>
                <%//                         Student Strengths Section                          %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="studentstrengths">
                    <legend>Student Strengths</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--yellow">
                            <i class="fas fa-star"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Student Strengths</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedstudentstrengthssourcejson" name="spedstudentstrengthssourcejson" title="spedstudentstrengthssourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--grow">
                                <Spedmon:DataEntryRow rowLabel="Source" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedstudentstrengthssource" 
                                        name              = "spedstudentstrengthssource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSel"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedstudentstrengths"
                                    name         = "spedstudentstrengths"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on General Education (Summary)" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedstudentstrengthsimpact"
                                    name         = "spedstudentstrengthsimpact"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('studentstrengths'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('studentstrengths'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                         Parent Concerns Section                            %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="parentconcerns">
                    <legend>Parent Concerns</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--purple">
                            <i class="fas fa-users"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Describe parent concerns</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedparentconcernssourcejson" name="spedparentconcernssourcejson" title="spedparentconcernssourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--grow">
                                <Spedmon:DataEntryRow rowLabel="Source" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedparentconcernssource" 
                                        name              = "spedparentconcernssource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSel"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedparentconcerns"
                                    name         = "spedparentconcerns"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('parentconcerns'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('parentconcerns'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                                 Reading                                %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="reading">
                    <legend>Reading</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--blue">
                            <i class="fas fa-book-open"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Reading</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedreadingsourcejson" name="spedreadingsourcejson" title="spedreadingsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedreadingreviewedna" name="spedreadingreviewedna" firedataselected="false" title="Reviewed Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedreadingsource" 
                                        name              = "spedreadingsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelReading"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedreadingbaselinevalue" name="spedreadingbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedreadingbaselinedate" name="spedreadingbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedreadingbaselineunit" 
                                        name              = "spedreadingbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelReading"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedreadingtoolsused" 
                                        name              = "spedreadingtoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelReading"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillsreading"
                                    name         = "speddevacafunskillsreading"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedreadingimpactsummary"
                                    name         = "spedreadingimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('reading'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('reading'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                                 Writing                                %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="writing">
                    <legend>Writing</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--green">
                            <i class="fas fa-pencil-alt"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Writing</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedwritingsourcejson" name="spedwritingsourcejson" title="spedwritingsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedwritingreviewedna" name="spedwritingreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedwritingsource" 
                                        name              = "spedwritingsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelWriting"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedwritingbaselinevalue" name="spedwritingbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedwritingbaselinedate" name="spedwritingbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedwritingbaselineunit" 
                                        name              = "spedwritingbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelWriting"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedwritingtoolsused" 
                                        name              = "spedwritingtoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelWriting"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillswriting"
                                    name         = "speddevacafunskillswriting"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedwritingimpactsummary"
                                    name         = "spedwritingimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('writing'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('writing'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                                   Math                                 %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="math">
                    <legend>Math</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--orange">
                            <i class="fas fa-calculator"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Math</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedmathsourcejson" name="spedmathsourcejson" title="spedmathsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedmathreviewedna" name="spedmathreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedmathsource" 
                                        name              = "spedmathsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelMath"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedmathbaselinevalue" name="spedmathbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedmathbaselinedate" name="spedmathbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedmathbaselineunit" 
                                        name              = "spedmathbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelMath"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedmathtoolsused" 
                                        name              = "spedmathtoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelMath"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillsmath"
                                    name         = "speddevacafunskillsmath"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedmathimpactsummary"
                                    name         = "spedmathimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('math'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('math'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                        Communication Development                       %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="communicationdev">
                    <legend>Communication Development</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--teal">
                            <i class="fas fa-comments"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Communication Development</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedcommunicationdevsourcejson" name="spedcommunicationdevsourcejson" title="spedcommunicationdevsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedcommunicationdevreviewedna" name="spedcommunicationdevreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedcommunicationdevsource" 
                                        name              = "spedcommunicationdevsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelCommunicationDev"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedcommunicationdevbaselinevalue" name="spedcommunicationdevbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedcommunicationdevbaselinedate" name="spedcommunicationdevbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedcommunicationdevbaselineunit" 
                                        name              = "spedcommunicationdevbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelCommunicationDev"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedcommunicationdevtoolsused" 
                                        name              = "spedcommunicationdevtoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelCommunicationDev"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillscommunicationdev"
                                    name         = "speddevacafunskillscommunicationdev"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedcommunicationdevimpactsummary"
                                    name         = "spedcommunicationdevimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('communicationdev'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('communicationdev'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                   Gross/Fine Motor Skills Development                  %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="grossfinemotor">
                    <legend>Gross/Fine Motor Skills Development</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--pink">
                            <i class="fas fa-running"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Gross/Fine Motor Skills Development</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedgrossfinemotorsourcejson" name="spedgrossfinemotorsourcejson" title="spedgrossfinemotorsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedgrossfinemotorreviewedna" name="spedgrossfinemotorreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedgrossfinemotorsource" 
                                        name              = "spedgrossfinemotorsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelGrossFineMotor"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedgrossfinemotorbaselinevalue" name="spedgrossfinemotorbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedgrossfinemotorbaselinedate" name="spedgrossfinemotorbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedgrossfinemotorbaselineunit" 
                                        name              = "spedgrossfinemotorbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelGrossFineMotor"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedgrossfinemotortoolsused" 
                                        name              = "spedgrossfinemotortoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelGrossFineMotor"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillsgrossfinemotordev"
                                    name         = "speddevacafunskillsgrossfinemotordev"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedgrossfinemotorimpactsummary"
                                    name         = "spedgrossfinemotorimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('grossfinemotor'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('grossfinemotor'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                                  Health                                %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="health">
                    <legend>Health</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--red">
                            <i class="fas fa-heartbeat"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Health</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedhealthsourcejson" name="spedhealthsourcejson" title="spedhealthsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedhealthreviewedna" name="spedhealthreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedhealthsource" 
                                        name              = "spedhealthsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelHealth"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedhealthbaselinevalue" name="spedhealthbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedhealthbaselinedate" name="spedhealthbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedhealthbaselineunit" 
                                        name              = "spedhealthbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelHealth"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedhealthtoolsused" 
                                        name              = "spedhealthtoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelHealth"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillshealth"
                                    name         = "speddevacafunskillshealth"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedhealthimpactsummary"
                                    name         = "spedhealthimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('health'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('health'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                                Vocational                              %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="vocational">
                    <legend>Vocational</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--indigo">
                            <i class="fas fa-briefcase"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Vocational</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedvocationalsourcejson" name="spedvocationalsourcejson" title="spedvocationalsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedvocationalreviewedna" name="spedvocationalreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedvocationalsource" 
                                        name              = "spedvocationalsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelVocational"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedvocationalbaselinevalue" name="spedvocationalbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedvocationalbaselinedate" name="spedvocationalbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedvocationalbaselineunit" 
                                        name              = "spedvocationalbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelVocational"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedvocationaltoolsused" 
                                        name              = "spedvocationaltoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelVocational"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillsvocational"
                                    name         = "speddevacafunskillsvocational"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedvocationalimpactsummary"
                                    name         = "spedvocationalimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('vocational'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('vocational'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                       Adaptive/Daily Living Skills                     %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="adaptivedailyliving">
                    <legend>Adaptive/Daily Living Skills</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--gray">
                            <i class="fas fa-home"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Adaptive/Daily Living Skills</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedadaptivedailylivingsourcejson" name="spedadaptivedailylivingsourcejson" title="spedadaptivedailylivingsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedadaptivedailylivingreviewedna" name="spedadaptivedailylivingreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedadaptivedailylivingsource" 
                                        name              = "spedadaptivedailylivingsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelAdaptiveDailyLiving"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedadaptivedailylivingbaselinevalue" name="spedadaptivedailylivingbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedadaptivedailylivingbaselinedate" name="spedadaptivedailylivingbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedadaptivedailylivingbaselineunit" 
                                        name              = "spedadaptivedailylivingbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelAdaptiveDailyLiving"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedadaptivedailylivingtoolsused" 
                                        name              = "spedadaptivedailylivingtoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelAdaptiveDailyLiving"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillsadaptivedailyliving"
                                    name         = "speddevacafunskillsadaptivedailyliving"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedadaptivedailylivingimpactsummary"
                                    name         = "spedadaptivedailylivingimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('adaptivedailyliving'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('adaptivedailyliving'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                       Social/Emotional/Behavioral                      %>
                <%//=============================================================================%>

                <fieldset class="iep-present-tab-accordion iep-present-tab-accordion--collapsed present-levels-section" data-section="socialemotionalbehavioral">
                    <legend>Social/Emotional/Behavioral</legend>

                    <div class="iep-present-tab-accordion__header" tabindex="0" role="button" aria-expanded="false" onclick="fnToggleIEPAccordion(this);">
                        <div class="iep-present-tab-accordion__icon iep-present-tab-accordion__icon--cyan">
                            <i class="fas fa-heart"></i>
                        </div>
                        <h3 class="iep-present-tab-accordion__title">Social/Emotional/Behavioral</h3>
                        <span class="iep-present-tab-accordion__status iep-present-tab-accordion__status--empty"></span>
                        <div class="iep-present-tab-accordion__chevron">
                            <i class="fas fa-chevron-down"></i>
                        </div>
                    </div>

                    <div class="iep-present-tab-accordion__content">
                        <Spedmon:HiddenTextArea ID="spedsocialemotionalbehavioralsourcejson" name="spedsocialemotionalbehavioralsourcejson" title="spedsocialemotionalbehavioralsourcejson" runat="server"/>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--na">
                                <Spedmon:CheckBox ID="spedsocialemotionalbehavioralreviewedna" name="spedsocialemotionalbehavioralreviewedna" firedataselected="false" title="Reviewed , Not Applicable" defaultValue="false" useDefaultValue="true" runat="server" />
                                <label>Reviewed,<br />Not Applicable</label>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--source">
                                <Spedmon:DataEntryRow rowLabel="Source of Information" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedsocialemotionalbehavioralsource" 
                                        name              = "spedsocialemotionalbehavioralsource"
                                        title             = "Select source"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_present_levels_sources.asmx/viewSelSocialEmotionalBehavioral"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--value">
                                <label>Baseline Value</label>
                                <Spedmon:DataEntryBoxText ID="spedsocialemotionalbehavioralbaselinevalue" name="spedsocialemotionalbehavioralbaselinevalue" title="Enter baseline value" runat="server" />
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--date">
                                <label>Baseline Date</label>
                                <Spedmon:DataEntryBoxDate ID="spedsocialemotionalbehavioralbaselinedate" name="spedsocialemotionalbehavioralbaselinedate" title="Baseline Date" size="10" runat="server"/>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__row">
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--unit">
                                <Spedmon:DataEntryRow rowLabel="Baseline Unit" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedsocialemotionalbehavioralbaselineunit" 
                                        name              = "spedsocialemotionalbehavioralbaselineunit"
                                        title             = "Select unit"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_baseline_units.asmx/viewSelSocialEmotionalBehavioral"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                            <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--tools">
                                <Spedmon:DataEntryRow rowLabel="Tools Used" useBootstrapGrid="false" runat="server">
                                    <Spedmon:ComboBoxMultiSelect 
                                        id                = "spedsocialemotionalbehavioraltoolsused" 
                                        name              = "spedsocialemotionalbehavioraltoolsused"
                                        title             = "Select tools used"
                                        dataPrivate       = "true"
                                        dataURL           = "sped_assessment_tools.asmx/viewSelSocialEmotionalBehavioral"
                                        multiSelect       = "true"
                                        multiSelectShowOK = "false"
                                        runat             = "server" />
                                </Spedmon:DataEntryRow>
                            </div>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Performance Summary" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "speddevacafunskillssocialemotionalbehavioral"
                                    name         = "speddevacafunskillssocialemotionalbehavioral"
                                    title        = "Enter content"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__field iep-present-tab-accordion__field--full">
                            <Spedmon:DataEntryRow rowLabel="Impact on Educational Performance" useBootstrapGrid="false" runat="server">
                                <Spedmon:RichTextAreaBox
                                    id           = "spedsocialemotionalbehavioralimpactsummary"
                                    name         = "spedsocialemotionalbehavioralimpactsummary"
                                    title        = "Enter impact"
                                    showControls = "false"
                                    runat        = "server">
                                </Spedmon:RichTextAreaBox>
                            </Spedmon:DataEntryRow>
                        </div>

                        <div class="iep-present-tab-accordion__progress-link">
                            <span>View current progress: </span>
                            <i class="fas fa-chart-line ml-2" title="View Current Progress" onclick="opnPatGoalProgress();"></i>
                        </div>

                        <%-- Save and Finalize Buttons --%>
                        <div class="iep-present-tab-accordion__actions d-flex justify-content-end mt-3 pt-3 border-top">
                            <button type="button" class="btn btn-outline-secondary btn-sm mr-2" onclick="fnSavePresentLevelsSection('socialemotionalbehavioral'); return false;">
                                <i class="fas fa-save mr-1"></i> Save Draft
                            </button>
                            <button type="button" class="btn btn-success btn-sm" onclick="fnFinalizePresentLevelsSection('socialemotionalbehavioral'); return false;">
                                <i class="fas fa-check-circle mr-1"></i> Finalize Section
                            </button>
                        </div>
                    </div>
                </fieldset>

                <%//=============================================================================%>
                <%//                       Additional Fields                                    %>
                <%//=============================================================================%>

                <Spedmon:DataEntryRow rowLabel="Areas of Necessity Explained in terms of goals and objectives in order that the student receives educational benefits" useBootstrapGrid="false" runat="server">
                    <Spedmon:RichTextAreaBox
                        id           = "speddevacafunskillsareasofneccessity"
                        name         = "speddevacafunskillsareasofneccessity"
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox>
                </Spedmon:DataEntryRow>

                <Spedmon:DataEntryRow rowLabel="Enter Progress Monitoring Data" useBootstrapGrid="false" runat="server">
                    <Spedmon:RichTextAreaBox
                        id           = "spedprogressmonitoringdata"
                        name         = "spedprogressmonitoringdata"
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox>
                </Spedmon:DataEntryRow>

                <div class="mt-3">
                    <span>View progress monitoring data: </span>
                    <i class="fas fa-chart-line ml-2" title="View Current Progress for All Goals" onclick="opnPatGoalProgress();"></i>
                </div>

                <Spedmon:DataEntryRow rowLabel="Based on the evaluation data, provide a statement of the student's present levels of academic achievement and functional performance, including how the student's disability affects the student's involvement and progress in the general education curriculum or for children in early childhood, participation in appropriate activities." useBootstrapGrid="false" runat="server">
                    <Spedmon:RichTextAreaBox
                        id           = "spedstudentpresentlevelsstatement"
                        name         = "spedstudentpresentlevelsstatement"
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox>
                </Spedmon:DataEntryRow>

                <%//=============================================================================%>
                <%//                       Footer with Prepared By                              %>
                <%//=============================================================================%>

                <div class="mt-3 d-flex justify-content-end align-items-center">
                    <div class="prepared-by-box mr-3">
                        <span>Prepared by: </span>
                        <span id="preparedByNameDisplay"></span>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                  Special Considerations & Behavior Tab                     %>
<%//=============================================================================%>

<div id="tab-sped-iep-special-considerations-and-behavior">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                              Transition Tab                                %>
<%//=============================================================================%>

<div id="tab-sped-iep-transition">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                           Accommodations Tab                               %>
<%//=============================================================================%>

<div id="tab-sped-iep-accommodations">
    <div class="container-fluid">
        <div id="datamanagerowsrestviewpatientaccommodations" class="row mt-2">
            <div class="col-12">
                <div id="restviewpatientaccommodations"></div><!-- rest view -->
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                              Goals Tab                                      %>
<%//=============================================================================%>

<div id="tab-sped-iep-goals">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <div class="col-auto">
                    <Spedmon:DataEntryRow rowLabel="Transition Goal:" useBootstrapGrid="false" runat="server">
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

                <div id="dataManagementRowsForGoals" class="container-fluid mt-4">
                    <div class="row mt-3">
                        <div class="col-12">
                            <div class="mb-3 font-weight-bold">Any edits to an existing goal will update all previously recorded service records. If you do not want the goal updated for saved records, create a new goal. Deleting a goal will not affect saved service records.</div>
                            <div id="goalsRestView"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//             IEP Related Services (Promised Services) %>
<%//=============================================================================%>

<div id="tab-sped-iep-related-services">      
        <div class="container-fluid">
        <%if(saveTypeVal == Constants.SAVE_TYPE_EDIT) {%>
        <div class="row">
          <div class="col-12">
            <table class="table table-sm">
            <thead>           
            <tr>
              <th>Case Manager</th>
              <th>Disability 1</th>
              <th>Disability 2</th>
              <th>Last Eval Date</th>
              <th>Last IEP Date</th>
              <th>Next IEP Date</th>
              <th>Exited SpEd Date</th>
            </tr>
            </thead>
            <tbody>
              <tr>
                <td><%=p.spEdCaseManagerName%></td>
                <td><%=p.spEdDisability1CodeAndName%></td>
                <td><%=p.spEdDisability2CodeAndName%></td>
                <td><%=p.spEdLastEvalDateYMD%></td>
                <td><%=p.spEdLastAnnualIEPDateYMD%></td>
                <td><%=p.spEdNextAnnualIEPDateYMD%></td>
                <td><%=p.spEdExitedSpEdDateYMD%></td>
              </tr>
            </tbody>
             </table>
            </div> <!-- col-->  
        </div> <!-- row-->
        <%}%>
            
        <div id="datamanagerowsrestviewpatientpromisedservices" class="row mt-2">
        <div class="col-12">
        <div id="restviewpatientpromisedservices"></div><!-- rest view -->
        </div> <!-- col -->
        </div> <!-- row -->
        </div> <!-- container -->
</div> <!-- iep related services -->

<%//=============================================================================%>
<%//                            Provisions Tab                                   %>
<%//=============================================================================%>

<div id="tab-sped-iep-provisions">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                          LRE Placement Tab                                  %>
<%//=============================================================================%>

<div id="tab-sped-iep-lre-placement">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                    Summary of Performance Tab                              %>
<%//=============================================================================%>

<div id="tab-sped-iep-summary-of-performance">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                           Create IEP Tab                                    %>
<%//=============================================================================%>

<div id="tab-sped-iep-create-iep">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <script type="text/javascript">
                    function doGenerateIepPreview() {
                        let urlGenerateIepPreview = '<%=Spedmon.SpEdDocumentTemplates.URL_SPED_DOCUMENT_OUTPUT(Spedmon.SpEdDocumentTemplates.SPED_DOCUMENT_DATA_SOURCE_PATIENT_CURRENT_OR_WIP_SPED_DATA,this.clientID, this.patID)%>';
                        MBA.ComponentCommon.fnOpenWindow(urlGenerateIepPreview, 'ieppreview');
                    };
                </script>

                <Spedmon:DataEntryButton ID="generateIepPreview" style="PRIMARY" onclick="doGenerateIepPreview()" label="Generate Preview of Current or Work In Progress IEP" runat="server" />
            </div>
        </div>
    </div>
</div>

<%//=============================================================================%>
<%//                         Student History Tab                                %>
<%//=============================================================================%>

<div id="tab-sped-iep-student-history">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
            </div>
        </div>
    </div>
</div>

</div> <!-- tabs -->
</div> <!-- col -->
</div> <!-- row -->

</Spedmon:DataEntryRows>

</div> <!-- col -->
</div> <!-- row -->
</div> <!-- container -->

<%//#####################################################################################################%>
<%//                                           Scripts                                                   %>
<%//#####################################################################################################%>

<script type="text/javascript">
    let $r1_cl = null;
    let $r1_cr = null;
    let initComplete = false;

    var _editingUserName = '<%=editingUserName%>';

    const PARM_NAME_CLIENT_ID = '<%=Constants.PARM_CLIENT_ID%>';
    const PARM_NAME_PAT_ID = '<%=Constants.PARM_PATIENT_ID%>';
    const PARM_NAME_ACTIVE = '<%=Constants.PARM_ACTIVE%>';
    const PARM_NAME_PAT_GOAL_ID = '<%=Constants.PARM_PATIENT_GOAL_ID%>';
    const PARM_NAME_GRP_SVC_CLASS_NAME_ID = '<%=Constants.PARM_GRP_SVC_CLS_NME_ID%>';

    function saveIEPData() {
        $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', function (rd) {
            if (initComplete) {
            }
        }, true);
    }

    const PRESENT_LEVELS_SECTION_NAMES = {
        'studentstrengths': 'Student Strengths',
        'parentconcerns': 'Parent Concerns',
        'reading': 'Reading',
        'writing': 'Writing',
        'math': 'Math',
        'communicationdev': 'Communication Development',
        'grossfinemotor': 'Gross/Fine Motor',
        'health': 'Health',
        'vocational': 'Vocational',
        'adaptivedailyliving': 'Adaptive/Daily Living',
        'socialemotionalbehavioral': 'Social/Emotional/Behavioral'
    };

    function fnGetPresentLevelsStatusObj() {
        var raw = $('[name="spedpresentlevelsdatajson"]').val() || '';
        var obj = {};
        if (raw) {
            try { obj = JSON.parse(raw); } catch (e) { obj = {}; }
        }
        if (!obj.sectionStatus) { obj.sectionStatus = {}; }
        return obj;
    }

    function fnSetPresentLevelsStatusObj(obj) {
        $('[name="spedpresentlevelsdatajson"]').val(JSON.stringify(obj)).trigger('change');
    }

    function fnGetSectionStatusInfo(sectionName) {
        var obj = fnGetPresentLevelsStatusObj();
        return obj.sectionStatus ? obj.sectionStatus[sectionName] : null;
    }

    function fnTodayMMDDYYYY() {
        var d = new Date();
        var mm = ('0' + (d.getMonth() + 1)).slice(-2);
        var dd = ('0' + d.getDate()).slice(-2);
        return mm + '/' + dd + '/' + d.getFullYear();
    }

    function fnRecordSectionStatus(sectionName, status) {
        var obj = fnGetPresentLevelsStatusObj();
        obj.sectionStatus[sectionName] = { status: status, by: _editingUserName, on: fnTodayMMDDYYYY() };
        fnSetPresentLevelsStatusObj(obj);
    }

    function fnClearSectionStatus(sectionName) {
        var obj = fnGetPresentLevelsStatusObj();
        if (obj.sectionStatus && obj.sectionStatus.hasOwnProperty(sectionName)) {
            delete obj.sectionStatus[sectionName];
            fnSetPresentLevelsStatusObj(obj);
        }
    }

    function fnSavePresentLevelsSection(sectionName) {
        fnRecordSectionStatus(sectionName, 'draft');
        $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', function (rd) {
            if (rd && rd.success) {
                fnMarkSectionSavedDraft(sectionName);
            }
        }, true);
    }

    function fnFinalizePresentLevelsSection(sectionName) {
        var displayName = PRESENT_LEVELS_SECTION_NAMES[sectionName] || sectionName;
        fnRecordSectionStatus(sectionName, 'finalized');
        $.spedmonWebUI.dataEntry.openValidateThenSaveDialog('custom', function (rd) {
            if (rd && rd.success) {
                fnMarkSectionFinalized(sectionName);
            }
        }, true);
    }

    function fnSetSectionEditorName($accordion, byName) {
        var $header = $accordion.find('.iep-present-tab-accordion__header').first();
        if (!$header.length) { return; }
        var $editor = $header.find('.iep-present-tab-accordion__editor');
        if (!byName) {
            $editor.remove();
            return;
        }
        if (!$editor.length) {
            $editor = $('<span class="iep-present-tab-accordion__editor"></span>');
            $header.append($editor);
        }
        $editor.text(byName);
    }

    function fnApplyDraftBadge($accordion, byName) {
        var $status = $accordion.find('.iep-present-tab-accordion__status');
        if (!$status.length) { return; }
        $status.removeClass('iep-present-tab-accordion__status--empty iep-present-tab-accordion__status--checked iep-present-tab-accordion__status--not-checked iep-present-tab-accordion__status--finalized iep-present-tab-accordion__status--saved-draft');
        $status.addClass('iep-present-tab-accordion__status--saved-draft');
        $status.html('<i class="fas fa-save iep-present-tab-accordion__status-icon"></i> Saved Draft');
        fnSetSectionEditorName($accordion, byName ? ('Edited by ' + byName) : '');
    }

    function fnApplyFinalizedBadge($accordion, byName) {
        var $status = $accordion.find('.iep-present-tab-accordion__status');
        if (!$status.length) { return; }
        $status.removeClass('iep-present-tab-accordion__status--empty iep-present-tab-accordion__status--checked iep-present-tab-accordion__status--not-checked iep-present-tab-accordion__status--saved-draft iep-present-tab-accordion__status--finalized');
        $status.addClass('iep-present-tab-accordion__status--finalized');
        $status.html('<i class="fas fa-check-circle iep-present-tab-accordion__status-icon"></i> Finalized');
        $accordion.addClass('iep-present-tab-accordion--finalized');
        var $finalizeBtn = $accordion.find('.iep-present-tab-accordion__actions .btn-success');
        $finalizeBtn.prop('disabled', true)
            .removeClass('btn-success')
            .addClass('btn-secondary')
            .html('<i class="fas fa-check mr-1"></i> Finalized');
        fnSetSectionEditorName($accordion, byName ? ('Finalized by ' + byName) : '');
    }

    function fnMarkSectionSavedDraft(sectionName) {
        var $accordion = $('.iep-present-tab-accordion[data-section="' + sectionName + '"]');
        if ($accordion.length) {
            fnApplyDraftBadge($accordion, _editingUserName);
        }
    }

    function fnMarkSectionFinalized(sectionName) {
        var $accordion = $('.iep-present-tab-accordion[data-section="' + sectionName + '"]');
        if ($accordion.length) {
            fnApplyFinalizedBadge($accordion, _editingUserName);
        }
    }

    function fnToggleIEPAccordion(headerElement) {
        var $accordion = $(headerElement).closest('.iep-present-tab-accordion');
        var isCollapsed = $accordion.hasClass('iep-present-tab-accordion--collapsed');
        if (isCollapsed) {
            $accordion.removeClass('iep-present-tab-accordion--collapsed');
            $(headerElement).attr('aria-expanded', 'true');
        } else {
            $accordion.addClass('iep-present-tab-accordion--collapsed');
            $(headerElement).attr('aria-expanded', 'false');
        }
    }

    function fnExpandAllIEPPresentTabAccordions() {
        $('.iep-present-tab-accordion').removeClass('iep-present-tab-accordion--collapsed');
        $('.iep-present-tab-accordion__header').attr('aria-expanded', 'true');
    }

    function fnCollapseAllIEPPresentTabAccordions() {
        $('.iep-present-tab-accordion').addClass('iep-present-tab-accordion--collapsed');
        $('.iep-present-tab-accordion__header').attr('aria-expanded', 'false');
    }

    function closeWindow() {
        window.close();
    };

    function initProfile() {
        let opts = {};
        opts.PARM_NAME_CLIENT_ID = '<%=Spedmon.Constants.PARM_CLIENT_ID%>';
        opts.PARM_NAME_REC_ID = '<%=Spedmon.Constants.PARM_REC_ID%>';
        opts.PARM_NAME_SAVE_TYPE = '<%=Spedmon.Constants.PARM_SAVE_TYPE%>';
        opts.PARM_NAME_VALIDATE_REC = '<%=Spedmon.Constants.PARM_VALIDATE_REC%>';
        opts.PARM_NAME_EDIT_DEL_REASON = '<%=Spedmon.Constants.PARM_EDIT_DEL_REASON%>';
        opts.PARM_NAME_SEARCH_TERM = '<%=Spedmon.Constants.PARM_SEARCH_TERM%>';
        opts.sessionTimeOutUrl = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.baseUrlSaveProfile = '<%=Spedmon.Patients.URL_SVC_SAVE_PROFILE_BASE()%>';
        opts.baseUrlGetProfile = '<%=Spedmon.Patients.URL_SVC_GET_BASE()%>';
        opts.baseUrlSiteIDSel = '<%=Spedmon.Sites.URL_SVC_VIEW_SEL()%>';
        opts.baseUrlPreferredContactMethodIDSel = '<%= Spedmon.ContactMethods.URL_VIEW_SEL_BASE()%>';
        opts.isPcalStaff = <%=isPcalStaffJSBoolStr%>;
        opts.VALUE_SAVE_TYPE = '<%=saveType%>';
        opts.VALUE_PAT_ID = '<%=recID%>';
        opts.baseUrlSaveProfilePicture = '<%=Spedmon.PatientProfilePictures.URL_SVC_SAVE_OR_REPLACE_BASE()%>';
        opts.baseUrlGetProfilePicture = '<%=Spedmon.PatientProfilePictures.URL_SVC_GET_BASE()%>';
        opts.baseUrlDeleteProfilePicture = '';
        opts.enableProfilePictureUpload = true;
        opts.baseUrlFindStudentsWithSSID = '<%=Spedmon.CrossClientPatients.URL_VIEW_SEL_FOR_NEW_RECS_BASE()%>';
        opts.fnAfterSaveEdit = function (patID) {
            if (initComplete) {
            }
        };
        opts.fnBeforeShrink = function () {
            $($r1_cl).removeClass('col-3');
            $($r1_cr).removeClass('col-9');
        };
        opts.fnAfterShrink = function () {
            $($r1_cl).addClass('col-3 shrink');
            $($r1_cr).addClass('col-12');
        };
        opts.fnBeforeRestore = function () {
            $($r1_cl).removeClass('col-3 shrink');
            $($r1_cr).removeClass('col-12');
        };
        opts.fnAfterRestore = function () {
            $($r1_cl).addClass('col-3');
            $($r1_cr).addClass('col-9');
        };
        opts.baseUrlInvitePatientPortal     = '<%=Spedmon.Patients.URL_INVITE_PATIENT_TO_PORTAL_BASE()%>';
        opts.baseUrlSaveMessage             = '<%=urlUserMessagesSave%>';
        opts.baseUrlurlRecipientSrc         = '<%=urlRecipientSrc%>';
        MBA.PatientProfileCommon.fnSetup('profile', opts);
    };

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
        optsObj.defaultPageRowOrder               = '<%=Spedmon.PatientGoal.DEFAULT_PAGING_ORDER%>';
        optsObj.baseUrlAddNew                     = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlEdit                       = '<%=Spedmon.PatientGoals.URL_REST_SAVE_INLINE_BASE()%>';
        optsObj.baseUrlDelete                     = '<%=Spedmon.PatientGoals.URL_REST_DELETE_INLINE_BASE()%>'
        optsObj.groupSvcClassNameIDOpts           = '<%=Spedmon.GroupsServiceClasses.URL_REST_VIEWSEL_FOR_ORP_DOCS_BASE()%>';
        optsObj.patientGoalsDefaultDates          = '<%=Spedmon.PatientGoalsDefaultDates.URL_SVC_VIEW_DEFAULT_DATES_BASE()%>';
        optsObj.baseUrlIndividualGoal             = '<%=Spedmon.PatientGoalsProgressIndividualGoals.URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS_BASE()%>';
        optsObj.roleID                            = '<%=rd.wu.usr.roleID%>';
        optsObj.baseUrlViewProgress               = '<%=urlViewAllPatientGoalsProgress%>';
        optsObj.pracGrpSvcClassNameID             = '<%=pracGrpSvcClassNameID%>';
        optsObj.autoHidePageControls              = true;
        optsObj.enableScrollView                  = true;
        optsObj.scrollViewUseCustomHeight         = true;
        optsObj.scrollViewCustomHeight            = '20em';
        MBA.PatientGoalsCommon.fnSetup('goalsRestView', optsObj);
        return;
    }

    function initPromisedServicesView() {

        let optsObj = {
          PARM_NAME_CLIENT_ID:       '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , PARM_NAME_PAT_ID:          '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , PARM_NAME_ACTIVE:          '<%=Spedmon.Constants.PARM_ACTIVE%>'
        , PARM_NAME_REC_ID:          '<%=Spedmon.Constants.PARM_REC_ID%>'
        , containerCtrlID:           'datamanagerowsrestviewpatientpromisedservices'
        , sessionTimeOutUrl:         '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , baseUrlView:               '<%=Spedmon.PatientPromisedServices.URL_REST_VIEW()%>'
        , defaultPageRowOrder:       '<%=Spedmon.PatientPromisedService.DEFAULT_PAGING_ORDER%>'
        , baseUrlAddNew:             '<%=Spedmon.PatientPromisedServices.URL_ADD_NEW_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlEdit:               '<%=Spedmon.PatientPromisedServices.URL_EDIT_PATIENT_PROMISED_SERVICE()%>'
        , baseUrlDelete:             '<%=Spedmon.PatientPromisedServices.URL_REST_DELETE_INLINE()%>'
        , baseUrlReport:             ''
        , defaultReportNumber:       '1'
        , autoHidePageControls:      true
        , enableScrollView:          true
        , scrollViewUseCustomHeight: true
        , scrollViewCustomHeight:    '20em'

        };

        MBA.PatientPromisedServicesCommon.fnSetup('restviewpatientpromisedservices', optsObj);
        return;
    };

    function opnPatGoalProgress() {
        MBA.ComponentCommon.fnOpenWindow('<%=urlViewAllPatientGoalsProgress%>', 'patgoalsprogress');
    };

    function updateOtherTabsDisability1(dataitem) {
        if (dataitem && dataitem.name) {
            $('#spedDisability1Display').text(dataitem.name);
        }
    }

    function updateOtherTabsDisability2(dataitem) {
        if (dataitem && dataitem.name) {
            $('#spedDisability2Display').text(dataitem.name);
        }
    }

    function fnShowOrHideOtherTxtForReferringPerson(selectedID) {
        if (selectedID == '99') {
            $('#divSpedReferringPersonOtherTxt').show();
        } else {
            $('#divSpedReferringPersonOtherTxt').hide();
        }
    }

    function updateCaseMangerNameInput() {
        setTimeout(function () {
            document.getElementById('<%= spedcasemanagerusername.ClientID %>').value = document.querySelector('[id*="selectspedcasemanager"] input[type="text"]').value;
        }, 100);
    }
    function initTabs() {
        $("#patspedtabs").MBA_Tabs({});              
        <%if (!String.IsNullOrWhiteSpace(tabToOpen)) {%>
            $('a[href="#<%=tabToOpen%>"]').click();
        <%}%>
        var tabID = sessionStorage.getItem("tabToClickOnLoad");
        if (tabID) {
            sessionStorage.removeItem("tabToClickOnLoad");
            $('a[href="#' + tabID + '"]').click();
        }
        $('#patspedtabs').on('shown.bs.tab click', 'a[href="#tabpresentlevels"]', function () {
            initPresentLevelsStatusBadges();
        });
    };

    var statusBadgesInitialized = false;

    var STATUS_BADGE_CONFIG = {
        'checked': {
            icon:      'fa-check-circle',
            text:      'Reviewed, N/A',
            className: 'iep-present-tab-accordion__status--checked'
        },
        'not-checked': {
            icon:      'fa-times-circle',
            text:      'Not Reviewed',
            className: 'iep-present-tab-accordion__status--not-checked'
        }
    };

    function fnInjectStatusBadgeStyles() {
        if ($('#iep-status-badge-styles').length) { return; }
        var css = '' +
            '.iep-present-tab-accordion__status {' +
            '    display: inline-flex; align-items: center; gap: 0.25rem;' +
            '    padding: 0.25rem 0.5rem; font-size: 0.6875rem; font-weight: 500;' +
            '    line-height: 1; border-radius: 9999px; white-space: nowrap;' +
            '    margin-left: auto; margin-right: 0.5rem;' +
            '}' +
            '.iep-present-tab-accordion__status--empty { display: none; }' +
            '.iep-present-tab-accordion__status--checked {' +
            '    background-color: #d1fae5; color: #065f46; border: 1px solid #6ee7b7;' +
            '}' +
            '.iep-present-tab-accordion__status--not-checked {' +
            '    background-color: #fee2e2; color: #991b1b; border: 1px solid #fca5a5;' +
            '}' +
            '.iep-present-tab-accordion__status--saved-draft {' +
            '    background-color: #fef3c7; color: #92400e; border: 1px solid #fcd34d;' +
            '}' +
            '.iep-present-tab-accordion__status--finalized {' +
            '    background-color: #dbeafe; color: #1e40af; border: 1px solid #93c5fd;' +
            '}' +
            '.iep-present-tab-accordion__header { position: relative; }' +
            '.iep-present-tab-accordion__editor {' +
            '    position: absolute; left: 50%; top: 50%;' +
            '    transform: translate(-50%, -50%);' +
            '    font-size: 0.8125rem; font-weight: 600; color: #475569;' +
            '    white-space: nowrap; pointer-events: none;' +
            '}' +
            '.iep-present-tab-accordion__status-icon { font-size: 0.625rem; }';
        $('<style id="iep-status-badge-styles">' + css + '</style>').appendTo('head');
    }

    function fnApplyReviewedBadge($accordion, byName) {
        var $status = $accordion.find('.iep-present-tab-accordion__status');
        if (!$status.length) { return; }
        $status.removeClass('iep-present-tab-accordion__status--empty iep-present-tab-accordion__status--not-checked iep-present-tab-accordion__status--saved-draft iep-present-tab-accordion__status--finalized iep-present-tab-accordion__status--checked');
        $status.addClass('iep-present-tab-accordion__status--checked');
        $status.html('<i class="fas fa-check-circle iep-present-tab-accordion__status-icon"></i> Reviewed, N/A');
        fnSetSectionEditorName($accordion, byName ? ('Reviewed by ' + byName) : '');
    }

    function fnApplyNotReviewedBadge($accordion) {
        var $status = $accordion.find('.iep-present-tab-accordion__status');
        if (!$status.length) { return; }
        $status.removeClass('iep-present-tab-accordion__status--empty iep-present-tab-accordion__status--checked iep-present-tab-accordion__status--saved-draft iep-present-tab-accordion__status--finalized iep-present-tab-accordion__status--not-checked');
        $status.addClass('iep-present-tab-accordion__status--not-checked');
        $status.html('<i class="fas fa-times-circle iep-present-tab-accordion__status-icon"></i> Not Reviewed');
        fnSetSectionEditorName($accordion, '');
    }

    function fnGetReviewedNAState($accordion) {
        var $hiddenInput = $accordion.find('input[type="text"]').filter(function () {
            return ($(this).attr('name') || '').toLowerCase().indexOf('reviewedna') > -1;
        });
        if ($hiddenInput.length) { return $hiddenInput.val() === 'true'; }
        var $checkbox = $accordion.find('input[type="checkbox"]').filter(function () {
            return ($(this).attr('id') || '').toLowerCase().indexOf('reviewedna') > -1;
        });
        if ($checkbox.length) { return $checkbox.is(':checked'); }
        return null;
    }

    function initPresentLevelsStatusBadges() {
        fnInjectStatusBadgeStyles();
        $('.iep-present-tab-accordion').each(function () {
            var $accordion = $(this);
            var section = $accordion.attr('data-section');
            var info = section ? fnGetSectionStatusInfo(section) : null;
            if (info && info.status === 'finalized') {
                fnApplyFinalizedBadge($accordion, info.by);
                return;
            }
            if (info && info.status === 'draft') {
                fnApplyDraftBadge($accordion, info.by);
                return;
            }
            if (info && info.status === 'reviewed') {
                fnApplyReviewedBadge($accordion, info.by);
                return;
            }
            var isChecked = fnGetReviewedNAState($accordion);
            if (isChecked === null) {
                $accordion.find('.iep-present-tab-accordion__status').addClass('iep-present-tab-accordion__status--empty');
                return;
            }
            if (isChecked) {
                fnApplyReviewedBadge($accordion, '');
            } else {
                fnApplyNotReviewedBadge($accordion);
            }
        });
        if (statusBadgesInitialized) { return; }
        $(document).on('change', '.iep-present-tab-accordion input[type="checkbox"]', function (e) {
            var $checkbox = $(this);
            if (($checkbox.attr('id') || '').toLowerCase().indexOf('reviewedna') === -1) { return; }
            fnHandleReviewedNAToggle($checkbox.closest('.iep-present-tab-accordion'), $checkbox.is(':checked'));
        });
        $(document).on('spedmoninputdata', '.iep-present-tab-accordion input[type="text"]', function (e) {
            var $input = $(this);
            if (($input.attr('name') || '').toLowerCase().indexOf('reviewedna') === -1) { return; }
            fnHandleReviewedNAToggle($input.closest('.iep-present-tab-accordion'), $input.val() === 'true');
        });
        statusBadgesInitialized = true;
    }

    function fnHandleReviewedNAToggle($accordion, isChecked) {
        var section = $accordion.attr('data-section');
        var info = section ? fnGetSectionStatusInfo(section) : null;
        if (info && (info.status === 'draft' || info.status === 'finalized')) { return; }
        if (isChecked) {
            if (section) { fnRecordSectionStatus(section, 'reviewed'); }
            fnApplyReviewedBadge($accordion, _editingUserName);
        } else {
            if (section) { fnClearSectionStatus(section); }
            fnApplyNotReviewedBadge($accordion);
        }
    }

    function fnInjectResendValidationStyles() {
        if ($('#iep-resend-validation-styles').length) { return; }
        var css = '' +
            '@keyframes iepHighlightPulse {' +
            '    0%   { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0.5); }' +
            '    25%  { box-shadow: 0 0 0 6px rgba(255, 193, 7, 0.3); }' +
            '    50%  { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0.5); }' +
            '    75%  { box-shadow: 0 0 0 6px rgba(255, 193, 7, 0.3); }' +
            '    100% { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0); }' +
            '}' +
            '.iep-resend-highlight {' +
            '    animation: iepHighlightPulse 2.5s ease-in-out;' +
            '    border: 2px solid #ffc107 !important; border-radius: 6px;' +
            '    transition: border-color 0.3s ease;' +
            '}' +
            '.iep-resend-toast {' +
            '    position: fixed; top: 20px; right: 20px; z-index: 10000;' +
            '    min-width: 340px; max-width: 480px; padding: 14px 20px;' +
            '    background-color: #fff3cd; color: #856404;' +
            '    border: 1px solid #ffc107; border-left: 4px solid #ffc107;' +
            '    border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);' +
            '    font-size: 0.875rem; font-weight: 500;' +
            '    display: flex; align-items: center; gap: 10px;' +
            '    opacity: 0; transform: translateX(40px);' +
            '    transition: opacity 0.35s ease, transform 0.35s ease;' +
            '}' +
            '.iep-resend-toast--visible { opacity: 1; transform: translateX(0); }' +
            '.iep-resend-toast__icon { font-size: 1.15rem; flex-shrink: 0; }';
        $('<style id="iep-resend-validation-styles">' + css + '</style>').appendTo('head');
    }

    function fnShowResendToast(message) {
        fnInjectResendValidationStyles();
        $('.iep-resend-toast').remove();
        var $toast = $(
            '<div class="iep-resend-toast">' +
                '<i class="fas fa-exclamation-triangle iep-resend-toast__icon"></i>' +
                '<span>' + message + '</span>' +
            '</div>'
        );
        $('body').append($toast);
        setTimeout(function () { $toast.addClass('iep-resend-toast--visible'); }, 50);
        setTimeout(function () {
            $toast.removeClass('iep-resend-toast--visible');
            setTimeout(function () { $toast.remove(); }, 400);
        }, 4000);
    }

    function fnHighlightMeetingSections() {
        fnInjectResendValidationStyles();
        var $details = $('.gridlines-layout-meeting-details');
        var $info    = $('.gridlines-layout-meeting-info');
        $details.addClass('iep-resend-highlight');
        $info.addClass('iep-resend-highlight');
        $('html, body').animate({ scrollTop: $details.offset().top - 100 }, 400);
        setTimeout(function () {
            $details.removeClass('iep-resend-highlight');
            $info.removeClass('iep-resend-highlight');
        }, 2500);
    }

    function fnValidateMeetingBeforeResend() {
        var meetingDate     = $('input[name="spedmeetingdate"]').val()              || '';
        var meetingTime     = $('input[name="spedmeetingtime"]').val()              || '';
        var meetingDuration = $('input[name="spedmeetingdurationinmins"]').val()    || '';
        var meetingTitle    = $('input[name="spedmeetingtitle"]').val()             || '';
        if (!meetingDate || !meetingTime || !meetingDuration || !meetingTitle) {
            fnHighlightMeetingSections();
            fnShowResendToast('Please complete Meeting Date, Time, Duration, and Title before sending.');
            return false;
        }
        return true;
    }

    var _lastSavedMeetingDate     = '';
    var _lastSavedMeetingTime     = '';
    var _lastSavedMeetingDuration = '';
    var _lastSavedMeetingTitle    = '';

    function fnCaptureMeetingBaseline() {
        _lastSavedMeetingDate     = $('input[name="spedmeetingdate"]').val()           || '';
        _lastSavedMeetingTime     = $('input[name="spedmeetingtime"]').val()           || '';
        _lastSavedMeetingDuration = $('input[name="spedmeetingdurationinmins"]').val() || '';
        _lastSavedMeetingTitle    = $('input[name="spedmeetingtitle"]').val()          || '';
    }

    function fnCheckMeetingDetailsChanged() {
        var currentDate     = $('input[name="spedmeetingdate"]').val()           || '';
        var currentTime     = $('input[name="spedmeetingtime"]').val()           || '';
        var currentDuration = $('input[name="spedmeetingdurationinmins"]').val() || '';
        var currentTitle    = $('input[name="spedmeetingtitle"]').val()          || '';
        return (currentDate     !== _lastSavedMeetingDate)
            || (currentTime     !== _lastSavedMeetingTime)
            || (currentDuration !== _lastSavedMeetingDuration)
            || (currentTitle    !== _lastSavedMeetingTitle);
    }
    function fnInitMeetingChangeDetection() {
        fnCaptureMeetingBaseline();
        $('input[name="spedmeetingdate"], input[name="spedmeetingtime"], input[name="spedmeetingdurationinmins"], input[name="spedmeetingtitle"]')
            .on('change', function () {
                if (fnCheckMeetingDetailsChanged()) {
                    var $grid = $('#restViewSpEdGridlinesLayout');
                    var dataObj = $grid.data('jq-mba-sped-gridlines-layout-common');
                    if (dataObj && dataObj.meetingSent) {
                        MBA.SpEdMeetingIEPGridCommon.fnResetMeetingSentState('restViewSpEdGridlinesLayout');
                    }
                }
            });
    }

    var _meetingHistoryData = <%=meetingHistoryJSON%>;

    function initAccommodationsView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , containerCtrlID: 'datamanagerowsrestviewpatientaccommodations'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlGet: '<%=Spedmon.PatientAccommodations.URL_SERVICE_BASE%>/get'
            , baseUrlSave: '<%=Spedmon.PatientAccommodations.URL_SERVICE_BASE%>/save'
        , baseUrlView: '<%=Spedmon.PatientAccommodations.URL_REST_VIEW()%>'
        , defaultPageRowOrder: '<%=Spedmon.PatientAccommodation.DEFAULT_PAGING_ORDER%>'
        , baseUrlAddNew: '<%=Spedmon.PatientAccommodations.URL_ADD_NEW_PATIENT_ACCOMMODATION()%>'
        , baseUrlEdit: '<%=Spedmon.PatientAccommodations.URL_EDIT_PATIENT_ACCOMMODATION()%>'
            , baseUrlDelete: '<%=Spedmon.PatientAccommodations.URL_REST_DELETE_INLINE()%>'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '24em'
        };

        MBA.PatientAccommodationsCommon.fnSetup('restviewpatientaccommodations', optsObj);
        return;
    };

    function initGridlinesLayout() {

        let optsObj = {
            PARM_NAME_CLIENT_ID:         '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
          , PARM_NAME_PAT_ID:            '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
          , PARM_NAME_ACTIVE:            '<%=Spedmon.Constants.PARM_ACTIVE%>'
          , containerCtrlID:             'dataManagementRowsForSpEdGridlinesLayout'
          , sessionTimeOutUrl:           '<%=MBA.Credential.generateSessionExpiredLink()%>'
          , autoHidePageControls:        true
          , enableScrollView:            true
          , scrollViewUseCustomHeight:   true
          , scrollViewCustomHeight:      '20em'
          , isPcalStaff:                 <%=isPcalStaffJSBoolStr%>
          , populateDefaults:            true
          , participantCountCtrlID:      'spedGridlinesLayout_participant_count'
          , addRowBtnID:                 'spedGridlinesLayout_add_row'
          , existingCtrlParticipantJSON: 'spedparticipantdetailsjson'
          , existingCtrlLayoutJSON:      'spedgridlineslayoutjson'
          , existingCtrlCaseManagerUID:  'spedfacilitatoruserid'
          , baseUrlResendInvite:         '<%=Spedmon.Patients.URL_SVC_RESEND_MEETING_INVITE_BASE()%>'
          , baseUrlSendMeeting:          '<%=Spedmon.Patients.URL_SVC_SEND_MEETING_INVITES_BASE()%>'
            , onAdd: function (selObj) { }
            , onRemove: function (selObj) { }
            , onChange: function (selObj) { }
            , onResend: function (selObj) { return fnValidateMeetingBeforeResend(); }
        };

        MBA.SpEdMeetingIEPGridCommon.fnSetup('restViewSpEdGridlinesLayout', optsObj);

        $('#selectFacilitator_selection').on('autocompleteselect', function (event, ui) {
            if (ui && ui.item && ui.item.label) {
                MBA.SpEdMeetingIEPGridCommon.fnSetCaseManagerName('restViewSpEdGridlinesLayout', ui.item.label);
                $('input[name="spedfacilitatorusername"]').val(ui.item.label);
            }
        });

        $('#selectFacilitator_selection').on('change', function () {
            var selectedName = $(this).val() || '';
            if (selectedName) {
                MBA.SpEdMeetingIEPGridCommon.fnSetCaseManagerName('restViewSpEdGridlinesLayout', selectedName);
                $('input[name="spedfacilitatorusername"]').val(selectedName);
            }
        });

        $('#spedGridlinesLayout_view_history').on('click', function (e) {
            e.preventDefault();
            var $h = $('#spEdMeetingHistoryRestView');
            if ($h.length && $h.is(':visible')) {
                $('html, body').animate({ scrollTop: $h.offset().top - 80 }, 400);
            } else {
                if (!_meetingHistoryData || _meetingHistoryData.length === 0) {
                    if (typeof fnShowResendToast === 'function') {
                        fnShowResendToast('No past meeting sessions found for this patient.');
                    }
                }
            }
            return false;
        });

        $('#spedGridlinesLayout_refresh').on('click', function (e) {
            e.preventDefault();
            sessionStorage.setItem('tabToClickOnLoad', 'tab-sped-iep-team-members');
            window.location.reload();
            return false;
        });

        MBA.SpEdMeetingIEPHistoryGridCommon.fnSetup('spEdMeetingHistoryRestView', {
            historyData: _meetingHistoryData
        });

        fnInitMeetingChangeDetection();

        return;
    }

    /*------------------------------------------------------------------------*/

    $(document).ready(function () {

        $r1_cl = $('#r1-cl');
        $r1_cr = $('#r1-cr');
        initComplete = false;

        $($r1_cl).addClass('mba-save-type-edit');
        $($r1_cr).addClass('mba-save-type-edit');
        $($r1_cl).addClass('col-3');
        $($r1_cr).addClass('col-9');

        initProfile();
        initTabs();
        initPatientGoalsView();
        initPromisedServicesView();
        initGridlinesLayout();
        initPresentLevelsStatusBadges();
        initAccommodationsView();

        initComplete = true;
    });
</script>