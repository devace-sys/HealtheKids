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
   * RmtsParticipantPossible */
  /**
   * 
   **************************************************************************/
  public class RmtsParticipantPossible : RmtsParticipantSelectionChange
  {	  
      public DateTime? effectiveDate;
      public long?     participantID;
      public bool      submitClaims;
      public long      clientID;
      public long      pracID;
      public long      groupID;
      public long      groupServiceClassNameID;
  }
  
  /***************************************************************************
   * RmtsParticipantsPossible */
  /**
   * 
   **************************************************************************/
  public class RmtsParticipantsPossible:Entities
  {            
  

    /***************************************************************************
     * viewSel */
    /**
     * 
     ***************************************************************************/   

    public static ReturnSel viewSel (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , bool          top
                                     , string        topSize
                                     , string        clientid
                                     , string        term)
    {
             
      /*----------------------------
       * Define our context column
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {      
        ss.addDisplayColumn("'[Submit Claims]: ' + [submitClaimsStr] + ' [Title]: ' + [title] as context1");
        ss.addDisplayColumn("[title] as recData1");
        ss.addDisplayColumn("[submitClaimsStr] as recData2");
      };
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
      delegate{return RmtsParticipantsPossible.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "", clientid, term, dc);});

    }


    /*************************************************************************
     * view */
    /**
     * View all possible participants
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
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = "dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW (@userID, @userGroup, @userRank, @clientID, @term)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var vClientID = Validate.reqClientID (uInfo, clientID);
      var vTerm     = Validate.optString   (term, Messages.INVALID_SEARCH_TERM);

      var parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",     SqlDbType.VarChar, vTerm,     ParameterDirection.Input, 256));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
   }


  
  }
}

