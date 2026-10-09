<%@Page Language="C#" AutoEventWireup="true" CodeBehind="request_file_upload_public.aspx.cs" Inherits="Spedmon.request_file_upload_public" %>

<h2 class="mba-page-sub-title">Send Us A File</h2>

<%if (request_complete_val == false) {%>

<form id="record" name="record" method="post" enctype="multipart/form-data" action="<%=post_url%>" data-ajax="false">

<h3 class="mba-page-sub-title">Part <%=request_part%> of <%=REQUEST_PART_7%></h3>
<hr />


<%

 /*============================================================
  * Display validation message if neccessary
  *============================================================*/

if (!String.IsNullOrEmpty(request_message)){%>
<div class="mba-ui-form-validation-message">
<%=request_message%>
</div>
<%}%>

<% 

/*============================================================
 * Part 1 - Intro and captcha
 *============================================================*/
 
if (request_part == REQUEST_PART_1) 
{%>

<div class="ui-field-contain">

<label>
We <strong class="strong-big-bold">REALLY CARE</strong> about safeguarding information about you and your kids, so please:
<ol>
  <li>Decifer this image</li>
  <li>Type those characters below</li>
</ol>
</label>
<img src="<%=captcha_url%>" />
</div>

<div class="ui-field-contain">
<label for="<%=PARM_REQUEST_TOKEN%>">This makes sure you are a human</label>
<input type="text" id="<%=PARM_REQUEST_TOKEN%>" name="<%=PARM_REQUEST_TOKEN%>" autocomplete="off" placeholder="Please type the characters here… CASE SENSITIVE" required="required" autofocus="autofocus" value="" />
</div>

<%}%>

<% 

/*============================================================
 * Part 2 - County
 *============================================================*/
 
if (request_part == REQUEST_PART_2) 
{%>

<div id="q1" class="ui-field-contain">
<label for="<%=PARM_COUNTY_CODE%>">In <strong class="strong-big-bold">which county</strong> is your local education agency (LEA) located?</label>
<select id="<%=PARM_COUNTY_CODE%>" name="<%=PARM_COUNTY_CODE%>" required="required" autofocus="autofocus" data-native-menu="false">
<%=COUNTY_OPTIONS%>
</select>
</div>
<%}%>

<%

/*============================================================
 * Part 3 - District
 *============================================================*/
 
else if (request_part == REQUEST_PART_3) 
{%>

<div id="q2" class="ui-field-contain">
<label for="<%=PARM_DISTRICT_CODE%>">For <strong class="strong-big-bold">which local education agency (LEA)</strong> are you providing this file?</label>
<select id="<%=PARM_DISTRICT_CODE%>" name="<%=PARM_DISTRICT_CODE%>" required="required" autofocus="autofocus" data-native-menu="false">
<%=DISTRICT_OPTIONS%>
</select>
</div>
<%}%>

<%

/*============================================================
 * Part 4 - User information 
 *============================================================*/
 
else if (request_part == REQUEST_PART_4)
{%>

<div id="q3" class="ui-field-contain">
<label for="<%=PARM_FIRST_NAME%>">What is <strong class="strong-big-bold">your first name</strong>?</label>
<input id="<%=PARM_FIRST_NAME%>" name="<%=PARM_FIRST_NAME%>" type="text" required="required" autofocus="autofocus" value="<%=first_name%>" />
</div>

<div id="q4" class="ui-field-contain">
<label for="<%=PARM_LAST_NAME%>">What is <strong class="strong-big-bold">your last name</strong>?</label>
<input id="<%=PARM_LAST_NAME%>" name="<%=PARM_LAST_NAME%>" type="text" required="required" value="<%=last_name%>" />
</div>

<div id="q5" class="ui-field-contain">
<label for="<%=PARM_WORK_EMAIL%>">What is <strong class="strong-big-bold">your OFFICIAL WORK email address</strong>?</label>
<input id="<%=PARM_WORK_EMAIL%>" name="<%=PARM_WORK_EMAIL%>" type="email" required="required" value="<%=work_email%>" />
</div>

<%}%>


<%

/*============================================================
 * Part 5 - File class
 *============================================================*/
 
else if (request_part == REQUEST_PART_5)
{%>

<div id="q6" class="ui-field-contain">
<label for="<%=PARM_FILE_CLASS%>">What information is in the file?</label>
<select id="<%=PARM_FILE_CLASS%>" name="<%=PARM_FILE_CLASS%>" required="required" autofocus="autofocus" data-native-menu="false">
<%=FILE_CLASS_OPTIONS%>
</select>
</div>

<%}%>

<%

/*============================================================
 * Part 6 - File type based on file class and reference date
 * if needed
 *============================================================*/

else if (request_part == REQUEST_PART_6) 
{%>

<%

/*--------------------------------------
 * File class is a work batch
 *-------------------------------------*/
 
if (file_class == FILE_CLASS_WORK_BATCH) 
{%>

<div id="q7a" class="ui-field-contain">
<label for="<%=PARM_FILE_TYPE%>">Please select one <strong class="strong-big-bold">TYPE of Practitioner</strong> who rendered the services in this file? (Please seperate files by practitioner type)</label>
<select id="<%=PARM_FILE_TYPE%>" name="<%=PARM_FILE_TYPE%>" autofocus="autofocus" required="required" data-native-menu="false">
<%=FILE_TYPE_OPTIONS%>
</select>
</div>

<div id="q8a" class="ui-field-contain">
<label for="<%=PARM_REF_DATE%>">Please type or select the <strong class="strong-big-bold">OLDEST service date</strong> in the file</label>
<input id="<%=PARM_REF_DATE%>" name="<%=PARM_REF_DATE%>" type="date" placeholder="mm/dd/yyyy" max="<%=request_date_yyyy_mm_dd%>" required="required" value="<%=ref_date%>" />
</div> 
<%}%>

<%
/*--------------------------------------
 * File class is a student data file
 *-------------------------------------*/
 
else if (file_class == FILE_CLASS_STUDENT_DATA) 
{%>

<div id="q7b" class="ui-field-contain">
<label for="<%=PARM_FILE_TYPE%>"><strong class="strong-big-bold">Who or what</strong> is in this file?</label>
<select id="<%=PARM_FILE_TYPE%>" name="<%=PARM_FILE_TYPE%>" autofocus="autofocus" required="required" data-native-menu="false">
<%=FILE_TYPE_OPTIONS%>
</select>
</div>
<%}%>

<%}%>

<%

/*============================================================
 * Part 7 - File upload
 *============================================================*/

else if (request_part == REQUEST_PART_7) 
{%>

<div id="q9" class="ui-field-contain">
<label for="<%=PARM_FILE_NAME%>">Please <strong class="strong-big-bold">browse and select the file</strong> you want to send us (browse your local computer drives)</label>
<input id="<%=PARM_FILE_NAME%>" name="<%=PARM_FILE_NAME%>" type="file" required="required" autofocus="autofocus"/>
</div>
<%}%>

<%/*###########################################################################
    # Common form options
    ###########################################################################*/%>

<hr/>    
<div class="ui-field-contain">
<fieldset data-role="controlgroup" data-type="horizontal">
<legend>Please answer the question(s) and then <strong class="strong-big-bold">click on proceed</strong> to continue or cancel to exit</legend>
<a class="mba-ui-form-options-control ui-btn ui-corner-all ui-btn-inline ui-btn-icon-right ui-icon-home" data-ajax="false" href="<%=home_url%>">Cancel and Exit</a>
<button id="<%=PARM_PROCEED%>" name="<%=PARM_PROCEED%>" class="mba-ui-form-options-control ui-btn ui-corner-all ui-btn-inline ui-btn-icon-right ui-icon-arrow-r" type="submit">Proceed</button>
</fieldset>
</div>
</form>

<script type="text/javascript">
  
  $(document).on('pageinit', '#page', function() { $.mobile.loading('hide'); });
  $(document).on('submit', '#record', function() {
    $.mobile.loading('hide');

    var notFilledOut = 0;

    var fldsInput  = $('#record input[required="required"]');
    var fldsSelect = $('#record select[required="required"]');

    $(fldsInput).each(function(index, fld) {
      fldVal = $(fld).val();
      if (fldVal == '') notFilledOut++;
    });

    $(fldsSelect).each(function(index, fld) {
      fldVal = $(fld).val();
      if (!fldVal) { notFilledOut++; }
    });

        
    if (notFilledOut > 0) {
      messagePopup('Please Answer All Question(s)', '<p>One or more questions do not have answers.  Please answer all the questions on this page before proceeding.</p>', function() { });
      return false;
    }

    $.mobile.loading('show');
  });


</script>

<%}
else
{%>
<h3>Upload Complete</h3>
<hr />

<h4>Your file has been sent to us.  If we have any questions we will contact you.</h4>
<h4>Please select what you would like to do next</h4>

<hr />
<div data-role="controlgroup" data-type="horizontal">
<a class="mba-ui-form-options-control ui-btn ui-corner-all ui-btn-inline ui-btn-icon-right ui-icon-action" data-ajax="false" href="<%=another_file_url%>">Send Us Another File</a>
<a class="mba-ui-form-options-control ui-btn ui-corner-all ui-btn-inline ui-btn-icon-right ui-icon-home" data-ajax="false" href="<%=home_url%>">Cancel and Exit</a>
</div>

<%}%>

