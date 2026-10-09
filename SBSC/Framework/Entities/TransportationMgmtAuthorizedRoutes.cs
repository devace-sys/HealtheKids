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
   * TransportationMgmtAuthorizedRoute */
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtAuthorizedRoute : Entity
  {
    public long      clientID;
    public string    clientName;
    public string    busNumber;
    
    public  string   origName;
    public  string   origAddress;
    public  string   origPlaceID;
    
    public  string   destName;
    public  string   destAddress;
    public  string   destPlaceID;
    
    public  decimal? distanceMiles;
    public  string   distanceMilesStr;

    public  long     busDriverID;
    public  string   busDriverName;

  }
  
  /***************************************************************************
   * TransportationMgmtAuthorizedRoutes */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtAuthorizedRoutes : Entities
  {
  
    public const string URL_SERVICE_BASE            = @"transport_mgmt_auth_routes.asmx";
    public const string URL_SAVE                    = URL_SERVICE_BASE + @"/save";
    public const string URL_DUP                     = URL_SERVICE_BASE + @"/duplicate";
    public const string URL_DUP_REVERSE             = URL_SERVICE_BASE + @"/duplicateandreversestops";
    public const string URL_DELETE                  = URL_SERVICE_BASE + @"/delete";

    public static string URL_SAVE_BASE()
    {
      return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRoutes.URL_SAVE, true);
    }

    public static string URL_DUP_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRoutes.URL_DUP, true);
    }

    public static string URL_DUP_REVERSE_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRoutes.URL_DUP_REVERSE, true);
    }

    public static string URL_DELETE_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRoutes.URL_DELETE, true);
    }

    /***************************************************************************
     * save */
    /**
     * Save an authorized route
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Routes's client id
     * @param  name            Name of the route
     * @param  busNum          Number of the bus
     *
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
                                      , string        name
						              , string        busNumber
						              , string        origPlaceID
						              , string        destPlaceID
                                      , string        distanceMiles										                      
                                      , string        busDriverID										                      
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
     
      long       vClientID       = Validate.reqClientID (uInfo,         clientID);
      long       vTransMgmtID    = Validate.reqInteger  (transMgmtID,   @"Invalid mgmt id"); 
      string     vName           = Validate.reqString   (name,          @"Invalid route name");
	    Object     vBusNumber      = Validate.optString   (busNumber,     @"Invalid bus number");	  
      Object     vOrigPlaceID    = Validate.optString   (origPlaceID,   @"Origin address required");
      Object     vDestPlaceID    = Validate.optString   (destPlaceID,   @"Destination address required");       
      Object     vDistanceMiles  = Validate.optFixed    (distanceMiles, @"Invalid distance miles");	  
      var        vBusDriverID    = Validate.optInteger  (busDriverID,   @"Invalid bus driver id");	  

      parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,   vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",   SqlDbType.BigInt,   vTransMgmtID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",          SqlDbType.VarChar,  vName,          ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@busNumber",     SqlDbType.VarChar,  vBusNumber,     ParameterDirection.Input, 50));     	    
      parms.Add(Database.SqlParm("@origPlaceID",   SqlDbType.VarChar,  vOrigPlaceID,   ParameterDirection.Input, 255));      
	  parms.Add(Database.SqlParm("@destPlaceID",   SqlDbType.VarChar,  vDestPlaceID,   ParameterDirection.Input, 255));
	  parms.Add(Database.SqlParm("@distanceMiles", SqlDbType.Decimal,  vDistanceMiles, ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@busDriverID",   SqlDbType.BigInt,   vBusDriverID,   ParameterDirection.Input));

      return Entities.save (   connSpedmon
                             , log
                             , uInfo
                             , saveType
                             , validateRec
                             , editDelReason
                             , recID
                             , "TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_SAVE"
                             , "There is already an active route with this name"
                             , ref parms
                             , null );
    }

    /***************************************************************************
     * duplicate */
    /**
     * Duplicates an existing route with an option to reverse the direction
	 * of all of the stops on the route.
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Routes's client id
     * @param  name            Name of the route
	 * @param  busNum          Number of the bus
     *
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

    public static ReturnSaveRecord duplicate ( SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
                                          , string        transMgmtID 
                                          , string        routeIDToDuplicate
                                          , string        newRouteName
                                          , bool          reverseStops )
  
    {

      /* TODO: This method contains a temp fix to make sure that each new trip has mile calculations.
       * It does this by immediately calling the route member edit.
       * We need to refactor because all ops are not in a transaction
       * we need to possibly create a new method that will everything this method needs to do 
       * but handles the transaction at the middleware level. */


      List<SqlParameter> parms = new List<SqlParameter>();
     
      long   vClientID           = Validate.reqClientID (uInfo, clientID);
      long   vTransMgmtID        = Validate.reqInteger  (transMgmtID,        @"Invalid mgmt id");
      long   vRouteIDToDuplicate = Validate.reqInteger  (routeIDToDuplicate, @"Invalid mgmt id");
      string vNewRouteName       = Validate.reqString   (newRouteName,       @"Invalid route name");

      parms.Add(Database.SqlParm("@clientID",           SqlDbType.BigInt,   vClientID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",        SqlDbType.BigInt,   vTransMgmtID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@routeIDToDuplicate", SqlDbType.BigInt,   vRouteIDToDuplicate, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@newRouteName",       SqlDbType.VarChar,  vNewRouteName,       ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@reverseStops",       SqlDbType.Bit,      reverseStops,        ParameterDirection.Input));

      ReturnSaveRecord rd =  Entities.save (  connSpedmon
                                              , log
                                              , uInfo
                                              , "1"
                                              , "0"
                                              , ""
                                              , null
                                              , "TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DUPLICATE"
                                              , "There is already an active route with this name"
                                              , ref parms
                                              , null );

      /* If we are reversing stops call the edit for each member to force generation of trip and recalc of miles if needed */      

      if (reverseStops == true)
      {
        var members = TransportationMgmtAuthorizedRouteMembers.loadAllRecords ( connSpedmon, log, uInfo, clientID, transMgmtID, rd.recordID.ToString() );
        foreach (var member in members)
        {          
          TransportationMgmtAuthorizedRouteMembers.save (  connSpedmon
                                                          , log
                                                          , uInfo
                                                          , clientID
                                                          , transMgmtID
                                                          , member.routeID.ToString()
                                                          , member.patID.ToString()
                                                          , member.origPlaceID
                                                          , member.destPlaceID
                                                          , member.weekDaysJSON
                                                          , member.selectAmPm
                                                          , "Edit to compute miles if neccessary"
                                                          , "N"
                                                          , Constants.SAVE_TYPE_EDIT.ToString()
                                                          , member.id.ToString());
        }
      }
      return rd;
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
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW (@userID, @userGroup, @userRank, @clientID, @transMgmtID, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long    vClientID     = Validate.reqClientID (uInfo, clientID);
      long    vTransMgmtID  = Validate.reqInteger  (transMgmtID, @"Invalid mgmt id"); 
 
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@TransMgmtID",  SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));

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
     * viewPatNotAssigned */
    /**
     *
     **************************************************************************/  
    
    public static ReturnDB viewPatNotAssigned (   SqlConnection connSpedmon
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
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_VIEW_PAT_NOT_ASSIGNED (@userID, @userGroup, @userRank, @clientID, @transMgmtID, @patID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long    vClientID     = Validate.reqClientID (uInfo, clientID);
      long    vTransMgmtID  = Validate.reqInteger  (transMgmtID, @"Invalid mgmt id"); 
      long    vPatID        = Validate.reqInteger  (patID,       @"Invalid patient id");

      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@TransMgmtID",  SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.BigInt,  vPatID,       ParameterDirection.Input));

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

    public static List<TransportationMgmtAuthorizedRoute> loadAllRecords (    SqlConnection connSpedmon
                                                                            , DetailsLog    log
                                                                            , UserInfo      uInfo
                                                                            , string        clientID
                                                                            , string        transMgmtID ) 
    {
      
      List<TransportationMgmtAuthorizedRoute> listItems = new List<TransportationMgmtAuthorizedRoute>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (TransportationMgmtAuthorizedRoute)
                                      , delegate { 
                                        return TransportationMgmtAuthorizedRoutes.view (   connSpedmon
                                                                                         , log
                                                                                         , uInfo
                                                                                         , Entities.REC_VIEW_ALL
                                                                                         , false
                                                                                         , ""
                                                                                         , ""
                                                                                         , "Y"
                                                                                         , clientID
                                                                                         , transMgmtID
                                                                                         , null);}
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          TransportationMgmtAuthorizedRoute listItem = (TransportationMgmtAuthorizedRoute) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }             
    
    /***************************************************************************
     * viewSel */
    /**
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        transMgmtID
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {                     
          ss.addDisplayColumn("busNumber       as context1");
          ss.addDisplayColumn("busNumber       as [recData1]");
          ss.addDisplayColumn("origName        as [recData2]");
          ss.addDisplayColumn("origAddress     as [recData3]");        
          ss.addDisplayColumn("origPlaceID     as [recData4]");
          ss.addDisplayColumn("destName        as [recData5]");
          ss.addDisplayColumn("destAddress     as [recData6]");
          ss.addDisplayColumn("destPlaceID     as [recData7]");        
          ss.addDisplayColumn("distanceMilesStr as [recData8]");
          ss.addDisplayColumn("convert(varchar, busDriverID) as [recData9]");
          ss.addDisplayColumn("busDriverName   as [recData10]");           
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return TransportationMgmtAuthorizedRoutes.view (   connSpedmon
                                                                                     , log
                                                                                     , uInfo
                                                                                     , Entities.REC_VIEW_SEL
                                                                                     , top
                                                                                     , topSize
                                                                                     , ""
                                                                                     , "Y"
                                                                                     , clientID
                                                                                     , transMgmtID
                                                                                     , dc); 
                                  });
                                                                    
    }

    /***************************************************************************
     * viewSelPatNotAssigned */
    /**
     ***************************************************************************/

    public static ReturnSel viewSelPatNotAssigned (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        transMgmtID
                                      , string        patID )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {                     
          ss.addDisplayColumn("convert(varchar,id)        as [recData1]");
          ss.addDisplayColumn("name                       as [recData2]");
          ss.addDisplayColumn("convert(varchar, clientID) as [recData3]");             
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return TransportationMgmtAuthorizedRoutes.viewPatNotAssigned (   connSpedmon
                                                                                     , log
                                                                                     , uInfo
                                                                                     , Entities.REC_VIEW_SEL
                                                                                     , top
                                                                                     , topSize
                                                                                     , ""
                                                                                     , "Y"
                                                                                     , clientID
                                                                                     , transMgmtID
                                                                                     , patID
                                                                                     , dc); 
                                  });
                                                                    
    }

    /***************************************************************************
     * load */
    /**
     * Outputs data for a single record
     *
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     *
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static TransportationMgmtAuthorizedRoute load (   SqlConnection connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , string        clientID
                                                             , string        transMgmtID
                                                             , string        recID )
    {
      return (TransportationMgmtAuthorizedRoute) Entities.load(  connSpedmon
                                                                  , log
                                                                  , uInfo
                                                                  , recID
                                                                  , typeof (TransportationMgmtAuthorizedRoute)
                                                                  , delegate { 
         return TransportationMgmtAuthorizedRoutes.view (  connSpedmon
                                                          , log
                                                          , uInfo
                                                          , Entities.REC_VIEW_LOAD
                                                          , false
                                                          , recID
                                                          , ""
                                                          , ""
                                                          , clientID
                                                          , transMgmtID
                                                          , null ); 
        });
    }

    /***************************************************************************
     * delete */
    /**    
     *
     * @param  editDelReason   Reason for edit/delete
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/

    public static ReturnSaveRecord delete (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , string        editDelReason
                                            , string        validateRec
                                            , string        clientID
                                            , string        transMgmtID
                                            , string        recID )
    {

        /*----------------------------
         * Check for required and
         * optional parameters
         * and validate data integrity
         * of all supplied parameters
         *----------------------------*/

        long    vClientID     = Validate.reqClientID (uInfo, clientID);
        long    vTransMgmtID  = Validate.reqInteger  (transMgmtID, @"Invalid mgmt id"); 

        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();
        parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@TransMgmtID",  SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));

        /*----------------------------
         * Call base method
         *----------------------------*/

        return Entities.delete (   connSpedmon
                                 , log
                                 , uInfo
                                 , editDelReason
                                 , validateRec
                                 , recID
                                 , "TRANSPORTATION_MGMT_AUTHORIZED_ROUTES_DELETE"
                                 , ref parms);
    }

  }
}
