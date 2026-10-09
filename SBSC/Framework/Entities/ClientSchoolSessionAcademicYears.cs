using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using MBA;


namespace Spedmon
{
    
  /***************************************************************************
   * ClientSchoolSessionAcademicYear */
  /**
   *
   **************************************************************************/

  public class ClientSchoolSessionAcademicYear: Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"startDate desc, endDate desc";
    public long    clientID;
    public long    companyFiscalYearID;
    public string  companyFiscalYearName;
    public string  startDateStr;
    public string  endDateStr;
    public string  startDateStrYMD;
    public string  endDateStrYMD;
  }

  /***************************************************************************
   * ClientSchoolSessionAcademicYears */
  /**
   ***************************************************************************/   
  
  public class ClientSchoolSessionAcademicYears:Entities
  {

    public const string URL_SERVICE_BASE               = @"client_school_session_academic_years.asmx";
    public const string URL_REST_SAVE_INLINE_BASE      = URL_SERVICE_BASE + @"/saveinline";
    public const string URL_REST_DELETE_INLINE_BASE    = URL_SERVICE_BASE + @"/deleteinline";
    public const string URL_REST_VIEW_SEL_INLINE_BASE  = URL_SERVICE_BASE + @"/viewSel";
    public const string URL_REST_VIEW_BASE             = @"api/v1/clientschoolsessionacademicyears";

    /***************************************************************************
     * URL_REST_SAVE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_SAVE_INLINE()
    {
        return MBA.HttpApplication.createLink(ClientSchoolSessionAcademicYears.URL_REST_SAVE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_DELETE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink(ClientSchoolSessionAcademicYears.URL_REST_DELETE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_VIEW_SEL_INLINE */
    /**
     * 
     **************************************************************************/ 
    public static string URL_REST_VIEW_SEL_INLINE()
    {
        return MBA.HttpApplication.createLink(ClientSchoolSessionAcademicYears.URL_REST_VIEW_SEL_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(ClientSchoolSessionAcademicYears.URL_REST_VIEW_BASE, true);
    }

    /***************************************************************************
     * deleteInline */
    /**
     * "Deletes" record
     * 
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord deleteInline (  SqlConnection   connSpedmon
                                                  , DetailsLog      log
                                                  , UserInfo        uInfo
                                                  , string          clientID
                                                  , string          recID )
    {           
                
      string deleteSproc  = @"CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

     long vClientID = Validate.reqClientID(uInfo, clientID);      /* Force client ID to be that of users */
      
      var parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,"","N",recID,deleteSproc,ref parms);
    }
    
   /***************************************************************************
    * saveInline */
   /**
    * Save new or update existing record
    *
    * @return                 ReturnSaveNewRecord
    ***************************************************************************/   
  
    public static ReturnSaveRecord saveInline (  SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo
                                               , string        clientID
                                               , string        companyFiscalYearID
										       , string        name
                                               , string        startDate
                                               , string        endDate
                                               , string        saveType
                                               , string        recID)
    {           
                       
      string saveSproc = @"CLIENT_SCHOOL_SESSION_ACADEMIC_YEAR_SAVE";
      string dupRecMsg = @"Year already exists";

      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      long     vClientID            = Validate.reqClientID         (uInfo,  clientID);
      long     vCompanyFiscalYearID = Validate.reqInteger          (companyFiscalYearID, @"Invalid school year selection");
      string   vName                = Validate.reqString           (name,   @"Invalid school year name");
      DateTime[] vDates             = Validate.reqStartAndEndDate  (startDate, endDate, Messages.INVALID_DATE_RANGE);
                 
      var parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID",              SqlDbType.BigInt,    vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@companyFiscalYearID",   SqlDbType.BigInt,    vCompanyFiscalYearID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",                  SqlDbType.VarChar,   vName,                 ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@startDate",             SqlDbType.DateTime,  vDates[0],             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",               SqlDbType.DateTime,  vDates[1],             ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, "N", @"", recID, saveSproc, dupRecMsg, ref parms, null);
    }
     
    /***************************************************************************
     * view */
    /**
     * View base method
     * 
     * @return            ReturnDB
     ***************************************************************************/   

    public static ReturnDB view (  SqlConnection connSpedmon
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

      string viewUDF  = "dbo.CLIENT_SCHOOL_SESSION_ACADEMIC_YEARS_VIEW (@userID, @userGroup, @userRank, @clientID, @term, @active, @recID)";
      
      /*----------------------------
      * Validate parameters specific
      * to this entity.view
      * and populate their
      * coresponding database
      * parameters
      *----------------------------*/
      
      Object vClientID = Validate.reqClientID (uInfo, clientID);
      string vTerm     = Validate.optString   (term, Messages.INVALID_SEARCH_TERM);

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
                                      , string        clientID
                                      , string        term )
     {

       defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {
              
       };
     
       return Entities.viewSel(  connSpedmon
                               , log
                               , uInfo
                               , top
                               , topSize
                               , delegate {
                                   return ClientSchoolSessionAcademicYears.view (  connSpedmon
                                                                                  , log
                                                                                  , uInfo
                                                                                  , Entities.REC_VIEW_SEL
                                                                                  , top
                                                                                  , topSize
                                                                                  , ""
                                                                                  , "1"
                                                                                  , clientID
                                                                                  , term
                                                                                  , dc);});
    
     }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/
 
    public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                              , DetailsLog   log
                                              , UserInfo     uInfo
                                              , bool         pageObjectList
                                              , string       pageOrder
                                              , string       idx
                                              , string       active
                                              , string       clientID )
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ClientSchoolSessionAcademicYear.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(ClientSchoolSessionAcademicYear)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return ClientSchoolSessionAcademicYears.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , active
                                                                       , clientID
                                                                       , null
                                                                       , dc);
                                      });
 
 
    }
  
  }
}
