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
   * PatientDataSource */
  /**
   * Various sources of patient data
   *
   * TODO: Move this when we can to the entity.  It has to stay here now because
   * of the way we are creating controls.
   ****************************************************************************/
  
  public enum PatientDataSource
  {
    [Description("All Active")]
    ALL_PATIENTS              = 0,
    SERVICE_HISTORY           = 1,
    [Description("In Caseload")]
    CASE_LOAD = 2, 
    ONE_ON_ONE_ASSIGNMENTS    = 3,
    [Description("All Inactive")]
    INACTIVE_PATIENTS = 4,
    SPECIAL_ED_ONLY           = 5,
    RECEIVED_TRANS_SVCS_ONLY  = 6,
    SERVICE_JOURNALS_ONLY     = 7,
    SERVICE_DESCRIPTIONS_ONLY = 8
  }
  
  /**************************************************************************
   * StepSelectPatient */
  /**
   * Controls used to select a patient and store the record id in selectid
   ****************************************************************************/

  public class StepSelectPatient:StepBase
  {  
    
    public StepSelectPatient()
    {                          
    }
        
    protected string tempinstr       = "";
    protected string addpatlnkid     = "";
    protected string addpatinstrid   = "";

    
    protected string datasource_all_str      = ((int) PatientDataSource.ALL_PATIENTS).ToString();
    protected string datasource_caseload_str = ((int) PatientDataSource.CASE_LOAD).ToString();
    protected string datasource_ac_inac_str = ((int)PatientDataSource.INACTIVE_PATIENTS).ToString();
            
    /*-------------------------------
     * Property values
     *------------------------------*/
   
    protected string             _selectid          = "patid";
    protected string             _selectvalue       = "";
    protected string             _selectname        = "";
    protected SelectType         _selecttype        = SelectType.SEARCH_BOX;
    protected PatientDataSource  _datasource        = PatientDataSource.ALL_PATIENTS;
    protected bool               _showaddpatient    = true;
    protected bool               _showpatientnotes  = true; 
    protected bool               _showdatasource    = false;
    protected bool               _savedatasource    = false;
    protected int                _selectdelay;                  // Note: Only used by COMBO_BOX
    protected bool               _selectall         = false;    // Note: Only used by COMBO_BOX    

    protected bool               _multiSelect       = false;    // Allows multiple selection of entities
    protected string             _multiselectvalues = "";
    protected string             _multiselectnames  = "";
    protected bool               _multiselectload   = false;
    
    /*-------------------------------
     * Properties
     *------------------------------*/
    
    public string            selectid          { get { return _selectid;         } set { _selectid         = value; }}
    
    
    public string            selectvalue       { get { return _selectvalue;      } set { _selectvalue      = value; }}
    public string            selectname        { get { return _selectname;       } set { _selectname       = value; }}
    
    public SelectType        selecttype        { get { return _selecttype;       } set { _selecttype       = value; }}    
    public PatientDataSource datasource        { get { return _datasource;       } set { _datasource       = value; }}
    public bool              showaddpatient    { get { return _showaddpatient;   } set { _showaddpatient   = value; }}
    public bool              showpatientnotes  { get { return _showpatientnotes; } set { _showpatientnotes = value; }}
    public bool              showdatasource    { get { return _showdatasource;   } set { _showdatasource   = value; }}
    public bool              savedatasource    { get { return _savedatasource;   } set { _savedatasource   = value; }}    
    public int               selectdelay       { get { return _selectdelay;      } set { _selectdelay      = value; }}
    public bool              selectall         { get { return _selectall;        } set { _selectall        = value; }}
    public bool              multiSelect       { get { return _multiSelect;      } set { _multiSelect      = value; }}
    
    public string multiSelectValues       { get { return _multiselectvalues;    } set { _multiselectvalues        = value; } } 
    public string multiSelectNames        { get { return _multiselectnames;     } set { _multiselectnames         = value; } } 
    public bool   multiSelectLoad         { get { return _multiselectload;      } set {_multiselectload           = value; } }                
    
    protected override void Render(HtmlTextWriter writer)
    {                                
      
      /*============================================================
       * Create unique ids
       *===========================================================*/  

      addpatlnkid   = this.ID + "_addpat";
      addpatinstrid = this.ID + "_addpatinstr";

      /*============================================================
       * Get user data
       *===========================================================*/  

      /*-------------------------------
       * Get out if user is logged out
       * otherwise get the user group
       *------------------------------*/

      if (rd.loggedIn == false) return;                          
      int userGroup = rd.wu.usr.userGroupID;
            
      /*============================================================
       * Overrides for multiple selection
       *===========================================================*/  
      
      if (_multiSelect)
      {
        _showdatasource   = false;
        _savedatasource   = false;
        _showaddpatient   = false; 
        _showpatientnotes = false;       
      }
      
      /*============================================================
       * Setup step options control.
       * 
       * If a control exists already get out, otherwise create one
       *===========================================================*/  
      
      MBA.StepOptions stepopts = getStepOptions();
      if (stepopts == null) 
      {
        stepopts = new MBA.StepOptions();
      }
      else throw new Critical("User defined step options are not allowed with this control");
                                                 
      /*============================================================
       * Create default instructions
       *===========================================================*/  

      if (_showdatasource)
      {
        tempinstr = @"<li class=""ui-spedmon-step-instruction"">If desired, click on the source of patient data you wish to select patients from.";        
        if (_savedatasource)
        {
          tempinstr = tempinstr + @"  The system will remember your choice.";
        }
        tempinstr = tempinstr + @"</li>";
      }
      
      if (_selecttype == SelectType.SEARCH_BOX)
      {                  
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">Enter the patient's name (last name, first name, date of birth) and press enter or click the find icon.</li><li class=""ui-spedmon-step-instruction"">Select a patient from the list.</li>";
      }
      else if (_selecttype == SelectType.COMBO_BOX)
      {
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">Start typing the patient's name (last name, first name), then select a patient from the list.</li>";
      }
      
      if (_multiSelect)
      {
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">The selected patient will be listed below.</li>";      
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">To add additional patients to the list of selected patients, perform additional searches.</li>";          
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">To remove patients from the list of selected patients, click the remove button to the right of their name.</li>";      
        tempinstr = tempinstr + @"<li class=""ui-spedmon-step-instruction"">When your list of selections is complete, click OK to continue.</li>";              
      }     
     
      /*============================================================
       * Create add patient button
       *===========================================================*/  
      
      if (_showaddpatient)
      {

        /*-------------------------------
         * Create control
         *------------------------------*/

        MBA.Link lnkAddpat   = new MBA.Link();
        lnkAddpat.ID         = addpatlnkid;
        
        /*-------------------------------
         * Provide group based action url
         *
         * TODO: Factor these hardcoded
         * url constants out
         *------------------------------*/
 
        if      (userGroup == Constants.USER_GROUP_SBSC)   lnkAddpat.url = "user_all_pat_save_2.aspx";
        else if (userGroup == Constants.USER_GROUP_CLIENT) lnkAddpat.url = "user_all_pat_save_2.aspx";
        else                                               lnkAddpat.url = "";
        
        /*-------------------------------
         * Create rest of control
         *------------------------------*/

        lnkAddpat.pvt        = true;
        lnkAddpat.linkMode   = 1;
        lnkAddpat.appMode    = "uidbssub";
        lnkAddpat.icon       = "ui-icon-person";
        lnkAddpat.title      = "Add Patient";        
        lnkAddpat.beforeOpen = "function(){$('#" + this.ID + "').spedmonStep_clear();}";
        lnkAddpat.Controls.Add(new MBA.RawText("Add Patient"));
        
        /*-------------------------------
         * Add control to step options
         *------------------------------*/

        stepopts.Controls.Add(lnkAddpat);
        
        /*-------------------------------
         * Create and add default 
         * instruction
         *------------------------------*/
        
        tempinstr = tempinstr + @"<li id=""" + addpatinstrid + @""" class=""ui-spedmon-step-instruction"">If the patient is NOT on the list click ‘Add Patient’ and THEN AFTER SAVING THE PATIENT, try your patient search again.</li>";
        
      }
                  
      /*============================================================
       * Before selection step options
       *===========================================================*/  
      
      if (stepopts.Controls.Count > 0)
        this.Controls.Add(stepopts);
      
      /*============================================================
       * After selection step options
       *===========================================================*/  
      
      MBA.StepSelectionOptions stepselopts = getStepSelectionOptions();
      
      if (stepselopts == null)      
        stepselopts = new MBA.StepSelectionOptions();      
      else
        throw new Critical("User defined step selection options are not allowed with this control");
            
      /*============================================================
       * Patient notes
       *===========================================================*/  
      
      if (_showpatientnotes) 
      {
        /*-------------------------------
         * Create control
         *------------------------------*/
        
        MBA.Button butPatNotes = new MBA.Button();
      
        butPatNotes.ID      = this.ID + "_dspNotesPat";
        butPatNotes.icon    = "ui-icon-note";
        butPatNotes.onclick = "$.spedmonWebUI.showNotesPatient('" + this.ID + "')";
        butPatNotes.Controls.Add(new MBA.RawText("View Notes"));
            
        /*-------------------------------
         * Add control to step select
         * options
         *------------------------------*/

        stepselopts.Controls.Add(butPatNotes); 

      }
      
      /*-------------------------------
       * If there are step select 
       * options add the step select 
       * options control and its 
       * children to the step control
       *------------------------------*/
      
      if (stepselopts.Controls.Count > 0)      
        this.Controls.Add(stepselopts);           

      /*============================================================
       * Title
       *===========================================================*/  
       
      if (Util.IsNullOrEmpty(this._title))
      {
        if (_multiSelect == false)
        {
          this._title = "Who is the Patient?";
        }
        else
        {
          this._title = "Who are the Patients?";
        }
      }
            
      /*============================================================
       * Instructions 
       *===========================================================*/  
      
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
    
    protected override void render(ref HtmlTextWriter writer)
    {
    

        int userGroup = rd.wu.usr.userGroupID;
      /*-------------------------------
       * This is called in the middle
       * of the bases render
       *------------------------------*/  
                                                    
      /*-------------------------------
       * Parameters
       *------------------------------*/            

      string parms = "[{id:'clientid'},{id:'pracid'},{id:'dos'},{id:'patdatasource'}]";  
      string url   = "patients.asmx/viewSel";
      
      /*-------------------------------
       * Render select
       *------------------------------*/            
      
      if (_selecttype == SelectType.SEARCH_BOX)
      {
        MBA.SearchBox selPatient = new MBA.SearchBox();
                   
        selPatient.ID          = _selectid ;
        selPatient.name        = _selectid;
        selPatient.value       = _selectvalue;
        selPatient.selectName  = _selectname;
        selPatient.title       = "Select Patient (Last Name, First Name)";
        selPatient.dataPrivate = true;
        selPatient.dataURL     = url;
        selPatient.dataParms   = parms;
        selPatient.multiSelect          = _multiSelect;
        selPatient.multiSelectListTitle = "Selected Patients";
        selPatient.multiSelectNames    = _multiselectnames;
        selPatient.multiSelectValues   = _multiselectvalues;
        selPatient.multiSelectLoad     = _multiselectload;
        selPatient.RenderControl(writer);           
      }
      else if (_selecttype == SelectType.COMBO_BOX)
      {
        MBA.ComboBox selPatient = new MBA.ComboBox();
                   
        selPatient.ID          = _selectid;
        selPatient.name        = _selectid;
        selPatient.value       = _selectvalue;
        selPatient.selectName  = _selectname;
        selPatient.title       = "Select Patient (Last Name, First Name)";
        selPatient.dataPrivate = true;
        selPatient.dataURL     = url;
        selPatient.dataParms   = parms;
        selPatient.delay       = _selectdelay;
        selPatient.selectAll   = _selectall;
        selPatient.multiSelect          = _multiSelect;
        selPatient.multiSelectListTitle = "Selected Patients";
        selPatient.multiSelectNames    = _multiselectnames;
        selPatient.multiSelectValues   = _multiselectvalues;
        selPatient.multiSelectLoad     = _multiselectload;
        selPatient.RenderControl(writer);

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
         string noun         = "Patients";
         string verb         = "viewSel";
         string name         = "source";                 
         string v;
         
         
         if (_savedatasource)
           if (UserPreferences.getPreferenceValue(selector, selectortype, noun, verb, name, ref rd.wu.preferences, out v))         
             whatdatasource = v;
         
         /*-------------------------------
          * Render datasource control
          *------------------------------*/
         
         MBA.RadioBox datasource     = new MBA.RadioBox("patdatasource", whatdatasource);
         datasource.ID               = "patdatasource";
         datasource.title            = "Select From";
         datasource.firedataselected = false;
         datasource.noClear          = true;
         
         string selectionHeaderStart = "";

         if (userGroup == Constants.USER_GROUP_CLIENT)
         {
             datasource.AddSelection("All Patients", ((int)PatientDataSource.ALL_PATIENTS).ToString());
             datasource.AddSelection("Caseload", ((int)PatientDataSource.CASE_LOAD).ToString());

             selectionHeaderStart = "function(oldval,newval){if (oldval != newval){"
         + "if (newval != " + datasource_all_str + "){$('#" + addpatlnkid + "').hide();$('#" + addpatinstrid + "').hide();} else {$('#" + addpatlnkid + "').show();$('#" + addpatinstrid + "').show();}";
         }
         //datasource.AddSelection("Service History", "1");

         if (userGroup == Constants.USER_GROUP_SBSC)
         {
             datasource.AddSelection("Caseload", ((int)PatientDataSource.CASE_LOAD).ToString());
             datasource.AddSelection("Active Patients", ((int)PatientDataSource.ALL_PATIENTS).ToString());
             datasource.AddSelection("Inactive Patients", ((int)PatientDataSource.INACTIVE_PATIENTS).ToString());
             
             selectionHeaderStart = "function(oldval,newval){if (oldval != newval){"
         + "if (newval != " + datasource_ac_inac_str + "){$('#" + addpatlnkid + "').hide();$('#" + addpatinstrid + "').hide();} else {$('#" + addpatlnkid + "').show();$('#" + addpatinstrid + "').show();}";
         }
         /*-------------------------------
          * Render start of selection
          * handler
          *------------------------------*/

         datasource.onSelectValue = selectionHeaderStart;
         
        /*-------------------------------
         * Include code in the handler
         * to save the data source if
         * this is specified
         *------------------------------*/  

        if (_savedatasource)
          datasource.onSelectValue = datasource.onSelectValue + "$.spedmonWebUI.setUserPreference('" + selector + @"','" + selectortype + @"','Patients','viewSel','source',newval);";
        
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
        MBA.HiddenInput datasource   = new MBA.HiddenInput("patdatasource", whatdatasource);
        datasource.ID                = "patdatasource";
        datasource.title             = "Select From";
        datasource.noClear           = true;
        datasource.RenderControl(writer);
      }   

      /*-------------------------------
       * Clients: Hide patient add button if
       * datasource is not all
       *------------------------------*/  
       
       if (userGroup == Constants.USER_GROUP_CLIENT)
       {

           if (whatdatasource != datasource_all_str)
           {
               this._onpageloadend = "$('#" + addpatlnkid + "').hide();$('#" + addpatinstrid + "').hide();";
           }
       }

      /*-------------------------------
       * SBSC: Hide patient add button if
       * datasource is not all inactive
       *------------------------------*/  
       
       if (userGroup == Constants.USER_GROUP_SBSC)
       {
           if (whatdatasource != datasource_ac_inac_str)
           {
               this._onpageloadend = "$('#" + addpatlnkid + "').hide();$('#" + addpatinstrid + "').hide();";
           }
       }
  
      
                 
    }    
  }   
}
