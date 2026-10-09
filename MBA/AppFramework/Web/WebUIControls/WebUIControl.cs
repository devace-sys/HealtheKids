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
   * WebUIControl */
  /**
   * Base class for most controls.  Note this inherits from Control vs WebControl.
   * The webcontrol class has some extra functionality and overhead that is not
   * desired... for example it puts span tags around child controls.
   * 
   * http://www.w3schools.com/tags/ref_standardattributes.asp
   * 
   * @param  tag             Controls xhtml tag (required)
   * @param  id              Unique ID of control
   * @param  noclosetag      true = no closing tag 
   * @param  title           Title of control
   * @param  tabindex        Tab index of control
   * 
   * @param  cssclass        CSS classname
   * @param  cssinline       CSS inline style 
   * @param  hidden          This control should be hidden (display:none)
   *
   * @param  addPreControl   Add control/markup that should be before this control 
   * @param  addPostControl  Add control/markup that should be after this control 
   * @param  addChildControl Add control/markup that should be inside this control
   ****************************************************************************/ 

  [ParseChildren(false)]

  public abstract class WebUIControl : ControlBase
  {                
    public WebUIControl (string tag, bool noclosetag):base()
    { 
      Validate.reqString (tag,@"Tag name is required");
      this._tag        = tag;        
      this._noclosetag = noclosetag;
      this._ctrlattrs  = new List<NameValue>();
    }
    
    /*-------------------------------
     * Attribute constants
     *------------------------------*/ 

    public static readonly string ATTR_HTML_TAG                  = "0";
    public static readonly string ATTR_JS_PAGE_LOAD_METHOD       = "1";
    public static readonly string ATTR_JS_PAGE_LOAD_EVENT_ASSIGN = "2";
    public static readonly string ATTR_JS_KEY_EVENT_ASSIGN       = "3";
    public static readonly string ATTR_JS_CSS_ASSIGN             = "4";
    public static readonly string ATTR_HTML_TAG_CHILD_TEXT       = "5";

    protected  string    _tag;
    protected  bool      _noclosetag;
    protected  bool      _hidden;
    protected  bool      _hasscript;
    protected  bool      _hasscriptKeypress;
    protected  bool      _singleQuoteValueAttribute = false;
    protected  bool      _excludeFromTabIndex       = false;
    
   /*-------------------------------
    * Additional controls we want
    * before, inside, or after this
    * control.  
    *------------------------------*/
    
    protected List<RawHTML> _preControls    = new List<RawHTML>();
    protected List<RawHTML> _childControls  = new List<RawHTML>();
    protected List<RawHTML> _postControls   = new List<RawHTML>();
    
    protected void addPreControl   (RawHTML c)  {_preControls.Add(c);}
    protected void addChildControl (RawHTML c)  {_childControls.Add(c);}
    protected void addPostControl  (RawHTML c)  {_postControls.Add(c);}

    /***************************************************************************
     * findParentStep */
    /**
     * Finds ctrls parent step control (if it exists)
     * 
     * @param  ctrl            Root control     
     * @return                 Step control or null
     ***************************************************************************/   

    public static Step findParentStep (Control ctrl)
    {
      
      if (ctrl != null)
      {
        Type ct = ctrl.GetType();
        if (ct == typeof (MBA.Step)) 
        {
          return (Step) ctrl;
        }
        else if (ctrl.Parent != null) 
        {
          return findParentStep (ctrl.Parent);
        }
        else 
        {
          return null;
        }
      }
      return null;
    }
   
    public Step findParentStep()
    {
      return findParentStep(this);
    }
    
    /***************************************************************************
     * setParentStepLabel */
    /**
     * Finds ctrls parent step control (if it exists) sets its label
     * 
     * @param  labelText       text to display in label
     * @return                 Step control or null
     ***************************************************************************/   

    public Step setParentStepLabel(string labelText)
    {
      Step step = findParentStep();
      if (step != null) step.label = labelText;
      return step;
    }
                

    protected void addCssClass     (string cssclass)
    {
      /*-------------------------------
       * We want all css classes to
       * be stored in one attribute
       * seperated by spaces
       *------------------------------*/
  
      int classAttrIdx = findAttributeIdx("class");

      if (classAttrIdx != -1)
      {
        // There is already a class defined, append the new one to it
        string tempClass = (string) findAttribute("class");
        tempClass = tempClass + " " + cssclass;
        replaceAttribute("class",tempClass);
      }
      else
      {
        // No class definition yet, create one
        this.cssClass = cssclass;
      }
    }

    protected bool hasCssClass (string classname)
    {
      // Search for class attribute
      
      int classAttrIdx = findAttributeIdx("class");
      
      // If it is defined
      
      if (classAttrIdx != -1)
      {
        // Grab its value and search for our substring

        string tempClass = (string) findAttribute("class");
        return tempClass.Contains(classname);
      }
      
      return false;
    }

    public  string    cssClass  {get{return (string) this.findAttribute("class");}  set {this.addAttribute("class", value, ATTR_HTML_TAG);}}
    public  string    cssInline {get{return (string) this.findAttribute("style");}  set {this.addAttribute("style", value, ATTR_HTML_TAG);}}
    public  bool      hidden    {get{return (bool)   this.findAttribute("hide");}   set {this.addAttribute("hide",  value, ATTR_JS_PAGE_LOAD_METHOD);}}
    public  string    title     {get{return (string) this.findAttribute("title");}  set {this.addAttribute("title", value, ATTR_HTML_TAG);}}
    
    public  bool  singleQuoteValueAttribute {get {return _singleQuoteValueAttribute;} set {_singleQuoteValueAttribute = value;} }
    
    public bool   excludeFromTabIndex { get { return _excludeFromTabIndex;} 
                                        set {
                                          _excludeFromTabIndex = value;
                                          if (_excludeFromTabIndex == true)
                                          {
                                            this.addOrReplaceAttribute(@"tabindex",@"-1",ATTR_HTML_TAG); 
                                          }
                                          else
                                          {
                                            this.addOrReplaceAttribute(@"tabindex",@"0",ATTR_HTML_TAG); 
                                          }
                                        }
                                      }

    /*-------------------------------
     * AttributeMatch 
     * Courtesy of Author Unknown
     * http://www.codeproject.com/KB/cs/predicates.aspx
     *------------------------------*/ 

    protected class AttributeMatch
    {
      public AttributeMatch(string namein) {_name = namein;}
      // Attribute name to match
      private string _name;
      public string name{ get { return _name; } set {_name = value; }}
    
      // Gets the predicate.  
      public Predicate<NameValue> Match {get { return IsMatch; }}
      private bool IsMatch(NameValue nv){if (nv.name == _name){return true;}else{return false;}
      }
     }
  
    protected List<NameValue> _ctrlattrs;
 
    protected Object findAttribute (string name)
    {
      NameValue nv = _ctrlattrs.Find(new AttributeMatch(name).Match);
      if (nv != null)
        return nv.value;
      else 
        return null;
    }
    
    protected int findAttributeIdx (string name)
    {
      return _ctrlattrs.FindIndex(new AttributeMatch(name).Match);
    }

    public void addAttribute (string name, Object value, string type)
    {
      this._ctrlattrs.Add(new NameValue(name,value,type));
    }
    
    protected void replaceAttribute(string name, Object value)
    {
      int attrIdx = findAttributeIdx(name);
      if (attrIdx != -1)
        _ctrlattrs[attrIdx].value = value;
    }
    
    protected void addOrReplaceAttribute (string name, Object value, string type)
    {
      int attrIdx = findAttributeIdx(name);
      if (attrIdx != -1)
        _ctrlattrs[attrIdx].value = value;  
      else
         this._ctrlattrs.Add(new NameValue(name,value,type));
    }

    protected void removeAttribute (string name)
    {
      int attrIdx = findAttributeIdx(name);
      if (attrIdx != -1)
      {
        _ctrlattrs.RemoveAt(attrIdx);
      }
    }
    
    /*-------------------------------
     * Render the control
     *------------------------------*/ 
          
    protected override void Render(HtmlTextWriter writer)
    {
      
      /*-------------------------------
       * Render pre controls
       *------------------------------*/  
      
      foreach (RawHTML c in _preControls)
        c.RenderControl(writer);
       
      /*-------------------------------
       * Add id
       *------------------------------*/  

      if (!Util.IsNullOrEmpty(this.ID)) _ctrlattrs.Add(new NameValue("id", this.ID, ATTR_HTML_TAG));
            
      /*-------------------------------
       * Search for scripting
       * attributes.  We want to share
       * the same script tags if
       * we find any.
       *------------------------------*/  
      
      _hasscript = false;

      foreach (NameValue nvp in _ctrlattrs)
      {
        if ((nvp.typename == ATTR_JS_PAGE_LOAD_METHOD)       ||
            (nvp.typename == ATTR_JS_PAGE_LOAD_EVENT_ASSIGN) ||
            (nvp.typename == ATTR_JS_CSS_ASSIGN))
        { 
          _hasscript = true;     
          break;
        }
      }
      
      /*-------------------------------
       * Search for keypress atrributes
       * We want to share the same
       * block of script if we find any
       *------------------------------*/  
      
      _hasscriptKeypress = false;
      foreach (NameValue nvp in _ctrlattrs){
        if (nvp.typename == ATTR_JS_KEY_EVENT_ASSIGN){_hasscriptKeypress = true;break;}}
      
      /*-------------------------------
       * Throw exceptions if required
       * properties are missing
       *------------------------------*/  
      
      if (_hasscript) Validate.reqString(this.ID, @"id is required");

      /*-------------------------------
       * Construct our markup
       * starting with the opening
       * tag and html attributes
       *------------------------------*/  
      
      string markup = "";
      markup = @"<" + _tag;

      
      /*-------------------------------
       * HTML attributes
       *------------------------------*/  

      foreach (NameValue nvp in _ctrlattrs){
        if (nvp.typename == ATTR_HTML_TAG)
        { 
          string attrQuote = @"""";          
          if ((nvp.name == "value") && (_singleQuoteValueAttribute == true)) 
            attrQuote = "'";
          markup = markup + @" " + nvp.name + @"=" + attrQuote + nvp.value + attrQuote;
        }
      }
      
      /*-------------------------------
       * Closing opening tag
       *------------------------------*/  

      if (_noclosetag)
      {   
   
       /*-------------------------------
        * Closing opening tag as a
        * XHTML compliant empty tag
        * There are no child controls
        * only html attributes and
        * client side script
        *------------------------------*/  

        markup = markup + @"/>";
        writer.Write(markup);
      
      }
      else
      {
      
      /*-------------------------------
       * Closing opening tag as a
       * regular tag.  There may be
       * child controls to render.
       *------------------------------*/  
        
        markup = markup + @">";
        writer.Write(markup);
        
      /*-------------------------------
       * Render any child text that
       * was provided as a property
       *------------------------------*/  
      
       foreach (NameValue nvp in _ctrlattrs){
         if (nvp.typename == ATTR_HTML_TAG_CHILD_TEXT)
           writer.Write ((string)nvp.value);}
       
       /*-------------------------------
        * Render this controls children
        *------------------------------*/  
        
        base.Render(writer);

      /*-------------------------------
       * Render child controls passed in
       *------------------------------*/  
      
      foreach (RawHTML c in _childControls)
        c.RenderControl(writer);
                
      /*-------------------------------
       * Render closing tag
       *------------------------------*/  
        
        markup = @"</" + _tag + @">";
        writer.Write(markup);

      }
      
      /*-------------------------------
       * Client side methods 
       *------------------------------*/   
      
      if (_hasscript)
      {
        writer.Write(@"<script type=""text/javascript"">");
        writer.Write(@"$(function() {");
        foreach (NameValue nvp in _ctrlattrs)
        {

         /*-------------------------------
          * Page ready, method calls
          * nvp.name is the method name
          * nvp.value are the arguments
          * if any
          *------------------------------*/ 

          if (nvp.typename == ATTR_JS_PAGE_LOAD_METHOD)
          {
            // If nvp.value is not a string, provide a empty string for value
            writer.Write("$('#" + this.ID + @"')." + nvp.name + @"(" + ((nvp.value.GetType() == typeof(string)) ? (string)nvp.value : @"") + @");");
          }
         
          /*-------------------------------
           * Event assignments
           * nvp.name is the event name
           * nvp.value is the script to
           * execute
           *------------------------------*/ 

          else if (nvp.typename == ATTR_JS_PAGE_LOAD_EVENT_ASSIGN)
          {
             writer.Write(@"$('#" + this.ID + @"').bind('" + nvp.name + @"',function(e){");
             writer.Write((string)nvp.value);
             writer.Write(@"});");
          }
        }
        writer.Write(@"});");
        writer.Write(@"</script>");

      /*-------------------------------
       * Render post controls
       *------------------------------*/  
      
       foreach (RawHTML c in _postControls)
         c.RenderControl(writer);
     }
    }
  }

}

