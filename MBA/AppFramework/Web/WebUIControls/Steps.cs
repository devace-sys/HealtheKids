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
   * Steps */
  /**
   * 
   * 
   ****************************************************************************/

  public class Steps : ControlBase
  {
    protected  string    _form_id;
    protected  string    _steps_id;
    protected  string    _title;
    protected  string    _dataURL;
    protected  string    _dataReturn;
    protected  string    _dataParms;
    protected  int       _firstStep       = 0;
    protected  bool      _dataPrivate     = true;
    protected  bool      _animated        = true;
    protected  bool      _autoScroll      = false;
    protected  bool      _dependent       = true;
    protected  bool      _autoheight      = true;
    protected  bool      _openOnMouseOver = false;
    protected  string    _onload          = "";

    public  bool    dataPrivate  { get { return _dataPrivate; } set { _dataPrivate = value; } }
    public  string  dataURL      { get { return _dataURL; }     set { _dataURL     = MBA.HttpApplication.createLink(value, _dataPrivate); } }
    public  bool    dependent    { get { return _dependent; }   set { _dependent   = value; } }
    public  bool    autoheight   { get { return _autoheight; }  set { _autoheight  = value; } }
    public  bool    animated     { get { return _animated; }    set { _animated    = value; } }
    public  int     firstStep    { get { return _firstStep; }   set { _firstStep   = value; } }
    public  bool    autoScroll   { get { return _autoScroll; }  set { _autoScroll  = value; } }
    
    public  bool    openOnMouseOver { get { return _openOnMouseOver; } set { _openOnMouseOver = value; } }
    public  string  onload          { get { return _onload;          } set { _onload          = value; } }
   
    public static bool isStepControl (Type ct)
    {
        if      (ct == typeof(MBA.StepBase))             return true;
        else if (ct == typeof(MBA.StepRecordViewSelect)) return true;        
        return false;
    }
    
    public static bool isStepControl (Control ctrl)
    {
      return isStepControl(ctrl.GetType());
    }
    
    protected override void Render(HtmlTextWriter writer)
    {
      /*-------------------------------
       * Create unique ids
       *------------------------------*/

      _steps_id = this.ID + "_steps";
      _form_id  = this.ID;

      /*-------------------------------
       * Render our opening tags
       *------------------------------*/

      writer.Write(@"<form class=""steps steps-outer-cont"" id=""" + _form_id + @""" method=""post"" action=""" + dataURL + @""">");
      writer.Write(@"<div class=""steps steps-inner-cont"" id=""" + _steps_id + @""">");

      /*-------------------------------
       * Iterrate through child
       * controls before we render 
       *------------------------------*/

      int numSteps = 0;
      List<StepBase> stepControls = new List<StepBase>();
      foreach (Control c in base.Controls)
      {
        Type ct = c.GetType().BaseType;
        if (isStepControl (ct))
        {
          /*-------------------------------
           * If we find a Step control
           * count it, and pass values to it
           *------------------------------*/
          
          numSteps++;
          
          StepBase cs = (StepBase)c;
          
          cs.number      = numSteps;
          cs.stepsid     = _steps_id;
          cs.formid      = _form_id;
          cs.dataPrivate = _dataPrivate;
          
          stepControls.Add(cs);
          
        }
      }

      if (numSteps == 0)
      {
        throw new Exception("Step controls required");
      }

      foreach (Control c in base.Controls)
      {
        Type ct = c.GetType().BaseType;
        
        if (isStepControl (ct))
        {        
          /*-------------------------------
           * Pass # steps
           *------------------------------*/          
          StepBase cs = (StepBase)c;
          cs.numberOfSteps = numSteps;                  
        }
      }

      /*-------------------------------
       * Render child controls
       *------------------------------*/

      base.Render(writer);

      /*-------------------------------
       * Render closing tags and
       * client side script to complete
       * control creation
       *------------------------------*/

      writer.Write("</div>");
      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");

      /*-------------------------------
       * Supress submit on enter to
       * overcome the default form
       * behavoir and allowing an
       * exception for enters inside
       * textareas.
       *------------------------------*/

      writer.Write(@"$('#" + _form_id + @"').bind('keypress',function(e){var nd = e.target.nodeName.toLowerCase();if (nd='textarea') return true;var kp = $.spedmonWebUI.whatKeycode(e);if (kp == 13) return false;});");
      
      /*-------------------------------
       * Instruct client to render 
       * steps.  Note: We use the
       * jQuery UI Accordion control
       *------------------------------*/

      writer.Write(@"$('#" + _steps_id + @"').accordion({active:false, fillSpace:true, clearStyle:true, collapsible: false, autoHeight:" + Util.netBoolToJSBool(_autoheight) + ",animated:'slide'});");

      /*-------------------------------
       * Turn off animation if desired
       *------------------------------*/

      if (!_animated)
        writer.Write(@"$('#" + _steps_id + @"').accordion('option','animated',false);");

      /*-------------------------------
       * Setup step "onactive" and 
       * "ondeactive" execution
       * Also setup data selection
       * options
       *------------------------------*/

      writer.Write(@"$('#" + _steps_id + @"').bind('accordionchange', function(event, ui){");
      writer.Write(@"var prevStepID = ui.oldHeader.attr('id');");
      writer.Write(@"var stepID = ui.newHeader.attr('id');");
      
      // Previous step

      writer.Write(@"switch(prevStepID){");

      foreach (StepBase c in stepControls)
      {
        writer.Write(@"case '" + c.ID + @"':{");

        if (c.hasSelOpts)
        {
          writer.Write(@"$('#" + c.idselopts + @"').show();");
        }

        writer.Write(c.ondeactive);
        writer.Write(@";");
        writer.Write(@"break;}");
      }

      writer.Write(@"default:{break;}");
      writer.Write(@"}");

      // New step

      writer.Write(@"switch (stepID) {");
      foreach (StepBase c in stepControls)
      {
        writer.Write(@"case '" + c.ID + @"':{");

        // If this step has selection options and a data value has not been selected go ahead and hide
        // the options when the step has focus

        if (c.hasSelOpts)
        {
          writer.Write(@"$('#" + c.idselopts + @"').hide();");
        }

        writer.Write(c.onactive);
        writer.Write(@";");
        writer.Write(@"break;}");
      }
      
      writer.Write(@"default:{break;}");
      writer.Write(@"}");

      /*-------------------------------
       * When step is active focus on
       * first visible input control
       * Note: A delay timer is required
       * if the steps are not animated
       * to ensure that the control 
       * can be focused on
       *------------------------------*/

      writer.Write(@"var contentID = '#' + ui.newContent.attr('id');");
      writer.Write(@"var $focusCtrl = $(contentID).find('input:visible').first();");
      if (!_animated) writer.Write(@"$(contentID).oneTime(100,function(){");
      writer.Write(@"if ($focusCtrl) $focusCtrl.focus();");
      if (!_animated) writer.Write(@"});");

      // Auto scroll

      if (_autoScroll) writer.Write(@"$.scrollTo(ui.newHeader,500);");

      writer.Write(@"});");

      /*-------------------------------
       * Activate desired first step
       *------------------------------*/

      writer.Write(@"$('#" + _steps_id + @"').accordion('option','active'," + _firstStep.ToString() + @");");
      
      /*-------------------------------
       * Render onload call
       *------------------------------*/

      writer.Write(_onload);

      writer.Write(@"});");

      /*-------------------------------
       * Generate steps_clear_all
       * this clears all input when
       * run
       *------------------------------*/

      writer.Write(@"function " + _steps_id + "_clear(stepnum){");
      writer.Write(@"switch(stepnum){");
      writer.Write(@"default:");
      foreach (StepBase c in stepControls)
      {
        writer.Write(@"case " + c.number + ":");
        writer.Write(@"$('#" + c.ID + @"').spedmonStep_clear();");
      }
      writer.Write(@"}");
      writer.Write(@"}");
      writer.Write(@"</script>");
      writer.Write(@"</form>");
    }
  }
  

}

