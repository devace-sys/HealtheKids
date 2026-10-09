using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /**************************************************************************
     * PatientInfoRequestsResponsesMassUpdateRow */
    /**
     **************************************************************************/    
	public class PatientInfoRequestsResponsesMassUpdateRow
    {              
      public long   id;      
      public long   pirrMassUpdateID;
      public long   patID;
      public string patName;
      public string patPerIDs;
      public int    numOfPatPers;
      public bool   processed;
      public long?  pirrID;
      public long   clientID;
      public bool   completed;
    }
	
    /***************************************************************************
     * PatientInfoRequestsResponsesMassUpdateRows */
    /**
     *
     **************************************************************************/
	public class PatientInfoRequestsResponsesMassUpdateRows : Entities
    {
               
        /***************************************************************************
         * view */
        /**
         **************************************************************************/
		protected static ReturnDB view (
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        pirrMassUpdateID
          , string        completed
          , string        processed
          , string        active
          , string        recID
          , int           recViewType
          , bool          pagedOrTop
          , string        idx
          , string        canEdit
          , defineCols    dc )
        {
            string viewUDF = "PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS_VIEW (@userID, @userGroup, @userRank, @clientID, @pirrMassUpdateID, @completed, @processed)";

            Object vClientID         = Validate.optClientID (uInfo, clientID);
            Object vPirrMassUpdateID = Validate.optInteger  (pirrMassUpdateID, @"Invalid mass update id");
            Object vCompleted        = Validate.optFlag     (completed,        @"Invalid completed flag", true);
            Object vProcessed        = Validate.optFlag     (processed,        @"Invalid processed flag", true);

            var parms = new List<SqlParameter>();
            
            parms.Add(Database.SqlParm("@clientID",          SqlDbType.BigInt, vClientID,          ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pirrMassUpdateID",  SqlDbType.BigInt, vPirrMassUpdateID,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@completed",         SqlDbType.Bit,    vCompleted,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@processed",         SqlDbType.Bit,    vProcessed,         ParameterDirection.Input));

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
        public static List<PatientInfoRequestsResponsesMassUpdateRow> viewList ( 
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID            
          , string        pirrMassUpdateID
          , string        completed
          , string        processed ) 
        {
          var recs = new List<PatientInfoRequestsResponsesMassUpdateRow>();
         
          var rd = PatientInfoRequestsResponsesMassUpdateRows.view (  connSpedmon
                                                                    , log
                                                                    , uInfo
                                                                    , clientID                                                                    
                                                                    , pirrMassUpdateID
                                                                    , completed
                                                                    , processed
                                                                    , "Y" /* active */
                                                                    , ""
                                                                    , Entities.REC_VIEW_RAW
                                                                    , false
                                                                    , ""
                                                                    , ""                                     
                                                                    , null);

          var slo = Database.convertRecordsToList(ref rd.records, typeof(PatientInfoRequestsResponsesMassUpdateRow));
          
          foreach (var o in slo) {
            recs.Add((PatientInfoRequestsResponsesMassUpdateRow)o);
          }
          return recs;
        }
    }
}
