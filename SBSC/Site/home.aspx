<%@Page Language="C#" CodeBehind="home.aspx.cs" Inherits="Spedmon.home"%>

<%/************************/%>
<%/* Home                 */%>
<%/* Private Start Page   */%>
<%/************************/%>


<%/*********************************************************************************/%>
<%/* Quick Start                                                                   */%>
<%/*********************************************************************************/%>

<div class="container-fluid">
<div class="row">

<div class="col-12">

<h1 class="welcome-message welcome-message-greeting">
Hello, <%=this.userName%>
</h1>

<h2 class="welcome-message welcome-message-greeting-title-org">
<%=this.userTitle%>, <%=this.userOrganization%>
</h2>

<%if(showPatientSearch == true){%>        

        <div class="text-center mt-3">
        
        <Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server" />
        
        <Spedmon:DataEntryRowSelectPatient
            ID                   = "selectPatient" 
            entityControlID      = "patid"  
            rowLabel             = "Patient (Last,First)"
            dataEntryRowRenderAs = "FIELD"
            selectTitle          = "Enter Last, First"
            showAddNew           = "true"
            showClearSelection   = "true"
            onSpedmonInputData   = "fnOpenSelectedPatientProfileScreenMedicalHistory()"            
            runat                = "server">
         </Spedmon:DataEntryRowSelectPatient>
         </div>
<%}%>
<% else if(showPatPersonSearch == true){  %>        

       <div class="text-center mt-3">
        
           <Spedmon:DataEntryBoxSearch
                ID                 = "term"
                name               = "term"
                label              = "Search For Parent/Guardians By Email or Name"
                fireSpedmonInput   = "false"
                title              = "Enter search term then click search icon.  Opens a new window."
                size               = "20"
                runat              = "server" />

           <Spedmon:DataEntryButton
                ID="butdosearch"
                title="Click here to search (Open a New Window)"
                iconOnly="true"
                faIcon="fa fa-search text-success fa-2x"
                assignBsCssClasses="false"
                onclick="openPatientPersonResults()"
                runat="server"   />

       </div>

<% }  %>

</div> <!-- col -->

