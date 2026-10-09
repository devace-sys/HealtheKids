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
   * Group */
  /**
   * Group of controls that submit seperate form values but need to be
   * treated as a single value for display purposes.  For example
   * a persons name.
   **************************************************************************/

  public class Group : WebUIControlContainer
  {
    public Group() : base("div", false) { }

    protected string _fnControlLabel;
    protected string _fnControlValue;
    protected string _fnGroupDataSelect;

    protected string _fnNameControlLabel;
    protected string _fnNameControlValue;
    protected string _fnNameGroupDataSelect;

    protected bool _okButton;
    protected string _okButtonID;

    public string fnControlLabel { get { return _fnControlLabel; } set { _fnControlLabel = value; } }
    public string fnControlValue { get { return _fnControlValue; } set { _fnControlValue = value; } }
    public bool okButton { get { return _okButton; } set { _okButton = value; } }

    protected override void Render(HtmlTextWriter writer)
    {

      /*-------------------------------
       * Generate unique function names
       * and element ids
       *------------------------------*/

      _fnNameControlLabel = this.ID + "_getctrllbl";
      _fnNameControlValue = this.ID + "_getctrlval";
      _fnNameGroupDataSelect = this.ID + "_seldata";
      _okButtonID = this.ID + "_okbut";

      _fnGroupDataSelect = @"var ctrlID = e.target.id; var $me = $('#" + this.ID + @"'); var $meParent = $me.parent(); var meid = $me.attr('id'); $lbl = " + this._fnNameControlLabel + @"(); $val = " + this._fnNameControlValue + @"(); $.spedmonWebUI.fireDataSelected($meParent,{id:meid,label:$lbl,value:$val});return false;";

      /*-------------------------------
       * Listen for spedmoninput data
       * events from the child controls
       * in the group, run our
       * handler, and cancel the 
       * original event
       *------------------------------*/

      //this.addAttribute("spedmoninputdata", "e.stopImmediatePropagation();"+_fnNameGroupDataSelect + "(e);return false;", ATTR_JS_PAGE_LOAD_EVENT_ASSIGN);
      this.addAttribute("spedmoninputdata", "e.stopPropagation();return false;", ATTR_JS_PAGE_LOAD_EVENT_ASSIGN);

      /*-------------------------------
       * Add OK button
       *------------------------------*/

      if (_okButton)
      {
        Button b = new Button();
        b.ID = _okButtonID;
        b.text = "OK";
        b.onclick = _fnNameGroupDataSelect + "(e);return false;";
        base.Controls.Add(b);
      }

      /*-------------------------------
       * Render child controls
       *------------------------------*/

      base.Render(writer);

      /*-------------------------------
       * Generate our handler scripts
       *------------------------------*/

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"function " + this._fnNameControlLabel + @"(){" + this._fnControlLabel + @"};");
      writer.Write(@"function " + this._fnNameControlValue + @"(){" + this._fnControlValue + @"};");
      writer.Write(@"function " + this._fnNameGroupDataSelect + @"(e){" + this._fnGroupDataSelect + @"};");
      writer.Write(@"</script>");
    }
  }

}

