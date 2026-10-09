<%@Page Language="C#" 
  AutoEventWireup="true" 
  CodeBehind="telecomm_iep.aspx.cs"
  Inherits="Spedmon.TeleCommPageIEP"
  systemStatusElementID = "systemstatus"    
  formJoinControlID     = "formjoin" 
  formLeaveControlID                      = "formleave"
  browserNotSupportedElementID            = "browsernotsupported"
  sessionLogElementID                     = "sessionlog"
  participantPublicationControlsElementID = "participantpubcontrols"
  participantStreamsElementID             = "participantstreams"
  participantStreamsContainerID           = "participantsstreamscontainer"
  toggleParticipantsViewBtnID             = "toggleparticipantsviewbtn"
  whatIsMyPinBtnID                        = "whatismypinbtn"
  sendMeetingInvitesBtnID                 = "sendmeetinginvitesbtn"
  appendSharedFilesBtnID                  = "appendsharedfilesbtn"
  sessionFilesElementID                   = "meetingfiles"
  sessionPresentContentElementID          = "sessionpresentcontent"
  customIncludeForPageCSS                 = "iep/screen-iep.css" 
  customIncludeForPageJS                  = "iep/page.js"
  autoRestoreFormAndSignatureData         = true
%>

<div id="page" class="page container"> <%/* Page grid */%>

<%/*###################################### Header ######################################*/%>

<header id="pageheader" class="pageheader row">
<section class="col-12">
<div class="container"> <%/* Header content grid */%>

<div class="row"> <%/* Header content grid - Row 1 */%>

<!-- ################### Logo and title ################### -->
  <div class="col-6">
    <img id="app-logo" class="pagelogo" alt="logo" src="web-ui-3\mba\css\app-icons\HYQueue-logo.svg">
  </div> <!-- col -->
  <div class="col-6">
    <h1 id="meeting-title" class="pagetitle">
    <%if (tsp.renderWhatRoom == MBA.TeleCommRenderWhatRoom.INSIDE_ROOM) {%>
      <%=tsp.roomTitle%>
    <%} else {%>
      <%=roomTitlePublic%>    
    <%}%>
    </h1>
  </div> <!-- col -->

  <div class="col-12">    
    <div id="systemstatus">
      <%=(generateSessionJoinedFailedStatusMessageIfNeeded(tsp))%>
    </div>    
  </div> <!--col -->

</div> <!-- row -->
</div> <!-- Header content container -->
</section> <!-- col -->
</header> <!-- row -->

<%/*###################################### Main ###################################### */%>

<main id="pagemain" class="pagemain row" role="main"> <%/* Page grid - Row 2 */%>

<section class="col-12"> <%/* Page grid - Row 2 - Column 1 */%>
<div class="container"> <%/* Main content grid */%> 

<%/*###################################### 
    # Main Content Inside Room 
    ######################################*/%>

