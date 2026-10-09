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
   * StepRecordOps */
  /**
   * StepSelect provides commonly used record selection functions
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/
   
  public class StepRecordOps : StepRecordViewSelect
  {
    public StepRecordOps()
      : base("Select a Record",
             "The following list shows all records that you can perform operations on.",
              RecordViewSelectPurpose.RECORD_OP)
    {
    }
        
    /*============================================================
     * Properties
     *============================================================*/   

    protected  bool    _activeFlag   = true;
    protected  bool    _cancelButton = true;
    
    public bool   activeFlag        { get { return _activeFlag;        }  set { _activeFlag        = value;  }}        
    public bool   cancelButton      { get { return _cancelButton;      }  set { _cancelButton      = value;  }}

   /*============================================================
    * Methods
    *============================================================*/   

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
       * Render buttons
       *------------------------------*/
      
      foreach(RecordOpButton b in recOpButtons)
      {
        b.tblIDSel    = this._tblIDSel;
        b.statusIDSel = this._statusIDSel;
        b.recIDPos    = this._recIDPos;
        this.Controls.Add(b);
        //b.RenderControl(writer);
      }
      
      /*-------------------------------
       * Add cancel button
       *------------------------------*/
      
      if (_cancelButton)
      {
        MBA.Button canSel = new MBA.Button();
        canSel.ID         = "canSel";
        canSel.icon       = "ui-icon-arrowreturnthick-1-w";
        canSel.onclick    = "$.spedmonWebUI.gotoMenuLink('homePageLink')";
        canSel.Controls.Add(new MBA.RawText("Cancel and Exit"));
        this.Controls.Add(canSel);
        //canSel.RenderControl(writer);
      }
                                    
    }
  }
}

