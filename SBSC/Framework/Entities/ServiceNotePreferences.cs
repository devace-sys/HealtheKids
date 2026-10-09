using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Specialized;
using MBA;

namespace Spedmon
{

    /***************************************************************************
     * ServiceNotePreferenceType
    /**
     * Service note preference type
     ****************************************************************************/

    public class ServiceNotePreferenceType
    {
      public long   id;
      public string ShortPrefDesc;
      public string LongPrefDesc;
      public bool   UseFormattedNotes;      
    }

    /***************************************************************************
     * ServiceNotePreferenceTypes
    /**
     * Methods used to work with service note preference types
     ****************************************************************************/

    public class ServiceNotePreferenceTypes : Entities
    {

      /***************************************************************************
       * viewSel */
      /**
       * 
       **************************************************************************/
       
      public static ReturnSel viewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, bool top, string topSize, string term)
      {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
          ss.addDisplayColumn("Description as context1");
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(connSpedmon, log, uInfo, top, topSize,
        delegate { return ServiceNotePreferenceTypes.view(connSpedmon, log, uInfo, Entities.REC_VIEW_SEL, top, topSize, "", "", dc); });

      }
      /***************************************************************************
       * view */
      /**
       * 
       **************************************************************************/

      public static ReturnDB view(SqlConnection connSpedmon,
                                   DetailsLog log,
                                   UserInfo uInfo,
                                   int recViewType,
                                   bool pagedOrTop,
                                   string idx,
                                   string canEdit,
                                   string active,
                                   defineCols dc)
      {

        string viewUDF = "dbo.SVCNOTE_PREFERENCE_TYPES_VIEW (null,null,null)";

        /*----------------------------
         * Validate parameters specific
         * to this entity.view
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/

        List<SqlParameter> parms = new List<SqlParameter>();

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

      }
    }
           
    /***************************************************************************
     * ServiceNotePreference */
    /**
     * Service note preference
     ****************************************************************************/

    public class ServiceNotesPreference
    {      
      public int    inputPracID;
      public long   mustUseNoteType;
      public long   currentTemplateID;
      public bool   mustSetAPreference;
      public bool   canChangePreference;
      public int    typePrefID;
      public long   currentPreferenceID;
      public string prefNote;
      public bool   useFormattedNotes;
      public string shortPrefDesc;
      public string longPrefDesc;
      public string mustUseReason;
    }
    
    /***************************************************************************
     * ServiceNotePreferences */
    /**
     * Service note preferences
     ****************************************************************************/
     
    public class ServiceNotesPreferences:Entities
    {
    
      /***************************************************************************
       * save */
      /**
       * Save service note preferences
       ****************************************************************************/
      
      public static ReturnSaveRecord save (SqlConnection connSpedmon
                                           , DetailsLog log
                                           , UserInfo uInfo
                                           , long pracID
                                           , string prefType
                                           , string prefNote
                                           , string editDelReason
                                           , string validateRec
                                           , string saveType
                                           , string recID)
      {
               
        /*----------------------------
         * Validate parameters specific
         * to this entity.save
         * and populate their
         * coresponding database
         * parameters
         *----------------------------*/
         
         int    prefTypeVal  = Validate.reqInteger (prefType, @"Invalid preference type");
         string prefNoteVal  = Validate.optString  (prefNote, @"Invalid preference note");

      
      
        List<SqlParameter> parms = new List<SqlParameter>();
            
        /*----------------------------
         * Populate db params
         *----------------------------*/          

        parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int,     pracID,       ParameterDirection.Input));
        parms.Add(Database.SqlParm("@prefType",  SqlDbType.Int,     prefTypeVal,  ParameterDirection.Input));
        parms.Add(Database.SqlParm("@prefNote",  SqlDbType.VarChar, prefNoteVal,  ParameterDirection.Input,8000));
    
        /*----------------------------
         * Call base method which 
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.save(connSpedmon, 
                             log, 
                             uInfo, 
                             saveType, 
                             validateRec, 
                             editDelReason, 
                             recID, 
                             "SVCNOTES_PRAC_PREFERENCE_SAVE", 
                             @"Duplicate preference", 
                             ref parms, 
                             null);
      }
      
      /***************************************************************************
       * load */
      /**
       * Load service note preferences
       ****************************************************************************/
      
      public static ServiceNotesPreference load (SqlConnection connSpedmon
                                                 , DetailsLog log
                                                 , UserInfo uInfo
                                                 , long pracID)
      {
        ServiceNotesPreference p = new ServiceNotesPreference();
          
        string sql = @"SVCNOTES_CHECK_PRAC_PREF";
          
        List<SqlParameter> parms = new List<SqlParameter>();

        parms.Add(Database.SqlParm("@pracID",                 SqlDbType.Int,     pracID,                ParameterDirection.Input));
        parms.Add(Database.SqlParm("@inputPracID",            SqlDbType.Int,     p.inputPracID,         ParameterDirection.Output));
        parms.Add(Database.SqlParm("@mustUseNoteType",        SqlDbType.BigInt,  p.mustUseNoteType,     ParameterDirection.Output));
        parms.Add(Database.SqlParm("@currentTemplateID",      SqlDbType.Int,     p.currentTemplateID,   ParameterDirection.Output));
        parms.Add(Database.SqlParm("@mustSetAPreference",     SqlDbType.Bit,     p.mustSetAPreference,  ParameterDirection.Output));
        parms.Add(Database.SqlParm("@canChangePreference",    SqlDbType.Bit,     p.canChangePreference, ParameterDirection.Output));
        parms.Add(Database.SqlParm("@currentPreferenceID",    SqlDbType.Int,     p.currentPreferenceID, ParameterDirection.Output));
        parms.Add(Database.SqlParm("@typePrefID" ,            SqlDbType.Int,     p.typePrefID,          ParameterDirection.Output));
        parms.Add(Database.SqlParm("@prefNote",               SqlDbType.VarChar, p.prefNote,            ParameterDirection.Output, 8000));
        parms.Add(Database.SqlParm("@shortPrefDesc",          SqlDbType.VarChar, p.shortPrefDesc,       ParameterDirection.Output, 8000));
        parms.Add(Database.SqlParm("@longPrefDesc",           SqlDbType.VarChar, p.longPrefDesc,        ParameterDirection.Output, 8000));
        parms.Add(Database.SqlParm("@mustUseReason",          SqlDbType.VarChar, p.mustUseReason,       ParameterDirection.Output, 8000));
        parms.Add(Database.SqlParm("@useFormattedNotes",      SqlDbType.Bit,     p.useFormattedNotes,   ParameterDirection.Output));
      
        ReturnDB rd = Database.execSproc(connSpedmon, log, sql,parms);
        p = (ServiceNotesPreference) Database.convertParameters(rd, typeof(ServiceNotesPreference));
        
        return p;
      
      }
      
    }

