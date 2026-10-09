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
   * DelegateUserSpecificAction
  /**
   * 
   ****************************************************************************/
  
  public delegate bool DelegateUserSpecificAction (ref RequestResponse rd);


  /**************************************************************************
   * ControlBase*/
  /**
   * Base class for most controls.  Note this inherits from Control vs WebControl.
   * The webcontrol class has some extra functionality and overhead that is not
   * desired... for example it puts span tags around child controls.
   ****************************************************************************/ 

  public class ControlBase:Control
  {
    protected RequestResponse rd;
    protected WebApp          wa;
    
    public ControlBase()       
    {
      rd = HttpApplication.retrieveRequestResponse();        
      this.Load += new EventHandler(load);
    }
    
    protected void load(Object sender, EventArgs e)
    {      
      wa = (WebApp) this.Page;      
    }

  }
}
