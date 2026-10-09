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
   * ServiceNoteAnswerSelection */
  /**
   * An answer a user can select
   ****************************************************************************/  

   public class ServiceNoteAnswerSelection:ServiceNoteAnswerSelectBase
   {
     
     
     /***************************************************************************
      * generateSelectionListItem */
     /**
      * Generate selection list item HTML for selection source list
      ****************************************************************************/

     public string generateSelectionListItem ()
     {
       StringBuilder sb = new StringBuilder();

       sb.Append(@"<li class=""servicenoteguidedanswersdata"" data-role=""listitemselection""");
       
       sb.Append(@" data-selection-source=""{0}""");   // Source
       sb.Append(@" data-selection-from=""{1}""");     // Header note answer id  (was question id)
       sb.Append(@" data-selection-for=""{2}""");      // Header id
       sb.Append(@" data-selection-name=""{3}""");     // AnswerText
       sb.Append(@" data-selection-value=""{4}""");    // AnswerID
       sb.Append(@" data-selection-selected=""{5}"""); // Selected
       sb.Append(@"</li>");

       string listItemPtrn = sb.ToString();
            
            
        string selListItem = String.Format(listItemPtrn
                                           ,  this.answerSource
                                           ,  this.headerNoteAnswerID
                                            , this.headerID
                                            , this.answerValue
                                            , this.answerID
                                            , this.answerSelected.ToString().ToLower());
        return selListItem;
      }
  
     
   }
  
}