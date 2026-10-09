using System;
using System.Web;
using System.Web.UI;
using System.ComponentModel;

using EAW.Web.UI;
using EAW.Web.UI.Controls.Attributes;
using EAW.Web.UI.Controls.Base;

namespace EAW.Web.UI.Controls
{

	public class ChildMarkup : ControlBase
	{

		protected String _markup = @"";
    
   public String Markup { get { return _markup; } set { _markup = value; } }
    
    public ChildMarkup (): this("")
    {
    }
    
    public ChildMarkup(string markup) 
		{
		  this._markup = markup;
    }				
		
		protected override void Render (HtmlTextWriter writer)
		{		
		  
      writer.Write(_markup);
      base.Render (writer);
		}
	}
}

