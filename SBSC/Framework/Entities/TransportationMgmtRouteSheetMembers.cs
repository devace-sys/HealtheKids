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
   * TransportationMgmtRouteSheetMember */
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtRouteSheetMember : TransportationMgmtAuthorizedRouteMember
  {            
    public string    sheetCode;
    public long      sheetBatchID;
    public long      sheetID;                    
  }
  
  /***************************************************************************
   * TransportationMgmtRouteSheetMembers */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtRouteSheetMembers : Entities
  {
    
    /***************************************************************************
     * view */
    /**
     *
     **************************************************************************/  
    
    public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active
                                  , string        clientID
                                  , string        transMgmtID
                                  , string        patID
                                  , string        sheetBatchID                                  
                                  , string        sheetCode
                                  , string        routeID
                                  , string        sheetID
                                  , defineCols    dc )
    {
      
      string viewUDF = @" dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_VIEW (@userID, @userGroup, @userRank, @clientID, @transMgmtID, @patID, @sheetBatchID, @sheetCode, @routeID, @sheetID, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long    vClientID     = Validate.reqClientID (uInfo, clientID);
      long    vTransMgmtID  = Validate.reqInteger  (transMgmtID,  @"Invalid mgmt id"); 
      Object  vPatID        = Validate.optInteger  (patID,        Messages.INVALID_PAT_ID);
      Object  vSheetBatchID = Validate.optInteger  (sheetBatchID, @"Invalid batch id");
      String  vSheetCode    = Validate.optString   (sheetCode,    @"Invalid sheet code");
      Object  vRouteID      = Validate.optInteger  (routeID,      @"Invalid route id");
      Object  vSheetID      = Validate.optInteger  (sheetID,      @"Invalid sheet id"); 
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",  SqlDbType.BigInt,  vTransMgmtID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.BigInt,  vPatID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sheetBatchID", SqlDbType.BigInt,  vSheetBatchID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sheetCode",    SqlDbType.VarChar, vSheetCode,    ParameterDirection.Input, 512));      
      parms.Add(Database.SqlParm("@routeID",      SqlDbType.BigInt,  vRouteID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sheetID",      SqlDbType.BigInt,  vSheetID,      ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
                            , log
                            , uInfo
                            , recViewType
                            , pagedOrTop
                            , idx
                            , canEdit
                            , active
                            , viewUDF
                            , ref parms
                            , null
                            , dc );    
    }

    /***************************************************************************
     * loadAllRecords */
    /**    
     *
     ***************************************************************************/

    public static List<TransportationMgmtRouteSheetMember> loadAllRecords (   SqlConnection connSpedmon
                                                                            , DetailsLog    log
                                                                            , UserInfo      uInfo
                                                                            , string        clientID
                                                                            , string        transMgmtID                                                         
                                                                            , string        patID
                                                                            , string        sheetBatchID                                  
                                                                            , string        sheetCode
                                                                            , string        routeID
                                                                            , string        sheetID
                                                                           ) 
    {
      
      List<TransportationMgmtRouteSheetMember> listItems = new List<TransportationMgmtRouteSheetMember>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (TransportationMgmtRouteSheetMember)
                                      , delegate { 
                                        return TransportationMgmtRouteSheetMembers.view (   connSpedmon
                                                                                     , log
                                                                                     , uInfo
                                                                                     , Entities.REC_VIEW_ALL
                                                                                     , false
                                                                                     , ""
                                                                                     , ""
                                                                                     , "Y"
                                                                                     , clientID
                                                                                     , transMgmtID
                                                                                     , patID
                                                                                     , sheetBatchID
                                                                                     , sheetCode
                                                                                     , routeID
                                                                                     , sheetID                                                                                      
                                                                                     , null);}
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          TransportationMgmtRouteSheetMember listItem = (TransportationMgmtRouteSheetMember) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }             
    


 
  }
}