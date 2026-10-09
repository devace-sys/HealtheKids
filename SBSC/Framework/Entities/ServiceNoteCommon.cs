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
     * ServiceNoteCommon */
    /**
     * Common service note functionality
     ****************************************************************************/

    public class ServiceNoteCommon
    {
        public static string SVC_NOTE_PARM_NOTE_ID   = "svcnoteid";
        public static string SVC_NOTE_PARM_QUESTION_ID = "svcnotequestionid";
        //public static string SVC_NOTE_PARM_STEP      = "svcnotestep";
        public static string SVC_NOTE_PARM_MODE      = "svcnotepagemode";
        public static string SVC_NOTE_PARM_RESP_MSG  = "svcnoterspmsg";
        public static string SVC_NOTE_PARM_ORG_PAGE  = "svcnoteorgpage";
        public static string SVC_NOTE_PARM_DEST_PAGE = "svcnotedestpage";
        public static string SVC_NOTE_PARM_CLIENT_ID = "svcnoteclientid";
        public static string SVC_NOTE_PARM_PRAC_ID   = "svcnotepracid";
        public static string SVC_NOTE_PARM_PREF_ID   = "svcnoteprefid";
        public static string SVC_NOTE_PARM_PROCEED   = "proceed";
        public static string SVC_NOTE_PARM_SKIP      = "skip";
        public static string SVC_NOTE_PARM_RESET     = "reset";
        public static string SVC_NOTE_PARM_DELETE    = "delete";
                
        public static string PAGE_MODE_ENTER = "enter";
        public static string PAGE_MODE_EXIT = "exit";
        
        public static string PAGE_CLIENT_PROV_SVC_NOTES_SAVE = "client_prov_svc_notes_save.aspx";
        public static string PAGE_CLIENT_PROV_SVC_NOTE_SAVE  = "client_prov_svc_note_save.aspx";

        
        public static string SVC_NOTE_SELECTION_SOURCE_ALL = "all";
        public static string SVC_NOTE_SELECTION_SOURCE_FAV = "fav";
        public static string SVC_NOTE_SELECTION_SOURCE_NEW = "new";

        public enum NoteRequestMode
        {
          LOAD = 1,
          SAVE = 2,
          VIEW = 3
        }
        
     
    
    
                                    
    }
    
   
}
