<%@ Page Language="C#" CodeBehind="user_all_practitioner_patient_referral_save.aspx.cs" Inherits="Spedmon.UserAllPractitionerPatientReferralSave" %>


<Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server"/>
<Spedmon:HiddenInput ID="pracid" name="pracid" title="pracid" runat="server"/>
<Spedmon:HiddenInput ID="referringbyuserid" name="referringbyuserid" title="referringbyuserid" runat="server"/>
<Spedmon:HiddenInput ID="recid" name="recid" title="recid" runat="server"/>
<Spedmon:HiddenInput ID="savetype" name="savetype" title="savetype" runat="server"/>

<%--<Spedmon:HiddenInput ID="patid" name="patid" title="record id" runat="server"/>--%>

<%if (pageOK == true){%>
 <div class="referral-container">        

        <div class="header">
            <h1><i class="fas fa-user-md"></i> Patient Referral System</h1>
            <p>Streamlined referral management for practitioners</p>
        </div>

        <div class="form-content">
            <!-- Priority Section -->
            <div class="section">
                <div class="section-title">
                    <i class="fas fa-exclamation-triangle"></i>
                    Urgency Level
                </div>
                <div class="priority-grid">
                    <div class="priority-card routine" data-priority="routine">
                        <input type="checkbox" id="pat_ref_routine" runat="server" />
                        <i class="fas fa-clock"></i>
                        <div class="priority-label">Routine</div>
                    </div>
                    <div class="priority-card urgent" data-priority="urgent">
                        <input type="checkbox" id="pat_ref_urgent" runat="server" />
                        <i class="fas fa-exclamation"></i>
                        <div class="priority-label">Urgent</div>
                    </div>
                    <div class="priority-card crisis" data-priority="crisis">
                        <input type="checkbox" id="pat_ref_crisis" runat="server" />
                        <i class="fas fa-exclamation-triangle"></i>
                        <div class="priority-label">Crisis</div>
                    </div>
                </div>
            </div>

            <!-- Patient Information -->
            <div class="section prac_pat_ref_patinfo">
                <div class="section-title">
                    <i class="fas fa-user-injured"></i>
                    Select Patient
                </div>
                <div class="form-grid">
                    <div class="form-group">            
                        <Spedmon:DataEntryRowSelectPatient
                            ID                   = "selectPatient" 
                            entityControlID      = "patid"  
                            rowLabel             = "Patient (Last,First)"
                            dataEntryRowRenderAs = "FIELD"
                            selectTitle          = "Enter Last, First"
                            onSpedmonInputData   = "triggerPreLoadData(e);"                            
                            runat                = "server">
                        </Spedmon:DataEntryRowSelectPatient> 
                    </div>
                </div>
            </div>

            <!-- Practitioner Information -->
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
                        <input type="text" id="pat_ref_prac_name" class="form-control" placeholder="Enter practitioner name" runat="server" />
                    </div>
                    <div class="form-group">
                        <label for="pat_ref_prac_agency">
                            <i class="fas fa-building"></i>Agency/Organization
                        </label>
                        <input type="text" id="pat_ref_prac_agency" class="form-control" placeholder="Enter agency name" runat="server" />
                    </div>
                    <div class="form-group">
                        <label for="pat_ref_prac_email">
                            <i class="fas fa-envelope"></i>Email Address
                        </label>
                        <input type="email" id="pat_ref_prac_email" class="form-control" placeholder="practitioner@example.com" runat="server" />
                    </div>
                    <div class="form-group">
                        <label for="pat_ref_prac_phone">
                            <i class="fas fa-phone"></i>Phone Number
                        </label>
                        <input type="tel" id="pat_ref_prac_phone" class="form-control" placeholder="(555) 123-4567" runat="server" />
                    </div>
                </div>
            </div>

            <!-- Parent Authorization -->
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
                        <input id="pat_ref_parent_name_datalist" list="pat_ref_parent_name" class="form-control" placeholder="Type or click to select…" autocomplete="off" runat="server" required />
                        <datalist id="pat_ref_parent_name" class="form-control" hidden>
                        </datalist>
                    </div>
                    <div class="form-group">
                        <label for="pat_ref_parent_relationship">
                            <i class="fas fa-heart"></i>Relationship
                        </label>
                        <input type="text" id="pat_ref_parent_relationship" class="form-control" placeholder="Relationship" runat="server" />
                    </div>
                    <div class="form-group">
                        <label for="pat_ref_parent_email">
                            <i class="fas fa-envelope"></i>Email Address
                        </label>
                        <input type="email" id="pat_ref_parent_email" class="form-control" placeholder="parent@example.com" runat="server" />
                    </div>
                    <div class="form-group">
                        <label for="pat_ref_parent_phone">
                            <i class="fas fa-phone"></i>Phone Number
                        </label>
                        <input type="tel" id="pat_ref_parent_phone" class="form-control" placeholder="(555) 123-4567" runat="server" />
                    </div>
                </div>
            </div>

            <!-- Referral Details -->
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
                        <textarea id="pat_ref_reason_or_impression" class="form-control" placeholder="Provide detailed information about the reason for referral..." runat="server"></textarea>
                    </div>
                    <div class="form-group" style="display:none">
                        <label for="pat_ref_select_attach">
                            <i class="fas fa-paperclip"></i>Attachments to Include
                        </label>
                        <select id="pat_ref_select_attach" class="form-control" runat="server" multiple="true">                           
                        </select>
                    </div>
                </div>
            </div>

            <!-- Information to Include -->
            <div class="section">
                <div class="section-title">
                    <i class="fas fa-check-square"></i>
                    Information to Include in Referral
                </div>
                <div class="checkbox-grid">
                    <div class="checkbox-item" data-checkbox="pat_ref_diagnosis">
                        <input type="checkbox" id="pat_ref_diagnosis" runat="server" />
                        <i class="fas fa-stethoscope"></i>
                        <span class="checkbox-label">DSM-5 or ICD-10 Diagnosis</span>
                    </div>
                    <div class="checkbox-item" data-checkbox="pat_ref_recent_screenings">
                        <input type="checkbox" id="pat_ref_recent_screenings" runat="server" />
                        <i class="fas fa-search"></i>
                        <span class="checkbox-label">Recent Screenings</span>
                    </div>
                    <div class="checkbox-item" data-checkbox="pat_ref_medications">
                        <input type="checkbox" id="pat_ref_medications" runat="server" />
                        <i class="fas fa-pills"></i>
                        <span class="checkbox-label">Current Medications</span>
                    </div>
                    <div class="checkbox-item" data-checkbox="pat_ref_direct_svc_history">
                        <input type="checkbox" id="pat_ref_direct_svc_history" runat="server" />
                        <i class="fas fa-history"></i>
                        <span class="checkbox-label">Direct Service History</span>
                    </div>
                    <div class="checkbox-item" data-checkbox="pat_ref_nonconfid_session_notes">
                        <input type="checkbox" id="pat_ref_nonconfid_session_notes" runat="server" />
                        <i class="fas fa-file-alt"></i>
                        <span class="checkbox-label">Non-Confidential Session Notes</span>
                    </div>
                    <div class="checkbox-item" data-checkbox="pat_ref_confid_session_notes">
                        <input type="checkbox" id="pat_ref_confid_session_notes" runat="server" />
                        <i class="fas fa-lock"></i>
                        <span class="checkbox-label">Confidential Session Notes</span>
                    </div>
                </div>
            </div>

            <!-- Submit Section -->
            <div class="submit-section">
                <button type="button" id="pat_ref_save_btn" class="submit-btn">
                    <i class="fas fa-paper-plane"></i>
                    Submit Referral
                </button>
                <div class="success-checkmark" id="success-animation"></div>
            </div>
        </div>
</div>

<script type="text/javascript"> 

    function getStoredFilesInfo() {
        const selectedOptions = $('#pat_ref_select_attach option:selected');
        let result = {};

        if (selectedOptions.length > 0) {
            selectedOptions.each(function () {
                const value = $(this).val();
                const text = $(this).text();
                result[value] = text;
            });
        }

        return JSON.stringify(result);
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function initializeForm() {
        let patid = $('#' + '<%=Constants.PARM_PATIENT_ID%>').val();

        if (patid && patid > 0) {
            loadParentAuthorizationOptions();
            //loadStoredFilesOptions();
        }        
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function triggerPreLoadData(e) {
        loadParentAuthorizationOptions();
        //loadStoredFilesOptions();
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function loadParentAuthorizationOptions() {
        let clientid = $('#' + '<%=Constants.PARM_CLIENT_ID%>').val();
        let patid = $('#' + '<%=Constants.PARM_PATIENT_ID%>').val();

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
        
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function loadStoredFilesOptions() {
        let clientid = $('#' + '<%=Constants.PARM_CLIENT_ID%>').val();
        let pracid = $('#' + '<%=Constants.PARM_PRACTITIONER_ID%>').val();
        let patid = $('#' + '<%=Constants.PARM_PATIENT_ID%>').val();

        let $dropdown = $('#pat_ref_select_attach').empty();

        /****** set up ajax url ***********/        
        var reqUrl = '<%=Spedmon.StoredFiles.URL_WEB_SVC_VIEW_SEL_BASE()%>';
        var reqData = JSON.stringify({
            '<%=Constants.PARM_CLIENT_ID%>': clientid,
            '<%=Constants.PARM_PRACTITIONER_ID%>': pracid,
            '<%=Constants.PARM_PATIENT_ID%>': patid,
            'referencedentityid': "",
            '<%=Constants.PARM_FILE_CLASS%>': "",
            'filenamespace': "",
            'filesource': "",
            'term': ""
        });

        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod(reqUrl, reqData, null)
            .then(responseData => {
                let selRecs = responseData.rawData.SelRecs;
                if (selRecs) {
                    $dropdown.append($('<option disabled selected>Select attachments...</option>'));
                    responseData.rawData.SelRecs.forEach(option => {
                        let $option = $('<option></option>')
                            .attr('value', option.id)
                            .text(option.value);
                        $dropdown.append($option);
                    });
                }
            })
            .catch(responseData => {
                $.spedmonWebUI.dialogMessage('ERROR', responseData.message, null, 400, 200, null, null, null);
            });
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function resetForm() {
        $('.priority-card').removeClass('selected');
        $('.priority-card input[type="checkbox"]').prop('checked', false);
        $('.form-control').val('');
        $('.checkbox-item').removeClass('checked');
        $('.checkbox-item input[type="checkbox"]').prop('checked', false);
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function syncPriorityUIFromCheckbox() {
        $('.priority-card').removeClass('selected');
        $('.priority-card input[type="checkbox"]').each(function () {
            if (this.checked) $(this).closest('.priority-card').addClass('selected');
        });
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function syncCheckboxItemsUI() {
        $('.checkbox-item').each(function () {
            const $item = $(this);
            const isChecked = $item.find('input[type="checkbox"]').prop('checked');
            $item.toggleClass('checked', isChecked);
        });
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function populateParentInfo(selectedOption) {
        if (selectedOption.val()) {
            $('#pat_ref_parent_relationship').val(selectedOption.data('relationship'));
            $('#pat_ref_parent_email').val(selectedOption.data('email'));
            $('#pat_ref_parent_phone').val(selectedOption.data('phone'));
        } 
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    $(document).ready(function () {        
        
        // Initialize form
        initializeForm();

        if ($('#<%=Constants.PARM_SAVE_TYPE%>').val() === '2') {
            let patid = $('#' + '<%=Constants.PARM_PATIENT_ID%>').val();
            if (patid && patid > 0) {
                syncPriorityUIFromCheckbox();
                syncCheckboxItemsUI();
            }
        }

        // Priority selection
        $('.priority-card').on('click', function () {
            $('.priority-card').removeClass('selected');
            $(this).addClass('selected');

            // Update hidden checkbox
            $('.priority-card input[type="checkbox"]').prop('checked', false);
            $(this).find('input[type="checkbox"]').prop('checked', true);
        });

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

        $('#pat_ref_parent_name_datalist').on('input change', function () {
            const val = this.value;
            const $opt = $('#pat_ref_parent_name option').filter(function () {
                return this.value === val;
            });

            if ($opt.length) {
                populateParentInfo($opt);
            }
        });

        // Form validation
        function validateForm() {
            let isValid = true;

            const requiredFields = $('.form-control[required]');
            requiredFields.each(function () {
                if (!this.checkValidity()) {
                    $(this).addClass('error');
                    isValid = false;

                    setTimeout(() => {
                        $(this).removeClass('error');
                    }, 5000);
                }
            });

            return isValid;
        }


        // Submit button
        $('#pat_ref_save_btn').on('click', function () {

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
            requestObj['savetype'] = $('#<%=Constants.PARM_SAVE_TYPE%>').val();
            requestObj['recid'] = $('#<%=Constants.PARM_REC_ID%>').val();

            let requestJSON = JSON.stringify(requestObj);
            MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PractitionerPatientReferrals.URL_SVC_REF_SAVE_BASE()%>', requestJSON, null)
                .then(responseData => {
                    MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                    resetForm();
                    $submitBtn.html(originalText);
                    window.close();
                })
                .catch(err => {
                    MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                    $submitBtn.html(originalText);
                    MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                });
        });
    });
    
</script>
<%} /* patient is ok */ %>