///*#####################################################################################################################
//  #
//  # Conditions Library
//  #
//  #####################################################################################################################*/ 

///***************************************************************************
// * fnGetMembersCondtionsRequestData
///**
// ***************************************************************************/   

//function fnGetMembersConditionsRequestData (wgt) {
//  var reqData  =  '{'
//               +' "clientID":"' + wgt.options.organizationID + '"'
//			   +',"groupSvcClassNameID":"' + wgt.options.ownerID + '"'
//			   +',"term":""}';
//  return reqData;  
//};

///***************************************************************************
// * fnAddMemberConditionsDiaContent
///**
// ***************************************************************************/   

//function fnAddMemberConditionsDiaContent (wgt, dia, frm ) {
  
//  /*============================================================
//   * Create unique ids for fields we will be enhancing or
//   * interacting with
//   *============================================================*/ 
  
//  var me_id  = $(wgt.element).attr('id');
//  var frm_id = $(frm).attr('id');       
//  wgt.options.new_cond_name_id  = me_id + '-' + frm_id + '-new-cond-name';
  
//  /*============================================================
//   * Build form
//   *============================================================*/ 
  
//  var $instructions = wgt._generateInstructionsBox("Enter the name of the patient's condition below. You can add diagnosis information after you have clicked Add");
//  $(frm).append($instructions);
  
//  var $inpCondName  = $('<input name="name" id="' + wgt.options.new_cond_name_id  + '" type="text" placeholder="Enter condition name"/>');  
  
//  var $l1 = wgt._generateFormGridColLabel('Condition Name');  
//  var $r1 = wgt._generateFormGridRow ($l1, $inpCondName);
//  var $fg = wgt._generateFormGridContainer ($r1);
  
//  $(frm).append($fg);  
//  $(frm).append('<input name="entityID"    value=""  type="hidden" />');
//  $(frm).append('<input name="saveType"    value="1" type="hidden" />');
//  $(frm).append('<input name="shareRecord" value="0" type="hidden" />');

//  $($inpCondName).spedmonTextbox({"showOK":false});

//};

///***************************************************************************
// * fnEditMemberConditionsFormPopulate */
///**
// * 
// ***************************************************************************/   

//function fnEditMemberConditionsFormPopulate (wgt, $frm, mbrObj) {  
//  $('#' + wgt.options.edit_cond_name_id).val(mbrObj.lbl);
//  $('#' + wgt.options.edit_cond_desc_id).val(mbrObj.context1);
//  $('#' + wgt.options.edit_cond_entityid_id).val(mbrObj.entityID);   	 
//  $('#' + wgt.options.edit_cond_sharerec_id).val(mbrObj.recData1);
//  $('#' + wgt.options.edit_cond_diags_id).entityrecordmanage('refresh');
//};

///***************************************************************************
// * fnEditMemberConditionsDiaContent */
///**
// * 
// ***************************************************************************/   

//function fnEditMemberConditionsDiaContent (wgt, dia, frm) {
  
//  /*============================================================
//   * Create unique ids for fields we will be enhancing or
//   * interacting with
//   *============================================================*/ 
  
//  var me_id  = $(wgt.element).attr('id');
//  var frm_id = $(frm).attr('id');    
  
//  wgt.options.edit_cond_entityid_id   = me_id + '-' + frm_id + '-edit-cond-entityid';
//  wgt.options.edit_cond_name_id       = me_id + '-' + frm_id + '-edit-cond-name';
//  wgt.options.edit_cond_diags_id      = me_id + '-' + frm_id + '-edit-cond-diags';
//  wgt.options.edit_cond_sharerec_id   = me_id + '-' + frm_id + '-edit-cond-sharerec';
    
//  /*============================================================
//   * Build form
//   *============================================================*/ 

//  var $inpCondEntityID = $('<input name="entityID" id="' + wgt.options.edit_cond_entityid_id  + '" type="hidden" />');
//  var $inpCondName     = $('<input name="name" id="' + wgt.options.edit_cond_name_id  + '" type="text" placeholder="Enter condtion name"/>');      
//  var $inpShareRec     = $('<input name="shareRecord" id="' + wgt.options.edit_cond_sharerec_id +'" type="text" title="Share this"/>');  
//  var $divDiags        = $('<div id="' + wgt.options.edit_cond_diags_id + '"></div>');
      
//  var instContent =  '<ul>'
//                   + '<li>Click the Add New button below to add a diagnosis for this condition.</li>'
//                   + '<li>You will be able to add and edit Assessment, Diagnosis, Interventions, and Expected Outcomes for the Diagnosis.</li>'
//                   + '<li>You can add multiple Diagnosis’s related to this condition.</li>'
//                   + '<li>Once a condition is added to the plan, you can make edits to personalize the Assessment, Diagnosis, Interventions, and Expected Outcomes for the patient’s plan.'
//                   + 'Click the pencil icon to edit a saved diagnosis. '
//                   + 'Click the trash icon to remove a saved diagnosis</li>'
//				   + '<li>If you would like to share this condition, including diagnosis details, click YES.  Other practitioners, within the same practice group, will have access to use this condition in creating their own plans.</ul>'
//				   + '</ul>';
				   
//  var $instructions = wgt._generateInstructionsBox(instContent);
//  $(frm).append($instructions);
  
  
//  var $constParmsObjCommon = [  { name:"clientid",            value:(wgt.options.organizationID)}
//                              , { name:"groupsvcclassnameid", value:(wgt.options.ownerID)} 				  
//				             ];
							 
