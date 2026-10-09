using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
 
  /***************************************************************************
   * ClientDomain */
  /**
   * 
   **************************************************************************/  
  public class ClientDomain : Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"name asc";

    public long clientID;
   
  }
  
  /***************************************************************************
   * ClientDomains */
  /**
   * 
   **************************************************************************/

  public class ClientDomains: Entities
  {
    public const string SEL_LABEL                   = @"Client Domains";
    public const string URL_SERVICE_BASE            = @"client_domains.asmx";
    public const string URL_REST_SAVE_INLINE_BASE   = URL_SERVICE_BASE + @"/saveinline";
    public const string URL_REST_DELETE_INLINE_BASE = URL_SERVICE_BASE + @"/deleteinline";
    public const string URL_VIEW_SEL                = URL_SERVICE_BASE + @"/viewSel";
    public const string URL_REST_VIEW_BASE          = @"api/v1/clientdomains";
    public const string URL_WEB_REPORT_BASE         = @"client_domains.ashx";

    /***************************************************************************
     * URL_REST_SAVE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_SAVE_INLINE()
    {
      return MBA.HttpApplication.createLink(ClientDomains.URL_REST_SAVE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_DELETE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_REST_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink(ClientDomains.URL_REST_DELETE_INLINE_BASE, true);
    }

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(ClientDomains.URL_REST_VIEW_BASE, true);
    }
 
    /***************************************************************************
     * URL_REPORT */
    /**
     * 
     **************************************************************************/  
    public static string URL_WEB_REPORT()
    { 
       return MBA.HttpApplication.createLink(ClientDomains.URL_WEB_REPORT_BASE, true);
    }
 
    /***************************************************************************
     * view */
    /**
     * Returns ReturnDB.  Base method use for other views.
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
                                 , string        term 
                                 , defineCols    dc)
    {
                  
      var viewUDF = "CLIENTS_DOMAINS_VIEW(@userID, @userGroup, @userRank, @clientID, @term, @recID, @canEdit, @active)";
      var parms   = new List<SqlParameter>();
 
      /*----------------------------
       * Validate parameters specific
       * to this entity.view that 
       * will be used in all cases
       *----------------------------*/  
      
      int    vClientID       = Validate.reqClientID (uInfo, clientID);
      Object vTerm           = Validate.optString(term);   
              
      /*----------------------------
       * Populate database parameters
       *----------------------------*/
      
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt  , vClientID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",      SqlDbType.VarChar , vTerm,       ParameterDirection.Input, 50));
      
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
     * Returns ReturnSel * 
     ***************************************************************************/

     public static ReturnSel viewSel(    SqlConnection connSpedmon
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , bool top
                                       , string topSize
                                       , string clientID
                                       , string term)
     {

       /*###########################################################################
         # Define context columns
         ###########################################################################*/

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms) {


        };

        /*###########################################################################
          # Call the base method which handles the rest and return
          ###########################################################################*/

         return Entities.viewSel( connSpedmon
                                 , log
                                 , uInfo
                                 , top
                                 , topSize
                                 , delegate {
                                        
                                   return ClientDomains.view(connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_SEL
                                           , top
                                           , topSize
                                           , ""
                                           , "1"
                                           , clientID
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

        public static ReturnDataTable viewTbl(  SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , bool paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string clientID )
      {
        ReturnDataTable so = new ReturnDataTable();

        /*----------------------------
         * Define our columns and
         * set the page order for
         * paging
         *----------------------------*/

         defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
         {
                ss.addDisplayColumn("name             as [Domain Name]", true);
               /* ss.addDisplayColumn("notes            as [Notes]");*/
              pageroworder = ss.pageRowOrder();
         };

         /*----------------------------
          * Call base method which
          * handles the rest
          *----------------------------*/

          so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
              delegate {
                  return ClientDomains.view(connSpedmon
                                           , log
                                           , uInfo
                                           , Entities.REC_VIEW_TBL
                                           , paged
                                           , pageNumber
                                           , canEdit
                                           , active
                                           , clientID
                                           , ""                                           
                                           , dc);
              });

            /*----------------------------
             * Add a title and footer
             *----------------------------*/

            so.tableName   = SEL_LABEL;
            so.tableFooter = Messages.CONFIDENTIAL;

            /*----------------------------
             * Done
             *----------------------------*/

            return so;
    }
 
    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , bool pageObjectList
                                             , string pageOrder
                                             , string idx
                                             , string active
                                             , string clientID )
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = ClientDomain.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects (   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(ClientDomain)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return ClientDomains.view (   connSpedmon
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
                                           , string          clientID
                                           , string          recID )
    {           
                
      var deleteSproc = @"CLIENTS_DOMAINS_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      int vClientID = Validate.reqClientID(uInfo, clientID);      
      
      var parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
     
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);

    }

    /***************************************************************************
     * save 
     *
     * Returns ReturnSaveRecord
     * 
     ***************************************************************************/

    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
                                         , string        domain
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID )
    {

        var saveSproc = @"CLIENTS_DOMAINS_SAVE";
        
        int    vClientID  = Validate.reqClientID (uInfo, clientID);
        string vDomain    = Validate.reqString   (domain, @"Domain is required");
 
        List<SqlParameter> parms = new List<SqlParameter>();
 
        parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,  vClientID,  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@domain",    SqlDbType.VarChar, vDomain,    ParameterDirection.Input, 1000));

        return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, @"This domain already exists for this client", ref parms, null);
    }
  }
}