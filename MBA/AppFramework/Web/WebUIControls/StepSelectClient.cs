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
   * StepSelectClient */
  /**
   * Qualification data 
   ****************************************************************************/

  public class StepSelectClient:StepBase
  {  
               
    /*============================================================
     * Child controls 
     *===========================================================*/  
   
    protected MBA.StepOptions ctrlStepOpts  = new StepOptions();
    protected MBA.ComboBox    ctrlSelClient = new MBA.ComboBox();
    
    
    /*============================================================
     * Properties and options internal values
     *===========================================================*/  
        
    
    protected override void Render(HtmlTextWriter writer)
    {                                

      /*============================================================
       * Setup client select control
       *===========================================================*/        

      ctrlSelClient.ID          = @"clientid";
      ctrlSelClient.name        = @"clientid";
      ctrlSelClient.title       = @"Select Client";
      ctrlSelClient.dataPrivate = true;
      ctrlSelClient.dataURL     = @"clients.asmx/viewSel";
      ctrlSelClient.value       = @"";            
             
      /*============================================================
       * Setup step options control.
       * 
       * If a control exists already get out, otherwise create one
       *===========================================================*/        
      
      MBA.StepOptions stepopts = getStepOptions();
      if (stepopts == null) 
      {
        stepopts = new MBA.StepOptions(); 
        this.Controls.Add(stepopts);
      }
      else
      {
        throw new Critical("User defined step options are not allowed with this control");
      }

      /*-------------------------------
       * Commence rendering base
       * Note: the base will call
       * render()
       *------------------------------*/

      base.Render(writer);
    }
    
    protected override void render(ref HtmlTextWriter writer)
    {
         	                                                              
            
      /*============================================================
       * Create control structure
       *===========================================================*/  
                            
      /*-------------------------------
       * Control Group
       *------------------------------*/  
                                                                                  
    }       
  }   
}