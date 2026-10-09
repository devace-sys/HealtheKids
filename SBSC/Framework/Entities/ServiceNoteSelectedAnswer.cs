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
   * ServiceNoteSelectedAnswer */
  /**
   * An answer the user has selected
   ****************************************************************************/  

	public class ServiceNoteSelectedAnswer:ServiceNoteAnswerSelectBase
  {
  
     public static SubmittedListItem createSubmittedListItem (ServiceNoteSelectedAnswer snsa)
     {
       SubmittedListItem sli = new SubmittedListItem();
       
       sli.selectionInputId = "";
       sli.selectionFor     = snsa.headerID;              // Header ID   
       sli.selectionFrom    = snsa.headerNoteAnswerID;   // Header note answer ID (was question id)
       sli.selectionValue   = snsa.answerID;             // AnswerID
       sli.selectionName    = snsa.answerValue;          // AnswerText
       sli.selectionMarked  = snsa.answerMarked;         // Marked
       sli.selectionSource  = snsa.answerSource;         // Source
       sli.selectionIdx     = snsa.answerOrder;           
       sli.selectionInputId = ServiceNoteAnswerHeader.generateUniqueID(ServiceNoteAnswerHeader.PREFIX_RESP, snsa.noteID, snsa.questionID, snsa.headerID, snsa.headerNoteAnswerID);
       return sli;       
     }

  
  }
  
}