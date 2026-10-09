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
 
  /***************************************************************************
   * ServiceTrackingClass */
  /**
   * 100 = Promised SpEd Service (tracked via promised sped services)
   * 200 = Promised Non SpEd Service (tracked via order)
   * 300 = User provided
   **************************************************************************/  
  
  public enum ServiceTrackingClass
  {
       [Description("IEP / IFSP")] 
	   SPED_SERVICE     = 100
	 , [Description("Other (IHP, 504, Counseling, etc.)")]  
	   NON_SPED_SERVICE = 200
     , [Description("Any Treatment")] 
	   USER_PROVIDED    = 300
  }

  /**************************************************************************
  * SelectServiceTrackingClass */
  /**
   *
   ****************************************************************************/ 

  public class SelectServiceTrackingClass : RadioBox
  {
    
    public SelectServiceTrackingClass() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }
              
    public static int getIntValueFromEnum (ServiceTrackingClass valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (ServiceTrackingClass valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static ServiceTrackingClass getEnumValueFromString (string valueInStr)
    {
      return (ServiceTrackingClass) Enum.Parse(typeof(ServiceTrackingClass),valueInStr,true);
    }
   
    protected override void OnPreRender(EventArgs e)
    {
	  this.addCssClass("ui-spedmon-box-radio-yes-no-container");
      this.additionalCssClassNameForContainer = "modern2021";
      this.AddSelection(ServiceTrackingClass.SPED_SERVICE);
      this.AddSelection(ServiceTrackingClass.NON_SPED_SERVICE);
      base.OnPreRender(e);
    }

  }
}

