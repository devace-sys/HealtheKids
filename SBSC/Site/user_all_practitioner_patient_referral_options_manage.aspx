<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_practitioner_patient_referrals_manage.aspx.cs" Inherits="Spedmon.userAllPracPatReferralOptionsManage" %>

<Spedmon:HiddenInput ID="clientid" name="clientid" title="clientid" runat="server"/>

 <div class="referral-container-new-client">        

        <div class="header-nc">
            <h1><i class="fas fa-user-md"></i> Notifications</h1>
            <p>All incoming and outgoing referrals will be listed on the referral management screen. If an incoming referral is
            assigned, the assigned practitioner will receive additional referral notifications. The options below are additional
            notification options. Add staff who should receive email notifications for each of the priority levels.</p>
        </div>

        <div class="form-content-nc">
            <!-- Priority Section -->
            <div class="section-nc">
                <div class="line-container">
                    <div class="line"></div>
                    <h2 class="line-title">Incoming Referrals</h2>
                    <div class="line"></div>
                </div>

                <div class="row d-flex flex-wrap">
                    <div class="col-auto">
                        <div class="priority-card-nc routine-nc" data-priority="routine">
                            <input type="checkbox" id="pat_ref_routine_nc">
                            <i class="fas fa-clock"></i>
                            <div class="priority-label-nc">Routine</div>
                        </div>
                    </div>
                    <div class="col d-flex flex-wrap">
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllRoutineNotifications1" 
                                entityControlID = "useridforallroutinenotifications1"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                            </div>
 
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllRoutineNotifications2" 
                                entityControlID = "useridforallroutinenotifications2"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                         </div>
 
                         <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllRoutineNotifications3" 
                                entityControlID = "useridforallroutinenotifications3"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                         </div>
                     </div>
                </div>

                <div class="row d-flex flex-wrap">
                    <div class="col-auto">
                        <div class="priority-card-nc urgent-nc" data-priority="urgent">
                            <input type="checkbox" id="pat_ref_urgent_nc">
                            <i class="fas fa-exclamation"></i>
                            <div class="priority-label-nc">Urgent</div>
                        </div>
                    </div>
                    <div class="col d-flex flex-wrap">
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllUrgentNotifications1" 
                                entityControlID = "useridforallurgentnotifications1"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                        </div>
 
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllUrgentNotifications2" 
                                entityControlID = "useridforallurgentnotifications2"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                        </div>
 
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllUrgentNotifications3" 
                                entityControlID = "useridforallurgentnotifications3"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                        </div>
                    </div>
                </div>

                <div class="row d-flex flex-wrap">
                    <div class="col-auto">
                        <div class="priority-card-nc crisis-nc" data-priority="crisis">
                            <input type="checkbox" id="pat_ref_crisis_nc">
                            <i class="fas fa-exclamation-triangle"></i>
                            <div class="priority-label-nc">Crisis</div>
                        </div>
                    </div>

                    <div class="col d-flex flex-wrap">
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllCrisisNotifications1" 
                                entityControlID = "useridforallcrisisnotifications1"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                        </div>
 
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllCrisisNotifications2" 
                                entityControlID = "useridforallcrisisnotifications2"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                        </div>
 
                        <div class="col-auto">
                            <Spedmon:DataEntryRowSelectUser 
                                ID              = "selectUserForAllCrisisNotifications3" 
                                entityControlID = "useridforallcrisisnotifications3"                
                                rowLabel        = "Select User" 
                                runat           = "server">
                            </Spedmon:DataEntryRowSelectUser>
                        </div>
                    </div>
                </div>
            </div>

            <div class="line-container">
                <div class="line"></div>
                <h2 class="line-title">Custom Referral Messaging</h2>
                <div class="line"></div>
            </div>

            <div class="row d-flex flex-wrap mb-4">
                <div class="col-auto">
                    <h5>Are you feeling UNSAFE - YES (English)</h5>
                    <Spedmon:RichTextAreaBox 
                        id    = "announcementcontent1" 
                        name  = "announcementcontent1" 
                        title = "Enter content"
                        showControls = "false"
                        runat = "server">
                    </Spedmon:RichTextAreaBox> 
                </div>

                <div class="col-auto">
                    <h5>Are you feeling UNSAFE - YES (Spanish)</h5>
                    <Spedmon:RichTextAreaBox 
                        id           = "announcementcontent2" 
                        name         = "announcementcontent2" 
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox> 
                </div>
            </div>

            <div class="row d-flex flex-wrap">
                <div class="col-auto">
                    <h5>Are you feeling UNSAFE - NO (English)</h5>
                    <Spedmon:RichTextAreaBox 
                        id           = "announcementcontent3" 
                        name         = "announcementcontent3" 
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox> 
                </div>

                <div class="col-auto">
                    <h5>Are you feeling UNSAFE - NO (Spanish)</h5>
                    <Spedmon:RichTextAreaBox 
                        id           = "announcementcontent4" 
                        name         = "announcementcontent4" 
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox> 
                </div>
            </div>

            
            <!-- Save Section -->
            <div class="submit-section-nc">
                <button type="button" id="pat_ref_save_btn_nc" class="submit-btn-nc">
                    <i class="fas fa-paper-plane"></i>
                    Save Referral Option
                </button>
                <div class="success-checkmark-nc" id="success-animation-nc"></div>
            </div>
        </div>
     <div id="enYesMsg" runat="server" style="display:none;">
         <p>We understand that you are feeling unsafe, and we want to ensure you get the help you need right away. Please know you are not alone. Here are immediate resources available to you:<br />-<span style="font-size: 12pt;"><strong>Call 911</strong></span> if you are in immediate danger.<br />-<span style="font-size: 12pt;"><strong>Text HOME to 741741</strong></span> to connect with a trained Crisis Text Line counselor 24/7.<br />-<span style="font-size: 12pt;"><strong>Call the National Suicide Prevention Lifeline at 988</strong></span> for free and confidential support, available 24/7.<br /><br />If you are at school, please go to the nearest trusted adult (teacher, counselor, or staff member) right away for assistance. You can also submit this form, and a school counselor will follow up with you as soon as possible.</p>
     </div>
     <div id="esYesMsg" runat="server" style="display:none;">
         <p>Entendemos que se siente inseguro y queremos asegurarnos de que reciba la ayuda que necesita de inmediato. Tenga en cuenta que no est&aacute; solo. Aqu&iacute; tiene recursos inmediatos disponibles:<br />- <span style="font-size: 12pt;"><strong>Llame al 911</strong></span> si se encuentra en peligro inminente.<br />- Env&iacute;e un mensaje de <span style="font-size: 12pt;"><strong>texto con la palabra HOME al 741741</strong></span> para comunicarse con un consejero capacitado de Crisis Text Line, disponible las 24 horas, los 7 d&iacute;as de la semana.<br />- <span style="font-size: 12pt;"><strong>Llame a la L&iacute;nea Nacional de Prevenci&oacute;n del Suicidio al 988</strong></span> para obtener apoyo gratuito y confidencial, disponible las 24 horas, los 7 d&iacute;as de la semana.<br /><br />Si est&aacute; en la escuela, acuda de inmediato al adulto de confianza m&aacute;s cercano (maestro, consejero o miembro del personal) para recibir ayuda. Tambi&eacute;n puede enviar este formulario y un consejero escolar se pondr&aacute; en contacto con usted lo antes posible.</p>
     </div>
     <div id="enNoMsg" runat="server" style="display:none;">
         <p>Thank you for letting us know. We understand that reaching out can be difficult, and we are here to support you. A school counselor will review your request and follow up with you as soon as possible. If your situation changes or becomes urgent, please reach out to a trusted adult or use one of the crisis resources below for immediate support:<br />-<span style="font-size: 12pt;"><strong>Text HOME to 741741</strong></span> for 24/7 crisis counseling.<br />-<span style="font-size: 12pt;"><strong>Call the National Suicide Prevention Lifeline at 988</strong></span> for free, confidential support.<br /><br />Your safety and well-being are our top priority.</p>
     </div>
     <div id="esNoMsg" runat="server" style="display:none;">
         <p>Gracias por informarnos. Entendemos que contactar a alguien puede ser dif&iacute;cil y estamos aqu&iacute; para apoyarte. Un consejero escolar revisar&aacute; tu solicitud y se pondr&aacute; en contacto contigo lo antes posible. Si tu situaci&oacute;n cambia o se vuelve urgente, comun&iacute;cate con un adulto de confianza o utiliza uno de los recursos de crisis a continuaci&oacute;n para obtener apoyo inmediato:<br />- <span style="font-size: 12pt;"><strong>Env&iacute;a HOME por mensaje de texto al 741741</strong></span> para recibir asesoramiento en caso de crisis las 24 horas, los 7 d&iacute;as de la semana.<br />- <span style="font-size: 12pt;"><strong>Llama a la L&iacute;nea Nacional de Prevenci&oacute;n del Suicidio al 988</strong></span> para obtener apoyo gratuito y confidencial.<br /><br />Tu seguridad y bienestar son nuestra prioridad.</p>
     </div>
