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
   * StepSelectStandardOrpDocName */
  /**
   * Controls used to select a standard orp document name
   * TODO: Complete when I have time
   ****************************************************************************/

  public class StepSelectStandardOrpDocName : StepBase
  {  
    
    public StepSelectStandardOrpDocName ()
    {                          
    }
    
	  protected override void render(ref HtmlTextWriter writer)
    {                        
	    
	    MBA.ComboBox selName = new MBA.ComboBox();
	    
	  
	  }
	
    protected override void Render(HtmlTextWriter writer)
    {                                

      /*-------------------------------
       * If title is not provided
       * use default
       *------------------------------*/
      
      if (Util.IsNullOrEmpty(this._title))
        this._title = @"What is the name of the ordered service?";
          
      /*============================================================
       * If instructions are not provided use default
       *===========================================================*/  
      
      if (Util.IsNullOrEmpty(this._instr))  
        this._instr = @"Select or search for the type of service that has been prescribed."
                    + @" Use the Mange Prescription Documents button to upload and manage documents associated with this order."
                    + @" NOTE: If the service type is not in the list, select “Temporary Name” from the list"
                    + @" and then use the “Request a Service” button to have Practi-Cal add the new Service Type."
                    + @" You will need to edit the name once Practi-Cal adds it to SpEdCare.";

     /*============================================================
       * Setup step options control.
       *===========================================================*/  
      
      MBA.StepOptions stepopts = getStepOptions();
      if (stepopts == null) 
      {
        stepopts = new MBA.StepOptions();
      }
      else throw new Critical("User defined step options are not allowed with this control");


      base.Render(writer);
    }    
  }   
}