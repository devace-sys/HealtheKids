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
   * PlanWriterPlansPatientPerson */
  /**
   *
   ***************************************************************************/

  public class PlanWriterPlansPatientPerson : PatientPerson
  {
        public long   planID;
        public string planName;
        public bool   useInPlan;
        public int    action;
        public bool   signed;
        public string signedDateStr;

    }
  
  /***************************************************************************
   * PlanWriterPlansPatientPersons */
  /**
   *
   ***************************************************************************/
  
  public class PlanWriterPlansPatientPersons : Entities
  {    

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
								  , string        planID		                                             
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW (@userID, @userGroup, @userRank, @clientID, @planID, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long   vClientID            = Validate.reqClientID                      (uInfo, clientID);
      long   vPlanID              = Validate.reqInteger                       (planID,           Messages.INVALID_PLAN_ID);	      
	  Object vTerm                = Validate.optString                      (term,        @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,   vClientID,             ParameterDirection.Input));
      parms.Add(Database.SqlParm("@planID",               SqlDbType.BigInt,   vPlanID,               ParameterDirection.Input));
     // parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar,  vTerm,                 ParameterDirection.Input, 256));
      
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
                                      , string        patientID
                                      , string        planID  
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {         
          ss.addDisplayColumn("personRoleAndRelationship as context1");
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
                                  return PlanWriterPlansPatientPersons.view (  connSpedmon
                                                                              , log
                                                                              , uInfo
                                                                              , Entities.REC_VIEW_SEL
                                                                              , top
                                                                              , topSize
                                                                              , ""
                                                                              , "Y"
                                                                              , clientID
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

    public static PlanWriterPlansPatientPerson load (   SqlConnection connSpedmon
                                                           , DetailsLog    log
                                                           , UserInfo      uInfo
                                                           , string        clientID
                                                           , string        groupSvcClassNameID
                                                           , string        patientID
                                                           , string        planID
                                                           , string        recID )
    {
      return (PlanWriterPlansPatientPerson) Entities.load (   connSpedmon
                                                                , log
                                                                , uInfo
                                                                , recID
                                                                , typeof (PlanWriterPlansPatientPerson)
                                                                , delegate {          
                                                                  return PlanWriterPlansPatientPersons.view (  connSpedmon
                                                                                                              , log
                                                                                                              , uInfo
                                                                                                              , Entities.REC_VIEW_LOAD
                                                                                                              , false
                                                                                                              , recID
                                                                                                              , ""
                                                                                                              , ""
                                                                                                              , clientID
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

    public static List<PlanWriterPlansPatientPerson> loadAllRecords (   SqlConnection connSpedmon
                                                                       , DetailsLog    log
                                                                       , UserInfo      uInfo
                                                                       , string        clientID
                                                                       , string        groupSvcClassNameID  
																			                                 , string        patientID
                                                                       , string        planID )
    {
    
      List<PlanWriterPlansPatientPerson> listItems = new List<PlanWriterPlansPatientPerson>();

      bool hasRecords = false;
      
      Object[] recs = loadAllRecords(   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof (PlanWriterPlansPatientPerson)
                                      , delegate { 
                                        return PlanWriterPlansPatientPersons.view (   connSpedmon
                                                                                     , log
                                                                                     , uInfo
                                                                                     , Entities.REC_VIEW_ALL
                                                                                     , false
                                                                                     , ""
                                                                                     , ""
                                                                                     , ""
                                                                                     , clientID
                                                                                     , planID
                                                                                     , null
                                                                                     , null);}
                                                                                     , out hasRecords);
    
      if (hasRecords == true)
      {
        foreach (Object rec in recs) {
          PlanWriterPlansPatientPerson listItem = (PlanWriterPlansPatientPerson) rec;
          listItems.Add(listItem);
        }
      }
      return listItems;
    }

  }
}
