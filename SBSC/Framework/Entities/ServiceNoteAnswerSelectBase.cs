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
    * ServiceNoteAnswerSelectBase */
   /**
    * An answer the user can select or an answer the user has selected
    * Note: Keep in sych with t-sql type answer submitted
    ****************************************************************************/  

   public abstract class ServiceNoteAnswerSelectBase
   {
     public long   noteID;
     public long   questionID;
     public long   headerID;
     public long   headerNoteAnswerID;
     public long   answerID; 	  
     public string answerValue;
     public bool   answerMarked;
     public string answerSource;
     public bool   answerSelected;
     public long   answerOrder;
  }
   
}