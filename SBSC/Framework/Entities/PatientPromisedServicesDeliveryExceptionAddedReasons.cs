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
     * PatientPromisedServicesDeliveryExceptionAddedReason */
    /**
     ***************************************************************************/

    public class PatientPromisedServicesDeliveryExceptionAddedReason : Entity
    {
    }

    /***************************************************************************
     * PatientPromisedServicesDeliveryExceptionAddedReasons */
    /**
     ***************************************************************************/

    public class PatientPromisedServicesDeliveryExceptionAddedReasons : Entities
    {
      
      /***************************************************************************
       * view */
      /**
       * 
       ***************************************************************************/

        public static ReturnDB view(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, int recViewType, bool pagedOrTop, string idx, string canEdit, string active, string term, defineCols dc)
        {
            string viewUDF = "dbo.PATIENTS_Promised_Services_Delivery_Exception_Added_Reasons_View (@userID, @userGroup, @userRank, @term)";
       
            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            string vTerm = Validate.optString(term,@"Invalid reason");

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 256));

            /*----------------------------
             * Call base method which 
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }
     
        /***************************************************************************
         * viewList */
        /**
         * 
         ***************************************************************************/
        public static List<PatientPromisedServicesDeliveryExceptionAddedReason> viewList ( SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo )
        {
           var recs = new List<PatientPromisedServicesDeliveryExceptionAddedReason>();         
           var rd   = PatientPromisedServicesDeliveryExceptionAddedReasons.view (  connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, "", "", "Y", "", null);
           var slo  = Database.convertRecordsToList(ref rd.records, typeof(PatientPromisedServicesDeliveryExceptionAddedReason));
           foreach (var o in slo) { recs.Add((PatientPromisedServicesDeliveryExceptionAddedReason) o); }
           return recs;
        }

    }
}
