using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;
using EAW.Web.UI.Controls;

namespace MBA.WebUI3Controls
{
	public class PasswordBox : EAW.Web.UI.Controls.Password
	{		
        // https://material.io/develop/web/components/input-controls/text-field/
		
        public PasswordBox (): base()
		{
		   this.WrapOptionOuter = WrapOption.div;
         this.WrapOptionOuterClass = @"mdc-text-field";
         this.Class                = @"mdc-text-field__input";
         this.LabelClass           = @"mdc-floating-label";
    }

		protected override void Render (HtmlTextWriter writer)
		{
            base.Render (writer);
		}

	}
}

