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
  public class sbs_all_telecomm_iep_types_save : WebUI
  {
     public sbs_all_telecomm_iep_types_save(): base( @"sbs_all_telecomm_iep_types_save"
	                                               , TeleCommIEPTypes.SEL_LABEL_ADD_NEW
                                                 , @""
                                                 , @""
										                             , Constants.ROLE_SBS_ALL){} 
   
	protected void Page_Load(object sender, EventArgs e)
  {
      /*###########################################################################
        # Fetch parameters 
        ###########################################################################*/    
      
      string savetype          = MBA.HttpApplication.getParameter(Constants.PARM_SAVE_TYPE);
      string recid             = MBA.HttpApplication.getParameter(Constants.PARM_REC_ID);
	  
	  /*###########################################################################
        # Determine save type
        ###########################################################################*/    

      Object vSaveType  = Spedmon.Validate.optInteger (savetype,  Messages.INVALID_SAVE_TYPE);
      int    saveType   = Constants.SAVE_TYPE_NEW;
      if (vSaveType == null) vSaveType = Constants.SAVE_TYPE_NEW;
      saveType  = (int) vSaveType;

	  
    }
  }
}