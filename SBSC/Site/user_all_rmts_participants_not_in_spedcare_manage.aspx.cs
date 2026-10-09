using System;

namespace Spedmon
{

  /***************************************************************************
   * UserAllRmtsParticipantsNotInSpEdCareManage */
  /**
   * 
   ***************************************************************************/

  public class UserAllRmtsParticipantsNotInSpEdCareManage : WebUI
  {

    public UserAllRmtsParticipantsNotInSpEdCareManage() : base (StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.MENU_ID_MANAGE
                                                     , StructuredDataImportFilesRmtsParticipantsNotInSpEdCare.SEL_LABEL_MANAGE
                                                     , "rmts_participation_roster_save.css"
                                                     , ""
                                                     , Constants.ROLE_SBS_ALL) { }
    
    protected void Page_Load(object sender, EventArgs e)
    {
    }
    
  }
}
