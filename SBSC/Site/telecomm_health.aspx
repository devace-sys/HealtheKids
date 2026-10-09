<%@Page Language="C#" 
  AutoEventWireup                         = "true" 
  CodeBehind                              = "telecomm_health.aspx.cs"
  Inherits                                = "Spedmon.TeleCommPageTeleHealth"
  systemStatusElementID                   = "systemstatus"    
  formJoinControlID                       = "formjoin" 
  formLeaveControlID                      = "formleave"
  browserNotSupportedElementID            = "browsernotsupported"
  sessionLogElementID                     = "sessionlog"
  participantPublicationControlsElementID = "participantpubcontrols"
  participantStreamsElementID             = "participantstreams"
  participantStreamsContainerID           = "participantsstreamscontainer"
  toggleParticipantsViewBtnID             = "toggleparticipantsviewbtn"
  sendMeetingInvitesBtnID                 = "sendmeetinginvitesbtn"
  appendSharedFilesBtnID                  = "appendsharedfilesbtn"
  sessionFilesElementID                   = "meetingfiles"
  sessionPresentContentElementID          = "sessionpresentcontent"
  fullScreenContainerID                   = "fullscreencontainer"
  headerElementSelector                   = "#pageheader"
  mainElementSelector                     = "#pagemain"
  footerElementSelector                   = "#pagefooter"
  customIncludeForPageCSS                 = "health/page.css"
  customIncludeForPageJS                  = "health/page.js"
  autoRestoreFormAndSignatureData         = false
  facilitatorRequiredInRoom               = true
%>

<div id="page" class="page container"> <%/* Page grid */%>

<%/*#################################################################################### 
    #                                      Header
    ####################################################################################*/%>

<header id="pageheader" class="pageheader row"> <%/* Page grid - Row 1 */%>
<section class="col-12"> <%/* Page grid - Row 1 - Column 1 (full width) */%>

  <%/*###################################
      #  Header Content 
      #  Note: This is a seperate grid
      ###################################*/%>

  <div class="container"> <%/* Header content grid */%>

    <div class="row"> <%/* Header content grid - Row 1 */%>

      <%/*##################
          # Logo 
          ##################*/%>

      <section class="col-6"> <%/* Header content grid - Row 1 - Col 1*/%>
        <img class="pagelogo" alt="logo" src="web-ui-3\mba\css\app-icons\HYQueue-logo.svg">
      </section> <%/* Header content grid - Row 1 - Col 1*/%>

      <%/*##################
          # Title
          ##################*/%> 

      <section class="col-6"> <%/* Header content grid - Row 1 - Col 2*/%>
         <h1 class="pagetitle">
         <%if (tsp.renderWhatRoom == MBA.TeleCommRenderWhatRoom.INSIDE_ROOM) {%><%=tsp.roomTitle%><%} else {%><%=roomTitlePublic%><%}%>
         </h1>
      </section> <%/* Header content grid - Row 1 - Col 2*/%>
    </div> <%/* Header content grid - Row 1 */%>

    <div class="row"> <%/* Header content grid - Row 2 */%> 

      <%/*##################
          # System status
          ##################*/%>

      <section class="col-12">
        <div id="systemstatus" class="systemstatus">
            <%=(generateSessionJoinedFailedStatusMessageIfNeeded(tsp))%>
        </div>
      </section> 

      </div> <%/* Header content grid - Row 2 */%>

    </div> <%/* Header content grid */%> 
  </section><%/* Page grid - Row 1 - Column 1 */%>
</header> <%/* Page grid - Row 1 */%>

<%/*#################################################################################### 
    #                                      Main
    ####################################################################################*/%>

<main id="pagemain" class="pagemain row" role="main"> <%/* Page grid - Row 2 */%>
<section class="col-12"> <%/* Page grid - Row 2 - Column 1 */%>
<div class="container"> <%/* Main content grid */%> 

<%/*###################################### 
    #          Inside Room 
    ######################################*/%>

