using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{  
  
  /**************************************************************************
   * TeleCommSessionsTeleHealth */
  /**
   * 
   * 
   ****************************************************************************/

  public class TeleCommParticipantsTeleHealth : MBA.TeleCommParticipants
  {        

    /***************************************************************************
     * viewListPatients */
    /**
     * Gets list of patient participants
     * 
     ***************************************************************************/   

    public static List<TeleCommParticipant> viewListPatients (  SqlConnection connUsers
                                                              , DetailsLog    log
                                                              , UserInfo      uInfo
                                                              , long          sessionID ) {
      
      return viewList(  connUsers
                      , log
                      , uInfo
                      , Constants.APP_NAME
                      , Constants.TELECOMM_PURPOSE_TELEHEALH
                      , sessionID
                      , PARTICIPANT_ROLE_PATIENT);
    }
  
  }
}
