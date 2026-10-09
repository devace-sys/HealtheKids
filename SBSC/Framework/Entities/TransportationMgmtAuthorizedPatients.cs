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
   * TransportationMgmtAuthorizedPatient */
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtAuthorizedPatient : Entity
  {
    public long    clientID;
    public string  clientName;
    public long    patID;
    public string  patName;
    
    public string  siteName;
    public string  siteAddress;        
    public string  sitePlaceID;
    
    public string  homeName;
    public string  homeAddress;
    public string  homePlaceID;

    public DateTime patDOB;
    public string   patDOBStr;
    public string   patSSID;

    public int     assignedRouteCount;
    public string  assignedRouteNames;

  }
  
  /***************************************************************************
   * TransportationMgmtAuthorizedPatients */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtAuthorizedPatients : Entities
  {
  
    public const string URL_SERVICE_BASE            = @"transport_mgmt_auth_patients.asmx";
    public const string URL_SAVE                    = URL_SERVICE_BASE + @"/save";
    public const string SEL_LABEL                   = @"Transportation Services - Authorized Patients";
    public const string URL_WEB_REPORT_BASE         = "transport_mgmt_auth_patients.ashx";

    /***************************************************************************
     * URL_SAVE_BASE */
    /**
     ***************************************************************************/

    public static string URL_SAVE_BASE()
    {
      return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedPatients.URL_SAVE, true);
    }
    
    /***************************************************************************
     * URL_WEB_REPORT */
    /**
     ***************************************************************************/
    public static string URL_WEB_REPORT()
    {
      return MBA.HttpApplication.createLink(TransportationMgmtAuthorizedPatients.URL_WEB_REPORT_BASE, true);
    }

    /***************************************************************************
     * save */
    /**
     * Save an authorized patient
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Patient's client id
     * @param  patID
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
                                          , string        patID
                                          , string        sitePlaceID
                                          , string        homePlaceID                                          
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
     
      long   vClientID      = Validate.reqClientID (uInfo,       clientID);
      long   vTransMgmtID   = Validate.reqInteger  (transMgmtID, @"Invalid mgmt id"); 
      long   vPatID         = Validate.reqInteger  (patID,       Messages.INVALID_PAT_ID);
      
      Object vSitePlaceID   = Validate.optString  (sitePlaceID, @"Invalid site place id");      
      Object vHomePlaceID   = Validate.optString  (homePlaceID, @"Invalid home place id");
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@TransMgmtID",  SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.BigInt,  vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@sitePlaceID",  SqlDbType.VarChar, vSitePlaceID, ParameterDirection.Input, 255));      
      parms.Add(Database.SqlParm("@homePlaceID",  SqlDbType.VarChar, vHomePlaceID, ParameterDirection.Input, 255));
           
      return Entities.save (  connSpedmon
                            , log
                            , uInfo
                            , saveType
                            , validateRec
                            , editDelReason
                            , recID
                            , "TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_SAVE"
                            , "There is already a patient with this ID assigned"
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
                                  , string        patID
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_VIEW (@userID, @userGroup, @userRank, @clientID, @transMgmtID, @patID, @term, @active, @recID)";
      
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
      Object  vPatID        = Validate.optInteger  (patID,       @"Invalid patient id");
      Object  vTerm         = Validate.optString   (term,        @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@TransMgmtID",  SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.BigInt,  vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",         SqlDbType.VarChar, vTerm,        ParameterDirection.Input));
      
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
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("patDOBStr + ' | ' + siteName + ' | ' + homeName as context1");
          ss.addDisplayColumn("siteName      as [recData1]");
          ss.addDisplayColumn("siteAddress   as [recData2]");        
          ss.addDisplayColumn("sitePlaceID   as [recData3]");
          ss.addDisplayColumn("homeName      as [recData4]");
          ss.addDisplayColumn("homeAddress   as [recData5]");
          ss.addDisplayColumn("homePlaceID   as [recData6]");
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
                                  return TransportationMgmtAuthorizedPatients.view (   connSpedmon
                                                                                     , log
                                                                                     , uInfo
                                                                                     , Entities.REC_VIEW_SEL
                                                                                     , top
                                                                                     , topSize
                                                                                     , ""
                                                                                     , "Y"
                                                                                     , clientID
                                                                                     , transMgmtID
                                                                                     , ""
                                                                                     , term
                                                                                     , dc); 
                                  });
                                                                    
    }

    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl ( SqlConnection connSpedmon
                                           , DetailsLog   log
                                           , UserInfo     uInfo
                                           , bool         paged
                                           , string       pageNumber
                                           , string       canEdit
                                           , string       active
                                           , string       clientID
                                           , string       transMgmtID
    )
    {
        ReturnDataTable so = new ReturnDataTable();

        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("name                      as [Student Name]", true);
            ss.addDisplayColumn("patDOBStr                 as [Date\nof\nBirth]");
            ss.addDisplayColumn("patSSID                   as [SSID]");
            ss.addDisplayColumn("assignedRouteCount        as [Number\nOf\nAssigned\nRoutes]");
            ss.addDisplayColumn("assignedRouteNames        as [Assigned Routes]");
            pageroworder = ss.pageRowOrder();
        };

        /*----------------------------
         * Call base method which
         * handles the rest
         *----------------------------*/

        so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
            delegate {
                return TransportationMgmtAuthorizedPatients.view (  connSpedmon
                                                                   , log
                                                                   , uInfo
                                                                   , Entities.REC_VIEW_TBL
                                                                   , paged
                                                                   , pageNumber
                                                                   , ""
                                                                   , "Y"
                                                                   , clientID
                                                                   , transMgmtID
                                                                   , ""
                                                                   , ""
                                                                   , dc); 
            });

        /*----------------------------
         * Add a title and footer
         *----------------------------*/

        so.tableName = SEL_LABEL;
        so.tableFooter = Messages.CONFIDENTIAL;

        /*----------------------------
         * Done
         *----------------------------*/

        return so;
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

    public static TransportationMgmtAuthorizedPatient load (   SqlConnection connSpedmon
                                                             , DetailsLog    log
                                                             , UserInfo      uInfo
                                                             , string        clientID
                                                             , string        transMgmtID
                                                             , string        patID
                                                             , string        recID )
    {
      return (TransportationMgmtAuthorizedPatient) Entities.load (  connSpedmon
                                                                  , log
                                                                  , uInfo
                                                                  , recID
                                                                  , typeof (TransportationMgmtAuthorizedPatient)
                                                                  , delegate { 
         
         return TransportationMgmtAuthorizedPatients.view (   connSpedmon
                                                           , log
                                                           , uInfo
                                                           , Entities.REC_VIEW_LOAD
                                                           , false
                                                           , recID
                                                           , ""
                                                           , ""
                                                           , clientID
                                                           , transMgmtID
                                                           , patID
                                                           , ""
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
                                            , string        patID
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
        long    vPatID        = Validate.reqInteger  (patID,       Messages.INVALID_PAT_ID);

        /*----------------------------
         * Collect all of the parameters
         * that are specific to this
         * delete method.
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();
  
        parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@TransMgmtID",  SqlDbType.BigInt,  vTransMgmtID, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@patID",        SqlDbType.BigInt,  vPatID,       ParameterDirection.Input));

        /*----------------------------
         * Call base method
         *----------------------------*/

        return Entities.delete (   connSpedmon
                                 , log
                                 , uInfo
                                 , editDelReason
                                 , validateRec
                                 , recID
                                 , "TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS_DELETE"
                                 , ref parms);
    }

  }
}
