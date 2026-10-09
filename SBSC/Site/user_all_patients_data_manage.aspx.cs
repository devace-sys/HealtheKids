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
   * UserAllPatientsDataManage */
  /**
   * 
   ***************************************************************************/


  public class UserAllPatientsDataManage : WebUI

  {
    public bool is_pcalStaff;

    public UserAllPatientsDataManage () : base(   Util.createUniqueID()
                                                , StructuredDataImportFilesPatientData.SEL_LABEL_MANAGE
                                                , @""
                                                , @""
										        , Constants.ROLE_BULK_PATIENT_IMPORT) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {
    
      is_pcalStaff = this.uInfo.pcalStaff;
      
    }
  }

}
