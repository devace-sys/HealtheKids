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
     * ServiceNoteAnswerSelections */
    /**
     * Request for list of service notes
     ****************************************************************************/

    public class ServiceNoteAnswerSelections
    {
      /***************************************************************************
       * view */
      /**
       * Request for list of selected list items
       ****************************************************************************/
       
      public static List<ServiceNoteAnswerSelection> view ( SqlConnection connSpedmon
                                                          , DetailsLog log
                                                          , UserInfo uInfo
                                                          , long clientID
                                                          , long pracID
                                                          , long noteID
                                                          , long questionID
                                                          , string answerSource
                                                          , long? headerID
                                                          , long? headerNoteAnswerID
                                                          )
      {

        List<ServiceNoteAnswerSelection> rl = new List<ServiceNoteAnswerSelection>();
        
        string sql = @"select * from dbo.SVCNOTES_NOTE_QUESTION_ANSWER_SELECTIONS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID, @answerSource, @headerID, @headerNoteAnswerID)";

        List<SqlParameter> parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,  ParameterDirection.Input));

        parms.Add(Database.SqlParm("@clientID",            SqlDbType.BigInt,  clientID,     ParameterDirection.Input));
        parms.Add(Database.SqlParm("@pracID",              SqlDbType.BigInt,  pracID,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@noteID",              SqlDbType.BigInt,  noteID,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@questionID",          SqlDbType.BigInt,  questionID,   ParameterDirection.Input));
     
        parms.Add(Database.SqlParm("@answerSource",        SqlDbType.VarChar, answerSource,       ParameterDirection.Input, 50));
        parms.Add(Database.SqlParm("@headerID",            SqlDbType.BigInt,  headerID,           ParameterDirection.Input));
        parms.Add(Database.SqlParm("@headerNoteAnswerID",  SqlDbType.BigInt,  headerNoteAnswerID, ParameterDirection.Input));

        ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
        Object[] ol = Database.convertRecords(rd.records, typeof(ServiceNoteAnswerSelection));

        foreach (Object o in ol)
        {
          ServiceNoteAnswerSelection r = (ServiceNoteAnswerSelection)o;
          rl.Add(r);
        }

        return rl;
      }
            
    }
  
}
