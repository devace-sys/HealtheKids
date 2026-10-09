using System;
using System.Text;
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
   * DataEntryRowsRenderAs
  /**
   * 
   ****************************************************************************/
  public enum DataEntryRowsRenderAs
  {
        ROWS      
      , FIELDS      
  }
    
  /**************************************************************************
   * DataEntryRowsPurpose
  /**
   * 
   ****************************************************************************/  

  public enum DataEntryRowsPurpose
  {      
      SAVE   = 10
    , VIEW   = 20
    , MANAGE = 30    
    , CUSTOM = 100    
  }

  /**************************************************************************
   * DataEntryRows
  /**
   * 
   ****************************************************************************/  
  public class DataEntryRows:ControlBase
  {
    public DataEntryRows () : base()
  	{   	  
    }
    
    protected DataEntryRowsRenderAs _dataEntryRowsRenderAs  = DataEntryRowsRenderAs.ROWS;
    protected DataEntryRowsPurpose  _purpose                = DataEntryRowsPurpose.SAVE;
    protected bool                  _useBootstrapFluid      = false;
    protected bool                  _useBootstrapGrid       = true;
    protected bool                  _dataPrivate            = true;
    protected string                _dataURL                = null;

    public DataEntryRowsRenderAs dataEntryRowsRenderAs
    {
      get { return _dataEntryRowsRenderAs; }
      set { _dataEntryRowsRenderAs = value; }
    }

    public bool    useBootStrapGrid    { get { return _useBootstrapGrid; }   set { _useBootstrapGrid = value; }}
    public bool    useBootstrapFluid    { get { return _useBootstrapFluid; } set { _useBootstrapFluid = value; }}
    public bool    dataPrivate          { get { return _dataPrivate; } set { _dataPrivate = value; } }
    public  string  dataURL              { get { return _dataURL; }     set { _dataURL = MBA.HttpApplication.createLink(value, _dataPrivate); } }
    public  DataEntryRowsPurpose purpose { get { return _purpose;}      set {_purpose = value;}}


    /***************************************************************************
     * Render */
    /**
     * 
     * 
     ***************************************************************************/         
    
    protected override void Render(HtmlTextWriter writer)
    {                       
                  
      var formclass = "";
	  var rowsclass = "";

	  if (String.IsNullOrWhiteSpace(this.ID)) 
      { 
        if      (_purpose == DataEntryRowsPurpose.SAVE)   this.ID = Constants.PARM_SAVE_FORM;
        else if (_purpose == DataEntryRowsPurpose.MANAGE) this.ID = Constants.PARM_MANAGE_FORM;
      }
      
      if (_dataEntryRowsRenderAs == DataEntryRowsRenderAs.ROWS)
      {
         formclass = @"ui-spedmon-data-entry-rows"; 
         rowsclass = @"ui-spedmon-data-entry-rows" + ((_useBootstrapGrid) ?
                        ((_useBootstrapFluid) ? @" container-fluid" : @" container")
                        : "");
      }
      else if (_dataEntryRowsRenderAs == DataEntryRowsRenderAs.FIELDS)
      {
         formclass = @"ui-spedmon-data-entry-fields";
         rowsclass = @"ui-spedmon-data-entry-fields";
      }

      writer.Write (@"<form id=""{0}"" action=""{1}"" method=""post"" class=""{2}"">", this.ID, _dataURL, formclass);
      writer.Write (@"<div class=""{0}"">", rowsclass);

      base.Render(writer);
        
      writer.Write(@"</div>");  
      writer.Write(@"</form>"); 
           
      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(@"$(function() {");
      writer.Write(@"$('#" + this.ID + @"').spedmonDataEntryRows({});");
      writer.Write(@"});");
      writer.Write(@"</script>");
      return;
    }
  }
}
