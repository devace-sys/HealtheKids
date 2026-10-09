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
   * ORPDocumentStandardSelectionName */
  /**
   * 
   **************************************************************************/

  public class ORPDocumentStandardSelectionName: Entity
  {
    public long     groupSvcClassNameID;
    public string   groupSvcClassName;
    public string   svcDescTemplateText;
    public string   noteCrit1TemplateText;
    public string   noteCrit2TemplateText;
    public string   noteCrit3TemplateText;
    public string   noteCrit4TemplateText;
    public string   noteCrit5TemplateText;
    public string   noteCrit6TemplateText;
    public string   noteCrit7TemplateText;
    public string   noteCrit8TemplateText;
    public string   noteCrit9TemplateText;
    public string   noteCrit10TemplateText;
    public bool     allowMultipleOrders;
    public string   orderContextFieldName;
    public string   formBuilderContentJSON;
    public long     clientID;
    public string   clientName;
    public string   formBuilderContentForServiceJournalEntryNotesJSON;
    public long     serviceJournalAssociatedEventTypeID;
  }
          
  /***************************************************************************
   * ORPDocumentsStandardSelectionNames */
  /**
   * 
   **************************************************************************/

  public class ORPDocumentsStandardSelectionNames:Entities
  {
    /***************************************************************************
     * DEFAULT_PAGING_ORDER */
    /**
     * For view objects
     ***************************************************************************/       

    public const string DEFAULT_PAGING_ORDER = @"name asc";
        
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       

    public const string SEL_LABEL             = @"ORP Standard Selection Names";
    public const string SEL_LABEL_NEW         = @"Add New";
    public const string SEL_LABEL_EDIT        = @"Edit";
    public const string SEL_LABEL_EDIT_DELETE = @"Edit or Delete Existing";
    public const string SEL_LABEL_VIEW        = @"View";
    public const string SEL_LABEL_MANAGE      = @"Manage";
    
    /***************************************************************************
     * MENU_ID_* */
    /**
     * Unique menu ids
     ***************************************************************************/       

    public const string MENU_ID_ADD_NEW      = @"orpdocstdselnamenewlink";
    public const string MENU_ID_EDIT_DELETE  = @"orpdocstdselnameeditdellink";
    public const string MENU_ID_VIEW         = @"orpdocstdselnameviewlink";
    public const string MENU_ID_MANAGE       = @"orpdocstdselnamemanagelink";

    /***************************************************************************
     * URL_SBS_* */
    /**
     * Urls for SBS
     ***************************************************************************/       

    public const string URL_SERVICE_BASE    = @"orp_documents_standard_selection_names.asmx";
    public const string URL_DELETE          = URL_SERVICE_BASE + "/delete";
    public const string URL_SBS_SAVE        = @"sbs_all_orp_document_standard_selection_names_save.aspx";
    public const string URL_SBS_EDIT_DELETE = @"sbs_all_orp_document_standard_selection_names_edit_delete.aspx";
    public const string URL_SBS_VIEW        = @"sbs_all_orp_document_standard_selection_names_view.aspx";
    public const string URL_SBS_MANAGE      = @"sbs_all_orp_document_standard_selection_names_manage.aspx";
    public const string URL_REST_VIEW       = @"api/v1/orpdocumentsstandardselectionnames";
    public const string URL_WEB_REPORT      = @"orp_documents_standard_selection_names.ashx";

    /***************************************************************************
     * URL_ADD_NEW */
    /**
     * 
     **************************************************************************/
    public static string URL_ADD_NEW_BASE ()
    {
      return MBA.HttpApplication.createLink(  ORPDocumentsStandardSelectionNames.URL_SBS_SAVE
                                            , true
                                            , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                            , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)                                            
                                            );
    }

    /***************************************************************************
     * URL_EDIT */
    /**
     * 
     **************************************************************************/  
    public static string URL_EDIT_BASE()
    {
      return MBA.HttpApplication.createLink (  ORPDocumentsStandardSelectionNames.URL_SBS_SAVE
                                             , true
                                             , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                             , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                             , new NameValue(Constants.PARM_REC_ID, @"")
                                            );
    }

    /***************************************************************************
     * URL_DELETE_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_DELETE_BASE()
    {
      return MBA.HttpApplication.createLink( ORPDocumentsStandardSelectionNames.URL_DELETE
                                            , true
                                           );
    }

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW_BASE()
    { 
       return MBA.HttpApplication.createLink(ORPDocumentsStandardSelectionNames.URL_REST_VIEW, true);
    }


    /***************************************************************************
     * URL_WEB_REPORT_BASE */
    /**
     * 
     **************************************************************************/  
    public static string URL_WEB_REPORT_BASE()
    { 
       return MBA.HttpApplication.createLink(ORPDocumentsStandardSelectionNames.URL_WEB_REPORT, true);
    }

    /***************************************************************************
     * delete */
    /**
     * "Deletes" record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (  SqlConnection   connSpedmon
                                           , DetailsLog      log
                                           , UserInfo        uInfo
                                           , string          editDelReason
                                           , string          validateRec
                                           , string          recID )
    {           
                
      string deleteSproc  = @"ORP_DOCUMENT_STANDARD_SELECTION_NAMES_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);
    }

                    
    /***************************************************************************
     * save */
    /**
     * Save new or update existing record
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
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
  
    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientid
                                         , string        name
										 , string        groupServiceClassNameID
										 , string        notes                                         
                                         , string        svcDescTemplateText   
                                         , string        noteCrit1TemplateText
                                         , string        noteCrit2TemplateText
                                         , string        noteCrit3TemplateText
                                         , string        noteCrit4TemplateText
                                         , string        noteCrit5TemplateText
                                         , string        noteCrit6TemplateText
                                         , string        noteCrit7TemplateText
                                         , string        noteCrit8TemplateText
                                         , string        noteCrit9TemplateText
                                         , string        noteCrit10TemplateText
                                         , string        allowMultipleOrders
                                         , string        orderContextFieldName
                                         , string        formBuilderContentJSON
                                         , string        formBuilderContentForServiceJournalEntryNotesJSON
                                         , string        serviceJournalAssociatedEventTypeID
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
      string saveSproc  = @"ORP_DOCUMENT_STANDARD_SELECTION_NAMES_SAVE";
      string dupRecMsg  = @"Name already exists";
      
      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/  
           
      object     vClientID                = Validate.optInteger  (((clientid == "0") ? null : clientid), Messages.INVALID_CLIENT_ID);
      string     vName                    = Validate.reqString   (name,                    @"Invalid standard name");
      long       vGroupServiceClassNameID = Validate.reqInteger  (groupServiceClassNameID, Messages.INVALID_GROUP_ID);
      string     vNotes                   = Validate.optString   (notes,                   Messages.INVALID_NOTES);
      string     vSvcDescTempText         = Validate.optString   (svcDescTemplateText,     @"Invalid service description template");
      string     vNoteCrit1TempText       = Validate.optString   (noteCrit1TemplateText,   @"Invalid note crit 1 template");
      string     vNoteCrit2TempText       = Validate.optString   (noteCrit2TemplateText,   @"Invalid note crit 2 template");                 
      string     vNoteCrit3TempText       = Validate.optString   (noteCrit3TemplateText,   @"Invalid note crit 3 template");
      string     vNoteCrit4TempText       = Validate.optString   (noteCrit4TemplateText,   @"Invalid note crit 4 template");
      string     vNoteCrit5TempText       = Validate.optString   (noteCrit5TemplateText,   @"Invalid note crit 5 template");
      string     vNoteCrit6TempText       = Validate.optString   (noteCrit6TemplateText,   @"Invalid note crit 6 template");
      string     vNoteCrit7TempText       = Validate.optString   (noteCrit7TemplateText,   @"Invalid note crit 7 template");
      string     vNoteCrit8TempText       = Validate.optString   (noteCrit8TemplateText,   @"Invalid note crit 8 template");
      string     vNoteCrit9TempText       = Validate.optString   (noteCrit9TemplateText,   @"Invalid note crit 9 template");
      string     vNoteCrit10TempText      = Validate.optString   (noteCrit10TemplateText,  @"Invalid note crit 10 template");
      bool       vAllowMultipleOrders     = Validate.reqFlag     (allowMultipleOrders,     @"Invalid value for allow multiple orders");
      string     vOrderContextFieldName   = Validate.optString   (orderContextFieldName,   @"Invalid context field name");
      string     vFormBuilderContentJSON  = Validate.optString   (formBuilderContentJSON,  @"Invalid form data");

      string     vFormBuilderContentForServiceJournalEntryNotesJSON = Validate.optString(formBuilderContentForServiceJournalEntryNotesJSON);
      long       vServiceJournalAssociatedEventTypeID = Validate.reqInteger(serviceJournalAssociatedEventTypeID,@"Invalid service journal event type id");

      var parms = new List<SqlParameter>();
        
      parms.Add(Database.SqlParm("@clientID",                SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",                    SqlDbType.VarChar,  vName,                      ParameterDirection.Input, 255));
      parms.Add(Database.SqlParm("@groupSvcClassNameID",     SqlDbType.BigInt,   vGroupServiceClassNameID,   ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@notes",                   SqlDbType.VarChar,  vNotes,                     ParameterDirection.Input, 512));
      parms.Add(Database.SqlParm("@svcDescTemplateText",     SqlDbType.VarChar,  vSvcDescTempText,           ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit1TemplateText",   SqlDbType.VarChar,  vNoteCrit1TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit2TemplateText",   SqlDbType.VarChar,  vNoteCrit2TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit3TemplateText",   SqlDbType.VarChar,  vNoteCrit3TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit4TemplateText",   SqlDbType.VarChar,  vNoteCrit4TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit5TemplateText",   SqlDbType.VarChar,  vNoteCrit5TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit6TemplateText",   SqlDbType.VarChar,  vNoteCrit6TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit7TemplateText",   SqlDbType.VarChar,  vNoteCrit7TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit8TemplateText",   SqlDbType.VarChar,  vNoteCrit8TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit9TemplateText",   SqlDbType.VarChar,  vNoteCrit9TempText,         ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@noteCrit10TemplateText",  SqlDbType.VarChar,  vNoteCrit10TempText,        ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@allowMultipleOrders",     SqlDbType.Bit,      vAllowMultipleOrders,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orderContextFieldName",   SqlDbType.VarChar,  vOrderContextFieldName,     ParameterDirection.Input, 200));
      parms.Add(Database.SqlParm("@formBuilderContentJSON",  SqlDbType.VarChar,  vFormBuilderContentJSON,    ParameterDirection.Input, -1));

      parms.Add(Database.SqlParm("@formBuilderContentForServiceJournalEntryNotesJSON",  SqlDbType.VarChar,  vFormBuilderContentForServiceJournalEntryNotesJSON, ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@serviceJournalAssociatedEventTypeID",                SqlDbType.BigInt,   vServiceJournalAssociatedEventTypeID, ParameterDirection.Input));

      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms,null);
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
				                  , string        rdrGroupSvcClassNameID
				                  , string        rdrGroupID
				                  , string        rdrPracID
                                  , string        term
                                  , defineCols    dc )
    {
    
      string viewUDF = "dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES_VIEW (@userID, @userGroup, @userRank, @clientID, @rdrGroupSvcClassNameID, @rdrGroupID, @rdrPracID, @term, @active, @recID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/  
       
      Object  vClientID               = Validate.optInteger  (clientID,  Messages.INVALID_CLIENT_ID);      
      Object  vRdrPracID              = Validate.optPracID   (uInfo,  rdrPracID);      
      Object  vRdrGroupSvcClassNameID = Validate.optInteger  (rdrGroupSvcClassNameID, Messages.INVALID_GROUP_FAMILY);
      Object  vRdrGroupID             = Validate.optInteger  (rdrGroupID,             Messages.INVALID_GROUP_ID);
	  Object  vTerm                   = Validate.optString   (term,                   Messages.INVALID_SEARCH_TERM);
      	    
	    List<SqlParameter> parms = new List<SqlParameter>();
                         
      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,   vClientID,                ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rdrGroupSvcClassNameID",   SqlDbType.BigInt,   vRdrGroupSvcClassNameID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rdrGroupID",               SqlDbType.BigInt,   vRdrGroupID,              ParameterDirection.Input));
      parms.Add(Database.SqlParm("@rdrPracID",                SqlDbType.BigInt,   vRdrPracID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                     SqlDbType.VarChar,  vTerm,                    ParameterDirection.Input, 255));
	    	  
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

    }
    
    /***************************************************************************
     * viewSel */
    /**
     * Returns a 
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/
  
    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
				                      , string        rdrGroupSvcClassNameID
				                   	  , string        rdrGroupID
				                	  , string        rdrPracID             
                                      , string        term ) 
    {
      /*###########################################################################
        # Define context columns
        ###########################################################################*/  

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){           
        
        ss.addDisplayColumn("svcDescTemplateText    as recData1");
        ss.addDisplayColumn("noteCrit1TemplateText  as recData2");
        ss.addDisplayColumn("noteCrit2TemplateText  as recData3");
        ss.addDisplayColumn("noteCrit3TemplateText  as recData4");
        ss.addDisplayColumn("noteCrit4TemplateText  as recData5");        
        ss.addDisplayColumn("formBuilderContentJSON as recData6");        
        ss.addDisplayColumn("convert(varchar(200), allowMultipleOrders)    as recData7");
        ss.addDisplayColumn("orderContextFieldName  as recData8");
        ss.addDisplayColumn("noteCrit5TemplateText  as recData9");
        ss.addDisplayColumn("noteCrit6TemplateText  as recData10");
        ss.addDisplayColumn("noteCrit7TemplateText  as recData11");
        ss.addDisplayColumn("noteCrit8TemplateText  as recData12");
        ss.addDisplayColumn("noteCrit9TemplateText  as recData13");
        ss.addDisplayColumn("noteCrit10TemplateText  as recData14");
      };
     
      /*###########################################################################
        # Call the base method which handles the rest and return
        ###########################################################################*/  

      return Entities.viewSel(  connSpedmon
                              , log
                              , uInfo
                              , top
                              , topSize
                              , delegate{ return                              
                                ORPDocumentsStandardSelectionNames.view (  connSpedmon
                                                                         , log
                                                                         , uInfo
                                                                         , Entities.REC_VIEW_SEL
                                                                         , top
                                                                         , topSize
                                                                         , ""
                                                                         , "1"
                                                                         , clientID
                                                                         , rdrGroupSvcClassNameID
                                                                         , rdrGroupID
                                                                         , rdrPracID
                                                                         , term
                                                                         , dc );
                              });
    }
    

    
    /***************************************************************************
     * viewTbl */
    /**
     * Returns a data table of records for preview or record selection.
     * 
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnDataTable viewTbl (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          paged
                                           , string        pageNumber
                                           , string        canEdit
                                           , string        active
                                           , string        clientID
                                           , string        groupSvcClassNameID )
   {
     ReturnDataTable so        = new ReturnDataTable();
     string          tableName = ORPDocumentsStandardSelectionNames.SEL_LABEL;
     
     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {       
       ss.addDisplayColumn("id");       
       ss.addDisplayColumn("name                     as [Name]",             true);
       ss.addDisplayColumn("clientName               as [Client]");
       ss.addDisplayColumn("groupSvcClassName        as [Group Family]");       
       ss.addDisplayColumn("notes                    as [Key Words]");
       ss.addDisplayColumn("svcDescTemplateText      as [Service Description Template Text]");
       ss.addDisplayColumn("noteCrit1TemplateText    as [Note Criteria 1 Template Text]");
       ss.addDisplayColumn("noteCrit2TemplateText    as [Note Criteria 2 Template Text]");
       ss.addDisplayColumn("noteCrit3TemplateText    as [Note Criteria 3 Template Text]");
       ss.addDisplayColumn("noteCrit4TemplateText    as [Note Criteria 4 Template Text]");

       pageroworder = ss.pageRowOrder();
     };

     /*###########################################################################
       # Call the base method which handles the rest and returns a ReturnDataTable
       ###########################################################################*/  

     so = Entities.viewTbl(  connSpedmon
                           , log
                           , uInfo
                           , paged
                           , pageNumber
                           , delegate { return                            
                             ORPDocumentsStandardSelectionNames.view (  connSpedmon
                                                , log
                                                , uInfo
                                                , Entities.REC_VIEW_TBL
                                                , paged
                                                , pageNumber
                                                , canEdit
                                                , active
                                                , clientID
                                                , groupSvcClassNameID
                                                , ""
                                                , ""
                                                , ""
                                                , dc); 
                             });
   
     /*###########################################################################
       # Add a title and footer to ReturnDataTable then return
       ###########################################################################*/  
               
     so.tableName   = tableName;
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
    } 
        
  /***************************************************************************
   * viewObjects */
  /**
   * Returns a data table of records for preview or record selection.
   * 
   * @return                 ReturnDataTable
   ***************************************************************************/
  public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                             , DetailsLog    log
                                             , UserInfo      uInfo
                                             , bool          pageObjectList
                                             , string        pageOrder
                                             , string        idx
                                             , string        active
                                             , string        clientID
                                             , string        groupSvcClassNameID
                                             , string        term )
    {
      /* Default page order */

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ORPDocumentsStandardSelectionNames.DEFAULT_PAGING_ORDER;

      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      var rd = Entities.viewObjects( connSpedmon
                                    , log
                                    , uInfo
                                    , typeof(ORPDocumentStandardSelectionName)
                                    , pageObjectList
                                    , pageOrder
                                    , delegate {
                                       return ORPDocumentsStandardSelectionNames.view (  connSpedmon
                                                                                       , log
                                                                                       , uInfo
                                                                                       , Entities.REC_VIEW_OBJECTS
                                                                                       , pageObjectList
                                                                                       , idx
                                                                                       , "" /* Can Edit */
                                                                                       , active
                                                                                       , clientID
                                                                                       , groupSvcClassNameID
                                                                                       , ""
                                                                                       , ""
                                                                                       , term
                                                                                       , dc );
                                   });
            
      return rd;
    }

    /***************************************************************************
     * load */
    /**
     * Loads single record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing client specific data
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static ORPDocumentStandardSelectionName load (  SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo                                                 
                                                         , string        recID )
    {      
      return (ORPDocumentStandardSelectionName) Entities.load(connSpedmon, log, uInfo, recID, typeof(ORPDocumentStandardSelectionName),
      delegate { return ORPDocumentsStandardSelectionNames.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", null, "", "","","",null); });
    } 
                          
  }
}
