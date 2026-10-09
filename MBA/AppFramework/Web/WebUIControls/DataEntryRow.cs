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
   * DataEntryRowRenderAs
  /**
   * 
   ****************************************************************************/
  public enum DataEntryRowRenderAs
  {
        ROW
      , FIELD
  }
  
  /**************************************************************************
   * DataEntryRow
  /**
   * 
   ****************************************************************************/  
  public class DataEntryRow:ControlBase
  {
    public DataEntryRow () : base()
  	{   	  
    }
    
    protected DataEntryRowRenderAs        _dataEntryRowRenderAs               = DataEntryRowRenderAs.ROW;
    protected DelegateUserSpecificAction  _entryAllowedFn                     = null;
    protected DelegateUserSpecificAction  _entryNotAllowedReplacementValueFn  = null;
    protected bool                        _entryNotAllowedUseReplacementValue = true;
    protected string                      _onSpedmonInputData                 = "";
    protected bool?                       _entryAllowed                       = null;
    protected bool                        _entryIsAllowed                     = true;  /* Initial value MUST be true */      
    protected bool                        _entryInitiallyHidden               = false;
    protected bool                        _useBootstrapGrid                   = true;
    protected int                         _userGroup                          = -1;
    protected string                      _userRole                           = null;
    protected string                      _additionalRowClass                 = "";
    protected string                      _colLabelBSClasses                  = " col-xs-12 col-sm-12 col-md-3 col-lg-3 col-xl-2";
    protected string                      _colEntryBSClasses                  = " col-xs-12 col-sm-12 col-md-9 col-lg-9 col-xl-10";
    protected string                      _onDocReady                         = null;
    protected string                      _additionalOnDocReady               = "";
    protected bool                        _renderChildControlsOnly            = false;
    protected string                      _additionalInformation              = @"";
    protected string                      _colEntryID                         = @"";
    protected UserInfo                    _uInfo                              = null;
    public DataEntryRowRenderAs           dataEntryRowRenderAs               { get { return _dataEntryRowRenderAs; } 
                                                                               set { _dataEntryRowRenderAs = value; }}
    public bool?                          entryAllowed                       { get { return _entryAllowed; }  set {_entryAllowed = value;} }
    public bool                           useBootstrapGrid                   { get { return _useBootstrapGrid; }  set { _useBootstrapGrid = value;} }
    public  DelegateUserSpecificAction    entryAllowedFn                     { get { return _entryAllowedFn;}                      set { _entryAllowedFn = value; }}
    public  DelegateUserSpecificAction    entryNotAllowedReplacementValueFn  { get { return _entryNotAllowedReplacementValueFn;  } set { _entryNotAllowedReplacementValueFn  = value; }}
    public bool                           entryNotAllowedUseReplacementValue { get { return _entryNotAllowedUseReplacementValue; } set { _entryNotAllowedUseReplacementValue = value; }}
    public string                         rowLabel                           { get ; set; }        
    public bool                           entryInitiallyHidden               { get { return _entryInitiallyHidden; }   set { _entryInitiallyHidden = value; }}
    public string                         onSpedmonInputData                 { get { return _onSpedmonInputData;   }   set { _onSpedmonInputData   = value; }}
    public bool                           renderChildControlsOnly            { get { return _renderChildControlsOnly;} set { _renderChildControlsOnly = value; }}
    public string                         additionalInformation              { get { return _additionalInformation; }  set { _additionalInformation = value; }}    
    public UserInfo                       uInfo                              { get { return _uInfo; }                  set {  _uInfo = value; } }

    /***************************************************************************
     * addHiddenInput */
    /**
     * 
     * Adds hidden input to the controls
     ***************************************************************************/             
    protected void addHiddenInput (string ctrlID, string parmName, string parmValue = @"") 
    {
      var input = new MBA.HiddenInput();
      input.ID    = ctrlID;
      input.name  = parmName;
      input.value = parmValue;
      input.title = parmName;
      this.Controls.Add(input);
    }

    /***************************************************************************
     * determineIfValueCanBeSelectedAndIfNotWhatValueToUse */
    /**
     * 
     ***************************************************************************/             
    protected void determineIfEntryIsAllowedAndWhatReplacementValueToUse (ref RequestResponse rd)
    {                        
      if (_entryAllowed.HasValue == true)
      {        
        _entryIsAllowed = _entryAllowed.Value;
      }  
      else
      { 
        if (_entryAllowedFn != null)
          _entryIsAllowed = _entryAllowedFn(ref rd);       
        else
          _entryIsAllowed = true;
      }

      if ((_entryIsAllowed == false) && (_entryNotAllowedUseReplacementValue == true) && (_entryNotAllowedReplacementValueFn != null))
       _entryNotAllowedReplacementValueFn(ref rd);
    }

   /***************************************************************************
     * renderAdditionalInformation */
    /**
     * 
     ***************************************************************************/
    private void renderAdditionalInformation ()
    {
      if (String.IsNullOrWhiteSpace(_additionalInformation)) return;
        
      var addInfo = new MBA.Wrapper(@"div"
                                    ,new MBA.RawHTML(@"<span class=""ui-spedmon-select-entity-additional-info-icon ui-icon ui-icon-info""></span>")
                                    ,new MBA.RawHTML(@"<span class=""ui-spedmon-select-entity-additional-info-text"">" 
                                                 + _additionalInformation 
                                                         + @"</span>")
                                        );
       addInfo.cssClass = @"ui-spedmon-select-entity-additional-info";
       
    }
    

    /***************************************************************************
     * OnPreRender */
    /**
     * 
     ***************************************************************************/         
    protected override void OnPreRender(EventArgs e)
    {
 
      if (rd.loggedIn)
      { 
        this._userGroup = rd.wu.usr.userGroupID;
        this._userRole  = rd.wu.usr.roleName.ToLower();
        this._uInfo     = new UserInfo();
        UserInfo.retrieveUserInfo(rd, ref this._uInfo);        
        determineIfEntryIsAllowedAndWhatReplacementValueToUse (ref rd);
      }    
      if (String.IsNullOrWhiteSpace(this.ID)) this.ID = Util.createUniqueID(@"data-entry-row");
      _colEntryID = Util.createUniqueID(this.ID);    
      base.OnPreRender(e); 
    }

    /***************************************************************************
     * Render */
    /**
     * 
     * 
     ***************************************************************************/         
    
    protected override void Render(HtmlTextWriter writer)
    {                       
            
      if (_renderChildControlsOnly)
      {
        base.Render(writer);
        return;
      }
           
      if (_entryIsAllowed == true)
      {                 
                                   
        if (_dataEntryRowRenderAs == DataEntryRowRenderAs.ROW)
        { 
          
          var rowclass =  (_additionalRowClass 
                       + " ui-spedmon-data-entry-row" 
                       + ((_entryInitiallyHidden) ? " ui-spedmon-data-entry-row-input-hide-until-needed" : "")
                       + ((_useBootstrapGrid) ? " row" : "")).Trim();
                   
          var colclass                  = "ui-spedmon-data-entry-col";
          var collabelclass             =  colclass + " ui-spedmon-data-entry-col-label" + ((_useBootstrapGrid) ? _colLabelBSClasses : "");
          var colentryclass             =  colclass + " ui-spedmon-data-entry-col-entry" + ((_useBootstrapGrid) ? _colEntryBSClasses : "");

          writer.Write(@"<div id=""{0}"" class=""{1}"">", this.ID, rowclass);               /* Row */        
          writer.Write(@"<div class=""{0}""><h5>{1}</h5></div>", collabelclass, rowLabel);  /* Column - Label */        
          writer.Write(@"<div id=""{0}"" class=""{1}"">",_colEntryID, colentryclass);       /* Column - Entry */
              
          base.Render(writer);

          /* Add additional info */

          if (!String.IsNullOrWhiteSpace(_additionalInformation)) {
        
            var addInfo = new MBA.Wrapper(@"div"
                                          ,new MBA.RawHTML(@"<span class=""ui-spedmon-select-entity-additional-info-icon ui-icon ui-icon-info""></span>")
                                          ,new MBA.RawHTML(@"<span class=""ui-spedmon-select-entity-additional-info-text"">" 
                                            + _additionalInformation 
                                            + @"</span>")
                                          );
             addInfo.cssClass = @"ui-spedmon-select-entity-additional-info";
             addInfo.RenderControl(writer);
          }
        
          writer.Write(@"</div>");  /* Column - Entry */
          writer.Write(@"</div>");  /* Row */

         
        }
        
        /* Render as a field */

        else if (_dataEntryRowRenderAs == DataEntryRowRenderAs.FIELD)
        {
          var fieldcontclass = "ui-spedmon-data-entry-field-container"
                             + ((_entryInitiallyHidden) ? " ui-spedmon-data-entry-field-input-hide-until-needed" : "");                          
          var fieldentryclass = @"ui-spedmon-data-entry-field-entry";
          var fieldlabelclass = @"ui-spedmon-data-entry-field-label";
          writer.Write(@"<span id=""{0}"" class=""{1}"">", this.ID, fieldcontclass);        /* Row */
          writer.Write(@"<span id=""{0}"" class=""{1}"">", _colEntryID, fieldentryclass);   /* Column - Entry */
          base.Render(writer);
          writer.Write(@"</span>");                                                         /* Column - Entry */
          /* Label must be after*/
          writer.Write(@"<label class=""{0}"">{1}</label>", fieldlabelclass, rowLabel);     /* Column - Label */
          writer.Write(@"</span>"); /* Row */        
        }
        else
        {

        }
                
        if (String.IsNullOrWhiteSpace(_onDocReady))
        {
          _onDocReady = @"$('#" + this.ID + @"').spedmonDataEntryRow({" 
          + @"colEntryID:'" + _colEntryID + @"'"
          + @",renderedAsField:" + ((_dataEntryRowRenderAs == DataEntryRowRenderAs.FIELD) ? "true" : "false")
          + @",onSpedmonInputData:function(e){" + _onSpedmonInputData + @"}});";
        }

        if (String.IsNullOrWhiteSpace(_additionalOnDocReady))
        {
          _additionalOnDocReady = @"";
        }

        writer.Write(@"<script type=""text/javascript"">");
        writer.Write(@"$(function() {");
        writer.Write(_onDocReady);
        writer.Write(_additionalOnDocReady);
        writer.Write(@"});");
        writer.Write(@"</script>");        
      }
      else
      {
        var rowclassnoinputallowed = "ui-spedmon-data-entry-row-no-input-allowed";
        writer.Write(@"<div id=""{0}"" class=""{1}"">",this.ID,rowclassnoinputallowed);
        base.Render(writer);
        writer.Write(@"</div>");      
      }
         
      return;
    }
  }
}
