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
 * sbs_all_smartsheets */
/**
 * help page
***************************************************************************/

namespace Spedmon
{
  public class sbs_all_smartsheets : WebUI
  {
    
    public sbs_all_smartsheets(): base("smart_sheets","Smartsheets","","",Constants.ROLE_SBS_STAFF){}
      
    public string smartSheetsSheetListStr  = "";
    public string smartSheetsReportListStr = "";        
    
    protected void Page_Load(object sender, EventArgs e)
    {   
      smartSheetsSheetListStr  = SSDataSheets.ViewAllAsHTMLTable();
      smartSheetsReportListStr = SSDataReports.ViewAllAsHTMLTable();      
      ;
    }
  }
}


