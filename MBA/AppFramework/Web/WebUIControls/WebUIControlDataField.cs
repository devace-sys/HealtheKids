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
   * WebUIControlDataField */
  /**
   * Base class for all controls that collect single data items from users.
   *
   * @param  name            name
   * @param  value           value
   * @param  inlineLabel     Label to display before control if desired 
   * @param  maxlength       Maximum # of characters allowed
   *                        (Note: This is a client side test only)
   *****************************************************************************/

  public abstract class WebUIControlDataField : WebUIControlData
  {
    /*-------------------------------
     * Field constants for client
     * side.  Keep this in synch with
     * the $.spedmonWebUI.field
     * definitions.
     *------------------------------*/
    
    public const string WEB_UI_FIELD_HAS_DEFAULT = "mba-web-ui-field-has-default";
    
    /*-------------------------------
     * Constructors
     *------------------------------*/
    
    public WebUIControlDataField(string tag, bool noclosetag)                            : base(tag, noclosetag, true) { }
    public WebUIControlDataField(string tag, bool noclosetag, string name)               : base(tag, noclosetag, true) { this.name = name;}
    public WebUIControlDataField(string tag, bool noclosetag, string name, string value) : base(tag, noclosetag, true) { this.name = name; this.value = value;}

    protected  string   _inlineLabel                         = "";
    protected  bool     _privateEntry                        = false;
    protected  string   _privateLabel                        = "Value Entered";

    protected  bool     _useDefaultValue                     = false;
        // TODO: it's not intuitive (I think) but the dev has to manually set useDefaultValue = true
        //       after setting the defaultValue

    protected  bool     _readOnly                            = false;
    protected  string   _additionalCssClassNameForContainer  = @"";
    protected  string   _inlineLabelCss                      = @"ui-widget-header ui-state-default ui-corner-all ui-spedmon-label-inline";
    protected  bool     _labelIsSpan                         = false;
    public  string  formID          { get { return (string)this.findAttribute("form"); } 
                                       set { this.addAttribute("form", value, ATTR_HTML_TAG); } }
    public  string  maxlen           { get { return (string)this.findAttribute("maxlength"); } 
                                       set { this.addAttribute("maxlength", value, ATTR_HTML_TAG); } }

    public  string  inlineLabel      { get { return this._inlineLabel; }                            
                                       set { this._inlineLabel = value; } }

    public  string  inlineLabelCss   {  get { return this._inlineLabelCss;}
                                       set { this._inlineLabelCss = value;}}

    public  bool    labelIsSpan      {  get {  return this._labelIsSpan;}
                                        set { this._labelIsSpan = value;}}
    public  bool    privateEntry     { get { return _privateEntry; }                           
                                       set { this._privateEntry = value; } }
    
    public  string  privateLabel     { get { return _privateLabel; }                           
                                       set { this._privateLabel = value; } }
    
    public  bool    useDefaultValue  { get { return _useDefaultValue; } set { this._useDefaultValue = value; }}
        
    // TODO: See if we can replace set with addOrReplace
    
    public  string  defaultValue     { /* We use an HTML5 attribute data-? (? = user defined) to pass the default value */
                                      get { return (string) this.findAttribute("data-default-value"); }
                                      set { this.addAttribute("data-default-value", value, ATTR_HTML_TAG);}}
 
    
    public bool   readOnly { get { return _readOnly;} 
                             set {
                                   _readOnly = value;
                                   if (_readOnly == true)
                                   {
                                     this.addOrReplaceAttribute(@"readonly",@"1",ATTR_HTML_TAG); 
                                   }
                                   else
                                   {
                                     this.removeAttribute(@"readonly"); 
                                   }
                                 }
                            }

    public string additionalCssClassNameForContainer { get { return _additionalCssClassNameForContainer; }
                                                       set { _additionalCssClassNameForContainer = value; }}

    protected override void Render(HtmlTextWriter writer)
    {
      /*-------------------------------
       * Check for required attributes
       *------------------------------*/

      if (Util.IsNullOrEmpty(this.title)) throw new Critical("title required");

      /*-------------------------------
       * Add automatic attributes
       *------------------------------*/

      this.addAttribute("autocomplete", "off", ATTR_HTML_TAG);    // Prevents browser from autocompleting field
      
      /*-------------------------------
       * Generate inline label if 
       * applicable
       *------------------------------*/

      if (!Util.IsNullOrEmpty(this._inlineLabel))
      {               
        string lblElem = @"label";
        if (_labelIsSpan == true) lblElem = @"span"; 
        string lblHtml = String.Format(@"<{0} class=""{1}"">{2}</{0}>",lblElem, this._inlineLabelCss,this._inlineLabel);
        RawHTML c = new RawHTML(lblHtml);
        this.addPreControl(c);
      }
      
      /*-------------------------------
       * Setup default value if 
       * applicable.  
       * 
       * Default values provide the 
       * initial value and the value a 
       * control is set back to on clear.
       *------------------------------*/

      if ((_useDefaultValue))
      { 
      
        /*-------------------------------
         * Only certain controls can use
         * default values
         *------------------------------*/
        
        if (!((this.hasCssClass(WEB_UI_FIELD_DATA_BOOL)       || 
               this.hasCssClass(WEB_UI_FIELD_DATA_FLAG)       ||
               this.hasCssClass(WEB_UI_FIELD_DATA_DATE_RANGE) ||
               this.hasCssClass(WEB_UI_FIELD_DATA_NUMBER)     ||
               this.hasCssClass(WEB_UI_FIELD_DATA_TEXT)       ||
               this.hasCssClass(WEB_UI_FIELD_DATA_DATE)       ||
               this.hasCssClass(WEB_UI_FIELD_DATA_TIME)
             )))
               
          throw new Warning(@"Default values are not supported for this control.");
        
        /*-------------------------------
         * Check for required attributes
         *------------------------------*/

        if (Util.IsNullOrEmpty(this.defaultValue))
          throw new Warning(Messages.NO_DEFAULT_VALUE);
        
        /*-------------------------------
         * Check format of default value
         * if field type is not a date
         * or date range
         * (dates are handled seperately)
         *------------------------------*/

        if (!this.hasCssClass(WEB_UI_FIELD_DATA_DATE) && (!this.hasCssClass(WEB_UI_FIELD_DATA_DATE_RANGE)))
        {

          if (this.hasCssClass(WEB_UI_FIELD_DATA_TEXT))
            Validate.reqString(this.defaultValue, Messages.INVALID_DEFAULT_VALUE);
        
          if (this.hasCssClass(WEB_UI_FIELD_DATA_BOOL) || (this.hasCssClass(WEB_UI_FIELD_DATA_FLAG)))
            Validate.reqFlag(this.defaultValue, Messages.INVALID_DEFAULT_VALUE);

          if (this.hasCssClass(WEB_UI_FIELD_DATA_NUMBER))
            Validate.reqFloat(this.defaultValue, Messages.INVALID_DEFAULT_VALUE);                  
        }

        /*-------------------------------
         * Provide initial value
         * if field type is not a date
         * or date range
         * (dates are handled seperately)
         *------------------------------*/

        if (!this.hasCssClass(WEB_UI_FIELD_DATA_DATE) && (!this.hasCssClass(WEB_UI_FIELD_DATA_DATE_RANGE)))
        {        
          if (Util.IsNullOrEmpty (this.value)) 
            this.value = this.defaultValue;
        }
        
        /*-------------------------------
         * Add automatic css and values 
         *------------------------------*/

        this.addCssClass (WEB_UI_FIELD_HAS_DEFAULT);                      
        
      }

      base.Render(writer);
    }
  }
}

