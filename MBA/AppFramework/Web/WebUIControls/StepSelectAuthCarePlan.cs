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
   * StepSelectAuthCarePlan */
  /**
   * Controls used to select an authorized care plan
   ****************************************************************************/

  public class StepSelectAuthCarePlan : StepBase
  {  
    
    public StepSelectAuthCarePlan ()
    {                          
    }
    
    
	  protected override void render(ref HtmlTextWriter writer)
    {                        
      MBA.SelectAuthCarePlan acp = new SelectAuthCarePlan();      
      acp.RenderControl(writer);  
	  }
	
    protected override void Render(HtmlTextWriter writer)
    {                                

      /*-------------------------------
       * If title is not provided
       * use default
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(this._title))
        this._title = @"What Is The Authorized Service Plan";
          
      /*-------------------------------
       * If instructions are not provided
       * use default
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(this._instr))  
        this._instr = @"Click on an option below.";

      base.Render(writer);
    }    
  }   
}