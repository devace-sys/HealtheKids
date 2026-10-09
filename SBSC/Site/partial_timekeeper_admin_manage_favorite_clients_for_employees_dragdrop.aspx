<%@ Page Language="C#" CodeBehind="partial_timekeeper_admin_manage_favorite_clients_for_employees_dragdrop.aspx.cs" Inherits="Spedmon.PartialTimekeeperAdminManageFavoriteClientsForEmployeesDragdrop" %>

<div class="row">

  
  <div id="caseloadcolumn" class="cg-column-left">
    <ul id="caseload">
    </ul>
  </div>
  
  <!-- **** My Groups **** -->
  
  <div id="groupscolumn" class="cg-column-right">
    <div id="groups">
    </div>
  </div>

</div>

<script type="text/javascript">


$(function () {


  var $tkn             = '<%=tkn%>';

  var $orgID           = '';
  var $ownerID         = '';
  var $caseload        = $('#caseload');  //todo: refactor, get rid of this
  var $groups          = $('#groups');
  var $caseloadCol     = $('#caseloadcolumn');
  var $groupsCol       = $('#groupscolumn');

  // hide the modal
  $('#viewExpectedTreatmentsCont').hide();

 setupDragdropWidgets($tkn, $orgID, $ownerID, $caseload, $groups, $caseloadCol, $groupsCol);

});

</script>