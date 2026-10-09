using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using System.Collections;
using System.Collections.Generic;
using System.Net.Mail;
using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls.Base
{
	/// <summary>
	/// Base class for Control
	/// </summary>
	public abstract class ElementBase : ControlBase
	{

        #region Constructors

		/// <summary>
		/// Initializes a new instance of the <see cref="EAW.Web.UI.ElementBase"/> class.
		/// </summary>
		/// <param name="tag">Tag.</param>
		/// <param name="classCtrl">Class ctrl.</param>

		public ElementBase (HtmlTextWriterTag tag, string classCtrl) : this(Enum.GetName(typeof(HtmlTextWriterTag),tag),classCtrl)
		{
		
    }

		/// <summary>
		/// Initializes a new instance of the <see cref="EAW.Web.UI.ControlBase"/> class.
		/// </summary>
		/// <param name="element">Element.</param>
		/// <param name="classCtrl">Class ctrl.</param>

		public ElementBase (string element, string classCtrl)
		{
			this._attributes = new Dictionary<string, string> ();
			this._element    = element;
			this._classCtrl  = @"eaw-web-ui" + " " + classCtrl;
      _progressiveEnhanceMarkup = new ChildMarkup();
		}
        
    #endregion
        
		#region Properties

    private   string                             _accessKey                 = null;
		private   Dictionary <string,string>         _attributes                = null;
    private   string                             _classCtrl                 = null;
		private   string                             _class                     = null;       	    
    protected List<Control>                      _controlsToRenderBefore    = new List<Control>();
    protected List<Control>                      _controlsToRenderAfter     = new List<Control>();
    protected List<Control>                      _childControlsToPrepend    = new List<Control>();
    protected List<Control>                      _childControlsToAppend     = new List<Control>();
    private   string                             _element                   = null;
		private   bool?                              _hidden                    = null;
		private   string                             _style                     = null;
		private   int?                               _tabIndex                  = null;
		private   string                             _title                     = null;
    private   WrapOption                         _wrapOptionOuter           = WrapOption.na;
    private   String                             _wrapOptionOuterClass      = @"";
    private   bool                              _progressiveEnhance         = false;
    private   ComponentLibrary                  _progressiveEnhanceLibrary  = ComponentLibrary.none;
    private   ChildMarkup                       _progressiveEnhanceMarkup   = null;
      
               
		/// <summary>
		/// Specifies a shortcut key to activate/focus this control
		/// </summary>
		/// <value>The character to use</value>
		[Description("Gets or sets access key"), Category("HTML Attribute"), DefaultValue(null)] 
    public string AccessKey { get { return _accessKey; } set { _accessKey = value; } }

		/// <summary>
		/// Specifies one or more custom CSS classnames for an control
		/// </summary>
		/// <value>String</value>

    [Description("Gets or sets CSS class"), Category("HTML Attribute"), DefaultValue(null)] 
		public string Class { get { return _class; } set { _class = value; } }

		/// <summary>
		/// Specifies that an control is not yet, or is no longer, relevant
		/// </summary>
		/// <value>True or False</value>

    [Description("Gets or sets hidden state"), Category("HTML Attribute"), DefaultValue(null)] 
		public bool? Hidden { get { return _hidden; } set { _hidden = value; } }
		
		/// <summary>
		/// Specifies an inline CSS style for an control
		/// </summary>
		/// <value>Style rules</value>
   
    [Description("Progressive enhance?"), Category("Render Option"), DefaultValue(false)] 
	  public bool ProgressiveEnhance { get { return _progressiveEnhance; } set { _progressiveEnhance = value; } }

		[Description("Progressive enhance library to use?"), Category("Render Option"), DefaultValue(ComponentLibrary.none)] 
    public ComponentLibrary ProgressiveEnhanceLibrary { get { return _progressiveEnhanceLibrary;} set {_progressiveEnhanceLibrary = value;}}

    [Description("Progressive enhance markup"), Category("Render Option"), DefaultValue(false)] 
	  public string ProgressiveEnhanceMarkup { get { return _progressiveEnhanceMarkup.Markup; } set { _progressiveEnhanceMarkup.Markup = value; } }

    [Description("Gets or sets inline CSS style"), Category("HTML Attribute"), DefaultValue(null)] 
		public string Style { get { return _style; } set { _style = value; } }

		/// <summary>
		/// Specifies the tabbing order of an control
		/// </summary>
		/// <value>Integer</value>

    [Description("Gets or sets tab index"), Category("HTML Attribute"), DefaultValue(null)] 
		public int? TabIndex { get { return _tabIndex; } set { _tabIndex = value; } }

		/// <summary>
		/// Specifies extra information about an control
		/// </summary>
		/// <value>String</value>

    [Description("Gets or sets title"), Category("HTML Attribute"), DefaultValue(null)] 
		public string Title { get { return _title; } set { _title = value; } }


    /// <summary>
    /// Gets or sets the wrap option outer.
    /// </summary>
    /// <value>The wrap option outer.</value>

    [Description("Gets or sets container for this element"), Category("Render option"), DefaultValue(WrapOption.na)] 
		public WrapOption WrapOptionOuter { get { return _wrapOptionOuter; } set { _wrapOptionOuter = value; } }


    /// <summary>
    /// Gets or sets the wrap option outer css class.
    /// </summary>
    /// <value>The wrap option outer css class.</value>

    [Description("Gets or sets outer container css class for this element"), Category("Render option")] 
    public String WrapOptionOuterClass { get { return _wrapOptionOuterClass; } set { _wrapOptionOuterClass = value; } }
        
    #endregion

		#region Methods
		    
    /// <summary>
		/// Adds an HTML attribute to the dictionary of attributes to render 
		/// </summary>
		/// <param name="key">The name of the attribute</param>
		/// <param name="value">The value of the attribute</param>

		protected void AddAttribute (string key, string value) 
		{
		  if (_attributes.ContainsKey(key)) throw new Exception(key + @" is already defined");
          _attributes.Add (key, value);
		  return;
		}

    /// <summary>
    /// Adds the attribute if defined.
    /// </summary>
    /// <param name="attributeProperty">Attribute property.</param>
    /// <param name="attributeName">Attribute name.</param>        

    protected void AddAttributeIfDefined (bool? attributeProperty, string attributeName)
		{
		  if (attributeProperty.HasValue) if (attributeProperty.Value == true) AddAttribute (attributeName, attributeName);
        }
        
        protected void AddAttributeIfDefined (String attributeProperty, String attributeName)
		{
		  if (!String.IsNullOrEmpty(attributeProperty)) this.AddAttribute (attributeName, attributeProperty);
        }

        protected void AddAttributeIfDefined (int? attributeProperty, String attributeName)
		{
		  if (attributeProperty.HasValue) this.AddAttribute (attributeName, attributeProperty.Value.ToString());
        }
        
        protected void AddAttributeIfDefined (double? attributeProperty, String attributeName)
		{
		  if (attributeProperty.HasValue) this.AddAttribute (attributeName, attributeProperty.Value.ToString());
        }

        protected void AddAttributeIfDefined (DateTime? attributeProperty, String attributeName)
		{
		  AddAttributeIfDefined(attributeProperty,attributeName,null);
        }

        protected void AddAttributeIfDefined (DateTime? attributeProperty, String attributeName, String fmt)
		{
		  if (String.IsNullOrEmpty(fmt)) fmt = @"yyyy-MM-dd";
          if (attributeProperty.HasValue) this.AddAttribute(attributeName,attributeProperty.Value.ToString(fmt));
        }

        protected void AddAttributeIfDefined (TimeSpan? attributeProperty, String attributeName)
		{
          // hh\:mm\:ss: 03:00:00
          // https://msdn.microsoft.com/en-us/library/dd992632(v=vs.110).aspx
 
          if (attributeProperty.HasValue) this.AddAttribute(attributeName,attributeProperty.Value.ToString(@"hh\:mm:\:ss"));
		}
        
        protected void AddAttributeIfDefined (MailAddress attributeProperty, String attributeName)
		{
		  if (attributeProperty != null) this.AddAttribute(attributeName,attributeProperty.Address);
        }

        protected void AddAttributeIfDefined (Uri attributeProperty, String attributeName)
		{
		  if (attributeProperty != null) this.AddAttribute(attributeName,attributeProperty.OriginalString);
        }
	    
		/// <summary>
	  /// Appends control
	  /// </summary>
	  /// <param name="c">Control</param>
    
    public void AppendChildControl (Control c)
    {
      _childControlsToAppend.Add(c);
    }
    
		/// <summary>
	  /// Prepends control
	  /// </summary>
	  /// <param name="c">Control</param>
    
    public void PrependChildControl (Control c)
    {
      _childControlsToPrepend.Add(c);
    }

     /// <summary>
	  /// Render the outer wrapper starting tag
	  /// </summary>
	  /// <param name="writer">Writer.</param>
    
    protected void RenderOuterWrapStart (ref HtmlTextWriter writer)
    {
      if (WrapOptionOuter == WrapOption.na) return;              
      if (WrapOptionOuter == WrapOption.div) writer.Write(@"<div class=""{0}"">", _wrapOptionOuterClass);
    }

    /// <summary>
	  /// Render the outer wrapper ending tag
	  /// </summary>
	  /// <param name="writer">Writer.</param>
    
    protected void RenderOuterWrapEnd (ref HtmlTextWriter writer)
    {
      if (WrapOptionOuter == WrapOption.na) return;
      if (WrapOptionOuter == WrapOption.div) writer.Write(@"</div>");
    
    }

      /// <summary>
	    /// Render the specified writer.
	    /// </summary>
	    /// <param name="writer">Writer.</param>

		protected override void Render (HtmlTextWriter writer)
		{
            
    if (_progressiveEnhance)
    {
      Script s1 = new Script(_progressiveEnhanceMarkup);
      this._controlsToRenderAfter.Add(s1);
    }
    
    RenderOuterWrapStart(ref writer);    

    /* Render any controls that need to come immediately before this control*/

			foreach (Control _ctrl in _controlsToRenderBefore) {
              _ctrl.RenderControl(writer);			
            }

			// Build class attribute
      /*      
            if (!String.IsNullOrEmpty (this._class)) {
				this._class = this._classCtrl + " " + this._class;
			} else {
				this._class = this._classCtrl;
			}
      */

			/* Add global attributes to our internal list of attributes */
			
			AddAttributeIfDefined (this.ID,    @"id");
			AddAttributeIfDefined (_accessKey, @"accesskey");
			AddAttributeIfDefined (_class,     @"class");
			AddAttributeIfDefined (_title,     @"title");
			AddAttributeIfDefined (_style,     @"style");
			AddAttributeIfDefined (_hidden,    @"hidden");
			AddAttributeIfDefined (_tabIndex,  @"tabindex");
						
			/* Add attributes from our internal list to control itself */
		
			foreach (KeyValuePair <string,string> kvp in _attributes) {
				writer.AddAttribute (kvp.Key, kvp.Value);        
			}
            
            /* Clear out our internal list */

            _attributes.Clear();

            /* Render control */
            
			writer.RenderBeginTag (this._element);
			
      foreach (Control _ctrl in _childControlsToPrepend) {
              _ctrl.RenderControl(writer);			
      }
			
      base.Render (writer);

      foreach (Control _ctrl in _childControlsToAppend) {
              _ctrl.RenderControl(writer);			
      }
			
      writer.RenderEndTag();

            /* Render any controls that need to come immediately after this control */

			foreach (Control _ctrl in _controlsToRenderAfter) {
              _ctrl.RenderControl(writer);			
           
              
              }
      RenderOuterWrapEnd(ref writer);
		
      
            } 
        #endregion

	}
}

