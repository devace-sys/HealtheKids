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

namespace MBA
{
  /**************************************************************************
   * StepInstructionFormat */
  /**
   * Various styles of step instructions
   *
   ****************************************************************************/
  
  public enum StepInstructionFormat
  {
    FREE_FORM     = 0,
    UL_LIST       = 1,
    OL_LIST       = 2,
    PARAGRAPH     = 3
  }
  
  /**************************************************************************
   * StepBase */
  /**
   * Base class for our step controls
   **************************************************************************/

  public abstract class StepBase : ControlBase
  {

    protected string  _title           = "";
    protected string  _steps_id        = "";
    protected string  _form_id         = "";
    protected string  _instr           = "";
    protected string  _label           = "";
    protected string  _onactive        = "";
    protected string  _ondeactive      = "";
    protected string  _onclear         = "";
    protected int     _number          = 0;
    protected int     _numberOfSteps   = 0;
    protected int     _stepType        = 0;
    protected bool    _dataPrivate     = true;
    protected bool    _optional        = false;
    protected string  _actionURL       = "";
    protected string  _ondataselected  = "";
    protected bool    _hasSelectOpts   = false;
    protected bool    _hasStepOpts     = false;
    protected bool    _autoNextStep    = true;    
    
    protected string  _onpageloadstart = "";
    protected string  _onpageloadend   = "";
    
    protected StepInstructionFormat _instructionFormat = StepInstructionFormat.FREE_FORM;
    
    protected string id_sel_opts   = "";
    protected string id_step_opts  = "";
    protected string id_label      = "";
    protected string _id_start_sec = "";
        
    public string title        { get { return _title; }      set { _title = value; } }
    public string instructions { get { return _instr; }      set { _instr = value; } }
    public string label        { get { return _label; }      set { _label = value; } }
    public string stepsid      { get { return _steps_id; }   set { _steps_id = value; } }
    public string formid       { get { return _form_id; }    set { _form_id = value; } }
    public int    number       { get { return _number; }     set { _number = value; } }
    public string onactive     { get { return _onactive; }   set { _onactive = value; } }
    public string ondeactive   { get { return _ondeactive; } set { _ondeactive = value; } }
    public string onclear      { get { return _onclear; }    set { _onclear = value; } }
    public bool   optional     { get { return _optional; }   set { _optional = value; } }

    public int    numberOfSteps  { get { return _numberOfSteps; }  set { _numberOfSteps = value; } }
    public int    stepType       { get { return _stepType; }       set { _stepType = value; } }
    public bool   dataPrivate    { get { return _dataPrivate; }    set { _dataPrivate = value; } }
    public string actionURL      { get { return _actionURL; }      set { _actionURL = MBA.HttpApplication.createLink(value, _dataPrivate); } }
    public string ondataselected { get { return _ondataselected; } set { _ondataselected = value +@";" ; } }

    public string idselopts      { get { return id_sel_opts; } }
    public string idlabel        { get { return id_label; } }
    public bool   hasSelOpts     { get { return _hasSelectOpts; } }
    public bool   hasStepOpts    { get { return _hasStepOpts; } }
    public string idstartsec     { get { return _id_start_sec; } set { _id_start_sec  = value; }}
    public bool   autoNextStep   { get { return _autoNextStep; } set { _autoNextStep  = value; }}
    
    public string onPageLoadStart  { get { return _onpageloadstart; } set {_onpageloadstart = value;}}
    public string onPageLoadEnd    { get { return _onpageloadend;   } set {_onpageloadend   = value;}}
    
    public StepInstructionFormat instructionFormat {get {return _instructionFormat;} set {_instructionFormat = value;}}
          
   /**************************************************************************
    * render */
   /**
    * Secondary render method.  Called within Render.
    **************************************************************************/
    
    protected abstract void render(ref HtmlTextWriter writer);
   
   /**************************************************************************
    * getStepOptions */
   /**
    * Returns step options
    **************************************************************************/
    
    protected StepOptions getStepOptions()
    {
      StepOptions so = null;
      
      foreach (Control c in this.Controls)
      {
        if ((c.GetType()) == typeof(StepOptions))
        {
          so = (StepOptions) c;
          break;
        }
      }
      
      return so;
    }
    
    /**************************************************************************
     * getStepSelectionOptions */
    /**
     * Returns step selection options
     **************************************************************************/

    protected StepSelectionOptions getStepSelectionOptions()
    {
      StepSelectionOptions sso = null;

      foreach (Control c in this.Controls)
      {
        if ((c.GetType()) == typeof(StepSelectionOptions))
        {
          sso = (StepSelectionOptions) c;
          break;
        }
      }
      return sso;
    }

