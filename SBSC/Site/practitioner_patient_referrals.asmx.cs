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

namespace Spedmon
{
    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]

    public class PractitionerPatientReferralSvc : MBA.WebSvc
    {
        /***************************************************************************
         * save *
        /**
         **************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord save(
              string clientid
              , string pracid  
              , string referringbyuserid
              , string patID
              , string priority
              , string referredtopracname
              , string referredtoorgname
              , string referredtopracemail
              , string referredtopracphone
              , string parentguardianname
              , string parentguardianrelationship
              , string parentguardianemail
              , string parentguardianphone
              , string parentguardianconsent
              , string referraltype
              , string notes
              , string reffileid
              , string includediagnoses
              , string includeordersorprescriptions
              , string includeservicerecordstreatments
              , string includeservicerecordsassessementsorscreenings
              , string includeservicenotesnonconfidential
              , string includeservicenotesconfidential
              , string isused
              , string referredtopracid
              , string referralsourcename
              , string referralsourcerole
              , string referralsourceemail
              , string referralsourcephone
              , string behavioralisssuesconcerns
              , string academicconcerns
              , string anxietyordepressionconcerns
              , string familystressconcerns
              , string bullyingconcerns
              , string otherconcerns
              , string savetype
              , string recid)
        {
            return (ReturnSaveRecord) callMethod(typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.PractitionerPatientReferrals.save(
                        this.dbConnApp
                      , this.log
                      , this.uInfo
                      , clientid
                      , pracid
                      , referringbyuserid
                      , patID
                      , priority
                      , referredtopracname
                      , referredtoorgname
                      , referredtopracemail
                      , referredtopracphone
                      , parentguardianname
                      , parentguardianrelationship
                      , parentguardianemail
                      , parentguardianphone
                      , parentguardianconsent
                      , referraltype
                      , notes
                      , reffileid
                      , includediagnoses
                      , includeordersorprescriptions
                      , includeservicerecordstreatments
                      , includeservicerecordsassessementsorscreenings
                      , includeservicenotesnonconfidential
                      , includeservicenotesconfidential
                      , isused
                      , referredtopracid
                      , referralsourcename
                      , referralsourcerole
                      , referralsourceemail
                      , referralsourcephone
                      , behavioralisssuesconcerns
                      , academicconcerns
                      , anxietyordepressionconcerns
                      , familystressconcerns
                      , bullyingconcerns
                      , otherconcerns
                      , ""
                      , "N"
                      , savetype
                      , recid);
                },
                Constants.ROLE_ALL_PCAL_AND_CLIENT
            );
        }

        /***************************************************************************
         * delete 
         *
         * 
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

        public ReturnSaveRecord delete(string recid)
        {
            return (ReturnSaveRecord)
            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.PractitionerPatientReferrals.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           "",
                                           "0",
                                           recid);
            },
              Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
        }

    }
}