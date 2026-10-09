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
   * ServiceNoteAnswerSubmitted */
  /**
   * An answer a user can select
   ****************************************************************************/  

   public class ServiceNoteAnswerSubmitted:ServiceNoteAnswerSelectBase
   {

     public static ServiceNoteAnswerSubmitted CreateNewFromSubmittedListItem (long noteID, long questionID, SubmittedListItem sli)
     {
       ServiceNoteAnswerSubmitted snas = new ServiceNoteAnswerSubmitted();
       
       snas.noteID             = noteID;
       snas.questionID         = questionID;
       
       snas.headerID           = sli.selectionFor;    // Header ID   
       snas.headerNoteAnswerID = sli.selectionFrom;   // Header note answer ID (was question id)
       snas.answerID           = sli.selectionValue;  // AnswerID
       snas.answerValue        = sli.selectionName;   // AnswerText
       snas.answerMarked       = sli.selectionMarked; // Marked
       snas.answerSource       = sli.selectionSource; // Source
       snas.answerSelected     = true;
       snas.answerOrder        = sli.selectionIdx;
       
       return snas;       
     }

     
   }
  
}