    /***************************************************************************
     * ServiceNotesPreferenceRequest */
    /**
     * Methods used for handling request
     ****************************************************************************/

    public class ServiceNotesPreferenceRequest:Return
    {
      
      public static string SVC_NOTE_PREF_PARM_PRAC_ID      = "svcnoteprefpracid";
      public static string SVC_NOTE_PREF_PARM_MODE         = "svcnoteprefmode";
      public static string SVC_NOTE_PREF_PARM_ORIGIN_PAGE  = "svcnotepreforiginpage";
      public static string SVC_NOTE_PREF_PARM_PREF_TYPE    = "svcnoteprefpreftype";
      public static string SVC_NOTE_PREF_PARM_PREF_NOTE    = "svcnoteprefnote";

      public static string PAGE_CLIENT_PROV_SVC_NOTES_PREF = "client_prov_svc_notes_preference.aspx";

      public string enterExitURL   = "";
      public bool   needToRedirect = false;
      public string newURL         = "";
      public string html           = "";
      public string homeURL        = "";
      
      public ServiceNotesPreference svcNotePref = null;
      
      /***************************************************************************
       * GenerateUrlClientProvSave */
      /**
       * 
       ****************************************************************************/

      public static string GenerateUrlClientProv (ServiceNoteCommon.NoteRequestMode mode, long pracID, string originPage)
      {
        return GenerateUrl (PAGE_CLIENT_PROV_SVC_NOTES_PREF, pracID, mode, originPage);
      }
      
      public static string GenerateUrlClientProv (ServiceNoteCommon.NoteRequestMode mode)
      {
        return GenerateUrl (PAGE_CLIENT_PROV_SVC_NOTES_PREF, mode);
      }            

      /***************************************************************************
       * GenerateUrl */
      /**
       * 
       ****************************************************************************/

      protected static string GenerateUrl (string page, long pracID, ServiceNoteCommon.NoteRequestMode mode, string originPage)
      {
        string url = MBA.HttpApplication.createLink( page
                                                     , true
                                                     , new NameValue(SVC_NOTE_PREF_PARM_PRAC_ID, pracID.ToString())
                                                     , new NameValue(SVC_NOTE_PREF_PARM_MODE, mode.GetHashCode().ToString())
                                                     , new NameValue(SVC_NOTE_PREF_PARM_ORIGIN_PAGE, originPage));
        return url;
      }
             
      public static string GenerateUrl (string page, ServiceNoteCommon.NoteRequestMode mode)
      {
        string url = MBA.HttpApplication.createLink( page
                                                     , true
                                                     , new NameValue(SVC_NOTE_PREF_PARM_MODE, mode.GetHashCode().ToString())
                                                    );
        return url;
      
      }
      
