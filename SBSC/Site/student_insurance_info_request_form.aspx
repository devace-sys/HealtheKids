<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="student_insurance_info_request_form.aspx.cs" Inherits="Spedmon.StudentInsuranceInfoRequestForm" subTitle="Student Insurance Information Request"%>

<%/*================================== Page Init Is OK  ==================================*/%>

<%if (pageInitIsOK == true) {%>

<%/*========== Common Header  ==========*/%>

<div class="container">
   <div class="row">
      <div class="col-4">
         <img src="<%=clientLogoDataURL%>"
            alt="<%=clientName%>"
            style="width:80%;height:80%;object-fit:contain;display:block;">
      </div> <!-- col -->
      <div class="col-8">
          <h1 class="text-center"><%=clientName%></h1>            

          <%if(commonHeaderShowRequestTitle   == true){%><h2 class="text-center"><%=GetLocalResourceObject("Common_Header_Content")%></h2><%}%>

          <%if(commonHeaderShowRequestTitle   == true){%><div><%=requestMessageContent%></div><%}%>

          <%if(commonHeaderShowRequestTitle   == true){%><h5 class="text-center font-weight-bold"><%=GetLocalResourceObject("Common_Header_Text_Note")%></h5><%}%>
           
      </div> <!-- col -->      
   </div> <!-- row -->
</div> <!-- container -->

<hr/>            

<%/*========== Info Request ==========*/%>

<%if (responseMode == false){%>

<%/*========== Need A Language Selection ==========*/%>

<%if (promptForWhat == 1){%>

<div class="d-flex flex-column justify-content-center align-items-center">
<a class="btn btn-info m-1" href="<%=requestURL_EN%>">Continue in english</a>
<a class="btn btn-info m-1" href="<%=requestURL_ES%>">Continuar en español</a>
</div>

<%}else if (promptForWhat == 2) {%>

<form id="info-request-response-frm" method="post" action="student_insurance_info_request_form.aspx">
<h3 class="text-center mb-4"><%=GetLocalResourceObject("Form_Title")%></h3>
<input id="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" 
                   name="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" 
                   type="hidden" 
                   value="<%=ptkn%>" />

<input id="<%= Spedmon.Constants.PARM_FORM_REQUEST_OR_RESPONSE %>" 
                   name="<%= Spedmon.Constants.PARM_FORM_REQUEST_OR_RESPONSE %>" 
                   type="hidden" 
                   value="<%= Spedmon.Constants.FRM_RSP %>" />

<input id    = "<%=Spedmon.Constants.PARM_LANGUAGE%>"                    
       name  = "<%=Spedmon.Constants.PARM_LANGUAGE%>" 
       type  = "hidden" 
       value = "<%=rd.language%>" />

<input id="<%=PARM_RESPONDER_IS_PARENT_GUARDIAN%>"
    name="<%=PARM_RESPONDER_IS_PARENT_GUARDIAN%>" 
    type="hidden" 
    value="1"  />

<div class="container">
    
<div class="row">
<div class="col-12 col-md-2">
    

                <label for="<%=PARM_STUDENT_FIRST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("Student_First_Name_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_STUDENT_FIRST_NAME%>" 
                       name="<%=PARM_STUDENT_FIRST_NAME%>"                       
                       placeholder="<%=GetLocalResourceObject("Student_First_Name_PlaceHolder")%>"
                       type="text" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_STUDENT_LAST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("Student_Last_Name_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_STUDENT_LAST_NAME%>" 
                       name="<%=PARM_STUDENT_LAST_NAME%>" 
                       placeholder="<%=GetLocalResourceObject("Student_Last_Name_PlaceHolder")%>"
                       type="text" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_STUDENT_DOB%>" class="custom-label">
                    <%=GetLocalResourceObject("Student_DOB_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_STUDENT_DOB%>" 
                       name="<%=PARM_STUDENT_DOB%>" 
                       placeholder=""
                       type="date" min="1900-01-01" max="<%=MAX_DOB%>" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_STUDENT_ID%>" class="custom-label">
                    <%=GetLocalResourceObject("Student_ID_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_STUDENT_ID%>" 
                       name="<%=PARM_STUDENT_ID%>" 
                       placeholder="<%=GetLocalResourceObject("Student_ID_PlaceHolder")%>"
                       type="text" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_INSURANCE_CARRIER_CODE%>" class="custom-label">
                    <%=GetLocalResourceObject("Insurance_Carrier_ID")%>
                </label>
                <select class="form-control form-control-sm" 
                        id="<%=PARM_INSURANCE_CARRIER_CODE%>" 
                        name="<%=PARM_INSURANCE_CARRIER_CODE%>" required="required">
                        
                    <%=insuranceCarrierOptions%>
                </select>
</div> <!-- col -->


<div class="col-12 col-md-2">
                <label for="<%=PARM_INSURANCE_MEMBER_ID%>" class="custom-label">
                    <%=GetLocalResourceObject("Insurance_Memeber_ID")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_INSURANCE_MEMBER_ID%>" 
                       name="<%=PARM_INSURANCE_MEMBER_ID%>" 
                       placeholder="<%=GetLocalResourceObject("Insurance_Member_PlaceHolder")%>"
                       type="text" required="required" />
</div> <!-- col -->

</div> <!-- row -->

<div class="row">
<div id="carrier-other-cont" class="col-12 col-md-2">
                <label for="<%=PARM_INSURANCE_CARRIER_OTHER_NAME%>" class="custom-label">           
                    <%=GetLocalResourceObject("Insurance_Carrier_Other_Name")%>                   
                </label>
                <input class="form-control form-control-sm" 
                       id="<%=PARM_INSURANCE_CARRIER_OTHER_NAME%>" 
                       name="<%=PARM_INSURANCE_CARRIER_OTHER_NAME%>" 
                       placeholder="<%=GetLocalResourceObject("Insurance_Carrier_Other_Name_PlaceHolder")%>" 
                       type="text" />
</div> <!-- col -->
</div> <!-- row -->

<!--  =====================================================================================================  -->

<div class="row">
<div class="col-12 col-md-2">
                <label for="<%=PARM_STUDENT_FIRST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("Responder_First_Name_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_RESPONDER_FIRST_NAME%>" 
                       name="<%=PARM_RESPONDER_FIRST_NAME%>"                       
                       placeholder="<%=GetLocalResourceObject("Responder_First_Name_PlaceHolder")%>"
                       type="text" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_STUDENT_LAST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("Responder_Last_Name_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_RESPONDER_LAST_NAME%>" 
                       name="<%=PARM_RESPONDER_LAST_NAME%>"                       
                       placeholder="<%=GetLocalResourceObject("Responder_Last_Name_PlaceHolder")%>"
                       type="text" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_RESPONDER_EMAIL%>" class="custom-label">
                    <%=GetLocalResourceObject("Responder_Email_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_RESPONDER_EMAIL%>" 
                       name="<%=PARM_RESPONDER_EMAIL%>"                       
                       placeholder="<%=GetLocalResourceObject("Responder_Email_PlaceHolder")%>"
                       type="email" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_RESPONDER_PHONE%>" class="custom-label">
                    <%=GetLocalResourceObject("Responder_Phone_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_RESPONDER_PHONE%>" 
                       name="<%=PARM_RESPONDER_PHONE%>"                       
                       placeholder="<%=GetLocalResourceObject("Responder_Phone_PlaceHolder")%>"
                       type="tel" />
</div> <!-- col -->

</div> <!-- row -->

<!--  =====================================================================================================  -->
<div class="row mb-0 py-1">
<div class="col-12 col-md-8">
                <div class="d-flex mt-2 align-items-start ">
                    <div class="checkbox-wrapper-19 mr-2">
                        <input type="radio" id="consent_yes" 
                               name="<%=PARM_CONSENT%>" 
                               value="1" required="required"  />
                        <label class="check-box" for="consent_yes"></label>
                    </div>
                    <label for="consent_yes" class="mr-4" style="font-weight: 200; font-size: 0.75em;">
                    <span style="font-weight: bold; text-decoration: underline;"><%=GetLocalResourceObject("CONSENT_YES")%></span> <%=GetLocalResourceObject("CONSENT_YES_NO_COMMON")%>
                    </label>
                    
                    <div class="checkbox-wrapper-19 mr-2">
                        <input type="radio" id="consent_no" 
                               name="<%=PARM_CONSENT%>" 
                               value="0" required="required" />
                        <label class="check-box" for="consent_no"></label>
                    </div>
                    <label for="consent_no" style="font-weight: 200; font-size: 0.75em;">
                       <span style="font-weight: bold; text-decoration: underline;"><%=GetLocalResourceObject("CONSENT_NO")%></span> <%=GetLocalResourceObject("CONSENT_YES_NO_COMMON")%>
                    </label>
                </div>
</div> <!-- col -->

<div class="col-12 col-md-4">            
              <label style="font-weight: bold; font-size: 0.8rem" class="custom-label"><%=GetLocalResourceObject("SIGNATURE_LABEL")%></label>
              <br />
              <canvas id="responder-signature-img" style="border:1px solid"></canvas>
              <textarea id="<%=PARM_RESPONDER_SIGNATURE_IMG_DATA%>" name="<%=PARM_RESPONDER_SIGNATURE_IMG_DATA%>" style="display:none;"></textarea>
</div> <!-- col -->
</div> <!-- row -->

<!-- Submit and Clear Buttons -->

<div class="row mb-2 py-2">
            <div class="col-6">
                <button type="reset"
                        id="btn-clear-form"
                        class="btn btn-secondary btn-block">
                    <span><%=GetLocalResourceObject("CLEAR_LABEL")%></span>
                </button>
            </div> <!-- col -->
            <div class="col-6 d-flex justify-content-end">
                <button type="submit"
                        id="btn-submit-form"
                        class="btn btn-primary btn-block">
                    <span><%=GetLocalResourceObject("SUBMIT_LABEL")%></span>
                </button>
            </div> <!-- col -->
        </div> <!-- row -->
</div> <!-- container -->
</form>

<script type="text/javascript" src="third-party/signature-pad.min.js"></script>

<script type="text/javascript">

    let $studentFirstName = null;
    let $studentLastName = null;
    let $studentDOB = null;
    let $studentId = null;
    let $insuranceMemberId = null;
    let $insuranceCarrierSel   = null;
    let $otherCarrierCont = null;
    let responderSigPad        = null;
    let $responderSigTA = null;
    let $responderFirstName = null;
    let $responderLastName = null;
    let $responderEmail = null;
    let $responderPhone = null;

    $(document).ready(function () {

        let responderSigCanvas = document.getElementById('responder-signature-img');

        responderSigPad = new SignaturePad(responderSigCanvas);

        $studentFirstName = $('#<%=PARM_STUDENT_FIRST_NAME%>');
        $studentLastName = $('#<%=PARM_STUDENT_LAST_NAME%>');
        $studentDOB = $('#<%=PARM_STUDENT_DOB%>');
        $studentId = $('#<%=PARM_STUDENT_ID%>');
        $insuranceMemberId = $('#<%=PARM_INSURANCE_MEMBER_ID%>');

        $responderSigTA = $('#<%=PARM_RESPONDER_SIGNATURE_IMG_DATA%>');
        $responderFirstName = $('#<%=PARM_RESPONDER_FIRST_NAME%>');
        $responderLastName = $('#<%=PARM_RESPONDER_LAST_NAME%>');
        $responderEmail = $('#<%=PARM_RESPONDER_EMAIL%>');
        $responderPhone = $('#<%=PARM_RESPONDER_PHONE%>');

        $insuranceCarrierSel   = $('#<%=PARM_INSURANCE_CARRIER_CODE%>');
        $otherCarrierCont      = $('#carrier-other-cont');

        $($otherCarrierCont).hide();

        $($insuranceCarrierSel).on('change', function () {
            let carrierSel = $($insuranceCarrierSel).val();
           
            if (carrierSel == '<%=Spedmon.InsuranceCarriers.OPTION_VALUE_OTHER%>') {
                $($otherCarrierCont).show();
                $($insuranceMemberId).val('');
            }
            else if (carrierSel == '<%=Spedmon.InsuranceCarriers.OPTION_VALUE_NO_INSURANCE%>') {
                $($otherCarrierCont).hide();
                $($insuranceMemberId).val('None');
            }
            else {
                $($otherCarrierCont).hide();
                $($insuranceMemberId).val('');
            }
        });
        let submitAttempted = false;
        $('#btn-submit-form').on('click', function () {
            let consentChecked = $('input[name="<%=PARM_CONSENT%>"]:checked').length > 0;
            if (!consentChecked) {
                submitAttempted = true;
                let $consentContainer = $('#consent_yes').closest('.col-12.col-md-8');
                $consentContainer.addClass('consent-required');
                $('#consent_yes').focus();
                return false;
            }
            if (!responderSigPad.isEmpty()) {
                $($responderSigTA).val(responderSigPad.toDataURL());
            } else {
                $($responderSigTA).val('');
            }

        });

        $('input[name="<%=PARM_CONSENT%>"]').on('change', function () {
            if (submitAttempted && $(this).is(':checked')) {
                $('#consent_yes')
                    .closest('.col-12.col-md-8')
                    .removeClass('consent-required')
            }
        });

        $('#info-request-response-frm').on('reset', function () {
            responderSigPad.clear();
            $($responderSigTA).val('');
            $($otherCarrierCont).hide();
            $('.consent-required').removeClass('consent-required');
            submitAttempted = false;
        });

    });
</script>

<%} /* Prompt for requested data */%>

<%/*========== Info Response ==========*/%>

<%} else {%>

<div class="container">
<div class="row">
<div class="col-12">
<div class="alert alert-success">
<h3 class="text-center">
<%=GetLocalResourceObject("Response_Title")%>
</h3>
<h4 class="text-center">            

</h4>
</div> <!-- alert -->
</div> <!-- col -->
</div> <!-- row -->

<%if(responseShowNoInsuranceOptions == true){%>
<div class="row mt-2">
<div class="col-12">
<div class="alert alert-info">
<h3 class="text-center"><%=GetLocalResourceObject("Covered_CA_Message_Top")%></h3>
<h4 class="text-center"><%=GetLocalResourceObject("Covered_CA_Message_Bottom_Left")%> <a style="color:#000;" href="https://www.coveredca.com/">Covered California</a> <%=GetLocalResourceObject("Covered_CA_Message_Bottom_Right")%></h4>
</div> <!-- alert -->
</div> <!-- col -->
</div> <!-- row -->
<%}%>
</div> <!-- container -->
<%}%>

<%} else {%>

<%/*================================== Page Init Is NOT OK  ==================================*/%>

<%/*========== Not or no longer a Valid Request  ==========*/%>

<div class="alert alert-info">
<p class="text-center"><%=GetLocalResourceObject("Page_Init_Not_OK")%></p>
</div>

<%}%>