//  var $dynamicParmsObjCommon = [{
//      fnName  :function(){ return 'conditionid';}
//    , fnValue :function(){ return '' + $('#' + wgt.options.edit_cond_entityid_id).val();}
//  }];
  
  
//  var $l1 = wgt._generateFormGridColLabel('Share This Condition');
//  var $r1 = wgt._generateFormGridRow ($l1, $inpShareRec);
  
//  var $l2 = wgt._generateFormGridColLabel('Name');  
//  var $r2 = wgt._generateFormGridRow ($l2, $inpCondName);
  
//  var $l3 = wgt._generateFormGridColLabel('Diagnosis');  
//  var $r3 = wgt._generateFormGridRow ($l3, $divDiags);      
  
//  var $fg = wgt._generateFormGridContainer ($r1,$r2,$r3);
  
//  $(frm).append($fg);    
//  $(frm).append('<input name="saveType" value="2" type="hidden" />');
//  $(frm).append($inpCondEntityID);
  
//  $($divDiags).entityrecordmanage ({
//      tkn:(wgt.options.tkn)
//	, allowFlag:false
//    , viewSelMethodBaseUrl:"plan_writer_conditions_diagnosis.asmx/viewSel"
//    , saveFormBaseUrl:"user_all_plan_writer_conditions_diagnosis_save.aspx"
//    , deleteMethodBaseUrl:"plan_writer_conditions_diagnosis.asmx/delete"
//	, waitingMessage:"Waiting for you to finish with the diagnosis record"
//    , constantParmsObjCommon:($constParmsObjCommon)
//    , dynamicParmsObjCommon:($dynamicParmsObjCommon)
//  });
    
//  $($inpCondName).spedmonTextbox({"showOK":false});
//  $($inpShareRec).spedmonYesNo({});
//};

///*#####################################################################################################################
//  #
//  # Plans
//  #
//  #####################################################################################################################*/ 

///***************************************************************************
// * fnGetPlansRequestData
///**
// ***************************************************************************/   

//function fnGetPlansRequestData (wgt) {
//  var reqData  =  '{'
//               +' "clientid":"'            + wgt.options.organizationID + '"'
//			   +',"groupsvcclassnameid":"' + wgt.options.ownerID + '"'			   
//			   +',"term":""}';
//  return reqData;
//};

///***************************************************************************
// * fnAddNewPlanDiaContent */
///**
// * Note: Called by entitygroups
// ***************************************************************************/   
 
//function fnAddNewPlanDiaContent (wgt, dia, frm) {
  
//  /*============================================================
//   * Create unique ids for fields we will be enhancing or
//   * interacting with
//   *============================================================*/ 
  
//  var me_id  = $(wgt.element).attr('id');
//  var frm_id = $(frm).attr('id');    
  
//  /* Note a group name unique id is already provided by the widget */
  
//  wgt.options.add_new_patientid_id   = me_id + '-' + frm_id + '-add-new-patientid';   
//  wgt.options.add_new_plantypeid_id  = me_id + '-' + frm_id + '-add-new-plantypeid';   
//  wgt.options.add_new_plandate_id    = me_id + '-' + frm_id + '-add-new-plandate';   
  
//  var $patSel     = $('<input name="patientid" id="'  + wgt.options.add_new_patientid_id  +'" title="Last Name, First Name" class="mba-web-ui-field-simple" type="text"/>');
//  var $planDate   = $('<input name="plandate" id="'   + wgt.options.add_new_plandate_id   +'" title="Select Plan Date" type="text"/>');
//  var $planType   = $('<input name="plantypeid" id="' + wgt.options.add_new_plantypeid_id +'" value="1" type="hidden"/>');
  
//  var $l1 = wgt._generateFormGridColLabel('Select a Patient');  
//  var $r1 = wgt._generateFormGridRow ($l1, $patSel);
//  var $l2 = wgt._generateFormGridColLabel('Select a Plan Date');  
//  var $r2 = wgt._generateFormGridRow ($l2, $planDate);
  
//  var $fg = wgt._generateFormGridContainer ($r1,$r2);
  
//  $(frm).append($fg);
//  $(frm).append($planType);
  
//  /* Enhance */
  
//  var $patSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"patients.asmx/viewSel");
//  var $patSelNVP = [   { name:"clientid",       value:(wgt.options.organizationID) }
//                     , { name:"pracid",         value:"" }	
//					 , { name:"dos",            value:"" }							  
//				     , { name:"patdatasource",  value:"0" }							  
//			        ];

//  $($patSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:($patSelUrl),data:"",namevalues:($patSelNVP),getnamevaluesfn:null}});	 
//  $($planDate).spedmonDatebox({multidate:false,showOK:false,maxDate:'',dateText:(wgt.options.startDateDflt),defaultDate:(wgt.options.startDateDflt),useVisibleWorkaround:false});

//};

///***************************************************************************
// * fnChangePlanFormPopulate 
///**
// ***************************************************************************/   

//function fnChangePlanFormPopulate (wgt, $frm ) {

