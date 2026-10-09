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

  /***************************************************************************
   * Instructions */
  /**
   * Instructions box
   * 
   * @param  id                  Instructions ID
   * @param  title               Instructions title
   * @param  instructionsWidth   Width in em, %, or px (default 50%)
   * @param  instructionState    jQuery UI ui-state (default ui-state-highlight)
   * @param  instructionIcon     jQuery UI ui-icon  (default ui-icon-info)
   * @param  instructionsHTML    Markup of instructions
   *
   * Generates markup for on screen instructions or an onscreen notice.
   ***************************************************************************/

  public class Instructions : WebUIControlDisplay
  {

    public Instructions ()          : this(""){}
    public Instructions (string id) : base("div",false)
    {
      this.ID = id;
      this.addCssClass(@"ui-instruction-list-content");
    }

    protected string   _instructionHTML   = "";
    protected string   _width             = "50%";
    protected string   _instructionState  = "ui-state-highlight";
    protected string   _instructionIcon   = "ui-icon-info";
   // protected bool     _closeButton       = false;
    protected bool    _renderBrs          = true;

    public    string   instructionHTML    { get { return _instructionHTML;}  set {_instructionHTML  = value;}}
    public    string   instructionWidth   { get { return _width; }           set {_width            = value;}}
    public    string   instructionState   { get { return _instructionState;} set {_instructionState = value;}}
    public    string   instructionIcon    { get { return _instructionIcon;}  set {_instructionIcon  = value;}}
   // public    bool     closeButton        { get { return _closeButton;}      set {_closeButton      = value;}}

   public bool renderBrs { get { return _renderBrs;} set { _renderBrs = value;} }
    protected override void Render(HtmlTextWriter writer)
    {            
      writer.Write(@"<div class=""ui-widget"" style=""width:" + _width +@";margin:0 auto"">");
      writer.Write(@"<div class=""" + _instructionState +@" ui-corner-all"" style=""padding:1em;border:1px solid #000;"">");
      writer.Write(@"<div class=""ui-instructions-list"">");

      writer.Write(@"<div class=""ui-instruction-list-title"">");
      writer.Write(@"<span class=""ui-icon " + _instructionIcon + @""" style=""float:left;margin-right:1em;""></span>");
      writer.Write(@"<span class=""ui-instruction-list-title"">");
      writer.Write(this.title);
      writer.Write(@"</span>");
      writer.Write(@"</div>");
      
      /*-------------------------------
       * Instructions HTML are rendered
       * pulling instuctions from
       * instructionsHTML and then 
       * any child controls.
       *------------------------------*/ 
      
      writer.Write(_instructionHTML);
      base.Render(writer);

      writer.Write(@"</div>");
      writer.Write(@"</div>");     
      writer.Write(@"</div>");

      if (_renderBrs) writer.Write(@"<br/><br/>");

    }
  }

}

