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
     * ServiceNoteRequests */
    /**
     * Methods used to work with requests
     ****************************************************************************/

    public class ServiceNoteRequests
    {

        /***************************************************************************
         * process */
        /**
         * Process page request
         ****************************************************************************/

        public static ServiceNoteRequest process ( SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , NameValueCollection httpRequestParms
                                                   , HttpFileCollection  httpRequestFiles)
        {

          ServiceNoteRequest r = new ServiceNoteRequest();

          string modeStr = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_MODE];
          int modeVal = Validate.reqInteger(modeStr, @"Invalid mode");
          
          /*============================================================
           * Load
           *============================================================*/  
             
          if (modeVal == (int) ServiceNoteCommon.NoteRequestMode.LOAD)
          {

            r = load(connSpedmon, log, uInfo, httpRequestParms);
            r.needToRedirect = false;                
          }

          /*============================================================
           * Save
           *============================================================*/  

          else if (modeVal == (int) ServiceNoteCommon.NoteRequestMode.SAVE)
          {
            r = save(connSpedmon, log, uInfo, httpRequestParms, httpRequestFiles);
            r.needToRedirect = true;
            if (r.note.noteCompleted)
            {                    
              r.newURL = r.entryExitURL;
            }
            else
            {              
              r.newURL = r.loadURL;
              r.newURL = r.newURL + @"&" + ServiceNoteCommon.SVC_NOTE_PARM_RESP_MSG + "=" + r.responseMessage;
            }
          }

          /*============================================================
           * View
           *============================================================*/  

          else if (modeVal == (int) ServiceNoteCommon.NoteRequestMode.VIEW)
          {
          }

          return r;
        }

        /***************************************************************************
         * load */
        /**
         * Load service note request for given noteid and step
         ****************************************************************************/

        public static ServiceNoteRequest load (  SqlConnection connSpedmon
                                               , DetailsLog    log
                                               , UserInfo      uInfo                                                
                                               , NameValueCollection httpRequestParms
                                               )
        {

            
            ServiceNoteRequest r = new ServiceNoteRequest();

            string noteidStr     = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_NOTE_ID];
            string questionIDStr = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_QUESTION_ID];
            string originPageStr = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_ORG_PAGE];
            string clientIDStr   = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_CLIENT_ID];
            string pracIDStr     = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_PRAC_ID];
            string entryTypeStr  = httpRequestParms[ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE];
            string entryExitStr  = httpRequestParms[ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM];        
            string respMsg       = httpRequestParms[ServiceNoteCommon.SVC_NOTE_PARM_RESP_MSG];
            
            int    entryTypeVal  = Validate.reqInteger  (entryTypeStr,  @"Invalid service entry type", true);
            long   noteidVal     = Validate.reqInteger  (noteidStr,     @"Invalid note id",            false);
            long   questionIDVal = Validate.reqInteger  (questionIDStr, @"Invalid question id",        false);
            string originPageVal = Validate.reqString   (originPageStr, @"Invalid origin page");
            int    clientIDVal   = Validate.reqClientID (uInfo,clientIDStr);
            int    pracIDVal     = Validate.reqPracID   (uInfo,pracIDStr);
            string entryExitVal  = Validate.reqString   (entryExitStr,  @"Invalid entry exit");
      
            return load(connSpedmon, log, uInfo, clientIDVal, pracIDVal, noteidVal, questionIDVal, entryExitVal, entryTypeVal, originPageVal, respMsg);

        }

        /***************************************************************************
         * load */
        /**
         * Load service note request for given noteid and step
         ****************************************************************************/

        public static ServiceNoteRequest load (  SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , long clientID
                                               , long pracID
                                               , long noteID
                                               , long questionID
                                               , string entryExitVal
                                               , int entryTypeVal
                                               , string originPage
                                               , string respMsg                                             
                                              )
        {

          ServiceNoteRequest r = new ServiceNoteRequest();
          
          r.responseMessage  = respMsg;
          r.clientID         = clientID;
          r.pracID           = pracID;
          r.noteID           = noteID;
          r.questionID       = questionID;

          r.entryType        = entryTypeVal;
          r.entryExit        = entryExitVal;
          r.originPage       = originPage;
          r.note             = ServiceNotes.load (connSpedmon, log, uInfo, clientID, pracID, r.noteID, r.questionID);
          r.question         = ServiceNoteQuestions.load (connSpedmon, log, uInfo, r.clientID, r.pracID, r.noteID, r.questionID);
          r.headers          = ServiceNoteAnswerHeaders.view (connSpedmon, log, uInfo, r.clientID, r.pracID, r.noteID, r.questionID);
          r.answerSelections = ServiceNoteAnswerSelections.view (connSpedmon, log, uInfo, r.clientID, r.pracID, r.noteID, r.questionID,null,null, null);
          r.selectedAnswers  = ServiceNoteSelectedAnswers.view  (connSpedmon, log, uInfo, r.clientID, r.pracID, r.noteID, r.questionID,null,null,null);
          r.homeURL          = MBA.HttpApplication.createLink(MBA.Constants.HOME_PRIVATE, true);
          r.backURL          = r.note.GenerateBackUrl    (r.entryExit,r.entryType, r.originPage);
          r.forwardURL       = r.note.GenerateForwardUrl (r.entryExit,r.entryType, r.originPage);
          r.loadURL          = r.note.GenerateSaveUrl (ServiceNoteCommon.NoteRequestMode.LOAD, r.entryExit, questionID, r.entryType, r.originPage);
          r.saveURL          = r.note.GenerateSaveUrl (ServiceNoteCommon.NoteRequestMode.SAVE, r.entryExit, questionID, r.entryType, r.originPage);

          r.listURL          = ServiceNotes.GenerateUrlClientProvViewNotesToSave (entryExitVal,entryTypeVal);
          r.entryExitURL     = ServiceRecordEntryExitRequest.GenerateUrlClientProv (entryExitVal,entryTypeVal);
          //r.selectedAnswers
          //r.selectedAnswersCombined = SelectionListItems.view(connSpedmon, log, uInfo, r.noteID, r.questionID);
            
          /*============================================================
           * Load previously selected answers if they exist
           *===========================================================*/               
            
          foreach (ServiceNoteAnswerHeader header in r.headers)
          {
            string                  ri = header.GenerateResponseId();
            List<SubmittedListItem> sl = new List<SubmittedListItem>();

            /*foreach (SelectionListItem sli in r.selectedAnswersCombined)
            {                
              if (sli.selectionInputId == ri)
              {
                sl.Add(sli);
              }
            }
              
            r.selectedAnswers.Add(ri,sl);                           */

          }
                                 
          
          return r;
        }
        

        /***************************************************************************
         * delete */
        /**
         * Delete note and associated records
         ****************************************************************************/
        
        public static ReturnDB delete (SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , long clientID
                                                , long pracID
                                                , long noteID
                                                , long questionID
                                                , int    entryType
                                                , string entryExit
                                                , string originPage
                                                )
        {
            /*============================================================
             * Reset note
             *============================================================*/
            
            DateTime today = DateTime.Now;
            
            string sql = "SVCNOTES_DELETE_NOTE_AND_RELATED_RECORDS";

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,  ParameterDirection.Input));

            parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt, clientID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt, pracID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@noteID",         SqlDbType.BigInt, noteID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@today",          SqlDbType.DateTime, today,        ParameterDirection.Input));
            
            /*============================================================
             * Call sproc and return
             *============================================================*/

            ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);
            return rd;
            
        }
      
  
        /***************************************************************************
         * reset */
        /**
         * Reset note to first question
         ****************************************************************************/
        
        public static ServiceNoteRequest reset (SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , long clientID
                                                , long pracID
                                                , long noteID
                                                , long questionID
                                                , int    entryType
                                                , string entryExit
                                                , string originPage
                                                )
        {
            /*============================================================
             * Reset note
             *============================================================*/
            
            DateTime today = DateTime.Now;
            
            string sql = "SVCNOTES_RESET_NOTE";

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,  ParameterDirection.Input));
            parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt, clientID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt, pracID,        ParameterDirection.Input));      
            parms.Add(Database.SqlParm("@noteID",         SqlDbType.BigInt, noteID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@today",          SqlDbType.DateTime, today,        ParameterDirection.Input));
                            
            ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);

            /*============================================================
             * Load newly updated note so we can get the next question to
             * answer.  In this case the first question.
             *============================================================*/

            ServiceNote note = ServiceNotes.load(connSpedmon, log, uInfo, clientID, pracID, noteID, null);

            /*============================================================
             * Load updated request with next question.
             *============================================================*/

            ServiceNoteRequest request = load (connSpedmon, log, uInfo, clientID, pracID, noteID, note.questionID, entryExit, entryType, originPage,"");

            return request;
        }
        
        /***************************************************************************
         * save */
        /**
         * Save responses to question
         ****************************************************************************/

        public static ServiceNoteRequest save (SqlConnection connSpedmon
                                               , DetailsLog log
                                               , UserInfo uInfo
                                               , NameValueCollection httpRequest
                                               , HttpFileCollection  httpFiles
                                              )
        {         
                        
            /*============================================================
             * Load existing note so we can determine what parameters
             * are expected
             *============================================================*/

            ServiceNoteRequest request = load (connSpedmon, log, uInfo, httpRequest);

            /*============================================================
             * Get expected parameters from httpRequest
             *============================================================*/

            bool receivedAllExpected = true;
            request.submittedLists   = new SubmittedLists();
            request.submittedAnswers = new List<ServiceNoteAnswerSubmitted>();
            
         
           /*============================================================
            * Determine if the reset, skip, delete, or proceed button was used
            *============================================================*/

            request.resetNoteUsed = false;
            string clearStr = httpRequest[ServiceNoteCommon.SVC_NOTE_PARM_RESET];
            if (!String.IsNullOrEmpty(clearStr)) request.resetNoteUsed = true;
                        
            request.proceedUsed = false;
            string proceedStr = httpRequest[ServiceNoteCommon.SVC_NOTE_PARM_PROCEED];
            if (!String.IsNullOrEmpty(proceedStr)) request.proceedUsed = true;
            
            request.skipUsed = false;
            string skipStr    = httpRequest[ServiceNoteCommon.SVC_NOTE_PARM_SKIP];
            if (!String.IsNullOrEmpty(skipStr)) request.skipUsed = true;
         
            request.deleteNoteAndRelRecUsed = false;
            string delStr  = httpRequest[ServiceNoteCommon.SVC_NOTE_PARM_DELETE];
            if (!String.IsNullOrEmpty(delStr)) request.deleteNoteAndRelRecUsed = true;
         
            /*============================================================
             * If reset was used, call reset this will return the url to
             * use next
             *============================================================*/

            if (request.resetNoteUsed == true)            
            {
              return reset (connSpedmon, log, uInfo, request.clientID, request.pracID, request.noteID, request.questionID, request.entryType, request.entryExit, request.originPage);
            }
            
            /*============================================================
             * If delete was used, call delete.  Then set notecompleted to
             * true so we can trigger loading the list of remaining notes
             * or the origin page.
             *============================================================*/
           
            if (request.deleteNoteAndRelRecUsed == true)
            {
              delete (connSpedmon, log, uInfo, request.clientID, request.pracID, request.noteID, request.questionID, request.entryType, request.entryExit, request.originPage);
              request.note.noteCompleted = true;
              return request;              
            }    
            
                        
            /*============================================================
             * If this question is optional and the user opted to skip then
             * we do not care about any answers they provided.  We will 
             * provide the default "skipped" answer in the answer save
             * routines 
             *============================================================*/
             
            if ((request.question.questionIsOptional == true) && (request.skipUsed == true))
            {              
              receivedAllExpected = true;
              return save (connSpedmon, log, uInfo, request.clientID, request.pracID, request.noteID, request.questionID, request.entryType, request.entryExit, request.originPage, request.originalFilename, request.savedFilename, request.fileSize, request.fileMimeType, request.submittedAnswers);
            }

            /*============================================================
             * Otherwise we do care about answers.
             *============================================================*/
                        
            foreach (ServiceNoteAnswerHeader header in request.headers)
            {
            
              string ri = header.GenerateResponseId(); /* Generate the id of the input we are expecting*/
              string rl = httpRequest[ri];             /* Retrieve it from the http request parameters */
              
              /*-------------------------------------
               * N level list
               *-------------------------------------*/                

              if (request.question.answerInputType == 1)
              {
              
                /*-------------------------------------
                 * We received a submitted answer list
                 *-------------------------------------*/                
                
                if (!String.IsNullOrEmpty(rl))
                {
                  request.submittedLists.Add(ri,rl);
                }

                /*--------------------------------------
                 * We did not 
                 *-------------------------------------*/                

                else
                {
                  receivedAllExpected = false;
                  break;
                }
                  
                /*============================================================
                 * Combine submitted items into one list
                 *============================================================*/

                bool hasEmptyLists = false;
                request.submittedItemsCombined = request.submittedLists.Combine(out hasEmptyLists);
            
                /*============================================================
                 * If one of the lists was empty and the question is not
                 * optional then not all of the questions were answered
                 *============================================================*/

                if (hasEmptyLists)
                {
                  request.note.noteCompleted = false;
                  request.responseMessage = "Please answer all questions";
                  return request;
                }
                  
                /*============================================================
                 * Convert submitted items into submitted answers
                 *============================================================*/
            
                foreach (SubmittedListItem sli in request.submittedItemsCombined)
                {
                  request.submittedAnswers.Add(ServiceNoteAnswerSubmitted.CreateNewFromSubmittedListItem(request.noteID, request.questionID, sli));
                }
            }
            
            else if (request.question.answerInputType == 2)
            {
                        
              bool filesExpected = true;
              bool filesReceived = false;
              string uploadPath  = Constants.SERVICE_NOTES_FILE_UPLOAD_PATH;            
              
              List<PostedFile> uploadedFiles = PostedFiles.saveFilesPosted(httpFiles,uploadPath);
              
              if (uploadedFiles.Count > 0) 
              {
                filesReceived = true;
                foreach (PostedFile uploadedFile in uploadedFiles)
                {
                  request.originalFilename = uploadedFile.uploadedAs;
                  request.savedFilename    = uploadedFile.savedAs;    
                  request.fileSize         = uploadedFile.fileSize;
                  request.fileMimeType     = uploadedFile.mimeType;              
                }
              }
              
              /*--------------------------------------
               * If files were expected and we did not
               * receive any exit
               *-------------------------------------*/
               
              if ((filesExpected == true) && (filesReceived == false))
              {                
                request.note.noteCompleted = false;
                request.responseMessage = "Please select a file to upload";
                return request;                  
              }

            
            }
            else
            {
            }
                
          }
            
          
          /*============================================================
           * In the event we did not receive all expected parameters
           * something went wrong
           *============================================================*/

          if (receivedAllExpected == false)
          {
            request.note.noteCompleted = false;
            request.responseMessage = "Unknown error try again";
            return request;
          }            


          /*============================================================
           * Continue with save
           *============================================================*/

          return save (connSpedmon, log, uInfo, request.clientID, request.pracID, request.noteID, request.questionID, request.entryType, request.entryExit, request.originPage, request.originalFilename, request.savedFilename, request.fileSize, request.fileMimeType, request.submittedAnswers);
        }


        /***************************************************************************
         * save */
        /**
         * Save responses to question
         ****************************************************************************/

        public static ServiceNoteRequest save (SqlConnection connSpedmon
                                                , DetailsLog log
                                                , UserInfo uInfo
                                                , long clientID
                                                , long pracID
                                                , long noteID
                                                , long questionID
                                                , int    entryType
                                                , string entryExit
                                                , string originPage
                                                , string originalFilename
                                                , string savedFilename
                                                , long   fileSize
                                                , string fileMimeType
                                                , List<ServiceNoteAnswerSubmitted> submitted
                                              )
        {

            /*============================================================
             * Save responses to step
             *============================================================*/

            string sql = "SVCNOTES_APPEND_NOTE_NOTEANSWERS";

            List<SqlParameter> parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt, uInfo.userid,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,    uInfo.userGroup, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,    uInfo.userRank,  ParameterDirection.Input));

            parms.Add(Database.SqlParm("@clientID",       SqlDbType.BigInt, clientID,      ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",         SqlDbType.BigInt, pracID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@noteID",         SqlDbType.BigInt, noteID,        ParameterDirection.Input));
            parms.Add(Database.SqlParm("@questionID",     SqlDbType.BigInt, questionID,    ParameterDirection.Input));
     
            
            parms.Add(Database.SqlParm("@originalFilename", SqlDbType.VarChar, originalFilename, ParameterDirection.Input, 8000));
            parms.Add(Database.SqlParm("@savedFilename",    SqlDbType.VarChar, savedFilename,    ParameterDirection.Input, 8000));
            parms.Add(Database.SqlParm("@fileSize",         SqlDbType.BigInt,  fileSize,         ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileMimeType",     SqlDbType.VarChar, fileMimeType,     ParameterDirection.Input, 8000));
            
            parms.Add(Database.SqlParmDataTable <ServiceNoteAnswerSubmitted> ("@svcNoteAnswersSubmitted", submitted, "SvcNoteAnswerSubmittedTblType"));

            ReturnDB rd = Database.execSproc(connSpedmon, log, sql, parms);

            
            /*============================================================
             * Load newly updated note so we can get the next question to
             * answer if any.
             *============================================================*/

            ServiceNote note = ServiceNotes.load(connSpedmon, log, uInfo, clientID, pracID, noteID, null);

            /*============================================================
             * Load updated request with next question.
             *============================================================*/

            ServiceNoteRequest request = load (connSpedmon, log, uInfo, clientID, pracID, noteID, note.questionID, entryExit, entryType, originPage,"");

            return request;
        }

    }


}
