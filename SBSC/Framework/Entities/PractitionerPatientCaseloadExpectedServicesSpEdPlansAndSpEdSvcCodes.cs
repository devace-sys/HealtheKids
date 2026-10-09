using MBA;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;

namespace Spedmon
{
    
    /***************************************************************************
     * PractitionerPatientCaseloadExpectedServicesSpEdPlansAndSpEdSvcCodes */
    /**
     *
	 * This is a special entities class only used in the practitioner caseload 
	 * expected services save/edit screen.  Its only purpose is to provide a 
	 * composite viewSel method that outputs:
     *
     * 1. Plans for a given patient
     * 2. SpEd Service Codes
     * 
     * The plans and spEd service codes are limited to services that either
     * the practitioner has indicated a preference for or (if no preferences
     * are set) default services for this practitioners practice family.  
 	 ***************************************************************************/
	 
    public class PractitionerPatientCaseloadExpectedServicesSpEdPlansAndSpEdSvcCodes : Entities
    {
     
        /***************************************************************************
         * view */
        /**
         * 
         ***************************************************************************/

        public static ReturnDB view (  SqlConnection connSpedmon
                                     , DetailsLog    log
                                     , UserInfo      uInfo
                                     , int           recViewType
                                     , bool          pagedOrTop
                                     , string        idx
                                     , string        clientID
                                     , string        pracID
                                     , string        patID
                                     , string        term
                                     , string        showcurrentonly 
                                     , defineCols    dc)
        {

          string viewUDF = "dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SPED_PLANS_AND_SPED_SVC_CODES_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @patID, @term, @showCurrentOnly)";

          /*----------------------------
           * Validate
           *----------------------------*/

          var vClientID         = Validate.reqClientID (uInfo , clientID);            
          var vPracID           = Validate.reqPracID   (uInfo, pracID);
          var vPatID            = Validate.reqPatID    (uInfo, patID);
          var vTerm             = Validate.optString   (term, Messages.INVALID_SEARCH_TERM);
          var vShowCurrentOnly  = Validate.reqFlag     (showcurrentonly,@"Invalid value for showCurrentOnly", true);

          /*----------------------------
           * Define db parms
           *----------------------------*/

          var parms = new List<SqlParameter>();

          parms.Add(Database.SqlParm("@clientID"         , SqlDbType.BigInt,  vClientID        , ParameterDirection.Input));
          parms.Add(Database.SqlParm("@pracID"           , SqlDbType.BigInt,  vPracID          , ParameterDirection.Input));
          parms.Add(Database.SqlParm("@patID"            , SqlDbType.BigInt,  vPatID           , ParameterDirection.Input));
          parms.Add(Database.SqlParm("@term"             , SqlDbType.VarChar, vTerm            , ParameterDirection.Input, 256));
          parms.Add(Database.SqlParm("@showCurrentOnly"  , SqlDbType.Bit,     vShowCurrentOnly , ParameterDirection.Input));
      
          /*----------------------------
           * Call base method which 
           * handles the rest and return
           * results
           *----------------------------*/

          return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, "", "Y", viewUDF, ref parms, null, dc);

        }

        /***************************************************************************
         * viewSel */
        /**         
         * 
         ***************************************************************************/
         
		 public static ReturnSel viewSel (  SqlConnection connSpedmon
                                           , DetailsLog    log
                                           , UserInfo      uInfo
                                           , bool          top
                                           , string        topSize
                                           , string        clientID
                                           , string        pracID
                                           , string        patID
                                           , string        term
                                           , string        showcurrentonly )
         {
          
            /*----------------------------
             * Define our context and 
             * additional columns 
             *----------------------------*/

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                ss.addDisplayColumn("spEdFreqCodeStr as recData1");
                ss.addDisplayColumn("spEdFreqCodeAndNameShort as recData2");
                ss.addDisplayColumn("minsPerFreqStr as recData3");
                ss.addDisplayColumn("startDateYYYYMMDD as recData4");
                ss.addDisplayColumn("endDateYYYYMMDD as recData5");
                ss.addDisplayColumn("spEdServiceCodeStr as recData6");
                ss.addDisplayColumn("spEdFreqName as recData7");
                ss.addDisplayColumn("numSvcLinesStr as recData8");
                ss.addDisplayColumn("hasSvcLinesDetailsStr as recData9");                
                ss.addDisplayColumn("svcLinesDetailsJSON as recData10");
                ss.addDisplayColumn("isPatPlanStr as recData11");
                ss.addDisplayColumn("selContextHTML as context1");
            };                         
            
            /*----------------------------
             * Call and return base method 
             *----------------------------*/
         
            return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
            delegate { return view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, clientID, pracID, patID, term, showcurrentonly, dc); });
        }       

    }
}
