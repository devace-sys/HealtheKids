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
using MBA;
using MBA.IdentifyData;
using System.Linq;

namespace MBA 
{      
      
  
  /**************************************************************************
   * StepSave */
  /**
   * Save record
   * 
   * TODO : Finish when I have time
   ****************************************************************************/

  public class StepSave:StepBase
  {  
          
    protected string _ctrlSaveTypeID         = @"savetype";
    protected string _ctrlSaveTypeName       = @"savetype";
    protected string _ctrlSaveTypeValue      = "";
    
    protected string _ctrlRecIDID            = "recid";
    protected string _ctrlRecIDName          = "recid";
    protected string _ctrlRecIDValue         = "";
    
    protected string _ctrlValidateRecID      = "validaterec";
    protected string _ctrlValidateRecName    = "validaterec"; 
    
    protected string _ctrlEditDelReasonID    = "editDelReason";
    protected string _ctrlEditDelReasonName  = "editDelReason";
   
    protected string _ctrlStatusListID       = "validatelist";
    
    protected string _ctrlButSaveID          = "";
    protected string _ctrlButSaveName        = "";
    
    protected string _ctrlButCancelID        = "";
    protected string _ctrlButCancelName      = "";
    
    
    protected MBA.HiddenInput _ctrlSaveType;
    protected MBA.HiddenInput _ctrlRecID;
    protected MBA.HiddenInput _ctrlValidateRec;
    protected MBA.HiddenInput _ctrlEditDelReason;
    protected MBA.DetailList  _ctrlStatusList;
    
    protected MBA.Button      _ctrlButSave;
    protected MBA.Button      _ctrlButCancel;
      
    protected Constants.SAVE_TYPE _saveType;
        
    protected override void Render(HtmlTextWriter writer)
    {                                
             

      /*-------------------------------
       * Commence rendering base
       * Note: the base will call
       * render()
       *------------------------------*/

      base.Render(writer);
    }
    
    protected override void render(ref HtmlTextWriter writer)
    {

      _ctrlSaveType.ID    = _ctrlSaveTypeID;
      _ctrlSaveType.name  = _ctrlSaveTypeName;
      _ctrlSaveType.title = "save_type";
      _ctrlSaveType.value = @"";
      
      _ctrlRecID.ID      = _ctrlRecIDID;
      
      _ctrlValidateRec.ID   = _ctrlValidateRecID;
      _ctrlValidateRec.name = _ctrlValidateRecName;
      
      _ctrlSaveType.RenderControl(writer);
      _ctrlRecID.RenderControl(writer);
      _ctrlValidateRec.RenderControl(writer);
      _ctrlEditDelReason.RenderControl(writer);     
      _ctrlStatusList.RenderControl(writer);
      
      if (_saveType == Constants.SAVE_TYPE.NEW)
      {
        if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
        {
        }
        else
        {
        }
      }
      else if (_saveType == Constants.SAVE_TYPE.EDIT)
      {
        if (rd.appMode != Constants.AMD_UI_DBS_SUB_PAGE)
        {
        }
        else
        {
        }
      }
      else
      {
        /* Unsupported*/
      }                   	                                                                                                                                                            
    }       
  }   
}