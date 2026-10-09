using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using SmartsheetData;
using MBA;
using Smartsheet.Api;
using Smartsheet.Api.Models;
using Smartsheet.Api.OAuth;

/***************************************************************************
 * sbs_all_smartsheet */
/**
 * Data from smartsheet
 ***************************************************************************/

namespace Spedmon
{
  public class sbs_all_smartsheet : WebUI
  {
    
    public sbs_all_smartsheet(): base("smart_sheet","Smartsheet","","",Constants.ROLE_SBS_STAFF){}
    
    public static string smartSheetTableStr = "";
    
    
    protected void Page_Load(object sender, EventArgs e)
    {   
    
      /*###########################################################################
        # Fetch parameters
        ###########################################################################*/    
     
      string ssDataClass = MBA.HttpApplication.getParameter(SSDataCommon.PARM_SS_DATA_CLASS);      
      string ssDataUid   = MBA.HttpApplication.getParameter(SSDataCommon.PARM_SS_DATA_UID);
      
      /*###########################################################################
        # Convert UID to long if possible
        ###########################################################################*/    

      long ssDataUidVal = 0;
      if (!long.TryParse(ssDataUid,out ssDataUidVal)) return;
      
      /*###########################################################################
        # Output sheet
        ###########################################################################*/    

      if (ssDataClass == SSDataCommon.VALUE_SS_DATA_CLASS_SHEET)
      {
        smartSheetTableStr = SSDataSheet.ViewAsHtmlTable(ssDataUidVal);
      }        

      /*###########################################################################
        # Output report
        ###########################################################################*/    

      else if (ssDataClass == SSDataCommon.VALUE_SS_DATA_CLASS_REPORT)
      {      
        smartSheetTableStr = SSDataReport.ViewAsHtmlTable(ssDataUidVal);
      }
      
    }
  }
}


