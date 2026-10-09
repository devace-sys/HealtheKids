using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;
using MBA;
using MBA.IdentifyData;
using System.Linq;

namespace MBA 
{      
    
  /**************************************************************************
   * StepSelectService */
  /**
   * Controls used to select a nameid
   ****************************************************************************/

  public class StepSelectService:StepBase
  {  
    
    public StepSelectService()
    {                          
    }

    /*-------------------------------
     * Property values
     *------------------------------*/
    
    protected string    _saveFormID                 = "save";
    protected string    _nextStepID                 = "step5";
    protected string    _nextStepNumber             = "4";
    protected string    _timeBasedID                = @"timebased";
    protected string    _mileBasedID                = @"milebased"; 
    protected string    _batchMinMilDetGridID       = "details";
    
    protected string    _nameIDID                   = "nameid";
    protected string    _nameIDValue                = "";
    
    protected string    _svcTypeID                  = "svctype";
    protected string    _svcTypeValue               = "";
        
    protected string    _hasSvcDetFlagsID           = @"hasSvcDetFlags";
    protected string    _hasSvcDetFlagsValue        = @"";
    
    protected string    _orpDocContID               = @"orpDocCont";
    protected string    _hasORPDocIDID              = @"hasOrpDocID";
    protected string    _hasORPDocIDValue           = @"";
    
    protected string    _svcDetContID               = "svcDetCont";
    protected string    _svcEntrySingleOrBatchID    = @"svcEntrySingleorBatch";
    protected string    _svcEntrySingleOrBatchValue = @"BATCH";

    protected string    _detFlagYNCommonTitle       = @"Y/N";
    protected string    _detFlagYNCommonCSS         = @"width:2em";   
    protected string    _svcDetFlagsContID          = @"svcDetFlagsCont";
    
    protected string    _svcDetFlag1ID              = "svcDetFlag1";
    protected string    _svcDetFlag1Value           = "";

    protected string    _svcDetFlag2ID              = "svcDetFlag2";
    protected string    _svcDetFlag2Value           = "";

    protected string    _svcDetFlag3ID              = "svcDetFlag3";
    protected string    _svcDetFlag3Value           = "";

    protected string    _svcDetFlag4ID              = "svcDetFlag4";
    protected string    _svcDetFlag4Value           = "";
        
    protected string    _svcDetFlagsOKID            = @"svcDetFlagsOK";
    protected string    _slpAssmtInstrID            = @"slpAssmtInstrID";
    
    protected string    _selORPDocIDID              = @"orpDocID";
    protected string    _selORPDocIDValue           = @"";
    protected string    _selORPDocIDLabel           = @"";
    
    protected string    _selORPDocOKID              = @"selORPDocIDOK";
    
    protected string    _addOrdPresID               = @"addOrdPres";
    protected string    _addPatProfID               = @"addPatProf";
    
    protected string    _selNameIDParms             = "[{id:'clientid'},{id:'pracid'},{id:'dos'},{id:'patid'},{id:'isiep'}]"; 
    protected string    _selNameIDUrl               = "services.asmx/viewSel";

    protected string    _selORPDocIDParms           = @"[{id:'clientid'},{id:'pracid'},{id:'patid'}]"; 
    protected string    _selORPDocIDUrl             = @"orp_documents.asmx/viewSel";

    protected bool      _autoOpenServiceList        = false;
    
    /*-------------------------------
     * Properties
     *------------------------------*/
    
    public string  saveFormID                 { get { return _saveFormID; }      set {_saveFormID     = value;} }
    public string  nextStepID                 { get { return _nextStepID; }      set {_nextStepID     = value;} }
    public string  nextStepNumber             { get { return _nextStepNumber;}   set {_nextStepNumber = value;} }    
    
    public string  nameIDID                   { get { return _nameIDID;    }     set { _nameIDID      = value;} }
    public string  nameIDValue                { get { return _nameIDValue; }     set { _nameIDValue   = value;} }
    