//  $('#' + wgt.options.chg_patientid_id).val(wgt.options.recData1);
//  $('#' + wgt.options.chg_patientid_id + '_selection').val(wgt.options.recData2); 
//  $('#' + wgt.options.chg_plandate_id).val(wgt.options.recData3);
//  $('#' + wgt.options.chg_plantypeid_id).val(wgt.options.recData4);
//  $('#' + wgt.options.chg_patpersons_id).entityrecordmanage('refresh');
//  $('#' + wgt.options.chg_plansigs_id).entityrecordmanage('refresh');

//};

///***************************************************************************
// * fnChangePlanDiaContent */
///**
// * Note: Called by entitygroup
// ***************************************************************************/   
 
//function fnChangePlanDiaContent (wgt, dia, frm) {
  
//  /* TOD0: Add these fields to the widget code */
   
//   $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
//   $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
//   $(frm).append('<input name="saveType" value="2" type="hidden" />');
//   $(frm).append('<input name="recID"          value="' + wgt.options.id             +'"  type="hidden" />');
  
//  /*============================================================
//   * Create unique ids for fields we will be enhancing or
//   * interacting with
//   *============================================================*/ 
  
//  var me_id  = $(wgt.element).attr('id');
//  var frm_id = $(frm).attr('id');    
  
//  /* Note a group name unique id is already provided by the widget */
  
//  wgt.options.chg_patientid_id   = me_id + '-' + frm_id + '-chg-patientid';   
//  wgt.options.chg_plandate_id    = me_id + '-' + frm_id + '-chg-plandate';   
//  wgt.options.chg_plantypeid_id  = me_id + '-' + frm_id + '-chg-plantypeid';   
//  wgt.options.chg_patpersons_id  = me_id + '-' + frm_id + '-chg-patpersons';   
//  wgt.options.chg_plansigs_id    = me_id + '-' + frm_id + '-chg-plansigs';
  
//  var $patSel        = $('<input name="patientid" id="'  + wgt.options.chg_patientid_id  +'" title="Last Name, First Name" class="mba-web-ui-field-simple" type="text"/>');
//  var $planDate      = $('<input name="plandate" id="'   + wgt.options.chg_plandate_id   +'" title="Select Plan Date" type="text"/>');
//  var $planType      = $('<input name="plantypeid" id="' + wgt.options.chg_plantypeid_id +'" type="hidden"/>');
//  var $divPatPersons = $('<div id="' + wgt.options.chg_patpersons_id + '"></div>');  
//  var $divPlanSigs   = $('<div id="' + wgt.options.chg_plansigs_id   + '"></div>');  
  
//  var $l1 = wgt._generateFormGridColLabel('Select a Patient');  
//  var $r1 = wgt._generateFormGridRow ($l1, $patSel);
  
//  var $l2 = wgt._generateFormGridColLabel('Select a Plan Date');  
//  var $r2 = wgt._generateFormGridRow ($l2, $planDate);
  
//  var $l3 = wgt._generateFormGridColLabel('Plan Participants');  
//  var $r3 = wgt._generateFormGridRow ($l3, $divPatPersons);
  
//  var $l4 = wgt._generateFormGridColLabel('Plan Signatures');  
//  var $r4 = wgt._generateFormGridRow ($l4, $divPlanSigs);
     
//  var $fg = wgt._generateFormGridContainer ($r1,$r2,$r3,$r4);
  
//  var instContent =  '<ul>'
//                  + '<li>Plan Participants - Click Add New to add a person related to this plan. This may be parent/guardian, teacher, or primary care physician. '
//                  + 'Once a relationship has been added, you can then choose to add the information to the plan, by clicking the plus sign. ' 
//                  + 'To remove them, click the minus sign.</li>'
//                  + '<li>Plan Signatures - Click the plus sign to add a person to the signature portion of this plan and click the minus sign to remove them.</li>'
//                  + '</ul>';
				   
//  var $instructions = wgt._generateInstructionsBox(instContent);
//  $(frm).append($instructions);

//  $(frm).append($fg);
//  $(frm).append($planType);
  

  
//  var $constParmsObjCommon = [  { name:"clientid",            value:(wgt.options.organizationID)}
//                              , { name:"groupsvcclassnameid", value:(wgt.options.ownerID)}  
//                              , { name:"planid",              value:(wgt.options.id)}
//                             ];
                                                         
//  var $dynamicParmsObjCommon = [
//    {
//        fnName  :function(){ return 'patientid';}
//      , fnValue :function(){ return '' + $('#' +  wgt.options.chg_patientid_id).val();}
//    }
//  ];

//  /* Enhance */
  
//  var $patSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,"patients.asmx/viewSel");
//  var $patSelNVP = [   { name:"clientid",       value:(wgt.options.organizationID) }
//                     , { name:"pracid",         value:"" }	
//					 , { name:"dos",            value:"" }							  
//				     , { name:"patdatasource",  value:"0" }							  
//			        ];
					
//  $($patSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:($patSelUrl),data:"",namevalues:($patSelNVP),getnamevaluesfn:null}});	 
//  $($planDate).spedmonDatebox({multidate:false,showOK:false,maxDate:'',dateText:(wgt.options.startDateDflt),defaultDate:(wgt.options.startDateDflt),useVisibleWorkaround:false});