</div> <!-- row -->
<div class="row">

        <div class="order-md-1 order-3 col-12 col-md-4 col-xl-3 offset-xl-1 mt-3"> <%--First column--%>
           
            <%--Potential Reimbursements--%>
            <% if (!hideCdeComplianceSummary || !hideParentConsentActionItem || !hideMissingAssmtsActionItem || !hideServiceAuthorizationActionItem || !hideDeptHeadWidget) {%>

            <div class="mba-action-items-container p-0 pt-1 pl-1 pr-1 mt-3">
                <h4 class="col-12 text-center">Service Compliance</h4>
              
                <% if (!hideDeptHeadWidget) { %>
                    
                    <div class="text-center">
                    
                      <Spedmon:LinkInternal
                        ID                 = "gotoDeptSvcsReview"
                        title              = "Click here to goto the department services review screen"
                        faClass            = "fa fa-link"
                        openNew            = "false"
                        subWindow          = "false"
                        runat              = "server" />
                      
                      <br />

                      <Spedmon:LinkInternal
                        ID                 = "gotoPracEfficiency"
                        title              = "Click here to goto the service opportunity management screen"
                        faClass            = "fa fa-link"
                        openNew            = "false"
                        subWindow          = "false"
                        runat              = "server" />
                      
                    </div>
                <% } %>

                <Spedmon:ActionItemTotalNumAmt
                    ID                 = "actionItemParentConsent"
                    title              = "Parent Consent"
                    urlBaseTotalNumAmt = "potential_lost_reimbursement_action_items.asmx/getparentconsent"
                    runat              = "server"/>

                <Spedmon:ActionItemTotalNumAmt
                    ID                 = "actionItemMissingAssmts"
                    title              = "Assessements for Upcoming IEP(s) and Missing Assessments"
                    urlBaseTotalNumAmt = "potential_lost_reimbursement_action_items.asmx/getmissingassmts"
                    runat              = "server"/>

                <Spedmon:ActionItemTotalNumAmt
                    ID                 = "actionItemMissingSpEdTreatments"
                    title              = "Missing Promised Services"
                    urlBaseTotalNumAmt = "potential_lost_reimbursement_action_items.asmx/getmissingspedtreatments"
                    runat              = "server"/>

                <Spedmon:ActionItemTotalNumAmt
                    ID                 = "actionItemSvcAuth"
                    title              = "Service Authorization"
                    urlBaseTotalNumAmt = "potential_lost_reimbursement_action_items.asmx/getserviceauthorization"
                    runat              = "server"/>
            
                <% if (!hideCdeComplianceSummary) {%>               
                  <div id="cdecompliancesummary" class="mt-2 mb-2"></div>
                <% } %>
  
            </div>
            <%}%>

            <%--Performance Widget--%>
            <% if ( !hidePerformanceWidget ) {%>
                <div class="mba-action-items-container col-12 pt-1 pl-1 pr-1 mt-3" style="height:350px; overflow:hidden;">
                    <Spedmon:PCalPerformanceWidget ID="pcalPerformanceWidget" runat= "server"/>
                </div>
            <%}%>

            <%--Calendar Widget--%>
            <% if (!hideCalendarWidget) {%>

               <div class="mba-action-items-container col-12 p-3 mt-3">

                   <%--For LEA Coordinators and PCal staff, we show a google calendar--%>

                    <%if (uInfo.userRole.ToLower() == Constants.ROLE_LEA_CORDINATOR || uInfo.pcalStaff)
                        { %>
                            <div class="mba-google-calendar-widget-container">
                                <iframe class="w-100 h-100" src="https://calendar.google.com/calendar/embed?height=600&amp;wkst=1&amp;bgcolor=%23ffffff&amp;ctz=America%2FLos_Angeles&amp;mode=AGENDA&amp;src=bGVhcm5pbmdAcHJhY3RpLWNhbC5jb20&amp;color=%23039BE5"></iframe>
                            </div>

                    <%--For others, we show our custom calendar--%>

                    <%}else {%>
                            <Spedmon:calendarWidget ID="calendarWidget" title="Record for Scheduled Services" defaultViewMode="agenda" runat= "server"/>
                   <%} %>
               </div>
            <%}%>

        </div> <%--First column End--%>

        <div class="order-md-2 order-1 col-12 col-md-4 mt-3 quick-links-container"> <%--Second column--%>

            <%--notifications and messages widget--%>
             <div class="mba-action-items-container d-flex justify-content-center p-1 mt-3 mba-max-height-300">
                <spedmon:NotificationsAndMessagesWidget ID = "spedmonUserNotificationsAndMessages" title = "Notifications & Messages" runat = "server"/>
            </div>

            <%-- Quick Links --%>
            <div class="mba-action-items-container col-12 mt-3 p-0">
                <Spedmon:UserQuickLinks
                                ID                 = "spedmonUserQuickLinksWidget"
                                title              = "My Quick Links"
                                runat              = "server"/>
            </div>

        </div> <%--Second column end--%>


        <div class="order-md-3 order-2 col-12 col-md-4 col-xl-3 mt-3"><%--Third column--%>

            <% if ( ! hideAnnouncementsAndTeachMe ) { %>
              <%--Announcements--%>
              <div class="mba-action-items-container col-12 mt-3 p-0">
                  <Spedmon:announcementsWidget ID="announcements" title="Announcements / Teach Me" runat= "server"/>
             </div>
           <% } 
              if ( ! hideGoalsProgressWidget ) { %>
              <div class="mba-action-items-container col-12 mt-3 p-0">
                <Spedmon:PCalPerformanceWidget ID="goalsProgressWidget" runat= "server"/>
             </div>
           <% } %>

        </div><%--Third column end--%>


    </div>
</div>

