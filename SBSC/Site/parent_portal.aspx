<%@ Page Language="C#" CodeBehind="parent_portal.aspx.cs" Inherits="Spedmon.parent_portal" %>

<%/****************************************/%>
<%/* Portal                               */%>
<%/* Private Parent Patient Portal page   */%>
<%/****************************************/%>
<%if (this.InitPageOK == true)
    { %>
<Spedmon:HiddenInput ID="recid" name="recid" title="recid" runat="server" />
<Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server" />
<Spedmon:HiddenInput ID="patid" name="patid" title="patid" runat="server" />
<Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server" />
<Spedmon:HiddenInput ID="patperid" name="patperid" title="patperid" runat="server" />
<Spedmon:HiddenInput ID="notenamespace" name="notenamespace" title="notenamespace" runat="server" />
<Spedmon:HiddenInput ID="notesource" name="notesource" title="notesource" runat="server" />
<Spedmon:HiddenInput ID="referringbyuserid" name="referringbyuserid" title="referringbyuserid" runat="server" />
<Spedmon:HiddenInput ID="active" name="active" title="active" runat="server" />
<Spedmon:HiddenInput ID="dos" name="dos" title="dos" runat="server" />
<Spedmon:HiddenInput ID="patientHomePlaceID" name="patientHomePlaceID" title="patientHomePlaceID" runat="server" />

<%/*********************************************************************************/%>
<%/* Quick Start                                                                   */%>
<%/*********************************************************************************/%>

<div class="container-fluid p-0">
    <section class="portal-parent-new-banner">
        <div class="portal-parent-new-banner__left">
            <div class="portal-parent-new-banner__icon-wrap">
                <div class="portal-parent-new-banner__main-icon">
                    <i class="fas fa-hands-helping"></i>
                </div>
            </div>

            <div class="portal-parent-new-banner__text">
                <h1><%=clientName %></h1>
                <p>Manage health information, messages, and forms through one secure portal.</p>                
            </div>
        </div>

        <div class="portal-parent-new-banner__right">
            <div class="portal-parent-new-banner__art">
                <span class="art-dot-grid art-dot-grid--top"></span>
                <span class="art-dot-grid art-dot-grid--mid"></span>
                <span class="art-circle art-circle--lg"></span>
                <span class="art-circle art-circle--sm"></span>
                <span class="art-wave art-wave--one"></span>
                <span class="art-wave art-wave--two"></span>
                <span class="art-spark art-spark--one"></span>
                <span class="art-spark art-spark--two"></span>

                <div class="art-medical-icon">
                    <div class="art-heart-wrap">
                        <i class="far fa-heart art-heart-outline"></i>
                        <i class="fas fa-plus art-heart-plus"></i>
                    </div>

                    <div class="art-hand-wrap">
                        <i class="fas fa-hand-holding-heart art-hand-heart"></i>
                    </div>
                </div>
            </div>
        </div>
    </section> 

    <div class="parent_portal_patient_data">
        <!-- Row 1: Basic Information -->
        <div class="row g-4 mb-4">
            <div class="col-12 col-md-6 col-lg-3">
                <div class="patient-data-field">
                    <label class="patient-data-label">Name</label>
                    <input id="txtName" type="text" readonly />
                </div>
            </div>
            <!-- Wrapper único para Email + Phone + Address (no altera el grid) -->
            <div id="portalContactAddressWrapper" style="display: contents;">
                <!-- Email -->
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="patient-data-field bell-field" data-bell-required="true">
                        <label class="patient-data-label">Email</label>
                        <div class="patient-data-input-wrapper portal-wrapper-email">
                            <input id="txtEmail" type="email" />
                        </div>
                    </div>
                </div>

                <!-- Phone -->
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="patient-data-field bell-field" data-bell-required="true">
                        <label class="patient-data-label">Phone</label>
                        <div class="patient-data-input-wrapper portal-wrapper-phone">
                            <input id="txtPhone" type="tel" />
                        </div>
                    </div>
                </div>

                <!-- Address (campos pequeños en una fila) -->
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="patient-data-field bell-field" data-bell-required="true">
                        <label class="patient-data-label">Address</label>
                        <div class="d-flex gap-2 flex-wrap" id="divAddressInfo">
                            <input id="txtStreet1" type="text" placeholder="Street 1" class="flex-grow-1" />
                            <input id="txtStreet2" type="text" placeholder="Street 2" class="flex-grow-1" />
                            <input id="txtCity" type="text" placeholder="City" style="width: 110px;" />
                            <input id="txtState" type="text" placeholder="State" maxlength="2" style="width: 60px;" />
                            <input id="txtZip5" type="text" placeholder="Zip5" maxlength="5" inputmode="numeric" style="width: 90px;" />
                            <input id="txtZip4" type="text" placeholder="Zip4" maxlength="4" inputmode="numeric" style="width: 90px;" data-bell-optional="true" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Row 2: Demographics -->
        <div class="row g-4 mb-4">
            <div class="col-12 col-md-6 col-lg-3">
                <div class="patient-data-field">
                    <label class="patient-data-label">Age</label>
                    <input id="txtAge" type="text" readonly />
                </div>
            </div>
            <div class="col-12 col-md-6 col-lg-3">
                <div class="patient-data-field">
                    <label class="patient-data-label">Gender</label>
                    <input id="txtGender" type="text" readonly />
                </div>
            </div>
        </div>

        <!-- Insurance Section (collapsible) -->
        <div class="insurance-section insurance-collapsible-section">
            <div id="insuranceToggle" class="insurance-title insurance-collapsible-header">
                <i class="fas fa-chevron-circle-right insurance-toggle-icon"></i>
                <span>Insurance Information</span>
            </div>

            <div id="insuranceCollapseBody" class="insurance-collapsible-body" style="display: none;">
                <div class="row g-4 align-items-start insurance-consent-layout">
                    <div class="col-12 col-xl-7">
                        <div class="insurance-required bell-field" data-bell-required="true">
                            <div id="insurance-autosave-hint" class="small" style="display: none;">
                                Secondary insurance will be saved once all required fields are completed.
                            </div>
                            <div id="insuranceCards" class="insurance-cards-column"></div>
                        </div>
                    </div>

                    <div class="col-12 col-xl-5">
                        <div class="consent-inline-section consent-inline-section-mockup">
                            <div class="row g-3 align-items-start">
                                <div class="col-12 col-lg-7">
                                    <div id="portal-consent-inline-options" class="consent-inline-options-two-col">
                                        <div class="consent-inline-option-row">
                                            <div class="checkbox-wrapper-19 me-2">
                                                <input type="radio" id="consent_yes_inline" name="portal_consent_inline" value="1" />
                                                <label class="check-box" for="consent_yes_inline"></label>
                                            </div>
                                            <label for="consent_yes_inline" class="consent-inline-label-mockup">
                                                <span class="consent-inline-strong">I consent</span> to the release of my child’s health records and/or access to benefit information for the purpose of billing
                                           
                                            </label>
                                        </div>

                                        <div class="consent-inline-option-row">
                                            <div class="checkbox-wrapper-19 me-2">
                                                <input type="radio" id="consent_no_inline" name="portal_consent_inline" value="0" />
                                                <label class="check-box" for="consent_no_inline"></label>
                                            </div>
                                            <label for="consent_no_inline" class="consent-inline-label-mockup">
                                                <span class="consent-inline-strong">I DO NOT consent</span> to the release of my child’s health records and/or access to benefit information for the purpose of billing
                                           
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 col-lg-5">
                                    <div class="consent-signature-block">
                                        <label class="consent-signature-label">Please Sign Below</label>
                                        <canvas id="responder-signature-img-inline" class="consent-signature-canvas"></canvas>
                                        <textarea id="responder-signature-img-data-inline" style="display: none;"></textarea>
                                    </div>
                                </div>
                            </div>

                            <div class="row mt-2 g-2 consent-inline-buttons-row">
                                <div class="col-12 col-lg-6">
                                    <button type="button" id="btn-clear-consent-inline" class="btn consent-inline-btn consent-inline-btn-clear w-100">
                                        CLEAR               
                                    </button>
                                </div>
                                <div class="col-12 col-lg-6">
                                    <button type="button" id="btn-submit-consent-inline" class="btn consent-inline-btn consent-inline-btn-submit w-100">
                                        SUBMIT               
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="d-flex justify-content-end align-items-center">
                    <button id="btnContact" type="button"
                        class="btn patient-contact-btn rounded-pill"
                        title="Personal Contacts">
                        <i class="fas fa-user-friends"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div id="parent-portal-tabs" class="p-2 m-2">
        <ul>
            <li><a href="#tab_messages">Messages</a></li>
            <li><a href="#tab_treatments">Treatments or Therapy</a></li>
            <%--<li><a href="#tab_referral">Referral Request</a></li>--%>
            <li><a href="#tab_shared_files">Files</a></li>
        </ul>
        <div id="tab_messages">
            <div class="container-fluid">
                <div class="parent-portal-journal">
                    <button id="btnMyJournal" class="btnJournal" type="button" title="My Journal">
                        <i class="fas fa-book-reader"></i>
                        My Journal
                    </button>
                </div>

                <div class="mba-portal-messages-widget p-1 mt-3">
                    <Spedmon:ParentPortalMessagesWidget ID="spedmonUserNotificationsAndMessages" title="Notifications & Messages" runat="server" />
                </div>
            </div>
        </div>
        <div id="tab_treatments">
            <div class="upcoming-visits-container">
                <div class="upcoming-visits-list">
                </div>
            </div>

            <div id="datamanagerowsrestviewservicerecords" class="container-fluid">
                <div class="section-title m-2">Visit History</div>
                <div class="row">
                    <div class="col-12">
                        <div id="restviewservicerecords"></div>
                    </div>
                </div>
            </div>
        </div>
        <%--<div id="tab_referral">
            <div class="container-fluid">
                <div class="form-content">
                    <div class="section">
                        <div class="section-title">
                            <i class="fas fa-user-md"></i>
                            Receiving Practitioner Information
                       
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="pat_ref_prac_name">
                                    <i class="fas fa-user"></i>Practitioner Name
                               
                                </label>
                                <input type="text" id="pat_ref_prac_name" class="form-control" placeholder="Enter practitioner name" required>
                            </div>
                            <div class="form-group">
                                <label for="pat_ref_prac_agency">
                                    <i class="fas fa-building"></i>Agency/Organization
                               
                                </label>
                                <input type="text" id="pat_ref_prac_agency" class="form-control" placeholder="Enter agency name" required>
                            </div>
                            <div class="form-group">
                                <label for="pat_ref_prac_email">
                                    <i class="fas fa-envelope"></i>Email Address
                               
                                </label>
                                <input type="email" id="pat_ref_prac_email" class="form-control" placeholder="practitioner@example.com" required>
                            </div>
                            <div class="form-group">
                                <label for="pat_ref_prac_phone">
                                    <i class="fas fa-phone"></i>Phone Number
                               
                                </label>
                                <input type="tel" id="pat_ref_prac_phone" class="form-control" placeholder="(555) 123-4567" required>
                            </div>
                        </div>
                    </div>

                    <div class="section">
                        <div class="section-title">
                            <i class="fas fa-user-shield"></i>
                            Parent/Guardian Authorization
                       
                        </div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="pat_ref_parent_name_lbl">
                                    <i class="fas fa-user-friends"></i>Parent/Guardian
                               
                                </label>
                                <input id="pat_ref_parent_name_datalist" list="pat_ref_parent_name" class="form-control" placeholder="Type or click to select…" autocomplete="off" required />
                                <datalist id="pat_ref_parent_name" class="form-control" hidden>
                                </datalist>
                            </div>
                            <div class="form-group">
                                <label for="pat_ref_parent_relationship">
                                    <i class="fas fa-heart"></i>Relationship
                               
                                </label>
                                <input type="text" id="pat_ref_parent_relationship" class="form-control" placeholder="Relationship" />
                            </div>
                            <div class="form-group">
                                <label for="pat_ref_parent_email">
                                    <i class="fas fa-envelope"></i>Email Address
                               
                                </label>
                                <input type="email" id="pat_ref_parent_email" class="form-control" placeholder="parent@example.com" />
                            </div>
                            <div class="form-group">
                                <label for="pat_ref_parent_phone">
                                    <i class="fas fa-phone"></i>Phone Number
                               
                                </label>
                                <input type="tel" id="pat_ref_parent_phone" class="form-control" placeholder="(555) 123-4567" />
                            </div>
                        </div>
                    </div>

                    <div class="section">
                        <div class="section-title">
                            <i class="fas fa-clipboard-list"></i>
                            Referral Details
                       
                        </div>
                        <div class="form-grid">
                            <div class="form-group textarea-group">
                                <label for="pat_ref_reason_or_impression">
                                    <i class="fas fa-edit"></i>Reason for Referral and Patient Impression
                               
                                </label>
                                <textarea id="pat_ref_reason_or_impression" class="form-control" placeholder="Provide detailed information about the reason for referral..."></textarea>
                            </div>
                            <div class="form-group" style="display: none;">
                                <label for="pat_ref_select_attach">
                                    <i class="fas fa-paperclip"></i>Attachments to Include
                               
                                </label>
                                <select id="pat_ref_select_attach" class="form-control" multiple>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="section">
                        <div class="section-title">
                            <i class="fas fa-check-square"></i>
                            Information to Include in Referral
                       
                        </div>
                        <div class="checkbox-grid">
                            <div class="checkbox-item" data-checkbox="pat_ref_diagnosis">
                                <input type="checkbox" id="pat_ref_diagnosis">
                                <i class="fas fa-stethoscope"></i>
                                <span class="checkbox-label">DSM-5 or ICD-10 Diagnosis</span>
                            </div>
                            <div class="checkbox-item" data-checkbox="pat_ref_recent_screenings">
                                <input type="checkbox" id="pat_ref_recent_screenings">
                                <i class="fas fa-search"></i>
                                <span class="checkbox-label">Recent Screenings</span>
                            </div>
                            <div class="checkbox-item" data-checkbox="pat_ref_medications">
                                <input type="checkbox" id="pat_ref_medications">
                                <i class="fas fa-pills"></i>
                                <span class="checkbox-label">Current Medications</span>
                            </div>
                            <div class="checkbox-item" data-checkbox="pat_ref_direct_svc_history">
                                <input type="checkbox" id="pat_ref_direct_svc_history">
                                <i class="fas fa-history"></i>
                                <span class="checkbox-label">Direct Service History</span>
                            </div>
                            <div class="checkbox-item" data-checkbox="pat_ref_nonconfid_session_notes">
                                <input type="checkbox" id="pat_ref_nonconfid_session_notes">
                                <i class="fas fa-file-alt"></i>
                                <span class="checkbox-label">Non-Confidential Session Notes</span>
                            </div>
                            <div class="checkbox-item" data-checkbox="pat_ref_confid_session_notes">
                                <input type="checkbox" id="pat_ref_confid_session_notes">
                                <i class="fas fa-lock"></i>
                                <span class="checkbox-label">Confidential Session Notes</span>
                            </div>
                        </div>
                    </div>

                    <div class="submit-section">
                        <button type="button" id="pat_ref_save_btn" class="submit-btn">
                            <i class="fas fa-paper-plane"></i>
                            Submit Referral
                       
                        </button>
                        <div class="success-checkmark" id="success-animation"></div>
                    </div>
                </div>
            </div>
        </div>--%>
        <div id="tab_shared_files">
            <div class="container-fluid">
                <div id="datamanagerowsrestviewstoredfiles" class="container-fluid">
                    <div class="section-title m-2">Files</div>
                    <div class="row">
                        <div class="col-12">
                            <div id="restviewstoredfiles"></div>
                            <!-- rest view -->
                        </div>
                        <!-- col -->
                    </div>
                    <!-- row -->
                </div>
                <!-- container -->
            </div>
        </div>
    </div>
    <%if (uInfo.associatedPatientPersons != null && uInfo.associatedPatientPersons.Count > 1) { %>
    <div class="portal-patient-pager">
        <div class="portal-patient-pager__pill">
            <button id="btnPrev" type="button"
                    class="portal-patient-pager__btn"
                    disabled title="Previous patient"
                    aria-label="Previous patient">
                &#8249;
            </button>
            <div class="portal-patient-pager__divider"></div>
            <span class="portal-patient-pager__label">
                Patient <span id="pagerIndex">1</span> of <span id="pagerTotal">0</span>
            </span>
            <div class="portal-patient-pager__divider"></div>
            <button id="btnNext" type="button"
                    class="portal-patient-pager__btn"
                    disabled title="Next patient"
                    aria-label="Next patient">
                &#8250;
            </button>
        </div>
    </div>
    <%} %>
</div>

<div id="dlgPersonalContacts" style="display: none;">
    <div id="datamanagerowsrestviewpatientpersons">
        <div id="restviewpatientpersons"></div>
    </div>
</div>

<div id="dlgMyJournal" style="display: none">
    <div id="manageviewmyjournalcontainer" class="col-12 my-4 p-4">
        <div id="myjournalcomponentview">
        </div>
    </div>
</div>

<script type="text/javascript" src="third-party/signature-pad.min.js"></script>
<script type="text/javascript">
    const listPat = <%=PatientsJson%>;
    const patients = listPat || [];
    let currentPatientIndex = 0;
    let responderSigPadInline = null;
    let portalConsentDirty = false;
    let portalConsentSavedOnce = false;

    <%// --------------------------------------------------------------------------------------------------- %>

    function initTabs() {
        $("#parent-portal-tabs").MBA_Tabs({});
    };

    <%// --------------------------------------------------------------------------------------------------- %>

    <%--function initializeReferralForm() {
        let patid = $('#<%=Constants.PARM_PATIENT_ID%>').val();

        resetForm();

        if (patid) {
            loadParentAuthorizationOptions();
            //loadStoredFilesOptions();
        }
    };--%>

    <%// --------------------------------------------------------------------------------------------------- %>

    function initServiceRecordsView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PATIENT_ID: '<%=Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_ACTIVE: '<%=Constants.PARM_ACTIVE%>'
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

    <%// --------------------------------------------------------------------------------------------------- %>

    function initUpcomingVisits() {
        let clientid = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let patid = $('#<%=Constants.PARM_PATIENT_ID%>').val();
        let active = $('#<%=Spedmon.Constants.PARM_ACTIVE%>').val();

        let patientsList = patients || [];
        let $cont = $('.upcoming-visits-container');
        $cont.empty();

        $cont.append('<div class="section-title m-2"> Upcoming Visits</div>');
        var $list = $('<div class="upcoming-visits-list"></div>');
        $cont.append($list);

        var currentPatient = null;
        for (var i = 0; i < patientsList.length; i++) {
            if (patientsList[i].patID == patid) {
                currentPatient = patientsList[i];
                break;
            }
        }

        if (!currentPatient || !currentPatient.upcomingVisits || !currentPatient.upcomingVisits.length) {
            $cont.append('<div>No upcoming visits.</div>');
            return;
        }

        var visits = currentPatient.upcomingVisits;

        $.each(visits, function (i, v) {
            var dateStr = v.meetingDateStr;
            var timeStr = v.meetingTimeStr.trim();

            var providerName = v.facilitatorName;
            var providerTitle = v.facilitatorTitle;

            var providerFull = providerTitle
                ? (providerName + ', ' + providerTitle)
                : providerName;

            var visitText = dateStr + ' @ ' + timeStr + ' with ' + providerFull;

            var $row = $('<div class="upcoming-visit-row d-flex align-items-center mb-1"></div>');

            var $cancelIcon = $('<button class="upcoming-visit-icon-cancel btn"><i class="fa fa-times-circle fa-2x text-danger me-1"></i></button>').on('click', function () {

                let requestObj = {};
                requestObj['<%=Constants.PARM_EDIT_DEL_REASON%>'] = "";
                requestObj['<%=Constants.PARM_VALIDATE_REC%>'] = "true";
                requestObj['<%=Constants.PARM_REC_ID%>'] = v.id;
                let requestJSON = JSON.stringify(requestObj);
                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.TeleIEPSessions.URL_DELETE_IEP()%>', requestJSON, null)
                    .then(responseData => {
                    })
                    .catch(err => {
                        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                    });
            });

            var msgBtnId = 'upcoming_visit_msg_' + i;

            var $msgIcon = $(
                '<button type="button" id="' + msgBtnId + '" class="upcoming-visit-icon-msg btn">' +
                '<i class="fa fa-comments fa-2x text-primary me-1"></i>' +
                '</button>'
            ).on('click', function (e) {
                e.preventDefault();

                var $me = $(this);

                var msgOpts = {
                    clientID: clientid,
                    sendMessageAjaxURL: '<%=urlUserMessagesSave%>',
                    deleteMessageAjaxURL: '',
                    recipientSrcURL: '<%=urlRecipientSrc%>',
                    isSendOnly: true,
                    replyModeOn: false,
                    allowCloseWidget: true,
                    viewModeSubject: 'Upcoming visit - ' + dateStr + ' @ ' + timeStr,
                    textAreaPrefill: ''
                };

                if (v.facilitatorUserID) {
                    msgOpts.recipientIDs = String(v.facilitatorUserID);
                    msgOpts.recipientNames = providerName || '';
                }

                msgOpts.dialogDivID = msgBtnId + '_dialog_div';

                MBA.parentPortalMessagesWidget.fnRenderMessages($me, { opts: msgOpts });

                return false;
            });

            var $videoIcon = $('<button class="upcoming-visit-icon-video btn"><i class="fa fa-video fa-2x text-success me-2 "></i></button>').on('click', function () {
                $.spedmonWebUI.recOpJoinTeleCommMeetingUsingUserID(v.id, '<%=Spedmon.TeleIEPSessions.URL_JOIN_MEETING()%>', null);
            });

            var $text = $('<span class="upcoming-visit-text"></span>').text(visitText);

            $row.attr('data-session-id', v.id);
            $row.attr('data-clientid', clientid);
            $row.attr('data-patid', patid);
            $row.attr('data-active', active);

            $row.append($cancelIcon, $msgIcon, $videoIcon, $text);
            $cont.append($row);
        });
    }

     <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initMissingBells(containerSelector) {
        var $container = $(containerSelector || document);

        $container.find('.bell-field[data-bell-required="true"]').each(function () {
            updateBellForField($(this));
        });

        $container.off('.missingBells');

        $container.on(
            'input.missingBells change.missingBells click.missingBells',
            '.bell-field[data-bell-required="true"] input, ' +
            '.bell-field[data-bell-required="true"] select, ' +
            '.bell-field[data-bell-required="true"] textarea, ' +
            '.bell-field[data-bell-required="true"] button',
            function () {
                var $wrapper = $(this).closest('.bell-field');
                updateBellForField($wrapper);
            }
        );
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initMyJournal() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
            , PARM_NAME_PRAC_ID: '<%=Spedmon.Constants.PARM_PRACTITIONER_ID%>'
            , PARM_NAME_PAT_ID: '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
            , PARM_NAME_TERM: '<%=Spedmon.Constants.PARM_SEARCH_TERM%>'
            , PARM_NAME_REC_ID: '<%=Spedmon.Constants.PARM_REC_ID%>'
            , PARM_NAME_NOTENAMESPACE: '<%=Spedmon.Constants.PARM_NOTE_NAMESPACE%>'
            , PARM_NAME_NOTESOURCE: '<%=Spedmon.Constants.PARM_NOTE_SOURCE%>'
            , PARM_NAME_ACTIVE: '<%=Spedmon.Constants.PARM_ACTIVE%>'
            , containerCtrlID: 'manageviewmyjournalcontainer'
            , sessionTimeOutUrl: '<%=MBA.Credential.generateSessionExpiredLink()%>'
            , baseUrlView: '<%=Spedmon.NoteLibrarySavedNotes.URL_REST_VIEW_BASE()%>'
            , baseUrlSave: '<%=Spedmon.NoteLibrarySavedNotes.URL_SAVE_BASE()%>'
            , defaultPageRowOrder: '<%=Spedmon.NoteLibrarySavedNote.DEFAULT_PAGING_ORDER%>'
            , autoHidePageControls: true
            , enableScrollView: true
            , scrollViewUseCustomHeight: true
            , scrollViewCustomHeight: '15em'
        };
        MBA.UserPersonalNotesCommon.fnSetup('myjournalcomponentview', optsObj);
        return;
    };

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
            , scrollViewCustomHeight: '17em'
            , fnOnResponseViewFromServer: function (elem, responseData, $me, dataObj) {
                return;
            }
            , isPcalStaff:<%=isPcalStaffJSBoolStr%>
            , baseUrlInvitePortal: '<%=Spedmon.PatientPersons.URL_INVITE_PARENT_PORTAL_BASE()%>'
            , currentPage: 2
    };

        MBA.PatientPersonsCommon.fnSetup('restviewpatientpersons', optsObj);
        return;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initStoredFilesView() {

        let optsObj = {
            PARM_NAME_CLIENT_ID: '<%=Constants.PARM_CLIENT_ID%>'
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
            , webSvcFlagAsConfidentialUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_FLAG_AS_CONFIDENTIAL()%>'
            , webSvcEnableSharingWithPatientUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PATIENT()%>'
            , webSvcDisableSharingWithPatientUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PATIENT()%>'
            , webSvcEnableSharingWithParentUrl:'<%=Spedmon.StoredFiles.URL_WEB_SVC_ENABLE_SHARING_WITH_PARENT()%>'
            , webSvcDisableSharingWithParentUrl: '<%=Spedmon.StoredFiles.URL_WEB_SVC_DISABLE_SHARING_WITH_PARENT()%>'
            , currUserID: <%=rd.wu.usr.id%>
            , downloadHandlerPrivateBaseUrl: '<%=Spedmon.StoredFiles.URL_DOWNLOAD_HANDLER_PRIVATE_BASE()%>'
            , fnGetFileClassValue: function (dataObj) { return ''; }
            , fnGetDateRangeValue: function (dataObj) { return ''; }
            , showOKToShareWithPatient: false
            , showOKToShareWithParentGuardian: false

        };

        MBA.StoredFilesCommon.fnSetup('restviewstoredfiles', optsObj);
        return;
    };


    <%// --------------------------------------------------------------------------------------------------- %>

    function initConsentInline() {
        let $signatureTA = $('#responder-signature-img-data-inline');
        let submitAttempted = false;

        $('input[name="portal_consent_inline"]').prop('checked', false);
        $signatureTA.val('');

        setPortalConsentDirty(false);

        bindPortalConsentDirtyTracking();

        $('#btn-submit-consent-inline').off('click').on('click', function () {
            let consentChecked = $('input[name="portal_consent_inline"]:checked').length > 0;

            if (!consentChecked) {
                submitAttempted = true;
                $('#portal-consent-inline-options').addClass('consent-required');
                $('#consent_yes_inline').focus();
                return false;
            }

            if (responderSigPadInline && !responderSigPadInline.isEmpty()) {
                $signatureTA.val(responderSigPadInline.toDataURL());
            } else {
                $signatureTA.val('');
            }

            saveConsentFromPortal();
        });

        $('input[name="portal_consent_inline"]').off('change.consentRequired').on('change.consentRequired', function () {
            if (submitAttempted && $(this).is(':checked')) {
                $('#portal-consent-inline-options').removeClass('consent-required');
            }
        });

        $('#btn-clear-consent-inline').off('click').on('click', function () {
            if (responderSigPadInline) {
                responderSigPadInline.clear();
            }

            $signatureTA.val('');
            $('input[name="portal_consent_inline"]').prop('checked', false);
            $('#portal-consent-inline-options').removeClass('consent-required');
            submitAttempted = false;

            setPortalConsentDirty(false);
        });
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function setPortalConsentDirty(isDirty) {
        portalConsentDirty = isDirty;
        updatePortalConsentSubmitState();
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function updatePortalConsentSubmitState() {
        var $btn = $('#btn-submit-consent-inline');

        if (!$btn.length) return;

        $btn.prop('disabled', !portalConsentDirty);
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function setupConsentSignaturePad() {
        var canvas = document.getElementById('responder-signature-img-inline');
        if (!canvas || typeof SignaturePad === 'undefined') return;

        if (responderSigPadInline) {
            return;
        }

        responderSigPadInline = new SignaturePad(canvas);
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function loadParentAuthorizationOptions() {
        let clientid = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let patid = $('#<%=Constants.PARM_PATIENT_ID%>').val();

        let $datalist = $('#pat_ref_parent_name').empty();

        /****** set up ajax url ***********/
        var reqUrl = '<%=Spedmon.PatientPersons.URL_VIEW_SEL_BASE()%>';
        var reqData = "{'clientid':'" + clientid + "','patientid':'" + patid + "','term':'" + '' + "'}";

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let selRecs = responseData.rawData.SelRecs;
                if (selRecs) {
                    responseData.rawData.SelRecs.forEach(option => {
                        $datalist.append('<option value="' + option.label + '" data-relationship="' + option.recData6 + '" data-email="' + option.recData4 + '" data-phone="' + option.recData5 + '">' + option.label + '</option>');
                    });
                }
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    //function resetForm() {
    //    $('.priority-card').removeClass('selected');
    //    $('.priority-card input[type="checkbox"]').prop('checked', false);
    //    $('#tab_referral .form-control').val('');
    //    $('.checkbox-item').removeClass('checked');
    //    $('.checkbox-item input[type="checkbox"]').prop('checked', false);
    //}

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    //function populateParentInfo(selectedOption) {
    //    if (selectedOption.val()) {
    //        $('#pat_ref_parent_relationship').val(selectedOption.data('relationship'));
    //        $('#pat_ref_parent_email').val(selectedOption.data('email'));
    //        $('#pat_ref_parent_phone').val(selectedOption.data('phone'));
    //    }
    //}
    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    //function getStoredFilesInfo() {
    //    const selectedOptions = $('#pat_ref_select_attach option:selected');
    //    let result = {};

    //    selectedOptions.each(function () {
    //        const value = $(this).val();
    //        const text = $(this).text();
    //        result[value] = text;
    //    });

    //    return JSON.stringify(result);
    //}

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function renderInsurances(insList) {
        var $cards = $('#insuranceCards').empty();
        $cards.removeClass('two-insurance-columns');

        insList = insList || [];

        var primaryIns = null;
        var secondaryIns = null;

        for (var i = 0; i < insList.length; i++) {
            var ins = insList[i] || {};

            if (ins.primaryCarrier === true) {
                primaryIns = ins;
                break;
            }
        }

        for (var j = 0; j < insList.length; j++) {
            var ins2 = insList[j] || {};

            var isPrimary = ins2.primaryCarrier === true;

            if (!isPrimary) {
                secondaryIns = ins2;
                break;
            }
        }

        if (primaryIns && secondaryIns && primaryIns.id && secondaryIns.id && primaryIns.id == secondaryIns.id) {
            secondaryIns = {};
        }

        if (primaryIns) {
            primaryIns.primaryCarrier = 1;
        }

        if (secondaryIns) {
            secondaryIns.primaryCarrier = 0;
        }

        if (patients && patients[currentPatientIndex]) {
            patients[currentPatientIndex].insurance = [
                primaryIns || {},
                secondaryIns || {}
            ];
        }

        $cards.addClass('two-insurance-columns');
        $cards.append(buildInsuranceCard(primaryIns || {}, 0, 'Primary'));
        $cards.append(buildInsuranceCard(secondaryIns || {}, 1, 'Secondary'));

        fillInsuranceCarrierSelects();
        updateBellForField($('.insurance-required.bell-field'));
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function buildInsuranceCard(ins, idx, labelText) {
        ins = ins || {};

        function safeVal(v) {
            return (v || '').toString().replace(/"/g, '&quot;');
        }

        var insId = safeVal(ins.id);
        var carrierIdVal = safeVal(ins.insuranceCarrierID);
        var carrierNameVal = safeVal(ins.insuranceCarrierName);
        var policyVal = safeVal(ins.ssid);
        var groupVal = safeVal(ins.policyGroupID);
        var holderVal = safeVal(ins.policyHolderName);
        var benfName = safeVal(ins.beneficiaryFirstName);
        var benfLastN = safeVal(ins.beneficiaryLastName);

        var insuranceRole = labelText.toLowerCase();

        var html = '';
        html += '<div class="insurance-card" data-ins-index="' + idx + '" data-ins-id="' + insId + '" data-ins-role="' + insuranceRole + '">';
        html += '  <div class="insurance-card-title">' + labelText + '</div>';

        html += '  <div class="summary-item">';
        html += '      <label class="summary-label">Carrier</label>';
        html += '      <select class="summary-input insurance-carrier-select ins-field" ' +
            'data-field="insuranceCarrierID" ' +
            'data-current-id="' + carrierIdVal + '" ' +
            'data-current-name="' + carrierNameVal + '">' +
            '      </select>';
        html += '  </div>';

        html += '  <div class="summary-item">';
        html += '      <label class="summary-label">Policy #</label>';
        html += '      <input type="text" class="summary-input ins-field" data-field="ssid" value="' + policyVal + '">';
        html += '  </div>';

        html += '  <div class="summary-item">';
        html += '      <label class="summary-label">Group ID</label>';
        html += '      <input type="text" class="summary-input ins-field" data-field="policyGroupID" value="' + groupVal + '">';
        html += '  </div>';

        html += '  <div class="summary-item">';
        html += '      <label class="summary-label">Holder\'s Name</label > ';
        html += '      <input type="text" class="summary-input ins-field" data-field="policyHolderName" value="' + holderVal + '">';
        html += '  </div>';

        html += '  <div class="summary-item">';
        html += '      <label class="summary-label">Beneficiary First Name</label>';
        html += '          <input type="text" class="summary-input ins-field" data-field="beneficiaryFirstName" value="' + benfName + '">';
        html += '  </div>';

        html += '  <div class="summary-item">';
        html += '      <label class="summary-label">Beneficiary Last Name</label>';
        html += '          <input type="text" class="summary-input ins-field" data-field="beneficiaryLastName" value="' + benfLastN + '">';
        html += '  </div>';

        return html;
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function bindPortalConsentDirtyTracking() {
        $('#insuranceCards')
            .off('input.portalConsent change.portalConsent')
            .on('input.portalConsent change.portalConsent', 'input, select, textarea', function () {
                setPortalConsentDirty(true);
            });

        $('input[name="portal_consent_inline"]')
            .off('change.portalConsentDirty')
            .on('change.portalConsentDirty', function () {
                setPortalConsentDirty(true);
            });
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function bindSignatureDirtyTracking() {
        var canvas = document.getElementById('responder-signature-img-inline');
        if (!canvas) return;

        $(canvas)
            .off('mouseup.portalConsent touchend.portalConsent')
            .on('mouseup.portalConsent touchend.portalConsent', function () {
                if (responderSigPadInline && !responderSigPadInline.isEmpty()) {
                    setPortalConsentDirty(true);
                }
            });
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function isFieldEmpty($el) {
        if ($el.is('textarea') || ($el.is('input') && !$el.is(':checkbox,:radio'))) {
            return $.trim($el.val()) === '';
        }
        if ($el.is('select')) {
            var v = $el.val();
            return (v === '' || v === null);
        }
        if ($el.is('button')) {
            var consent = $el.data('consent');
            return (consent !== 'yes');
        }
        if ($el.is('input[type="checkbox"], input[type="radio"]')) {
            var name = $el.attr('name');
            return !$el.closest('.bell-field').find('input[name="' + name + '"]:checked').length;
        }
        return true;
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function updateBellForField($wrapper) {
        var $fields = $wrapper.find('input, select, textarea');

        if (!$fields.length && $wrapper.hasClass('insurance-title')) {
            $fields = $('#insuranceCards .insurance-card[data-ins-role="primary"]').find('input, select, textarea');
        }

        if ($wrapper.hasClass('insurance-required')) {
            var $primaryCard = $('#insuranceCards .insurance-card[data-ins-role="primary"]');
            var $insuranceHeader = $('#insuranceToggle');
            var $primaryFields = $primaryCard.find('input, select, textarea');
            var insuranceEmpty = false;

            if ($primaryFields.length) {
                insuranceEmpty = false;

                $primaryFields.each(function () {
                    var $el = $(this);

                    if ($el.data('bellOptional') === true || $el.attr('data-bell-optional') === 'true') {
                        return;
                    }

                    var v = ($el.val() || '').toString().trim();
                    if (v === '') {
                        insuranceEmpty = true;
                        return false;
                    }
                });
            } else {
                insuranceEmpty = true;
            }

            var $insuranceIcon = $insuranceHeader.find('.missing-bell-icon').first();

            if (insuranceEmpty) {
                if (!$insuranceIcon.length) {
                    $insuranceIcon = $('<span class="missing-bell-icon shake-bell" title="Missing information"><i class="fas fa-bell"></i></span>');
                    $insuranceHeader.append(' ').append($insuranceIcon);
                }
            } else {
                $insuranceIcon.remove();
            }

            return;
        }

        var isEmpty = false;

        if ($fields.length) {
            isEmpty = false;

            $fields.each(function () {
                var $el = $(this);

                if ($el.data('bellOptional') === true || $el.attr('data-bell-optional') === 'true') {
                    return;
                }

                if ($el.is(':hidden') && !$el.is('[type="hidden"]')) {
                    return;
                }

                var v = ($el.val() || '').toString().trim();

                if ($el.is(':checkbox,:radio')) {
                    var name = $el.attr('name');
                    if (name && !$wrapper.find('input[name="' + name + '"]:checked').length) {
                        isEmpty = true;
                        return false;
                    }
                } else if (v === '') {
                    isEmpty = true;
                    return false;
                }
            });
        } else {
            isEmpty = true;
        }

        var $label = $wrapper.find('label').first();
        var $icon = $label.find('.missing-bell-icon').first();

        if (isEmpty) {
            if (!$icon.length) {
                $icon = $('<span class="missing-bell-icon shake-bell" title="Missing information"><i class="fas fa-bell"></i></span>');
                $label.append($icon);
            }
        } else {
            $icon.remove();
        }
    }


    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function openPersonalContacts() {

        $('#dlgPersonalContacts').dialog({
            modal: true,
            width: 1615,
            height: 592,
            title: 'Personal Contacts',
            resizable: true,
            open: function () {
                initPatientPersonsView();
            },
            close: function () {
                $(this).dialog('destroy');
            }
        });

        return false;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function openMyJournal() {

        $('#dlgMyJournal').dialog({
            modal: true,
            width: 1615,
            height: 592,
            title: 'My Journal',
            resizable: true,
            open: function () {
                initMyJournal();
            },
            close: function () {
                $(this).dialog('destroy');
            }
        });

        return false;
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function openPersonalFERPA() {
        let _requestDataObj = {};
        _requestDataObj['<%=Constants.PARM_CLIENT_ID%>'] = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let _requestDataJSON = JSON.stringify(_requestDataObj);
        let _reqUrl = '<%=Spedmon.PatientInfoRequestsPublicInsuranceForms.URL_SVC_GET_FORM_BY_CLIENT_ID_BASE()%>';
        let _sessionTimeOutURL = '<%=MBA.Credential.generateSessionExpiredLink()%>';

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(_reqUrl, _requestDataJSON, _sessionTimeOutURL)
            .then(
                responseData => {
                    MBA.ComponentCommon.fnOpenWindow(responseData.rawData.dataobj.formURL)
                }).catch(err => {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Could Not Get the Form URL', err.message, {});
                });
    };

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function fillInsuranceCarrierSelects() {
        var $selects = $('.insurance-carrier-select');

        if (!$selects.length) {
            return;
        }

        var requestObj = { term: '' };
        let requestJSON = JSON.stringify(requestObj);

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.InsuranceCarriers.URL_VIEW_SEL_BASE()%>', requestJSON, null)
            .then(responseData => {
                var selRecs = responseData.rawData.SelRecs;

                if (!selRecs.length) {
                    return;
                }

                $selects.each(function () {
                    var $sel = $(this);
                    var currentId = ($sel.attr('data-current-id') || '').trim();

                    $sel.find('option:not(:first)').remove();

                    for (var i = 0; i < selRecs.length; i++) {
                        var opt = selRecs[i];

                        var value = opt.id || '';
                        var text = opt.label || opt.text || opt.value || '';

                        $sel.append('<option value="' + value + '">' + text + '</option>');
                    }

                    if (currentId) {
                        $sel.val(currentId);
                    }
                });

                updateBellForField($('.insurance-required.bell-field'));
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Sorry There Was A Problem',
                    err.message,
                    {}
                );
            });
    }


    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function renderCurrentPatient() {
        if (!patients.length) return;

        var $consentBtn = $('#btnConsentRelease');
        const p = patients[currentPatientIndex];

        // Pager
        $('#pagerTotal').text(patients.length);
        $('#pagerIndex').text(currentPatientIndex + 1);
        $('#pagerName').text(p.patName || '');

        // Hidden inputs
        $('#<%=Constants.PARM_PATIENT_ID%>').val(p.patID || '');
        $('#<%=Constants.PARM_REC_ID%>').val(p.personID || '');

        $('#txtName, #txtEmail, #txtPhone, #txtStreet1, #txtStreet2, #txtCity, #txtState, #txtZip5, #txtZip4, #txtAge, #txtGender, #patientHomePlaceID').val('');

        $('.portal-wrapper-email .patient-data-icon').closest('button').remove();
        $('.portal-wrapper-phone .patient-data-icon').closest('button').remove();

        $('#txtName').val(p.patName || '');
        $('#txtStreet1').val(p.patStreet1 || '');
        $('#txtStreet2').val(p.patStreet2 || '');
        $('#txtCity').val(p.patCity || '');
        $('#txtState').val(p.patState || '');
        $('#txtZip5').val(p.patZip5 || '');
        $('#txtZip4').val(p.patZip4 || '');

        $('#txtAge').val(p.patAge || '');
        $('#txtGender').val(p.patGender || '');

        if (p.patEmail) $('#txtEmail').val(p.patEmail);
        if (p.patPhone) $('#txtPhone').val(p.patPhone);

        $('#patientHomePlaceID').val(p.patplaceHomeID || '');

        $('.portal-wrapper-email').append(
            '<button type="button" class="btn btn-preferred-contact" data-method="40" title="Preferred Contact Method">' +
            '  <i class="' + (p.patPreferredContactMethod == 40 ? 'fa fa-check-circle text-success' : 'fas fa-times-circle text-danger') + ' patient-data-icon"></i>' +
            '</button>'
        );

        $('.portal-wrapper-phone').append(
            '<button type="button" class="btn btn-preferred-contact" data-method="20" title="Preferred Contact Method">' +
            '  <i class="' + (p.patPreferredContactMethod == 20 ? 'fa fa-check-circle text-success' : 'fas fa-times-circle text-danger') + ' patient-data-icon"></i>' +
            '</button>'
        );

        $consentBtn.removeClass('btn-success btn-danger');
        $consentBtn.find('i').remove();
        $consentBtn.text('Consent to Release');

        if (p.patConsentToRelease === "Yes") {
            $consentBtn.addClass('btn-success');
            $consentBtn.prepend('<i class="fas fa-check"></i> ');
        } else {
            $consentBtn.addClass('btn-danger');
            $consentBtn.prepend('<i class="fas fa-times"></i> ');
        }

        renderInsurances(p.insurance || []);
        initMissingBells('.parent_portal_patient_data');

    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initInsuranceCollapse() {
        $('#insuranceToggle').off('click').on('click', function () {
            var $body = $('#insuranceCollapseBody');
            var $icon = $(this).find('.insurance-toggle-icon');

            $body.slideToggle(180, function () {
                var isVisible = $body.is(':visible');

                $icon
                    .toggleClass('fa-chevron-circle-right', !isVisible)
                    .toggleClass('fa-chevron-circle-down', isVisible);

                if (isVisible) {
                    setupConsentSignaturePad();
                }
            });
        });
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    // -------------------------------------------------------------------------
    // PAGER (Prev / Next)
    // -------------------------------------------------------------------------
    function updatePagerButtons() {
        $('#btnPrev').prop('disabled', currentPatientIndex === 0);
        $('#btnNext').prop('disabled', currentPatientIndex === patients.length - 1);
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function initPatientPager() {
        if (!patients.length) return;

        $('#pagerTotal').text(patients.length);

        $('#btnPrev').on('click', function () {
            if (currentPatientIndex > 0) {
                currentPatientIndex--;
                renderCurrentPatient();
                refreshPatientDependentViews();
                updatePagerButtons();
            }
        });

        $('#btnNext').on('click', function () {
            if (currentPatientIndex < patients.length - 1) {
                currentPatientIndex++;
                renderCurrentPatient();
                refreshPatientDependentViews();
                updatePagerButtons();
            }
        });

        updatePagerButtons();
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function refreshPatientDependentViews() {
        initUpcomingVisits();
        initServiceRecordsView();
        initStoredFilesView();
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function saveUserInfoFromPortal(contactMethodVal) {
        let clientid = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        let patid = $('#<%=Constants.PARM_PATIENT_ID%>').val();

        if (!patid) return;

        const p = (patients && patients[currentPatientIndex]) ? patients[currentPatientIndex] : null;

        const cm = (contactMethodVal !== undefined && contactMethodVal !== null)
            ? parseInt(contactMethodVal, 10)
            : parseInt((p && p.patPreferredContactMethod) ? p.patPreferredContactMethod : 10, 10);

        let requestObj = {};
        requestObj['<%=Constants.PARM_CLIENT_ID%>'] = clientid;
        requestObj['<%=Constants.PARM_PATIENT_ID%>'] = patid;

        requestObj['phone'] = $('#txtPhone').val();
        requestObj['email'] = $('#txtEmail').val();
        requestObj['street1'] = $('#txtStreet1').val();
        requestObj['street2'] = $('#txtStreet2').val();
        requestObj['city'] = $('#txtCity').val();
        requestObj['state'] = $('#txtState').val();
        requestObj['zip5'] = $('#txtZip5').val();
        requestObj['zip4'] = $('#txtZip4').val();
        requestObj['patienthomeplaceid'] = $('#patientHomePlaceID').val();
        requestObj['contactmethod'] = cm;

        let requestJSON = JSON.stringify(requestObj);

        let reqUrl = '<%=Spedmon.Patients.URL_SVC_SAVE_PATIENTS_INFO_BASE()%>';

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, requestJSON, null)
            .then(responseData => {
                updateBellForField($('.portal-wrapper-email').closest('.bell-field'));
                updateBellForField($('.portal-wrapper-phone').closest('.bell-field'));
                updateBellForField($('#divAddressInfo').closest('.bell-field'));
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                renderCurrentPatient();
            });
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function getNormalizedInsuranceFromCard($card, existingIns) {
        existingIns = existingIns || {};

        var role = ($card.attr('data-ins-role') || '').toLowerCase();
        var isPrimary = (role === 'primary');

        return {
            id: existingIns.id || '',

            insuranceCarrierID: $.trim(($card.find('[data-field="insuranceCarrierID"]').val() || '').toString()),

            beneficiaryLastName: $.trim(($card.find('[data-field="beneficiaryLastName"]').val() || existingIns.beneficiaryLastName || '').toString()),
            beneficiaryFirstName: $.trim(($card.find('[data-field="beneficiaryFirstName"]').val() || existingIns.beneficiaryFirstName || '').toString()),

            beneficiaryID: $.trim(($card.find('[data-field="ssid"]').val() || existingIns.beneficiaryID || '').toString()),

            policyHolderName: $.trim(($card.find('[data-field="policyHolderName"]').val() || existingIns.policyHolderName || '').toString()),
            policyGroupID: $.trim(($card.find('[data-field="policyGroupID"]').val() || existingIns.policyGroupID || '').toString()),

            expiredOrInvalid: existingIns.expiredOrInvalid || '',
            cybhiRegisteredWithTpa: existingIns.cybhiRegisteredWithTpa || '',

            primaryCarrier: isPrimary ? 1 : 0
        };
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function insuranceHasAllRequiredData(ins) {
        if (!ins) return false;

        return (
            ins.insuranceCarrierID !== '' &&
            ins.beneficiaryID !== '' &&
            ins.policyHolderName !== '' &&
            ins.policyGroupID !== '' &&
            ins.beneficiaryFirstName !== '' &&
            ins.beneficiaryLastName !== ''
        );
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function buildInsuranceSaveRequest(patid, clientid, ins) {
        return {
        '<%=Constants.PARM_PATIENT_ID%>': patid,
        '<%=Constants.PARM_CLIENT_ID%>': clientid,

            insurancecarrierid: ins.insuranceCarrierID,
            beneficiarylastname: ins.beneficiaryLastName,
            beneficiaryfirstname: ins.beneficiaryFirstName,
            beneficiaryid: ins.beneficiaryID,
            policyholdername: ins.policyHolderName,
            policygroupid: ins.policyGroupID,
            expiredorinvalid: ins.expiredOrInvalid,
            cybhiregisteredwithtpa: ins.cybhiRegisteredWithTpa,

            primarycarrier: ins.primaryCarrier ? '1' : '0',

        '<%=Constants.PARM_REC_ID%>': ins.id || '',
            '<%=Constants.PARM_SAVE_TYPE%>': (ins.id ? '2' : '1')
        };
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function showInsuranceAutosaveHint(show) {
        $('#insurance-autosave-hint').toggle(!!show);
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function saveInsuranceFromPortal(insIndex, field, value) {
        const p = patients && patients[currentPatientIndex];
        if (!p) return;

        insIndex = parseInt(insIndex, 10);
        if (isNaN(insIndex)) return;

        if (!p.insurance) {
            p.insurance = [];
        }

        if (!p.insurance[insIndex]) {
            p.insurance[insIndex] = {
                id: '',
                insuranceCarrierID: '',
                beneficiaryLastName: '',
                beneficiaryFirstName: '',
                beneficiaryID: '',
                policyHolderName: '',
                policyGroupID: '',
                expiredOrInvalid: '',
                cybhiRegisteredWithTpa: '',
                primaryCarrier: (insIndex === 0 ? 1 : 0)
            };
        }

        let patid = $('#<%=Constants.PARM_PATIENT_ID%>').val();
        let clientid = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        if (!patid || !clientid) return;

        const $card = $('#insuranceCards .insurance-card[data-ins-index="' + insIndex + '"]');
        const ins = getNormalizedInsuranceFromCard($card, p.insurance[insIndex]);

        if (!insuranceHasAllRequiredData(ins)) {
            showInsuranceAutosaveHint(true);
            return;
        }

        showInsuranceAutosaveHint(false);

        let requestObj = buildInsuranceSaveRequest(patid, clientid, ins);
        let requestJSON = JSON.stringify(requestObj);
        let reqUrl = '<%=Spedmon.PatientInsuranceCarriers.URL_REST_PATCARRIER_SAVE_INLINE_BASE()%>';

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, requestJSON, null)
            .then(responseData => {
                if (!ins.id && responseData && responseData.rawData && responseData.rawData.recordID) {
                    ins.id = responseData.rawData.recordID;
                }

                p.insurance[insIndex] = ins;
                updateBellForField($('#insuranceToggle'));
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Sorry There Was A Problem',
                    err.message,
                    {}
                );
                renderCurrentPatient();
            });
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>
    function saveConsentFromPortal() {
        var requestObj = buildPortalConsentSaveRequest();
        var requestJSON = JSON.stringify(requestObj);
        var reqUrl = '<%=Spedmon.PatientInfoRequestsPublicInsuranceFormResponses.URL_SAVE_RESPONSE_CONSENT_BASE()%>';

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, requestJSON, null)
            .then(responseData => {
                const p = patients && patients[currentPatientIndex];

                if (p) {
                    p.patConsentToRelease = (requestObj.ferpaConsent === '1') ? 'Yes' : 'No';
                }

                let $consentBtn = $('#btnConsentRelease');
                $consentBtn.removeClass('btn-success btn-danger');
                $consentBtn.find('i').remove();
                $consentBtn.text('Consent to Release');

                if (requestObj.ferpaConsent === '1') {
                    $consentBtn.addClass('btn-success');
                    $consentBtn.prepend('<i class="fas fa-check"></i> ');
                } else if (requestObj.ferpaConsent === '0') {
                    $consentBtn.addClass('btn-danger');
                    $consentBtn.prepend('<i class="fas fa-times"></i> ');
                }

                setPortalConsentDirty(false);
                portalConsentSavedOnce = true;

                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Saved',
                    'Consent information was saved successfully.',
                    {}
                );
            })
            .catch(err => {
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                    'Sorry There Was A Problem',
                    err.message,
                    {}
                );
            });
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    function buildPortalConsentSaveRequest() {
        var $primaryCard = $('#insuranceCards .insurance-card[data-ins-index="0"]');
        var $secondaryCard = $('#insuranceCards .insurance-card[data-ins-index="1"]');

        var requestObj = {};

        requestObj['clientid'] = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        requestObj['patid'] = $('#<%=Constants.PARM_PATIENT_ID%>').val();
        requestObj['patperid'] = $('#<%=Constants.PARM_PAT_PER_ID%>').val();

        requestObj['ferpaconsent'] = $('input[name="portal_consent_inline"]:checked').val();
        requestObj['respondersignatureimgdata'] = $('#responder-signature-img-data-inline').val();

        if ($primaryCard.length) {
            requestObj['primaryinsurancecarrierid'] = $primaryCard.find('[data-field="insuranceCarrierID"]').val();
            requestObj['primarymemberid'] = $primaryCard.find('[data-field="ssid"]').val();
            requestObj['primarypolicygroupid'] = $primaryCard.find('[data-field="policyGroupID"]').val();
            requestObj['primarypolicyholdername'] = $primaryCard.find('[data-field="policyHolderName"]').val();
            requestObj['primaryinsurancecarrierothername'] = "";
            requestObj['primarybeneficiaryfirstname'] = $primaryCard.find('[data-field="beneficiaryFirstName"]').val();
            requestObj['primarybeneficiarylastname'] = $primaryCard.find('[data-field="beneficiaryLastName"]').val();
        }

        requestObj['secondaryinsurancecarrierid'] = '';
        requestObj['secondarymemberid'] = '';
        requestObj['secondarypolicygroupid'] = '';
        requestObj['secondarypolicyholdername'] = '';
        requestObj['secondaryinsurancecarrierothername'] = '';

        if ($secondaryCard.length) {
            requestObj['secondaryinsurancecarrierid'] = $secondaryCard.find('[data-field="insuranceCarrierID"]').val();
            requestObj['secondarymemberid'] = $secondaryCard.find('[data-field="ssid"]').val();
            requestObj['secondarypolicygroupid'] = $secondaryCard.find('[data-field="policyGroupID"]').val();
            requestObj['secondarypolicyholdername'] = $secondaryCard.find('[data-field="policyHolderName"]').val();
            requestObj['secondaryinsurancecarrierothername'] = "";
            requestObj['secondarybeneficiaryfirstname'] = $secondaryCard.find('[data-field="beneficiaryFirstName"]').val();
            requestObj['secondarybeneficiarylastname'] = $secondaryCard.find('[data-field="beneficiaryLastName"]').val();
        }
        requestObj['savetype'] = "1";
        requestObj['recid'] = $('#<%=Constants.PARM_REC_ID%>').val();

        return requestObj;
    }

    <%/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/%>

    $(window).on('load', function () {
        initPatientPager();
        renderCurrentPatient();
        initMissingBells('.parent_portal_patient_data');
        initInsuranceCollapse();
        initConsentInline();

        // Tabs
        initTabs();

        // Initialize form
        //initializeReferralForm();

        // Checkbox items
        $('.checkbox-item').on('click', function () {
            const checkbox = $(this).find('input[type="checkbox"]');
            const isChecked = checkbox.prop('checked');

            checkbox.prop('checked', !isChecked);

            if (!isChecked) {
                $(this).addClass('checked');
            } else {
                $(this).removeClass('checked');
            }
        });

        //$('#pat_ref_parent_name_datalist').on('input change', function () {
        //    const val = this.value;
        //    const $opt = $('#pat_ref_parent_name option').filter(function () {
        //        return this.value === val;
        //    });

        //    if ($opt.length) {
        //        populateParentInfo($opt);
        //    }
        //});

        // Form validation
        //function validateForm() {
        //    let isValid = true;

        //    const requiredFields = $('.form-control[required]');
        //    requiredFields.each(function () {
        //        if (!this.checkValidity()) {
        //            $(this).addClass('error');
        //            isValid = false;

        //            setTimeout(() => {
        //                $(this).removeClass('error');
        //            }, 5000);
        //        }
        //    });
        //    return isValid;
        //}

        $('#btnContact').on('click', function () {
            openPersonalContacts();
        });

        $('#btnConsentRelease').on('click', function () {
            openPersonalFERPA();
        });

        $('#btnMyJournal').on('click', function () {
            openMyJournal();
        });

        $('#portalContactAddressWrapper')
            .off('click.ppPreferred', '.btn-preferred-contact')
            .on('click.ppPreferred', '.btn-preferred-contact', function (e) {
                e.preventDefault();

                const val = parseInt($(this).data('method'), 10); // 40 o 20

                if (val === 40 && $.trim($('#txtEmail').val() || '') === '') {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                        'Missing Information',
                        'Please enter an email before selecting it as preferred.',
                        {}
                    );
                    return;
                }

                if (val === 20 && $.trim($('#txtPhone').val() || '') === '') {
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog(
                        'Missing Information',
                        'Please enter a phone number before selecting it as preferred.',
                        {}
                    );
                    return;
                }

                $('.portal-wrapper-email .btn-preferred-contact i, .portal-wrapper-phone .btn-preferred-contact i')
                    .removeClass('fa fa-check-circle text-success')
                    .addClass('fas fa-times-circle text-danger');

                $(this).find('i')
                    .removeClass('fas fa-times-circle text-danger')
                    .addClass('fa fa-check-circle text-success');

                if (patients && patients[currentPatientIndex]) {
                    patients[currentPatientIndex].patPreferredContactMethod = val;
                }

                saveUserInfoFromPortal(val);
            });

        const contactAddrSelector = '#txtEmail, #txtPhone, #txtStreet1, #txtStreet2, #txtCity, #txtState, #txtZip5, #txtZip4';

        $('#portalContactAddressWrapper')
            .off('change.ppAddr', contactAddrSelector)
            .on('change.ppAddr', contactAddrSelector, function () {
                saveUserInfoFromPortal(null);
            });

        $('#insuranceCards')
            .off('change.ppIns', '.ins-field')
            .on('change.ppIns', '.ins-field', function () {

                updateBellForField($('.insurance-required.bell-field'));

                const $field = $(this);
                const $card = $field.closest('.insurance-card');
                const insIndex = $card.attr('data-ins-index');
                const field = $field.data('field');
                const value = $.trim($field.val() || '');

                saveInsuranceFromPortal(insIndex, field, value);
            });

        // Submit referral button
       <%-- $('#pat_ref_save_btn').on('click', function () {
            if (!validateForm()) {
                return;
            }
            let requestObj = {};
            const fileInfo = getStoredFilesInfo();
            const selectedPriority = $('.priority-card.selected').data('priority');
            const priorityMap = { 'routine': 1, 'urgent': 2, 'crisis': 3 };

            const $submitBtn = $(this);
            const originalText = $submitBtn.html();

            $submitBtn.html('Processing...');

            let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($submitBtn);
            requestObj['<%=Constants.PARM_CLIENT_ID%>'] = $('#<%=Constants.PARM_CLIENT_ID%>').val();
            requestObj['<%=Constants.PARM_PRACTITIONER_ID%>'] = $('#<%=Constants.PARM_PRACTITIONER_ID%>').val();
            requestObj['<%=Constants.PARM_REFERRING_BY_USER_ID%>'] = $('#<%=Constants.PARM_REFERRING_BY_USER_ID%>').val();
            requestObj['patID'] = $('#<%=Constants.PARM_PATIENT_ID%>').val();
            requestObj['<%=Constants.PARM_PAT_PER_ID%>'] = $('#pat_ref_parent_name').val();
            requestObj['priority'] = priorityMap[selectedPriority] || 1;
            requestObj['referredtopracname'] = $('#pat_ref_prac_name').val();
            requestObj['referredtoorgname'] = $('#pat_ref_prac_agency').val();
            requestObj['referredtopracemail'] = $('#pat_ref_prac_email').val();
            requestObj['referredtopracphone'] = $('#pat_ref_prac_phone').val();
            requestObj['parentguardianname'] = $('#pat_ref_parent_name_datalist').val();
            requestObj['parentguardianrelationship'] = $('#pat_ref_parent_relationship').val();
            requestObj['parentguardianemail'] = $('#pat_ref_parent_email').val();
            requestObj['parentguardianphone'] = $('#pat_ref_parent_phone').val();
            requestObj['parentguardianconsent'] = "0";
            requestObj['referraltype'] = "1";
            requestObj['notes'] = $('#pat_ref_reason_or_impression').val();
            requestObj['reffileid'] = fileInfo;
            requestObj['includediagnoses'] = $('#pat_ref_diagnosis').prop("checked");
            requestObj['includeordersorprescriptions'] = $('#pat_ref_medications').prop("checked");
            requestObj['includeservicerecordstreatments'] = $('#pat_ref_direct_svc_history').prop("checked");
            requestObj['includeservicerecordsassessementsorscreenings'] = $('#pat_ref_recent_screenings').prop("checked");
            requestObj['includeservicenotesnonconfidential'] = $('#pat_ref_nonconfid_session_notes').prop("checked");
            requestObj['includeservicenotesconfidential'] = $('#pat_ref_confid_session_notes').prop("checked");
            requestObj['isused'] = "0";
            requestObj['referredtopracid'] = "";
            requestObj['referralsourcename'] = "";
            requestObj['referralsourcerole'] = "";
            requestObj['referralsourceemail'] = "";
            requestObj['referralsourcephone'] = "";
            requestObj['behavioralisssuesconcerns'] = false;
            requestObj['academicconcerns'] = false;
            requestObj['anxietyordepressionconcerns'] = false;
            requestObj['familystressconcerns'] = false;
            requestObj['bullyingconcerns'] = false;
            requestObj['otherconcerns'] = "";
            requestObj['savetype'] = '<%=Constants.SAVE_TYPE_NEW%>';
            requestObj['recid'] = "";

            let requestJSON = JSON.stringify(requestObj);
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PractitionerPatientReferrals.URL_SVC_REF_SAVE_BASE()%>', requestJSON, null)
                .then(responseData => {
                    MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                    resetForm();
                    $submitBtn.html(originalText);
                })
                .catch(err => {
                    MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                    $submitBtn.html(originalText);
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                });
        });--%>

        initUpcomingVisits();
        initServiceRecordsView();
        initStoredFilesView();
    });
</script>
<%}
    else
    { %>
<div class="header">
    <h1><%=clientName%></h1>
    <h5>No Patient Related</h5>
</div>
<%} %>