//   $($divPatPersons).entityrecordmanage ({
//      tkn:(wgt.options.tkn)
//    , allowAddNew:true
//    , allowEdit:true
//    , allowDelete:false
//	, allowFlag:true
//    , viewSelMethodBaseUrl:"plan_writer_plans_patient_persons.asmx/viewSel"
//    , saveFormBaseUrl:"user_all_patient_persons_save.aspx"     
//    , deleteMethodBaseUrl:""
//	, flagMethodBaseUrl:"plan_writer_plans_patient_persons.asmx/toggleFlagRecord"
//	, waitingMessage:"Waiting for you to finish with the persons record"
//    , constantParmsObjCommon:($constParmsObjCommon)
//    , dynamicParmsObjCommon:($dynamicParmsObjCommon)
//  });
  
//  $($divPlanSigs).entityrecordmanage ({
//      tkn:(wgt.options.tkn)
//    , allowAddNew:false
//    , allowEdit:true
//    , allowDelete:false
//	, allowFlag:true
//    , viewSelMethodBaseUrl:"plan_writer_plans_signature_lines.asmx/viewSel"
//    , saveFormBaseUrl:"user_all_plan_writer_plans_signature_line_save.aspx"
//    , deleteMethodBaseUrl:""
//	, flagMethodBaseUrl:"plan_writer_plans_signature_lines.asmx/toggleFlagRecord"
//	, waitingMessage:"Waiting for you to finish with the signature record"
//    , constantParmsObjCommon:($constParmsObjCommon)
//    , dynamicParmsObjCommon:($dynamicParmsObjCommon)
//  });
  
//};

///***************************************************************************
// * fnPrintPlanFormPopulate */
///**
// * Note: Called by entitygroup
// ***************************************************************************/   

//function fnPrintPlanFormPopulate (wgt,$frm) {  
//};

///***************************************************************************
// * fnPrintPlanDiaContent */
///**
// * Note: Called by entitygroup
// ***************************************************************************/   
 
//function fnPrintPlanDiaContent (wgt,dia,frm) {
       
//  $(frm).append('<input name="organizationID" value="' + wgt.options.organizationID +'"  type="hidden" />');
//  $(frm).append('<input name="ownerID"        value="' + wgt.options.ownerID        +'"  type="hidden" />');
//  $(frm).append('<input name="groupID"        value="' + wgt.options.id             +'"  type="hidden" />');
    
//  /*============================================================
//   * Create unique ids for fields we will be enhancing or
//   * interacting with
//   *============================================================*/ 
  
//  var me_id  = $(wgt.element).attr('id');
//  var frm_id = $(frm).attr('id');    
    
//  var $planName = $('<span class="mba-entity-dia-inline-label">' + wgt.options.name + '</span>');
  
//  /*============================================================
//   * Build grid
//   *============================================================*/ 
  
//  var $l1 = wgt._generateFormGridColLabel('Print Care Plan For');  
//  var $r1 = wgt._generateFormGridRow ($l1, $planName);
    
//  var $fg = wgt._generateFormGridContainer ($r1);  
//  $(frm).append($fg);       
//}; 


///*#####################################################################################################################
//  #
//  # Plan Conditions
//  #
//  #####################################################################################################################*/ 


///***************************************************************************
// * fnGetPlanConditionsRequestData */
///**
// ***************************************************************************/   

//function fnGetPlanConditionsRequestData (wgt) {
   
//  var reqData = '{'
//                 + '"organizationID":"'  + wgt.options.organizationID + '"'
//                + ',"ownerID":"'        + wgt.options.ownerID        + '"'
//                 + ',"groupID":"'        + wgt.options.id             + '"'
//                 + ',"term":"'           + ''                         + '"'
//                 + '}';
//  return reqData;
//};
     

///***************************************************************************
// * fnAddPlanConditionDiaContent
///**
// ***************************************************************************/   

//function fnAddPlanConditionDiaContent (wgt, dia, frm ) {
   
//  $(frm).append('<input name="saveType"      value="1" type="hidden"/>');
//  $(frm).append('<input name="recID"         value=""  type="hidden"/>');
  
//  var $condSel = $('<input name="entityID" id="' + wgt.options.add_mbr_form_entity_id  +'" title="Condition Name" class="mba-web-ui-field-simple" type="text"/>');
       
//  var $l1 = wgt._generateFormGridColLabel('Select a Condition');  
//  var $r1 = wgt._generateFormGridRow ($l1, $condSel);
//  var $fg = wgt._generateFormGridContainer ($r1);
  
//  $(frm).append($fg);

//  /* Enhance */
       
//  var $condSelUrl = $.spedmonWebUI.createPrivateURL(wgt.options.tkn,wgt.options.getConditionsFromLibActionURL);
  			   
//  var $condSelNVP = [   { name:"clientID",             value:(wgt.options.organizationID) }
//                     ,  { name:"groupSvcClassNameID",   value:(wgt.options.ownerID)        }
//                    ];
//  $($condSel).spedmonSelectBox({dataParmType:"DOM", selectAll:true, selectType:($.fn.spedmonSelectBox.constants.SELECT_TYPE_COMBO_BOX),onSelect:function(event,ui){ /* */},ajaxopts:{url:($condSelUrl),data:"",namevalues:($condSelNVP),getnamevaluesfn:null}});
//};


///***************************************************************************
// * fnEditPlanConditionFormPopulate
///**
// ***************************************************************************/   

//function fnEditPlanConditionFormPopulate (wgt,$frm,mbrObj) {      
  