</div>

<script type="text/javascript">  

    // Submit button
    $('#pat_ref_save_btn_nc').on('click', function () {
        const $submitBtn = $(this);
        const originalText = $submitBtn.html();

        $submitBtn.html('Processing...');
        let $waitingIcon = MBA.ComponentCommon.fnElemDisableAndAddSpinner($submitBtn);

        let requestObj = {};

        requestObj['<%=Constants.PARM_CLIENT_ID%>'] = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        requestObj['useridforallroutinenotifications1'] = $('#useridforallroutinenotifications1').val();
        requestObj['useridforallroutinenotifications2'] = $('#useridforallroutinenotifications2').val();
        requestObj['useridforallroutinenotifications3'] = $('#useridforallroutinenotifications3').val();
        requestObj['useridforallurgentnotifications1']  = $('#useridforallurgentnotifications1').val();
        requestObj['useridforallurgentnotifications2']  = $('#useridforallurgentnotifications2').val();
        requestObj['useridforallurgentnotifications3']  = $('#useridforallurgentnotifications3').val();
        requestObj['useridforallcrisisnotifications1']  = $('#useridforallcrisisnotifications1').val();
        requestObj['useridforallcrisisnotifications2']  = $('#useridforallcrisisnotifications2').val();
        requestObj['useridforallcrisisnotifications3']  = $('#useridforallcrisisnotifications3').val();
        requestObj['englishYesMessageTemplate']         = $('#announcementcontent1').val();
        requestObj['spanishYesMessageTemplate']         = $('#announcementcontent2').val();
        requestObj['englishNoMessageTemplate']          = $('#announcementcontent3').val();
        requestObj['spanishNoMessageTemplate']          = $('#announcementcontent4').val();
        requestObj['savetype'] = "1";


        let requestJSON = JSON.stringify(requestObj);
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PractionerPatientReferalOptions.URL_SAVE_REFERAL_OPTION_BASE()%>', requestJSON, null)
            .then(responseData => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                $submitBtn.html(originalText);
                window.close();
            })
            .catch(err => {
                MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                $submitBtn.html(originalText);
                MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
            });
    });

    function htmlEncode(str) {
        const div = document.createElement('div');
        div.textContect = str;
        return div.innerHTML;
    }

    $(document).ready(function () {
    });

</script>