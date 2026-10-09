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
   * StepRecordsAddNewEditDeleteView */
  /**
   * All in one
   ****************************************************************************/

  public class StepRecordsAddNewEditDeleteView : StepRecordViewSelect
  {
    public StepRecordsAddNewEditDeleteView (): base (  "Select a Record"
                                                      , "Click add new to add to this list."
                                                      , RecordViewSelectPurpose.RECORD_ADD_NEW_EDIT_DELETE_VIEW)
    {
    }
    
    protected  bool     _displayGenHTM       = true;
    protected  bool     _displayGenPDF       = false;
    protected  bool     _displayGenXLS       = true;    
    protected  string   _displayGenXLSUrlFn  = null;    
    
    protected  string   _addNewURL;
    protected  string   _editURL;
    protected  string   _deleteURL;
    protected  string   _undeleteURL;
    
    protected  string   _actionFnAddNew      = "null";
    protected  string   _actionFnEdit        = "null";
    protected  string   _actionFnDelete      = "null";
    protected  string   _actionFnUndelete    = "null";        
    
    protected  string   _addParmsToActionURLFnAddNew     = "null";
    protected  string   _addParmsToActionURLFnEdit       = "null";
    protected  string   _addParmsToActionURLFnDelete     = "null";
    protected  string   _addParmsToActionURLFnUndelete   = "null";
    
    protected  bool     _addNewIsSubPage     = false;
    protected  bool     _editIsSubPage       = false;
    
    protected  bool     _hasAddNew           = true;
    protected  bool     _hasEdit             = true;
    protected  bool     _hasDelete           = true;
    protected  bool     _hasUndelete         = false;     
    protected  bool     _activeFlag          = true;
    protected  bool     _cancelButton        = true;
        
    protected  string   _addNewButtonLabel   = @"Add New Record";
    protected  string   _editButtonLabel     = @"Review/Edit Selected Record";
    protected  string   _deleteButtonLabel   = @"Delete/Deactivate Selected Record";
    protected  string   _unDeleteButtonLabel = @"Undelete/Reactivate Selected Record";

    public bool   displayGenHTM       { get { return _displayGenHTM;    } set { _displayGenHTM = value;  }}
    public bool   displayGenPDF       { get { return _displayGenPDF;    }  set { _displayGenPDF = value; } }
    public bool   displayGenXLS       { get { return _displayGenXLS;    } set { _displayGenXLS = value;  }}     
    public string displayGenXLSUrlFn  { get { return _displayGenXLSUrlFn; } set { _displayGenXLSUrlFn = value;  }}     
    
    public string addNewURL           { get { return _addNewURL;        } set { _addNewURL     = value;  }}
    public string editURL             { get { return _editURL;          } set { _editURL       = value;  }}
    public string deleteURL           { get { return _deleteURL;        } set { _deleteURL     = value;  }}
    public string unDeleteURL         { get { return _undeleteURL;      } set { _undeleteURL   = value;  }}

  	
  	public string addParmsToActionURLFnAddNew { get { return _addParmsToActionURLFnAddNew;   } set { if (!Util.IsNullOrEmpty(value)) _addParmsToActionURLFnAddNew = value ; else _addParmsToActionURLFnAddNew = "null";}}
    public string addParmsToActionURLFnEdit   { get { return _addParmsToActionURLFnEdit;     } set { if (!Util.IsNullOrEmpty(value)) _addParmsToActionURLFnEdit = value ; else _addParmsToActionURLFnEdit = "null";}}
           
    public string actionFnAddNew      { get { return _actionFnAddNew;   } set { if (!Util.IsNullOrEmpty(value)) _actionFnAddNew = "function(recID, saveType, actionURL){" + value + "}"; else _actionFnAddNew = "null";}}
    public string actionFnEdit        { get { return _actionFnEdit;     } set { if (!Util.IsNullOrEmpty(value)) _actionFnEdit = "function(recID, saveType, actionURL){" + value + "}"; else _actionFnEdit = "null";}}
    public string actionFnDelete      { get { return _actionFnDelete;   } set { if (!Util.IsNullOrEmpty(value)) _actionFnDelete = "function(recID, saveType, actionURL){" + value + "}"; else _actionFnDelete = "null";}}
    public string actionFnUnDelete    { get { return _actionFnUndelete; } set { if (!Util.IsNullOrEmpty(value)) _actionFnUndelete = "function(recID, saveType, actionURL){" + value + "}"; else _actionFnUndelete = "null";}} 

    public bool   addNewIsSubPage     { get { return _addNewIsSubPage;  } set { _addNewIsSubPage = value; }}         
    public bool   editIsSubPage       { get { return _editIsSubPage;    } set { _editIsSubPage   = value; }}     
    
    public bool   hasAddNew           { get { return _hasAddNew;           } set { _hasAddNew     = value; } }
    public bool   hasEdit             { get { return _hasEdit;             } set { _hasEdit       = value; } }
    public bool   hasDelete           { get { return _hasDelete;           } set { _hasDelete     = value; } }
    public bool   hasUndelete         { get { return _hasUndelete;         } set { _hasUndelete   = value; } }
        
    
    public bool   activeFlag        { get { return _activeFlag;        }  set { _activeFlag        = value;  }}        
    public bool   cancelButton      { get { return _cancelButton;      }  set { _cancelButton      = value;  }}

    public string addNewButtonLabel   { get { return _addNewButtonLabel;   } set { _addNewButtonLabel   = value; } }
    public string editButtonLabel     { get { return _editButtonLabel;     } set { _editButtonLabel     = value; } }
    public string deleteButtonLabel   { get { return _deleteButtonLabel;   } set { _deleteButtonLabel   = value; } }
    public string unDeleteButtonLabel { get { return _unDeleteButtonLabel; } set { _unDeleteButtonLabel = value; } }

    protected override void render(ref HtmlTextWriter writer)
    {
                             
      /*-------------------------------
       * Find all op buttons added by 
       * user and store them
       *------------------------------*/      

      List<RecordOpButton> recOpButtons = new List<RecordOpButton>();
                                                     
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
       * Create preview
       *------------------------------*/

      base.render(ref writer);
                    
      /*-------------------------------
       * Record add/edit/delete/undelete
       * and other operations
       *------------------------------*/
      
      writer.Write(@"<div>");

      /*-------------------------------
       * Add New Button
       *------------------------------*/
      
      if (_hasAddNew)
      {    
        _addNewURL = MBA.HttpApplication.createLink(_addNewURL, _dataPrivate);
        
        MBA.Button getNew = new MBA.Button();
        getNew.ID      = "getNew";
        getNew.icon    = "ui-icon-plus";        
        getNew.onclick = "$.spedmonWebUI.recAddNewEditDelete('" +                                                           
                                                          this._tblIDSel           + @"','"    + 
                                                          this._statusIDSel        + @"',"     + 
                                                          Constants.SAVE_TYPE_NEW  + @","      + 
                                                          this._recIDPos           + @",'"     + 
                                                          this._addNewURL          + @"',"     + 
                                            Util.netBoolToJSBool(_addNewIsSubPage) + @","      + 
                                                     _addParmsToActionURLFnAddNew  + @","      +
                                                     this._dataTableInitJsFn       + @","      +  
                                                                   _actionFnAddNew + ")";
        
        getNew.Controls.Add(new MBA.RawText(_addNewButtonLabel));
        getNew.RenderControl(writer);
      
      }
                  
      /*-------------------------------
       * Record operations buttons
       * Edit/Delete/Undelete Options
       * (requires record to be selected)
       *------------------------------*/
      
      /*-------------------------------
       * Render user added op buttons
       *------------------------------*/
      
      foreach(RecordOpButton b in recOpButtons)
      {
        b.tblIDSel    = this._tblIDSel;
        b.statusIDSel = this._statusIDSel;
        b.recIDPos    = this._recIDPos;
        //this.Controls.Add(b);
        b.RenderControl(writer);        
      }

      if (_hasEdit)
      {        
        _editURL = MBA.HttpApplication.createLink(_editURL, _dataPrivate);

        MBA.Button getEdt = new MBA.Button();
        getEdt.ID      = "getEdt";
        getEdt.icon    = "ui-icon-pencil";        
        getEdt.onclick = "$.spedmonWebUI.recAddNewEditDelete('" +                                                           
                                                          this._tblIDSel           + @"','"    + 
                                                          this._statusIDSel        + @"',"     + 
                                                          Constants.SAVE_TYPE_EDIT + @","      + 
                                                          this._recIDPos           + @",'"     + 
                                                          this._editURL            + @"',"     + 
                                              Util.netBoolToJSBool(_editIsSubPage) + @","      + 
                                                        _addParmsToActionURLFnEdit + @","      + 
                                                     this._dataTableInitJsFn       + @","      + 
                                                                     _actionFnEdit + ")";
        
        getEdt.Controls.Add(new MBA.RawText(_editButtonLabel));
        getEdt.RenderControl(writer);
      }
      
      if (_hasDelete)
      {
        
        _deleteURL = MBA.HttpApplication.createLink(_deleteURL, _dataPrivate);
        
        MBA.Button getDel = new MBA.Button();
        getDel.ID         = "getDel";
        getDel.icon       = "ui-icon-trash";
        getDel.onclick    = "$.spedmonWebUI.recAddNewEditDelete('" +                                                              
                                                             this._tblIDSel             + @"','" + 
                                                             this._statusIDSel          + @"',"  + 
                                                             Constants.SAVE_TYPE_DELETE + @","   + 
                                                             this._recIDPos             + @",'"  + 
                                                             this._deleteURL            + @"',"  +
                                                             "null"                     + @","   +                                                               
                                                           _addParmsToActionURLFnDelete + @","   + 
                                                           this._dataTableInitJsFn       + @","  + 
                                                             _actionFnDelete + ")";

        getDel.Controls.Add(new MBA.RawText(_deleteButtonLabel));
        getDel.RenderControl(writer);
      }
            
      if (_hasUndelete)
      {
        
        _undeleteURL = MBA.HttpApplication.createLink(_undeleteURL, _dataPrivate);
        
        MBA.Button getUnDel = new MBA.Button();
        getUnDel.ID         = "getUnDel";
        getUnDel.icon       = "ui-icon-cart";
        getUnDel.onclick    = "$.spedmonWebUI.recAddNewEditDelete('" +                                                              
                                                             this._tblIDSel                 + @"','" + 
                                                             this._statusIDSel              + @"',"  + 
                                                             Constants.SAVE_TYPE_REACTIVATE + @","   + 
                                                             this._recIDPos                 + @",'"  + 
                                                             this._undeleteURL              + @"',"  +
                                                             "null"                         + @","   + 
                                                             _addParmsToActionURLFnUndelete + @","   + 
                                                             this._dataTableInitJsFn       + @","    + 
                                                             _actionFnUndelete + ")";
        getUnDel.Controls.Add(new MBA.RawText(_unDeleteButtonLabel));
        getUnDel.RenderControl(writer);
      }


      writer.Write(@"</div>");

      /*-------------------------------
       * Report output options and cancel
       *------------------------------*/
      
      writer.Write(@"<div>");      
      
      if (_displayGenHTM) 
      {
        MBA.Button genHTML = new MBA.Button();
        genHTML.ID      = "genhtml";
        genHTML.icon    = "ui-icon-print";
        genHTML.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_HTML.ToString() + "," + Constants.REPT_DELIVER_WINDOW.ToString() + ")";
        genHTML.Controls.Add(new MBA.RawText("View Data on Screen (HTML)"));      
        genHTML.RenderControl(writer);
      }      
      
      if (_displayGenXLS)
      {
        // determine url string if passed
        string urlString;
        urlString = ((!String.IsNullOrEmpty(displayGenXLSUrlFn)) ? ("," + displayGenXLSUrlFn + "()") : "");

        MBA.Button genXLS = new MBA.Button();
        genXLS.ID = "genxls";
        genXLS.icon = "ui-icon-calculator";
        genXLS.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_XLS.ToString() + "," + Constants.REPT_DELIVER_DYNAMIC_FILE.ToString() + urlString + ")";
        genXLS.Controls.Add(new MBA.RawText("Download Data (Excel)"));
        genXLS.RenderControl(writer);
      }
              
      if (_displayGenPDF)
      {
          MBA.Button genPDF = new MBA.Button();
        genPDF.ID = "genpdf";
        genPDF.icon = "ui-icon-document";
        genPDF.onclick = "$.spedmonWebUI.rptGet(" + _frmID + "," + Constants.REPT_FORMAT_PDF.ToString() + "," + Constants.REPT_DELIVER_DYNAMIC_FILE.ToString() + ")";
        genPDF.Controls.Add(new MBA.RawText("Download Data and Print (PDF)"));
        genPDF.RenderControl(writer);
      }
      
      if (_cancelButton)
      {
        if (this.rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
        {
          MBA.Button canSel = new MBA.Button();
          canSel.ID         = "canSel";
          canSel.icon       = "ui-icon-arrowreturnthick-1-w";
          canSel.onclick    = "$.spedmonWebUI.gotoMenuLink('homePageLink')";
          canSel.Controls.Add(new MBA.RawText("Cancel and Exit"));
          canSel.RenderControl(writer);
        }
        else
        {
          MBA.Button canSel = new MBA.Button();
          canSel.ID         = "canSel";
          canSel.icon       = "ui-icon-arrowreturnthick-1-w";
          canSel.onclick    = "window.close();";
          canSel.Controls.Add(new MBA.RawText("Cancel and Close"));
          canSel.RenderControl(writer);      
        }      
      }      

      writer.Write(@"</div>");      
            
      
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
        inputActive.RenderControl(writer);
      }

    }
  }


}