<%if (tsp.renderWhatRoom == MBA.TeleCommRenderWhatRoom.INSIDE_ROOM) {%>

    <div class="row"> <%/* Main content grid - Row 1 */%>

        <%/*#################
            # Streams 
            ##################*/%> 
        <div class="col-12 mb-2"> <%/* Main content grid - Row 1 - Col 1*/%>
            <button id="toggleparticipantsviewbtn" type="button" class="btn btn-primary btn-sm">Switch View</button>
            <button id="whatismypinbtn" type="button" class="btn btn-warning btn-sm ml-2">What Is My Pin?</button>
            <%if(_tsp.participantIsFacilitator) {%>
              <button id="sendmeetinginvitesbtn" class="btn btn-info btn-sm ml-2" type="button">Resend Meeting Invites</button>
              <button id="appendsharedfilesbtn" class="btn btn-info btn-sm ml-2" type="button">Upload File</button>
			<%}%>
        </div> <%/* Main content grid - Row 1 - Col 1*/%>

        <section class="col-12"> <%/* Main content grid - Row 1 - Col 2*/%>
        <div id="participantsstreamscontainer" class="participantsstreamscontainer">
            <div id="participantstreams" class="participantstreams"></div>
            </div>
        </section> <%/* Main content grid - Row 1 - Col 2*/%>


    </div> <%/* Main content grid - Row 1 */%>

    <div class="row"> <%/* Main content grid - Row 2 */%>
      
    <section class="col-12">
        
    <h6>Attendance Roster<button id="viewcurrentattendanceroster" type="button" class="btn btn-sm btn-primary" style="margin-left:1em;font-size:.75em">View</button></h6>
    
    <Spedmon:TeleCommFormSign 
        ID                      = "signattendanceroster" 
        forFormID               = "" 
        sigClassName            = "attendanceroster" 
        ctrlSignatureTextAreaID = "attendanceroster-signatureImgBase64"
        ctrlIDSelectParticipant = "signattendrosteruid"
        ctrlIDInputPin          = "signattendrosterpin"
        ctrlIDSign              = "signattendroster"
        fieldNameSign           = "signroster"
        shareDataWhenSigned     = "false"
        title                   = "Attendance Roster"
        runat                   = "server">
      
      <div class="col-12 col-md-2 mt-2 p-0">
        <Spedmon:TeleCommFormSelectParticipant ID="signattendrosteruid" runat="server" />
      </div>
    
      <div class="col-12 offset-md-1 col-md-2 mt-2 p-0">   
        <Spedmon:TeleCommFormEnterPIN ID="signattendrosterpin" runat="server"/>
      </div>
    
      <div class="col-12 offset-md-1 col-md-6 mt-2 mb-2 p-0">

        <div id="signattendroster" class="btn-group btn-group-toggle col-12 p-0" data-toggle="buttons">
        <label class="btn btn-checkbox-white-blue col-12 ">
        <input id="signattendroser-signed" name="parent-signature-secondary-signed-iep" type="radio" value="signed"/>
        Sign Attendance Roster
        </label>
        </div>

        
      </div>

    </Spedmon:TeleCommFormSign>         
      </section>

    </div>
   
    <div class="row"> <%/* Main content grid - Row 3 */%>

<section class="col-12">

<!-- #### Meeting Files  #### -->
<h6>Files</h6>
<div id="meetingfiles" class="container">
<%=tsp.fileShareContent%>

</div> <!-- files -->
</section>
</div>

<div class="row"> <%/* Main content grid - Row 4 */%>

<%/*################### IEP Signature Page Questions Sections - Questions Vary Based on IEP Format ###################*/%>

<section class="col-12">
    <form id="iep-sig-page-questions" action="telecomm_iep.asmx/savesigpagequestions" data-telecomm-remote-update="2" class="iep-column container-fluid p-0">
    <%=_tsp.roomFormHTML%>
    </form>
</section>

<%/*################### Sign IEP - Primary Parent ###################*/%>

<section class="col-12 mt-2">
  <h6>Parent/Guardian/Surrogate/Adult Student Approval</h6>
    
  <p class="agree-attest"> 
  By signing the IEP I authorize and confirm agreement with all of the areas checked above
  </p>
      
  
    <Spedmon:TeleCommFormSign 
        ID                      = "signieppgprimary" 
        forFormID               = "iep-sig-page-questions" 
        sigClassName            = "pgiepapprovalprimary" 
        ctrlIDSelectParticipant = "parentprimaryuid"
        ctrlIDInputPin          = "parentprimarypin"
        ctrlSignatureTextAreaID = "parent-signature-primary-signatureImgBase64"
        ctrlIDSign              = "parent-signature-primary-signed-iep"
        fieldNameSign           = "parent-signature-primary-signed-iep"
        title                   = "Parent/Guardian/Surrogate/Adult Student Approval"
        runat                   = "server">
      
      <div class="col-12 col-md-5 d-flex justify-content-between flex-md-row flex-column p-0">
      <Spedmon:TeleCommFormSelectParentRole ID="parentprimaryrole" runat="server" />
      </div>
      
      <div class="col-0 col-md-7"></div>

      <div class="col-12 col-md-2 mt-2 p-0">
        <Spedmon:TeleCommFormSelectParticipant ID="parentprimaryuid" selectWhatParticipantRoleID="12" runat="server" />
      </div>
    
      <div class="col-12 offset-md-1 col-md-2 mt-2 p-0">   
        <Spedmon:TeleCommFormEnterPIN ID="parentprimarypin" runat="server"/>
      </div>
    
      <div class="col-12 offset-md-1 col-md-6 mt-2 mb-2 p-0">
        <div id="parent-signature-primary-signed-iep" class="btn-group btn-group-toggle col-12 p-0" data-toggle="buttons">
          <label class="btn btn-checkbox-white-blue col-12">
            <input id="parent-signature-primary-signed-iep-signed" name="parent-signature-primary-signed-iep" type="radio" value="signed" autocomplete="off"/>
          Sign the IEP
          </label>
        </div>
      </div>

     </Spedmon:TeleCommFormSign>    
</section>

<%/*################### Sign IEP - Secondary Parent ###################*/%>
 
<section class="col-12">
  <h6>Secondary Parent/Guardian/Surrogate/Adult Student Approval</h6>
         
  <p class="agree-attest"> By signing the IEP I authorize and confirm agreement with all of the areas checked above</p>
   
  <Spedmon:TeleCommFormSign 
      ID                      = "signieppgsecondary" 
      forFormID               = "iep-sig-page-questions" 
      sigClassName            = "pgiepapprovalsecondary" 
      ctrlSignatureTextAreaID = "parent-signature-secondary-signatureImgBase64"
      ctrlIDSelectParticipant = "parentsecondaryuid"
      ctrlIDInputPin          = "parentsecondarypin"
      ctrlIDSign              = "parent-signature-secondary-signed-iep"
      fieldNameSign           = "parent-signature-secondary-signed-iep"
      title                   = "Secondary Parent/Guardian/Surrogate/Adult Student Approval"
      runat                   = "server">
     
     <div class="col-12 col-md-5 d-flex justify-content-between flex-md-row flex-column p-0">
       <Spedmon:TeleCommFormSelectParentRole ID="parentsecondaryrole" runat="server" />
     </div>

     <div class="col-0 col-md-7"></div>
    
     <div class="col-12 col-md-2 mt-2 p-0">
       <Spedmon:TeleCommFormSelectParticipant ID="parentsecondaryuid" selectWhatParticipantRoleID="12" runat="server" />
     </div>
     
     <div class="col-12 offset-md-1 col-md-2 mt-2 p-0"> 
       <Spedmon:TeleCommFormEnterPIN ID="parentsecondarypin" runat="server"/>
     </div>

    <div class="col-12 offset-md-1 col-md-6 mt-2 mb-2 p-0"> 
      <div id="parent-signature-secondary-signed-iep" class="btn-group btn-group-toggle col-12 p-0" data-toggle="buttons">
        <label class="btn btn-checkbox-white-blue col-12 ">
        <input id="parent-signature-secondary-signed-iep-signed" name="parent-signature-secondary-signed-iep" type="radio" value="signed"/>
        Sign the IEP
        </label>
      </div>
    </div>  
    
   </Spedmon:TeleCommFormSign>    

</section>

<%/*################### Billing Option Consent - Parent  ###################*/%>

<section class="col-12">
      <h6>LEA Billing Options Program Consent</h6>
    
      <p class="agree-attest"> 
      If the above named student is or may become eligible for public benefits (Medi-Cal): I authorize the LEA/district to release student information for the
      limited purpose of billing Medi-Cal/Medicaid and to access Medi-Cal: health insurance benefits for applicable services.
      </p>

      <Spedmon:TeleCommFormSign
          ID                      = "signleaboppgconsent"
          sigClassName            = "leaboppgconsent"
          ctrlSignatureTextAreaID = "lea-bop-consent-parent-signatureImgBase64"
          ctrlIDSelectParticipant = "parentleabopconsentuid"
          ctrlIDInputPin = "parentleabopconsentpin"
          ctrlIDSign     = "parent-signature-lea-bop-consent"
          fieldNameSign  = "lea-bop-consent-parent-response"
          title          = "LEA Billing Options Program Consent"

          runat="server">

         <div class="col-12 col-md-5 d-flex justify-content-between flex-md-row flex-column p-0">
           <Spedmon:TeleCommFormSelectParentRole ID="parentleabopconsentrole" runat="server" />
         </div>
	   
         <div class="col-0 col-md-7"></div>

         <div class="col-12 col-md-2 mt-2 p-0">
           <Spedmon:TeleCommFormSelectParticipant ID="parentleabopconsentuid" selectWhatParticipantRoleID="12" runat="server" />
         </div>
     
         <div class="col-12 offset-md-1 col-md-2 mt-2 p-0"> 
           <Spedmon:TeleCommFormEnterPIN ID="parentleabopconsentpin" runat="server"/>
        </div>       
   
         <div class="col-12 offset-md-1 col-md-6 mt-2 mb-2 p-0">
           
           <div id="parent-signature-lea-bop-consent" class="btn-group btn-group-toggle col-12 p-0" data-toggle="buttons">

           <label class="btn btn-checkbox-white-green col-12 col-md-6">
             <input type="radio" id="lea-bop-consent-parent-response-approved" name="lea-bop-consent-parent-response" value="approved"/>Approve Consent
           </label>    
        
           <label class="btn btn-checkbox-white-red col-12 col-md-6">
             <input type="radio" id="lea-bop-consent-parent-response-declined" name="lea-bop-consent-parent-response" value="declined"/>Decline Consent
           </label>        
        
           </div>
        </div>

  </Spedmon:TeleCommFormSign>  
</section>

<%/*################### Generate Signature Page Document  (Facilitator(s) Only) ###################*/%>

<%if(_tsp.participantIsFacilitator) {%>
<section class="col-12">
  <button id="butGenSigPage" class="btn btn-primary btn-lg mt-3 mb-3" type="button">Generate Signature Page</button>
</section>
<%}%>

</div> <%/* Main content grid - Row 3 */%>


<%} else { %>

<%/*###################################### 
    # Main Content Outside Room 
    ######################################*/%>

<div class="row"> <%/* Main content grid (outside) - Row 1 */%>

<!-- ################### Join form ################### -->

<section class="col-12">
<Spedmon:TeleCommFormJoin ID="formjoin" runat="server"/>  
</section> <%/* Main content grid (outside) - Row 1 - Col 1*/%>

<!-- ################### Instructions ################### -->
     
<section class="col-12"> <%/* Main content grid (outside) - Row 1 - Col 2*/%>
  <div id="cam-and-mic-instructions" class="room-text-div">
       <strong>By logging into this meeting I agree and consent to the following conditions:</strong>
       <ul>
           <li>I understand that by logging in to this IEP meeting, I am a participating member of this IEP and will be logged as such.</li>
           <li>I understand that the meeting is required to verify my identity verbally even though they know who I am and I agree to identify myself.</li>
           <li>I understand that I should only attend meetings through this platform from a secure and private location, and should not use any device to record or otherwise capture the meeting.</li>
       </ul>
 </div> 
</section> <!-- col -->

</div> <%/* Main content grid (outside) - Row 1 */%>

<%} /* Outside room */%> 
</div> <%/* Main content grid */%> 
</section> <%/* Page grid - Row 2 - Column 1 */%>
</main> <%/* Page grid - Row 2 */%>

