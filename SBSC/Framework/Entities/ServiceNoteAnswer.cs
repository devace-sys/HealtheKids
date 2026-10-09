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
     * ServiceNoteAnswer */
    /**
     * Service note answer
     ****************************************************************************/

    public class ServiceNoteAnswer
    {         
        public long   NoteID;
        public long   QuestionID;
        public long   AnswerID;       
        public long   IsPracFavorite;
        public long   AnswerHeaderID;
        public string AnswerHeaderText;
        public string AnswerText;
        public int    AnswerInputType;
        public int    StoredAnswerID;
        public string AnswerValue;
        public int    IsCustomAnswer;
        public int    IsFollowup;        
        public int    AnswerRequiresFile;
        public int    AnswerRequiresText;
        public long   AnswerSequence;
        public long   ClosureHeaderAnswerID;
        public long   AnswerSelectionHeaderID;
        public long   AnswerSelectionHeaderText;
                           
        public ServiceNoteAnswer()
        {
        }

        
        /***************************************************************************
         * generateSelectionSource */
        /**
         * Generate selection source based on user favorite flag
         ****************************************************************************/

        public string generateSelectionSource()
        {
            string sSrc = ServiceNoteCommon.SVC_NOTE_SELECTION_SOURCE_ALL;
            if (this.IsPracFavorite == 1)
                sSrc = ServiceNoteCommon.SVC_NOTE_SELECTION_SOURCE_FAV;
            return sSrc;
        }
        
          /***************************************************************************
     * generateSelectionListItem */
    /**
     * Generate selection list item HTML for selection source list
     ****************************************************************************/

     public string generateSelectionListItem (long questionid)
     {
       StringBuilder sb = new StringBuilder();

       sb.Append(@"<li class=""servicenoteguidedanswersdata"" data-role=""listitemselection""");
       sb.Append(@" data-selection-source=""{0}""");
       sb.Append(@" data-selection-from=""{1}""");     // Question id
       sb.Append(@" data-selection-for=""{2}""");      // Header id
       sb.Append(@" data-selection-name=""{3}""");     // AnswerText
       sb.Append(@" data-selection-value=""{4}""");    // AnswerID
       sb.Append(@" data-selection-selected=""{5}"""); // Selected
       sb.Append(@"</li>");

       string listItemPtrn = sb.ToString();
            
        bool isSelected = false;
        if (this.StoredAnswerID > 0) 
        {
          isSelected = true;
        }
            
        string selListItem = String.Format(listItemPtrn
                                           , this.generateSelectionSource()
                                           , questionid
                                            , this.AnswerHeaderID
                                            , this.AnswerText
                                            , this.AnswerID
                                            , isSelected.ToString().ToLower());
        return selListItem;
      }
  
             
    }
 
}
