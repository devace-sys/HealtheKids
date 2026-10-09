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

namespace Spedmon
{           
    /***************************************************************************
     * ServiceNoteQuestions */
    /**
     * Methods used to work with service note questions
     ****************************************************************************/

    public class ServiceNoteQuestions
    {

      /***************************************************************************
       * load */
      /**
       * Load individual question
       ****************************************************************************/
      
      public static ServiceNoteQuestion load(SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , long clientID
                                                , long pracID
                                                , long noteID
                                                , long questionID)
        {

            ServiceNoteQuestion r = new ServiceNoteQuestion();
            List<ServiceNoteQuestion> l = ServiceNoteQuestions.view(connSpedmon, log, uInfo, clientID, pracID, noteID, questionID);
            if (l.Count == 1) r = l[0];
            return r;
        }

       /***************************************************************************
        * view */
       /**
        * Generate list of ServiceNoteQuestion
        ****************************************************************************/

       public static List<ServiceNoteQuestion> view(SqlConnection connSpedmon
                                                      , DetailsLog log
                                                      , UserInfo uInfo
                                                      , long clientID
                                                      , long pracID
                                                      , long noteID
                                                      , long questionID)
        {

            //string sql = "select * from SVCNOTES_NOTE_QUESTIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID)";
            string sql = "select * from SVCNOTES_NOTE_QUESTION_SELECTIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID)";
            List<ServiceNoteQuestion> servicenotequestions = new List<ServiceNoteQuestion>();
            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,   ParameterDirection.Input));

            parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt, clientID,   ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",     SqlDbType.BigInt, pracID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@noteID",     SqlDbType.BigInt, noteID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@questionID", SqlDbType.BigInt, questionID, ParameterDirection.Input));

            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            Object[] lo = Database.convertRecords(rd.records, typeof(ServiceNoteQuestion));

            foreach (Object o in lo) servicenotequestions.Add((ServiceNoteQuestion)o);

            return servicenotequestions;

        }
    }
}