//  $('#' + wgt.options.edit_cond_name_id).html('' + mbrObj.lbl);  
//  $('#' + wgt.options.edit_cond_entityid_id).val(mbrObj.entityID);
//  $('#' + wgt.options.edit_cond_clientid_id).val(mbrObj.recData1);
//  $('#' + wgt.options.edit_cond_patid_id).val(mbrObj.recData3);
//  $('#' + wgt.options.edit_cond_diags_id).entityrecordmanage('refresh');    
//  $('#' + wgt.options.edit_cond_pre_orders_id).entityrecordmanage('refresh');    
//  $('#' + wgt.options.edit_cond_svc_descs_id).entityrecordmanage('refresh');    
  
//};

///***************************************************************************
// * fnEditPlanConditionDiaContent 
///**
// ***************************************************************************/   

//function fnEditPlanConditionDiaContent (wgt, dia, frm) {
       
//  /*============================================================
//   * Create unique ids for fields we will be enhancing or
//   * interacting with
//   *============================================================*/ 
  
//  var me_id  = $(wgt.element).attr('id');
//  var frm_id = $(frm).attr('id');    
  
//  wgt.options.edit_cond_entityid_id   = me_id + '-' + frm_id + '-edit-cond-entityid';
//  wgt.options.edit_cond_name_id       = me_id + '-' + frm_id + '-edit-cond-name';
  
//  wgt.options.edit_cond_clientid_id   = me_id + '-' + frm_id + '-edit-cond-clientid';
//  wgt.options.edit_cond_patid_id      = me_id + '-' + frm_id + '-edit-cond-patid';
  
//  wgt.options.edit_cond_diags_id      = me_id + '-' + frm_id + '-edit-cond-diags';
//  wgt.options.edit_cond_pre_orders_id = me_id + '_' + frm_id + '-edit-cond-pre-orders';
//  wgt.options.edit_cond_svc_descs_id  = me_id + '_' + frm_id + '-edit-cond-svc-descs';
  
//  /*============================================================
//   * Build form
//   *============================================================*/ 

//  var $inpCondEntityID = $('<input name="entityID" id="' + wgt.options.edit_cond_entityid_id  + '" type="hidden" />');    
//  var $inpClientID     = $('<input name="patclientid" id="' + wgt.options.edit_cond_clientid_id +'" type="hidden"/>');
//  var $inpPatientID    = $('<input name="patpatientid" id="' + wgt.options.edit_cond_patid_id +'" type="hidden"/>');
  
//  var $spnCondName     = $('<span id="' + wgt.options.edit_cond_name_id  + '"></span>');
//  var $divDiags        = $('<div id="' + wgt.options.edit_cond_diags_id + '"></div>');  
//  var $divPreOrders    = $('<div id="' + wgt.options.edit_cond_pre_orders_id + '"></div>');
//  var $divSvcDescs     = $('<div id="' + wgt.options.edit_cond_svc_descs_id  + '"></div>');
  
//  var instContent = '<ul>'
//                  + '<li>Diagnosis - Select one or more (plus sign) diagnosis to add to this patients plan. You can remove a diagnosis, by clicking the minus sign.</li>'
//                  + '<li>'
//                  + 'Prescribed Orders - If this patient has a previous saved prescribed order in SpEdCare, click the plus sign to add it to this condition. ' 
//                  + 'To remove an order click the minus sign. '
//                  + 'You can add a new prescribed order for a specialized physical healthcare service, by clicking Add New. '
//                  + 'This will also add an order or prescription request on the care plan, where the ordering or prescribing professional can authorize the service.'
//                  + '</li>'
//                  + '<li>'
//                  + 'Accompany and Monitoring - If this patient has a previous saved accompany and monitoring order saved in SpEdCare, click the plus sign to add it to this condition. '
//                  + 'To remove an order click the minus sign. '
//                  + 'You can add a new accompany and monitoring, by clicking Add New. ' 
//                  + 'This will also add an order or prescription request on the care plan, where the ordering or prescribing professional can authorize the service.'
//                  + '</li>'
//                  + '</ul>';
				   
//  var $instructions = wgt._generateInstructionsBox(instContent);
  
//  $(frm).append($instructions);    
  
//  /* TODO: Add patient id to these parms */
  
//  var $constParmsObjCommon = [  { name:"clientid",            value:(wgt.options.organizationID)}
//                              , { name:"groupsvcclassnameid", value:(wgt.options.ownerID)}
//							  , { name:"planid",              value:(wgt.options.id)}
//				             ];
							 
//  var $dynamicParmsObjCommon = [
//    {
//        fnName  :function(){ return 'conditionid';}
//      , fnValue :function(){ return '' + $('#' + wgt.options.edit_cond_entityid_id).val();}
//    }
//    ,
//    {
//        fnName  :function(){ return 'patclientid';}
//      , fnValue :function(){ return '' + $('#' + wgt.options.edit_cond_clientid_id).val();}
//    }
//    ,
//    {
//        fnName  :function(){ return 'patpatientid';}
//      , fnValue :function(){ return '' + $('#' + wgt.options.edit_cond_patid_id).val();}
//    } 
//  ];
  
  
//  var $l1 = wgt._generateFormGridColLabel('Condition Name');
//  var $r1 = wgt._generateFormGridRow ($l1, $spnCondName);
  
//  var $l2 = wgt._generateFormGridColLabel('Diagnosis');  
//  var $r2 = wgt._generateFormGridRow ($l2, $divDiags);      
  
//  var $l3 = wgt._generateFormGridColLabel('Prescribed Orders');  
//  var $r3 = wgt._generateFormGridRow ($l3, $divPreOrders);      
  
