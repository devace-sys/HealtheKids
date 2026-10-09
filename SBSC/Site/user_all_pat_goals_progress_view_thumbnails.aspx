<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="user_all_pat_goals_progress_view_thumbnails.aspx.cs" Inherits="Spedmon.userAllPatGoalsProgressViewThumbnails"%>

<div class="container-fluid">    
  <%foreach (var progressItem in this.progressItems) {%>
  <div class="row">
  <div class="col-12">
  <div class="patient-goal-progress-chart-container patient-goal-progress-chart-container-screen">
    <div id="<%=progressItem.chartID%>"></div>    
  </div>
  </div> <!-- col -->
  </div> <!-- row -->
  <%}%>
</div> <!-- container -->

<script type="text/javascript" charset="utf-8">


    $(document).ready(function () {


        debugger;

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