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


  public class UserAllClientNotesManage : WebUI

  {

    public bool isPcalStaff = false;

    public UserAllClientNotesManage() : base(   ""  // Util.createUniqueID()  -- ???
                                                , ClientsNotes.SEL_LABEL_MANAGE
                                                , @""
                                                , @""
                        , Constants.ROLE_ALL_PCAL_AND_CLIENT ) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {
    
        isPcalStaff = this.uInfo.pcalStaff;

        var rowFilterForThisConsultant                =  findControlRecu(this.Page, "rowFilterForThisConsultant" ) as MBA.DataEntryRow;
        var ctrlCheckboxFilterForThisConsultant       =  findControlRecu(this.Page, "filterForThisConsultant")     as MBA.CheckBox;

        if ( isPcalStaff && this.uInfo.userRole == "Client Consultant" )
        {
                ctrlCheckboxFilterForThisConsultant.value = true;
                rowFilterForThisConsultant.Visible        = true;
        }
        else { 

                ctrlCheckboxFilterForThisConsultant.value = false;
                rowFilterForThisConsultant.Visible        = false;

        }
        
    }
  }

}
