using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{

	public class FieldSet : ElementBase
	{

        
        public FieldSet () : base("fieldset",@"fieldset")
		{
        }

        private   bool?      _disabled  = null;
        private   string     _formName  = null;

        [Description("All elements in this fieldset are disabled"), Category("HTML attribute"), DefaultValue(null)]
		public bool? Disabled { get { return _disabled; } set { _disabled = value; } }

        [Description("The form this belongs to"), Category("HTML attribute"), DefaultValue(null)]
		public string FormName { get { return _formName; } set { _formName = value; } }


        protected override void Render (HtmlTextWriter writer)
		{          
           AddAttributeIfDefined (_disabled, @"disabled");
           AddAttributeIfDefined (_formName, @"formname");
           base.Render (writer);
		}
	}
}