//  var $l4 = wgt._generateFormGridColLabel('Accompany and Monitoring');  
//  var $r4 = wgt._generateFormGridRow ($l4, $divSvcDescs);      

//  var $fg = wgt._generateFormGridContainer ($r1,$r2,$r3,$r4);
  
//  $(frm).append($fg);    
//  $(frm).append('<input name="saveType" value="2" type="hidden" />');
//  $(frm).append($inpCondEntityID);
//  $(frm).append($inpClientID);
//  $(frm).append($inpPatientID);
  
//  $($divDiags).entityrecordmanage ({
//      tkn:(wgt.options.tkn)
//	, allowAddNew:false
//    , allowEdit:true
//    , allowDelete:false
//    , viewSelMethodBaseUrl:"plan_writer_plans_conditions_diagnosis.asmx/viewSel"
//	, saveFormBaseUrl:"user_all_plan_writer_plans_conditions_diagnosis_save.aspx"
//    , deleteMethodBaseUrl:"plan_writer_plans_conditions_diagnosis.asmx/delete"
//	, flagMethodBaseUrl:"plan_writer_plans_conditions_diagnosis.asmx/toggleFlagRecord"
//	, waitingMessage:"Waiting for you to finish with the diagnosis record"
//    , constantParmsObjCommon:($constParmsObjCommon)
//    , dynamicParmsObjCommon:($dynamicParmsObjCommon)
//  });
  
//  $($divPreOrders).entityrecordmanage ({
//      tkn:(wgt.options.tkn)
//	, allowAddNew:true
//    , allowEdit:false
//    , allowDelete:false	
//    , viewSelMethodBaseUrl:"plan_writer_plans_conditions_prescribed_orders.asmx/viewSel"
//    , saveFormMenuLinkID:"manageordersnewlink"
//    , saveFormBaseUrl:""
//    , deleteMethodBaseUrl:"plan_writer_plans_conditions_prescribed_orders.asmx/delete"
//	, flagMethodBaseUrl:"plan_writer_plans_conditions_prescribed_orders.asmx/toggleFlagRecord"
//	, waitingMessage:"Waiting for you to finish with the prescription record"
//    , constantParmsObjCommon:($constParmsObjCommon)
//    , dynamicParmsObjCommon:($dynamicParmsObjCommon)
//  });
  
//  $($divSvcDescs).entityrecordmanage ({
//      tkn:(wgt.options.tkn)
//	, allowAddNew:true
//    , allowEdit:false
//    , allowDelete:false	
//    , viewSelMethodBaseUrl:"plan_writer_plans_conditions_service_descriptions.asmx/viewSel"
//    , saveFormMenuLinkID:"managesvcdescrlink"
//	, saveFormBaseUrl:""
//    , deleteMethodBaseUrl:"plan_writer_plans_conditions_service_descriptions.asmx/delete"
//	, flagMethodBaseUrl:"plan_writer_plans_conditions_service_descriptions.asmx/toggleFlagRecord"
//	, waitingMessage:"Waiting for you to finish with the service description record"
//    , constantParmsObjCommon:($constParmsObjCommon)
//    , dynamicParmsObjCommon:($dynamicParmsObjCommon)
//  });
  
    
  
//};


///***************************************************************************
// * fnRemovePlanConditionDiaContent
///**
// ***************************************************************************/   

//function fnRemovePlanConditionDiaContent (wgt,dia,frm) {
            
//	 $(frm).append('<input id="' + wgt.options.rem_mbr_form_entity_id +'" name="entityID" value="" type="hidden" />');
	
//	 $(frm).append('<br/>');
//     $(frm).append('Do you really want to remove <span id="' + wgt.options.rem_mbr_form_lbl + '" class="' + wgt.options.diaGroupOrMemberInlineLabelClass +'"></span>?');
//	 $(frm).append('<br/>');	 
//}

///*#####################################################################################################################
//  #
//  # Setup
//  #
//  #####################################################################################################################*/ 

///***************************************************************************
// * setupPlanWriterWidgets
///**
// ***************************************************************************/   

//function setupPlanWriterWidgets (  $tkn 
//                                  , $clientID
//								  , $grpSvcClassNameID
//								  , $sharedConditions
//								  , $myConditions
//								  , $plans
//								  , $conditionsCol
//								  , $plansCol
//								  , $fileUploadHandler
//								  , $fileUploadClass) {

//  var $getConditionsSharedActionURL = "plan_writer_conditions.asmx/viewSelSharedLib";  
 
// /*============================================================
//   * Create Shared Conditions Library widget
//   *============================================================*/   

//  $($sharedConditions).entitygroup ({  id: $grpSvcClassNameID
//                                     , organizationID: $clientID
//							         , ownerID: $grpSvcClassNameID
//                                     , name: "Shared Conditions Library"
//                                     , tkn: $tkn	
//							         , entitiesAreExternal: false
//                                     , allowShowHideContent: true
//									 , contentInitiallyShownOrHidden:"hidden"
//                                     , allowRemoveGroup: false
//                                     , allowAddMember: false
//									 , allowMemberEdit:false
//									 , allowMemberRemove:false
//									 , allowAddMemberDrop: false
//                                     , afterAddMemberEditMember:false
//                                     , allowPrintGroup:false
//							         , searchTermInpPlaceholder:"Type Text to Filter Condition List"
//                                     , getMembersActionURL: $getConditionsSharedActionURL
//                                     , fnGetMembersRequestData: (fnGetMembersConditionsRequestData)
//							         , logToConsole:false
//                                   });

