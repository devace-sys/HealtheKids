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
   * StepViewWithRecordOps */
  /**
   * StepViewOrSelect provides commonly used data view options and record select
   * options.
   *
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/

  public class StepViewWithRecordOps : StepRecordViewSelect
  {
    public StepViewWithRecordOps()
      : base("Records Available",
             "Select one of the following records by clicking anywhere on it's row.",
             RecordViewSelectPurpose.RECORD_VIEW_WITH_RECORD_OP)
    {
    }
    
    protected  bool    _activeFlag   = true;
    protected  bool    _cancelButton = true;
    
    protected string  _labelHTM = @"View Entire List of Records (HTML)";
    protected string  _labelXLS = @"Download Entire List of Records (Excel)";
    protected string  _labelPDF = @"Download Entire List of Records (PDF)";
    
    protected bool _displayGenHTM = true;
    protected bool _displayGenPDF = false;
    protected bool _displayGenXLS = true;
    
    public bool   activeFlag     { get { return _activeFlag;     }  set { _activeFlag    = value;  }}        
    public bool   cancelButton   { get { return _cancelButton;   }  set { _cancelButton  = value;  }}
    public string labelHTM       { get { return _labelHTM;       }  set { _labelHTM      = value;  }}
    public string labelXLS       { get { return _labelXLS;       }  set { _labelXLS      = value;  }}
    public string labelPDF       { get { return _labelPDF;       }  set { _labelPDF      = value;  }}
    public bool   displayGenHTM  { get { return _displayGenHTM;  }  set { _displayGenHTM = value;  }}
    public bool   displayGenPDF  { get { return _displayGenPDF;  }  set { _displayGenPDF = value;  }}
    public bool   displayGenXLS  { get { return _displayGenXLS;  }  set { _displayGenXLS = value;  }}
    
    
    protected override void render(ref HtmlTextWriter writer)
    {
    
      /*-------------------------------
       * Add active flag
       *------------------------------*/      
      
      if (_activeFlag)
      {
        HiddenInput inputActive = new HiddenInput();
      
        inputActive.ID    = "active";
        inputActive.name  = "active";
        inputActive.title = "active";
        inputActive.value = "1";
        base.Controls.Add(inputActive);
      }
      
      List<RecordOpButton> recOpButtons = new List<RecordOpButton>();
                                     
      /*-------------------------------
       * Find all op buttons added by 
       * user and store them
       *------------------------------*/      
                
      foreach (Control c in this.Controls)
      {
        if ((c.GetType()) == typeof(RecordOpButton))
        {          
          RecordOpButton b = (RecordOpButton) c;
          recOpButtons.Add(b);          
        }
      }

      /*-------------------------------
       * Temporarily remove op buttons
       *------------------------------*/      
      
      foreach (Control c in recOpButtons)
        this.Controls.Remove(c);
                        
      /*-------------------------------
       * Create preview.
       * We do this because we need
       * some values to be defined
       *------------------------------*/

      base.render(ref writer);
                  
      /*-------------------------------
       * Report output options
       *------------------------------*/

      if (_displayGenHTM) 
      {
        MBA.Button genHTML = new MBA.Button();
        genHTML.ID = "genhtml";
        genHTML.icon = "ui-icon-print";
        genHTML.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_HTML.ToString() + "," + Constants.REPT_DELIVER_WINDOW.ToString() + ")";
        genHTML.Controls.Add(new MBA.RawText(this._labelHTM));
        this.Controls.Add(genHTML);
      }

      
      if (_displayGenXLS)
      {      
        MBA.Button genXLS = new MBA.Button();
        genXLS.ID = "genxls";
        genXLS.icon = "ui-icon-calculator";
        genXLS.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_XLS.ToString() + "," + Constants.REPT_DELIVER_DYNAMIC_FILE.ToString() + ")";
        genXLS.Controls.Add(new MBA.RawText(this._labelXLS));
        this.Controls.Add(genXLS);      
      }
      
      /*-------------------------------
       * Render rec ops buttons
       *------------------------------*/
      
      foreach(RecordOpButton b in recOpButtons)
      {
        b.tblIDSel    = this._tblIDSel;
        b.statusIDSel = this._statusIDSel;
        b.recIDPos    = this._recIDPos;
        this.Controls.Add(b);
      }
      
      /*-------------------------------
       * Add cancel op button
       *------------------------------*/
      
      if (_cancelButton)
      {
        MBA.Button canSel = new MBA.Button();
        canSel.ID         = "canSel";
        canSel.icon       = "ui-icon-arrowreturnthick-1-w";
        canSel.onclick    = "$.spedmonWebUI.gotoMenuLink('homePageLink')";
        canSel.Controls.Add(new MBA.RawText("Cancel and Exit"));
        this.Controls.Add(canSel);
      }
      

    }
  }


}

