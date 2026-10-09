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
   * PatientPlace */
  /**
   *
   ***************************************************************************/

  public class PatientPlace : Entity
  {
    public long    clientID;
    public string  clientName;
    public long    patID;
    public string  patName;
    public string  address1;
    public string  address2;
    public string  city;
    public string  state;
    public string  zip5;
    public string  zip4;
    public string  placeID;
    public long    placeClass;
    public string  placeAddress;
  }
  
  /***************************************************************************
   * PatientPlaces */
  /**
   *
   ***************************************************************************/
  
  public class PatientPlaces : Entities
  {
    public const string SEL_LABEL             = "Patient Places";
    public const string SEL_LABEL_ADD         = "Record New";
    public const string SEL_LABEL_VIEW        = "View";
    public const string SEL_LABEL_EDIT_DELETE = "Review, Edit or Delete";
    public const string SEL_LABEL_EDIT        = "Edit";
    public const string SEL_LABEL_DELETE      = "Delete";
    public const string URL_USER_ALL_SAVE     = "user_all_patient_places_save.aspx";
    public const string URL_USER_ALL_EDIT     = "user_all_patient_places_edit_delete.aspx";

    public const string URL_SERVICE_BASE      = @"patient_places.asmx";
    public const string URL_VIEW_SEL          = URL_SERVICE_BASE + @"/viewSel";
    public const string URL_VIEW_INFO         = URL_SERVICE_BASE + @"/viewinfo";

    public static string URL_VIEW_SEL_BASE()
    {
      return MBA.HttpApplication.createLink(PatientPlaces.URL_VIEW_SEL, true);
    }

    public static string URL_VIEW_INFO_BASE()
    {
      return MBA.HttpApplication.createLink(PatientPlaces.URL_VIEW_INFO, true);
    }
    
    /***************************************************************************
     * save */
    /**
     *
     **************************************************************************/  
   
    public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                          , DetailsLog    log
                                          , UserInfo      uInfo
                                          , string        clientID
                                          , string        patID                                          
										  , string        name
										  , string        address1
										  , string        address2
										  , string        city
										  , string        state
										  , string        zip5
                                          , string        zip4
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
     
      long       vClientID      = Validate.reqClientID (uInfo, clientID);      
      long       vPatID         = Validate.reqInteger  (patID,         @"Invalid patient id");
      String     vName          = Validate.reqString   (name,          @"Place name required");
      String     vAddress1      = Validate.optString   (address1,      @"Address required");
      Object     vAddress2      = Validate.optString   (address2,      @"Address required");
      String     vCity          = Validate.reqString   (city,          @"City required");
      String     vState         = Validate.reqString   (state,         @"State required");
      String     vZip5          = Validate.reqString   (zip5,          @"Zip5 required");
      Object     vZip4          = Validate.optString   (zip4,          @"Zip4 is invalid"); 
            
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,   vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.BigInt,   vPatID,       ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@name",      SqlDbType.VarChar,  vName,        ParameterDirection.Input, 500));
      parms.Add(Database.SqlParm("@address1",  SqlDbType.VarChar,  vAddress1,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@address2",  SqlDbType.VarChar,  vAddress2,    ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@city",      SqlDbType.VarChar,  vCity,        ParameterDirection.Input, 100));
      parms.Add(Database.SqlParm("@state",     SqlDbType.VarChar,  vState,       ParameterDirection.Input, 2));
      parms.Add(Database.SqlParm("@zip5",      SqlDbType.VarChar,  vZip5,        ParameterDirection.Input, 5));
      parms.Add(Database.SqlParm("@zip4",      SqlDbType.VarChar,  vZip4,        ParameterDirection.Input, 4));	    
      
      ReturnSaveRecordWithRecordData so = Entities.saveAndReturnRecordData (  connSpedmon
                                                                            , log
                                                                            , uInfo
                                                                            , saveType
                                                                            , validateRec
                                                                            , editDelReason
                                                                            , recID
                                                                            , "PATIENT_PLACES_SAVE"
                                                                            , "There is already an active record with this place name"
                                                                            , ref parms
                                                                            , null );
    
      
      /* Refresh trip calculations (if neccessary) */
      
      TransportationMgmtTripCalculations.refreshAllTripCalcsWithPlaceID (connSpedmon, log, uInfo, so.recData1);
            
      return so;
      
    }
        
    /***************************************************************************
     * viewPlacesInfo*/
    /**
     ***************************************************************************/ 
     
    public static ReturnInfoTable viewPlacesInfo (   SqlConnection connSpedmon
                                                    , DetailsLog   log
                                                    , UserInfo     uInfo
                                                    , string       clientID
                                                    , string       patID )
    {
           
     /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();

      string    viewUDF     = "PATIENT_PLACES_VIEW_INFO (@userID, @userGroup, @userRank, @clientID, @patID)";     
      int       vClientID   = Validate.reqClientID (uInfo, clientID);
      int       vPatID      = Validate.reqInteger  (patID,        Messages.INVALID_PAT_ID);
      
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.BigInt,      vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.BigInt,      vPatID,        ParameterDirection.Input));
                                    
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
         
    }

     /***************************************************************************
      * load */
     /**
      ***************************************************************************/

      public static PatientPlace load (  SqlConnection connSpedmon
                                       , DetailsLog    log
                                       , UserInfo      uInfo
                                       , string        clientID
                                       , string        patID
                                       , string        recID )
      {
        return (PatientPlace) Entities.load (  connSpedmon
                                             , log
                                             , uInfo
                                             , recID
                                             , typeof(PatientPlace)
                                             , delegate { 
                                                 return PatientPlaces.view (   connSpedmon
                                                                             , log
                                                                             , uInfo
                                                                             , Entities.REC_VIEW_LOAD
                                                                             , false
                                                                             , recID
                                                                             , ""
                                                                             , ""
                                                                             , clientID
                                                                             , patID
                                                                             , ""
                                                                             , null ); 
                                             });
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
								  , string        patID
								  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.PATIENT_PLACES_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long    vClientID  = Validate.reqClientID (uInfo, clientID);
      long    vPatID     = Validate.reqInteger  (patID, @"Invalid patient id");       
      string  vTerm      = Validate.optString   (term,  @"Invalid search term");
            
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,  vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.BigInt,  vPatID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",      SqlDbType.VarChar, vTerm,     ParameterDirection.Input, 255));

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
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (   SqlConnection connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo
                                            , bool          paged
                                            , string        pageNumber
                                            , string        canEdit
                                            , string        active
                                            , string        clientID
                                            , string        patID )
    {
      ReturnDataTable so = new ReturnDataTable();
     
      /*----------------------------
       * Define our columns and
       * set the page order for
       * paging
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        ss.addDisplayColumn("id");
        ss.addDisplayColumn("name         as [Place Name]", true);
        ss.addDisplayColumn("placeAddress as [Place Address]");                        
        pageroworder = ss.pageRowOrder();
      };

      /*----------------------------
       * Call base method which
       * handles the rest
       *----------------------------*/

      so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
        delegate { return PatientPlaces.view(  connSpedmon
                                             , log
                                             , uInfo
                                             , Entities.REC_VIEW_TBL
                                             , paged
                                             , pageNumber
                                             , canEdit
                                             , active
                                             , clientID
                                             , patID
                                             , null                                             
                                             , dc); });
   
      /*----------------------------
       * Add a title and footer
       *----------------------------*/
                   
      so.tableName   = @"Patient Places";
      so.tableFooter = Messages.CONFIDENTIAL;
     
      /*----------------------------
       * Done
       *----------------------------*/

      return so;
    }
    
    /***************************************************************************
     * viewSel */
    /**
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
									  , string        patID                                      
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {                     
           ss.addDisplayColumn("placeAddress as context1");           
           ss.addDisplayColumn("placeAddress as recData1");
           ss.addDisplayColumn("placeID      as recData2");

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
                                  return PatientPlaces.view (  connSpedmon
                                                             , log
                                                             , uInfo
                                                             , Entities.REC_VIEW_SEL
                                                             , top
                                                             , topSize
                                                             , ""
                                                             , "Y"
                                                             , clientID
															 , patID
															 , term
                                                             , dc ); 
                                });
                                                                    
    }


  }
}