<%if (tsp.renderWhatRoom == MBA.TeleCommRenderWhatRoom.INSIDE_ROOM) {%>
 
<div class="row"> <%/* Main content grid - Row 1 */%>

<%/*#################
    # Streams 
    ##################*/%> 

<div class="col-12 mb-2"> <%/* Main content grid - Row 1 - Col 1*/%>
    <button id="toggleparticipantsviewbtn" type="button" class="btn btn-primary btn-sm">Switch View</button>
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

<%/*#################
    # Custom content
    ##################*/%> 

<section class="col-12"> <%/* Main content grid - Row 2 - Col 1*/%>
<%=tsp.roomContent%>
</section> <%/* Main content grid - Row 2 - Col 1*/%>
</div>  <%/* Main content grid - Row 2 */%>

<div class="row"> <%/* Main content grid - Row 3 */%>

<%/*#################
    # File Share
    ##################*/%> 

<section class="col-12"> <%/* Main content grid - Row 3 - Col 1*/%>
<h3>Files For This Session</h3>
<div id="meetingfiles" class="container">
<%=tsp.fileShareContent%>
</div>
</section> <%/* Main content grid - Row 3 - Col 1*/%>
</div> <%/* Main content grid - Row 3 */%>

<%if (showServiceRecordOptions == true) {%>
<div class="row"> <%/* Main content grid - Row 4 */%>
<%/*#################
    # Service record
    ##################*/%> 
<section class="col-12"> <%/* Main content grid - Row 4 - Col 1*/%>
<h3>Service Records</h3>
<div class="table-responsive">
<table id="tblSvcRecords" class="table table-hover table-sm">
<thead id="tblSvcRecordsHead" class="thead-dark">
<tr>
<th>
<span>Absent?</span>
</th>
<th>
<span>Patient</span>
</th>
<th>
<span>Plan Type</span>
</th>
<th>
<span>Start Time</span>
<input data-copy-down="startTime" class="form-control form-control-sm" type="time" value="<%=tsp.meetingStartTime24HrStr%>"/>
<button data-copy-down="startTime" type="button" class="btn btn-primary btn-sm">Copy</button>

</th>
<th>
<span>Minutes</span>
<input data-copy-down="numMins" class="form-control form-control-sm" type="number" min="0" value="<%=tsp.meetingDurationInMins%>"/>
<button data-copy-down="numMins" type="button" class="btn btn-primary btn-sm">Copy</button>

</th>
<th>
<span>Notes</span>
</th>
</tr>
</thead>
<tbody id="tblSvcRecordsBody">
<%foreach (var pp in patientParticipants){%>
<tr>
<td>
    <select name="patAbsent" class="form-control form-control-sm">
    <option value="0">No</option>
    <option value="1">Yes</option>
    </select>
</td>
<td><input name="patID" type="hidden" value="<%=pp.entityID%>"/><%=pp.name%></td>
<td>
    <select name="iep" class="form-control form-control-sm">
    <option value="1">IEP / IFSP</option>
    <option value="0">Other (IHP, 504, Counseling, etc.)</option>
    </select>
</td>
<td><input name="startTime" class="form-control form-control-sm" type="time" value="<%=tsp.meetingStartTime24HrStr%>"/></td>
<td><input name="numMins" class="form-control form-control-sm" type="number" min="0" value="<%=tsp.meetingDurationInMins%>"/></td>
<td><textarea name="notes" class="form-control form-control-sm" rows="1"></textarea></td>
</tr>
<%} /* Patient partipants*/%>
</tbody>
</table>
</div>

<form id="frmSvcRecords" data-telecomm-remote-update="1" method="post" action="telecomm_health.asmx/savesvcrecs">   
  <textarea id="details" style="display:none;" name="details"></textarea>
  <h6><%=Messages.ATTEST_STATEMENT %></h6>
  <button id="butSubSvcRecords" class="btn btn-primary" type="submit">Save Service Records</button>
</form>
<script>
   <%/* Note this is a global */%>
  latestServiceRecordDataRecorded = '<%=tsp.latestRoomFormDataJSONRecorded%>';
</script>
</section> <%/* Main content grid - Row 4 - Col 1*/%>
</div> <%/* Main content grid - Row 4 */%>
<%} /* Service Record Options */%>

<%} /* Inside room */ else { %>

<%/*###################################### 
    #          Outside room 
    ######################################*/%>

<div class="row"> <%/* Main content grid (outside) - Row 1 */%>

<%/*#################
    # Join Form
    ##################*/%> 

<section class="col-sm-6 col-12"> <%/* Main content grid (outside) - Row 1 - Col 1*/%>
<Spedmon:TeleCommFormJoin ID="formjoin" joinButtonLabel="Join Session" runat="server"/>  
</section> <%/* Main content grid (outside) - Row 1 - Col 1*/%>

<%/*#################
    # Instructions
    ##################*/%> 

<section class="col-sm-6 col-12"> <%/* Main content grid (outside) - Row 1 - Col 2*/%>

<h3 class="login-consent-title">By joining this session I agree and consent to the following conditions:</h3>

<ol class="login-consent-conditions">
  <li>I understand that the session/meeting is required to verify my identity verbally even though they know who I am and I agree to identify myself</li>
  <li>I understand that I should only attend sessions through this platform from a secure and private location, should utilize headphones to the extent possible, and should not use any device to record or otherwise capture the session</li>
  <li>I acknowledge that as with any group therapy session environment, I will receive confidential information about the other participants and such other participants will receive confidential information about me</li>
  <li>I understand that even though the hosting platform for these sessions is HIPAA/FERPA-compliant, there are potential privacy issues with using telemedicine and I must also do my part in respecting the privacy of others</li>
  <li>If I am not able to attend the session from a private location and/or utilize headphones, I understand that the group leader may ask me to leave the session</li>
  <li>I also understand that the service provider cannot guarantee that these guidelines will be adhered to by all group therapy participants and is not responsible for the actions of the other group therapy participants</li>
</ol>
</section> <%/* Main content grid (outside) - Row 1 - Col 2*/%>
</div> <%/* Main content grid (outside) - Row 1 */%>

<%} /* Outside room */%> 

</div> <%/* Main content grid */%> 
</section> <%/* Page grid - Row 2 - Column 1 */%>
</main> <%/* Page grid - Row 2 */%>

<%/*#################################################################################### 
    #                                    Footer
    ####################################################################################*/%>

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


</div> <%/* Page grid */%>

<div id="browsernotsupported" style="display:none"></div>
