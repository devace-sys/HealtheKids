using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{

	public class Button : ElementBase
	{

		public Button () : this(ButtonType.button)
		{
		}

		public Button (ButtonType type) : base("button","button")
		{
		  this._type  = type;
		}

		private string _name  = null;
		private ButtonType _type;
		private string _value = null;

		[Description("The name of the button.  Used in HTML forms."), Category("HTML attribute"), DefaultValue("")]
		public string Name { get { return _name; } set { _name = value; } }

		[Description("The button type"), Category("HTML attribute"), DefaultValue(InputType.text)]
		public ButtonType Type { get { return _type; } set { _type = value; } }

		[Description("The value of the button submitted.  Used in HTML forms."), Category("HTML attribute"), DefaultValue(null)]
		public string Value { get { return _value; } set { _value = value; } }

    protected override void Render (HtmlTextWriter writer)
		{
			this.AddAttribute ("type", Enum.GetName(typeof(ButtonType),this._type));

			if (!String.IsNullOrEmpty (_name))  this.AddAttribute ("name",  _name);
			if (!String.IsNullOrEmpty (_value)) this.AddAttribute ("value", _value);		


			base.Render (writer);
		}

	}
}

