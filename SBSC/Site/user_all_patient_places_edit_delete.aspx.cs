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
   * UserAllPatientPlacesEditDelete */
  /**
   * 
   ***************************************************************************/

  public class UserAllPatientPlacesEditDelete : WebUI
  {
    
    public UserAllPatientPlacesEditDelete() : base("patient_places_edit_delete"
	                                        , WebUI.CreatePageSubTitle(  PatientPlaces.SEL_LABEL
										                                                 , PatientPlaces.SEL_LABEL_EDIT_DELETE)
										                      , ""
											                    , ""
											                    , Constants.ROLE_ALL_PCAL_AND_CLIENT) { }
    
	  protected void Page_Load(object sender, EventArgs e)
    {
  	  long    clientID  = Spedmon.Validate.reqClientID(uInfo,MBA.HttpApplication.getParameter(@"clientid"));      
		  long    patID     = Spedmon.Validate.reqInteger(MBA.HttpApplication.getParameter(@"patid"),@"Invalid patient id");
      string  appMode   = MBA.HttpApplication.getParameter(Constants.PARM_APP_MODE);
      
     
      WebUIControlDataField ctrlAppMode  = findControlRecu(this.Page, "appmode")   as WebUIControlDataField;
      WebUIControlDataField ctrlClientID = findControlRecu(this.Page, "clientid")   as WebUIControlDataField;
      WebUIControlDataField ctrlPatID    = findControlRecu(this.Page, "patid")      as WebUIControlDataField;

      ctrlClientID.value = clientID.ToString();
      ctrlPatID.value    = patID.ToString();
      ctrlAppMode.value  = appMode.ToString();

    }
  }
}
