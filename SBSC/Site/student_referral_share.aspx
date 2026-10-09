<%@ Page Language="C#" CodeBehind="student_referral_share.aspx.cs" Inherits="Spedmon.StudentReferralShare" %>

<%if (pageInitIsOK == true) { %>

<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                                 Markup                                                          %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<%//###############################################%>
<%//#  Form to enter the PIN                       %>
<%//###############################################%>

<% if (reqLoadedOk) { %>
<div class="card-container">
    <%
        string urgencyClass = "routine"; string urgencyLabel = "Routine";
        if (rec.priority == 2) { urgencyClass = "urgent"; urgencyLabel = "Urgent"; }
        else if (rec.priority == 3) { urgencyClass = "crisis"; urgencyLabel = "Crisis"; }
    %>

    <div class="ribbon-wrapper <%= urgencyClass %>">
        <div class="checkmark"><%= urgencyLabel %></div>
    </div>

    <div class="container">
        <div class="row">
            <div class="col-12 mt-3">
                <h1 class="text-center"><%= clientname %></h1>
                <h2 class="text-center"><%= subtitle %></h2>
            </div>
        </div>
    </div>
    <!-- container -->
    <hr />
    <div style="text-align: center">
        <% if (refToParent.Equals("true")) { %>
        <h5 style="text-align: center;">Referral to:</h5>
        <p style="font-size: 18px; color: #555; text-align: center;">
            <strong>Referral Recipient:</strong> <em><%=refpracname %></em> &nbsp;|&nbsp;
            <strong>Email:</strong> <em><%=refpracemail %></em> &nbsp;|&nbsp;
            <strong>Agency:</strong> <em><%=refpracorg %></em> &nbsp;|&nbsp;
            <strong>Phone:</strong> <em><%=refpracphone %></em>
        </p>
        <% }
            else if (refToPrac.Equals("true")) {%>
        <h5 style="text-align: center;">Referral from:</h5>
        <p style="font-size: 18px; color: #555; text-align: center;">
            <strong>Referral Recipient:</strong> <em><%=prac.name %></em> &nbsp;|&nbsp;
            <strong>Email:</strong> <em><%=prac.email %></em> &nbsp;|&nbsp;
            <strong>Phone:</strong> <em><%=prac.phone %></em>
        </p>
        <%} %>
    </div>
    <hr style="margin: 30px 0;" />
    <div class="row">
        <div class="col-md-6">
            <h2 style="border-bottom: 1px solid #ccc; padding-bottom: 10px; font-weight: bold; font-size: 22px; margin-bottom: 20px;">Details to Share in the Referral</h2>
            <div class="form-check">
                <input class="form-check-input" id="includeDiagnoses" type="checkbox" disabled="disabled" />
                <label class="form-check-label" for="includeDiagnoses">DSM-5 or ICD-10 Diagnosis</label>
            </div>
            <div class="form-check">
                <input class="form-check-input" id="includeSvcRecordsAssessementsOrScreenings" type="checkbox" disabled="disabled" />
                <label class="form-check-label" for="includeSvcRecordsAssessementsOrScreenings">Recent Screenings</label>
            </div>
            <div class="form-check">
                <input class="form-check-input" id="includeOrdersOrPr" type="checkbox" disabled="disabled" />
                <label class="form-check-label" for="includeOrdersOrPr">Medications</label>
            </div>
            <div class="form-check">
                <input class="form-check-input" id="includeServiceRecordsTreatments" type="checkbox" disabled="disabled" />
                <label class="form-check-label" for="includeServiceRecordsTreatments">Direct Service History</label>
            </div>
            <div class="form-check">
                <input class="form-check-input" id="includeServiceNotesNonConfidential" type="checkbox" disabled="disabled" />
                <label class="form-check-label" for="includeServiceNotesNonConfidential">Non-Confidential Session Notes</label>
            </div>
            <div class="form-check">
                <input class="form-check-input" id="includeServiceNotesConfidential" type="checkbox" disabled="disabled" />
                <label class="form-check-label" for="includeServiceNotesConfidential">Confidential Session Notes</label>
            </div>
        </div>

        <div class="col-md-6 divider-left">
            <p style="margin-top: 50px; text-align: center; font-size: 22px"><strong>Student Name:</strong> <%= pat.name %></p>
        </div>
    </div>
    <!--row-->

    <hr style="margin: 30px 0;" />
    <form id="frm_pinvalidation" runat="server" method="post" action="student_referral_share.aspx">

        <input id="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" name="<%=Spedmon.Constants.PARM_PUBLIC_TOKEN%>" type="hidden" value="<%=ptkn%>" />
        <div style="text-align: center;">
            <h3>Enter the PIN</h3>
            <input runat="server" type="text" maxlength="10" minlength="1" autocomplete="off" title="The PIN cannot be empty" pattern="\d{1,10}" required="required" placeholder="PIN" id="txt_student_referral_pin" style="padding: 10px; width: 200px; font-size: 16px; border-radius: 6px; border: 1px solid #ccc; margin-bottom: 20px;" />
            <div style="color: red; font-weight: bold; font-size: 18px; margin-bottom: 2px">
                <%= errorMessage %>
            </div>
            <div>
                <% if (refToParent.Equals("true") && !completed)
                    { %>
                <button id="btn_prac_pat_parent_authorize" runat="server" type="submit" name="action" value="1" style="padding: 10px 20px; font-size: 16px; margin: 5px; background-color: #007bff; color: white; border: none; border-radius: 6px; cursor: pointer;">Approve</button>
                <button id="btn_prac_pat_parent_reject" runat="server" type="submit" name="action" value="2" style="padding: 10px 20px; font-size: 16px; margin: 5px; background-color: #dc3545; color: white; border: none; border-radius: 6px; cursor: pointer;">Decline</button>
                <%}
                else if (completed)
                {%>
                <button id="btn_prac_show_data" runat="server" type="submit" name="action" value="1" style="padding: 10px 20px; font-size: 16px; margin: 5px; background-color: #007bff; color: white; border: none; border-radius: 6px; cursor: pointer;">Enter</button>
                <%} %>
            </div>
        </div>
    </form>
    <hr style="margin: 30px 0;" />
    <p style="font-size: 14px; color: #555; text-align: center;">
        <%if (refToParent.Equals("true"))
            { %>
        <strong>Referral Submitted By:</strong> <%=prac.name %> &nbsp;|&nbsp;
        <strong>Email:</strong> <a href="mailto:<%=prac.email %>"><%=prac.email %></a> &nbsp;|&nbsp;
        <%} %>
        <strong>Referral No:</strong> <%=rec.referralID %> &nbsp;|&nbsp;
        <strong>Expires On:</strong> <%=rec.expirationDate.ToShortDateString() %> at <%=rec.expirationTimeStr %>
    </p>
</div>
<%} %>

<% if (dataLoadedOk)
    { %>
<div id="prac-pat-ref-pdf-content">
    <div class="mba-pdf-section">
        <div class="prac-pat-ref-info-header">
            <div class="col-12 mt-3">
                <h1 class="text-center"><%= clientname %></h1>
                <p class="text-center">Patient Health Information Summary</p>
            </div>
        </div>
        <div class="prac-pat-ref-patient-info">
            <div class="prac-pat-ref-patient-card">
                <div class="prac-pat-ref-patient-details">
                    <h3><%=pat.name %></h3>
                    <div class="prac-pat-ref-patient-meta ">
                        <span><strong>Age:</strong> <%=pat.ageCurrent %></span>
                        <span><strong>Gender:</strong> <%=pat.gender %></span>
                    </div>
                </div>
            </div>
        </div>
        <div id="prac-pat-ref-tabs">
            <ul class="tab-links ml-3 mb-0 pb-0">
                <% if (includeDiagnoses)
                    { %>
                <li><a href="#tab_diagnoses">Diagnoses</a></li>
                <% } %>
                <% if (includeSvcRecordsAssessementsOrScreenings)
                    { %>
                <li><a href="#tab_recordsassessementsorscreenings">Assessements or Screenings</a></li>
                <% } %>
                <% if (includeOrdersOrPrescriptions)
                    { %>
                <li><a href="#tab_ordersorprescriptions">Orders or Prescriptions</a></li>
                <% } %>
                <% if (includeServiceRecordsTreatments)
                    { %>
                <li><a href="#tab_servicerecordstreatments">Treatments or Therapy</a></li>
                <% } %>
                <% if (includeServiceNotesNonConfidential)
                    { %>
                <li><a href="#tab_servicenotesnonconfidential">Service Notes Non Confidential</a></li>
                <% } %>
                <% if (includeServiceNotesConfidential)
                    { %>
                <li><a href="#tab_servicenotesconfidential">Service Notes Confidential</a></li>
                <% } %>
                
            </ul>
            <div class="prac-pat-ref-tab-content">
                <div id="tab_diagnoses" class="tab active">
                    <%if (includeDiagnoses)
                        { %>
                    <div style="text-align: left">
                        <h5 style="text-align: center; margin-bottom: 7px">Diagnoses:</h5>
                        <div id="patientDiagnoses">
                            <%=patientDiagnosesData %>
                        </div>
                    </div>
                    <%} %>
                </div>
                <div id="tab_recordsassessementsorscreenings" class="tab">
                    <%if (includeSvcRecordsAssessementsOrScreenings)
                        { %>
                    <div style="text-align: left">
                        <h5 style="text-align: center; margin-bottom: 7px">Assessment Or Screening:</h5>
                        <div id="patServiceRecordsAOrS">
                            <table class="table table-sm">
                                <thead class="thead-light">
                                    <tr>
                                        <th>DOS</th>
                                        <th>Attendance Status</th>
                                        <th>Service Rendered</th>
                                        <th>Mins (if applicable)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% foreach (Spedmon.ServiceRecord srt in serviceRecordsDataAorS)
                                        { %>
                                    <tr>
                                        <td><%= srt.dosStr %></td>
                                        <% if (srt.patAbsent == true)
                                        { %>
                                        <td class="table-info">
                                            <% }
                                            else
                                            { %>
                                        <td>
                                            <% } %>
                                            <%= srt.attendanceStatusSelectionName %>
                                        </td>
                                        <td><%= srt.svcName %></td>
                                        <td><%= srt.numMins %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <%} %>
                </div>
                <div id="tab_ordersorprescriptions" class="tab">
                    <%if (includeOrdersOrPrescriptions)
                        { %>
                    <div style="text-align: left">
                        <div id="ordersOrPx">
                            <%=patientOrdersOrPrData %>
                        </div>
                    </div>
                    <%} %>
                </div>
                <div id="tab_servicerecordstreatments" class="tab">
                    <%if (includeServiceRecordsTreatments)
                        { %>
                    <div style="text-align: left">
                        <h5 style="text-align: center; margin-bottom: 7px">Treatments or Therapy:</h5>
                        <div id="patServiceRecordsTreatments">
                            <table class="table table-sm">
                                <thead class="thead-light">
                                    <tr>
                                        <th>DOS</th>
                                        <th>Attendance Status</th>
                                        <th>Service Rendered</th>
                                        <th>Mins (if applicable)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% foreach (Spedmon.ServiceRecord srt in serviceRecordsDataT)
                                        { %>
                                    <tr>
                                        <td><%= srt.dosStr %></td>
                                        <% if (srt.patAbsent == true)
                                        { %>
                                        <td class="table-info">
                                            <% }
                                            else
                                            { %>
                                        <td>
                                            <% } %>
                                            <%= srt.attendanceStatusSelectionName %>
                                        </td>
                                        <td><%= srt.svcName %></td>
                                        <td><%= srt.numMins %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <%} %>
                </div>
                <div id="tab_servicenotesnonconfidential" class="tab">
                    <%if (includeServiceNotesNonConfidential)
                        { %>
                    <div style="text-align: left">
                        <h5 style="text-align: center; margin-bottom: 7px">Service Notes Non Confidential:</h5>
                        <div id="patServiceNotesNonConfidential">
                        </div>
                    </div>
                    <%} %>
                </div>
                <div id="tab_servicenotesconfidential" class="tab">
                    <%if (includeServiceNotesConfidential)
                        { %>
                    <div style="text-align: left">
                        <h5 style="text-align: center; margin-bottom: 7px">Service Notes Confidential:</h5>
                        <div id="patServiceNotesConfidential">
                        </div>
                    </div>
                    <%} %>
                </div>                
            </div>
        </div>
        <p style="font-size: 14px; color: #555; text-align: center; margin-top: 30px">
            <strong>Referral Submitted By:</strong> <%=prac.name %> &nbsp;|&nbsp;
            <strong>Referral No:</strong> <%=rec.referralID %> &nbsp;|&nbsp;
            <strong>Email:</strong> <a href="mailto:<%=prac.email %>"><%=prac.email %></a> &nbsp;|&nbsp;
            <strong>Expires On:</strong> <%=rec.expirationDateStr %> at <%=rec.expirationTimeStr %>
        </p>
         <%if (rec.approvalRejectionDateStr != "")
                    { %>
        <p class="infoforprac" style="font-size: 15px; color: red; text-align: center; margin-top: 20px">
            <strong>Medical Data Release Autorization:</strong> <%=rec.parentGuardianName %> &nbsp;|&nbsp;
            <strong>Email:</strong> <a href="mailto:<%=prac.email %>"><%=rec.parentGuardianEmail %></a> &nbsp;|&nbsp;
            <strong>Phone:</strong> <%=rec.parentGuardianPhone %> &nbsp;|&nbsp;
            <strong>Date of Authorization:</strong> <%=rec.approvalRejectionDateStr %> at <%=rec.approvalRejectionTimeStr %>
        </p>
        <%} %>
    </div>
</div>
<%} %>


<%//##################################################################################################################%>
<%//#                                                                                                                 %>
<%//#                                         Data Management Scripts                                                 %>
<%//#                                                                                                                 %>
<%//##################################################################################################################%>

<script type="text/javascript">
    
    let comp = '<%= completed %>';
       
    function loadDetailsCheckBox() {
        var includeDiagnoses = <%= rec.includeDiagnoses.ToString().ToLower() %>;
        var includeSvcRecordsAssessementsOrScreenings = <%= rec.includeServiceRecordsAssessementsOrScreenings.ToString().ToLower() %>;
        var includeOrdersOrPrescriptions = <%= rec.includeOrdersOrPrescriptions.ToString().ToLower() %>;
        var includeServiceRecordsTreatments = <%= rec.includeServiceRecordsTreatments.ToString().ToLower() %>;
        var includeServiceNotesNonConfidential = <%= rec.includeServiceNotesNonConfidential.ToString().ToLower() %>;
        var includeServiceNotesConfidential = <%= rec.includeServiceNotesConfidential.ToString().ToLower() %>;

        $('#includeDiagnoses').prop('checked', includeDiagnoses);
        $('#includeSvcRecordsAssessementsOrScreenings').prop('checked', includeSvcRecordsAssessementsOrScreenings);
        $('#includeOrdersOrPr').prop('checked', includeOrdersOrPrescriptions);
        $('#includeServiceRecordsTreatments').prop('checked', includeServiceRecordsTreatments);
        $('#includeServiceNotesNonConfidential').prop('checked', includeServiceNotesNonConfidential);
        $('#includeServiceNotesConfidential').prop('checked', includeServiceNotesConfidential);
    };

    $(document).ready(function () {
        loadDetailsCheckBox();
        
        var $firstVisibleTab = $('.tab-links li:visible:first');

        if ($firstVisibleTab.length) {
            $firstVisibleTab.addClass('active');
            var firstTabHref = $firstVisibleTab.find('a').attr('href');
            $(firstTabHref).addClass('active');
        }

        $('.tab-links a').click(function (e) {
            e.preventDefault();

            var currentAttrValue = $(this).attr('href');

            $('.tab-links li').removeClass('active');
            $(this).parent().addClass('active');

            $('.tab').removeClass('active');
            $(currentAttrValue).addClass('active');
        });
    });
</script>
<%}
    else
    {%>
<div class="alert alert-danger text-center" style="font-size: 25px;"><%= errorMessage %></div>
<%}%>
