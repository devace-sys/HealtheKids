// global variables used to pass the checkbox id's to functions
var gblWgt;

function getAllTasksRequestData (wgt){

   var reqData    =  '{'
                      +'"organizationID":"' + wgt.options.organizationID + '"'
					  +',"ownerID":"'       + wgt.options.ownerID        + '"'
					  +',"groupID":"'       + wgt.options.ownerID        + '"'
					  +',"term":""}';

   return reqData;
};

function addTaskDiaNotImplemented (wgt, dia, frm ) {
  // TODO:
};


function getFavTasksRequestData (wgt){

   var reqData = '{'
			      + '"empid":"'        + wgt.options.id             + '"'
                  + '}';

   return reqData;
};

function addEmployeeDiaNotImplemented (wgt, dia, frm ) {

};

function getGroupsRequestData (wgt) {
   var reqData    =  '{'
                      +'"organizationID":"' + wgt.options.organizationID + '"'
					  +',"ownerID":"'       + wgt.options.ownerID        + '"'
					  +',"term":""}';

   return reqData;
};

function setupDragdropWidgets ($tkn, $orgID, $ownerID, $caseload, $groups, $caseloadCol, $groupsCol) {


  var $getItemsTaskListingActionURL      = "timekeeper_employee_favorites.asmx/viewSelTasks";
  var $addItemTaskListingActionURL       = "";
  var $editItemTaskListingActionURL      = "";
  var $removeItemTaskListingActionURL    = "";

  var $removeGroupCaseloadActionURL     = "";

  var $preloadPatExpectedSvcsURL        = "";

  var $fnGetItemsTasksRequestData  = getAllTasksRequestData;
  var $fnaddTaskDiaNotImplemented    = addTaskDiaNotImplemented;


  var $getItemsAssignedTasksActionURL    = "timekeeper_employee_favorites.asmx/viewSelTasksForEmployee";
  var $addItemAssignedTaskActionURL      = "timekeeper_employee_favorites.asmx/saveTaskForEmployee";
  var $removeItemAssignedTaskActionURL   = "timekeeper_employee_favorites.asmx/deleteTaskForEmployee";


  var $removeGroupGroupActionURL    = "";

  var $fngetFavTasksRequestData = getFavTasksRequestData;
  var $fnaddEmployeeDiaNotImplemented   = addEmployeeDiaNotImplemented;

  var $addNewAssignedTaskActionURL      = "";
  var $changeAssignedTaskActionURL  = "";
  var $getAssignedTasksActionURL        = "timekeeper_employees.asmx/viewSel";

  var $fnGetGroupsRequestData    = getGroupsRequestData;

  /* Note: This delegate uses vars declared above */

  var $fnRenderGroupsGroupWidget = function (wgt,grpObj,grpMkup) {
    $(grpMkup).entitygroup({  id: (grpObj.groupID)
                             , organizationID: $orgID
                             , ownerID: $ownerID
                             , name: (grpObj.lbl)
                             , tkn: $tkn
							 , entityGroupsReference1:($groups)
							 , allowChangeGroupName: false
                             , allowShowHideContent: false
                             , allowRemoveGroup: false
                             , allowAddMemberDrop: true
                             , allowMemberEdit:false
                             , searchTermInpPlaceholder:"Type Text to Filter"
                             , addMemberButLabel:"Add +"
                             , addMemberDiaTitle:"Add +"
                             , removeMemberButLabel:"Remove -"
                             , removeMemberDiaTitle:"Remove -"
                             , getMembersActionURL: $getItemsAssignedTasksActionURL
                             , addNewMemberActionURL: $addItemAssignedTaskActionURL
                             , removeMemberActionURL: $removeItemAssignedTaskActionURL
                             , changeGroupNameActionURL: $changeAssignedTaskActionURL
                             , removeGroupActionURL: $removeItemAssignedTaskActionURL
                             , fnGetMembersRequestData: $fngetFavTasksRequestData
                             , fnAddMemberDiaContent: $fnaddEmployeeDiaNotImplemented
                          });
  };


  $($caseload).entitygroup ({   id: $ownerID
                                , organizationID: $orgID
                                , ownerID: $ownerID
                                , name: "All Tasks"
                                , tkn: $tkn
								, entityGroupsReference2:($groups)
                                , allowChangeGroupName: false
                                , allowShowHideContent: false
                                , allowRemoveGroup: false
                                , allowAddMemberDrop: false
                                , searchTermInpPlaceholder:"Type Text to Filter Caseload List"
                                , addMemberButLabel:"Add Patient"
                                , addMemberDiaTitle:"Add Patient to Caseload"
								, addMemberDiaWidth:820
                                , addMemberDiaHeight:450
                                , addMemberDiaResizable:false
								, fnAddMemberCustomClearFields: function() {}
                                , removeMemberButLabel:"Remove Patient"
                                , removeMemberDiaTitle:"Remove Patient from Caseload"
                                , getMembersActionURL: $getItemsTaskListingActionURL
                                , addNewMemberActionURL: $addItemTaskListingActionURL
                                , removeMemberActionURL: $removeItemTaskListingActionURL
                                , removeGroupActionURL: $removeGroupCaseloadActionURL
                                , preloadPatExpectedSvcsURL: ""
                                , fnGetMembersRequestData: $fnGetItemsTasksRequestData
                                , fnAddMemberDiaContent: $fnaddTaskDiaNotImplemented
                                , fnEditMemberDiaContent: function() {}
                           });

   var fnSetExtRefToThis = function ($refToThis) {
     gblWgt = $refToThis;
   };

   $($caseload).entitygroup("getExternalRefToWgt", fnSetExtRefToThis);

  $($groups).entitygroups ({ id: $ownerID
                              , organizationID: $orgID
                              , ownerID: $ownerID
                              , name: "Employees"
                              , tkn: $tkn
						      , allowShowHideGroupsContent:true
							  , allowFilterGroups:true
                              , getGroupsActionURL:$getAssignedTasksActionURL
                              , addNewGroupActionURL: $addNewAssignedTaskActionURL
                              , fnGetGroupsRequestData:$fnGetGroupsRequestData
                              , fnRenderGroupWidget:$fnRenderGroupsGroupWidget
                            });

};

// event listeners for the checkboxes

$(function () {

});
