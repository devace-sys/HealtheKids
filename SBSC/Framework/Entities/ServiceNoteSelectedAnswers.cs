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
     * ServiceNoteSelectedAnswers */
    /**
     * Request for list of service notes
     ****************************************************************************/

    public class ServiceNoteSelectedAnswers
    {

      public static SubmittedList createSubmittedList (string id, List<ServiceNoteSelectedAnswer> snsal)
      {
        List<SubmittedListItem> sliil = createSubmittedListItemList(id, snsal);
        SubmittedList sl = new SubmittedList(id, sliil);
        return sl;
      }
      
      public static List<SubmittedListItem> createSubmittedListItemList (string id, List<ServiceNoteSelectedAnswer> snsal)
      {
        List<SubmittedListItem> slil = new List<SubmittedListItem>();
        foreach (ServiceNoteSelectedAnswer snsa in snsal)
        {
          SubmittedListItem sli = ServiceNoteSelectedAnswer.createSubmittedListItem(snsa);
          if (sli.selectionInputId == id)
          {
            slil.Add(sli);
          }
        }
        return slil;
      }
      
      /***************************************************************************
       * view */
      /**
       * Request for list of selected list items
       ****************************************************************************/
       
      public static List<ServiceNoteSelectedAnswer> view (  SqlConnection connSpedmon
                                                          , DetailsLog log
                                                          , UserInfo uInfo
                                                          , long clientID
                                                          , long pracID
                                                          , long noteID
                                                          , long questionID
                                                          , string answerSource
                                                          , long? headerID
                                                          , long? headerNoteAnswerID)
      {

        List<ServiceNoteSelectedAnswer> rl = new List<ServiceNoteSelectedAnswer>();
        
        string sql = @"select * from dbo.SVCNOTES_NOTE_QUESTION_ANSWERS_SELECTED_VIEW(@userID, @userGroup, @userRank, @clientID, @pracID, @noteID, @questionID, @answerSource, @headerID, @headerNoteAnswerID)";

        List<SqlParameter> parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,    ParameterDirection.Input));
        parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup, ParameterDirection.Input));
        parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,  ParameterDirection.Input));

        parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt, clientID,      ParameterDirection.Input));
        parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt, pracID,        ParameterDirection.Input));
        parms.Add(Database.SqlParm("@noteID",         SqlDbType.BigInt, noteID,        ParameterDirection.Input));
        parms.Add(Database.SqlParm("@questionID",     SqlDbType.BigInt, questionID,    ParameterDirection.Input));
     
        parms.Add(Database.SqlParm("@answerSource",   SqlDbType.VarChar, answerSource, ParameterDirection.Input, 50));
        parms.Add(Database.SqlParm("@headerID",            SqlDbType.BigInt,  headerID,           ParameterDirection.Input));
        parms.Add(Database.SqlParm("@headerNoteAnswerID",  SqlDbType.BigInt,  headerNoteAnswerID, ParameterDirection.Input));

        ReturnDB rd = Database.execQuery(connSpedmon, log, sql, false, parms);
        Object[] ol = Database.convertRecords(rd.records, typeof(ServiceNoteSelectedAnswer));

        foreach (Object o in ol)
        {
          ServiceNoteSelectedAnswer r = (ServiceNoteSelectedAnswer)o;
          rl.Add(r);
        }

        return rl;
      }
            
    }
  
}