      /***************************************************************************
       * GeneratePreferenceSelection */
      /**
       * 
       ****************************************************************************/

      public static string generatePreferenceSelection (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, int value)
      {
        ReturnSel     rs   = ServiceNotePreferenceTypes.viewSel(connSpedmon, log, uInfo, false, "", "");
        StringBuilder sb   = new StringBuilder();
                
        sb.Append (@"<fieldset data-role=""controlgroup"" data-iconpos=""right"">");
        sb.Append (@"<legend><h3 style=""text-align:center;margin:0;padding:0;"">Please select one of the following answers</h3></legend>");

        foreach (SelRec r in rs.SelRecs)
        {
          string optionID = "svc-note-pref-" + r.id.ToString();
          string selAttr = "";
          if (r.id == value) selAttr = @"checked = ""checked""";
          sb.AppendFormat(@"<label><h4 style=""margin:0;padding:0;"">{0}</h4><h5 style=""margin:0;padding:0;"">{1}</h5><input id=""{2}"" name=""{3}"" value=""{4}"" type=""radio"" {5}></input></label>", r.label, r.context1, optionID , SVC_NOTE_PREF_PARM_PREF_TYPE, r.id,selAttr);
        }
        sb.Append(@"</fieldset>");
        
        return sb.ToString();
      }

      /***************************************************************************
       * GeneratePreferenceNote */
      /**
       * 
       ****************************************************************************/

      public static string generatePreferenceNote(string value)
      {
        if (Util.IsNullOrEmpty(value)) value = "";
        StringBuilder sb = new StringBuilder();
        sb.Append(@"<label>");
        sb.Append(@"<h3 style=""text-align:center;margin:0;padding:0;"">Please Type Any Additional Details on How Notes Are Kept</h3>");
        sb.AppendFormat(@"<textarea id=""{0}"" name=""{1}"">", SVC_NOTE_PREF_PARM_PREF_NOTE, SVC_NOTE_PREF_PARM_PREF_NOTE);
        sb.Append(value);
        sb.Append(@"</textarea>");
        sb.Append(@"</label>");
        return sb.ToString();
      }
      
      /***************************************************************************
       * GeneratePreferenceForm */
      /**
       * 
       ****************************************************************************/

      public static string generatePreferenceForm (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, long pracID, string originPage, string saveURL, int prefTypeVal, string prefNoteVal, string homeURL)
      {
        StringBuilder sb  = new StringBuilder();  

        sb.Append (@"<h2 style=""text-align:center;"">Where will you record and store your professional/progress notes?</h2>");	        
        
        sb.AppendFormat(@"<form id=""record"" data-ajax=""false"" method=""post"" action=""{0}"">", saveURL);        
        sb.AppendFormat(@"<input type=""hidden"" id=""{0}"" name=""{1}"" value=""{2}""/>",SVC_NOTE_PREF_PARM_PRAC_ID, SVC_NOTE_PREF_PARM_PRAC_ID, pracID);
        sb.AppendFormat(@"<input type=""hidden"" id=""{0}"" name=""{1}"" value=""{2}""/>",SVC_NOTE_PREF_PARM_ORIGIN_PAGE, SVC_NOTE_PREF_PARM_ORIGIN_PAGE, originPage); 
        
        sb.Append(generatePreferenceSelection(connSpedmon, log, uInfo, prefTypeVal));       
        sb.Append(generatePreferenceNote(prefNoteVal));

        sb.Append(@"<h3 style=""text-align:center;margin:0;padding:0;"">Please Select An Option</h3>");
        
        sb.Append (@"<input type=""submit"" value=""Save and Exit"" data-icon=""action""/>");
        sb.Append (@"<input type=""reset"" value=""Clear"" data-icon=""delete""/>");
        sb.AppendFormat (@"<a href=""{0}"" data-ajax=""false"" class=""ui-btn ui-icon-back ui-btn-icon-left"">Cancel and Exit</a>", homeURL);
        
        sb.Append (@"</form>");        

        return sb.ToString();
      }
      
      /***************************************************************************
       * GeneratePreferenceNoChangeMessage */
      /**
       * The message the practitioner sees if they are not allowed
       ****************************************************************************/
      
      public static string generatePreferenceNoChangeMessage(string originPageVal, string reason)
      {
        string messageHtml  = @"<div class=""ui-body ui-body-a ui-corner-all"">{0}{1}</div>";        
        string proceedHtml  = @"<a href=""{0}"" class=""ui-btn ui-icon-arrow-r ui-btn-icon-right"" data-ajax=""false"">Proceed</a>";
        
        string html  = String.Format( messageHtml
                       ,@"<p>Sorry you cannot change your preference for the following reason</p><p>" + reason + @"</p>"
                       ,String.Format(proceedHtml,originPageVal));

        return html;
      }

