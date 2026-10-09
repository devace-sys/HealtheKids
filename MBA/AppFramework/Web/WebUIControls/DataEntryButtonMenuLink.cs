using System;
using System.Web.UI;
using System.Text;
using System.ComponentModel; 

namespace MBA
{
	/**************************************************************************
     * DataEntryButtonMenuLink */
	/**
     * 
     **************************************************************************/
	public class DataEntryButtonMenuLink : DataEntryButtonBase
	{
		public DataEntryButtonMenuLink()
        {

        }		
		
		protected string           _menuitemid                     = String.Empty;
		protected MenuItemLinkType _menuitemlinktype               = MenuItemLinkType.URL;
		protected bool             _noLinkInMenuThenRemoveParentLi = false;
		public string menuitemid { 
			get { return _menuitemid;}       
			set { _menuitemid      = value; }
		}    
		public MenuItemLinkType menuitemlinktype {
			get { return _menuitemlinktype;}
			set { _menuitemlinktype = value;}
        }
		public bool noLinkInMenuThenRemoveParentLi { 
			get {return _noLinkInMenuThenRemoveParentLi;} 
			set { _noLinkInMenuThenRemoveParentLi = value;}
		}

		protected override void Render(HtmlTextWriter writer)
        {
          string _options = "{"  
                        + "menuitemid:'"      + _menuitemid                          + "',"
                        + "menuitemlinktype:" + _menuitemlinktype.GetValueAsString() + ","
						+ "useJqueryUI:false,"
                        + "noLinkInMenuThenRemoveParentLi:" + Util.netBoolToJSBool(_noLinkInMenuThenRemoveParentLi) 
                        + "}";	
          base.Render(writer);
          writer.Write ("<script>$(document).ready(function(){ $('#" + this.ID + "').spedmonButtonMenuItemLink(" + _options + ");})</script>");

		}
    }
}
