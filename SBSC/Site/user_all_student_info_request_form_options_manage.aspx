<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_student_info_request_form_options_manage.aspx.cs" Inherits="Spedmon.userAllStudentInfoRequestFormOptionsManage" %>

<div class="d-flex justify-content-center mb-1">
    <Spedmon:DataEntryRowSelectClient 
        ID="selectClient" 
        entityControlID="clientid" 
        onSpedmonInputData="clientIDUpdated()" 
        rowLabel="Client" 
        dataEntryRowRenderAs="FIELD"         
        runat="server">
    </Spedmon:DataEntryRowSelectClient>
</div>

 <div class="referral-container-new-client">        

        <div class="header-nc">
            <h1>Custom Insurance Information Request Messaging</h1>
            <p>Health e Kids insurance information request form messaging can be customize below for both targeted (students with services) and broad public outreach messaging.</p>
        </div>

        <div class="form-content-nc">

            <div class="row d-flex flex-wrap mb-4">
                <div class="col-auto">
                    <h5>Targeted Insurance Custom Messaging (English)</h5>
                    <Spedmon:RichTextAreaBox 
                        id    = "insuranceInfoRequestMessageBodyContentPrivateEN" 
                        name  = "insuranceinforequestmessagebodycontenten" 
                        title = "Enter content"
                        showControls = "false"
                        runat = "server">
                    </Spedmon:RichTextAreaBox> 
                </div>

                <div class="col-auto">
                    <h5>Targeted Insurance Custom Messaging (Spanish)</h5>
                    <Spedmon:RichTextAreaBox 
                        id           = "insuranceInfoRequestMessageBodyContentPrivateES" 
                        name         = "insuranceinforequestmessagebodycontentes" 
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox> 
                </div>
            </div>

            <div class="row d-flex flex-wrap">
                <div class="col-auto">
                    <h5>Broad Insurance Custom Messaging (English)</h5>
                    <Spedmon:RichTextAreaBox 
                        id           = "insuranceInfoRequestMessageBodyContentPublicEN" 
                        name         = "insuranceinforequestmessagebodycontenten" 
                        title        = "Enter content"
                        showControls = "false"
                        runat        = "server">
                    </Spedmon:RichTextAreaBox> 
                </div>

                <div class="col-auto">
                    <h5>Broad Insurance Custom Messaging (Spanish)</h5>
                    <Spedmon:RichTextAreaBox 
                        id           = "insuranceInfoRequestMessageBodyContentPublicES" 
                        name         = "insuranceinforequestmessagebodycontentes" 
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
                    Save Messages
                </button>
                <div class="success-checkmark-nc" id="success-animation-nc"></div>
            </div>
        </div>
     <div id="enPrivateMsg" runat="server" style="display:none;">
         <p>Providing this information does not obligate your child to receive any school-based medical or mental health services. If your child does receive services, this information may be used to help cover the cost of care. Thank you for helping us maintain accurate records to support student health and wellness.</p>
     </div>
     <div id="esPrivateMsg" runat="server" style="display:none;">
         <p>Proporcionar esta información no obliga a que su hijo(a) reciba servicios médicos o de salud mental en la escuela. Si su hijo(a) recibe servicios, esta información puede utilizarse para ayudar a cubrir el costo de la atención. Gracias por ayudarnos a mantener registros precisos que apoyan la salud y el bienestar de los estudiantes.</p>
     </div>
     <div id="enPublicMsg" runat="server" style="display:none;">
         <p>Providing this information does not obligate your child to receive any school-based medical or mental health services. If your child does receive services, this information may be used to help cover the cost of care. Thank you for helping us maintain accurate records to support student health and wellness.</p>
     </div>
     <div id="esPublicMsg" runat="server" style="display:none;">
         <p>Proporcionar esta información no obliga a que su hijo(a) reciba servicios médicos o de salud mental en la escuela. Si su hijo(a) recibe servicios, esta información puede utilizarse para ayudar a cubrir el costo de la atención. Gracias por ayudarnos a mantener registros precisos que apoyan la salud y el bienestar de los estudiantes.</p>
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
        requestObj['insuranceInfoRequestMessageBodyContentEN'] = $('#insuranceInfoRequestMessageBodyContentPrivateEN').val();
        requestObj['insuranceInfoRequestMessageBodyContentES'] = $('#insuranceInfoRequestMessageBodyContentPrivateES').val();
        requestObj['savetype'] = "1";

        let requestObj1 = {};

        requestObj1['<%=Constants.PARM_CLIENT_ID%>'] = $('#<%=Constants.PARM_CLIENT_ID%>').val();
        requestObj1['insuranceInfoRequestMessageBodyContentEN'] = $('#insuranceInfoRequestMessageBodyContentPublicEN').val();
        requestObj1['insuranceInfoRequestMessageBodyContentES'] = $('#insuranceInfoRequestMessageBodyContentPublicES').val();
        requestObj1['savetype'] = "1";


        let requestJSON = JSON.stringify(requestObj);
        let requestJSON1 = JSON.stringify(requestObj1);
        MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PatientInfoRequestsFormOptions.URL_SAVE_REFERAL_OPTION_BASE()%>', requestJSON, null)
            .then(responseData => {
                MBA.ComponentCommon.fnAjaxCallAsmxWebMethod('<%=Spedmon.PatientInfoRequestsPublicFormOptions.URL_SAVE_REFERAL_OPTION_BASE()%>', requestJSON1, null)
                    .then(responseData1 => {
                        MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                        $submitBtn.html(originalText);
                        window.close();
                    })
                    .catch(err => {
                        MBA.ComponentCommon.fnElemEnableAndRemoveSpinner($submitBtn, $waitingIcon);
                        $submitBtn.html(originalText);
                        MBA.ComponentCommon.fnCreateOneTimeAlertDialog('Sorry There Was A Problem', err.message, {});
                    });
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

    function clientIDUpdated() {
        var id = $('#clientid').val();
        if (id) {
            var params = new URLSearchParams(location.search);
            params.set('<%=Constants.PARM_CLIENT_ID%>', id);
            location.href = location.pathname + '?' + params.toString();
        }
    }

    $(document).ready(function () {
    });

</script>