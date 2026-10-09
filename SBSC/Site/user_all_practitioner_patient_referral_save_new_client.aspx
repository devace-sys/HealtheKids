<%@ Page Language="C#" CodeBehind="user_all_practitioner_patient_referral_save_new_client.aspx.cs" Inherits="Spedmon.UserAllPractitionerPatientReferralSaveNewClient" %>

<Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server"/>
<Spedmon:HiddenInput ID="userpracid" name="userpracid" title="userpracid" runat="server" />
<Spedmon:HiddenInput ID="referringbyuserid" name="referringbyuserid" title="referringbyuserid" runat="server"/>
<Spedmon:HiddenInput ID="recid" name="recid" title="recid" runat="server"/>
<Spedmon:HiddenInput ID="savetype" name="savetype" title="savetype" runat="server"/>

<%if (pageOK == true){%>
 <div class="referral-container-new-client">        

        <div class="header-nc">
            <h1><i class="fas fa-user-md"></i> Patient Referral System</h1>
            <p>Streamlined referral management for practitioners</p>
        </div>

        <div class="form-content-nc">
            <!-- Priority Section -->
            <div class="section-nc">
                <div class="section-title-nc">
                    <i class="fas fa-exclamation-triangle"></i>
                    Urgency Level
                </div>
                <div class="priority-grid-nc">
                    <div class="priority-card-nc routine-nc" data-priority="routine">
                        <input type="checkbox" id="pat_ref_routine_nc" runat="server" />
                        <i class="fas fa-clock"></i>
                        <div class="priority-label-nc">Routine</div>
                    </div>
                    <div class="priority-card-nc urgent-nc" data-priority="urgent">
                        <input type="checkbox" id="pat_ref_urgent_nc" runat="server" />
                        <i class="fas fa-exclamation"></i>
                        <div class="priority-label-nc">Urgent</div>
                    </div>
                    <div class="priority-card-nc crisis-nc" data-priority="crisis">
                        <input type="checkbox" id="pat_ref_crisis_nc" runat="server" />
                        <i class="fas fa-exclamation-triangle"></i>
                        <div class="priority-label-nc">Crisis</div>
                    </div>
                </div>
            </div>

            <!-- Patient Information -->
            <div class="flex-container-nc">
                <div class="section-nc prac_pat_ref_patinfo_nc">
                    <div class="section-title-nc">
                        <i class="fas fa-user-injured"></i>
                        Select Client
                    </div>
                    <div class="form-grid-nc">
                        <div class="form-group-nc">            
                            <Spedmon:DataEntryRowSelectPatient
                                ID                   = "selectPatientRef" 
                                entityControlID      = "patid" 
                                showAddNew           = "true" 
                                rowLabel             = "Client (Last,First)"
                                dataEntryRowRenderAs = "FIELD"
                                selectTitle          = "Enter Last, First"                          
                                runat                = "server">
                            </Spedmon:DataEntryRowSelectPatient>                  
                        </div>                    
                    </div>
                  </div>

                <!-- Practitioner Information -->
                <div class="section-nc">
                    <div class="section-title-nc">
                        <i class="fas fa-user-md"></i>
                        Assigned Practitioner 
                    </div>
                    <div class="form-grid-nc">
                        <div class="form-group-nc">
                            <Spedmon:DataEntryRowSelectPractitioner
                                ID                                 = "selectPractitionerRef"
                                entityControlID                    = "pracid"                                
                                rowLabel                           = "Practitioner (Last,First)?"
                                selectTitle                        = "Enter Last, First"
                                preSelectedDataSource              = "ALL_PRACTITIONERS"
                                dataEntryRowRenderAs               = "FIELD"
                                showClearSelection                 = "true"
                                runat                              = "server">
                             </Spedmon:DataEntryRowSelectPractitioner>
                        </div>
                    </div>
                </div>
            </div>

            <div class="section-nc">
                <div class="section-title-nc">
                    <i class="fas fa-share-alt"></i>
                    Referral Source
                </div>
                <div id="svc_ref_practitioner_data_nc" class="form-grid-nc">
                    <div class="form-group-nc">
                        <label for="pat_ref_source_name_nc">
                            <i class="fas fa-user"></i>Name
                        </label>
                        <input type="text" id="pat_ref_source_name_nc" name="pat_ref_source_name_nc" class="form-control" placeholder="Name" runat="server" />
                    </div>
                    <div class="form-group-nc">
                        <label for="pat_ref_source_role_nc">
                            <i class="fas fa-user-tag"></i>Role
                        </label>
                        <select type="text" id="pat_ref_source_role_nc" name="pat_ref_source_role_nc" class="form-control" placeholder="Role" runat="server" >
                            <option value="Parent/Guardian" >Parent/Guardian</option>
                            <option value="Teacher" >Teacher</option>
                            <option value="Nurse" >Nurse</option>
                            <option value="Student" >Student</option>
                            <option value="Other" >Other school staff</option>
                        </select>
                    </div>
                    <div class="form-group-nc">
                        <label for="pat_ref_source_email_nc">
                            <i class="fas fa-envelope"></i>Email Address
                        </label>
                        <input type="email" id="pat_ref_source_email_nc" name="pat_ref_source_email_nc" class="form-control" placeholder="practitioner@example.com" runat="server" />
                    </div>
                    <div class="form-group-nc">
                        <label for="pat_ref_source_phone_nc">
                            <i class="fas fa-phone"></i>Phone Number
                        </label>
                        <input type="tel" id="pat_ref_source_phone_nc" name="pat_ref_source_phone_nc"  class="form-control" placeholder="(555) 123-4567" runat="server" />
                    </div>
                </div>
            </div>

            <!-- Parent Authorization -->
            <div class="section-nc">
                <div class="section-title-nc">
                    <i class="fas fa-user-shield"></i>
                    Presenting Concerns
                </div>
                <div class="form-grid-nc">
                    <div class="form-group-nc">
                        <div class="checkbox-concerns">
                            <input type="checkbox" id="pat_ref_behavioral_issues" runat="server" />
                            <label for="pat_ref_behavioral_issues">
                                Behavioral Issues
                            </label> 
                        </div>
                    </div>
                    <div class="form-group-nc">
                        <div class="checkbox-concerns">                        
                            <input type="checkbox" id="pat_ref_academic_concerns" runat="server" />
                            <label for="pat_ref_academic_concerns">
                                Academic Concerns
                            </label>
                        </div>
                    </div>
                    <div class="form-group-nc">
                        <div class="checkbox-concerns">
                            <input type="checkbox" id="pat_ref_anxiety_deoression" runat="server" />
                            <label for="pat_ref_anxiety_deoression">
                                Anxiety/Depression 
                            </label>                        
                        </div>
                    </div>
                    <div class="form-group-nc">
                        <div class="checkbox-concerns">
                            <input type="checkbox" id="pat_ref_family_stress" runat="server"/>
                            <label for="pat_ref_family_stress">
                                Family Stress
                            </label>                        
                        </div>
                    </div>
                    <div class="form-group-nc">
                        <div class="checkbox-concerns">
                            <input type="checkbox" id="pat_ref_bullying" runat="server"/>
                            <label for="pat_ref_bullying">
                                Bullying
                            </label>                        
                        </div>
                    </div>
                    <div class="form-group-nc">
                        <textarea type="checkbox" id="pat_ref_other_concerns" class="form-control" placeholder="Other" runat="server"></textarea>
                    </div>
                </div>
            </div>

            <!-- Referral Details -->
            <div class="section-nc">
                <div class="section-title-nc">
                    <i class="fas fa-clipboard-list"></i>
                    Referral Details
                </div>
                <div class="form-grid-nc">
                    <div class="form-group-nc textarea-group-nc">
                        <label for="pat_ref_reason_or_impression_nc">
                            <i class="fas fa-edit"></i>Reason for Referral and Patient Impression
                        </label>
                        <textarea id="pat_ref_reason_or_impression_nc" class="form-control" placeholder="Provide detailed information about the reason for referral..." runat="server"></textarea>
                    </div>
                    <div class="form-group-nc" style="display:none;">
                        <label for="pat_ref_select_attach_nc">
                            <i class="fas fa-paperclip"></i>Attachments to Include
                        </label>
                        <select id="pat_ref_select_attach_nc" class="form-control" runat="server" multiple="true">                           
                        </select>
                    </div>
                </div>
            </div>            

            <!-- Submit Section -->
            <div class="submit-section-nc">
                <button type="button" id="pat_ref_save_btn_nc" class="submit-btn-nc">
                    <i class="fas fa-paper-plane"></i>
                    Submit Referral
                </button>
                <div class="success-checkmark-nc" id="success-animation-nc"></div>
            </div>
        </div>
</div>

<script type="text/javascript"> 

    <%// --------------------------------------------------------------------------------------------------- %>

    function resetForm() {
        $('.priority-card-nc').removeClass('selected');
        $('.priority-card-nc input[type="checkbox"]').prop('checked', false);
        $('.form-control').val('');
        $('.checkbox-concerns input[type="checkbox"]').prop('checked', false);
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    function syncPriorityUIFromCheckbox() {
        $('.priority-card-nc').removeClass('selected');
        $('.priority-card-nc input[type="checkbox"]').each(function () {
            if (this.checked) $(this).closest('.priority-card-nc').addClass('selected');
        });
    }

    <%// --------------------------------------------------------------------------------------------------- %>

    $(document).ready(function () {     

        if ($('#<%=Constants.PARM_SAVE_TYPE%>').val() === '2') {
            let patid = $('#' + '<%=Constants.PARM_PATIENT_ID%>').val();
            if (patid && patid > 0) {
                syncPriorityUIFromCheckbox();
            }
        }

        // Priority selection
        $('.priority-card-nc').on('click', function () {
            $('.priority-card-nc').removeClass('selected');
            $(this).addClass('selected');

            // Update hidden checkbox
            $('.priority-card-nc input[type="checkbox"]').prop('checked', false);
            $(this).find('input[type="checkbox"]').prop('checked', true);
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
        $('#pat_ref_save_btn_nc').on('click', function () {
            if (!validateForm()) {
                return;
            }
            let requestObj = {};
            //const fileInfo = getStoredFilesInfo();
            const selectedPriority = $('.priority-card-nc.selected').data('priority');
            const priorityMap = { 'routine': 1, 'urgent': 2, 'crisis': 3 };
            const pracID = $('#<%=Constants.PARM_PRACTITIONER_ID%>').val();
            const $submitBtn = $(this);
            const originalText = $submitBtn.html();

            $submitBtn.html('Processing...');

            let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($submitBtn);
            requestObj['<%=Constants.PARM_CLIENT_ID%>'] = $('#<%=Constants.PARM_CLIENT_ID%>').val();
            requestObj['<%=Constants.PARM_PRACTITIONER_ID%>'] = $('#userpracid').val();
            requestObj['<%=Constants.PARM_REFERRING_BY_USER_ID%>'] = $('#<%=Constants.PARM_REFERRING_BY_USER_ID%>').val();
            requestObj['patID'] = $('#<%=Constants.PARM_PATIENT_ID%>').val();
            requestObj['priority'] = priorityMap[selectedPriority] || 1;
            requestObj['referredtopracname'] = "";
            requestObj['referredtoorgname'] = "";
            requestObj['referredtopracemail'] = "";
            requestObj['referredtopracphone'] = "";
            requestObj['parentguardianname'] = "";
            requestObj['parentguardianrelationship'] = "";
            requestObj['parentguardianemail'] = "";
            requestObj['parentguardianphone'] = "";
            requestObj['parentguardianconsent'] = "3";
            requestObj['referraltype'] = "2";
            requestObj['notes'] = $('#pat_ref_reason_or_impression_nc').val();
            requestObj['reffileid'] = '';
            requestObj['isused'] = "0";
            requestObj['includediagnoses'] = false;
            requestObj['includeordersorprescriptions'] = false;
            requestObj['includeservicerecordstreatments'] = false;
            requestObj['includeservicerecordsassessementsorscreenings'] = false;
            requestObj['includeservicenotesnonconfidential'] = false;
            requestObj['includeservicenotesconfidential'] = false;
            requestObj['referredtopracid'] = pracID;
            requestObj['referralsourcename'] = $('#pat_ref_source_name_nc').val();
            requestObj['referralsourcerole'] = $('#pat_ref_source_role_nc').val();
            requestObj['referralsourceemail'] = $('#pat_ref_source_email_nc').val();
            requestObj['referralsourcephone'] = $('#pat_ref_source_phone_nc').val();
            requestObj['behavioralisssuesconcerns'] = $('#pat_ref_behavioral_issues').prop("checked");
            requestObj['academicconcerns'] = $('#pat_ref_academic_concerns').prop("checked");
            requestObj['anxietyordepressionconcerns'] = $('#pat_ref_anxiety_deoression').prop("checked");
            requestObj['familystressconcerns'] = $('#pat_ref_family_stress').prop("checked");
            requestObj['bullyingconcerns'] = $('#pat_ref_bullying').prop("checked");
            requestObj['otherconcerns'] = $('#pat_ref_other_concerns').val();
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