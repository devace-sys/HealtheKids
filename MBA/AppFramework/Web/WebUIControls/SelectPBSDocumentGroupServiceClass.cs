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
   * PBSDocumentGroupServiceClass */
  /**
   ****************************************************************************/
  
  public enum PBSDocumentGroupServiceClass  
  {            
	    OT      = 4
    , PT      = 6
    , SPEECH  = 9
    , UKNOWN  = 0
  }
  
  /**************************************************************************
   * SelectPBSDocumentGroupServiceClass */
  /**
   *
   ****************************************************************************/ 

  public class SelectPBSDocumentGroupServiceClass:RadioBox
  {
    
    public SelectPBSDocumentGroupServiceClass():base() 
    {        
      this.firedataselected = true;
      this.labelIsSpan      = false;
      this.noClear          = false;	       
    }

    protected override void OnPreRender(EventArgs e)
    {
      this.AddSelection("Speech Services",                ((int) PBSDocumentGroupServiceClass.SPEECH).ToString()); /* int to string and back to int again, i guess */
                                                               /* follow-up comment: a C# enum behaves deceptively different than a C enum.  see https://www.tutorialsteacher.com/csharp/csharp-enum */
      this.AddSelection("Occupational Therapy Services",  ((int) PBSDocumentGroupServiceClass.OT).ToString());
      this.AddSelection("Physical Therapy Services",      ((int) PBSDocumentGroupServiceClass.PT).ToString());
      base.OnPreRender(e);
    }

  }
}

