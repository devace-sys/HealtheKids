using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    
  /***************************************************************************
   * PlanWriterPlansServiceDescription */
  /**
   *
   ***************************************************************************/

  public class PlanWriterPlansServiceDescription : ServiceJournalsServiceDescription
  {      
    public long    planID;
    public string  planName;    
    public bool    useInPlan;
    public string  name;
    public string requestID;
  }

    /***************************************************************************
     * PlanWriterPlansServiceDescriptions */
    /**
     *
     ***************************************************************************/

    public class PlanWriterPlansServiceDescriptions : Entities
  {
    public const string SEL_LABEL        = @"Diagnosis";
    public const string SEL_LABEL_ADD    = @"Add New";
    public const string SEL_LABEL_EDIT   = @"Edit";
    public const string SEL_LABEL_DELETE = @"Delete";

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
                                  , string        groupSvcClassNameID
                                  , string        planID
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @groupSvcClassNameID, @planID, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long   vClientID            = Validate.reqClientID                      (uInfo, clientID);
      Object   vGroupSvcClassNameID = Validate.optPlanWriterGroupSvcClassNameID (uInfo, groupSvcClassNameID);      
      long   vPlanID              = Validate.reqInteger                       (planID,      Messages.INVALID_PLAN_ID);
      Object vTerm                = Validate.optString                        (term,        @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,   vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@groupSvcClassNameID",  SqlDbType.BigInt,   vGroupSvcClassNameID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planID",               SqlDbType.BigInt,   vPlanID,               ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar,  vTerm,                 ParameterDirection.Input, 256));
      
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
                                      , string        groupSvcClassNameID
                                      , string        planID
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {         
          //ss.addDisplayColumn("planName + '|' + conditionName as context1");
          ss.addDisplayColumn("useInPlan as recFlagged");
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
                                  return PlanWriterPlansServiceDescriptions.view (  connSpedmon
                                                                                  , log
                                                                                  , uInfo
                                                                                  , Entities.REC_VIEW_SEL
                                                                                  , top
                                                                                  , topSize
                                                                                  , ""
                                                                                  , "Y"
                                                                                  , clientID
                                                                                  , groupSvcClassNameID
                                                                                  , planID
                                                                                  , term
                                                                                  , dc ); 
                                  });
                                                                    
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

    public static PlanWriterPlansServiceDescription load (   SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
                                                           , string        groupSvcClassNameID
                                                           , string        planID
                                                           , string        conditionID
                                                           , string        recID )
    {
      return (PlanWriterPlansServiceDescription) Entities.load (   connSpedmon
                                                                , log
                                                                , uInfo
                                                                , recID
                                                                , typeof (PlanWriterPlansServiceDescription)
                                                                , delegate {          
                                                                  return PlanWriterPlansServiceDescriptions.view (  connSpedmon
                                                                                                                  , log
                                                                                                                  , uInfo
                                                                                                                  , Entities.REC_VIEW_LOAD
                                                                                                                  , false
                                                                                                                  , recID
                                                                                                                  , ""
                                                                                                                  , ""
                                                                                                                  , clientID
                                                                                                                  , groupSvcClassNameID
                                                                                                                  , planID
                                                                                                                  , ""
                                                                                                                  , null );
                                                            });
    }
          
    /***************************************************************************
     * loadAllRecords */
    /**    
     *
     ***************************************************************************/

    public static List<PlanWriterPlansServiceDescription> loadAllRecords (   SqlConnection connSpedmon
                                                                            , DetailsLog    log
                                                                            , UserInfo      uInfo
                                                                            , string        clientID
                                                                            , string        groupSvcClassNameID  
                                                                            , string        planID)
    {
    
      List<PlanWriterPlansServiceDescription> listItems = new List<PlanWriterPlansServiceDescription>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (PlanWriterPlansServiceDescription)
                                      , delegate { 
                                        return PlanWriterPlansServiceDescriptions.view (  connSpedmon
                                                                                        , log
                                                                                        , uInfo
                                                                                        , Entities.REC_VIEW_ALL
                                                                                        , false
                                                                                        , ""
                                                                                        , ""
                                                                                        , ""
                                                                                        , clientID
                                                                                        , groupSvcClassNameID
                                                                                        , planID
                                                                                        , null
                                                                                        , null);}
                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          PlanWriterPlansServiceDescription listItem = (PlanWriterPlansServiceDescription) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }


  }
}
