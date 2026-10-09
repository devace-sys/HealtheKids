using System;
using System.ComponentModel;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace MBA
{
  /**************************************************************************
     SelectReportFileType
   ****************************************************************************/ 

  public class SelectReportFileType:RadioBox
  {
    
    /**************************************************************************
     * ReportFileType 
     ****************************************************************************/
  
    public SelectReportFileType():base() 
    {        
      this.firedataselected = true;
      this.labelIsSpan      = false;
      this.noClear          = false;	       
    }

    public enum ReportFileTypeOptions  
    {            
        HTML = Constants.REPT_FORMAT_HTML_REPORT // 6
      , XLS  = Constants.REPT_FORMAT_XLS_REPORT  // 7
      , PDF  = Constants.REPT_FORMAT_PDF_REPORT  // 8
    }

    public static String[] ReportFileTypeLabels = new String[3]
    {
        "Excel"
      , "HTML"
      , "PDF"
    };

    protected override void OnPreRender(EventArgs e)
    {
      this.AddSelection(ReportFileTypeLabels[0], ( (int) ReportFileTypeOptions.XLS).ToString());
      this.AddSelection(ReportFileTypeLabels[1], ( (int) ReportFileTypeOptions.HTML).ToString());
      this.AddSelection(ReportFileTypeLabels[2], ( (int) ReportFileTypeOptions.PDF).ToString());
      base.OnPreRender(e);
    }
  }

}
