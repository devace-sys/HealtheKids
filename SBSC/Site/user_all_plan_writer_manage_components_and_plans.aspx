<%@ Page Language="C#" CodeBehind="user_all_plan_writer_manage_components_and_plans.aspx.cs" Inherits="Spedmon.UserAllPlanWriterManageComponentsAndPlans" %>


<div class="pw-columns ui-helper-clearfix">
  
  <!-- **** Conditions **** -->
  
  <div id="conditions-column" class="pw-column pw-column-left">
    
    <ul id="sharedconditions">
    </ul>
    <br />
    <ul id="conditions">
    </ul>
    
  </div>
  
  <!-- **** Plans **** -->
  
  <div id="plans-column" class="pw-column pw-column-right">
    
    <div id="plans">
    </div>
    
  </div>

</div>

<script type="text/javascript" charset="utf-8">
   
 /* Wait until page is fully loaded */
 
 $(window).on('load', function() {
        
  var $tkn                = '<%=tkn%>';
  var $clientID           = <%=clientID%>;
  var $grpSvcClassNameID  = <%=groupSvcClassNameID%>;
  var $sharedConditions   = $('#sharedconditions');
  var $myConditions       = $('#conditions');
  var $plans              = $('#plans');
  var $conditionsCol      = $('#conditions-column');
  var $plansCol           = $('#plans-column');
  var $fileUploadHandler  = '<%=MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE()%>';
  var $fileUploadClass    = '<%=Spedmon.PlanWriterPlans.VAL_FILE_CLASS_HEALTH_CARE_INSTRUCTIONS%>';
  
  setupPlanWriterWidgets (  $tkn                        
                          , $clientID
                          , $grpSvcClassNameID
                          , $sharedConditions
                          , $myConditions
                          , $plans
                          , $conditionsCol
                          , $plansCol 
                          , $fileUploadHandler
                          , $fileUploadClass );
      
  return;
  
});
</script>