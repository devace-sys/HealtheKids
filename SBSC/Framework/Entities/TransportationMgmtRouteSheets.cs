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
   * TransportationMgmtRouteSheet */
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtRouteSheet : TransportationMgmtAuthorizedRoute
  {
    
    public string   sheetCode;
    public long     sheetBatchID;
    public long     sheetID;
    public long     routeID;
    public string   routeName;
    public bool     sheetProcessed;
    
    public DateTime monDateVal;
    public DateTime tueDateVal;
    public DateTime wedDateVal;
    public DateTime thuDateVal;
    public DateTime friDateVal;
    
    public String   monDateStr;
    public String   tueDateStr;
    public String   wedDateStr;
    public String   thuDateStr;
    public String   friDateStr;
    public long     weekOfServiceVal;
        
  }
  
  
  /***************************************************************************
   * TransportationMgmtRouteSheets */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtRouteSheets : Entities
  {
          
    /***************************************************************************
     * save */
    /**
     * Save route sheets
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Routes's client id
     * @param  editDelReason   Reason for record edit or delete
     * @param  validateRec     1 = Performs data integrity validation tasks
     *                             Perform advisory validation tasks that can
     *                             only be conducted by referencing data from the
     *                             database and then exits WITHOUT saving the record
     *                         0 = Peform data integrity validation tasks and
     *                             if these tasks succeed peforms the desired
     *                             operation (saveType) on the record and exits
     * @param  saveType        Type of operation to perform
     *                         1 = New, 2 = Edit, 3 = Delete
     * @param  recID           Record id of existing patient record to edit or
     *                         delete.
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
                                          , string        transMgmtID 
                                          , string        routeID
                                          , string        startDate
                                          , string        editDelReason
                                          , string        validateRec
                                          , string        saveType
                                          , string        recID )  
    {
     
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
     
      long       vClientID                    = Validate.reqClientID (uInfo,       clientID);
      long       vTransMgmtID                 = Validate.reqInteger  (transMgmtID, @"Invalid mgmt id"); 
      DateTime   vStartDate                   = Validate.reqDate     (startDate,   Messages.INVALID_START_DATE);
      Object     vRouteID                     = Validate.optInteger  (routeID,     @"Invalid route ID");
	  
        
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",  SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",    SqlDbType.VarChar, vStartDate,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@routeID",      SqlDbType.VarChar, vRouteID,     ParameterDirection.Input));
	  
      return Entities.save ( connSpedmon
                            , log
                            , uInfo
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID
                            , "TRANSPORTATION_MGMT_ROUTE_SHEETS_SAVE"
                            , "There is already an active route sheet with this name"
                            , ref parms
                            , null );
    }


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
                                  , string        sheetBatchID
                                  , string        sheetCode
                                  , string        routeID
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW (@userID, @userGroup, @userRank, @clientID, @transMgmtID, @sheetBatchID, @sheetCode, @routeID, @active, @recID)";
      
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
      Object  vSheetBatchID = Validate.optInteger  (sheetBatchID, @"Invalid batch id");
      String  vSheetCode    = Validate.optString   (sheetCode,    @"Invalid sheet code");
      Object  vRouteID      = Validate.optInteger  (routeID,      @"Invalid route id");
       
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",  SqlDbType.BigInt,  vTransMgmtID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sheetBatchID", SqlDbType.BigInt,  vSheetBatchID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sheetCode",    SqlDbType.VarChar, vSheetCode,    ParameterDirection.Input, 512));      
      parms.Add(Database.SqlParm("@routeID",      SqlDbType.BigInt,  vRouteID,      ParameterDirection.Input));
      
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
     * load */
    /**
     * 
     ***************************************************************************/

    public static TransportationMgmtRouteSheet load (   SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string        clientID
                                                      , string        transMgmtID                                                                                                                
                                                      , string        sheetCode )
    {
      
      
      
      return (TransportationMgmtRouteSheet) Entities.load(  connSpedmon
                                                          , log
                                                          , uInfo                                                          
                                                          , typeof(TransportationMgmtRouteSheet)
                                                          , delegate { 
                                                            return TransportationMgmtRouteSheets.view (   
                                                                connSpedmon
                                                              , log
                                                              , uInfo
                                                              , Entities.REC_VIEW_RAW
                                                              , false
                                                              , ""
                                                              , ""
                                                              , "Y"
                                                              , clientID
                                                              , transMgmtID
                                                              , null
                                                              , sheetCode
                                                              , null
                                                              , null                                                                                     
                                                              );});
    } 
    
   

    /***************************************************************************
     * loadAllRecords */
    /**    
     *
     ***************************************************************************/

    public static List<TransportationMgmtRouteSheet> loadAllRecords (   SqlConnection connSpedmon
                                                                      , DetailsLog    log
                                                                      , UserInfo      uInfo
                                                                      , string        clientID
                                                                      , string        transMgmtID                                                         
                                                                      , string        sheetBatchID
                                                                      , string        sheetCode
                                                                      , string        routeID
                                                                    ) 
    {
      
      List<TransportationMgmtRouteSheet> listItems = new List<TransportationMgmtRouteSheet>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (TransportationMgmtRouteSheet)
                                      , delegate { 
                                        return TransportationMgmtRouteSheets.view (   connSpedmon
                                                                                     , log
                                                                                     , uInfo
                                                                                     , Entities.REC_VIEW_ALL
                                                                                     , false
                                                                                     , ""
                                                                                     , ""
                                                                                     , "Y"
                                                                                     , clientID
                                                                                     , transMgmtID
                                                                                     , sheetBatchID
                                                                                     , sheetCode
                                                                                     , routeID                                                                                     
                                                                                     , null);}
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          TransportationMgmtRouteSheet listItem = (TransportationMgmtRouteSheet) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }             
    


  }
}