<script type="text/javascript">

    let $cdeComplianceSummaryWidget = null;

    function openPatientPersonResults() {
        let _term = $('#term').val();
        let reqUrl = '<%=Spedmon.PatientPersons.URL_USER_ALL_VIEW_BASE("")%>' + _term;            
        return MBA.ComponentCommon.fnOpenWindow(reqUrl, null);
    };

    function fnOpenSelectedPatientProfileScreen (patScreenTabID) {
        let clientid = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let patid    = $('#<%=Constants.PARM_PATIENT_ID%>').val();
        if (!clientid) return;
        if (!patid)    return;
        let urlBase = '<%=patEditUrlBase%>' + patid;
        let parms    = [];
        parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>', clientid));
        if (patScreenTabID) parms.push(MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_TAB_TO_OPEN%>', patScreenTabID));
        let reqUrl = MBA.ComponentCommon.fnBuildUrl(urlBase, true, parms);        
        return MBA.ComponentCommon.fnOpenTab(reqUrl);
    };

    function fnOpenSelectedPatientProfileScreenMedicalHistory() {
        return fnOpenSelectedPatientProfileScreen('tab-medical-history');
    }

    function initCdeComplianceSummaryWidget() {

        let opts = {};
        opts.showHeader = false;
        opts.hideStatusSectionWhenNotInUse = true;
        opts.containerNoPadding = true;
        opts.containerNoBoxShadow = true;
        opts.containerNoBorder = true;
        opts.bootStrapTable = false;
        opts.bootStrapBorderlessTable = true;
        opts.label = 'CDE Implementation';
        opts.urlSessionExpiredLink = '<%=MBA.Credential.generateSessionExpiredLink()%>';
        opts.requestDataUrlBase = '<%=Spedmon.CdeComplianceCommon.WEB_SVC_CDE_COMPLIANCE_OVERALL_SUMMARY_FOR_A_PRAC()%>';
        opts.autoSetUpdateRequestDataParametersFromRequestDataFieldNames = false;
        opts.instructionsEnabled = false;
        opts.title = '';
        opts.subTitleProgressLabel = '';
        opts.subTitleProgressBar = '';
        opts.progressDataHasActionURL = true;
        opts.actionURLOpenWindow = false;
        opts.useChartCellOrColPctWidth = true;
        opts.useChartSmall = true;
        opts.fnGenerateProgressLabelTitleAttributeText = function (progressDataObj) {
            return 'All patients on my caseload where a CALPADS service has been assigned. Click here for more details.';
        };

        opts.fnGenerateProgressBarTitleAttributeText = function (progressDataObj) {
            return progressDataObj.value + '% of expected minutes to date have been provided.';
        };

        opts.fnGenerateProgressPercentTitleAttributeText = function (progressDataObj) {
            return 'Total number of minutes satisfied to date / expected to date : '
                + progressDataObj.additionalData2
                + ' / '
                + progressDataObj.additionalData1;
        };

        $($cdeComplianceSummaryWidget).MBA_ActionItemProgressBarChart(opts);
        $($cdeComplianceSummaryWidget).MBA_ActionItemProgressBarChart('requestDataParameterSetOrUpdate', (MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_CLIENT_ID%>', '<%=userClientID%>')));
        $($cdeComplianceSummaryWidget).MBA_ActionItemProgressBarChart('requestDataParameterSetOrUpdate', (MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_PRACTITIONER_ID%>', '<%=userPracID%>')));
        $($cdeComplianceSummaryWidget).MBA_ActionItemProgressBarChart('requestDataParameterSetOrUpdate', (MBA.ComponentCommon.fnCreateNameValueObject('<%=Constants.PARM_USE_MINS_PER_FREQ_ASSIGNED%>', 'N')));

    }

    $(document).ready(function () {
        $cdeComplianceSummaryWidget = $('#cdecompliancesummary');
        if ($cdeComplianceSummaryWidget.length == 0) return;
        initCdeComplianceSummaryWidget();
        $($cdeComplianceSummaryWidget).MBA_ActionItemProgressBarChart('getData');                
    });
</script>
