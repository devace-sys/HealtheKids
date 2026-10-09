<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_pat_goals_progress_view.aspx.cs" Inherits="Spedmon.userAllPatGoalsProgressView"%>

<%if(noGoalsToChart == true){%>
<div class="alert alert-info text-center">
<%if(noRefDate==false){%>
As of <%=dos%> there are no goals available
<%} else {%>
There are no goals available
<%}%>
</div>
<%}%>

<div class="container">    
  <%foreach (var progressItem in this.progressItems) {%>
  <div class="row">
  <div class="col-12">
     <h1 class="text-center"><%=progressItem.goal.groupSvcClassName%> Goal <%=progressItem.goal.startDateStr%> to <%=progressItem.goal.endDateStr%></h1>
  </div> <!-- col -->
  <div class="col-12">  
  <div id="<%=progressItem.chartID%>"></div>      
  </div> <!-- col -->
  <div class="col-12">
  <hr />
  </div><!-- col -->
  </div> <!-- row -->
  <%}%>
</div> <!-- container -->

<script type="text/javascript" charset="utf-8">

    $(document).ready(function () {

        MBA.PatientGoalProgressReporting.fnInit(
          '<%=Spedmon.PatientGoalsProgressIndividualGoals.URL_SVC_VIEW_PROGRESS_INDIVIDUAL_GOALS_BASE()%>'
        , '<%=MBA.Credential.generateSessionExpiredLink()%>'
        , '<%=Spedmon.Constants.PARM_CLIENT_ID%>'
        , '<%=Spedmon.Constants.PARM_PATIENT_ID%>'
        , '<%=Spedmon.Constants.PARM_PATIENT_GOAL_ID%>');

        <%foreach (var progressItem in this.progressItems) {%>
        MBA.PatientGoalProgressReporting.fnGetAndChartInDivIndivualGoalData (
            '<%=progressItem.goal.clientID%>'
            ,'<%=progressItem.goal.patID%>'
            ,'<%=progressItem.goal.id%>'
            ,'<%=progressItem.chartID%>');
        <%}%>
    });    
</script>