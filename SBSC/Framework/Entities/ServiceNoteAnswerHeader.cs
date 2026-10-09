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
   * ServiceNoteAnswerHeader */
  /**
   * Service note answer header (followup anwers to prev answer)
   ****************************************************************************/

   public class ServiceNoteAnswerHeader
   {
     public long   noteID;
     public long   questionID;
     public string questionText;
     public long   questionNumAllowedAnswers;
     public bool   questionIsOptional;
     public bool   answerUserFavoritesAllowed;
     public bool   answerUserEnteredAllowed;     
     public long   headerID;
     public long   headerNoteAnswerID;
     public string headerText;
     public long   headerOrder;
     
     public ServiceNoteAnswerHeader()
     {
     }

        /***************************************************************************
         * GenerateDataSourceId */
        /**
         * 
         ****************************************************************************/

        public string GenerateDataSourceId()
        {
          string dsid = "dsrc-" + this.noteID.ToString() + "-" + this.questionID.ToString() + "-" + this.headerID.ToString() + "-" + this.headerNoteAnswerID.ToString();
          return dsid;
        }
        
        /***************************************************************************
         * GenerateServiceNoteGuidedAnswerPartId */
        /**
         * 
         ****************************************************************************/
                  
        public string GenerateServiceNoteGuidedAnswerPartId()
        {
          string sngapid = "sngap-" + this.noteID.ToString() + "-" + this.questionID.ToString() + "-" + this.headerID.ToString() + "-" + this.headerNoteAnswerID.ToString();          
          return sngapid;
        }

        /***************************************************************************
         * GenerateResponseId */
        /**
         * 
         ****************************************************************************/
         
        public static string generateUniqueID (string prefix, long noteID, long questionID, long headerID, long headerNoteAnswerID)
        {
          /* Note: Do not change this format */
          string rid = prefix + "-" + noteID.ToString() + "-" + questionID.ToString() + "-" + headerID.ToString() + "-" + headerNoteAnswerID.ToString();          
          return rid;
        }
        
        public const string PREFIX_RESP = "resp";
        
        public string GenerateResponseId()
        {           
          return generateUniqueID(PREFIX_RESP,this.noteID, this.questionID, this.headerID, this.headerNoteAnswerID);
        }

    }   
}
