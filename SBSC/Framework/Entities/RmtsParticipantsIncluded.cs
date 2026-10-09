using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{   
 
  /***************************************************************************
   * RmtsParticipantIncluded */
  /**
   * 
   *
   * 
   **************************************************************************/

  public class RmtsParticipantIncluded:RmtsParticipantPossible
  { 
  }
  
 

  /***************************************************************************
   * RmtsParticipantsIncluded */
  /**
   * 
   *
   * 
   **************************************************************************/
  
  public class RmtsParticipantsIncluded:Entities
  {            
  
    /*************************************************************************
     * view */
    /**
     * All possible participants who are included 
     * 
     ***************************************************************************/   

    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active   
                                  , string        clientID
                                  , string        rosterID
                                  , defineCols    dc )
    {
      
      string viewUDF = "dbo.RMTS_PARTICIPANTS_INCLUDED_VIEW (@userID, @userGroup, @userRank, @clientID, @rosterID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var vClientID = Validate.reqClientID (uInfo, clientID);
      var vRosterID = Validate.optInteger  (rosterID, @"Invalid roster");

      var parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rosterID", SqlDbType.BigInt, vRosterID, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
   }

   /***************************************************************************
     * viewList */
    /**
     * View list of participants
     * 
     ***************************************************************************/   

   public static List<RmtsParticipantPossible> viewList (  SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , string        clientID
                                                          , string        rosterID )
     {
       var recs = new List<RmtsParticipantPossible>();
       ReturnDB rd = RmtsParticipantsIncluded.view (connSpedmon,log,uInfo,Entities.REC_VIEW_RAW,false,null,null,null,clientID,rosterID,null);
       List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(RmtsParticipantPossible));
       foreach (var o in slo) {
         recs.Add((RmtsParticipantPossible) o);
       }
       return recs;
     }

    
  }
}
