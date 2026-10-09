using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Text;
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
   * FieldSet*/
  /**
   * Group of controls that submit seperate form values but need to be
   * treated as a set for display purposes.  For example a persons name.
   **************************************************************************/

  public class FieldSet : WebUIControlContainer
  {
    protected MBA.Wrapper _ctrlLegend = new MBA.Wrapper("legend");
    protected MBA.Button  _ctrlOKBut  = new MBA.Button();
    protected MBA.Wrapper _ctrlLnks   = new MBA.Wrapper("div");
    
    protected bool   _includeOKButton             = true;
    protected bool   _includeLegend               = true;
    protected string _legendText                  = @"";        
    protected string _fieldNamePrefix             = @"";
    protected string _fnControlLabel              = @"";
    protected string _fnControlValue              = @"";
    protected string _fnNameControlLabel          = "";
    protected string _fnNameControlValue          = "";
    protected string _fnNameFieldSetDataSelect    = "";            
    protected string _fnFieldSetDataSelectHdlr    = "";
    
    /*
     parmName
     parmValue
     */
    
    public    string  fieldNamePrefix { get { return _fieldNamePrefix; } set { _fieldNamePrefix = value; } } 
    public    bool    includeLegend   { get { return _includeLegend;   } set { _includeLegend   = value; } }
    public    string  legendText      { get { return _legendText;      } set { _legendText      = value; } }
    public    bool    includeOKButton { get { return _includeOKButton; } set { _includeOKButton = value; } }
    public    string  fnControlLabel  { get { return _fnControlLabel;  } set { _fnControlLabel  = value; } }
    public    string  fnControlValue  { get { return _fnControlValue;  } set { _fnControlValue  = value; } }

    public FieldSet() : base("fieldset", false) 
    {
      //this.cssClass        = @"mba-fieldset";
      //_ctrlLegend.cssClass = @"mba-fieldset-legend";
    }

    protected override void OnPreRender(EventArgs e)
    {                               
      _fnNameControlLabel       = Util.createFormFieldIdOrName(this.ID,@"getctrllbl");
      _fnNameControlValue       = Util.createFormFieldIdOrName(this.ID,@"getctrlval");
      _fnNameFieldSetDataSelect = Util.createFormFieldIdOrName(this.ID,@"seldata");
      _fnFieldSetDataSelectHdlr = @"var ctrlID = e.target.id; var $me = $('#" + this.ID + @"'); var $meParent = $me.parent(); var meid = $me.attr('id'); $lbl = " + this._fnNameControlLabel + @"(); $val = " + this._fnNameControlValue + @"(); $.spedmonWebUI.fireDataSelected($meParent,{id:meid,label:$lbl,value:$val});return false;";

      _ctrlLnks.cssInline = @"padding-bottom:1em";
      
      if (_includeOKButton) 
      {            
        _ctrlOKBut.ID             = Util.createFormFieldIdOrName(this.ID,"butok");
        _ctrlOKBut.title          = @"Click here to proceed";
        _ctrlOKBut.text           = @"OK";
        _ctrlOKBut.cssInline      = "ui-spedmon-box-inline-ctrl";
        _ctrlOKBut.onclick        = _fnNameFieldSetDataSelect + "(e);return false;";
      }
            
      if (_includeLegend) 
      {
        if (!Util.IsNullOrEmpty(_legendText)) _ctrlLegend.Controls.Add(new RawText(this._legendText));
        this.Controls.Add(_ctrlLegend);
      }
            
      /*-------------------------------
       * Listen for spedmoninput data
       * events from the child controls
       * in the group, run our
       * handler, and cancel the 
       * original event
       *------------------------------*/

      this.addAttribute("spedmoninputdata", "e.stopPropagation();return false;", ATTR_JS_PAGE_LOAD_EVENT_ASSIGN);
      base.OnPreRender(e);
    }
    
    protected string generateStepLabel (params String[] parts)
    {
      StringBuilder sb = new StringBuilder();
      foreach (String part in parts) sb.Append(part);     
      return sb.ToString();  
    }
    

    protected override void Render(HtmlTextWriter writer)
    {                               
      
      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"function " + this._fnNameControlLabel       + @"(){"  + this._fnControlLabel + @"};");
      writer.Write(@"function " + this._fnNameControlValue       + @"(){"  + this._fnControlValue + @"};");
      writer.Write(@"function " + this._fnNameFieldSetDataSelect + @"(e){" + this._fnFieldSetDataSelectHdlr + @"};");
      writer.Write(@"</script>");

      /*-------------------------------
       * Include OK button 
       *------------------------------*/

      if (_includeOKButton) 
      {      
        this.Controls.Add(_ctrlOKBut);
      }

      /*-------------------------------
       * Render child controls
       *------------------------------*/

      base.Render(writer);
                 
    }
  }

}

