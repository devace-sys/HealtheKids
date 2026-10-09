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
   * SessionAttendanceStatus */
  /**
   ****************************************************************************/

  public enum SessionAttendanceStatus
  {      
      [Description("Regular Session")]
      REGULAR_SESSION = 0
       
    , [Description("Patient Absent")] 
      PATIENT_ABSENT  = 1

    , [Description("Practitioner Absent")]  
      PRACTITIONER_ABSENT = 2

    , [Description("Make Up Session")]   
      MAKEUP_SESSION = 4
  }
  
  /**************************************************************************
  * SelectSessionAttendanceStatus */
  /**
   *
   ****************************************************************************/ 

  public class SelectSessionAttendanceStatus : RadioBox
  {
    
    public SelectSessionAttendanceStatus() 
    {    
      this.firedataselected = true;      
      this.labelIsSpan      = false;
      this.noClear          = false;
      this._onSelectValue   = @"function(oldval,newval){return true;}";
    }
    
	          
    public static int getIntValueFromEnum (SessionAttendanceStatus valueInEnum)
    {
      return (int) valueInEnum;
    }
    
    public static string getStringValueFromEnum (SessionAttendanceStatus valueInEnum)
    {
      return getIntValueFromEnum(valueInEnum).ToString();      
    }
   
    public static SessionAttendanceStatus getEnumValueFromString (string valueInStr)
    {
      return (SessionAttendanceStatus) Enum.Parse(typeof(SessionAttendanceStatus),valueInStr,true);
    }
   
    protected override void OnPreRender(EventArgs e)
    {
      this.AddSelection(SessionAttendanceStatus.REGULAR_SESSION);
      this.AddSelection(SessionAttendanceStatus.PATIENT_ABSENT);
      this.AddSelection(SessionAttendanceStatus.PRACTITIONER_ABSENT);
      this.AddSelection(SessionAttendanceStatus.MAKEUP_SESSION);
      base.OnPreRender(e);
    }

  }
}

