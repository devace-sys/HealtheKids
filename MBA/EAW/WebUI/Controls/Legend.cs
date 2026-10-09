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
	/// Legend.  For use in fieldset and other.
	/// </summary>

	public class Legend : ElementBase
	{

		public Legend () : this(null)
		{
		}
		
		public Legend (string legendText) : base("legend",@"legend")
		{
          this._legendText = legendText;
		}

		private string _legendText  = null;
        
		protected override void OnPreRender (EventArgs e)
		{
		  if (!String.IsNullOrEmpty (_legendText)) {
		    this.Controls.Add (new System.Web.UI.LiteralControl (_legendText));
		  }
	      base.OnPreRender (e);
		}
		
        protected override void Render (HtmlTextWriter writer)
		{		
		  base.Render (writer);
		}
	}
}