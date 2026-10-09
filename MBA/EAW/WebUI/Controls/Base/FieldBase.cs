using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls.Base
{

	/// <summary>
	/// Base class for form fields
	/// </summary>

	public abstract class FieldBase : ElementBase
	{

		public FieldBase (string element, string classCtrl) : base(element, @"fieldbase" + " " + classCtrl)
		{
		}

		private bool?         _autoFocus    = null;
    protected String      _helperText   = null;
    private String        _labelText    = null;
    private String        _labelClass   = null;
    private String        _name         = null;
		private String        _placeholder  = null;
		private bool?         _readonly     = null;
		private bool?         _required     = null;
       
		/// <summary>
		/// Focus on this field first in a form?
		/// </summary>
		/// <value>Autofocus</value>

    [Description("Gets or sets autofocus state"), Category("HTML Attribute"), DefaultValue(null)] 
		public bool? AutoFocus { get { return _autoFocus; } set { _autoFocus = value; } }

    
    /// <summary>
		/// Gets or sets the helper text.
		/// </summary>
		/// <value>String</value>
    [Description("Inline help text."), Category("Render Option"), DefaultValue(null)] 
    public string HelperText { get { return _helperText; } set {_helperText = value;}}

    /// <summary>
		/// Gets or sets the label.
		/// </summary>
		/// <value>The label.</value>
        [Description("The label.  Used in HTML forms."), Category("Render Option"), DefaultValue(null)] 
        public string LabelText { get { return _labelText; } set {_labelText = value;}}

    /// <summary>
		/// Gets or sets the label CSS class
		/// </summary>
		/// <value>The label CSS class.</value>
        [Description("The label CSS Class.  Used in HTML forms."), Category("Render Option"), DefaultValue(null)] 
        public string LabelClass { get { return _labelClass; } set {_labelClass = value;}}

        /// <summary>
		/// Gets or sets the name of the control (name/value pair).
		/// </summary>
		/// <value>The name.</value>
		[Description("Gets or sets parameter name"), Category("HTML Attribute"), DefaultValue(null)] 
        public string Name { get { return _name; } set { _name = value; } }

		/// <summary>
		/// Gets or sets the text that describes what you expect the user to provide
		/// </summary>
		/// <value>The placeholder.</value>
    [Description("Gets or sets placeholder text"), Category("HTML Attribute"), DefaultValue(null)] 
		public string Placeholder { get { return _placeholder; } set { _placeholder = value; } }

		/// <summary>
		/// Is this a read only field?
		/// </summary>
		/// <value>The read only.</value>
    [Description("Gets or sets readonly state"), Category("HTML Attribute"), DefaultValue(null)] 
		public bool? ReadOnly { get { return _readonly; } set { _readonly = value; } }

		/// <summary>
		/// Is this a required field
		/// </summary>
		/// <value>The required.</value>
    [Description("Gets or sets required state"), Category("HTML Attribute"), DefaultValue(null)] 
		public bool? Required { get { return _required; } set { _required = value; } }

		protected override void Render (HtmlTextWriter writer)
		{		
			/* Add attributes to our internal list */
            
      AddAttributeIfDefined(_autoFocus, @"autofocus");
            AddAttributeIfDefined (_name,        @"name");
			AddAttributeIfDefined (_placeholder, @"placeholder");
			AddAttributeIfDefined (_readonly,    @"readonly");
			AddAttributeIfDefined (_required,    @"required");
			
            /* If label text has been provided then add a label control */

            if (!String.IsNullOrEmpty (_labelText)) {  
              Label _ctrlLabel = new Label(_labelText,this.ID);
              _ctrlLabel.ID = this.ID + @"_label";
              _ctrlLabel.Class = _labelClass;
              this._controlsToRenderBefore.Add(_ctrlLabel);
            }

		   base.Render (writer);
		}

	}
}

