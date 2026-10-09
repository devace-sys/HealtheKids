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
     * ServiceNoteAnswerHeaders */
    /**
     * Methods used to work with service note answer headers
     ****************************************************************************/

    public class ServiceNoteAnswerHeaders
    {
       /***************************************************************************
        * view */
       /**
        * Generate list of 
        ****************************************************************************/

       public static List<ServiceNoteAnswerHeader> view(SqlConnection connSpedmon
                                                          , DetailsLog log
                                                          , UserInfo uInfo
                                                          , long clientID
                                                          , long pracID
                                                          , long noteID
                                                          , long questionID
                                                          )
        {

            List<ServiceNoteAnswerHeader> rl = new List<ServiceNoteAnswerHeader>();

            string sql = @"select * from dbo.SVCNOTES_NOTE_QUESTION_ANSWER_HEADERS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID)";

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,  ParameterDirection.Input));

            parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt, clientID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt, pracID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@noteID",         SqlDbType.BigInt, noteID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@questionID",     SqlDbType.BigInt, questionID,    ParameterDirection.Input));
  

            ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
            Object[] ol = Database.convertRecords(rd.records, typeof(ServiceNoteAnswerHeader));

            foreach (Object o in ol)
            {
                ServiceNoteAnswerHeader r = (ServiceNoteAnswerHeader)o;
                rl.Add(r);
            }

            return rl;
        }
    }
  
}