    /**************************************************************************
     * Render */
    /**
     * Overrides render
     **************************************************************************/
    
    protected override void Render(HtmlTextWriter writer)
    {
      
      string id_header   = this.ID;
      string id_title    = this.ID + "_step_title";
      string id_stepnum  = this.ID + "_step_number";
      string id_content  = this.ID + "_step_content";
      string id_ntc_cont = this.ID + "_step_ntc_cont";
      string id_inst     = this.ID + "_step_instructions";
      string id_prev     = this.ID + "_step_prev_ctrl";
      string id_next     = this.ID + "_step_next_ctrl";
      string id_clear    = this.ID + "_step_clear_ctrl";
      string id_optional = this.ID + "_step_optional";
      string id_steps    = this.stepsid;
      
      id_label     = this.ID + "_step_label";
      id_step_opts = this.ID + "_step_opts";
      id_sel_opts  = this.ID + "_step_sel_opts";

      /*-------------------------------
       * Look for sections.
       *------------------------------*/

      List<String> sectionIDS = new List<string>();
      foreach (Control c in this.Controls)
      {
        if ((c.GetType()) == typeof(StepSection)) { sectionIDS.Add(c.ID); }
      }

      /*-------------------------------
       * If there are sections
       * look through them to see if
       * a start section is defined
       *------------------------------*/

      if (sectionIDS.Count > 0)
      {
        int curSec = 0;
       
        foreach (string secid in sectionIDS)
        {
          StepSection stepSec = (StepSection)this.FindControl(secid);
          if (stepSec.startSection == true)
          {
            this._title   = stepSec.title;
            this._instr   = stepSec.instructions;
            _id_start_sec = sectionIDS[curSec];
            break;
          }
          curSec++;
        }
      
       /*-------------------------------
        * If there are no start sections
        * defined get the id of the first one
        * This will be our default
        * We also use this to set the
        * initial step title and
        * instructions
        *------------------------------*/        
        
        if (Util.IsNullOrEmpty(_id_start_sec) == true)
        {
          StepSection stepSec = (StepSection) this.FindControl(sectionIDS[0]);
          this._title   = stepSec.title;
          this._instr   = stepSec.instructions;
          _id_start_sec = sectionIDS[0];
        }

      }

      /*-------------------------------
       * Look for step options
       *------------------------------*/

      StepOptions so = null;
      so = getStepOptions();
      
      if (so != null) 
        _hasStepOpts = true;
            
      /*-------------------------------
       * Look for post selection options
       *------------------------------*/

      StepSelectionOptions sso = null;
      sso = getStepSelectionOptions();
      
      if (sso != null)
        _hasSelectOpts = true;


      // TODO: Build JSON using JSON tools and pass options in as a class

      string options = @"{" +
                        @"id_steps:""#"     + id_steps + @"""," +
                        @"id_header:""#"    + id_header + @"""," +
                        @"id_ntc_cont:""#"  + id_ntc_cont + @"""," +
                        @"id_title:""#"     + id_title + @"""," +
                        @"id_label:""#"     + id_label + @"""," +
                        @"id_step_opts:""#" + id_step_opts + @"""," +
                        @"id_sel_opts:""#"  + id_sel_opts + @"""," +
                        @"id_stepnum:""#"   + id_stepnum + @"""," +
                        @"id_stepinst:""#"  + id_inst + @"""," +
                        @"id_optional:""#"  + id_optional + @"""," +
                        ((!Util.IsNullOrEmpty(_id_start_sec)) ? @"id_start_sec:""#" + _id_start_sec + @"""," : "") +
                        @"id_content:""#" + id_content + @"""}";

      writer.Write(@"<h3 id=""" + id_header + @""">");

      /*-------------------------------
       * Header start
       *------------------------------*/

      writer.Write(@"<a href=""#"">");

      // Step number and title

      writer.Write(@"<div  id=""" + id_ntc_cont + @""">");
      writer.Write(@"Step");
      writer.Write(@"<span id=""" + id_stepnum + @""">" + _number.ToString() + "</span>");
      writer.Write(@"<span id=""" + id_title + @""">" + _title + "</span>");

      // If this step is optional, display the optional indicator

      if (_optional) writer.Write(@"<span id=""" + id_optional + @""" class=""ui-spedmon-step-optional"">(Optional)</span>");

      writer.Write("</div>");

      // Data selected label

      writer.Write(@"<div id=""" + id_label + @""">");
      writer.Write(_label);
      writer.Write("</div>");

      // Selected data options

      if (_hasSelectOpts)
      {
        writer.Write(@"<div id =""" + id_sel_opts + @""">");

        // Move the controls

        foreach (Control c in sso.Controls)
        {
          c.RenderControl(writer);
        }
        sso.Controls.Clear();
        sso.Dispose();
        writer.Write("</div>");
      }

      /*-------------------------------
       * Header end
       *------------------------------*/

      writer.Write(@"</a>");
      writer.Write(@"</h3>");

      /*-------------------------------
       * Content section start
       *------------------------------*/

      writer.Write(@"<div id=""" + id_content + @""">");
      writer.Write(@"<div class=""ui-spedmon-step-content"">");
   
      /*-------------------------------
       * Instructions
       *------------------------------*/

      if      (_instructionFormat == StepInstructionFormat.UL_LIST)   writer.Write(@"<ul id=""" + id_inst + @""" class=""ui-spedmon-step-instructions"">" + this._instr + @"</ul>");
      else if (_instructionFormat == StepInstructionFormat.OL_LIST)   writer.Write(@"<ol id=""" + id_inst + @""" class=""ui-spedmon-step-instructions"">" + this._instr + @"</ol>");
      else if (_instructionFormat == StepInstructionFormat.PARAGRAPH) writer.Write(@"<p id=""" + id_inst + @""" class=""ui-spedmon-step-instructions"">" + this._instr + @"</p>");
      else                                                            writer.Write(@"<div id=""" + id_inst + @""" class=""ui-spedmon-step-instructions"">" + this._instr + @"</div>");
           
      /*-------------------------------
       * Step options
       *------------------------------*/

      if (_hasStepOpts)
      {
        writer.Write(@"<div id =""" + id_step_opts + @""" class =""ui-spedmon-step-opts-cont"">");

        // Move the controls
        
        foreach (Control c in so.Controls)
        {
          c.RenderControl(writer);
        }
        
        so.Controls.Clear();
        so.Dispose();
        writer.Write("</div>");
      }
      /*-------------------------------
        * Controls start
        *------------------------------*/

      render(ref writer);                         // Overriden by decendants for custom controls
      base.Render(writer);

      /*-------------------------------
       * Controls end
       *------------------------------*/

      /*-------------------------------
       * Search for all controls that
       * accept user data and add them
       * to a list (we will use this
       * later)
       *------------------------------*/

      List<String> ctrlIDS = new List<string>();
      foreach (Control c in this.Controls)
      {
        if ((c.GetType().BaseType) == typeof(WebUIControlDataField)) { ctrlIDS.Add(c.ID); }
      }

      /*-------------------------------
       * Dynamic inline script start
       *------------------------------*/

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");

      // Render pre page load instructions (if any)
      
      writer.Write(_onpageloadstart);

      // Setup select options

      if (_hasSelectOpts)
      {
        writer.Write("$('#" + id_sel_opts + @"').bind('click',function(e){return false;});");
      }

      /*-------------------------------
       * Generate step control
       * (client side)
       *------------------------------*/

      writer.Write("$('#" + this.ID + @"').spedmonStep(" + options + @");");

      /*-------------------------------
       * Setup auto advance
       * 
       * Autoadvance is triggered
       * when a data item has 
       * indicated it is complete
       * via custom event.
       *------------------------------*/
             
      // Bind to inputdata

      writer.Write("$('#" + id_content + @"').bind('spedmoninputdata', function(e){");

      // Update step label

      writer.Write("$('#" + id_label + @"').text(e.dataitem.label);");
   
      // If the advance step flag is set to false, get out

      writer.Write("if (e.dataitem.advanceStep == false) return;");

      // Show post selection options

      if (_hasSelectOpts)
      {
        writer.Write("$('#" + id_sel_opts + @"').show();");
      }
      
      // Execute post selection tasks (if any)

      writer.Write(_ondataselected);

      // Advance to next step or control (if permitted).  If this is not permitted the developer has to do this.
      
      if (_autoNextStep)
      {        
        writer.Write("$('#" + id_steps + @"').accordion('activate'," + this.number + ");");
      }
            
      writer.Write(@"});");
      
      // Render post page load instructions (if any)

      writer.Write(_onpageloadend);

      writer.Write(@"});");

      /*-------------------------------
       * Step set title/instructions
       *------------------------------*/

      writer.Write(@"function " + this.ID + "_set_title_instructions(newtitle,newinstructions){");
      writer.Write(@"$.spedmonWebUI.spedmonStepSetTitleInstructions(" + options + @",newtitle,newinstructions);");
      writer.Write(@"}");
      
      /*-------------------------------
       * Dynamic inline script end
       *------------------------------*/

      writer.Write(@"</script>");

      /*-------------------------------
       * Content end
       *------------------------------*/

      writer.Write(@"</div>");
      writer.Write(@"</div>");
    }
  }
}