    public string  svcTypeID                  { get { return _svcTypeID;              }  set { _svcTypeID              = value; }}    
    public string  svcTypeValue               { get { return _svcTypeValue;           }  set { _svcTypeValue           = value; }}
    
    public string  hasORPDocIDID              { get { return _hasORPDocIDID;}}
    public string  hasORPDocIDValue           { get { return _hasORPDocIDValue; }   set { _hasORPDocIDValue = value;  }}
    public string  selORPDocIDID              { get { return _selORPDocIDID;    }   set { _selORPDocIDID     = value; }}    

    public string  addOrdPresButID            { get { return _addOrdPresID;     }   set { _addOrdPresID      = value; }}
    public string  addPatProfButID            { get { return _addPatProfID;     }   set { _addPatProfID      = value; }}    
    
    public string  selORPDocIDValue           { get { return _selORPDocIDValue; }   set { if (value == "0") value = @"";
                                                                                         _selORPDocIDValue  = value; }}
    
    public string  selORPDocIDLabel           { get { return _selORPDocIDLabel; }   set { _selORPDocIDLabel  = value; }}

    public string  hasSvcDetFlagsID           { get { return _hasSvcDetFlagsID;    } set { _hasSvcDetFlagsID     = value; } }    
    public string  hasSvcDetFlagsValue        { get { return _hasSvcDetFlagsValue; } set { _hasSvcDetFlagsValue  = value; } }
  
    public string  svcDetFlag1ID              { get { return _svcDetFlag1ID ;   }   set { _svcDetFlag1ID    = value; }}    
    public string  svcDetFlag1Value           { get { return _svcDetFlag1Value; }   set { _svcDetFlag1Value = value; }}
 
    public string  svcDetFlag2ID              { get { return _svcDetFlag2ID ;   }   set { _svcDetFlag2ID    = value;} }    
    public string  svcDetFlag2Value           { get { return _svcDetFlag2Value; }   set { _svcDetFlag2Value = value;} }

    public string  svcDetFlag3ID              { get { return _svcDetFlag3ID ;   }   set { _svcDetFlag3ID    = value;} }    
    public string  svcDetFlag3Value           { get { return _svcDetFlag3Value; }   set { _svcDetFlag3Value = value;} }

    public string  svcDetFlag4ID              { get { return _svcDetFlag4ID ;   }   set { _svcDetFlag4ID    = value;} }    
    public string  svcDetFlag4Value           { get { return _svcDetFlag4Value; }   set { _svcDetFlag4Value = value;} }
       
    public string  svcEntrySingleOrBatchValue { get { return _svcEntrySingleOrBatchValue; } set { _svcEntrySingleOrBatchValue = value; } }    
    public bool    autoOpenServiceList        { get { return _autoOpenServiceList;        } set { _autoOpenServiceList        = value; } }
  
    protected override void Render(HtmlTextWriter writer)
    {                                

      /*-------------------------------
       * Get out if user is logged out
       *------------------------------*/

      if (rd.loggedIn == false) 
        return;

      /*-------------------------------
       * If title is not provided
       * use default
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(this._title))
        this._title = @"Select a Service";
          
      /*-------------------------------
       * If instructions are not provided
       * use default
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(this._instr))  
        this._instr = @"Please select a service from the drop-down below.  If you want to record a treatment or therapy service that is NOT authorized in ANY plan, select the “Notes and Other Services” option. Additionally, you can use this option to record; Additional services notes, consultations, training, guidance or any other non-billable activity.";


      /*-------------------------------
       * Init on clear 
       *------------------------------*/

      this._onclear =  @";doInitSelOrpAndSvcDet();";
     
      /*-------------------------------
       * When the step is activated init
       * auto activate list if desired
       * and prevent auto next step
       *------------------------------*/
     
     this._onactive = @";doInitSelOrpAndSvcDet();";
     
      /*-------------------------------
       * Auto activate the list if 
       * desired
       *------------------------------*/

     if (this._autoOpenServiceList == true)
       this._onactive = this._onactive + @";doOpenServiceList();";
     
      /*-------------------------------
       * Prevent auto next step
       *------------------------------*/

     this._autoNextStep = false;

      /*-------------------------------
       * Commence rendering base
       * Note: the base will call
       * render()
       *------------------------------*/

      base.Render(writer);
    }
    