//  /*============================================================
//   * My Conditions Library
//   *============================================================*/   

//  var $getConditionsActionURL           = "plan_writer_conditions.asmx/viewSelMyLib";
//  var $addMemberConditionsActionURL     = "plan_writer_conditions.asmx/saveMember";
//  var $editMemberConditionsActionURL    = "plan_writer_conditions.asmx/saveMember";
//  var $removeMemberConditionsActionURL  = "plan_writer_conditions.asmx/deleteMember";
       
//  /*============================================================
//   * Create My Conditions library widget
//   *============================================================*/   

//  $($myConditions).entitygroup ({  id: $grpSvcClassNameID
//                               , organizationID: $clientID
//							   , ownerID: $grpSvcClassNameID
//                               , name: "My Conditions Library"
//                               , tkn: $tkn	
//							   , entitiesAreExternal: false
//                               , allowShowHideContent: true
//                               , allowRemoveGroup: false
//                               , allowAddMemberDrop: false
//                               , afterAddMemberEditMember:true
//                               , allowPrintGroup:false
//							   , searchTermInpPlaceholder:"Type Text to Filter Condition List"
//                               , addMemberButLabel:"Add Condition"
//                               , addMemberDiaTitle:"Add New Condition"
//			                   , addMemberDiaWidth: 575
//                               , addMemberDiaHeight: 200
//                               , addMemberDiaResizable: true               								 
//                               , editMemberButLabel:"Edit Condition"
//                               , editMemberDiaTitle:"Edit Condition"
//                               , editMemberDiaWidth: 850
//                               , editMemberDiaHeight: 500
//                               , editMemberDiaResizable: true               								 
//							   , fnOnSuccessEditMember:function(wgt,rd) {/* Overide dflt */ return true;}
//							   , removeMemberButLabel:"Remove Condition"
//                               , removeMemberDiaTitle:"Remove Condition from List"                               
//                               , getMembersActionURL: $getConditionsActionURL 
//                               , addNewMemberActionURL: $addMemberConditionsActionURL
//                               , editMemberActionURL: $editMemberConditionsActionURL
//                               , removeMemberActionURL: $removeMemberConditionsActionURL
//                               , removeGroupActionURL: ''
//                               , fnGetMembersRequestData: (fnGetMembersConditionsRequestData)
//                               , fnAddMemberDiaContent: (fnAddMemberConditionsDiaContent)
//                               , fnEditMemberFormPopulate: (fnEditMemberConditionsFormPopulate)
//                               , fnEditMemberDiaContent: (fnEditMemberConditionsDiaContent)
//							   , logToConsole:false
//                            });
							
//  /*============================================================
//   * Plans
//   *============================================================*/   

//  var $getPlansActionURL      = "plan_writer_plans.asmx/viewSel";
//  var $addNewPlanActionURL    = "plan_writer_plans.asmx/save";
//  var $changePlanActionURL    = "plan_writer_plans.asmx/save";
//  var $removePlanActionURL    = "plan_writer_plans.asmx/delete";
//  var $printPlanActionURL     = "plan_writer_plans_file.ashx";						 
  
//  /*============================================================
//   * Plan Conditions
//   *============================================================*/   
  
//  var $getPlanConditionsActionURL   = "plan_writer_plans_conditions.asmx/viewSel";
//  var $addPlanConditonActionURL     = "plan_writer_plans_conditions.asmx/saveMember";
//  var $editPlanConditionActionURL   = "plan_writer_plans_conditions.asmx/saveMember";
//  var $removePlanConditionActionURL = "plan_writer_plans_conditions.asmx/deleteMember";
  
//  /*============================================================
//   * Delegate for creating plan widget
//   *============================================================*/   

//  var $fnRenderPlanWidget = function (wgt,grpObj,grpMkup) {
    
