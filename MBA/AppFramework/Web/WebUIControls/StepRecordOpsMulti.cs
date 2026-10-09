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
   * StepRecordOpsMulti */
  /**
   * StepSelect provides commonly used record selection functions
   * Note: This control has unsusual markup requirments for jQuery therefore
   * it has been put into its own class that inherits from control
   ****************************************************************************/
   
  public class StepRecordOpsMulti : StepRecordViewSelect
  {
    public StepRecordOpsMulti()
      : base("Select a Record",
             "The following list shows all records that you can perform operations on.",
              RecordViewSelectPurpose.RECORD_OP_MULTIPLE)
    {
    }
        
    /*============================================================
     * Properties
     *============================================================*/   

    protected  bool    _activeFlag         = true;
    protected  bool    _cancelButton       = true;
    protected  bool    _selectAllButton    = true;
    protected  bool    _unSelectAllButton  = true;
    
    protected  string  _onSelectAllBefore        = "";
    protected  string  _onUnSelectAllBefore      = "";
    
    public bool   activeFlag        { get { return _activeFlag;        }  set { _activeFlag        = value;  }}        
    public bool   cancelButton      { get { return _cancelButton;      }  set { _cancelButton      = value;  }}
    public bool   selectAllButton   { get { return _selectAllButton;   }  set { _selectAllButton   = value;  }}
    public bool   unSelectAllButton { get { return _unSelectAllButton; }  set { _unSelectAllButton = value;  }}

    public string onSelectAllBefore     { get { return _onSelectAllBefore;    }  set { _onSelectAllBefore     = value;  }}
    public string onUnSelectAllBefore   { get { return _onUnSelectAllBefore;  }  set { _onUnSelectAllBefore   = value;  }}
         
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
      
      /*-------------------------------
       * Select/unselect all
       *------------------------------*/
     
      if (_selectAllButton)
      {
        MBA.Button butSelAll = new MBA.Button();
        butSelAll.ID         = "butSelAll";
        butSelAll.icon       = "ui-icon-circle-plus";
        butSelAll.onclick    = _onSelectAllBefore + ";$.spedmonWebUI.recMultiSelectUnselectAll ('" + this._tblIDSel + @"',1);";
        butSelAll.Controls.Add(new MBA.RawText("Select All"));
        this.Controls.Add(butSelAll);
        //butSelAll.RenderControl(writer);
      }
      
      if (_unSelectAllButton)
      {

        MBA.Button butUnSelAll = new MBA.Button();

        butUnSelAll.ID         = "butClearAll";
        butUnSelAll.icon       = "ui-icon-circle-minus";
        butUnSelAll.onclick    = _onUnSelectAllBefore + ";$.spedmonWebUI.recMultiSelectUnselectAll ('" + this._tblIDSel + @"',0);";
        butUnSelAll.Controls.Add(new MBA.RawText("Clear All Selections"));
        this.Controls.Add(butUnSelAll);
        //butUnSelAll.RenderControl(writer);
      }

      foreach(RecordOpButton b in recOpButtons)
      {
        b.tblIDSel       = this._tblIDSel;
        b.statusIDSel    = this._statusIDSel;
        b.recIDPos       = this._recIDPos;
        b.fnTableRefresh = "function(){" + _onactive + "}";        
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

