using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * Service */
  /**
   ***************************************************************************/   
  
  public class Service:Entity
  {
    public int servicetype;         
    public int nameID;
  }
  
  /***************************************************************************
   * Services */
  /**
   * Services that Practitioners can provide
   * To view, add, edit, or delete Services that practitioners have provided
   * please see ServiceRecords
   ***************************************************************************/

  public class Services:Entities
  {     
    
    public const string URL_SERVICES    = @"services.asmx";
    public const string URL_VIEW_SEL    = URL_SERVICES + "/viewSel";
    public const string URL_VIEW_SEL2   = URL_SERVICES + "/viewSel2";
    public const string URL_VIEW_SEL_TMT   = URL_SERVICES + "/viewSelTmtTcmTrans";

    /* TODO: Move the SVC_NAMES_LIST_DATA_SOURCE code to a seperate entity */

    public const string SVC_NAMES_LIST_DATA_SOURCE_IEP_IFSP_NAME   = @"IEP / IFSP";
    public const string SVC_NAMES_LIST_DATA_SOURCE_OTHER_PLAN_NAME = @"Other (IHP, 504, Counseling, etc.)";
    public const string SVC_NAMES_LIST_DATA_SOURCE_CYBHI_NAME      = @"CYBHI";
    public const string SVC_NAMES_LIST_DATA_SOURCE_RU_HEALTH_NAME  = @"RU Health";

    public const int SVC_NAMES_LIST_DATA_SOURCE_IEP_IFSP_VALUE     = 100;
    public const int SVC_NAMES_LIST_DATA_SOURCE_OTHER_PLAN_VALUE   = 200;
    public const int SVC_NAMES_LIST_DATA_SOURCE_CYBHI_VALUE        = 300;
    public const int SVC_NAMES_LIST_DATA_SOURCE_RU_HEALTH_VALUE    = 400;
    
    public const int BILLING_PROGRAM_ID_LEA_BOP   = 1;
    public const int BILLING_PROGRAM_ID_CYBHI     = 2;
    public const int BILLING_PROGRAM_ID_RU_HEALTH = 3;

    /***************************************************************************
     * URL_VIEW_SEL_BASE */
    /**
     * 
     **************************************************************************/  

    /***************************************************************************
     * URL_VIEW_SEL_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_VIEW_SEL_BASE()
    { 
       return MBA.HttpApplication.createLink(Services.URL_VIEW_SEL, true);
    }

    /***************************************************************************
     * URL_VIEW_SEL2_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_VIEW_SEL2_BASE (bool showOnlyCopyDownSelections = false)
    {        
      return MBA.HttpApplication.createLink(  Services.URL_VIEW_SEL2
                                            , true
                                            );
    }

    /***************************************************************************
     * URL_VIEW_SEL_TMT_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_VIEW_SEL_TMT_BASE()
    {        
      return MBA.HttpApplication.createLink(  Services.URL_VIEW_SEL_TMT
                                            , true
                                            );
    }
        
    /***************************************************************************
     * isIEPIFSPAndBillingProgramIDToSvcNameListDataSourceID */
    /**
     * 
     **************************************************************************/  
    public static int isIEPIFSPAndBillingProgramIDToSvcNameListDataSourceID (bool isIEPIFSP, int billingProgramID)
    {
      if (billingProgramID == BILLING_PROGRAM_ID_LEA_BOP)
      {
        if (isIEPIFSP == true) 
          return SVC_NAMES_LIST_DATA_SOURCE_IEP_IFSP_VALUE;
        else 
          return SVC_NAMES_LIST_DATA_SOURCE_OTHER_PLAN_VALUE;
      }
      else if (billingProgramID == BILLING_PROGRAM_ID_CYBHI) {
        return SVC_NAMES_LIST_DATA_SOURCE_CYBHI_VALUE;
      }
      else if (billingProgramID == BILLING_PROGRAM_ID_RU_HEALTH) {
        return SVC_NAMES_LIST_DATA_SOURCE_RU_HEALTH_VALUE;
      }

      else return 0;
    }
    
    /***************************************************************************
     * viewListOfSvcNameListDataSources */
    /**
     * 
     **************************************************************************/  
    public static List<NameValueOption> viewListOfSvcNameListDataSources (          
          bool showSvcsForLeaBop        = true
        , bool showSvcsForLeaBopNonSpEd = true
        , bool showSvcsForCYBHI         = true
        , bool showSvcsForRUHealth      = true )
    {
      var recs = new List<NameValueOption>();
      recs.Add(new NameValueOption(SVC_NAMES_LIST_DATA_SOURCE_IEP_IFSP_NAME,   SVC_NAMES_LIST_DATA_SOURCE_IEP_IFSP_VALUE,   (!showSvcsForLeaBop),        false));
      recs.Add(new NameValueOption(SVC_NAMES_LIST_DATA_SOURCE_OTHER_PLAN_NAME, SVC_NAMES_LIST_DATA_SOURCE_OTHER_PLAN_VALUE, (!showSvcsForLeaBopNonSpEd), false));
      recs.Add(new NameValueOption(SVC_NAMES_LIST_DATA_SOURCE_CYBHI_NAME,      SVC_NAMES_LIST_DATA_SOURCE_CYBHI_VALUE,      (!showSvcsForCYBHI),         false));
      recs.Add(new NameValueOption(SVC_NAMES_LIST_DATA_SOURCE_RU_HEALTH_NAME,  SVC_NAMES_LIST_DATA_SOURCE_RU_HEALTH_VALUE,  (!showSvcsForRUHealth),      false));
      return recs;
    }


    /***************************************************************************
     * viewJSONOfSvcNameListDataSources */
    /**
     * 
     **************************************************************************/  
    public static string viewJSONOfSvcNameListDataSources (          
          bool showSvcsForLeaBop        = true
        , bool showSvcsForLeaBopNonSpEd = true
        , bool showSvcsForCYBHI         = true
        , bool showSvcForRUHealth       = true)
    {
      var recs = viewListOfSvcNameListDataSources(showSvcsForLeaBop,showSvcsForLeaBopNonSpEd,showSvcsForCYBHI,showSvcForRUHealth);
      return MBA.JSON.toJSONString(recs);      
    }

    /***************************************************************************
     * viewEntity */
    /**
     * Outputs service history for the given clientID, patID, pracID, and nameID
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatientID
     * @param  pracID          Practitioner ID
     * @param  nameID          Service ID
     * @return                 ReturnEntity
     ***************************************************************************/ 
    
     public static ReturnEntity viewEntity (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                            string clientID, 
                                            string patID,
                                            string pracID,
                                            string nameID,
                                            string isIEP,
                                            string dossvcs,
                                            string recID)
     {
 
       // TODO: Legacy remove
       
       ReturnEntity  so = new ReturnEntity();
       
       so.entity = new Entity();
       
       string referenceURL = MBA.StoredFileViewOrDownloadHandler.GenerateURL(@"storedfileworkbatch.ashx",EAW.MediaFile.DistributionModes.DELIVER,"");
              
       ReturnInfoTable pd = viewPossibleDups (connSpedmon, log, uInfo, clientID, pracID, patID, nameID, isIEP, dossvcs, recID, referenceURL);
       ReturnInfoTable ed = viewExistingDups (connSpedmon, log, uInfo, clientID, patID, nameID, recID, referenceURL);              
       ReturnInfoTable sh = viewShortHistory (connSpedmon, log, uInfo, clientID, patID, nameID, referenceURL); 
                    
       Client          cc = Clients.load     (connSpedmon, log, uInfo, clientID);
       Patient         pt = Patients.load    (connSpedmon, log, uInfo, patID);       

       string svchistory = "Duplicates You Will Create If You Save This Record\n\n";
       
       if (pd.hasRecords)
       {
         svchistory = svchistory + ReturnInfoTable.ToNoteString(pd,50);       
       }
       else
       {
         svchistory = svchistory + "None";
       }
                            
       svchistory = svchistory + "\n\nComplete 13 Month History of This Service\n\n";
       
       if (sh.hasRecords)
         svchistory = svchistory + ReturnInfoTable.ToNoteString(sh,50);       
       else
         svchistory = svchistory + "None";


       svchistory = svchistory + "\n\nDuplicates Which Have Already Been Processed\n\n";

       if (ed.hasRecords)
       {
         svchistory = svchistory + ReturnInfoTable.ToNoteString(ed,50);       
       }
       else
       {
         svchistory = svchistory + "None";
       }
       
         
       so.entity.name = pt.name;
       so.entity.notes = svchistory;
                 
       return so;
   } 

   /***************************************************************************
    * viewShortHistory */
   /**
    * Outputs last 13 months of service history for the given clientID and patientID
    * 
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object
    * @param  clientID        Client ID
    * @param  patID           PatientID
    * @param  nameID          NameID
    * @return                 ReturnInfoTable
    ***************************************************************************/ 
    
    public static ReturnInfoTable viewShortHistory (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                                    string clientID, 
                                                    string patID,
                                                    string nameID,
                                                    string referenceURL)
    {
           
     /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();

      string viewUDF    = "PATIENT_VIEW_SHORT_SERVICE_HISTORY(@userID,@userGroup,@userRank,@clientID,@patID,@nameID,@referenceURL)";
            
      int    vClientID  = Validate.reqClientID (uInfo,   clientID);
      int    vPatID     = Validate.reqInteger  (patID,   Messages.INVALID_PAT_ID);
      int    vNameID    = Validate.reqInteger  (nameID,  Messages.INVALID_SERVICE);       

      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int,     vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.Int,     vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",       SqlDbType.Int,     vNameID,      ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@referenceURL", SqlDbType.VarChar, referenceURL, ParameterDirection.Input, 1000));
                  
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
         
    }


   /***************************************************************************
    * viewExistingDups */
   /**
    * Outputs last 13 months of dups
    * 
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object
    * @param  clientID        Client ID
    * @param  patID           PatientID
    * @param  nameID          NameID
    * @return                 ReturnInfoTable
    ***************************************************************************/ 
    
    public static ReturnInfoTable viewExistingDups (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                                    string clientID, 
                                                    string patID,
                                                    string nameID,
                                                    string excludeRecID,
                                                    string referenceURL)
    {
           
     /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();

      string viewUDF    = "PATIENT_VIEW_SERVICE_HISTORY_EXISTING_DUPS (@userID,@userGroup,@userRank,@clientID,@patID,@nameID,@excludeRecID,@referenceURL)";
            
      int    vClientID  = Validate.reqClientID (uInfo,          clientID);
      int    vPatID     = Validate.reqInteger  (patID,          Messages.INVALID_PAT_ID);
      int    vNameID    = Validate.reqInteger  (nameID,         Messages.INVALID_SERVICE);             
      Object vRecID     = Validate.optInteger  (excludeRecID,   Messages.INVALID_RECORD_ID);

      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int,     vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.Int,     vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",       SqlDbType.Int,     vNameID,      ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@excludeRecID", SqlDbType.BigInt,  vRecID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referenceURL", SqlDbType.VarChar, referenceURL, ParameterDirection.Input, 1000));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
         
    }


   /***************************************************************************
    * viewPossibleDups */
   /**
    * Searches last 13 months of service history for the given clientID and patID
    * looking for possible duplicate entries
    * 
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object
    * @param  clientID        Client ID
    * @param  patID           PatientID
    * @param  nameID          NameID
    * @return                 ReturnInfoTable
    ***************************************************************************/ 
     
    public static ReturnInfoTable viewPossibleDups (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                                    string clientID, 
                                                    string pracID,
                                                    string patID,                                                    
                                                    string nameID,
                                                    string isIEP,
                                                    string dossvcs,
                                                    string excludeRecID,
                                                    string referenceURL)
    {
           
     /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();

      string viewUDF    = "PATIENT_VIEW_SERVICE_HISTORY_CHECK_DUPS (@userID, @userGroup, @userRank, @clientID, @pracID, @patID, @dosSvcs, @isIEP, @nameID, @excludeRecID, @referenceURL)";
            
      int    vClientID  = Validate.reqClientID (uInfo,         clientID);
      int    vPracID    = Validate.reqPracID   (uInfo,         pracID);
      int    vPatID     = Validate.reqInteger  (patID,         Messages.INVALID_PAT_ID);
      int    vNameID    = Validate.reqInteger  (nameID,        Messages.INVALID_SERVICE);       
      bool   vIsIep     = Validate.reqFlag     (isIEP,         Messages.IFSP_IEP_FLAG_BAD);      
      Object vRecID     = Validate.optInteger  (excludeRecID,  Messages.INVALID_RECORD_ID);
      
      DateTime[] vDosSvcsVal  = Validate.reqDateMulti (dossvcs, Messages.SERVICE_DATE_BAD, Constants.VAL_OPT_DATE_NO_FUTURE, Constants.CONV_OPT_DATE_NONE);
      string     vDosSvcsStr  = Validate.reqString    (dossvcs, Messages.SERVICE_DATE_BAD);

      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int,      vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",       SqlDbType.Int,      vPracID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.Int,      vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@nameID",       SqlDbType.Int,      vNameID,      ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@dosSvcs",      SqlDbType.VarChar,  vDosSvcsStr,  ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@isiep",        SqlDbType.Bit,      vIsIep,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@excludeRecID", SqlDbType.BigInt,   vRecID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@referenceURL", SqlDbType.VarChar,  referenceURL, ParameterDirection.Input, 1000));
    
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, parms);
         
    }

    
    /***************************************************************************
     * viewSelCore */
    /**
     * Outputs a simple list of all available services for selection display.
     * Simple lists contain name/value pairs for display.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patID           Patient id
     * @param  dos             Date of service 
     * @param  isIEP           true  = service is part of an IFSP/IEP
     *                         false = service is not part of an IFSP/IEP
     * @param  name            All or part of service name
     * @return                 ReturnServicesSimple
     ***************************************************************************/   

    protected static ReturnSel _viewSelCore (  SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , string clientID
                                             , string pracID
                                             , string patID
                                             , string dos
                                             , string isIEP
                                             , string name
                                             , string nameID
                                             , string svcNamesListDataSourceID = null)
    {      
     
     /*-------------------------------
      * Validate required and 
      * optional parameters
      *------------------------------*/ 

      int       vClientID                 = Validate.reqClientID (uInfo, clientID);
      int       vPracID                   = Validate.reqPracID   (uInfo, pracID);  
      DateTime  vDos                      = Validate.reqDate     (dos,      Messages.SERVICE_DATE_BAD);
      Object    vIsIep                    = Validate.optFlag     (isIEP,    Messages.IFSP_IEP_FLAG_BAD);
      int       vPatID                    = Validate.reqInteger  (patID,    Messages.PATIENT_ID_BAD);
      string    vName                     = Validate.optString   (name,     Messages.INVALID_SERVICE);
      Object    vNameID                   = Validate.optInteger  (nameID,   Messages.INVALID_NAME_ID);      
      Object    vSvcNamesListDataSourceID = Validate.optInteger(svcNamesListDataSourceID,@"Invalid service plan selection");

     /*-------------------------------
      * Setup database command
      *------------------------------*/ 
      
      string sql = @"";
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);
      
      parms.Add(Database.SqlParm("@clientID",                  SqlDbType.Int,       vClientID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",                    SqlDbType.Int,       vPracID,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                     SqlDbType.Int,       vPatID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dos",                       SqlDbType.DateTime,  vDos,                      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@isiep",                     SqlDbType.Bit,       vIsIep,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",                      SqlDbType.NVarChar,  vName,                     ParameterDirection.Input,100));
      parms.Add(Database.SqlParm("@nameID",                    SqlDbType.Int,       vNameID,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@svcNamesListDataSourceID",  SqlDbType.SmallInt,  vSvcNamesListDataSourceID, ParameterDirection.Input));

      /* Note: 
       *    id      = sr.nameID
       *   name - sr.name
       *   label = sr.name
       * , flag1    = sr.svcType
       * , class1   = sr.groupBase
       * , showOptions1 = 'SHOW_MILES' or 'SHOW_MINUTES'.  Never blank
       * , showOptions2 = SHOW_SPEECH_ASSESS_OPTIONS or SHOW_TREATMENT_ORP_DOC_SELECTION or blank
       * , showOptions3 = SHOW_TELEHEALTH or blank
       * , recData1 = groupServiceClassNameID
       * , recData2 = groupServiceClassName
       * , recData3 = ORP doc autoselect possible [0 or 1]
       * , recData4 = TELEHEALTH, IN_PERSON, TELEHEALTH|IN_PERSON
       * , recData5 = Plan Type Name
       * , recData6 = Service Type Name
       * , recData7 = Service Sub Type 1 Name
       * , recData8 = Service Sub Type 1 ID
       * , recData9 = CALPADS Code Name
       * , recData10 = CALPADS Code Value
       * , recData11 = sr.selectionNameWithoutInPersonOrTelehealthText
	   * , recData12 = sr.selectionForModalityFlags 1,2,3, or 0
	   * , recData13 = sr.selectionAltModalityNameID 
       * , recData14 = sr.serviceEntryOrpDocumentRequired
       */

      sql = @"select id, name AS label, name AS value, flag1, class1, showOptions1, showOptions2, showOptions3, recData1, recData2, recData3, recData4, recData5, recData6, recData7, recData8, recData9, recData10, recData11, recData12, recData13, recData14 from dbo.SERVICES_VIEW (@userID,@userGroup,@userRank,@nameID,@clientID,@pracID,@patID,@name,@dos,@isiep,null,null,@svcNamesListDataSourceID)";

     /*-------------------------------
      * Execute query and return 
      * results       
      *------------------------------*/ 

      ReturnDB  rd  = Database.execQuery(connSpedmon,log,sql,false,parms);
      ReturnSel so  = Database.convertReturnDBToReturnSel(ref rd);
      
      return so;      

    }
    
    /**************************************************************************
     * viewSel */
    /**
     * Outputs a simple list of all available services for selection display.
     * Simple lists contain name/value pairs for display.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patID           Patient id
     * @param  dos             Date of service 
     * @param  isIEP           true  = service is part of an IFSP/IEP
     *                         false = service is not part of an IFSP/IEP
     * @param  name            All or part of service name
     * @return                 ReturnServicesSimple
     ***************************************************************************/   

    public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID, string pracID, string patID, string dos, string isIEP, string name)
    {
       return _viewSelCore(connSpedmon, log, uInfo, clientID, pracID, patID, dos, isIEP, name, null);
    }

    
    public static ReturnSel viewSel (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID, string pracID, string patID, string dos, string isIEP, string name, string nameID)
    {
       return _viewSelCore(connSpedmon, log, uInfo, clientID, pracID, patID, dos, isIEP, name, nameID);
    }

    
    /**************************************************************************
     * viewSel2 */
    /**
     * Outputs same structure as viewSel but filters out either in person or
     * telehealth specific selections
     * 
     * @return                 ReturnSel
     ***************************************************************************/   

    public static ReturnSel viewSel2 (  SqlConnection connSpedmon
                                      , DetailsLog log
                                      , UserInfo uInfo
                                      , string clientID
                                      , string pracID
                                      , string patID
                                      , string dos
                                      , string svcNamesListDataSourceID
                                      , string name        
                                      , string viaTelehealth
                                      , string nameID = null)
    {
       var vViaTelehealth = Validate.reqFlag(viaTelehealth, @"Invalid via telehealth flag", true);

       var so =_viewSelCore(connSpedmon, log, uInfo, clientID, pracID, patID, dos, null, name, nameID, svcNamesListDataSourceID);

       /* Guard against no results */

       if (so.SelRecs is null) {
         return so;
       }

       List<SelRec> selections = new List<SelRec>();
       
       foreach (var SelRec in so.SelRecs)
       {

         /* Replace name with name that does not have (in person) or (via telehealth) in name */

         var newSvcName = SelRec.recData11;    
         SelRec.label = newSvcName;
         SelRec.value = newSvcName;
         
         /* Perform partition/filtering of selection.*/

         int selectionFor = 0;
         int.TryParse(SelRec.recData12,out selectionFor);
         
        /* If telehealth is toggled, include telehealth only and common */
         
         if  (vViaTelehealth == true) {
          if ((selectionFor == 1) || (selectionFor == 3)) {
               selections.Add(SelRec);
           }
        }
        
        /* If telehealth is not toggled, include in person only and common */
        
        else {
          if ((selectionFor == 2) || (selectionFor == 3)) {
            selections.Add(SelRec);
          }
        }
      }
      so.SelRecs = selections.ToArray();
      return so;
    }



    /***************************************************************************
     * viewSelTmtTcmTrans */
    /**
     * Outputs a simple list of all available services for selection display.
     * Simple lists contain name/value pairs for display.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     
     * @param  dos             Date of service 
     * @param  term            All or part of service name
     * @return                 ReturnServicesSimple
     ***************************************************************************/   

    public static ReturnSel viewSelTmtTcmTrans (   
    
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        clientID
      , string        pracID
      , string        svcNamesListDataSourceID
      , string        dos      
      , string        term )
    {      
     
     /*-------------------------------
      * Validate required and 
      * optional parameters
      *------------------------------*/ 

      long      vClientID                 = Validate.reqClientID (uInfo, clientID);
      long      vPracID                   = Validate.reqPracID   (uInfo, pracID);  
      int       vSvcNamesListDataSourceID = Validate.reqInteger  (svcNamesListDataSourceID, Messages.SERVICE_PLAN_BAD);
      DateTime  vDate                     = Validate.reqDate     (dos,   Messages.INVALID_DOS);
      string    vTerm                     = Validate.optString   (term,  Messages.INVALID_SERVICE);

     /*-------------------------------
      * Setup database command
      *------------------------------*/ 
      
      string sql = @"";
      
      var parms = new List<SqlParameter>();
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);

      parms.Add(Database.SqlParm("@clientID",                    SqlDbType.BigInt,     vClientID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",                      SqlDbType.BigInt,     vPracID,                      ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@svcNamesListDataSourceID",    SqlDbType.SmallInt,   vSvcNamesListDataSourceID,    ParameterDirection.Input));            
      parms.Add(Database.SqlParm("@dos",                         SqlDbType.Date,       vDate,                        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                        SqlDbType.VarChar,    vTerm,                        ParameterDirection.Input,100));
    
      sql = @"select id, SERVICE_NAME AS label, SERVICE_NAME AS value, CONVERT(VARCHAR(1),SERVICE_TYPE_ID) as recData1, SERVICE_IS_IND_OR_GRP as recData2, PROCEDURE_CODE as recData3, convert(varchar(50),SERVICE_NAME_ID) as recData4, SERVICE_RENDERED_VIA as recData5, showOptions3 from dbo.SERVICES_TMT_TCM_TRAN_VIEW (@userID,@userGroup,@userRank,@clientID,@pracID,@svcNamesListDataSourceID,@dos,@term)";

     /*-------------------------------
      * Execute query and return 
      * results       
      *------------------------------*/ 

      ReturnDB  rd  = Database.execQuery(connSpedmon,log,sql,false,parms);
      ReturnSel so  = Database.convertReturnDBToReturnSel(ref rd);
      
      return so;      

    }
    

    /***************************************************************************
     * viewSelForPlanTypeGroupID */
    /**
     * General selection view of services by plantype, group, and name
     * Not to be used for service record entry
     ***************************************************************************/   

    public static ReturnSel viewSelForPlanTypeGroupID (   
        SqlConnection connSpedmon
      , DetailsLog    log
      , UserInfo      uInfo
      , string        planType
      , string        groupID
      , string        term )
    {      
     
     ReturnSel so = new ReturnSel();

     /*-------------------------------
      * Validate required and 
      * optional parameters
      *------------------------------*/ 

      Object    vPlanType   = Validate.optInteger  (planType, Messages.INVALID_PLAN_TYPE);
      Object    vGroupID    = Validate.optInteger  (groupID,  Messages.INVALID_GROUP_ID);  
      string    vTerm       = Validate.optString   (term,     Messages.INVALID_SERVICE);

     /*-------------------------------
      * Setup database command
      *------------------------------*/ 
      
      var sql = @"select id = SERVICE_NAME_ID, label = SERVICE_NAME, value = SERVICE_NAME from dbo.SERVICES_VIEW_BY_PLAN_TYPE_GROUP_ID (@userID,@userGroup,@userRank,@planType,@groupID,@term)";
      var parms = new List<SqlParameter>();
      
      validateAndAddCommonUserInfoParameters(uInfo, ref parms);

      parms.Add(Database.SqlParm("@planType",  SqlDbType.BigInt,   vPlanType,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupID",   SqlDbType.BigInt,   vGroupID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",      SqlDbType.VarChar,  vTerm,      ParameterDirection.Input,256));
    
     /*-------------------------------
      * Execute query and return 
      * results       
      *------------------------------*/ 

      var rd = Database.execQuery(connSpedmon,log,sql,false,parms);
      so = Database.convertReturnDBToReturnSel(ref rd);
      return so;      

    }


  }  
}

