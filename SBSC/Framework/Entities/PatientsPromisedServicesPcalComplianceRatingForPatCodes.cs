using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Collections.Specialized;
using System.Collections;
using MBA;
using Geo;
using Geo.CDE;



namespace Spedmon
{    
  
  /***************************************************************************
   * PatientsPromisedServicesPcalComplianceRatingForPatCode */
  /**
   * 
   ****************************************************************************/

  public class PatientsPromisedServicesPcalComplianceRatingForPatCode
  {
    public int    id;
    public string name;
  }
  
  /***************************************************************************
   * PatientsPromisedServicesPcalComplianceRatingForPatCodes */
  /**
   * 
   ****************************************************************************/

  public class PatientsPromisedServicesPcalComplianceRatingForPatCodes: Entities
  {
        
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
                                 , defineCols    dc )
    {
      
      string viewUDF = "dbo.PATIENTS_Promised_Services_Pcal_Compliance_Rating_For_Pat_Codes_View (@userID,@userGroup,@userRank)";
      

      var parms = new List<SqlParameter>();   

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }
        
    /***************************************************************************
     * viewList */
    /**
     * 
     ***************************************************************************/
	 
    public static List<PatientsPromisedServicesPcalComplianceRatingForPatCode> viewList (  SqlConnection connSpedmon
                                                                                          , DetailsLog    log
                                                                                          , UserInfo      uInfo )
    {

      var recs = new List<PatientsPromisedServicesPcalComplianceRatingForPatCode>();
      var rd = PatientsPromisedServicesPcalComplianceRatingForPatCodes.view (connSpedmon,log,uInfo,Entities.REC_VIEW_RAW,false,"","","Y", null);
      var slo = Database.convertRecordsToList(ref rd.records, typeof(PatientsPromisedServicesPcalComplianceRatingForPatCode));
      foreach (var o in slo) {
         recs.Add ((PatientsPromisedServicesPcalComplianceRatingForPatCode) o );
      }
      return recs;    
    }

    
  }    
}
