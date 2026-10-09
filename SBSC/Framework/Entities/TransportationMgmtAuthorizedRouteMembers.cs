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
   * TransportationMgmtAuthorizedRouteMember */
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtAuthorizedRouteMember : Entity
  {
  
    public const string DEFAULT_PAGING_ORDER = @"displayOrder asc, name asc";

    public  long     clientID;
    public  string   clientName;
    
    public  long     routeID;
    public  string   routeName;
    
    public  string   origName;
    public  string   origAddress;
    public  string   origPlaceID;
    
    public  string   destName;
    public  string   destAddress;
    public  string   destPlaceID;
    
    public  decimal? distanceMiles;
    public  string   distanceMilesStr;
    
    public  long     patID;
    public  string   patName;
    public  DateTime patDOB;
    public  string   patDOBStr;
    
    public  string   sitePlaceID;
    public  string   siteName;
    public  string   siteAddress;

    public  string   homePlaceID;
    public  string   homeName;
    public  string   homeAddress;
    
    public  long    transMgmtID;
    public  long    transMgmtAuthPatID;
    public  long    transMgmtAuthRouteMemberID;

    public  string  weekDaysJSON;
    public  bool    scheduledForMon  = true;
    public  bool    scheduledForTue  = true;
    public  bool    scheduledForWed  = true;
    public  bool    scheduledForThur = true;
    public  bool    scheduledForFri  = true;

    public  string  selectAmPm;
    
  }
  
  /***************************************************************************
   * TransportationMgmtAuthorizedRouteMembers */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtAuthorizedRouteMembers : Entities
  {

    public const string URL_REST_VIEW    = @"api/v1/transportationmgmtauthorizedroutemembers";

    public const string URL_WEB_SERVICE  = @"transport_mgmt_auth_route_members.asmx";
    public const string URL_SAVE         = URL_WEB_SERVICE + @"/save";
    public const string URL_DELETE       = URL_WEB_SERVICE + @"/delete";
    public const string URL_VIEW_SEL     = URL_WEB_SERVICE + @"/viewSel";
    public const string URL_SAVE_MEMBERS_DISPLAY_ORDER = URL_WEB_SERVICE + @"/saveMembersDisplayOrder";
  
    public static string URL_REST_VIEW_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRouteMembers.URL_REST_VIEW, true);
    }

    public static string URL_SAVE_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRouteMembers.URL_SAVE, true);
    }

    public static string URL_DELETE_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRouteMembers.URL_DELETE, true);
    }

    public static string URL_VIEW_SEL_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRouteMembers.URL_VIEW_SEL, true);
    }

    public static string URL_SAVE_MEMBERS_DISPLAY_ORDER_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedRouteMembers.URL_SAVE_MEMBERS_DISPLAY_ORDER, true);
    }

    /***************************************************************************
     * save */
    /**
     * Save an authorized route member
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

    public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
                                          , string        transMgmtID
                                          , string        routeID
                                          , string        patID                                          
										  , string        origPlaceID
										  , string        destPlaceID
										  , string        weekDaysJSON
										  , string        selectAmPm
                                          , string        editDelReason
                                          , string        validateRec
                                          , string        saveType
                                          , string        recID )  
    {
           
      /*----------------------------
       * Take care of trip 
       * calculation
       *----------------------------*/

      ReturnTransportationMgmtTripCalculation rtc = TransportationMgmtTripCalculations.loadRefreshOrNew (connSpedmon, log, uInfo, clientID, patID, origPlaceID, destPlaceID);

      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
     
      long       vClientID        = Validate.reqClientID (uInfo,                clientID);
      long       vTransMgmtID     = Validate.reqInteger  (transMgmtID,          @"Invalid mgmt id"); 
      long       vRouteID         = Validate.reqInteger  (routeID,              @"Invalid route id"); 
      long       vPatID           = Validate.reqInteger  (patID,                @"Invalid patient id");     
      Object     vOrigPlaceID     = Validate.optString   (origPlaceID,          @"Origin address required");      
      Object     vDestPlaceID     = Validate.optString   (destPlaceID,          @"Destination address required");                  
      string     vWeekDaysJSON    = Validate.reqString   (weekDaysJSON,         @"Invalid days of the week values");
      object     vSelectAmPm      = Validate.optString   (selectAmPm,           @"Invalid value for AM/PM");
            
      parms.Add(Database.SqlParm("@clientID",        SqlDbType.BigInt,   vClientID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",     SqlDbType.BigInt,   vTransMgmtID,     ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@routeID",         SqlDbType.BigInt,   vRouteID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",           SqlDbType.BigInt,   vPatID,           ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@origPlaceID",     SqlDbType.VarChar,  vOrigPlaceID,     ParameterDirection.Input, 255));      
	  parms.Add(Database.SqlParm("@destPlaceID",     SqlDbType.VarChar,  vDestPlaceID,     ParameterDirection.Input, 255));	    
      parms.Add(Database.SqlParm("@weekDaysJSON",    SqlDbType.VarChar,  vWeekDaysJSON,    ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@selectAmPm",      SqlDbType.VarChar,  vSelectAmPm,      ParameterDirection.Input, 256));

      return Entities.save ( connSpedmon
                            , log
                            , uInfo
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID
                            , "TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE"
                            , "There is already an active record with this patient"
                            , ref parms
                            , null );
    }


    /***************************************************************************
     * saveMembersDisplayOrder */
    /**
     * Save an authorized route member
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

    public static ReturnSaveRecord saveMembersDisplayOrder (   SqlConnection connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , string        clientID
                                                             , string        transMgmtID
                                                             , string        routeID
                                                             , string        membersDisplayOrder )  
    {
     
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
     
      long       vClientID            = Validate.reqClientID      (uInfo,              clientID);
      long       vTransMgmtID         = Validate.reqInteger       (transMgmtID,        @"Invalid mgmt id"); 
      long       vRouteID             = Validate.reqInteger       (routeID,            @"Invalid route id");
      string     vMembersDisplayOrder = Validate.reqRecIDMultiStr (membersDisplayOrder,@"Invalid list"); 
      
            
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,   vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",          SqlDbType.BigInt,   vTransMgmtID,         ParameterDirection.Input));
	    parms.Add(Database.SqlParm("@routeID",              SqlDbType.BigInt,   vRouteID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@membersDisplayOrder",  SqlDbType.VarChar,  vMembersDisplayOrder, ParameterDirection.Input, 8000));
      	          
      return Entities.save ( connSpedmon
                            , log
                            , uInfo
                            , Constants.SAVE_TYPE_NEW.ToString()                            
                            , "N"
                            , ""
                            , ""
                            , "TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_SAVE_DISPLAY_ORDER"
                            , "There is already an active display order"
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
                                  , string        routeID
                                  , string        patID
                                  , string        authPatRecID     
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_VIEW (@userID, @userGroup, @userRank, @clientID, @transMgmtID, @transMgmtAuthPatID, @patID, @routeID, @active, @recID)";
      
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
      Object  vRouteID      = Validate.optInteger  (routeID,      @"Invalid route id");       
      Object  vPatID        = Validate.optInteger  (patID,        @"Invalid patient id");
      Object  vAuthPatID    = Validate.optInteger  (authPatRecID, @"Invalid auth patient rec id");
      
      parms.Add(Database.SqlParm("@clientID",           SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtID",        SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@routeID",            SqlDbType.BigInt,  vRouteID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",              SqlDbType.BigInt,  vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@transMgmtAuthPatID", SqlDbType.BigInt,  vAuthPatID,   ParameterDirection.Input));
      
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
     * viewSel */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
                                      , string        transMgmtID
                                      , string        routeID
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
           
          ss.addDisplayColumn("origToDestSummary as context1");
          
          ss.addDisplayColumn("origName      as [recData1]");
          ss.addDisplayColumn("origAddress   as [recData2]");        
          ss.addDisplayColumn("origPlaceID   as [recData3]");

          ss.addDisplayColumn("destName      as [recData4]");
          ss.addDisplayColumn("destAddress   as [recData5]");
          ss.addDisplayColumn("destPlaceID   as [recData6]");
        
          ss.addDisplayColumn("distanceMilesStr as [recData7]");
          
          ss.addDisplayColumn("sitePlaceID      as [recData8]");
          ss.addDisplayColumn("siteName         as [recData9]");
          ss.addDisplayColumn("siteAddress      as [recData10]");

          ss.addDisplayColumn("homePlaceID     as [recData11]");
          ss.addDisplayColumn("homeName        as [recData12]");
          ss.addDisplayColumn("homeAddress     as [recData13]");
          
          ss.addDisplayColumn("weekDaysJSON    as [recData14]");
          ss.addDisplayColumn("selectAmPm      as [recData15]");


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
                                  return TransportationMgmtAuthorizedRouteMembers.view (   connSpedmon
                                                                                     , log
                                                                                     , uInfo
                                                                                     , Entities.REC_VIEW_SEL
                                                                                     , top
                                                                                     , topSize
                                                                                     , ""
                                                                                     , "Y"
                                                                                     , clientID
                                                                                     , transMgmtID
                                                                                     , routeID
                                                                                     , ""
                                                                                     , ""
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

    public static TransportationMgmtAuthorizedRouteMember load (  SqlConnection connSpedmon
                                                                , DetailsLog    log
                                                                , UserInfo      uInfo
                                                                , string        clientID
                                                                , string        transMgmtID
                                                                , string        routeID
                                                                , string        patID
                                                                , string        recID )
    {
      return (TransportationMgmtAuthorizedRouteMember) Entities.load(  connSpedmon
                                                                     , log
                                                                     , uInfo
                                                                     , recID
                                                                     , typeof (TransportationMgmtAuthorizedRouteMember)
                                                                     , delegate { 
         
         return TransportationMgmtAuthorizedRouteMembers.view (  connSpedmon
                                                               , log
                                                               , uInfo
                                                               , Entities.REC_VIEW_LOAD
                                                               , false
                                                               , recID
                                                               , ""
                                                               , ""
                                                               , clientID
                                                               , transMgmtID
                                                               , routeID
                                                               , patID
                                                               , ""
                                                               , null ); 
        });
    }


    /***************************************************************************
     * loadAllRecords */
    /**    
     *
     ***************************************************************************/

    public static List<TransportationMgmtAuthorizedRouteMember> loadAllRecords (  SqlConnection connSpedmon
                                                                                , DetailsLog    log
                                                                                , UserInfo      uInfo
                                                                                , string        clientID
                                                                                , string        transMgmtID
                                                                                , string        routeID) 
    {
      
      List<TransportationMgmtAuthorizedRouteMember> listItems = new List<TransportationMgmtAuthorizedRouteMember>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (TransportationMgmtAuthorizedRouteMember)
                                      , delegate { 
                                        return TransportationMgmtAuthorizedRouteMembers.view ( connSpedmon
                                                                                 , log
                                                                                 , uInfo
                                                                                 , Entities.REC_VIEW_ALL
                                                                                 , false
                                                                                 , ""
                                                                                 , ""
                                                                                 , "Y"                                                                                 
                                                                                 , clientID
                                                                                 , transMgmtID
                                                                                 , routeID
                                                                                 , ""
                                                                                 , ""
                                                                                 , null);}
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          TransportationMgmtAuthorizedRouteMember listItem = (TransportationMgmtAuthorizedRouteMember) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
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
                                            , string        routeID
                                            , string        patID
                                            , string        recID )
    {

        /*----------------------------
         * Check for required and
         * optional parameters
         * and validate data integrity
         * of all supplied parameters
         *----------------------------*/

        long    vClientID       = Validate.reqClientID (uInfo, clientID);
        long    vTransMgmtID    = Validate.reqInteger  (transMgmtID,   @"Invalid mgmt id"); 
        long    vRouteID        = Validate.reqInteger  (routeID,       @"Invalid route id"); 
        long    vPatID          = Validate.reqInteger  (patID,         @"Invalid patient id");

        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt,  vClientID,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@transMgmtID",    SqlDbType.BigInt,  vTransMgmtID,    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@routeID",        SqlDbType.BigInt,  vRouteID,        ParameterDirection.Input));
        parms.Add(Database.SqlParm("@patID",          SqlDbType.BigInt,  vPatID,          ParameterDirection.Input));

        /*----------------------------
         * Call base method
         *----------------------------*/

        return Entities.delete (   connSpedmon
                                 , log
                                 , uInfo
                                 , editDelReason
                                 , validateRec
                                 , recID
                                 , "TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS_DELETE"
                                 , ref parms);
    }

    /*************************************************************************
    * viewList */
   /**
    * Return a list of Route Member records
    * 
    ***************************************************************************/

    public static List<TransportationMgmtAuthorizedRouteMember> viewList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        transMgmtID
                                                         , string        patID
                                                         , string        active)
      
     {
        var recs = new List<TransportationMgmtAuthorizedRouteMember>();
        ReturnDB rd = TransportationMgmtAuthorizedRouteMembers.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, transMgmtID, null, null, patID, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(TransportationMgmtAuthorizedRouteMember));
        foreach (var o in slo) {
            recs.Add((TransportationMgmtAuthorizedRouteMember) o);
        }
        return recs;
    }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/
    public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                              , DetailsLog log
                                              , UserInfo uInfo
                                              , bool pageObjectList
                                              , string pageOrder
                                              , string idx
                                              , string active
                                              , string clientID
                                              , string transMgmtID
                                              , string routeID
    )
    {

        /* Default page order */

        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = TransportationMgmtAuthorizedRouteMember.DEFAULT_PAGING_ORDER;

        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };

        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(TransportationMgmtAuthorizedRouteMember)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate
                                      {
                                          return TransportationMgmtAuthorizedRouteMembers.view(
                                                                     connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_OBJECTS
                                                                   , pageObjectList
                                                                   , idx
                                                                   , "" // canEdit
                                                                   , active
                                                                   , clientID
                                                                   , transMgmtID
                                                                   , routeID
                                                                   , ""
                                                                   , ""
                                                                   , dc
                                           );
                                      });
    }

  }
}
