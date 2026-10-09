using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using EAW.Web.UI;
using EAW.Web.UI.Controls.Base;
using EAW.Web.UI.Controls.Attributes;

namespace EAW.Web.UI.Controls.Base
{
    /// <summary>
	/// Input base.
	/// </summary>
    public abstract class InputBase : FieldBase
	{

		/// <summary>
		/// Initializes a new instance of the <see cref="EAW.Web.UI.InputBase"/> class.
		/// </summary>
		/// <param name="type">Type.</param>
		/// <param name="classCtrl">Class ctrl.</param>

		/// https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input

        public InputBase (InputType type, string classCtrl) : base("input", "inputbase" + " " + classCtrl)
		{
			_type = type;
		}

		private   AutoCompleteOption _autoCompleteOption = AutoCompleteOption.na;        
        protected InputType             _type           = InputType.text;
	    private   string                _list             = @"";
        protected string                _valueStr         = @"";
      
        /// <summary>
		/// Should autocomplete be used
		/// </summary>
		/// <value>The auto complete.</value>
        
        [Description("Gets or sets autocomplete option"), Category("HTML Attribute"), DefaultValue(null)]         
        public AutoCompleteOption Autocomplete { get { return _autoCompleteOption; } set { _autoCompleteOption = value; }}
        
        /// <summary>
		/// Gets or sets the input type.
		/// </summary>
		/// <value>The input type</value>
        
        [Description("Gets or sets input type"), Category("HTML Attribute"), DefaultValue(null)] 
		public InputType Type { get { return _type; } set { _type = value; } }
        
        /// <summary>
        ///  Data list to use.  This attribute is ignored when the type attribute's value is hidden, checkbox, radio, file, or a button type.
        /// </summary>
        /// <value>The id of the data list</value>        
        
        [Description("Gets or sets datalist to use"), Category("HTML Attribute"), DefaultValue(null)] 
        public String List { get { return _list; } set { _list = value; } }
		
        /// <summary>
        /// Render the specified writer.
        /// </summary>
        /// <param name="writer">Writer.</param>
        
        protected override void Render (HtmlTextWriter writer)
		{			           
            /* Add attributes to our internal list */ 
            
            this.AddAttribute ("type", Enum.GetName(typeof(InputType), _type));
            if (_autoCompleteOption != AutoCompleteOption.na) this.AddAttribute ("autocomplete", Enum.GetName(typeof(AutoCompleteOption), _autoCompleteOption));
			this.AddAttributeIfDefined(_list,     @"list");
            this.AddAttributeIfDefined(_valueStr, @"value");
            base.Render (writer);
		}

	}
}

