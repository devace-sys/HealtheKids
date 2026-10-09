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
using System.Text.RegularExpressions;

namespace MBA
{  
  /**************************************************************************
   * RequestServiceAuthorizationFrom */
  /**
   ****************************************************************************/
  
  public enum RequestServiceAuthorizationFrom
  {      
      PARENTS            = 10
    , ORP_PROFESSIONAL  = 20
    , UNKNOWN           = 99
  }
  
  /**************************************************************************
  * SelectRequestServiceAuthorizationFrom */
  /**
   *
   ****************************************************************************/ 

  public class SelectRequestServiceAuthorizationFrom:RadioBox
  {
    
    public SelectRequestServiceAuthorizationFrom () 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }
    
	          
    public static int getIntValueFromEnum (RequestServiceAuthorizationFrom valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (RequestServiceAuthorizationFrom valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static RequestServiceAuthorizationFrom getEmumValueFromString (string valueInStr)
    {
      return (RequestServiceAuthorizationFrom) Enum.Parse(typeof(RequestServiceAuthorizationFrom),valueInStr,true);
    }
   

    protected override void OnPreRender(EventArgs e)
    {
      this.AddSelection("Parents",        ((int) RequestServiceAuthorizationFrom.PARENTS).ToString());
      this.AddSelection("ORP Professional",      ((int) RequestServiceAuthorizationFrom.ORP_PROFESSIONAL).ToString());
      base.OnPreRender(e);
    }

  }
}

