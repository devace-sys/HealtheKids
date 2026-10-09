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
   * StepView */
  /**
   * StepView provides commonly used data view options
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/

  public class StepView : StepRecordViewSelect
  {
    public StepView()
      : base("Preview Data and Select Output Format",
             "The following is a preview of the data that will be in your view.  The actual output will not look like this preview.",
             RecordViewSelectPurpose.RECORD_VIEW)
    {
    }
    
    protected bool _displayGenHTM = true;
    protected bool _displayGenPDF = false;
    protected bool _displayGenXLS = true;
    
    public bool displayGenHTM  { get { return _displayGenHTM;  }  set { _displayGenHTM = value; } }
    public bool displayGenPDF  { get { return _displayGenPDF;  }  set { _displayGenPDF = value; } }
    public bool displayGenXLS  { get { return _displayGenXLS;  }  set { _displayGenXLS = value; } }
    
    protected override void render(ref HtmlTextWriter writer)
    {
      /*-------------------------------
       * Create preview
       *------------------------------*/

      base.render(ref writer);

      /*-------------------------------
       * Report output options
       *------------------------------*/

      MBA.Button genHTML = new MBA.Button();
      genHTML.ID = "genhtml";
      genHTML.icon = "ui-icon-print";
      genHTML.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_HTML.ToString() + "," + Constants.REPT_DELIVER_WINDOW.ToString() + ")";
      genHTML.Controls.Add(new MBA.RawText("View Data on Screen (HTML)"));
      
      if (_displayGenHTM) 
        genHTML.RenderControl(writer);
      
      /*
      MBA.Button genPDF = new MBA.Button();
      genPDF.ID = "genpdf";
      genPDF.icon = "ui-icon-document";
      genPDF.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_PDF.ToString() + "," + Constants.REPT_DELIVER_DYNAMIC_FILE.ToString() + ")";
      genPDF.Controls.Add(new MBA.RawText("Download Data and Print (PDF)"));
      
      if (_displayGenPDF)
        genPDF.RenderControl(writer);
      */
      
      MBA.Button genXLS = new MBA.Button();
      genXLS.ID = "genxls";
      genXLS.icon = "ui-icon-calculator";
      genXLS.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_XLS.ToString() + "," + Constants.REPT_DELIVER_DYNAMIC_FILE.ToString() + ")";
      genXLS.Controls.Add(new MBA.RawText("Download Data (Excel)"));
      
      if (_displayGenXLS)
        genXLS.RenderControl(writer);
      
      /*
      MBA.Button cancelPreview = new MBA.Button();
      cancelPreview.ID = "cancelpreview";
      cancelPreview.icon = "ui-icon-closethick";
      cancelPreview.onclick = "$('#validatelist').click();";
      cancelPreview.Controls.Add(new MBA.RawText("Cancel Preview"));
      cancelPreview.RenderControl(writer);
      */
    }
  }


}