    protected override void render(ref HtmlTextWriter writer)
    {
      /*============================================================
       * Get user data
       *===========================================================*/  

      /*-------------------------------
       * Get out if user is logged out
       * otherwise get the user group
       * and lowered role name
       *------------------------------*/

      if (rd.loggedIn == false) return;                          
      int userGroup        = rd.wu.usr.userGroupID;
      string roleNameLower = rd.wu.usr.roleName.ToLower();

      /*-------------------------------
       * Create controls but don't 
       * render yet
       *------------------------------*/  
                                                    
      MBA.HiddenInput svcEntrySingleOrBatch = new MBA.HiddenInput();
    
      svcEntrySingleOrBatch.ID        = _svcEntrySingleOrBatchID;
      svcEntrySingleOrBatch.name      = _svcEntrySingleOrBatchID;
      svcEntrySingleOrBatch.title     = _svcEntrySingleOrBatchID;
      svcEntrySingleOrBatch.noSubmit  = true;
      svcEntrySingleOrBatch.noClear   = true;
      svcEntrySingleOrBatch.value     = _svcEntrySingleOrBatchValue;
    
      MBA.HiddenInput svcType = new MBA.HiddenInput();
      
      svcType.ID       = _svcTypeID;
      svcType.name     = _svcTypeID;
      svcType.title    = _svcTypeID;
      svcType.value    = _svcTypeValue;
      svcType.noSubmit = true;
                
      MBA.HiddenInput hasSvcDetFlags = new MBA.HiddenInput();
      
      hasSvcDetFlags.ID    = _hasSvcDetFlagsID;
      hasSvcDetFlags.name  = _hasSvcDetFlagsID;
      hasSvcDetFlags.title = _hasSvcDetFlagsID;
      hasSvcDetFlags.value = _hasSvcDetFlagsValue;
                        
      MBA.ComboBox selNameID = new MBA.ComboBox();
                   
      selNameID.ID          = _nameIDID;;
      selNameID.name        = _nameIDID;
      selNameID.value       = _nameIDValue;
      selNameID.title       = "Select Service";
      selNameID.dataPrivate = true;
      selNameID.dataURL     = _selNameIDUrl;
      selNameID.dataParms   = _selNameIDParms;
      selNameID.onSelect    = @"doUpdateSvcEntryMode(ui)";
                        
      MBA.HiddenInput hasOrpDocID = new MBA.HiddenInput();
      hasOrpDocID.ID    = _hasORPDocIDID;
      hasOrpDocID.name  = _hasORPDocIDID;
      hasOrpDocID.title = _hasORPDocIDID;
      hasOrpDocID.value = _hasORPDocIDValue;
      
      MBA.Button selORPDocOK = new MBA.Button();
      selORPDocOK.ID      = _selORPDocOKID;
      selORPDocOK.text    = @"OK";
      selORPDocOK.title   = @"OK";
      selORPDocOK.cssInline = @"display:inline-block;margin-left:,5em;";
      selORPDocOK.onclick = @"doAcceptOrpDocIDSel()";
      
      MBA.ComboBox selOrpDocID  = new MBA.ComboBox();
      selOrpDocID.ID            = _selORPDocIDID;
      selOrpDocID.name          = _selORPDocIDID;
      selOrpDocID.value         = _selORPDocIDValue;
      selOrpDocID.selectName    = _selORPDocIDLabel;
      selOrpDocID.title         = "Select Order or Prescription";
      selOrpDocID.dataPrivate   = true;
      selOrpDocID.dataURL       = _selORPDocIDUrl;
      selOrpDocID.dataParms     = _selORPDocIDParms;
      selOrpDocID.displayInline = true;
      selOrpDocID.onSelect      = @"";
            
      /* Note this uses the menu link id in the js to navigate to the appropriate page */
      MBA.Button addOrdPresBut = new MBA.Button();
      addOrdPresBut.ID        = _addOrdPresID;
      addOrdPresBut.text      = @"Add A New Order or Prescription";
      addOrdPresBut.title     = @"Click here to add a new order or prescription";
      addOrdPresBut.cssClass  = @"ui-spedmon-step-sel-opt";
      addOrdPresBut.cssInline = @"display:inline-block;margin-left:,5em;";
      addOrdPresBut.onclick   = @"$.spedmonWebUI.openAddNewServiceJournalsPrescribedOrderForm(null,null,null,null,null,null);";
      
      /* Note this uses the menu link id in the js to navigate to the appropriate page */
      MBA.Button addPatProfBut = new MBA.Button();
      addPatProfBut.ID         = _addPatProfID;
      addPatProfBut.text       = @"Add A New Patient Profile";
      addPatProfBut.title      = @"Click here to add a new patient profile";
      addPatProfBut.cssClass   = @"ui-spedmon-step-sel-opt";
      addPatProfBut.cssInline  = @"display:inline-block;margin-left:,5em;";
      addPatProfBut.onclick    = @"$.spedmonWebUI.openAddNewServiceJournalsServiceDescriptionForm(null,null,null,null,null,null);";
            
      MBA.YesNo svcDetFlag1 = new MBA.YesNo();
    
      svcDetFlag1.ID        = _svcDetFlag1ID;
      svcDetFlag1.name      = _svcDetFlag1ID;
      svcDetFlag1.title     = _detFlagYNCommonTitle;
      svcDetFlag1.cssInline = _detFlagYNCommonCSS;
      svcDetFlag1.value     = _svcDetFlag1Value;
    
      MBA.YesNo svcDetFlag2 = new MBA.YesNo();
    
      svcDetFlag2.ID        = _svcDetFlag2ID;
      svcDetFlag2.name      = _svcDetFlag2ID;
      svcDetFlag2.title     = _detFlagYNCommonTitle;
      svcDetFlag2.cssInline = _detFlagYNCommonCSS;
      svcDetFlag2.value     = _svcDetFlag2Value;
    
      MBA.YesNo svcDetFlag3 = new MBA.YesNo();
    
      svcDetFlag3.ID        = _svcDetFlag3ID;
      svcDetFlag3.name      = _svcDetFlag3ID;
      svcDetFlag3.title     = _detFlagYNCommonTitle;
      svcDetFlag3.cssInline = _detFlagYNCommonCSS;
      svcDetFlag3.value     = _svcDetFlag3Value;
    
      MBA.YesNo svcDetFlag4 = new MBA.YesNo();
    
      svcDetFlag4.ID        = _svcDetFlag4ID;
      svcDetFlag4.name      = _svcDetFlag4ID;
      svcDetFlag4.title     = _detFlagYNCommonTitle;
      svcDetFlag4.cssInline = _detFlagYNCommonCSS;
      svcDetFlag4.value     = _svcDetFlag4Value;
    
      MBA.Button svcDetFlagsOK = new MBA.Button();
      
      svcDetFlagsOK.ID      = _svcDetFlagsOKID;
      svcDetFlagsOK.text    = @"OK";
      svcDetFlagsOK.title   = @"OK";
      svcDetFlagsOK.onclick = @"doAcceptSvcDetFlags()";
      
      MBA.Link slpAssmtInstLink = new Link();
      
      slpAssmtInstLink.ID         = _slpAssmtInstrID;
      slpAssmtInstLink.url        = @"client_prov_slp_assmt_instructions_2017_02_17.html";
      slpAssmtInstLink.pvt        = false;
      slpAssmtInstLink.title      = @"Click here";
      slpAssmtInstLink.linkMode   = 1;
      slpAssmtInstLink.text       = @"Click Here";
      slpAssmtInstLink.beforeOpen = "function(){}";
      
      /*-------------------------------
       * Render controls
       *------------------------------*/  
             
      /* Common */

      selNameID.RenderControl(writer);             /* Select service */      
      svcEntrySingleOrBatch.RenderControl(writer); /* Single or batch entry */     
      svcType.RenderControl(writer);               /* Service type */
      
      /* ORP document container */
      
      writer.Write(@"<div id=""{0}"">",_orpDocContID);
      
      writer.Write(@"<div class=""ui-spedmon-step-instructions"">");
      writer.Write(@"Please select the order or prescription that is associated with this service from the drop-down below then click OK.");
      writer.Write(@"</div>");

      hasOrpDocID.RenderControl(writer);  /* Has ORP document */
      selOrpDocID.RenderControl(writer);  /* Select ORP Document*/
            
      selORPDocOK.RenderControl(writer);  /* OK button*/

      writer.Write (@"<div class=""additional-info-below-select-entity"">");
      writer.Write (@"If you do not see any applicable orders or prescriptions in the drop-down above, click ");
      addOrdPresBut.RenderControl(writer);
      writer.Write(@" then try your selection again.");
      
      if (roleNameLower != Constants.ROLE_LEA_PROVIDER)      
      {
        /* Only render add patient profile button for non practitioner users.  Health services practitioners are 
         * not supposed to be using the service records entry screens for treatments. */  
             
        writer.Write(@"<br/>");
        writer.Write(@"OR if the treatment you are recording is for accompanying and monitoring services provided by a nurse or health aide, click ");
        addPatProfBut.RenderControl(writer);        
        writer.Write(@" instead to record the order and then try your selection again.");
      }      
      
      writer.Write(@"</div>");
      writer.Write(@"</div>");      
      
      /* Service details container */
      
      writer.Write(@"<div id=""svcDetCont"">");           
      
      hasSvcDetFlags.RenderControl(writer);        /* Has Svc Detail Flags */

      if (userGroup == Constants.USER_GROUP_CLIENT)
      {
        writer.Write(@"<div style=""padding:1em;line-height:2em;font-size:0.8em;font-weight:bold;margin:1em;"">");
        writer.Write(@"Important Instructions: Before selecting NO read guidance from ASHA and CASHA. ");
        slpAssmtInstLink.RenderControl(writer);
        writer.Write(@"</div>");
      }
      
      writer.Write(@"<div class=""ui-spedmon-step-instructions"">");
      writer.Write(@"Please answer <strong style=""text-decoration:underline !important;font-weight:bold !important;"">ALL</strong> of the following questions regarding this assessement then click the OK button below.");
      writer.Write(@"</div>");
      
      writer.Write(@"<table id=""svcDetFlagsCont"" style=""margin:0 auto"" display:""block"">");
      writer.Write(@"<tbody>");
            
      writer.Write(@"<tr>");      
      writer.Write(@"<td class=""ui-state-default"">");
      writer.Write(@"<label for=""svcDetFlag1"" style=""display:inline-block !important; width:100% !important; text-align:left !important;font-weight:bold !important;"">");
      writer.Write(@"Performed Evaluation of Speech Fluency?");
      writer.Write(@"</label>");
      writer.Write(@"</td>");      
      writer.Write(@"<td>");
      svcDetFlag1.RenderControl(writer);
      writer.Write(@"</td>");
      writer.Write(@"</tr>");
      
      writer.Write(@"<tr>");      
      writer.Write(@"<td class=""ui-state-default"">");
      writer.Write(@"<label for=""svcDetFlag2"" style=""display:inline-block !important; width:100% !important; text-align:left !important;font-weight:bold !important;"">");
      writer.Write(@"Performed Evaluation of Speech Sound Production?");
      writer.Write(@"</label>");
      writer.Write(@"</td>");      
      writer.Write(@"<td>");
      svcDetFlag2.RenderControl(writer);
      writer.Write(@"</td>");      
      writer.Write(@"</tr>");
      
      writer.Write(@"<tr>");      
      writer.Write(@"<td class=""ui-state-default"">");
      writer.Write(@"<label for=""svcDetFlag3"" style=""display:inline-block !important; width:100% !important; text-align:left !important;font-weight:bold !important;"">");
      writer.Write(@"Performed Evaluation of Language Comprehension and Expression?");
      writer.Write(@"</label>");
      writer.Write(@"</td>");      
      writer.Write(@"<td>");
      svcDetFlag3.RenderControl(writer);
      writer.Write(@"</td>");      
      writer.Write(@"</tr>");
      
      writer.Write(@"<tr>");      
      writer.Write(@"<td class=""ui-state-default"">");     
      writer.Write(@"<label for=""svcDetFlag4"" style=""display:inline-block !important; width:100% !important; text-align:left !important;font-weight:bold !important;"">");
      writer.Write(@"Performed Behavioral and Qualitative Analysis of Voice and Resonance?");
      writer.Write(@"</label>");
      writer.Write(@"</td>");      
      writer.Write(@"<td>");
      svcDetFlag4.RenderControl(writer);
      writer.Write(@"</td>");      
      writer.Write(@"</tr>");
      
      writer.Write(@"</tbody>");
      writer.Write(@"</table>");

      writer.Write(@"<div class=""ui-spedmon-step-instructions"">");
      writer.Write(@"Click the OK button below when you are done answering the questions above.");
      writer.Write(@"</div>");
      svcDetFlagsOK.RenderControl(writer);
      writer.Write(@"</div>");
      
      
      
      /*-------------------------------
       * Render script 
       *------------------------------*/  
      
      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"function doOpenServiceList() {{$('#{0}_button').click();}}",_nameIDID);
      writer.Write(@"function doGotoNextStepAfterSvcSel() {{$('#{0}_steps').accordion('activate', {1});}}",_saveFormID,_nextStepNumber);
      
