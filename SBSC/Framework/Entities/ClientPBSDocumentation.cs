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
   * ClientPBSDocument */
  /**
   * Physician based standard document record
   **************************************************************************/

  public class ClientPBSDocumentRecord: Entity
  {
    public long     clientID;
    public string   clientName;
    public long     groupServiceClassNameID;
    public string   groupServiceClassName;
	  public long     orpPracID;    
    public string   orpPracName;
    public string   orpPracNPI;
    public string   startDateStr;
    public string   endDateStr;
    public string   notes;
  }
          
  /***************************************************************************
   * ClientPBSDocumentation */
  /**
   * Methods to work with physician based standards documentation
   **************************************************************************/

  public class ClientPBSDocumentation:Entities
  {          
    
    public const string VAL_FILE_CLASS_PBS = "11";
    
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       

    public const string SEL_LABEL             = @"Special Authorization";
    public const string SEL_LABEL_NEW         = @"Add New";      
    public const string SEL_LABEL_EDIT        = @"Edit";
    public const string SEL_LABEL_EDIT_DELETE = @"Edit or Delete Existing";
    public const string SEL_LABEL_VIEW        = @"View";
    
    /***************************************************************************
     * URL_SBS_* */
    /**
     * Urls for SBS
     ***************************************************************************/       

    public const string URL_SBS_SAVE          = @"sbs_all_client_pbs_documentation_save.aspx";
    public const string URL_SBS_EDIT_DELETE   = @"sbs_all_client_pbs_documentation_edit_delete.aspx";
    public const string URL_SBS_VIEW          = @"sbs_all_client_pbs_documentation_view.aspx";
    
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
                
      string deleteSproc  = @"CLIENT_PBS_DOCUMENTATION_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      Object vClientID = Validate.optClientID(uInfo, "");      
      
      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
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
                                         , string        clientID
										                     , string        groupServiceClassNameID
                                         , string        orpPracID
                                         , string        startDate
										                     , string        endDate
										                     , string        notes                                         
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID)
    {           
                       
      string saveSproc  = @"CLIENT_PBS_DOCUMENTATION_SAVE";
      string dupRecMsg  = @"PBS already exists";
      
      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters
        ###########################################################################*/  
           
      long       vClientID                = Validate.reqClientID (uInfo, clientID);
      long       vGroupServiceClassNameID = Validate.reqInteger  (groupServiceClassNameID, Messages.INVALID_GROUP_ID);
	    long       vOrpPracID               = Validate.reqInteger  (orpPracID,               Messages.INVALID_PRAC_ID);      
      DateTime   vStartDate               = Validate.reqDate     (startDate,               Messages.INVALID_START_DATE);
      DateTime   vEndDate                 = Validate.reqDate     (endDate,                 Messages.INVALID_END_DATE);
      string     vNotes                   = Validate.optString   (notes,                   Messages.INVALID_NOTES);
                 
      List<SqlParameter> parms = new List<SqlParameter>();
  
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,   vGroupServiceClassNameID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@orpPracID",           SqlDbType.BigInt,   vOrpPracID,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",           SqlDbType.DateTime, vStartDate,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",             SqlDbType.DateTime, vEndDate,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@notes",               SqlDbType.VarChar,  vNotes,                     ParameterDirection.Input, -1));
      
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
                                  , string        groupServiceClassNameID
                                  , defineCols    dc)
    {
    
      string viewUDF = "dbo.CLIENT_PBS_DOCUMENTATION_VIEW (@userID, @userGroup, @userRank, @clientID, @groupSvcClassNameID, @active, @recID)";
      
      /*###########################################################################
        # Validate parameters specific to this entity view and create their 
        # database parameters
        ###########################################################################*/  
       
      Object  vClientID                = Validate.optClientID (uInfo,          clientID);
      Object  vGroupServiceClassNameID = Validate.optInteger  (groupServiceClassNameID, Messages.INVALID_GROUP_ID);
	    
	    List<SqlParameter> parms = new List<SqlParameter>();
                         
      parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID", SqlDbType.BigInt,   vGroupServiceClassNameID,   ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and return the results
        ###########################################################################*/  
      
      return Entities.view(connSpedmon,log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

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
                                           , string        clientID
                                           , string        groupServiceClassNameID
                                           , string        canEdit
                                           , string        active )
   {
     ReturnDataTable so        = new ReturnDataTable();
     string          tableName = @"Client PBS Documentation";
     
     /*###########################################################################
       # Define our display columns and set the page order.  Page order needs to
       # be in the same sort order as the udf called in the view.
       ###########################################################################*/  

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {
       
       ss.addDisplayColumn("id");       
       ss.addDisplayColumn("clientName             as [Client]",              true);
       ss.addDisplayColumn("groupServiceClassName  as [Groups]",              true);
       ss.addDisplayColumn("startDateStr           as [Effective\nDate]",     true);
       ss.addDisplayColumn("endDateStr             as [Expiration\nDate]",    true);
       ss.addDisplayColumn("orpPracName            as [Practitioner\nName]");
       ss.addDisplayColumn("orpPracNPI             as [Practitioner\nNPI #]");
                  
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
                           
                             ClientPBSDocumentation.view(  connSpedmon
                                                          , log
                                                          , uInfo
                                                          , Entities.REC_VIEW_TBL
                                                          , paged
                                                          , pageNumber
                                                          , canEdit
                                                          , active
                                                          , clientID
                                                          , groupServiceClassNameID
                                                          , dc); 
                             });
   
     /*###########################################################################
       # Add a title and footer then return
       ###########################################################################*/  
               
     so.tableName   = tableName;
     so.tableFooter = Messages.CONFIDENTIAL;
         
     return so;
     
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

    public static ClientPBSDocumentRecord load (  SqlConnection connSpedmon
                                                 , DetailsLog    log
                                                 , UserInfo      uInfo
                                                 , string        clientID
                                                 , string        recID )
    {      
      return (ClientPBSDocumentRecord) Entities.load(connSpedmon, log, uInfo, recID, typeof(ClientPBSDocumentRecord),
      delegate { return ClientPBSDocumentation.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", clientID, "", null); });
    } 
      
   /*************************************************************************
    * viewListPBSRecs */
   /**
    * Return a list of Special Authorization records
    * 
    ***************************************************************************/

    public static List<ClientPBSDocumentRecord> viewListPBSRecs( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        active)
      
     {
        var recs = new List<ClientPBSDocumentRecord>();
        ReturnDB rd = ClientPBSDocumentation.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, null, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(ClientPBSDocumentRecord));
        foreach (var o in slo) {
            recs.Add((ClientPBSDocumentRecord) o);
        }
        return recs;
    }    

  }
}