//    $(grpMkup).entitygroup( {  id: (grpObj.groupID)
//                             , organizationID: $clientID
//                             , ownerID: $grpSvcClassNameID
//                             , name: (grpObj.lbl)
//                             , context1:(grpObj.context1)
//							 , recData1:(grpObj.recData1)
//							 , recData2:(grpObj.recData2)
//							 , recData3:(grpObj.recData3)
//							 , recData4:(grpObj.recData4)
//							 , recData5:(grpObj.recData5)
//							 , recData6:(grpObj.recData6)
//							 , recData7:(grpObj.recData7)
//							 , recData8:(grpObj.recData8)
//							 , recData9:(grpObj.recData9)
//							 , recData10:(grpObj.recData10)
//							 , recData11:(grpObj.recData11)
//						     , recData12:(grpObj.recData12)
//							 , recData13:(grpObj.recData13)
//							 , recData14:(grpObj.recData14)
//							 , recData15:(grpObj.recData15)
//							 , recData16:(grpObj.recData16)
//							 , entityGroupsReference1:($plans)
//							 , tkn: $tkn				             
//                             , allowChangeGroupName: true
//                             , changeGroupNameButLabel:"Edit Plan Date, Participants and Signatures"
//                             , changeGroupNameDiaTitle:"Edit Plan Date, Participants and Signatures"
//							 , changeGroupNameDiaWidth: 850
//                             , changeGroupNameDiaHeight: 550
//                             , changeGroupNameDiaResizable: true
//                             , allowShowHideContent: true
//							 , showHideOnTitleClick:false
//                             , allowRemoveGroup: true
//                             , allowUploadFileForGroup:true							 
//							 , allowAddMemberDrop: true
//                             , allowMemberEdit:true
//                             , afterAddMemberEditMember:true
//                             , allowFilterGroup:false
//							 , allowPrintGroup:true
//							 , allowSortGroup:false
//							 , showHideContentButLabel:"Show or Hide Plan Details"
//                             , showHideContentButTitle:"Show or Hide Plan Details"
//                             , addMemberButLabel:"Add Condition"
//                             , addMemberDiaTitle:"Add Condition to This Plan"
//							 , addMemberDiaWidth: 775
//                             , addMemberDiaHeight: 200
//                             , addMemberDiaResizable: true
//                             , editMemberButLabel:"Edit Condition"
//                             , editMemberDiaTitle:"Edit Condition for This Plan"  
//							 , editMemberDiaWidth:850
//                             , editMemberDiaHeight:500
//                             , editMemberDiaResizable: true
//                             , removeMemberButLabel:"Remove Condition"
//                             , removeMemberDiaTitle:"Remove Condition From This Plan" 
//							 , fnRemoveMemberDiaContent: (fnRemovePlanConditionDiaContent)
//							 , printGroupButLabel:"Print This Plan"
//                             , printGroupButTitle:"Print This Plan"
//                             , printGroupDiaTitle:"Print This Plan"
//							 , printGroupDiaWidth:600
//                             , printGroupDiaHeight:215
//                             , printGroupDiaResizable:true  
//							 , fnPrintGroupFormPopulate: (fnPrintPlanFormPopulate)
//                             , fnPrintGroupDiaContent: (fnPrintPlanDiaContent)
//                             , getMembersActionURL: $getPlanConditionsActionURL
//                             , addNewMemberActionURL: $addPlanConditonActionURL
//                             , editMemberActionURL: $editPlanConditionActionURL                          
//                             , removeMemberActionURL: $removePlanConditionActionURL
//							 , changeGroupNameActionURL: $changePlanActionURL
//                             , removeGroupActionURL:  $removePlanActionURL
//							 , printGroupActionURL:   $printPlanActionURL
//                             , fnGetMembersRequestData: (fnGetPlanConditionsRequestData)
//                             , fnAddMemberDiaContent: (fnAddPlanConditionDiaContent)
//                             , removeGroupButLabel:"Remove Plan"
//                             , removeGroupDiaTitle:"Remove This Plan"
//                             , fnEditMemberFormPopulate: (fnEditPlanConditionFormPopulate)
//                             , fnEditMemberDiaContent: (fnEditPlanConditionDiaContent)
//							 , fnChangeGroupNameFormPopulate: (fnChangePlanFormPopulate)
//							 , fnChangeGroupNameDiaContent: (fnChangePlanDiaContent)
//                             , getConditionsFromLibActionURL:$getConditionsActionURL	
//							 , uploadFileForGroupButLabel:"Upload Completed Plan"
//                             , uploadFileForGroupButTitle:"Upload A Completed Plan"
//	                         , uploadFileForGroupFnDoFileUpload:function(wgt) {
							 
//							       var fileAdditionalDataJSONStr = '{clientid:' + wgt.options.organizationID + ', patid:' + wgt.options.recData1 + '}'; 
								   
//								   var fnCloseUploadSuccess = function() {
								   
//								   };
								   
//	                               $.spedmonWebUI.fileUpload (  (wgt.options.uploadFileForGroupButTitle)
//		  					                                 , ($fileUploadHandler)
//								                             , ($fileUploadClass)							                                 
//							                                 , ''
//                                                             , 'Plan Writer'
//                                                             , ''
//							                                 , (fileAdditionalDataJSONStr)
//							                                 , true
//								                             , fnCloseUploadSuccess );
//	                           }							   
//							 , logToConsole:false
//                             });
//  };
 
//  /*============================================================
//   * Create plans list widget   
//   *============================================================*/   
  
//   $($plans).entitygroups ({  id: $grpSvcClassNameID
//                            , organizationID: $clientID
//							, ownerID: $grpSvcClassNameID
//                            , name: "Current Plans"
//                            , tkn: $tkn
//							, allowPrintGroups:false
//							, allowShowHideGroupsContent:true
//							, allowFilterGroups:true
//							, searchTermInpTitle:"Filter Plans"
//                            , searchTermInpPlaceholder:"Enter Text to Filter Plans By"
//							, showHideGroupsContentButLabel:"Show or Hide All Plan Details"
//                            , showHideGroupsContentButTitle:"Show or Hide All Plan Details"
//                            , addNewGroupButLabel:"Add Plan"
//                            , addNewGroupDiaTitle:"Add New Plan"
//							, addNewGroupDiaWidth:775
//							, addNewGroupDiaHeight:300
//							, addNewGroupDiaResizable: true							
//							, getGroupsActionURL:$getPlansActionURL
//                            , addNewGroupActionURL: $addNewPlanActionURL
//                            , fnGetGroupsRequestData:(fnGetPlansRequestData)
//                            , fnRenderGroupWidget:$fnRenderPlanWidget
//                            , fnAddNewGroupDiaContent:(fnAddNewPlanDiaContent)
//							, logToConsole:false
//                           });   			
 
 
//};
