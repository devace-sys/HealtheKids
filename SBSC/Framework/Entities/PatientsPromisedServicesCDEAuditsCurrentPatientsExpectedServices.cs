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
   * PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedService */
  /**
   * 
   **************************************************************************/
  
  public class PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedService :  CdeComplianceBucketDetailByService

  {    
        public long     patientsPromisedServicesCDEAuditsCurrentPatientsID;
        public string   usersToFollowupWithJSON;
        public string   reason;
        public bool     hasUserProvidedDeliveryComplianceStat;
        public string   hasUserProvidedDeliveryComplianceStatStr;
        public int      userProvidedDeliveryComplianceMinsExpected;
        public int      userProvidedDeliveryComplianceMinsSatisfied; 
        public int      userProvidedDeliveryCompliancePctSatisfied;
        public string   userProvidedDeliveryComplianceNotes;
        public bool     moreThanExpected;
        public string   moreThanExpectedStr;
        public int      numOverDeliveredMins;
        public string   planServiceDeliverySummary;
  }
  
   
  /***************************************************************************
   * PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices */
  /**
   * 
   **************************************************************************/

  public class PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices:Entities
  {            
    
    public const string URL_REST_VIEW_BASE = @"api/v1/patientspromisedservicescdeauditscurrentpatientsexpectedservices";

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices.URL_REST_VIEW_BASE, true);
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
                                 , string        patID
                                 , defineCols    dc )
    {
      
      string viewUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_Expected_Services_View (@userID,@userGroup,@userRank,@clientID,@patID,@patAbsentMinsAreSatisfiedMins)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
      
      long  vClientID  = Validate.reqClientID (uInfo, clientID);
      Object vPatID    = Validate.optPatID    (uInfo, patID);
      
      bool vPatAbsentMinsAreSatisfiedMins = true; /* TODO: If needed in the future continue passing this up the stack */

      var parms = new List<SqlParameter>();   

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,    vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",     SqlDbType.BigInt,    vPatID,       ParameterDirection.Input));

      parms.Add(Database.SqlParm("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return  Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);    
       
    }
   
    /***************************************************************************
     * viewTbl 
     *
     * Returns ReturnDataTable
     * 
     ***************************************************************************/
 
     public static ReturnDataTable viewTbl ( SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , bool paged
                                           , string pageNumber
                                           , string canEdit
                                           , string active
                                           , string clientID
                                           , string patID )
     {
            ReturnDataTable so = new ReturnDataTable();

            /*###########################################################################
              # Get and validate client id passed in.  
              # Note: We do perform this same check in the view method but we dont return
              # the value.  
              # TODO: Until we can refactor viewTbl to return utility data like this
              # we have to do this.
              ###########################################################################*/

            var vClientID = Validate.reqClientID (uInfo, clientID);
            clientID = vClientID.ToString();

            /*###########################################################################
              # Define our display columns and set the page order.  Page order needs to
              # be in the same sort order as the udf called in the view.
              ###########################################################################*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {              
                ss.addDisplayColumn("patLastName                  as [Student Last Name]", true);
                ss.addDisplayColumn("patFirstName                 as [Student First Name]", true);
                ss.addDisplayColumn("patDOBStr                    as [Date\nOf\nBirth]");
                ss.addDisplayColumn("patSSID                      as [SSID]");
                ss.addDisplayColumn("siteName                     as [Site Name]");                
                ss.addDisplayColumn("spEdCaseManagerName          as [Case Manager]");
                ss.addDisplayColumn("spEdExitedSpEdDateStr        as [Student\nExited\nSpEd]");
                ss.addDisplayColumn("spEdServiceCode              as [spEdServiceCode]");                
                ss.addDisplayColumn("spEdServiceCodeAndName       as [Service]");
                ss.addDisplayColumn("planStartDateStr             as [Plan Start\nDate]");
                ss.addDisplayColumn("planEndDateStr               as [Plan End\nDate]");
                ss.addDisplayColumn("spEdFreqCode                 as [spEdFreqCode]");
                ss.addDisplayColumn("spEdFreqName                 as [Frequency]");
                ss.addDisplayColumn("minsPerFreq                  as [Minutes\nPer\nFrequency]");
                ss.addDisplayColumn("totMinsExpected              as [Minutes\nExpected\n To Date]");
                ss.addDisplayColumn("totMinsApplicable            as [Minutes\nSatisfied\n To Date\n(Capped at Expected)]");
                ss.addDisplayColumn("hasUserProvidedDeliveryComplianceStatStr as [Non\nSpEdCare\nStats]");
                ss.addDisplayColumn("pctExpectedApplicableStr     as [Percentage\nSatisfied\nTo Date\n(Capped at 100)]");
                ss.addDisplayColumn("moreThanExpectedStr          as [More\nMinutes\nDelivered\nThan\nExpected]");
                ss.addDisplayColumn("numOverDeliveredMins         as [Minutes\nOver\nDelivered]");               
                
                /*ss.addDisplayColumn("numSvcRecs       as [Sessions\nDocumented]"); */
                ss.addDisplayColumn("numPatAbsentTot  as [Sessions\nDocumented\nStudent\nAbsent]");
                /*ss.addDisplayColumn("numPracAbsentTot as [Sessions\nDocumented\nPractioner\nAbsent]");*/

                ss.addDisplayColumn("patID                        as [SpEdCare\nPatient ID]");

                ss.addDisplayColumn("userProvidedDeliveryComplianceMinsExpected   as [Minutes Expected (for manual Import)]");
                ss.addDisplayColumn("userProvidedDeliveryComplianceMinsSatisfied  as [Minutes Satisfied (for manual Import)]");
                ss.addDisplayColumn("userProvidedDeliveryCompliancePctSatisfied   as [Percent Satisfied (for manual Import)]");                                        
                ss.addDisplayColumn("userProvidedDeliveryComplianceNotes          as [Notes (for manual Import)]");                                        

                pageroworder = ss.pageRowOrder();
            };

            /*###########################################################################
              # Call the base method which handles the rest and returns a ReturnDataTable
              ###########################################################################*/

            so = Entities.viewTbl(connSpedmon
                                  , log
                                  , uInfo
                                  , paged
                                  , pageNumber
                                  , delegate {
                                      return
                                            view(connSpedmon
                                                   , log
                                                   , uInfo
                                                   , Entities.REC_VIEW_TBL
                                                   , paged
                                                   , pageNumber
                                                   , canEdit
                                                   , active
                                                   , clientID
                                                   , patID
                                                   , dc );
                                  });

            /*###########################################################################
              # Add a title and footer to ReturnDataTable then return
              ###########################################################################*/
            
            Client c = Clients.load(connSpedmon,log,uInfo,clientID);

            so.tableName   = String.Format("{0}-{1}-{2}"
                                          , c.name 
                                          , CdeComplianceCommon.SEL_LABEL_MANGE_FOR_CLIENT_CURRENT_AUDIT
                                          , DateTime.Now.ToYYYYMMDDHHMMSSString());                
            
            so.tableFooter = Messages.CONFIDENTIAL;

            return so;

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
                                              , string       clientID
                                              , string       patID ) 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedService.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects(connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedService)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return PatientsPromisedServicesCDEAuditsCurrentPatientsExpectedServices.view(connSpedmon
                                                                       , log
                                                                       , uInfo
                                                                       , Entities.REC_VIEW_OBJECTS
                                                                       , pageObjectList
                                                                       , idx
                                                                       , "" /* Can edit */
                                                                       , active
                                                                       , clientID 
                                                                       , patID
                                                                       , dc);
                                      });
 
 
    }
  
  }
}
