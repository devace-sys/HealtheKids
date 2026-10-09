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
   * PractitionerDataSource */
  /**
   * Various sources of practitioner data
   *
   * TODO: Move this when we can to the entity.  It has to stay here now because
   * of the way we are creating controls.
   ****************************************************************************/
  
  public enum PractitionerDataSource
  {
    [Description("All Active")]
    ALL_PRACTITIONERS       = 0,
    SERVICE_HISTORY         = 1,
    CASE_LOAD               = 2, 
    ONE_ON_ONE_ASSIGNMENTS  = 3,
    [Description("All Inactive")]
    INACTIVE_PRACTITIONERS  = 4,
    [Description("Transportation Only")]
    TRANSPORTATION_ONLY     = 5,
    [Description("Potential ORP Only")]
    POTENTIAL_ORP_ONLY      = 6,
    [Description("All Active and Inactive")]
    ALL_ACTIVE_AND_INACTIVE  = 7,
    [Description("Within Practice Family Only")]
    WITHIN_PRACTICE_FAMILY_ONLY  = 8
  }
  
  /**************************************************************************
   * StepSelectPractioner */
  /**
   * Controls used to select a patient and store the record id in selectid
   ****************************************************************************/

  public class StepSelectPractitioner:StepBase
  {  
    
    public StepSelectPractitioner()
    {                          
    }
        
    protected string tempinstr      = "";
    protected string addpraclnkid   = "";
    protected string addpracinstrid = "";
    
    protected string datasource_all_str           = ((int) PractitionerDataSource.ALL_PRACTITIONERS).ToString();
    protected string datasource_caseload_str      = ((int) PractitionerDataSource.CASE_LOAD).ToString();
    protected string datasource_potential_orp_str = ((int) PractitionerDataSource.POTENTIAL_ORP_ONLY).ToString();
            
    /*-------------------------------
     * Property values
     *------------------------------*/
   
    protected string                  _selectid               = "pracid";
    protected string                  _pracdatasourceid       = "pracdatasource";
    protected string                  _groupsvcclassnameid    = "groupserviceclassnameid"; 
    protected string                  _selectvalue            = "";
    protected string                  _selectname             = "";
    protected SelectType              _selecttype             = SelectType.COMBO_BOX;
    protected PractitionerDataSource  _datasource             = PractitionerDataSource.ALL_PRACTITIONERS;
    protected bool                    _showaddpractitioner    = false;
    protected bool                    _showeditpractitioner   = false;
    protected bool                    _showpractitionernotes  = true; 
    protected bool                    _showpractitionerqforms = true;
    protected bool                    _showdatasource         = false;
    protected bool                    _savedatasource         = false;
    protected int                     _selectdelay            = 0;       // Note: Only used by COMBO_BOX
    protected bool                    _selectall              = true;    // Note: Only used by COMBO_BOX
    protected bool                    _autoOpenSelectList     = false;
    
    protected bool               _multiSelect       = false;    // Allows multiple selection of entities
    protected string             _multiselectvalues = "";    
    protected string             _multiselectnames  = "";
    protected string             _multiselectcontextlabels        = "null";
    protected string             _multiSelectOnAdd                = "";
    protected string             _multiSelectOnRemove             = "";
 
    protected bool               _multiselectload                 = false;
    protected bool               _multiSelectDisplayContextLabels = false;
    
    /*-------------------------------
     * Properties
     *------------------------------*/
    
    public string                 selectid             { get { return _selectid;              } set { _selectid              = value; }}
    public string                 selectvalue          { get { return _selectvalue;           } set { _selectvalue           = value; }}
    public string                 selectname           { get { return _selectname;            } set { _selectname            = value; }}

    public SelectType             selecttype           { get { return _selecttype;            } set { _selecttype            = value; }}    
    public PractitionerDataSource datasource           { get { return _datasource;            } set { _datasource            = value; }}
    public bool                   showaddpractitioner  { get { return _showaddpractitioner;   } set { _showaddpractitioner   = value; }}
    public bool                   showeditpractitioner { get { return _showeditpractitioner;  } set { _showeditpractitioner  = value; }}
    public bool                   showpractionernotes  { get { return _showpractitionernotes; } set { _showpractitionernotes = value; }}
    public bool                   showpractionerqforms { get { return _showpractitionerqforms;} set { _showpractitionerqforms = value; }}
    public bool                   showdatasource       { get { return _showdatasource;        } set { _showdatasource        = value; }}
    public bool                   savedatasource       { get { return _savedatasource;        } set { _savedatasource        = value; }}    
    public int                    selectdelay          { get { return _selectdelay;           } set { _selectdelay           = value; }}
    public bool                   selectall            { get { return _selectall;             } set { _selectall             = value; }}
    public bool                   multiSelect          { get { return _multiSelect;           } set { _multiSelect           = value; }}
    public bool                   autoOpenSelectList   { get { return _autoOpenSelectList;    } set { _autoOpenSelectList    = value; }}
    
    public string multiSelectValues        { get { return _multiselectvalues;        } set { _multiselectvalues         = value; } } 
    public string multiSelectNames         { get { return _multiselectnames;         } set { _multiselectnames          = value; } } 
    public string multiSelectContextLabels { get { return _multiselectcontextlabels; } set { _multiselectcontextlabels  = value; } }
    public bool   multiSelectLoad          { get { return _multiselectload;          } set { _multiselectload           = value; } }                

    public string multiSelectOnAdd         { get { return _multiSelectOnAdd;         } set { _multiSelectOnAdd    = value; }}   
    public string multiSelectOnRemove      { get { return _multiSelectOnRemove;      } set { _multiSelectOnRemove = value; }}   

    public bool   multiSelectDisplayContextLabels { get {return _multiSelectDisplayContextLabels;} set {_multiSelectDisplayContextLabels = value;}}
                        
    /***************************************************************************
     * Render */
    /**
     * 
     * 
     ***************************************************************************/ 

    protected override void Render(HtmlTextWriter writer)
    {                                

      /*-------------------------------
       * Get out if user is logged out
       *------------------------------*/

      if (rd.loggedIn == false) 
        return;
                          
      /*-------------------------------
       * Get user group and role
       *------------------------------*/

      int    userGroup = rd.wu.usr.userGroupID;
      string userRole  = rd.wu.usr.roleName.ToLower();
             
      /*============================================================
       * Overrides for multiple selection
       *===========================================================*/  
      
      if (_multiSelect)
      {
        //_showdatasource        = false;
        _savedatasource        = false;
        _showaddpractitioner   = false;
        _showeditpractitioner  = false; 
        _showpractitionernotes = false;       
      }

      /*-------------------------------
       * Find step options control
       * and create one if it does not
       * exist.  
       * 
       * If it does exist get out!
       *------------------------------*/
      
      MBA.StepOptions stepopts = getStepOptions();
            
      if (stepopts == null)      
        stepopts = new MBA.StepOptions();      
      else
        throw new Critical("User defined step options are not allowed with this control");
                                                 
      /*-------------------------------
       * Create default instructions
       *------------------------------*/
      
      if (_showdatasource)
      {
        tempinstr = @"<li class=""ui-spedmon-step-instruction"">If desired, click on the source of data you wish to select practitioners from.";        
        if (_savedatasource)
        {
          tempinstr = tempinstr + @"  The system will remember your choice.";
        }
        tempinstr = tempinstr + @"</li>";
      }
      
      if (_selecttype == SelectType.SEARCH_BOX)
      {                  
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">Enter the practitioner's name (last name, first name) and press enter or click the find icon.</li>";
      }
      else if (_selecttype == SelectType.COMBO_BOX)
      {
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">Start typing the practitioner's (last name, first name), then select a practitioner from the list.</li>";
      }
      
      if (_multiSelect)
      {
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">The selected practitioner will be listed below.</li>";      
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">To add additional practitioners to the list of selected practitioners, perform additional searches.</li>";          
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">To remove practitioners from the list of selected practitioners, click the remove button to the right of their name.</li>";      
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">When your list of selections is complete, click OK to continue.</li>";              
      }     
                     
      /*-------------------------------
       * Create add prac button and
       * instruction ids.  These
       * ids will be used later.
       *------------------------------*/      
      
      addpraclnkid   = this.ID + "_addprac";
      addpracinstrid = this.ID + "_addpracinstr";
      
      /*-------------------------------
       * If specified, create add 
       * practitioner button "link" control
       *------------------------------*/      
      
      if (_showaddpractitioner)
      {

        bool okToIncludeAddPrac = false;
        
        /*-------------------------------
         * Create control
         *------------------------------*/

        MBA.Link lnkAddPrac   = new MBA.Link();
        lnkAddPrac.ID         = addpraclnkid;
        lnkAddPrac.url        = MBA.Practitioner.getSaveUrlForUserGroupUserRole(userGroup, userRole);
        if (!Util.IsNullOrEmpty(lnkAddPrac.url)) okToIncludeAddPrac = true; 
          
       /*-------------------------------
        * If we have a url we can send 
        * the user to for prac save go 
        * ahead and add the control
        *------------------------------*/      

        if (okToIncludeAddPrac == true)
        {
          /*-------------------------------
           * Create rest of control
           *------------------------------*/

          lnkAddPrac.pvt        = true;
          lnkAddPrac.linkMode   = 1;
          lnkAddPrac.appMode    = "uidbssub";
          lnkAddPrac.icon       = "ui-icon-person";
          lnkAddPrac.title      = "Add Practitioner";        
          lnkAddPrac.beforeOpen = "function(){$('#" + this.ID + "').spedmonStep_clear();}";
          lnkAddPrac.Controls.Add(new MBA.RawText("Add Practitioner"));
       
          /*-------------------------------
           * Add control to step options
           *------------------------------*/

          stepopts.Controls.Add(lnkAddPrac);
       
          /*-------------------------------
           * Create and add default
           * instruction
           *------------------------------*/
       
          tempinstr = tempinstr + @"<li id=""" + addpracinstrid + @""" class=""ui-spedmon-step-instruction"">If the practitioner is NOT on the list click ‘Add Practitioner’ and THEN AFTER SAVING THE PRACTITIONER, try your practitioner search again.</li>";
        }
      }
                        
      /*-------------------------------
       * If there are step options add 
       * the step options control and 
       * its children to the step 
       * control 
       *------------------------------*/

      if (stepopts.Controls.Count > 0)
        this.Controls.Add(stepopts);
      
      /*-------------------------------
       * Find step selection options 
       * control and create one if it 
       * does not exist.  
       * 
       * If it does exist get out!
       *------------------------------*/
      
      MBA.StepSelectionOptions stepselopts = getStepSelectionOptions();
      
      if (stepselopts == null)      
        stepselopts = new MBA.StepSelectionOptions();      
      else
        throw new Critical("User defined step selection options are not allowed with this control");
            
      /*-------------------------------
       * If specified, create a qforms 
       * button control
       *------------------------------*/
      
      if (_showpractitionerqforms)
      {
        /*-------------------------------
         * Create control
         *------------------------------*/
        
        MBA.Button butPracQForms = new MBA.Button();
      
        butPracQForms.ID      = this.ID + "_dspQFormsPrac";
        butPracQForms.icon    = "ui-icon-note";
        butPracQForms.onclick = "$.spedmonWebUI.showQFormsPractitioner("
                              + @"'"  + this.ID    + @"'"
                              + @",'" + _selectid  + @"'"
                              + @")";

        butPracQForms.Controls.Add(new MBA.RawText("View QForms"));
            
        /*-------------------------------
         * Add control to step select
         * options
         *------------------------------*/

        stepselopts.Controls.Add(butPracQForms); 

      }
      
      /*-------------------------------
       * If specified, create a patient 
       * notes button control
       *------------------------------*/
      
      if (_showpractitionernotes)
      {
        /*-------------------------------
         * Create control
         *------------------------------*/
        
        MBA.Button butPracNotes = new MBA.Button();
      
        butPracNotes.ID      = this.ID + "_dspNotesPrac";
        butPracNotes.icon    = "ui-icon-note";
        butPracNotes.onclick = "$.spedmonWebUI.showNotesPractitioner("
                             + @"'"  + this.ID    + @"'"
                             + @",'" + _selectid  + @"'"
                             + @")";
        butPracNotes.Controls.Add(new MBA.RawText("View Notes"));
            
        /*-------------------------------
         * Add control to step select
         * options
         *------------------------------*/

        stepselopts.Controls.Add(butPracNotes); 

      }
            
      /*-------------------------------
       * If specified, create an edit
       * prac
       *------------------------------*/
      
      if (_showeditpractitioner)
      {
       
        /*-------------------------------
         * Create control
         *------------------------------*/
        
        MBA.Button butPracEdit = new MBA.Button();

        butPracEdit.ID      = this.ID + "_editSelectedPrac";
        butPracEdit.icon    = "ui-icon-person";
        
        butPracEdit.onclick = @"$.spedmonWebUI.editSelectedPractitioner("
                            + @"'"  + this.ID                                             + @"'"
                            + @",'" + _selectid                                           + @"'"
                            + @",'" + MBA.Practitioner.getSaveUrlForUserGroupUserRole(userGroup, userRole) + @"'"
                            + @")";
        
        butPracEdit.Controls.Add(new MBA.RawText("Edit this Practitioner"));
      
        /*-------------------------------
         * Add control to step select
         * options
         *------------------------------*/

        stepselopts.Controls.Add(butPracEdit); 
      
      }
      
      /*-------------------------------
       * If there are step select 
       * options add the step select 
       * options control and its 
       * children to the step control
       *------------------------------*/
      
      if (stepselopts.Controls.Count > 0)      
        this.Controls.Add(stepselopts);           

      /*-------------------------------
       * If title is not provided
       * use default
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(this._title))
      {
         if (_multiSelect == false)
        {
          this._title = "Who is the Practitioner?";
        }
        else
        {
          this._title = "Who are the Practitioners?";
        }        
      }
      
      /*-------------------------------
       * If instructions are not provided
       * use default
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(this._instr))
      {
        this._instructionFormat = StepInstructionFormat.UL_LIST;
        this._instr = tempinstr;
      }
      
      /*-------------------------------
       * Commence rendering base
       * Note: the base will call
       * render()
       *------------------------------*/
                            
      base.Render(writer);
    }
    
    /***************************************************************************
     * render */
    /**
     * 
     * 
     ***************************************************************************/ 

    protected override void render(ref HtmlTextWriter writer)
    {
              
      /*-------------------------------
       * This is called in the middle
       * of the bases render
       *------------------------------*/  
                                                    
      _pracdatasourceid = _selectid + "_pracdatasource";
      
      /*-------------------------------
       * Parameters
       *------------------------------*/            

      string parms = "[{id:'clientid'},{id:'patid'},{id:'dos'},{id:'" + _pracdatasourceid + @"'},{id:'" + _groupsvcclassnameid + @"'}]"; 
      string url   = "practitioners.asmx/viewSel2";
      
      /*-------------------------------
       * Render select
       *------------------------------*/            
      
      if (_selecttype == SelectType.SEARCH_BOX)
      {
        MBA.SearchBox selPractitioner = new MBA.SearchBox();
                   
        selPractitioner.ID          = _selectid;
        selPractitioner.name        = _selectid;
        selPractitioner.value       = _selectvalue;
        selPractitioner.selectName  = _selectname;
        selPractitioner.title       = "Select Practitioner";
        selPractitioner.dataPrivate = true;
        selPractitioner.dataURL     = url;
        selPractitioner.dataParms   = parms;
        
        selPractitioner.multiSelect          = _multiSelect;
        selPractitioner.multiSelectListTitle = "Selected Practioners";
        selPractitioner.multiSelectNames     = _multiselectnames;
        selPractitioner.multiSelectValues    = _multiselectvalues;
        selPractitioner.multiSelectLoad      = _multiselectload;
        selPractitioner.multiSelectContextLabels = _multiselectcontextlabels;
        selPractitioner.multiSelectDisplayContextLabels = _multiSelectDisplayContextLabels;
        selPractitioner.multiSelectOnAdd         = _multiSelectOnAdd;
        selPractitioner.multiSelectOnRemove      = _multiSelectOnRemove;
        
        selPractitioner.RenderControl(writer);           
      }
      else if (_selecttype == SelectType.COMBO_BOX)
      {
        MBA.ComboBox selPractitioner = new MBA.ComboBox();
                   
        selPractitioner.ID          = _selectid;
        selPractitioner.name        = _selectid;
        selPractitioner.value       = _selectvalue;
        selPractitioner.selectName  = _selectname;
        selPractitioner.title       = "Select Practitioner";
        selPractitioner.dataPrivate = true;
        selPractitioner.dataURL     = url;
        selPractitioner.dataParms   = parms;
        selPractitioner.delay       = _selectdelay;
        selPractitioner.selectAll   = _selectall;
        
        selPractitioner.multiSelect          = _multiSelect;
        selPractitioner.multiSelectListTitle = "Selected Practioners";
        selPractitioner.multiSelectNames     = _multiselectnames;
        selPractitioner.multiSelectValues    = _multiselectvalues;
        selPractitioner.multiSelectLoad      = _multiselectload;
        selPractitioner.multiSelectContextLabels = _multiselectcontextlabels;
        selPractitioner.multiSelectDisplayContextLabels = _multiSelectDisplayContextLabels;
        selPractitioner.multiSelectOnAdd         = _multiSelectOnAdd;
        selPractitioner.multiSelectOnRemove      = _multiSelectOnRemove;
       
       
        if ((_selectall == true) && (_autoOpenSelectList == true))
        {
          string openListJs = @"$('#" + this._selectid + "_button').click();";          
          this._onactive = this._onactive + openListJs;
        }

        selPractitioner.RenderControl(writer);
      
      }
      else
      {
         throw new Critical("Unknown select type");      
      }
      
      /*-------------------------------
       * Render datasource selection
       * if specified
       *------------------------------*/            
            
      string whatdatasource = ((int)_datasource).ToString();  

      if (_showdatasource)
      {                                     

        /*-------------------------------
         * If save datasource is
         * specified retrieve preference 
         * for data source if it exits 
         * otherwise use default
         *------------------------------*/            
        
         string selector     = HttpApplication.currentEndPointName();
         string selectortype = UserPreferences.SELECTOR_TYPE_END_POINT;
         string noun         = "Practitioners";
         string verb         = "viewSel";
         string name         = "source";                 
         string v;
         
         
         if (_savedatasource)
           if (UserPreferences.getPreferenceValue(selector, selectortype, noun, verb, name, ref rd.wu.preferences, out v))         
             whatdatasource = v;
         
         /*-------------------------------
          * Render datasource control
          *------------------------------*/         
        
         MBA.RadioBox datasource     = new MBA.RadioBox(@"pracdatasource", whatdatasource);
         datasource.ID               = _pracdatasourceid;
         datasource.title            = "Select From";
         datasource.firedataselected = false;
         datasource.noClear          = true;
         
         //datasource.AddSelection("Service History", "1");
         //datasource.AddSelection("Caseload",                 ((int)PractitionerDataSource.CASE_LOAD).ToString());
         //datasource.AddSelection("1:1 Assignments",          ((int)PractitionerDataSource.ONE_ON_ONE_ASSIGNMENTS).ToString());
         datasource.AddSelection("Active Practitioners",     ((int)PractitionerDataSource.ALL_PRACTITIONERS).ToString());
         datasource.AddSelection("Inactive Practitioners",   ((int)PractitionerDataSource.INACTIVE_PRACTITIONERS).ToString());
         
         /*-------------------------------
          * Render start of selection
          * handler
          *------------------------------*/
            
         datasource.onSelectValue = "function(oldval,newval){if (oldval != newval){"
         + "if (newval != " + datasource_all_str + "){$('#" + addpraclnkid + "').hide();$('#" + addpracinstrid + "').hide();} else {$('#" + addpraclnkid + "').show();$('#" + addpracinstrid + "').show();}";
         
        /*-------------------------------
         * Include code in the handler
         * to save the data source if
         * this is specified
         *------------------------------*/  

        if (_savedatasource)
          datasource.onSelectValue = datasource.onSelectValue + "$.spedmonWebUI.setUserPreference('" + selector + @"','" + selectortype + @"','Practitioners','viewSel','source',newval);";
        
        /*-------------------------------
         * Finish handler
         *------------------------------*/

        datasource.onSelectValue = datasource.onSelectValue + "}return true;}";
                
        writer.Write(@"<div style=""padding-top:5px"">");        
        datasource.RenderControl(writer);
        writer.Write(@"</div>");
        
      }
      else
      {       
        MBA.HiddenInput datasource   = new MBA.HiddenInput(@"pracdatasource", whatdatasource);
        datasource.ID                = _pracdatasourceid;
        datasource.title             = "Select From";
        datasource.noClear           = true;
        datasource.RenderControl(writer);
      }   

      /*-------------------------------
       * Hide practitioner add button if
       * datasource is not all or
       * potential orp.  This overrides
       * whatever setting is specificed
       * on the control
       *------------------------------*/  
       
      if (!((whatdatasource == datasource_all_str) || (whatdatasource == datasource_potential_orp_str)))
      {
        this._onpageloadend = "$('#" + addpraclnkid + "').hide();$('#" + addpracinstrid + "').hide();";
      }              
      
      /*-------------------------------
       * Add notice for orp only 
       * selection if the datasource
       * is potential orp
       *------------------------------*/  

      if (whatdatasource == datasource_potential_orp_str)
      {    
        writer.Write(@"<div class=""additional-info-below-select-entity"">");
        writer.Write(Messages.MSG_PRAC_SELECTION_IS_QUALIFIED_ORP_ONLY);
        writer.Write(@"</div>");
      }          
    }    
  }   
}