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
    * StepSection */
  /**
  * StepSection
  * Note: This control has unsusual markup requirments for jQuery therefore
  * it has been put into its own class that inherits from control
  ****************************************************************************/

  public class StepSection : ControlBase
  {
    public StepSection() { }

    protected string _title    = "";
    protected string _instr    = "";
    protected string _titleID  = "";
    protected string _instrID  = "";
    protected bool   _startSec = false;
    
    public string title        { get { return _title; }   set { _title   = value; }}
    public string instructions { get { return _instr; }   set { _instr   = value; }}
    public bool   startSection { get { return _startSec;} set {_startSec = value; }}

    protected override void Render(HtmlTextWriter writer)
    {
      _titleID = this.ID + "_title";
      _instrID = this.ID + "_instr";

      /*-------------------------------
       * Content start
       *------------------------------*/
      writer.Write(@"<div id=""" + this.ID + @""">");
      /*-------------------------------
       * Controls start
       *------------------------------*/
      writer.Write(@"<span id=""" + _titleID + @""" style=""display:none"">" + this._title + @"</span>");
      writer.Write(@"<span id=""" + _instrID + @""" style=""display:none"">" + this._instr + @"</span>");

      base.Render(writer);
      
      /*-------------------------------
       * Controls end
       *------------------------------*/

      /*-------------------------------
       * Content end
       *------------------------------*/

      writer.Write(@"</div>");
    }
  }

}

