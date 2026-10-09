using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{
    /// <summary>
	/// Script element
	/// </summary>
	/// <description>
	/// <a href="https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script">Further Reading</a>
	/// </description>
	
	public class Script : ElementBase
	{
    
		public Script() : base("script",@"script")
		{
		}
    public Script(ChildMarkup cm) : base("script",@"script") 
    {
      this.Controls.Add(cm);
    }
		protected override void Render (HtmlTextWriter writer)
		{
			this.AddAttribute("type", @"text/javascript");

			base.Render (writer);
		}
	}
}

