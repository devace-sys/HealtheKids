using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;
using System.IO;

namespace Spedmon
{
  /***************************************************************************
   * CdeComplianceSvc */
  /*
   * Web services end points 
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
   * method that is not accessible from the outside.
   * 
   * These wrappers handle access control and parameter replacement.
   * 
   * The method is restricted to calls for given user groups
   * 
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or 
   * sprocs that return or save data
   ***************************************************************************/
 
  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class CdeComplianceSvc : MBA.WebSvc
  {
    public CdeComplianceSvc() : base() { }
    

    /***************************************************************************
     * getcdecompliancebucketssummary */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmts getcdecompliancebucketssummary (string clientid)
    {
      return (ReturnTotalNumAmts)
        callMethod(typeof(ReturnTotalNumAmts),
        delegate ()
        {
           return Spedmon.CdeComplianceBucketSummaries.getCdeComplianceBucketsSummary (dbConnApp, log, uInfo, clientid);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getoverallsummary */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnObject getoverallsummary (string clientid, string siteid)
    {
      return (ReturnObject)
        callMethod(typeof(ReturnObject),
        delegate ()
        {
           return Spedmon.CdeComplianceBucketSummaries.getOverallSummary (dbConnApp, log, uInfo, clientid, siteid);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getcdecompliancebucketssummaryforselpa */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmts getcdecompliancebucketssummaryforselpa (string selpacode)
    {
      return (ReturnTotalNumAmts)
        callMethod(typeof(ReturnTotalNumAmts),
        delegate ()
        {
           return Spedmon.CdeComplianceBucketSummariesForSelpa.getCdeComplianceBucketsSummary (dbConnApp, log, uInfo, selpacode);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE_FOR_SELPA); // Who can call this method
    }

    /***************************************************************************
     * getcdecompliancebucketssummarybyservice */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmts getcdecompliancebucketssummarybyservice (string clientid, string siteid)
    {
      return (ReturnTotalNumAmts)
        callMethod(typeof(ReturnTotalNumAmts),
        delegate ()
        {
           return Spedmon.CdeComplianceBucketSummariesByService.getCdeComplianceBucketsSummaryByService (dbConnApp, log, uInfo, clientid, siteid);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }
    
    /***************************************************************************
     * getcdecompliancebucketssummarybypcalcompliancerating */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmts getcdecompliancebucketssummarybypcalcompliancerating (string clientid, string siteid)
    {
      return (ReturnTotalNumAmts)
        callMethod(typeof(ReturnTotalNumAmts),
        delegate ()
        {
           return Spedmon.CdeComplianceBucketSummariesByPcalComplianceRating.getCdeComplianceBucketsSummaryByPcalComplianceRating (dbConnApp, log, uInfo, clientid, siteid);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }
    

    /***************************************************************************
     * getcdecomplianceoverallsummaryforapractitioner */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnTotalNumAmts getcdecomplianceoverallsummaryforapractitioner (string clientid, string pracid, string useminsperfreqassigned)
    {
      return (ReturnTotalNumAmts)
        callMethod(typeof(ReturnTotalNumAmts),
        delegate ()
        {
           return Spedmon.PractitionerPatientCaseloadExpectedServices.getCdeComplianceOverallSummaryForAPractitioner (dbConnApp, log, uInfo, clientid, pracid, useminsperfreqassigned);
        }, Constants.ROLE_SVCREC_SAVE_BATCH_MULTI_PAT_MULTI_SVC); // Who can call this method
    }
        
    /***************************************************************************
     * getcurrentyear */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnEntity getcurrentyear (string clientid)
    {
      return (ReturnEntity)
        callMethod(typeof(ReturnEntity),
        delegate ()
        {
           return Spedmon.CdeComplianceBucketSummaries.get (dbConnApp, log, uInfo, clientid);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * getcurrentyearforselpa */
    /**
     **************************************************************************/
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnEntity getcurrentyearforselpa (string selpacode)
    {
      return (ReturnEntity)
        callMethod(typeof(ReturnEntity),
        delegate ()
        {
           return Spedmon.CdeComplianceBucketSummariesForSelpa.get (dbConnApp, log, uInfo, selpacode);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * savecurrentauditperiod */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveOrReplaceRecord savecurrentauditperiod (string clientid, string startdate, string enddate)
    {
      return (ReturnSaveOrReplaceRecord)
        callMethod(typeof(ReturnSaveOrReplaceRecord),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesCDEAuditsCurrent.save (dbConnApp, log, uInfo, clientid, startdate, enddate,@"N");
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }
            
    /***************************************************************************
     * getcurrentauditperiod */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnEntity getcurrentauditperiod (string clientid, string patabsentminsaresatisfiedmins)
    {
      return (ReturnEntity)
        callMethod(typeof(ReturnEntity),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesCDEAuditsCurrent.get (dbConnApp, log, uInfo, clientid, patabsentminsaresatisfiedmins);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * savecurrentauditperiodpatient */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveOrReplaceRecord savecurrentauditperiodpatient (string clientid, string patid)
    {
      return (ReturnSaveOrReplaceRecord)
        callMethod(typeof(ReturnSaveOrReplaceRecord),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.save (dbConnApp, log, uInfo, clientid, patid, @"N");
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }
    
    /***************************************************************************
     * getcurrentauditperiodforselpa */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnEntity getcurrentauditperiodforselpa (string selpacode)
    {
      return (ReturnEntity)
        callMethod(typeof(ReturnEntity),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesCDEAuditsCurrentForSelpas.get (dbConnApp, log, uInfo, selpacode);
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }

    /***************************************************************************
     * deletecurrentauditperiodpatientinline */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveRecord deletecurrentauditperiodpatientinline (string clientid, string recid)
    {
      return (ReturnSaveRecord)
        callMethod(typeof(ReturnSaveRecord),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.deleteInline (dbConnApp, log, uInfo, clientid, recid, @"N");
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecordWithJSONData importpatientdataforcurrentaudit (
        string clientid
      , string datatoimportjson
      , string validaterec)
    {
        var retval = (ReturnSaveRecordWithJSONData)

            callMethod(typeof(ReturnSaveRecordWithJSONData),
            delegate ()
            {

                return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.importData(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , datatoimportjson
                , validaterec
                );
            },

            Constants.ROLE_CDE_COMPLIANCE_MANAGE);  // Who can call this method

        return retval;
    }
    
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecordWithJSONData reprocessimportedpatientdataforcurrentaudit (string clientid)
    {
        var retval = (ReturnSaveRecordWithJSONData)

            callMethod(typeof(ReturnSaveRecordWithJSONData),
            delegate ()
            {
              return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.reprocessImportedData (
                   this.dbConnApp
                 , this.log
                 , this.uInfo
                 , clientid
                 , "N"
              );
            },

            Constants.ROLE_CDE_COMPLIANCE_MANAGE);  // Who can call this method

        return retval;
    }        
        
    /***************************************************************************
     * saveorreplaceuserprovideddeliverycompliancestats */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public ReturnSaveOrReplaceRecord saveorreplaceuserprovideddeliverycompliancestats ( 
                                                        string clientid
                                                      , string ppscdeauditcurpatid
                                                      , string spedservicecode
                                                      , string planstartdate
                                                      , string spedfreqcode
                                                      , string minsperfreq
                                                      , string minsexpected
                                                      , string minssatisfied
                                                      , string pctexpectedapplicable
                                                      , string notes
                                                      , string remove )
    {
      return (ReturnSaveOrReplaceRecord)
        callMethod(typeof(ReturnSaveOrReplaceRecord),
        delegate ()
        {
           return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.saveOrReplaceUserProvidedDeliveryComplianceStats (
                 dbConnApp
               , log
               , uInfo
               , clientid
               , ppscdeauditcurpatid
               , spedservicecode
               , planstartdate
               , spedfreqcode
               , minsperfreq
               , minsexpected
               , minssatisfied
               , pctexpectedapplicable
               , notes 
               , remove
               , @"N");
        }, Constants.ROLE_CDE_COMPLIANCE_MANAGE); // Who can call this method
    }
    
    /***************************************************************************
     * importdatauserprovideddeliverycompliancestats */
    /**
     **************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecordWithJSONData importdatauserprovideddeliverycompliancestats(
        string clientid
      , string datatoimportjson
      , string validaterec )
    {
        var retval = (ReturnSaveRecordWithJSONData)

            callMethod(typeof(ReturnSaveRecordWithJSONData),
            delegate ()
            {

                return Spedmon.PatientsPromisedServicesCDEAuditsCurrentPatients.importDataUserProvidedDeliveryComplianceStats(
                  this.dbConnApp
                , this.log
                , this.uInfo
                , clientid
                , datatoimportjson
                , validaterec
                );
            },

            Constants.ROLE_CDE_COMPLIANCE_MANAGE);  // Who can call this method

        return retval;
    }
	

    }
}
