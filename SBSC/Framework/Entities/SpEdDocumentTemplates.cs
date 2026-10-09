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
   * SpEdDocumentTemplate */
  /** 
   ***************************************************************************/

   public class SpEdDocumentTemplate : Entity
   {
     public long     clientID;
     public string   clientName;
     public string   description;
     public int      spEdPlanTypeCode;
     public bool     standardSelection;
     public string   formBuilderContentJSON;
	 public bool     display;

     public const string DEFAULT_PAGING_ORDER = @"name asc";

   }

    /***************************************************************************
     * SpEdDocumentTemplates */
    /** 
     ***************************************************************************/
	 
    public class SpEdDocumentTemplates : Entities
    {
      public const int SPED_DOCUMENT_DATA_SOURCE_DOCUMENT_TEMPLATE                   = 1;
      public const int SPED_DOCUMENT_DATA_SOURCE_IEP_WRITER                          = 2;
      public const int SPED_DOCUMENT_DATA_SOURCE_PATIENT_CURRENT_OR_WIP_SPED_DATA    = 3;

      public const string FORM_BUILDER_QUESTIONS_TEXTAREA_ID  = "formbuilderquestionsjson";
      public const string FORM_BUILDER_ANSWERS_TEXTAREA_ID    = "formbuilderanswersjson";
      public const string SPED_PAT_INFO_HIDDEN_TEXTAREA_ID    = "sped-pat-info-hidden-textarea";
      public const string SPED_CLIENT_INFO_HIDDEN_TEXTAREA_ID = "sped-client-info-hidden-textarea";
      
      public const string SEL_LABEL_MANAGE              = @"Manage SpEd Document Templates";
      public const string URL_SBS_ALL_MANAGE            = @"sbs_all_manage_sped_document_templates.aspx";
      public const string MENU_LNK_MANAGE               = @"managespeddocumenttemplateslnk";
      public const string URL_REST_VIEW_BASE            = @"api/v1/speddocumenttemplates";
      public const string URL_SVC_BASE                  = @"sped_document_templates.asmx/";
      public const string URL_SVC_SAVE_BASE             = URL_SVC_BASE + @"save";
      public const string URL_SVC_SAVE_INLINE_BASE      = URL_SVC_BASE + @"saveinline";
      public const string URL_SVC_DELETE_INLINE_BASE    = URL_SVC_BASE + @"deleteinline";
      public const string URL_SPED_DOCUMENT_OUTPUT_BASE = @"user_all_sped_document_output.aspx";

      public static string URL_REST_VIEW()
      { 
        return MBA.HttpApplication.createLink( SpEdDocumentTemplates.URL_REST_VIEW_BASE, true);
      }
     
      public static string URL_SAVE()
      {
        return MBA.HttpApplication.createLink(SpEdDocumentTemplates.URL_SVC_SAVE_BASE, true);
      }

      public static string URL_SAVE_INLINE()
      {
        return MBA.HttpApplication.createLink(SpEdDocumentTemplates.URL_SVC_SAVE_INLINE_BASE, true);
      }

      public static string URL_DELETE_INLINE()
      {
        return MBA.HttpApplication.createLink(SpEdDocumentTemplates.URL_SVC_DELETE_INLINE_BASE, true);
      }

      public static string URL_SPED_DOCUMENT_OUTPUT(int dataSource, string recID)
      {
        return MBA.HttpApplication.createLink ( SpEdDocumentTemplates.URL_SPED_DOCUMENT_OUTPUT_BASE
                                               , true
                                               , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                               , new NameValue(Constants.PARM_DATA_SOURCE, dataSource)
                                               , new NameValue(Constants.PARM_REC_ID,      recID)
                                              );
      }

      public static string URL_SPED_DOCUMENT_OUTPUT(int dataSource, string clientID, string patID)
      {
        return MBA.HttpApplication.createLink ( SpEdDocumentTemplates.URL_SPED_DOCUMENT_OUTPUT_BASE
                                               , true
                                               , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                               , new NameValue(Constants.PARM_DATA_SOURCE, dataSource)
                                               , new NameValue(Constants.PARM_CLIENT_ID,   clientID)
                                               , new NameValue(Constants.PARM_REC_ID,      patID)
                                              );
      }
        

      /***************************************************************************
       * view */
      /** 
       ***************************************************************************/		 
      protected static ReturnDB view (
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , int           recViewType
          , bool          pagedOrTop
          , string        idx
          , string        canEdit
          , string        active
          , string        clientID
          , string        display
          , string        term
          , string        spEdPlanTypeCode
          , defineCols    dc )
      {
	
        string viewUDF = "dbo.SpEd_Document_Templates_View ( @userID, @userGroup, @userRank, @clientID, @term, @display, @spEdPlanTypeCode, @active, @recID)";

        Object  vClientID         = Validate.optInteger  (clientID,         Messages.INVALID_CLIENT_ID);
		Object  vDisplay          = Validate.optFlag     (display,          @"Invalid display flag");
		Object  vTerm             = Validate.optString   (term,             @"Invalid term");
        Object  vSpEdPlanTypeCode = Validate.optInteger  (spEdPlanTypeCode, @"Invalid plan type code");

        var parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@clientID"        , SqlDbType.BigInt ,  vClientID        , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@term"            , SqlDbType.VarChar , vTerm            , ParameterDirection.Input, 50));
        parms.Add(Database.SqlParm("@display"         , SqlDbType.Bit ,     vDisplay         , ParameterDirection.Input));
        parms.Add(Database.SqlParm("@spEdPlanTypeCode", SqlDbType.Int,      vSpEdPlanTypeCode, ParameterDirection.Input));

        var rd = Entities.view (  connSpedmon
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
                                , dc);
        return rd;
    }

    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/
    public static ReturnObjects viewObjects (   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , bool          pageObjectList
                                              , string        pageOrder
                                              , string        idx
                                              , string        clientID 
                                              , string        term )

    {           
      /* Default page order */  

      if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = SpEdDocumentTemplate.DEFAULT_PAGING_ORDER;
     
      /* Define columns delegate is used to specify columns and page order 
       * We pass in the desired page row order here */

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
      {
        pageroworder = pageOrder;
      };

      var rd =  Entities.viewObjects(  connSpedmon
                                     , log
                                     , uInfo
                                     , typeof(SpEdDocumentTemplate)
                                     , pageObjectList
                                     , pageOrder
                                     , delegate {                                      
                                         return SpEdDocumentTemplates.view (  connSpedmon
                                                                            , log
                                                                            , uInfo
                                                                            , Entities.REC_VIEW_OBJECTS
                                                                            , pageObjectList
                                                                            , idx
                                                                            , "" /* Can edit */
                                                                            , "Y"                                                             
                                                                            , clientID
                                                                            , null
                                                                            , term
                                                                            , ""
                                                                            , dc );
                                    });

      return rd;
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
                                      , string        term ) 
    {
      /*###########################################################################
        # Define context columns
        ###########################################################################*/  

      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms){           
        
        ss.addDisplayColumn("formBuilderContentJSON as recData1");        

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
                                SpEdDocumentTemplates.view (  connSpedmon
                                                             , log
                                                             , uInfo
                                                             , Entities.REC_VIEW_SEL
                                                             , top
                                                             , topSize
                                                             , ""
                                                             , "1"
                                                             , clientID
                                                             , "Y"
                                                             , term
                                                             , ""
                                                             , dc );
                              });
    }
    
    /***************************************************************************
     * load */
    /**
     ***************************************************************************/
    public static SpEdDocumentTemplate load (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
      return (SpEdDocumentTemplate)Entities.load(connSpedmon, log, uInfo, recID, typeof(SpEdDocumentTemplate),
      delegate { return SpEdDocumentTemplates.view (connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "Y", "", "", "", "",null); });
    } 
    
    /***************************************************************************
     * getCurrentIEPTemplate */
    /**
     ***************************************************************************/
    
    public static SpEdDocumentTemplate getCurrentIEPTemplate (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string clientID)
    {
      return (SpEdDocumentTemplate) Entities.loadNRecord(connSpedmon, log, uInfo, 0, typeof(SpEdDocumentTemplate),
      delegate { return SpEdDocumentTemplates.view (connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD_N, false, "", "", "Y", clientID, "Y", "", "100",null); });
    } 

    /***************************************************************************
     * save */
    /**
     ***************************************************************************/   
  
    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
										 , string        name
										 , string        description
                                         , string        formBuilderContentJSON
                                         , string        display
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      string saveSproc = @"SpEd_Document_Templates_Save";
      string dupRecMsg = @"Template already exists";
  
      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/

      Object  vClientID                   = Validate.optClientID (uInfo, clientID);
      string  vName                       = Validate.reqString   (name,                      @"Name is required");
	  Object  vDescription                = Validate.optString   (description,               @"Invalid description");
      Object  vFormBuilderContentJSON     = Validate.optString   (formBuilderContentJSON,    @"Invalid form data");
      bool    vDisplay                    = Validate.reqFlag     (display,                   @"Invalid display flag");
	              
      List<SqlParameter> parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID",                  SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@name",                      SqlDbType.VarChar,  vName,                      ParameterDirection.Input, 255));
      parms.Add(Database.SqlParm("@description",               SqlDbType.VarChar,  vDescription,               ParameterDirection.Input, 512));
      parms.Add(Database.SqlParm("@formBuilderContentJSON",    SqlDbType.VarChar,  vFormBuilderContentJSON,    ParameterDirection.Input, -1));
      parms.Add(Database.SqlParm("@display",                   SqlDbType.Bit,      vDisplay,                   ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms,null);
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
                
      var deleteSproc = @"dbo.SpEd_Document_Templates_Delete";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  
      
      var parms = new List<SqlParameter>();
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);

    }

  }
}
