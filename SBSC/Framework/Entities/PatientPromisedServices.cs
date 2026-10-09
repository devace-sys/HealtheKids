using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
  /***************************************************************************
   * NonPromisedSpEdService */
  /**
   * 
   **************************************************************************/  

 public class NonPromisedSpEdService
  {
     public int    spEdServiceCode;
     public string spEdServiceName;
     public int    numOfSvcsEntered;
  }
  
  /***************************************************************************
   * PatientPromisedService */
  /**
   * 
   **************************************************************************/   
  public class PatientPromisedService : Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"spEdServiceCodeAndName asc, id desc";

    public long     patID;
    public long     clientID;
    public int      spEdServiceCode;
    public string   spEdServiceCodeAndName;
    public int      spEdProviderCode;
    public string   spEdProviderCodeAndName;
    public int      spEdFreqCode;
    public string   spEdFreqCodeAndName;
    public string   spEdFreqCodeAndNameShort;
    public int      spEdLocationCode;
    public string   spEdLocationCodeAndName;
    public string   startDateStr;
    public string   startDateYYYYMMDD;
    public string   endDateStr;
    public string   endDateYYYYMMDD;
    public bool     individualDelivery;
    public string   individualDeliveryStr;
    public bool     groupDelivery;
    public string   groupDeliveryStr;
    public int      minsPerFreq;
    public bool     replacementDataActive;
	public int?     replacementSpEdServiceCode;
    public string   replacementSpEdServiceCodeAndName;
    public int?     replacementSpEdFreqCode;
    public string   replacementSpEdFreqCodeAndName;
    public int?     replacementMinsPerFreq;
    public int      numSvcLines;
    public bool     hasSvcLinesDetails;
    public string   svcLinesDetailsJSON;
    //public string   svcLinesDetailsHTML;
  }  
  
  /***************************************************************************
   * PatientPromisedServices */
  /**
   * 
   **************************************************************************/  
 
  public class PatientPromisedServices: Entities
  {
    public const string URL_USER_ALL_SAVE_BASE      = @"user_all_pat_promised_services_save.aspx";

    public const string URL_SERVICE_BASE            = @"PatientPromisedServices.asmx";
    public const string URL_REST_DELETE_INLINE_BASE = URL_SERVICE_BASE + @"/deleteinline";
    public const string URL_VIEW_SEL                = URL_SERVICE_BASE + @"/viewSel";
    public const string URL_GET_NON_PROMISED        = URL_SERVICE_BASE + @"/getnonpromisedspedservicesdelivery";
    public const string URL_REST_VIEW_BASE          = @"api/v1/patientpromisedservices";

    /***************************************************************************
     * URL_ADD_NEW_PATIENT_PROMISED_SERVICE */
    /**
     * 
     **************************************************************************/  
    public static string URL_ADD_NEW_PATIENT_PROMISED_SERVICE()
    {
      return MBA.HttpApplication.createLink( PatientPromisedServices.URL_USER_ALL_SAVE_BASE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)                                            
                                            );
    }

    /***************************************************************************
     * URL_EDIT_PATIENT_PROMISED_SERVICE */
    /**
     * 
     **************************************************************************/  
    public static string URL_EDIT_PATIENT_PROMISED_SERVICE()
    {
      return MBA.HttpApplication.createLink (PatientPromisedServices.URL_USER_ALL_SAVE_BASE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                             , new NameValue(Constants.PARM_REC_ID, @"")
                                            );
    }

    /***************************************************************************
     * URL_REST_DELETE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink(PatientPromisedServices.URL_REST_DELETE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(PatientPromisedServices.URL_REST_VIEW_BASE, true);
    }

    /***************************************************************************
     * URL_VIEW_SEL_BASE */
    /**
     * 
     **************************************************************************/

    public static string URL_VIEW_SEL_BASE()
    { 
       return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
    }

    /***************************************************************************
     * generateUrlGetNonPromised */
    /**
     * 
     **************************************************************************/

    public static string generateUrlGetNonPromised(string clientID, string patID, string startDate, string endDate)
    {
      return MBA.HttpApplication.createLink (  URL_GET_NON_PROMISED
                                              , true
                                              , new NameValue(Constants.PARM_CLIENT_ID,  clientID)
                                              , new NameValue(Constants.PARM_PATIENT_ID, patID)
                                              , new NameValue(Constants.PARM_START_DATE, startDate)
                                              , new NameValue(Constants.PARM_END_DATE,   endDate));
    }
 
    /***************************************************************************
     * view */
    /**
     * 
     **************************************************************************/

    public static ReturnDB view (  SqlConnection connSpedmon
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
                                 , string        refDate
                                 , defineCols    dc
                                 , bool requirePatID = false)
    { 

      var viewUDF = "PATIENT_PROMISED_SERVICES_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @refDate, @term, @recID, @canEdit, @active)";  /* recid is null for now... */
 
      var parms = new List<SqlParameter>();
 
      /*----------------------------
       * Validate parameters specific
       * to this entity.view that 
       * will be used in all cases
       *----------------------------*/  
      
      Object    vClientID       = Validate.optClientID (uInfo, clientID);      
      Object    vPatID;
      
      if (requirePatID == true)
      {
        vPatID = Validate.reqPatID(uInfo, patID);
      }
      else
      {
        vPatID = Validate.optInteger(patID, Messages.INVALID_PAT_ID);
      }

      Object    vRefDate        = Validate.optDate     (refDate,       @"Invalid reference date");
      Object    vCanEdit        = Validate.optFlag     (canEdit,        Messages.INVALID_EDIT_FLAG);
      Object    vTerm           = Validate.optString(term);   
      Object    vIdx            = Validate.optInteger(idx, "Invalid id or page number");
              
      /*----------------------------
       * Populate database parameters
       *----------------------------*/
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt     ,   vClientID,            ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt     ,   vPatID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@refDate",              SqlDbType.Date       ,   vRefDate,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar    ,   vTerm,                ParameterDirection.Input, 50));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
        
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
    }

    /***************************************************************************
     * load */
    /**
     * 
     **************************************************************************/  

    public static PatientPromisedService load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
        return (PatientPromisedService)Entities.load(connSpedmon, log, uInfo, recID, typeof(PatientPromisedService),
        delegate {
            return PatientPromisedServices.view(connSpedmon
                            , log
                            , uInfo
                            , Entities.REC_VIEW_LOAD
                            , false
                            , recID
                            , ""
                            , ""
                            , ""
                            , ""
                            , null
                            , null
                            , null); });
    }
   
    /***************************************************************************
     * viewSel */
    /**
     * 
     **************************************************************************/  

    public static ReturnSel viewSel(SqlConnection connSpedmon,
                                        DetailsLog log,
                                        UserInfo uInfo,
                                        bool top,
                                        string topSize,
                                        string active,
                                        string clientID,
                                        string patID,
                                        string term)
    {
            
            /*----------------------------
             * Define our context column
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("spEdFreqCodeStr as recData1");
                ss.addDisplayColumn("spEdFreqCodeAndNameShort as recData2");
                ss.addDisplayColumn("minsPerFreqStr as recData3");
                ss.addDisplayColumn("startDateYYYYMMDD as recData4");
                ss.addDisplayColumn("endDateYYYYMMDD as recData5");
                ss.addDisplayColumn("spEdServiceCodeStr as recData6");
                ss.addDisplayColumn("spEdFreqName as recData7");
                ss.addDisplayColumn("numSvcLinesStr as recData8");
                ss.addDisplayColumn("hasSvcLinesDetailsStr as recData9");                
                ss.addDisplayColumn("svcLinesDetailsJSON as recData10");
                ss.addDisplayColumn("selContextHTML as context1");
            };                         
            
            DateTime startDate;
            DateTime endDate;
            Util.computeClaimingYear(out startDate, out endDate);

            string refDate = startDate.ToShortDateString();
            
            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", active, clientID, patID, term, refDate, dc, true); });

    }

    /***************************************************************************
     * viewObjects */
    /**
     * 
     **************************************************************************/  

    public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , bool pageObjectList
                                             , string pageOrder
                                             , string idx
                                             , string active
                                             , string clientID
                                             , string patID)
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientPromisedService.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PatientPromisedService)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return PatientPromisedServices.view ( connSpedmon
                                                                               , log
                                                                               , uInfo
                                                                               , Entities.REC_VIEW_OBJECTS
                                                                               , pageObjectList
                                                                               , idx
                                                                               , "" /* Can edit */
                                                                               , active
                                                                               , clientID
                                                                               , patID
                                                                               , null
                                                                               , null
                                                                               , dc);
                                      });
 
 
    }
 
    /***************************************************************************
     * deleteInline */
    /**
     * 
     **************************************************************************/  
 
    public static ReturnSaveRecord deleteInline(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , string recID)
    {
        string deleteSproc  = @"PATIENT_PROMISED_SERVICE_Delete_Inline";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      List<SqlParameter> parms = new List<SqlParameter>();
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo, @"", "N", recID,deleteSproc,ref parms);
    }
 
    /***************************************************************************
     * save */
    /**
     * 
     **************************************************************************/  

    public static ReturnSaveRecord save(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo
                                        , string patID
                                        , string spEdServiceCode
                                        , string spEdProviderCode
                                        , string spEdFreqCode
                                        , string spEdLocationCode
                                        , string startDate
                                        , string endDate
                                        , string individualDelivery
                                        , string groupDelivery
                                        , string minsPerFreq
                                        , string replacementDataActive
                                        , string replacementSpEdServiceCode
                                        , string replacementSpEdFreqCode
                                        , string replacementMinsPerFreq
                                        , string editDelReason
                                        , string validateRec
                                        , string saveType
                                        , string recID)
    {

        long    vPatID              = Validate.reqInteger (patID,              Messages.INVALID_PAT_ID);
        int     vSpEdServiceCode    = Validate.reqInteger (spEdServiceCode,    @"Invalid service");
        int     vSpEdProviderCode   = Validate.reqInteger (spEdProviderCode,   @"Invalid service provider");
        int     vSpEdFreqCode       = Validate.reqInteger (spEdFreqCode,       @"Invalid service frequency");
        int     vSpEdLocationCode   = Validate.reqInteger (spEdLocationCode,   @"Invalid service location");

        Object  vStartDate          = Validate.optDate    (startDate,          Messages.INVALID_START_DATE);
        Object  vEndDate            = Validate.optDate    (endDate,            Messages.INVALID_END_DATE);
        Object  vIndividualDelivery = Validate.optFlag    (individualDelivery, @"Invalid individual delivery flag");
        Object  vGroupDelivery      = Validate.optFlag    (groupDelivery,      @"Invalid group delivery flag");
        Object  vMinsPerFreq        = Validate.optInteger (minsPerFreq,        @"Invalid minutes per frequency",  true);

        Object  vReplacementDataActive         = Validate.optFlag    (replacementDataActive,         @"Invalid use replacement data flag");
        Object  vReplacementSpEdServiceCode    = Validate.optInteger (replacementSpEdServiceCode,    @"Invalid replacement service");
        Object  vReplacementSpEdFreqCode       = Validate.optInteger (replacementSpEdFreqCode,       @"Invalid replacement service frequency");
        Object  vReplacementMinsPerFreq        = Validate.optInteger (replacementMinsPerFreq,        @"Invalid replacement duration",  true);
 
        var parms = new List<SqlParameter>();
 
        parms.Add(Database.SqlParm("@patID",              SqlDbType.BigInt, vPatID,              ParameterDirection.Input));
        parms.Add(Database.SqlParm("@spEdServiceCode",    SqlDbType.Int,    vSpEdServiceCode,    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@spEdProviderCode",   SqlDbType.Int,    vSpEdProviderCode,   ParameterDirection.Input));
        parms.Add(Database.SqlParm("@spEdFreqCode",       SqlDbType.Int,    vSpEdFreqCode,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@spEdLocationCode",   SqlDbType.Int,    vSpEdLocationCode,   ParameterDirection.Input));
        parms.Add(Database.SqlParm("@startDate",          SqlDbType.Date,   vStartDate,          ParameterDirection.Input));
        parms.Add(Database.SqlParm("@endDate",            SqlDbType.Date,   vEndDate,            ParameterDirection.Input));
        parms.Add(Database.SqlParm("@individualDelivery", SqlDbType.Bit,    vIndividualDelivery, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@groupDelivery",      SqlDbType.Bit,    vGroupDelivery,      ParameterDirection.Input));
        parms.Add(Database.SqlParm("@minsPerFreq",        SqlDbType.Int,    vMinsPerFreq,        ParameterDirection.Input));
 
        parms.Add(Database.SqlParm("@replacementDataActive",         SqlDbType.Bit,    vReplacementDataActive,         ParameterDirection.Input));
        parms.Add(Database.SqlParm("@replacementSpEdServiceCode",    SqlDbType.Int,    vReplacementSpEdServiceCode,    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@replacementSpEdFreqCode",       SqlDbType.Int,    vReplacementSpEdFreqCode,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@replacementMinsPerFreq",        SqlDbType.Int,    vReplacementMinsPerFreq,        ParameterDirection.Input));
 
        return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, "PATIENT_PROMISED_SERVICE_Save", Messages.DUP_CLIENT_REC, ref parms, null);
    }
 
    /***************************************************************************
     * getNonPromisedSpEdServiceDelivery 
     *
     * Returns a list of non promised services objects that were delivered
     * 
     ***************************************************************************/
    public static ReturnObjects getNonPromisedSpEdServicesDelivery  (  SqlConnection connSpedmon
                                                                      , DetailsLog   log
                                                                      , UserInfo     uInfo
                                                                      , string       clientID
                                                                      , string       patID
                                                                      , string       startDate
                                                                      , string       endDate )
    {

        ReturnObjects so = new ReturnObjects();

        var clientIDVal  = Validate.reqClientID (uInfo, clientID);
        var patIDVal     = Validate.reqInteger  (patID,      Messages.INVALID_PAT_ID);
        var startDateVal = Validate.reqDate     (startDate,  Messages.INVALID_START_DATE);
        var endDateVal   = Validate.reqDate     (endDate,    Messages.INVALID_END_DATE);

        var parms = new List<SqlParameter>();      

        parms.Add(Database.SqlParm("@clientID",               SqlDbType.Int,  clientIDVal,  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@patID",                  SqlDbType.Int,  patIDVal,     ParameterDirection.Input));
        parms.Add(Database.SqlParm("@planInEffectStartDate",  SqlDbType.Date, startDateVal, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@planInEffectEndDate",    SqlDbType.Date, endDateVal,   ParameterDirection.Input));
            
        string sql = @"select * from dbo.PATIENT_NON_PROMISED_SPED_SERVICES_DELIVERY_FOR_A_PATIENT_DETAILS_VIEW (@clientID,@patID,@planInEffectStartDate,@planInEffectEndDate)";
        ReturnDB rd  = Database.execQuery(connSpedmon, log, sql, false, parms);
        so.hasRecords = rd.hasRecords;
        if (rd.hasRecords){ 
          so.data = Database.convertRecordsToList(ref rd.records, typeof(NonPromisedSpEdService)).ToArray();
        }
        return so;
    }
  }
}