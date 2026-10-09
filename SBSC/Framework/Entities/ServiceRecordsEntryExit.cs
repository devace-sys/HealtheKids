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
   * ServiceRecordEntryExitRequest */
  /**
   * Service record entry and exit point controller.
   ****************************************************************************/

    public class ServiceRecordEntryExitRequest : Return
    {

      public ServiceRecordEntryExitRequest()
      {
      }

      public string prefsURL   = "";
      public string notesURL   = "";
      public string svcRecURL  = "";
      public string homeURL    = "";
      
      public string html       = "";
      
      public bool   needToRedirect   = false;
      public string newURL           = "";

      public bool   showSetPrefsMessage         = false;
      public bool   showOutstandingNotesMessage = false;
      public bool   showCanChangePrefsMessage   = false;
      public bool   showSvcRecSaveOptions       = false;
      
      public ServiceNotesPreference svcNotePref = null;
      public List<ServiceNote>      svcNotes    = null;

      public static string SVC_REC_ENTRY_EXIT_PARM             = "svcrecentryexit";
      public static string SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE  = "svccrecentrytype";
      public static string SVC_REC_ENTRY_EXIT_PARM_CLIENT_ID   = "clientid";
      public static string SVC_REC_ENTRY_EXIT_PARM_PRAC_ID     = "pracid";
      public static string SVC_REC_ENTRY_EXIT_ENTER            = "enter";
      public static string SVC_REC_ENTRY_EXIT_EXIT             = "exit";
      public static string PAGE_CLIENT_PROV_SVC_REC_ENTER_EXIT = "client_prov_svcrec_entry_exit.aspx";


      /***************************************************************************
       * GenerateUrlClientProvEnter */
      /**
       * 
       ****************************************************************************/

      public static string GenerateUrlClientProvEnter(int entryType)
      {
        return GenerateUrlClientProv(SVC_REC_ENTRY_EXIT_ENTER, entryType);
      }

      /***************************************************************************
       * GenerateUrlClientProvExit */
      /**
       * 
       ****************************************************************************/

      public static string GenerateUrlClientProvExit(int entryType)
      {
        return GenerateUrlClientProv(SVC_REC_ENTRY_EXIT_EXIT, entryType);
      }

      /***************************************************************************
       * GenerateUrlClientProv */
      /**
       * 
       ****************************************************************************/

      public static string GenerateUrlClientProv (string enterExit, int entryType)
      {

        string url = MBA.HttpApplication.createLink(PAGE_CLIENT_PROV_SVC_REC_ENTER_EXIT
                                                    , true
                                                    , new NameValue(SVC_REC_ENTRY_EXIT_PARM, enterExit)
                                                    , new NameValue(SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE, entryType.ToString()));

        return url;
      }

      /***************************************************************************
       * process */
      /**
       * Processes incoming request
       ****************************************************************************/

      public static ServiceRecordEntryExitRequest process ( SqlConnection       connSpedmon
                                                          , DetailsLog          log
                                                          , UserInfo            uInfo
                                                          , NameValueCollection httpRequestParms)
      {




        string entryExitStr = httpRequestParms[SVC_REC_ENTRY_EXIT_PARM];
        string entryTypeStr = httpRequestParms[SVC_REC_ENTRY_EXIT_PARM_ENTRY_TYPE];
        string clientIDStr  = httpRequestParms[SVC_REC_ENTRY_EXIT_PARM_CLIENT_ID];
        string pracIDStr    = httpRequestParms[SVC_REC_ENTRY_EXIT_PARM_PRAC_ID];
        
        return process(connSpedmon, log, uInfo, entryExitStr, entryTypeStr, clientIDStr, pracIDStr);

      }


      public static ServiceRecordEntryExitRequest process ( SqlConnection connSpedmon
                                                          , DetailsLog    log
                                                          , UserInfo      uInfo
                                                          , string        entryExitStr
                                                          , string        entryTypeStr
                                                          , string        clientIDStr
                                                          , string        pracIDStr)
      {

        ServiceRecordEntryExitRequest r = new ServiceRecordEntryExitRequest();

        /*============================================================
         * Get parms
         *============================================================*/        

        string entryExitVal    = Validate.reqString  (entryExitStr, @"Entry/exit parameter requiried");
        int    entryTypeVal    = Validate.reqInteger (entryTypeStr, @"Entry type required", true);
        
        int    clientIDVal     = Validate.reqClientID (uInfo, clientIDStr);
        int    pracIDVal       = Validate.reqPracID  (uInfo,  pracIDStr);

        string messageHtml     = @"<div class=""ui-body ui-body-a ui-corner-all"">{0}{1}{2}</div>";        
        string proceedHtml     = @"<a href=""{0}"" class=""ui-btn ui-icon-arrow-r ui-btn-icon-right"" data-ajax=""false"">Proceed</a>";
        string svcRecHtml      = @"<a href=""{0}"" class=""ui-btn ui-icon-arrow-r ui-btn-icon-right"" data-ajax=""false"">Enter More Service Records</a>";
        string quitHtml        = @"<a href=""{0}"" class=""ui-btn ui-icon-arrow-l ui-btn-icon-left"" data-ajax=""false"">Quit and Return to SpEdCare HOME Screen</a>";

        string changeMindHtml  = @"please goto Service Records -> Where Do I Keep My Progress Notes";
        
        /*============================================================
         * Init
         *============================================================*/        
         
        r.showCanChangePrefsMessage   = false;
        r.showOutstandingNotesMessage = false;
        r.showSetPrefsMessage         = false;
        r.showSvcRecSaveOptions       = false;        
        r.needToRedirect              = false;
        r.homeURL                     = HttpApplication.createLink(MBA.Constants.HOME_PRIVATE, true);
        
        /*============================================================
         * Get preference for prac
         *============================================================*/

        r.svcNotePref = ServiceNotesPreferences.load(connSpedmon, log, uInfo, pracIDVal);
        
        /*============================================================
         * Generate URLS based on role
         *============================================================*/

        /*--------------------------------------
         * Practitioner
         *-------------------------------------*/

        if (uInfo.userRoleLower == Constants.ROLE_LEA_PROVIDER)
        {
          string returnPage = GenerateUrlClientProv(entryExitVal, entryTypeVal);
          r.prefsURL  = ServiceNotesPreferenceRequest.GenerateUrlClientProv(ServiceNoteCommon.NoteRequestMode.LOAD, pracIDVal, returnPage);
          r.notesURL  = ServiceNotes.GenerateUrlClientProvViewNotesToSave(entryExitVal,entryTypeVal);
          r.svcRecURL = ServiceRecords.GenerateUrlClientProv(entryTypeVal,r.svcNotePref.useFormattedNotes);
        }

        /*============================================================
         * If a preference must be set
         *============================================================*/

        if (r.svcNotePref.mustSetAPreference == true)
        {
          r.showSetPrefsMessage         = true;          
          r.newURL                      = r.prefsURL;
          r.html                        = String.Format( messageHtml
                                                        ,@"<h1 style=""text-align:center;font-weight:bold;"">NEW in January 2015</h1><h2 style=""text-align:center;"">You can keep your notes in SpEdCare or another place.</h2><h2 style=""text-align:center;"">Please indicate where you would like to keep them.</h2>" + @"<h2 style=""text-align:center;"">If you change your mind later " + changeMindHtml + @"</h2>"
                                                        ,String.Format(proceedHtml,r.newURL)
                                                        ,"");
          return r;
        }
            
        /*============================================================
         * Check for incomplete notes
         *============================================================*/
         
        int numNotes = 0;        
        r.svcNotes = ServiceNotes.viewIncompleteNotes(connSpedmon, log, uInfo, clientIDVal, pracIDVal, out numNotes);

        /*============================================================
         * If there are incomplete notes, user has to fill them out
         *============================================================*/

        if (numNotes > 0)
        {          
          
          r.newURL                      = r.notesURL;
          r.needToRedirect              = true;
          
          /*--------------------------------------
           * If incomplete notes were detected
           * on service record entry
           *-------------------------------------*/

          if (entryExitVal == SVC_REC_ENTRY_EXIT_ENTER)
          {
            r.needToRedirect              = false;
            r.showOutstandingNotesMessage = true;
            r.newURL                      = r.notesURL;
            r.html                        = String.Format( messageHtml
                                                          ,@"<h1 style=""text-align:center;"">Sorry - you did not finish your notes for your latest entry/entries.</h1><h2 style=""text-align:center;"">Please enter notes and save.</h2>"
                                                          ,String.Format(proceedHtml,r.newURL)
                                                          ,"");
          
          }
                             
          return r;
        }
                
        /*============================================================
         * If we are entering a service record entry session show
         * the change prefs message if the user can change their
         * prefs and they are not using the formatted notes option
         *============================================================*/

        if (entryExitVal == SVC_REC_ENTRY_EXIT_ENTER)
        {
          /*
          if (r.svcNotePref.canChangePreference == true)
          {
            if (r.svcNotePref.useFormattedNotes == false)
            {
              string additionalDetails = "";
              if (String.IsNullOrEmpty(r.svcNotePref.prefNote) == false)
                additionalDetails = @"<div style=""display:block;margin:0 auto;width:50%;""><h4 style=""text-align:center;"">Additional Details</h4><div style=""border:1px solid;padding:1em;white-space: pre-wrap;"">" + r.svcNotePref.prefNote + @"</div></div>";
              
              r.needToRedirect              = false;
              r.showCanChangePrefsMessage   = true;
              r.newURL                      = r.svcRecURL;         
              r.html                        = String.Format( messageHtml
                                                          ,@"<h2 style=""text-align:center;"">Our records indicate that you are keeping your notes</h2><h3 style=""text-align:center;"">" + r.svcNotePref.shortPrefDesc + @"</h3>" + additionalDetails + @"<h3 style=""text-align:center;"">If you change your mind about this " + changeMindHtml + @"</h3>"
                                                          ,String.Format(proceedHtml,r.newURL)
                                                          ,"");
            }
            else
            {
              r.needToRedirect              = true;
              r.showCanChangePrefsMessage   = false;
              r.newURL                      = r.svcRecURL;  
            }
          }
          else
          {
            r.needToRedirect              = true;
            r.showCanChangePrefsMessage   = false;
            r.newURL                      = r.svcRecURL;   
          }
          */
          
          // The commented out code above and these three lines below get rid of the bump screen for preference reminder
          
          r.needToRedirect              = true;
          r.showCanChangePrefsMessage   = false;
          r.newURL                      = r.svcRecURL;   

          return r;
          
        }

        /*============================================================
         * If we are exiting a service record entry (and note) session
         * ask user if they want to go home or enter more
         *============================================================*/

        if (entryExitVal == SVC_REC_ENTRY_EXIT_EXIT)
        {
          //r.showCanChangePrefsMessage = false;
          //r.newURL                    = r.svcRecURL;
          //r.needToRedirect            = true;                             
          //return r;
          
          r.needToRedirect              = false;
          r.showCanChangePrefsMessage   = false;
          r.newURL                      = r.svcRecURL;         
          r.html                        = String.Format( messageHtml
                                                          ,@"<h2 style=""text-align:center;"">Do you want to enter more service records or quit?</h2>"
                                                          ,String.Format(svcRecHtml, r.svcRecURL)
                                                          ,String.Format(quitHtml,   r.homeURL));
 
          return r;
          
        }

        return r;

      }
    }



   
}
