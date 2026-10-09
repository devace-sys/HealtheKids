using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * UserAllPatientPersonManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllPatientPersonManage : WebUI
  {
    
    public UserAllPatientPersonManage() : base ( "patient_persons_manage"
                                                 , PatientPersons.SEL_LABEL_MANAGE
                                                 , ""
                                                 , ""
                                                 , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {   
      string  clientid    = MBA.HttpApplication.getParameter(@"clientid");
	    string  patientid   = MBA.HttpApplication.getParameter(@"patientid");	    
	    
      long    clientID    = Spedmon.Validate.reqClientID (uInfo,clientid);	          
		  long    patientID   = Spedmon.Validate.reqInteger  (patientid,Messages.INVALID_PAT_ID);
      
      HiddenInput ctrlClientID = findControlRecu(this.Page, "clientid") as HiddenInput;
      HiddenInput ctrlPatID    = findControlRecu(this.Page, "patid")    as HiddenInput;      
                  
      ctrlClientID.value = clientid;
      ctrlPatID.value    = patientid;

    }
  }
}