      /***************************************************************************
       * process */
      /**
       * Processes incoming request
       ****************************************************************************/
      
      public static ServiceNotesPreferenceRequest process (SqlConnection connSpedmon
                                                           , DetailsLog log
                                                           , UserInfo uInfo
                                                           , NameValueCollection httpRequestParms)
      {

        string pracIDStr     = httpRequestParms[SVC_NOTE_PREF_PARM_PRAC_ID];
        string modeStr       = httpRequestParms[SVC_NOTE_PREF_PARM_MODE];
        string entryTypeStr  = httpRequestParms[ServiceRecordEntryExitRequest.SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE];   
        string originPageStr = httpRequestParms[SVC_NOTE_PREF_PARM_ORIGIN_PAGE];
        string prefTypeStr   = httpRequestParms[SVC_NOTE_PREF_PARM_PREF_TYPE];
        string prefNoteStr   = httpRequestParms[SVC_NOTE_PREF_PARM_PREF_NOTE];
        
        if (Util.IsNullOrEmpty(pracIDStr))     pracIDStr     = uInfo.userPracIDStr;
        if (Util.IsNullOrEmpty(entryTypeStr))  entryTypeStr  = "0";
        if (Util.IsNullOrEmpty(originPageStr)) originPageStr = MBA.HttpApplication.createLink(MBA.Constants.HOME_PRIVATE, true);
        
        return process (connSpedmon, log, uInfo, pracIDStr, modeStr, entryTypeStr, originPageStr, prefTypeStr, prefNoteStr);
               
      }


      public static ServiceNotesPreferenceRequest process (SqlConnection connSpedmon
                                                           , DetailsLog log
                                                           , UserInfo uInfo
                                                           , string pracIDStr
                                                           , string modeStr
                                                           , string entryTypeStr
                                                           , string originPageStr
                                                           , string prefTypeStr
                                                           , string prefNoteStr)
      {
        ServiceNotesPreferenceRequest r = new ServiceNotesPreferenceRequest();
        
        r.homeURL                     = HttpApplication.createLink(MBA.Constants.HOME_PRIVATE, true);
               
        int    pracIDVal        = Validate.reqPracID  (uInfo, pracIDStr);
        int    modeVal          = Validate.reqInteger (modeStr,       @"Invalid mode");
        int    entryType        = Validate.reqInteger (entryTypeStr,  @"Invalid service entry type",true);                
        string originPageVal    = Validate.reqString  (originPageStr, @"Invalid origin page");        
        
        string loadUrl          = "";
        string saveUrl          = "";
        
        // Generate urls based on role
        
        if (uInfo.userRoleLower == Constants.ROLE_LEA_PROVIDER)
        {
          loadUrl = GenerateUrlClientProv(ServiceNoteCommon.NoteRequestMode.LOAD, pracIDVal, originPageVal);  
          saveUrl = GenerateUrlClientProv(ServiceNoteCommon.NoteRequestMode.SAVE);
          //saveUrl = GenerateUrlClientProv(ServiceNoteCommon.NoteRequestMode.SAVE, pracIDVal, originPageVal);
        }
        
        if (modeVal == (int)ServiceNoteCommon.NoteRequestMode.LOAD)
        {
          r.svcNotePref    = ServiceNotesPreferences.load(connSpedmon, log, uInfo, pracIDVal);            
          
          if (r.svcNotePref.canChangePreference == true)
          {
            r.html           = generatePreferenceForm(connSpedmon, log, uInfo, pracIDVal, originPageVal, saveUrl, r.svcNotePref.typePrefID, r.svcNotePref.prefNote, r.homeURL);
            r.needToRedirect = false;
          }
          else
          {
            r.html = generatePreferenceNoChangeMessage(originPageVal,r.svcNotePref.mustUseReason);
            r.needToRedirect = false;
          }
          // If we need to redirect come back here
        }
        
        else if (modeVal == (int)ServiceNoteCommon.NoteRequestMode.SAVE)
        {
          ReturnSaveRecord rs = ServiceNotesPreferences.save(connSpedmon, log, uInfo, pracIDVal, prefTypeStr, prefNoteStr,"","F",Constants.SAVE_TYPE_NEW.ToString(),"");
          
          if (rs.status == Return.RET_SUCCESS)
          {
            r.needToRedirect = true;
            r.newURL         = originPageVal;
          }
          else
          {
          
          }
        }
        else if (modeVal == (int)ServiceNoteCommon.NoteRequestMode.VIEW)
        {
        }
        
        return r;
      }
      
      
 

    }

}
