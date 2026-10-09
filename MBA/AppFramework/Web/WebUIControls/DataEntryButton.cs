using System;
using System.Web.UI;
using System.Text;
using System.ComponentModel; 

namespace MBA
{
	/**************************************************************************
     * DataEntryButton */
	/**
     * 
     **************************************************************************/
	public class DataEntryButton : DataEntryButtonBase
	{
		public DataEntryButton()
        {

        }
		
		protected string _onclick = String.Empty;

		public string onclick
        {
	        get { return _onclick; }
			set { _onclick = value; }
        }
		
		protected override void Render(HtmlTextWriter writer)
        {
		    base.Render(writer);
		    writer.Write ("<script>$(document).ready(function(){");
			writer.Write ("$('#" + this.ID + "').click(function(e){" + _onclick + "});");
			writer.Write ("})</script>");
		
		}
    }
}