<footer id="pagefooter" class="pagefooter row fixed-bottom"> <%/* Page grid - Row 3 */%>
<section class="col-12"> <%/* Page grid - Row 3 - Column 1 */%>
<div class="container"> <%/* Footer content grid */%>

<%/*###################################### 
    #          Inside room 
    ######################################*/%>

<%if (tsp.renderWhatRoom == MBA.TeleCommRenderWhatRoom.INSIDE_ROOM) {%>

<div class="row"> <%/* Footer content grid - Row 1 */%>

  <%/*#################
      # Participant
      # pub controls
      ##################*/%> 

  <section class="col-3"> <%/* Footer content grid - Row 1 - Col 1 */%>
    <div id="participantpubcontrols" class="publicationcontrols"></div>
  </section> <%/* Footer content grid - Row 1 - Col 1 */%>

  <%/*#################
      # Time         # 
      #################*/%> 

  <section class="col-3"> <%/* Footer content grid - Row 1 - Col 2 */%>    
    <div><span class="meeting-counter-label">Meeting Time</span><span id="meeting-timer" class="meeting-counter-data"></span></div>
  </section> <%/* Footer content grid - Row 2 - Col 3 */%>

  <%/*#################
      # Name          # 
      #################*/%> 

  <section class="col-3"> <%/* Footer content grid - Row 1 - Col 2 */%>
    <span><%=tsp.participantName%></span>
  </section> <%/* Footer content grid - Row 1 - Col 2 */%>

  <%/*#################
      # Form leave    # 
      #################*/%> 

  <section class="col-3"> <%/* Footer content grid - Row 1 - Col 3 */%>
    <Spedmon:TeleCommFormLeave ID="formleave" leaveButtonLabel="Leave Session" runat="server"/>
  </section> <%/* Footer content grid - Row 1 - Col 3 */%>

</div> <%/* Footer content grid - Row 1 */%>

<%/*###################################### 
    #          Inside room 
    ######################################*/%>

<%} else {%>
<div class="row">
<div class="col-12"></div>
</div>
<%}%>
</div> <%/* Footer content grid */%>
</section> <%/* Page grid - Row 3 - Column 1 */%>  
</footer> <%/* Page grid - Row 3 */%>   

</div> <!--container -->

<div id="browsernotsupported" style="display:none"></div>
<ul id="sessionlog" style="display:none"></ul>
