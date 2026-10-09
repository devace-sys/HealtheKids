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
   * AuthCarePlan */
  /**
   ****************************************************************************/
  
  public enum AuthCarePlan
  {      
      IEP_IFSP             = 100
    , OTHER_WRITTEN_PLAN   = 200
    , NO_WRITTEN_PLAN      = 300    
  }
  
  /**************************************************************************
  * SelectAuthCarePlan */
  /**
   *
   ****************************************************************************/ 

  public class SelectAuthCarePlan:ControlBase
  {
    
    public SelectAuthCarePlan() 
    {
    
    }
    
	  protected string        _id           = @"authcareplan";
	  protected string        _title        = @"This service is "; 
    protected AuthCarePlan  _value        = AuthCarePlan.IEP_IFSP;
    protected string        _valueStr     = "";	  
	  
    public string       id    { get { return _id;    } set { _id    = value; } }
    public string       title { get { return _title; } set { _title = value; } }
    public AuthCarePlan value { get { return _value; } set { _value = value; } }
    
	  protected override void Render (HtmlTextWriter writer) { 
	  
	    _valueStr = ((int)_value).ToString();
      
      /*============================================================
       * Authorized Plan Type Radio Box
       *===========================================================*/  
        
      MBA.RadioBox carePlans     = new MBA.RadioBox (_id, _valueStr);
       
      carePlans.ID               = _id;
      carePlans.title            = _title;
      carePlans.firedataselected = true;
      carePlans.noClear          = false;
         
      carePlans.AddSelection("Authorized in an IEP or IFSP",        ((int) AuthCarePlan.IEP_IFSP).ToString());
      carePlans.AddSelection("Authorized in Another Written Plan",  ((int) AuthCarePlan.OTHER_WRITTEN_PLAN).ToString());
      carePlans.AddSelection("Not Authorized in ANY Written Plan",  ((int) AuthCarePlan.NO_WRITTEN_PLAN).ToString());
                
      carePlans.RenderControl(writer);
	
	  }  
  
  }

}

