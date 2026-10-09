using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text;
using System.Text.RegularExpressions;

namespace MBA
{

  /**************************************************************************
   * ButtonConfirm */
  /**
   * Button with confirm dialog when clicked
   * 
   * @param  onclick         action to take when button is clicked
   * @param  icon            jquery ui icon (ui-icon-x)
   ****************************************************************************/

  public class ButtonConfirm : Button
  {
    public ButtonConfirm() : base() { }
    
    protected string _confirmTitle   = @"Please confirm your selection";
    protected string _confirmMessage = @"Are you sure?";
    protected string _confirmYesFn   = "";
    protected string _clickHdlr      = "";    
          
    /***************************************************************************
     * confirmTitle */
    /**
     * Title of confirmation dialog
     ***************************************************************************/   
    
    public string confirmTitle 
    {
      get { return _confirmTitle; }
      set { if ( !String.IsNullOrEmpty (value) ) _confirmTitle = value; }      
    }

    /***************************************************************************
     * confirmMessage */
    /**
     * Message displayed in confirmation dialog above yes/no
     ***************************************************************************/   
    
    public string confirmMessage
    {
      get { return _confirmMessage;}
      set { if (!String.IsNullOrEmpty(value)) _confirmMessage = value; }
    }
    
    /***************************************************************************
     * onclick */
    /**
     * Overrides base onclick.  Function to execute when Yes is clicked.
     ***************************************************************************/   

    public new string onclick
    {
      get { return (string) this.findAttribute("click"); }
      
      set { 

        if ( String.IsNullOrEmpty( value ) ) return;
        
        _confirmYesFn = "function(){" + value + "}";
   
        _clickHdlr    = String.Format( @"$.spedmonWebUI.dialogConfirm('{0}', '{1}', {2}, null)" 
                                        , _confirmTitle
                                        , _confirmMessage
                                        , _confirmYesFn);

        this.addAttribute("click", _clickHdlr, ATTR_JS_PAGE_LOAD_EVENT_ASSIGN); 
      }
    }
    
  }
}

