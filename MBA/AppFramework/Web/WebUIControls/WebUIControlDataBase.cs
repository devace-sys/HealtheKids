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
   * WebUIControlData*/
  /**
   * Base class for all controls that collect data from users.
   * 
   * @param  name        name
   * @param  value       value
   * @param  noClear     Adds a class to the CSS attribute that can be used by
   *                     client side code to not clear this field during a form clear.
   * @param  noSubmit    Adds a class to the CSS attribute that is used by client 
   *                     side code to not submit this field as par of a post
   * @param  dgLabel     Used by datagrid control.  Indicates that this field
   *                     is to be treated as a read only label
   * @param  dgKey       Used by datagrid control.  Indicates that this field
   *                     is to be used as a dg key field for add/remove.
   *****************************************************************************/

  public abstract class WebUIControlData : WebUIControl
  {
    
    /*-------------------------------
     * Field constants for client
     * side.  Keep this in synch with
     * the $.spedmonWebUI.field
     * definitions.
     *------------------------------*/

    public const string WEB_UI_FIELD_NO_CLEAR       = "mba-web-ui-field-no-clear";
    public const string WEB_UI_FIELD_NO_SUBMIT      = "mba-web-ui-field-no-submit";
    public const string WEB_UI_FIELD_SIMPLE         = "mba-web-ui-field-simple";
    public const string WEB_UI_FIELD_COMPLEX        = "mba-web-ui-field-complex";

    public const string WEB_UI_FIELD_DATA_TEXT        = "mba-web-ui-field-data-text";
    public const string WEB_UI_FIELD_DATA_TEXT_AREA   = "mba-web-ui-field-data-text-area";
    public const string WEB_UI_FIELD_DATA_NUMBER      = "mba-web-ui-field-data-number";
    public const string WEB_UI_FIELD_DATA_DATE        = "mba-web-ui-field-data-date";
    public const string WEB_UI_FIELD_DATA_TIME        = "mba-web-ui-field-data-time";    
    public const string WEB_UI_FIELD_DATA_DATE_RANGE  = "mba-web-ui-field-data-date-range";    
    public const string WEB_UI_FIELD_DATA_BOOL        = "mba-web-ui-field-data-bool"; /* Can be true, false, or null */
    public const string WEB_UI_FIELD_DATA_FLAG        = "mba-web-ui-field-data-flag"; /* Can only be true or false */
    
    /*-------------------------------
     * Constructors
     *------------------------------*/

    public WebUIControlData (string tag, bool noclosetag, bool simplefield)                            : base(tag, noclosetag) { this._simpleField = simplefield;}
    public WebUIControlData (string tag, bool noclosetag, bool simplefield, string name)               : base(tag, noclosetag) { this._simpleField = simplefield; this.name = name; }    
    public WebUIControlData (string tag, bool noclosetag, bool simplefield, string name, string value) : base(tag, noclosetag) { this._simpleField = simplefield; this.name = name; this.value = value; }
            
    /*-------------------------------
     * Private values for properies
     *------------------------------*/

    protected  bool   _noClear         = false;
    protected  bool   _noSubmit        = false;
    protected  bool   _simpleField     = true;

    /*-------------------------------
     * Properties
     *------------------------------*/

    public  string    name   { get { return (string)this.findAttribute("name"); }      
                               set { this.addAttribute("name", value, ATTR_HTML_TAG); } }
    
    public  string    value  { get { return (string)this.findAttribute("value"); }     
                               set {/*--------------------------------------------------
                                     * Make sure incoming value is a web safe string
                                     * Technique courtesy of John White
                                     * http://whitepages.unlimitedviz.com/2010/05/format-an-html-safe-string-using-net/
                                     *------------------------------------------------*/                                      
                                     string vValue = (_simpleField) ? System.Security.SecurityElement.Escape(value) : value; 
                                     this.addAttribute("value", vValue, ATTR_HTML_TAG); } }
        
    public  bool    noClear          { get { return _noClear;         } set { this._noClear         = value; }}
    public  bool    noSubmit         { get { return _noSubmit;        } set { this._noSubmit        = value; }}
      
    /***************************************************************************
     * setParentStepLabel */
    /**
     * Finds ctrls parent step control (if it exists) sets its label using 
     * the value of this control
     * 
     * @param  labelText       text to display in label
     * @return                 Step control or null
     ***************************************************************************/   

    public Step setParentStepLabel ()
    {
      return setParentStepLabel(this.value);
    }
    
    /***************************************************************************
     * Render */
    /**
     ***************************************************************************/   

    protected override void Render(HtmlTextWriter writer)
    {
      if (_simpleField) this.addCssClass (WEB_UI_FIELD_SIMPLE); else this.addCssClass (WEB_UI_FIELD_COMPLEX);
      if (_noClear)     this.addCssClass (WEB_UI_FIELD_NO_CLEAR);
      if (_noSubmit)    this.addCssClass (WEB_UI_FIELD_NO_SUBMIT);
      
      base.Render(writer);
    }
  }
}

