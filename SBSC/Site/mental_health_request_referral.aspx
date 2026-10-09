<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="mental_health_request_referral.aspx.cs" Inherits="Spedmon.MentalHealthReqesutReferralForm" subTitle="Mental Health Referral Request"%>

<%/*================================== Page Init Is OK  ==================================*/%>

<%if (pageInitIsOK == true) {%>

<%/*========== Common Header  ==========*/%>

<div class="container">
   <div class="row align-items-center">
      <div class="col-4">
         <img src="<%=clientLogoDataURL%>"
            alt="<%=clientName%>"
            style="width:80%;height:80%;object-fit:contain;display:block;">
      </div> <!-- col -->
      <div class="col-8">
          <h1 class="text-center"><%=clientName%></h1>                       
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

<form id="info-request-response-frm" method="post" action="mental_health_request_referral.aspx">
<h3 class="text-center mb-4"><%=GetLocalResourceObject("Form_Title")%></h3>

<div class="row justify-content-center align-items-center">
    <div class="col-12 col-md-4">
        <label for="pat_ref_source_role_nc">
            <%=GetLocalResourceObject("Source_Role_Label")%>
        </label>
        <select type="text" id="pat_ref_source_role_nc" name="pat_ref_source_role_nc" class="form-control" placeholder="Role" onchange="changeSourceRole(this.value)" required="required">
            <option value="" selected disabled hidden><%=GetLocalResourceObject("Role_Option0")%></option>
            <option value="Parent/Guardian" ><%=GetLocalResourceObject("Role_Option1")%></option>
            <option value="Self" ><%=GetLocalResourceObject("Role_Option2")%></option>
            <option value="Teacher" ><%=GetLocalResourceObject("Role_Option3")%></option>
            <option value="Nurse" ><%=GetLocalResourceObject("Role_Option4")%></option>
            <option value="Peer" ><%=GetLocalResourceObject("Role_Option5")%></option>
            <option value="Other" ><%=GetLocalResourceObject("Role_Option6")%></option>
        </select>
    </div>
</div>
    <%if(commonHeaderShowRequestTitle   == true){%>
    <div id="feelingSafeDiv" class="row justify-content-center align-items-center transition-div-bottom">
        <div class="col-12 col-md-6">
            <div class="safety-container">
                <div class="button-group">
                    <div class="choice-btn custom-yes" data-value="Yes">Yes</div>
                    <p class="question">Are feeling unsafe right now?</p>
                    <div class="choice-btn custom-no" data-value="No">No</div>
                </div>
                <input id="feelingsafevalue" type="hidden" name="feelingsafevalue" title="feelingsafevalue"/>
            </div>
        </div>
    </div>
    <%}%>

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

<div class="container">

    <%if(commonHeaderShowRequestTitle   == true){%><div id="feelingSafeMessage" class="transition-div-bottom"></div><%}%>

<!--  =====================================================================================================  -->

<div class="row pt-3">
<div class="col-12 col-md-2">
                <label for="<%=PARM_RESPONDER_FIRST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("Responder_First_Name_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_RESPONDER_FIRST_NAME%>" 
                       name="<%=PARM_RESPONDER_FIRST_NAME%>"                       
                       placeholder="<%=GetLocalResourceObject("Responder_First_Name_PlaceHolder")%>"
                       type="text" required="required" />
</div> <!-- col -->

<div class="col-12 col-md-2">
                <label for="<%=PARM_RESPONDER_LAST_NAME%>" class="custom-label">
                    <%=GetLocalResourceObject("Responder_Last_Name_Label")%>
                </label>
                <input class="form-control form-control-sm custom-input" 
                       id="<%=PARM_RESPONDER_LAST_NAME%>" 
                       name="<%=PARM_RESPONDER_LAST_NAME%>"                       
                       placeholder="<%=GetLocalResourceObject("Responder_Last_Name_PlaceHolder")%>"
                       type="text" required="required" />
</div> <!-- col -->

</div> <!-- row -->
    
<div class="row pt-3">
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
            <label for="<%=PARM_STUDENT_TEACHER%>" class="custom-label">
                <%=GetLocalResourceObject("Student_Teacher_Label")%>
            </label>
            <input class="form-control form-control-sm custom-input" 
                    id="<%=PARM_STUDENT_TEACHER%>" 
                    name="<%=PARM_STUDENT_TEACHER%>" 
                    placeholder="<%=GetLocalResourceObject("Student_Teacher_PlaceHolder")%>"
                    type="text" />
</div> <!-- col -->

</div> <!-- row -->

<!--  =====================================================================================================  -->

<div class="row pt-3">

<div class="col-12 col-md-3">
    <textarea id="<%=PARM_DETAIL_INFO%>" name="<%=PARM_DETAIL_INFO%>" class="form-control" placeholder="<%=GetLocalResourceObject("Detail_Info_Placeholder")%>"></textarea>
</div> <!-- col -->
<div class="col-12 col-md-9">
    <div class="row">
        <h5 class="text-center"><%=GetLocalResourceObject("Responder_Choice_Label")%></h5>
        <div class="col-12 col-md-4">
                        <label for="<%=PARM_RESPONDER_EMAIL%>" class="custom-label">
                            <%=GetLocalResourceObject("Responder_Email_Label")%>
                        </label>
                        <input class="form-control form-control-sm custom-input" 
                               id="<%=PARM_RESPONDER_EMAIL%>" 
                               name="<%=PARM_RESPONDER_EMAIL%>"                       
                               placeholder="<%=GetLocalResourceObject("Responder_Email_PlaceHolder")%>"
                               type="email" />
        </div> <!-- col -->

        <div class="col-12 col-md-4">
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
    let $responderFirstName = null;
    let $responderLastName = null;
    let $detaiInfo = null;
    let $responderEmail = null;
    let $responderPhone = null;
    let $selectedValue = "No";

    $(document).ready(function () {

        $studentFirstName = $('#<%=PARM_STUDENT_FIRST_NAME%>');
        $studentLastName = $('#<%=PARM_STUDENT_LAST_NAME%>');
        $studentDOB = $('#<%=PARM_STUDENT_DOB%>');
        $studentId = $('#<%=PARM_STUDENT_ID%>');
        $responderFirstName = $('#<%=PARM_RESPONDER_FIRST_NAME%>');
        $responderLastName = $('#<%=PARM_RESPONDER_LAST_NAME%>');
        $detaiInfo = $('#<%=PARM_DETAIL_INFO%>');
        $responderEmail = $('#<%=PARM_RESPONDER_EMAIL%>');
        $responderPhone = $('#<%=PARM_RESPONDER_PHONE%>');

        let submitAttempted = false;
        $('#btn-submit-form').on('click', function () {
             submitAttempted = true;
        });

        changeSourceRole("");

        $(".choice-btn").on('click', function () {
            $(".choice-btn").removeClass("customyesnoselected");
            $(this).addClass("customyesnoselected");

            $selectedValue = $(this).data("value");
            
            updateFeelingSafeMessage($selectedValue);
        });
    });

    function updateFeelingSafeMessage(newval) {
        const params = new URLSearchParams(window.location.search);
        const lang = params.get('lang');
        $('#<%=PARM_FEELING_SAFE%>').val($selectedValue);
        console.log($('#<%=PARM_FEELING_SAFE%>').val());
        if (lang == 'es') {
            if (newval == 'No') {
                $('#feelingSafeMessage').html('<%=spanishNoMessageTemplate%>');
            } else {
                $('#feelingSafeMessage').html('<%=spanishYesMessageTemplate%>');
            }
        }
        else {
            if (newval == 'No') {
                $('#feelingSafeMessage').html('<%=englishNoMessageTemplate%>');
            } else {
                $('#feelingSafeMessage').html('<%=englishYesMessageTemplate%>');
            }
        }

        $('#feelingSafeMessage').addClass("show");
    };

    function changeSourceRole(value) {
        console.log(value);
        if (value == "Parent/Guardian" || value == "Self") {
            $('#feelingSafeDiv').addClass("show");
        }
        else {
            $('#feelingSafeDiv').removeClass("show");
            $('#feelingSafeMessage').removeClass("show");
        }
    }
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
</div> <!-- container -->
<%}%>

<%} else {%>

<%/*================================== Page Init Is NOT OK  ==================================*/%>

<%/*========== Not or no longer a Valid Request  ==========*/%>

<div class="alert alert-info">
<p class="text-center"><%=GetLocalResourceObject("Page_Init_Not_OK")%></p>
</div>

<%}%>