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
   * PatientsPromisedServicesCDEAuditCurrent */
  /**
   * 
   **************************************************************************/
  
  public class PatientsPromisedServicesCDEAuditCurrentForSelpa : CdeComplianceBucketSummary
  {    
    public const string DEFAULT_PAGING_ORDER = "startDate asc";
    public long  selpaCode;
  }

 
  /***************************************************************************
   * PatientsPromisedServicesCDEAuditsCurrentForSelpas */
  /**
   * 
   **************************************************************************/

  public class PatientsPromisedServicesCDEAuditsCurrentForSelpas:Entities
  {            
     /***************************************************************************
       * load */
      /**
       * 
       **************************************************************************/
 
      public static PatientsPromisedServicesCDEAuditCurrentForSelpa load (  SqlConnection connSpedmon
                                                                  , DetailsLog    log
                                                                  , UserInfo      uInfo
                                                                  , string        selpaCode)
      {
        var so = new PatientsPromisedServicesCDEAuditCurrentForSelpa();

        so = (PatientsPromisedServicesCDEAuditCurrentForSelpa) Entities.loadNRecord (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , 0
                                                      , typeof(PatientsPromisedServicesCDEAuditCurrentForSelpa)
                                                      , delegate { 
                                                          return PatientsPromisedServicesCDEAuditsCurrentForSelpas.view ( connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_RAW                                                                                           
                                                                                                , false
                                                                                                , ""
                                                                                                , ""
                                                                                                , ""
                                                                                                , selpaCode
                                                                                                , null );});
               
        return so;
      }
    
      /***************************************************************************
       * get */
      /**
       * 
       **************************************************************************/
 
      public static ReturnEntity get (  SqlConnection connSpedmon
                                       , DetailsLog    log
                                       , UserInfo      uInfo
                                       , string        selpaCode)
      {
        var so = new ReturnEntity();
        so.entity = PatientsPromisedServicesCDEAuditsCurrentForSelpas.load(connSpedmon,log,uInfo,selpaCode);
        return so;
      }

    /*************************************************************************
     * view */
    /**
     *
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
                                  , string        selpaCode
                                  , defineCols    dc )
    {
      
      string viewUDF = "dbo.Patients_Promised_Services_CDE_Audits_Current_For_SELPA_View (@userID, @userGroup, @userRank, @selpaCode, @patAbsentMinsAreSatisfiedMins)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var  vSelpaCode = Validate.reqSelpaCode  (uInfo, selpaCode);
      bool vPatAbsentMinsAreSatisfiedMins = true; /* TODO: If needed in the future continue passing this up the stack */
      
      var parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@selpaCode", SqlDbType.Int, vSelpaCode, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patAbsentMinsAreSatisfiedMins", SqlDbType.Bit, vPatAbsentMinsAreSatisfiedMins, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }
  }
}
