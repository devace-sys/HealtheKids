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
   * ServiceSubTypeIndividualOrGroup */
  /**
   ****************************************************************************/
  public enum ServiceSubTypeIndividualOrGroup
  {      
      [Description("Individual Session")]
	    INDIVIDUAL = 2000
      
	  , [Description("Group Session")]
	    GROUP = 2001

   , [Description("Unknown")]
     UNKNOWN = 0
  }
  
  /**************************************************************************
  * SelectRequestServiceAuthorizationMethod */
  /**
   *
   ****************************************************************************/ 

  public class SelectServiceSubTypeIndividualOrGroup:RadioBox
  {
    
    public SelectServiceSubTypeIndividualOrGroup () 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }
              
    public static int getIntValueFromEnum (ServiceSubTypeIndividualOrGroup valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (ServiceSubTypeIndividualOrGroup valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static ServiceSubTypeIndividualOrGroup getEmumValueFromString (string valueInStr)
    {
      return (ServiceSubTypeIndividualOrGroup) Enum.Parse(typeof(ServiceSubTypeIndividualOrGroup),valueInStr,true);
    }
   
    protected override void OnPreRender(EventArgs e)
    {
      this.AddSelection(ServiceSubTypeIndividualOrGroup.INDIVIDUAL);
      this.AddSelection(ServiceSubTypeIndividualOrGroup.GROUP);
      base.OnPreRender(e);
    }

  }
}

