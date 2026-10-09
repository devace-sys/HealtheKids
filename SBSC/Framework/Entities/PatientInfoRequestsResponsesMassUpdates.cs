using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /**************************************************************************
     * PatientInfoRequestsResponsesMassUpdate */
    /**
     **************************************************************************/
    
	public class PatientInfoRequestsResponsesMassUpdate
    {
       public long   id;
       public long   clientID;
       public string clientName;
       public string requesterName;
       public string requesterEmail;
       public string requesterPhone;
       public string requestBaseUrl;
       public int    numOfPats;
       public int    numOfPatPers;
       public bool   completed;       
    }

    /***************************************************************************
     * PatientInfoRequestsResponsesMassUpdates */
    /**
     *
     **************************************************************************/
	public class PatientInfoRequestsResponsesMassUpdates : Entities
    {
       /***************************************************************************
        * updateStats */
       /**
        **************************************************************************/
       public static ReturnSaveRecord updateStats ( 
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        recID )
        {
            ReturnSaveRecord so = new ReturnSaveRecord();

            string saveSproc = "PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_UPDATE_STATS";

            var vClientID = Validate.reqClientID (uInfo,clientID);
                      
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
            
            return Entities.save (   connSpedmon
                                   , log
                                   , uInfo
                                   , "2" /*saveType*/
                                   , "N" /* validateRec */
                                   , "" /* editDelReason */
                                   , recID
                                   , saveSproc
                                   , @"Campaign is completed already"
                                   , ref parms
                                   , delegate () { });            
        }

        /***************************************************************************
         * view */
        /**
         **************************************************************************/
		protected static ReturnDB view (
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        completed
          , string        active
          , string        recID
          , int           recViewType
          , bool          pagedOrTop
          , string        idx
          , string        canEdit
          , defineCols    dc )
        {
            string viewUDF = "PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES_VIEW (@userID, @userGroup, @userRank, @clientID, @completed)";

            Object vClientID      = Validate.optClientID (uInfo, clientID);
            Object vCompleted     = Validate.optFlag     (completed,        @"Invalid completed flag", true);
            
            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt, vClientID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@completed",  SqlDbType.Bit,    vCompleted,  ParameterDirection.Input));

            return Entities.view (
                  connSpedmon
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
                , dc
            );
        }
        
        /***************************************************************************
         * viewList */
        /**
         **************************************************************************/
        public static List<PatientInfoRequestsResponsesMassUpdate> viewList ( 
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        completed ) 
        {
          var recs = new List<PatientInfoRequestsResponsesMassUpdate>();
         
          var rd = PatientInfoRequestsResponsesMassUpdates.view (  connSpedmon
                                                                 , log
                                                                 , uInfo
                                                                 , clientID
                                                                 , completed
                                                                 , "Y" /* active */
                                                                 , ""
                                                                 , Entities.REC_VIEW_RAW
                                                                 , false
                                                                 , ""
                                                                 , ""                                     
                                                                 , null);

          var slo = Database.convertRecordsToList(ref rd.records, typeof(PatientInfoRequestsResponsesMassUpdate));
          
          foreach (var o in slo) {
            recs.Add((PatientInfoRequestsResponsesMassUpdate)o);
          }
          return recs;
        }
    }
}
