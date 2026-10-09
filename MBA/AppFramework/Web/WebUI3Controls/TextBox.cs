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
	public class TextBox : EAW.Web.UI.Controls.Text
	{
        // https://material.io/develop/web/components/input-controls/text-field/
		
        public TextBox (): base()
		{
		
         this.WrapOptionOuter      = WrapOption.div;
         this.WrapOptionOuterClass = @"mdc-text-field";
         this.Class                = @"mdc-text-field__input";
         this.LabelClass           = @"mdc-floating-label";
    }

		
    protected override void Render (HtmlTextWriter writer)
		{	     
      if (!String.IsNullOrEmpty (_helperText))
      {        
        ChildMarkup cm1 = new ChildMarkup();
        cm1.Markup = @"<div class=""mdc-text-field-helper-line"">"
                   + @"<div class=""mdc-text-field-helper-text"" aria-hidden=""true"">"
                   + _helperText
                   + @"</div></div>";
        this._childControlsToAppend.Add(cm1);
      }
      base.Render (writer);
		}

	}
}