      writer.Write(@"function doAcceptOrpDocIDSel() {{doGotoNextStepAfterSvcSel();}}");
      writer.Write(@"function doAcceptSvcDetFlags() {{doGotoNextStepAfterSvcSel();}}");
            
      writer.Write(@"function hasOrpDocID() {{ var hodi = $('#{0}').val(); if (hodi == '1') return true; return false; }}", _hasORPDocIDID);      
      writer.Write(@"function hasSvcDetailFlags() {{ var hsdf = $('#{0}').val(); if (hsdf == '1') return true; return false; }}",_hasSvcDetFlagsID);
      writer.Write(@"function svcEntryIsSingleOrBatch() {{ return $('#{0}').val(); }}",_svcEntrySingleOrBatchID);
      
      writer.Write(@"function clearSelOrpDocID() {{ $('#{0}').spedmonSelectBox_clear();}}", _selORPDocIDID);
      writer.Write(@"function showSelOrpDocID()  {{ $('#{0}').val('1'); $('#{1}').show();}}",                    _hasORPDocIDID, _orpDocContID);
      writer.Write(@"function hideSelOrpDocID()  {{ $('#{0}').val('0'); $('#{1}').hide();clearSelOrpDocID();}}",   _hasORPDocIDID, _orpDocContID);

