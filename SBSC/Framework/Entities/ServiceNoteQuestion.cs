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
     * ServiceNoteQuestion */
    /**
     * Service note question
     ****************************************************************************/

    public class ServiceNoteQuestion
    {
    
      public long   noteID;
      public long   questionID;
      public string questionText;
      public long   questionNumAllowedAnswers;
      public bool   questionIsOptional;
      public bool   answerUserFavoritesAllowed;
      public bool   answerUserEnteredAllowed;
      public long   answerInputType;
      
      public ServiceNoteQuestion()
      {
      }

      /***************************************************************************
       * GenerateQuestionFileId */
      /**
       * Generate file id
       ****************************************************************************/

      public string GenerateQuestionFilesId()
      {
        string fuid = "file-" + questionID.ToString();
        return fuid;
      }


      /***************************************************************************
       * GenerateQuestionFreeTextId */
      /**
       * Generate unique id
       ****************************************************************************/

      public string GenerateQuestionFreeTextId()
      {
        string ftid = "text-" + questionID.ToString();
        return ftid;
      }
        
    }

  
}
