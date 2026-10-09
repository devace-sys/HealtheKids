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
   * ServiceJournalEventSelection */
  /**
   * Event selection
   **************************************************************************/

  public class ServiceJournalEventSelection
  {  
    public long   id;
    public string noteNamespace;
    public string noteSource;
    public bool   isDefault;
    public string name;
    public string eventLabel;
    public bool   reqStartTime;
    public bool   reqEndTime;
    public bool   reqORPDoc;
    public long   orpDocTypeID;
    public long   orpDocID;
    public string orpDocName;
    public bool   reqNote;
    public int    contSvcGroupPart;
    public int    displayOrder;
    public bool   active;    
  }
  
  /***************************************************************************
   * ReturnServiceJournalEventSelection */
  /**
   * Return class for single event selection
   **************************************************************************/

  public class ReturnServiceJournalEventSelection : Return
  {
 
    public ReturnServiceJournalEventSelection ()            : base(){}
    public ReturnServiceJournalEventSelection (string msg)  : base(msg){}
    public ReturnServiceJournalEventSelection (Exception e) : base(e){}
    public ReturnServiceJournalEventSelection (Warning e)   : base(e){}
    public ReturnServiceJournalEventSelection (Critical e)  : base(e){}
    public ReturnServiceJournalEventSelection (SessionExpired e):base(e){}
    
    public ServiceJournalEventSelection eventSelection;
  
  }
  
  /***************************************************************************
   * ServiceJournalsJournalEventSelections */
  /**
   * Methods to work with service journal event selections
   **************************************************************************/

  public class ServiceJournalsJournalEventSelections:Entities
  {          
    
    public const string URL_SERVICE                            = @"servicejournalseventselections.asmx";
    public const string URL_VIEW_SEL_JOURNAL_PAT_ORDERS_ONLY   = URL_SERVICE + "/viewSelJournalPatOrdersOnly";

    /***************************************************************************
     * URL_VIEW_SEL_JOURNAL_PAT_ORDERS_ONLY_BASE */
    /**
     * 
     **************************************************************************/  

    public static string URL_VIEW_SEL_JOURNAL_PAT_ORDERS_ONLY_BASE()
    {
       return MBA.HttpApplication.createLink(ServiceJournalsJournalEventSelections.URL_VIEW_SEL_JOURNAL_PAT_ORDERS_ONLY, true); 
    }

   /***************************************************************************
    * getEventSelectionDefault */
   /**
    * Returns default
    ***************************************************************************/   
   
    public static ServiceJournalEventSelection getEventSelectionDefault ( 
        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo 
      , string        noteNamespace
      , string        noteSource
      , string        journalID)
    {
      
      ServiceJournalEventSelection so    = new ServiceJournalEventSelection();      
      ReturnDB rd = view(connSpedmon,log,uInfo,REC_VIEW_RAW,false,"","","",noteNamespace,noteSource,"true",journalID,"","",null);
      so = (ServiceJournalEventSelection) Database.convertRecord(rd.records,typeof(ServiceJournalEventSelection));
      return so;
    }   


   /***************************************************************************
    * getEventSelectionData */
   /**
    * Returns default
    ***************************************************************************/   
   
    public static ServiceJournalEventSelection getEventSelectionData ( 
        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo 
      , string        eventID
      , string        journalID
      , string        pracID)
    {      
      ServiceJournalEventSelection so = new ServiceJournalEventSelection();            
      ReturnDB rd = view(connSpedmon,log,uInfo,REC_VIEW_LOAD,false,eventID,"","","","","",journalID,pracID, "",null);
      so = (ServiceJournalEventSelection) Database.convertRecord(rd.records,typeof(ServiceJournalEventSelection));
      return so;
    }   

   /***************************************************************************
    * getEventSelectionReturnData */
   /**
    * Returns 
    ***************************************************************************/   

    public static ReturnServiceJournalEventSelection getEventSelectionReturnData (
        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo 
      , string        eventID
      , string        journalID )
    {
      ReturnServiceJournalEventSelection so = new ReturnServiceJournalEventSelection();
      so.eventSelection = getEventSelectionData ( connSpedmon, log , uInfo , eventID, journalID, "");
      return so;
    }
   
   /***************************************************************************
    * viewSel */
   /**
    * 
    ***************************************************************************/   
    
    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        journalID
                                      , string        pracID
                                      , string        term)
    {
             
      /*----------------------------
       * Define our context column
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){
      };
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
      delegate{return ServiceJournalsJournalEventSelections.view (connSpedmon,log,uInfo,Entities.REC_VIEW_SEL, top, topSize, "", "", "", "", "", journalID, pracID, term, dc);});

    }

    /***************************************************************************
     * view */
    /**
     * 
    ***************************************************************************/   
    
    public static ReturnDB view (SqlConnection connSpedmon, 
                                 DetailsLog    log, 
                                 UserInfo      uInfo,
                                 int           recViewType,
                                 bool          pagedOrTop,
                                 string        idx,
                                 string        canEdit,
                                 string        active,
                                 string        noteNamespace,
                                 string        noteSource,
                                 string        isDefault,
                                 string        journalID,
                                 string        pracID,
                                 string        term,
                                 defineCols    dc) 
    {
    
      string viewUDF = "dbo.SvcJournal_Event_Selections (@userID, @userGroup, @userRank, @noteNamespace, @noteSource, @isDefault, @journalID, @pracID, @term, @recID)";
      
      Object vNoteNamespace = Validate.optString  (noteNamespace, @"Invalid note namespace");
      Object vNoteSource    = Validate.optString  (noteSource,    @"Invalid note source");
      Object vIsDefault     = Validate.optFlag    (isDefault,     @"Invalid default flag");
      Object vJournalID     = Validate.optInteger (journalID,     @"Invalid journal id");
      Object vPracID        = Validate.optPracID  (uInfo,pracID);
      Object vTerm          = Validate.optString  (term);
 
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@noteNamespace", SqlDbType.VarChar, vNoteNamespace, ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@noteSource",    SqlDbType.VarChar, vNoteSource,    ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@isDefault",     SqlDbType.Bit,     vIsDefault,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID",     SqlDbType.BigInt,  vJournalID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",        SqlDbType.BigInt,  vPracID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",          SqlDbType.VarChar, vTerm,          ParameterDirection.Input,255));
    
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }
   
   /***************************************************************************
    * viewJournalEventsAndPatOrders */
   /**
    * Used with journal.  Replaced event selection.
    ***************************************************************************/   
    
    public static ReturnDB viewJournalEventsAndPatOrders(SqlConnection connSpedmon, 
                                   DetailsLog    log 
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
                                 , string        noteNamespace
                                 , string        noteSource
                                 , string        isDefault
                                 , string        journalID
                                 , string        pracID
                                 , string        groupSvcClassNameID
				                 , string        patID
                                 , string        dos
                                 , string        includeOnlyOrpDocTypeIDs
                                 , string        groupID
                                 , string        displayRank
                                 , string        term
                                 , bool          includeEvents
                                 , bool          includeOrders
                                 , defineCols    dc) 
    {

      string viewUDF = "dbo.SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW (@userID, @userGroup, @userRank, @clientID, @journalID, @pracID, @patID, @isDefault, @noteNamespace, @noteSource, @groupSvcClassNameID, @includeOnlyOrpDocTypeIDs, @displayRank, null, null, @dos, @groupID, @term, @includeOrders, @includeEvents, @active, @recID)";
      
      Object vNoteNamespace            = Validate.optString       (noteNamespace,            @"Invalid note namespace");
      Object vNoteSource               = Validate.optString       (noteSource,               @"Invalid note source");
      Object vIsDefault                = Validate.optFlag         (isDefault,                @"Invalid default flag");
      Object vJournalID                = Validate.optInteger      (journalID,                @"Invalid journal id");
      Object vClientID                = Validate.optClientID      (uInfo,                    clientID);
      Object vPracID                   = Validate.optPracID       (uInfo,                    pracID);
      
      // pat orders filters
      Object vGroupSvcClassNameID      = Validate.optInteger      (groupSvcClassNameID,      Messages.INVALID_GROUP_ID);
      Object vPatID                    = Validate.optInteger      (patID,                    Messages.INVALID_PAT_ID);
	  Object vDOS                      = Validate.optDate         (dos,                      Messages.INVALID_DOS);
      Object vTerm                     = Validate.optString       (term,                     Messages.INVALID_SEARCH_TERM);      
      Object vIncludeOnlyOrpDocTypeIDs = Validate.optRecIDMultiStr(includeOnlyOrpDocTypeIDs, @"Invalid orp doc type ids");
      Object vDisplayRank              = Validate.optInteger      (displayRank,              @"Invalid display ranking");
      long    vGroupID                 = Validate.reqInteger      (groupID,                  @"Invalid group id");       
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@noteNamespace", SqlDbType.VarChar, vNoteNamespace, ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@noteSource",    SqlDbType.VarChar, vNoteSource,    ParameterDirection.Input,500));
      parms.Add(Database.SqlParm("@isDefault",     SqlDbType.Bit,     vIsDefault,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@clientID",      SqlDbType.BigInt,  vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@journalID",     SqlDbType.BigInt,  vJournalID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",        SqlDbType.BigInt,  vPracID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",          SqlDbType.VarChar, vTerm,          ParameterDirection.Input,255));
      
      // pat orders filters
      parms.Add(Database.SqlParm("@groupSvcClassNameID",      SqlDbType.BigInt,   vGroupSvcClassNameID,         ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                    SqlDbType.BigInt,   vPatID,                       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@dos",                      SqlDbType.Date,     vDOS,                         ParameterDirection.Input));
	  parms.Add(Database.SqlParm("@includeOnlyOrpDocTypeIDs", SqlDbType.VarChar,  vIncludeOnlyOrpDocTypeIDs,    ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@displayRank",              SqlDbType.BigInt,   vDisplayRank,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupID",                  SqlDbType.BigInt,   vGroupID,                     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@includeOrders",            SqlDbType.BigInt,   includeOrders,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@includeEvents",            SqlDbType.BigInt,   includeEvents,               ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    

    }

   /***************************************************************************
    * _viewSelJournalEventsAndPatOrdersCore */
   /**
    * Core routine used for journal entry and practice office.  
    * Replaced event selection in the case of journal entry.
    * Both journal and practice office require the same viewSel data.
    ***************************************************************************/   
    
   private static ReturnSel _viewSelJournalEventsAndPatOrdersCore (
        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , bool          top
      , string        topSize
      , string        clientID
      , string        journalID
      , string        patID
      , string        pracID
      , string        orpDocTypeID
      , string        groupID
      , string        term
      , bool          includeEvents
      , bool          includeOrders ) 
    {
      if (Util.IsNullOrEmpty(orpDocTypeID)) orpDocTypeID = "2,3";

      /*----------------------------
       * Define our context column
       *----------------------------*/

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {        
        ss.addDisplayColumn("context1");        
        ss.addDisplayColumn("svcNoteTemplateTitle             as [recData1]");
        ss.addDisplayColumn("svcNoteTemplateText              as [recData2]");        
        ss.addDisplayColumn("convert(varchar,reqORPDoc)       as [recData3]");        
        ss.addDisplayColumn("convert(varchar,orpDocID)        as [recData4]");        
        ss.addDisplayColumn("orpDocName                       as [recData5]");        
        ss.addDisplayColumn("convert(varchar,reqStartTime)    as [recData6]");        
        ss.addDisplayColumn("convert(varchar,reqEndTime)      as [recData7]");        
        ss.addDisplayColumn("convert(varchar,svcNameID)       as [recData8]");        
        ss.addDisplayColumn("svcNoteCriteriaFormQuestionsJSON as [recData9]");        
        ss.addDisplayColumn("convert(varchar,iep)             as [recData10]");  
        ss.addDisplayColumn("convert(varchar,lastApprovalExpirationState) as [recData11]");
        ss.addDisplayColumn("formBuilderContentForServiceJournalEntryNotesJSON as [recData12]");
          
      };
     
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewSel(connSpedmon, log, uInfo ,top, topSize, 
      delegate{return ServiceJournalsJournalEventSelections.viewJournalEventsAndPatOrders( connSpedmon
                                                                                         , log
                                                                                         , uInfo
                                                                                         , Entities.REC_VIEW_SEL
                                                                                         , top
                                                                                         , topSize
                                                                                         , ""
                                                                                         , "1"
                                                                                         , clientID
                                                                                         , ""
                                                                                         , ""
                                                                                         , ""
                                                                                         , journalID
                                                                                         , pracID
                                                                                         , null
                                                                                         , patID
                                                                                         , null
                                                                                         , orpDocTypeID
                                                                                         , groupID
                                                                                         , @"1"    /* Limits patient profiles to most current*/
                                                                                         , term
                                                                                         , includeEvents
                                                                                         , includeOrders
                                                                                         , dc);
      }); 

    }

   /***************************************************************************
    * viewSelJournalEventsAndPatOrders */
   /**
    * Used for journal entry.  Replaced event selection.
    ***************************************************************************/   
    
    public static ReturnSel viewSelJournalEventsAndPatOrders (
        SqlConnection connSpedmon
      , DetailsLog    log 
      , UserInfo      uInfo
      , bool          top
      , string        topSize
      , string        clientID
      , string        journalID
      , string        patID
      , string        pracID
      , string        orpDocTypeID
      , string        groupID
      , string        term ) 
    {
   
        return _viewSelJournalEventsAndPatOrdersCore (
            connSpedmon
          , log 
          , uInfo
          , top
          , topSize
          , clientID
          , journalID
          , patID
          , pracID
          , orpDocTypeID
          , groupID
          , term
          , true
          , true );
          
    }
   
   /***************************************************************************
    * viewSelJournalPatOrdersOnly */
   /**
    * Used for custom journal entry via practice office.
    ***************************************************************************/   
    
    public static ReturnSel viewSelJournalPatOrdersOnly (
          SqlConnection connSpedmon
        , DetailsLog    log 
        , UserInfo      uInfo
        , bool          top
        , string        topSize
        , string        clientID
        , string        patID
        , string        pracID       
        , string        groupID
        , string        term ) 
    {
       string journalID    = "";
       string orpDocTypeID = "2";
       
       return _viewSelJournalEventsAndPatOrdersCore (
            connSpedmon
          , log 
          , uInfo
          , top
          , topSize
          , clientID
          , journalID
          , patID
          , pracID
          , orpDocTypeID
          , groupID
          , term
          , false
          , true );
    }
        
  }
}