      writer.Write(@"function clearSvcDetailFlags() {{$('#{0}').val('');$('#{1}').val('');$('#{2}').val('');$('#{3}').val('');}}",_svcDetFlag1ID,_svcDetFlag2ID,_svcDetFlag3ID,_svcDetFlag4ID);      
      writer.Write(@"function showSvcDetailCont() {{$('#{0}').val('1'); $('#{1}').show();}}",_hasSvcDetFlagsID,_svcDetContID);
      writer.Write(@"function hideSvcDetailCont() {{$('#{0}').val('0'); $('#{1}').hide();clearSvcDetailFlags();}}",_hasSvcDetFlagsID,_svcDetContID);
      

      writer.Write(@"      
              
       function doInitOrpDocID(){{         
         if ( hasOrpDocID() == true) showSelOrpDocID(); else hideSelOrpDocID();
       }};
       
       function doInitSvcDetail() {{
         if (hasSvcDetailFlags() == true) showSvcDetailCont(); else hideSvcDetailCont();
         var $svcDetailFlagInputs = $('#{0} tbody').find('input');
         var $svcDetailFlagRows = $('#{0} tbody').find('tr');
         $.each($svcDetailFlagRows, function(ri, detRow) {{
           $(detRow).focusin(function() {{ $(detRow).css('outline', '2px solid Black'); }});
           $(detRow).focusout(function() {{ $(detRow).css('outline', 'none'); }});
         }});
         $('#{0}').bind('spedmoninputdata', function(e) {{
           var ynCur = $('#' + e.dataitem.id);
           var ynCurIdx = $($svcDetailFlagInputs).index(ynCur);
           if (ynCurIdx < 3) {{
             var ynNxtIdx = ynCurIdx + 1;
             var ynNxt = $($svcDetailFlagInputs).get(ynNxtIdx);
             $(ynNxt).focus();
           }}
           return false;
         }});
       }}", _svcDetFlagsContID);
      
      
      writer.Write(@"
       function doUpdateSvcEntryMode(ui) {{

         if (ui.item.showOptions3 == 'SHOW_TELEHEALTH') {{$.spedmonWebUI.msgTeleHealth();}}
         
         $('#{0}').val(ui.item.flag1);

         if (svcEntryIsSingleOrBatch() == 'SINGLE') {{
           if (ui.item.showOptions1 == 'SHOW_MINUTES') $('#{1}').spedmonStep_switchSection('#{2}');
           if (ui.item.showOptions1 == 'SHOW_MILES') $('#{1}').spedmonStep_switchSection('#{3}');
         }}
         
         if (svcEntryIsSingleOrBatch() == 'BATCH') {{
           var minMilDetObj = $('#{4}').data('spedmondatagrid');

           if (ui.item.showOptions1 == 'SHOW_MILES') {{
             minMilDetObj.hideSection('minutes');
             minMilDetObj.showSection('miles');
             minMilDetObj.clearValues('minutes');
           }}
           
           if (ui.item.showOptions1 == 'SHOW_MINUTES') {{
             minMilDetObj.hideSection('miles');
             minMilDetObj.showSection('minutes');
             minMilDetObj.clearValues('miles');
           }}
         
         }}
                         
         if (ui.item.showOptions2 == 'SHOW_SPEECH_ASSESS_OPTIONS') {{
           hideSelOrpDocID();
           showSvcDetailCont();
           return true;
         }} 
         
         else if (ui.item.showOptions2 == 'SHOW_TREATMENT_ORP_DOC_SELECTION') {{
           hideSvcDetailCont();
           showSelOrpDocID();
           return true;
         }}
         
         else {{
           hideSvcDetailCont();
           hideSelOrpDocID();
           doGotoNextStepAfterSvcSel();  /* After selection made advance */
           return true;
         }}
                 
         
         return true;
       }}
       ",_svcTypeID, _nextStepID, _timeBasedID, _mileBasedID, _batchMinMilDetGridID );
      
      
      writer.Write(@"function doInitSelOrpAndSvcDet() {{ doInitOrpDocID(); doInitSvcDetail(); }}");
            
      /* On load, init */
      
      writer.Write(@"$(function() {{ doInitSelOrpAndSvcDet(); }})");       
      writer.Write(@"</script>");
    
    }       
  }   
}