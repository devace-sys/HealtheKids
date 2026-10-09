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
   * ReturnTransportationMgmtTripCalculation */
  /**
   *
   ***************************************************************************/

  public class ReturnTransportationMgmtTripCalculation: Return
  {
    public ReturnTransportationMgmtTripCalculation ()                 : base(){}
    public ReturnTransportationMgmtTripCalculation (string msg)       : base(msg){}
    public ReturnTransportationMgmtTripCalculation (Exception e)      : base(e){}
    public ReturnTransportationMgmtTripCalculation (Warning e)        : base(e){}
    public ReturnTransportationMgmtTripCalculation (Critical e)       : base(e){}  
    public ReturnTransportationMgmtTripCalculation (SessionExpired e) : base(e){}    
    
    public ReturnTransportationMgmtTripCalculation (int whatis, TransportationMgmtTripCalculation tc):base()
    {
      this.id               = tc.id;
      this.origPlaceID      = tc.origPlaceID;
      this.destPlaceID      = tc.destPlaceID;
      this.distanceInMiles  = tc.distanceInMilesStr;
      this.origAddress      = tc.origAddress;
      this.destAddress      = tc.destAddress;
      this.whatIsResultData = whatis;
    }
            
    public  long     id;
    public  string   origPlaceID;
    public  string   destPlaceID;
    public  string   origAddress;
    public  string   destAddress;
    public  string   distanceInMiles;
    public  int      whatIsResultData;
  }
  
  /***************************************************************************
   * TransportationMgmtTripCalculation */
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtTripCalculation
  {
    public  long     id;
    public  string   origPlaceID;
    public  string   destPlaceID;
    public  decimal? distanceInMiles;
    public  string   distanceInMilesStr;
    public  string   origAddress;
    public  string   destAddress;
    public  DateTime lastUpdated;
    public  bool     active;
    public  long     currentAgeInDays;
  }
  
  /***************************************************************************
   * TransportationMgmtTripCalculations */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtTripCalculations: Entities
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
										              , string        origPlaceID
										              , string        destPlaceID
										              , string        placeID
										              , string        clientID
										              , bool          quickTripLookup
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_VIEW (@userID, @userGroup, @userRank, @origPlaceID, @destPlaceID, @placeID, @clientID, @active, @recID, @quickTripLookup)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
             
      Object  vOrigPlaceID  = Validate.optString    (origPlaceID,  @"Invalid place id");      
      Object  vDestPlaceID  = Validate.optString    (destPlaceID,  @"Invalid place id"); 
      Object  vPlaceID      = Validate.optString    (placeID,      @"Invalid place id"); 
      Object  vClientID      = Validate.optClientID (uInfo, clientID);
            
      parms.Add(Database.SqlParm("@origPlaceID",     SqlDbType.VarChar,  vOrigPlaceID,    ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@destPlaceID",     SqlDbType.VarChar,  vDestPlaceID,    ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@placeID",         SqlDbType.VarChar,  vPlaceID,        ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,   vClientID,       ParameterDirection.Input));
	    
	    parms.Add(Database.SqlParm("@quickTripLookup", SqlDbType.Bit,      quickTripLookup, ParameterDirection.Input));
	                 
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
     * Outputs data for a single record
     *
     *
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @return                 ReturnEntity
     ***************************************************************************/

    public static TransportationMgmtTripCalculation load (  SqlConnection connSpedmon
                                                            , DetailsLog    log
                                                            , UserInfo      uInfo
										                                        , string        origPlaceID
										                                        , string        destPlaceID
                                                          )
    {
      return (TransportationMgmtTripCalculation) Entities.load ( connSpedmon
                                                                 , log
                                                                 , uInfo
                                                                 , typeof (TransportationMgmtTripCalculation)
                                                                 , delegate {          
                                                                   return TransportationMgmtTripCalculations.view (
                                                                        connSpedmon
                                                                      , log
                                                                      , uInfo
                                                                      , Entities.REC_VIEW_RAW
                                                                      , false
                                                                      , null
                                                                      , ""
                                                                      , "Y"
                                                                      , origPlaceID
                                                                      , destPlaceID
                                                                      , null
                                                                      , ""
                                                                      , true
                                                                      , null
                                                                    );
                                                                  });
    }
    
    /***************************************************************************
     * saveOrReplace */
    /**
     * Save trip calc
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Routes's client id
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

    public static ReturnSaveOrReplaceRecord saveOrReplace (   SqlConnection connSpedmon
                                                            , DetailsLog    log
                                                            , UserInfo      uInfo
                                                            , string        clientID
                                                            , string        patID
										                                        , string        origPlaceID
										                                        , string        destPlaceID
										                                        , ReturnGoogleDistanceMatrix  rdm  )  
    {
                             
      Object  vClientID       = Validate.optClientID (uInfo, clientID);      
      Object  vPatID          = Validate.optInteger  (patID,                Messages.INVALID_PAT_ID);
      String  vOrigPlaceID    = Validate.reqString   (origPlaceID,          @"Origin required");
      String  vDestPlaceID    = Validate.reqString   (destPlaceID,          @"Destination required");
      Object  vDistanceMiles  = Validate.optFixed    (rdm.distanceInMiles,  @"Invalid distance miles");
      Object  vDistanceMeters = Validate.optFixed    (rdm.distanceInMeters, @"Invalid distance miles");
      String  vOriginIn       = Validate.optString   (rdm.originIn);
      String  vDestinationIn  = Validate.optString   (rdm.destinationIn);      
      String  vOriginOut      = Validate.optString   (rdm.originOut);
      String  vDestinationOut = Validate.optString   (rdm.destinationOut);
      String  vMapsUrl        = Validate.optString   (rdm.mapsURL);
      String  vRequestData    = Validate.optString   (rdm.requestData);
      String  vResponseData   = Validate.optString   (rdm.responseData);
      
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
                 
      parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,   vClientID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",           SqlDbType.BigInt,   vPatID,           ParameterDirection.Input));
      parms.Add(Database.SqlParm("@origPlaceID",     SqlDbType.VarChar,  vOrigPlaceID,     ParameterDirection.Input, 255));
	    parms.Add(Database.SqlParm("@destPlaceID",     SqlDbType.VarChar,  vDestPlaceID,     ParameterDirection.Input, 255));	    
  	  parms.Add(Database.SqlParm("@distanceMiles",   SqlDbType.Decimal,  vDistanceMiles,   ParameterDirection.Input));

      parms.Add(Database.SqlParm("@distanceMeters",  SqlDbType.Decimal,  vDistanceMeters,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@mapsUrl",         SqlDbType.NVarChar, vMapsUrl,         ParameterDirection.Input, 4000));      
      parms.Add(Database.SqlParm("@origIn",          SqlDbType.NVarChar, vOriginIn,        ParameterDirection.Input, 4000));
      parms.Add(Database.SqlParm("@destIn",          SqlDbType.NVarChar, vDestinationIn,   ParameterDirection.Input, 4000));
      parms.Add(Database.SqlParm("@origOut",         SqlDbType.NVarChar, vOriginOut,       ParameterDirection.Input, 4000));
      parms.Add(Database.SqlParm("@destOut",         SqlDbType.NVarChar, vDestinationOut,  ParameterDirection.Input, 4000));
      parms.Add(Database.SqlParm("@reqData",         SqlDbType.NVarChar, vRequestData,     ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@rspData",         SqlDbType.NVarChar, vResponseData,    ParameterDirection.Input, -1));

      return Entities.saveOrReplaceRecord (   connSpedmon
                                            , log
                                            , uInfo
                                            , "N"
                                            , "TRANSPORTATION_MGMT_TRIP_CALCULATION_SAVE"
                                            , ref parms
                                            , null
                                          );
                            
    }
        
    /***************************************************************************
     * loadRefreshOrNew */
    /**
     * @return  ReturnTransportationMgmtTripCalculation
     ***************************************************************************/

    public static ReturnTransportationMgmtTripCalculation loadRefreshOrNew (  SqlConnection connSpedmon
                                                                            , DetailsLog    log
                                                                            , UserInfo      uInfo
                                                                            , string        clientID
                                                                            , string        patID
										                                                        , string        origPlaceID
										                                                        , string        destPlaceID
										                                                       )  
    {
                       
      
      ReturnTransportationMgmtTripCalculation rd = new ReturnTransportationMgmtTripCalculation();
      
      /*----------------------------
       * If we dont have the origin
       * and destination get out
       *----------------------------*/
      
      if (Util.IsNullOrEmpty(origPlaceID)) return rd;
      if (Util.IsNullOrEmpty(destPlaceID)) return rd;
      
      /*----------------------------
       * Init the various entities
       * we are going to need
       *----------------------------*/

      int                               whatIsResultData = 0;
      bool                              calcDistance     = false;
      
      TransportationMgmtTripCalculation tc               = null;
      TransportationMgmtPlace           op               = null;
      TransportationMgmtPlace           dp               = null;
      ReturnGoogleDistanceMatrix        rdm              = null;
      ReturnSaveOrReplaceRecord         rsr              = null;
            
      /*----------------------------
       * Fetch origin place data
       *----------------------------*/

      op = TransportationMgmtPlaces.load(connSpedmon, log, uInfo, clientID, patID, origPlaceID);
      if (op == null) return rd;      
      
      /*----------------------------
       * Fetch destination place data
       *----------------------------*/

      dp = TransportationMgmtPlaces.load(connSpedmon, log, uInfo, clientID, patID, destPlaceID);
      if (dp == null) return rd;
      
      /*----------------------------
       * Fetch trip calculation data
       *----------------------------*/
            
      tc = TransportationMgmtTripCalculations.load (connSpedmon, log, uInfo, origPlaceID, destPlaceID);
                   
      /*----------------------------
       * Decide what to do
       *----------------------------*/
      
      if (tc == null) 
      {
        calcDistance     = true;
        whatIsResultData = 1;  /* No stored trip */
      }
      else
      {        
        
        calcDistance = Constants.GOOG_DIST_MATRIX_REFRESH_FOR_ALL_REQUESTS;
        
        if (calcDistance == true)
        {
          whatIsResultData = 5; /* Refesh unconditional */
        }
        if ((tc.distanceInMiles.HasValue == false) && (calcDistance == false)) {
          whatIsResultData = 6; /* No miles, try recalc*/
          calcDistance = true;
        }
        if ((op.placeAddress != tc.origAddress) && (calcDistance == false))
        {
           calcDistance = true;
           whatIsResultData = 2; /* Place address has changed*/
        }
        
        if ((dp.placeAddress != tc.destAddress) && (calcDistance == false))
        {
          calcDistance = true;
          whatIsResultData = 2; /* Place address has changed*/
        }
        
        if ((tc.currentAgeInDays >= Constants.GOOG_DIST_MATRIX_REFRESH_MAX_AGE_IN_DAYS) && (calcDistance == false))
        {
          calcDistance = true;  
          whatIsResultData = 3; /* Stale */
        }
        
        if (calcDistance == false)
        {
          whatIsResultData = 4; /* Using existing */
        }
      
      }
                                   
      /*----------------------------
       * If we have to calc or recalc
       * distance, do it, then reload
       *----------------------------*/
      
      if (calcDistance == true)
      {
        rdm = MBA.GeoUtil.computeDistanceAndTravelTime (op.placeAddress, dp.placeAddress, true, false);                
        rsr = saveOrReplace(connSpedmon, log, uInfo, clientID, patID, op.placeID, dp.placeID, rdm);
        tc  = TransportationMgmtTripCalculations.load (connSpedmon, log, uInfo ,op.placeID ,dp.placeID);
      }
      
      /*----------------------------
       * Create results
       * and get out
       *----------------------------*/

      rd = new ReturnTransportationMgmtTripCalculation (whatIsResultData, tc);
      return rd;
      
    } 


    public static ReturnTransportationMgmtTripCalculation loadRefreshOrNew (  SqlConnection connSpedmon
                                                                            , DetailsLog    log
                                                                            , UserInfo      uInfo
										                                                        , string        origPlaceID
										                                                        , string        destPlaceID )  
    {
      
      return loadRefreshOrNew ( connSpedmon, log, uInfo, "", "", origPlaceID, destPlaceID );
    }
    
    
    public static ReturnTransportationMgmtTripCalculation loadRefreshOrNew (  SqlConnection connSpedmon
                                                                            , DetailsLog    log
                                                                            , UserInfo      uInfo
										                                                        , TransportationMgmtTripCalculation rec )  
    {
      
      return loadRefreshOrNew ( connSpedmon, log, uInfo, rec.origPlaceID, rec.destPlaceID );
    }
    
    
    /***************************************************************************
     * viewListByPlaceID*/
    /**
     * @return list
     ***************************************************************************/

    public static List<TransportationMgmtTripCalculation> viewListByPlaceID (   SqlConnection connSpedmon
                                                                              , DetailsLog    log
                                                                              , UserInfo      uInfo 
										                                                          , string        placeID )
    {
      
      bool hasRecords = false;
      
      List<TransportationMgmtTripCalculation> records = new List<TransportationMgmtTripCalculation>();
      
      Object[] recObjs = Entities.loadAllRecords (   connSpedmon
                                                   , log
                                                   , uInfo
                                                   , typeof(TransportationMgmtTripCalculation)                                                                 
                                                   , delegate {          
                                                     return TransportationMgmtTripCalculations.view (   
                                                          connSpedmon
                                                        , log
                                                        , uInfo
                                                        , Entities.REC_VIEW_ALL
                                                        , false
                                                        , ""
                                                        , ""
                                                        , "Y"
                                                        , null
                                                        , null 
                                                        , placeID
                                                        , ""
                                                        , false
                                                        , null );
                                                      }
                                                    , out hasRecords);
      if (hasRecords) {    
        foreach(Object recObj in recObjs) {
          TransportationMgmtTripCalculation record = (TransportationMgmtTripCalculation) recObj;
          records.Add(record);
        }
      } 
    
      return records;
    }
      
    /***************************************************************************
     * viewListByClientID */
    /**
     * @return list
     ***************************************************************************/

    public static List<TransportationMgmtTripCalculation> viewListByClientID (   SqlConnection connSpedmon
                                                                               , DetailsLog    log
                                                                               , UserInfo      uInfo 
                                                                               , string        clientID )
    {
      
      bool hasRecords = false;
      
      List<TransportationMgmtTripCalculation> records = new List<TransportationMgmtTripCalculation>();
      
      Object[] recObjs = Entities.loadAllRecords (   connSpedmon
                                                   , log
                                                   , uInfo
                                                   , typeof(TransportationMgmtTripCalculation)                                                                 
                                                   , delegate {          
                                                     return TransportationMgmtTripCalculations.view (   
                                                          connSpedmon
                                                        , log
                                                        , uInfo
                                                        , Entities.REC_VIEW_ALL
                                                        , false
                                                        , ""
                                                        , ""
                                                        , "Y"
                                                        , null
                                                        , null 
                                                        , null
                                                        , clientID
                                                        , false
                                                        , null );
                                                      }
                                                    , out hasRecords);
      if (hasRecords) {    
        foreach(Object recObj in recObjs) {
          TransportationMgmtTripCalculation record = (TransportationMgmtTripCalculation) recObj;
          records.Add(record);
        }
      } 
    
      return records;
    }

    /***************************************************************************
     * viewListAll */
    /**
     * @return list
     ***************************************************************************/
    public static List<TransportationMgmtTripCalculation> viewListAll (   SqlConnection connSpedmon
                                                                         , DetailsLog    log
                                                                         , UserInfo      uInfo )
    {
      
      bool hasRecords = false;
      
      List<TransportationMgmtTripCalculation> records = new List<TransportationMgmtTripCalculation>();
      
      Object[] recObjs = Entities.loadAllRecords (   connSpedmon
                                                   , log
                                                   , uInfo
                                                   , typeof(TransportationMgmtTripCalculation)                                                                 
                                                   , delegate {          
                                                     return TransportationMgmtTripCalculations.view (   
                                                          connSpedmon
                                                        , log
                                                        , uInfo
                                                        , Entities.REC_VIEW_ALL
                                                        , false
                                                        , ""
                                                        , ""
                                                        , "Y"
                                                        , null
                                                        , null 
                                                        , null
                                                        , ""
                                                        , false
                                                        , null );
                                                      }
                                                    , out hasRecords);
      if (hasRecords) {    
        foreach(Object recObj in recObjs) {
          TransportationMgmtTripCalculation record = (TransportationMgmtTripCalculation) recObj;
          records.Add(record);
        }
      } 
    
      return records;
    }

    /***************************************************************************
     * refreshTripCalcs
    /**
     *
     ***************************************************************************/

    protected static void refreshTripCalcs (  SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo 
                                            , ref List<TransportationMgmtTripCalculation> tripCalcs)
    {
			foreach (TransportationMgmtTripCalculation tripCalc in tripCalcs) {
			  loadRefreshOrNew ( connSpedmon, log, uInfo, tripCalc );
			};
      
      return;
      
    }
    
    /***************************************************************************
     * refreshAllTripCalcsWithPlaceID */
    /**
     * Refreshes all trip data with the given placeID if neccessary
     ***************************************************************************/
    
    public static void refreshAllTripCalcsWithPlaceID (   SqlConnection connSpedmon
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo 
										                , string        placeID)
    {

      if (Util.IsNullOrEmpty(placeID)) return;
    
      List<TransportationMgmtTripCalculation> tripCalcs = viewListByPlaceID (   connSpedmon
                                                                              , log
                                                                              , uInfo 
				  						                                                        , placeID );
      				  						                                                        
	refreshTripCalcs (  connSpedmon, log, uInfo , ref tripCalcs );
			
	return;									                                                        
    }
  
    /***************************************************************************
     * refreshAllTripCalcsWithClientID */
    /**
     * Refreshes all trip data in bulk if neccessary
     ***************************************************************************/
         
    public static void refreshAllTripCalcsWithClientID (  SqlConnection connSpedmon
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        clientID )
    {

    
      List<TransportationMgmtTripCalculation> tripCalcs = viewListByClientID (   connSpedmon
                                                                                , log
                                                                                , uInfo 
                                                                                , clientID );
      				  						                                                        
			refreshTripCalcs (  connSpedmon, log, uInfo , ref tripCalcs );
			
			return;
												                                                        
    }

    /***************************************************************************
     * refreshAllTripCalcs */
    /**
     * Refreshes all trip data in bulk if neccessary
     ***************************************************************************/
         
    public static void refreshAllTripCalcs (  SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                           )
    {

    
      List<TransportationMgmtTripCalculation> tripCalcs = viewListAll (   connSpedmon
                                                                         , log
                                                                         , uInfo 
				  						                                                 );
      				  						                                                        
			refreshTripCalcs (  connSpedmon, log, uInfo , ref tripCalcs );
			
			return;
												                                                        
    }

  }
}
