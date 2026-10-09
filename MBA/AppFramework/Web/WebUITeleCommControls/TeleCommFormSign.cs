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
   * TeleCommFormSign */
  /**
   * Use with telecomm-common.js
   * 
   * 
   ****************************************************************************/ 

  public class TeleCommFormSign:ControlBase
  {
    public TeleCommFormSign(){
     
    }    
    
    protected string                     _forFormID               = "";
    protected string                     _ctrlSignatureTextAreaID = "";
    protected string                     _sigClassName            = "";
    protected string                     _ctrlIDInpUID            = "";
    protected string                     _ctrlIDInpPin            = "";
    protected string                     _ctrlIDButSign           = "";
    protected string                     _fieldNameSign           = "";
    protected string                     _ctrlIDAddData           = "";      
    protected string                     _ctrlIDSignatureData     = "";      
    protected bool                       _shareDataWhenSigned     = true; 
    protected string                     _title                   = @"";
    public string                         forFormID                 { get { return _forFormID;}               set {_forFormID = value;}}
    public string                         ctrlSignatureTextAreaID   { get { return _ctrlSignatureTextAreaID;} set {_ctrlSignatureTextAreaID = value;}}
    public string                         sigClassName              { get { return _sigClassName;}            set {_sigClassName = value;}}
    public string                         ctrlIDSelectParticipant   { get { return _ctrlIDInpUID;}            set {_ctrlIDInpUID = value;}}
    public string                         ctrlIDInputPin            { get { return _ctrlIDInpPin;}            set {_ctrlIDInpPin = value;}}
    public string                         ctrlIDSign                { get { return _ctrlIDButSign;}           set { _ctrlIDButSign = value;}}	  
    public string                         fieldNameSign             { get { return _fieldNameSign;}           set { _fieldNameSign = value;}}	  
    public bool                           shareDataWhenSigned       { get { return _shareDataWhenSigned;}     set {_shareDataWhenSigned = value;}} 
    public string                         title                     { get { return _title;}                   set { _title = value; }}
    protected override void Render (HtmlTextWriter writer) 
	  { 
      var _ctrlID          = this.ID;
      _ctrlIDAddData       = _ctrlID + @"additionaldata";      
      _ctrlIDSignatureData = _ctrlID + @"signaturedatacont"; // used as outer container of signature pad

      // set up opts for signature pad plugin
      string _opts = @"{"
                    + @" ""inputNameAndID"":""" + _ctrlSignatureTextAreaID
                    + @""",""inputInitialValue"":"""
                    + @""",""includeRenderDialogBtn"":" + "false"
                    + @",""fnSave"":function() { MBA.telecomm.doSignForm ("
                                                    + "'" + _forFormID                                
                                                    + "', '" + _ctrlID                                   
                                                    + "', '" + _sigClassName                             
                                                    + "', '" + _ctrlIDInpUID                             
                                                    + "', '" + _ctrlIDInpPin                             
                                                    + "', '" + _ctrlIDButSign                            
                                                    + "', '" + _fieldNameSign                            
                                                    + "', '" + _ctrlIDAddData                            
                                                    + "', '" + Util.netBoolToJSBool(_shareDataWhenSigned)
                                                    + "', '" + _title                                    
                                                    + "');"
                                                    + "}"
                    + @",""fnCancel"":function() { $('#" + _ctrlIDButSign + "').children('label').removeClass('active'); }"
                    + @"}";

      writer.Write(@"<div id=""{0}"" class=""container"">",_ctrlID);
      writer.Write(@"<form id=""{0}"" class=""row"" autocomplete=""off"">",_ctrlIDAddData);
      writer.Write(@"<div id=""{0}""></div>", _ctrlIDSignatureData);
      base.Render(writer);      
      writer.Write(@"</form>");
      writer.Write(@"</div>");

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");
      
      writer.Write(@"$('#{0}').on('submit',", _ctrlIDAddData);
      writer.Write(@"function (frmSubEvent){"); 
      writer.Write(@"frmSubEvent.preventDefault();");
      writer.Write(@"return false;");
      writer.Write(@"});");

      writer.Write(@"$('#{0} label > input[type=radio]').click(",_ctrlIDButSign);
      writer.Write(@"function(){"); 
      writer.Write(@"$('#" + _ctrlIDSignatureData + "').spedmonSignaturePad(null," + _opts + ");"); // if user is signing, show them the signature pad
      writer.Write(@"});");

      writer.Write(@"})");
      writer.Write(@"</script>");
	  }  
  }
}

