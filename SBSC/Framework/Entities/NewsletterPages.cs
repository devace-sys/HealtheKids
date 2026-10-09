

using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

using MBA.Reporting;
using MBA;



namespace Spedmon
{


   /***************************************************************************
    * NewsletterPage */
  /**
     **************************************************************************/  
    public class NewsletterPage : MBA.Entity
    {
        public const string DEFAULT_PAGING_ORDER = "id asc";

        public string appName;
        public string title;
        public string content;
        public bool okToDisplay;

        public string startDateStr;
        public string endDateStr;


        public string forContactRoleIdValsStr;
        public string forContactRoleNamesStr;

        public string forClientNamesStr;
        public string forClientIdValsStr;

        public string forUserRoleIdValsStr;
        public string forUserRoleNamesStr;

        public DateTime created;
        public long createdBy;
        public DateTime lastModified;
        public long lastModifiedBy;
       
        public string activeStr;

        public long revisionNum; 
        public bool readyToSend;
        public bool sentToAll;

        public string readyToSendStr;
        public string sentToAllStr;
        public bool mustResend;

        public bool sendEmailSelected;
        public string sendEmailSelectedStr;

        public bool    isResourceLibraryTopic;
        public string  tags;
        public string  tooltip;
        public string  isResourceLibraryTopicStr;
        public string  mustResendStr;
    }


   /***************************************************************************
    * NewsletterPageContentUserResponsePendingEmailNotification */
  /**
     **************************************************************************/  
    public class NewsletterPageContentUserResponsePendingEmailNotification : NewsletterPage
    {
        
        public long recipientClientID;
        public long contactID;

        public long recipUserID;
        public string contactName;
        public string email;
        public bool is_last_iter_per_batch;

    }


   /***************************************************************************
    * ReturnNewsletterPage */
  /**
     **************************************************************************/ 
    public class ReturnNewsletterPage : Return
    {
        public ReturnNewsletterPage() : base() { }
        public ReturnNewsletterPage(string msg) : base(msg) { }
        public ReturnNewsletterPage(Exception e) : base(e) { }
        public ReturnNewsletterPage(Warning e) : base(e) { }
        public ReturnNewsletterPage(Critical e) : base(e) { }
        public ReturnNewsletterPage(SessionExpired e) : base(e) { }

        public NewsletterPage multimediaPage = new NewsletterPage();
    }


   /***************************************************************************
    * NewsletterPages */
  /**
   * Graphically-emhanced richtext documents that can be sent as emails;
   * also included in help library
     **************************************************************************/ 
    public class NewsletterPages:Entities
    {
	     public const string SEL_LABEL_MANAGE          = @"Manage Newsletters";
	     public const string URL_MANAGE                = @"sbs_mgmt_newsletters_manage.aspx";
	     public const string MENU_LNK_ID_MANAGE        = @"multimediaoutcampmgmtlnk";
	
	     public const string SEL_LABEL = "Newsletters";
	     public const string SEL_LABEL_ADD = "Record New";
	     public const string SEL_LABEL_VIEW = "View";
	     public const string SEL_LABEL_EDIT_DELETE = "Review, Edit or Delete";
	     public const string SEL_LABEL_EDIT = "Edit";
	     public const string SEL_LABEL_SAVE = "Record New Newsletters";
	     public const string URL_SAVE = "sbs_mgmt_newsletter_page_save.aspx";
	     public const string MENU_ID_SAVE = "addnewsletterslink";
	
	     public const string URL_SVC_BASE = @"newsletter_pages.asmx";
	        
	     public const string URL_SVC_VIEW_SEL_BASE = URL_SVC_BASE + @"/viewSel";
	     public const string URL_SVC_DELETE_BASE = URL_SVC_BASE + @"/delete";
	     public const string URL_SVC_DELETE_INLINE_BASE = URL_SVC_BASE + @"/deleteinline";
	
	     public const string URL_REST_VIEW_BASE = @"api/v1/newsletters";
	
	     //public const string MENU_ID_MANAGE = @"multimediaoutcampmgmtlnk";
	
	     public const string URL_WEB_REPORT_BASE = @"newsletter_pages.ashx";
	     public const string URL_SEND_EMAIL_BASE = @"newsletter_pages.asmx/addindivrecipemailaddy";
	     public const string URL_RESEND_BASE = @"newsletter_pages.asmx/resetandrepublish";
	     public const string URL_DOWNLOAD_REPORT_BASE = @"newsletter_pages.ashx";
	
	     public const string URL_PAGEVIEW_BASE = "newsletter_page_private.aspx";
	     public const string URL_PAGEVIEW_RAW = "newsletter_page_content_private.ashx";
	

       /***************************************************************************
        * URL_REST_VIEW_SEL_INLINE */
       /**
        * 
        **************************************************************************/
        public static string URL_REST_VIEW_SEL_INLINE()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_SVC_VIEW_SEL_BASE, true);
        }

       /***************************************************************************
        * URL_REST_VIEW */
       /**
        * 
        **************************************************************************/
        public static string URL_REST_VIEW()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_REST_VIEW_BASE, true);
        }

       /***************************************************************************
         * URL_WEB_REPORT */
       /**
        * 
        **************************************************************************/
        public static string URL_WEB_REPORT()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_WEB_REPORT_BASE, true);
        }


       /***************************************************************************
        * URL_ADD_NEW */
       /**
        * 
        **************************************************************************/
        public static string URL_ADD_NEW()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_SAVE
                                                  , true
                                                  , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                  , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_NEW)
                                                  );
        }

       /***************************************************************************
        * URL_EDIT */
       /**
        * 
        **************************************************************************/
        public static string URL_EDIT()
        {
             return MBA.HttpApplication.createLink(NewsletterPages.URL_SAVE
                                                    , true
                                                    , new NameValue(Constants.PARM_APP_MODE, Constants.AMD_UI_DBS_SUB_PAGE)
                                                    , new NameValue(Constants.PARM_SAVE_TYPE, Constants.SAVE_TYPE_EDIT)
                                                    , new NameValue(Constants.PARM_REC_ID, @"")
                                                  );
        }

        /***************************************************************************
         * URL_DELETE_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_DELETE_INLINE()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_SVC_DELETE_INLINE_BASE
                                                  , true
                                                 );
        }

        /***************************************************************************
        * URL_SEND_EMAIL */
        /**
         * 
         **************************************************************************/
        public static string URL_SEND_EMAIL()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_SEND_EMAIL_BASE
                                                  , true
                                                 );
        }

        /***************************************************************************
       * URL_RESEND_BASE */
        /**
         * 
         **************************************************************************/
        public static string URL_RESEND()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_RESEND_BASE
                                                  , true
                                                 );
        }

        /***************************************************************************
       * URL_DOWNLOAD_REPORT */
        /**
         * 
         **************************************************************************/
        public static string URL_DOWNLOAD_REPORT()
        {
            return MBA.HttpApplication.createLink(NewsletterPages.URL_DOWNLOAD_REPORT_BASE
                                                  , true
                                                 );
        }


	  /**
	   * addIndivRecipEmailAddy 
	   *
	   * Sends a multimedia newsletter to one or more email addresses, manually entered, with a custom text body prepended in the email

	   * @param connSpedmon   SqlConnection object to Spedmon database, where newsletter entries are stored
	   * @param log           DetailsLog object
	   * @param uInfo         UserInfo object pertaining to logged-in user (found from URL token)
	   * @param mm_recid        unique numeric ID for the multimedia message to be sent
	
	   * @param email_address   string of email addresses, separated by commas or semicolons, to which the emails will be sent
	
	   * @param custom_msgbody  freeform text to be prepended in the message body
	
	   * @return              serializable ReturnSaveRecord object containing exception object from SMTP call, if any
	
	   */

       public static ReturnSaveRecord addIndivRecipEmailAddy(

                                                  // this method is mis-named; does not actually add anything anywhere in the database.
                                                  // should be re-named as addIndivRecipEmailAddys() up and down the call stack
                                                  // and the URL endpoint should be renamed as well.
 
                                                  SqlConnection connApp
	                                            , DetailsLog    log
											    , UserInfo      uInfo
                                                , string        mm_recid
                                                , string        email_address

                                                // MISNAMED; this ought to be called email_addresses,
                                                // in JS and all the way up and down the call stack

                                                , string custom_msgbody)

       {

          string retEmailOutStatus = "";

          var n = Spedmon.NewsletterPages.load(
            connApp, log, uInfo, mm_recid);
      
          /* Wrap content in tr and td so its compatible with the outer markup used in Email.generateHtmlContentWithHeroImage60pct */

          var msgBody = String.Format( @"<tr class=""{0}tr""><td class=""{0}td"">{1}</td></tr>"
                              , Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT
                              , n.content);

          email_address  =  email_address.Replace(';',',');

          var plural_email_addresses =  email_address.Split(',');

          foreach( var email_address_i in plural_email_addresses) { 

            var result = MBA.Email.sendAnnouncementAsHtmlWithHeroImageAndRichText(

               //0,  // userMsgId; these messages don't have a corresponding dialog widget to open, so the URL param openmsgmodal
               // will not be applicable
   
               false, // promptUserToGotoURL
               null,
               null,  // ManPage notifications will also not have a gotoURL callback, at least for this release

               Constants.APP_EMAIL_FROM,

               email_address_i , //n.email,

               custom_msgbody ,

               n.title, // newManPageSubject,
               "",

               msgBody,

               MBA.EmbeddedResources.CommonImages.IMAGE_NAME_PCA_LOGO_W_PENCIL,


               out retEmailOutStatus
            );
      

            if (!result) { 
              var retval_bad = new ReturnSaveRecord( new Exception(retEmailOutStatus) );
              
              return retval_bad;
            }

          }

          return new ReturnSaveRecord();

       }


       /***************************************************************************
        * delete */
       /**
        * "Deletes" a multimedia newsletter
        *
        * @return                 ReturnSaveRecord
       ***************************************************************************/  
       public static ReturnSaveRecord delete (  SqlConnection connUsers
	                                            , DetailsLog    log
											                        , UserInfo      uInfo
											                        , string        editDelReason
											                        , string        validateRec
											                        , string        recID )
       {
	
	      string appName   = Constants.APP_NAME;  
	      List<SqlParameter> parms  = new List<SqlParameter>();
	      parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, appName, ParameterDirection.Input,50));
	
	
	      return Entities.delete(connUsers,log,uInfo, editDelReason,validateRec,recID, "NEWSLETTER_PAGE_DELETE", ref parms);

       }


	   /**
	    * save */
       /* Calls SQL procedure to save new or edit existing newsletter.
	
	    * @param startDate     date from which an email campaign is schedule to begin
	    * @param forContactRoleIds     all client contact roles for which the emails will be sent, indicated by numeric IDs, comma-separated
	
	    * @param forUserRoleIds     all client web account user roles for which the emails will be sent, indicated by numeric IDs, comma-separated
	
	    * @param forClientIds       all client IDs for which the emails will be sent, indicated by numeric IDs, comma-separated; narrows down the selected web user or client contact emails, to the selected clients only
	
	    * @param title         title of the message; used as subject in outgoing emails
	    * @param content       HTML content to be saved and sent, including with base64 encoded PNGs
	
	    * @param readyToSend                toggle switch to pause or delay sending out emails containing this message
	
	    * @param isResourceLibraryTopic     NOT USED
	
	    * @param tags                       space-separated list of keywords, intended for searchability
	
	    * @param tooltip                    freeform text intended to be rendered in a hover-over popup tooltip, for previewing.  TODO - NOT YET IMPLEMENTED
	
	    * @param saveType       "1" if saving new object; "2" if edit existing
	    * @param validateRec    "1" or "Y" to run the save routine in the database, to preview any possible error messages, without committing changes to the database.  "0" or "N" to commit changes to the database.
	    * @param editDelReason  NOT IMPLEMENTED for this save procedure; no effect
	    * @param recID          unique numeric ID for an existing record, if edit (with saveType="2").  Otherwise leave null or empty string
	
	    * @return              ReturnSaveRecord
	
	    */


       public static ReturnSaveRecord save (  SqlConnection    connSpedmon
                                            , DetailsLog    log
                                            , UserInfo      uInfo

                                            , string        startDate                                          

                                            , string        forContactRoleIds
                                            , string        forUserRoleIds

                                            , string        forClientIds

                                            , string        title
                                            , string        content


                                            , string        readyToSend

                                            , string    isResourceLibraryTopic
                                            , string    tags
                                            , string    tooltip

                                            , string    sendEmailSelected

                                            , string        saveType
                                            , string        validateRec
                                            , string        editDelReason
                                            , string        recID )
       {

	        string appName = Constants.APP_NAME;
	
	        List<SqlParameter> parms = new List<SqlParameter>();
	
	        string    saveSproc             = "NEWSLETTER_PAGE_SAVE";
	
	
	
	        string    vAppName              = Validate.reqString        ( appName,              Messages.NO_APP_NAME );
	        DateTime  vStartDate            = Validate.reqDate          ( startDate,            Messages.INVALID_START_DATE );
	 
	
			string    vForContactRoleIds       = Validate.optRecIDMultiStr ( forContactRoleIds,       @"Invalid contact role ids");
	
	        string vForUserRoleIds = Validate.optRecIDMultiStr (forUserRoleIds,       @"Invalid user role ids");
	
	
	        string    vForClientIds         = Validate.optRecIDMultiStr ( forClientIds,         @"Invalid client ids");
	        string    vTitle                = Validate.reqString        ( title,                @"Invalid title" );
	        string    vContent              = Validate.reqString        ( content,              @"Invalid content" );
	
			bool vreadyToSend = Validate.reqFlag          (readyToSend,          @"ready to send?" );

            bool vSendEmailSelected = Validate.reqFlag( sendEmailSelected, "send as email?");

            bool vIsResourceLibraryTopic = Validate.reqFlag(isResourceLibraryTopic, "is resource library topic?");
	
	        string vTags                 = Validate.optString( tags );
	        if (vTags == null) vTags = "";
	
	        string vTooltip              = Validate.optString( tooltip );
	        if (vTooltip == null) vTooltip = "";
	
	        if ( Util.IsNullOrEmpty(forContactRoleIds) && Util.IsNullOrEmpty(forUserRoleIds) ) { 
	          var retv1 = new ReturnSaveRecord ( new Critical() );
	          retv1.details = new string[] { "please specify recipents by user role or contact" };
	          return retv1;
	        }
	
	        if ( ! Util.IsNullOrEmpty(forContactRoleIds) && ! Util.IsNullOrEmpty(forUserRoleIds) ) { 
	          var retv2 = new ReturnSaveRecord ( new Critical() );
	          retv2.details = new string[] { "please specify recipents by user role or contact, not both" };
	          return retv2;
	        }
	
	        parms.Add(Database.SqlParm( "@appName",              SqlDbType.VarChar,   vAppName,             ParameterDirection.Input, 50) );
	        parms.Add(Database.SqlParm( "@startDate",            SqlDbType.DateTime,  vStartDate,           ParameterDirection.Input) );
	
			parms.Add(Database.SqlParm( "@forContactRoleIdsStr",    SqlDbType.VarChar,   vForContactRoleIds,      ParameterDirection.Input, 8000) );
	
			parms.Add(Database.SqlParm("@forUserRoleIdsStr",    SqlDbType.VarChar,   vForUserRoleIds,      ParameterDirection.Input, 8000) );
	
	
	        parms.Add(Database.SqlParm( "@forClientIdsStr",      SqlDbType.VarChar,   vForClientIds,      ParameterDirection.Input, 8000) );
	        parms.Add(Database.SqlParm( "@title",                SqlDbType.VarChar,   vTitle,               ParameterDirection.Input, 512)  );
	        parms.Add(Database.SqlParm( "@content",              SqlDbType.VarChar,   vContent,             ParameterDirection.Input, -1) );
	        parms.Add(Database.SqlParm( "@readyToSend",          SqlDbType.Bit, vreadyToSend,         ParameterDirection.Input) );
	
	
	        parms.Add(Database.SqlParm("@isResourceLibraryTopic",      SqlDbType.Bit,   vIsResourceLibraryTopic,     ParameterDirection.Input)  );
	        parms.Add(Database.SqlParm("@tags",                        SqlDbType.VarChar,  vTags,                   ParameterDirection.Input, 512) );
	        parms.Add(Database.SqlParm("@tooltip",                     SqlDbType.VarChar,  vTooltip,                ParameterDirection.Input, 1000) );

            parms.Add(Database.SqlParm("@sendEmailSelected", SqlDbType.Bit, vSendEmailSelected, ParameterDirection.Input, 1000));

            ReturnSaveRecord so = Entities.save (  connSpedmon
	                                             , log
	                                             , uInfo
	                                             , saveType
	                                             , validateRec
	                                             , editDelReason
	                                             , recID
	                                             , saveSproc
	                                             , @"Duplicate content"
	                                             , ref parms
	                                             , delegate(){});
	
	        return so;

       }


      /***************************************************************************
       * view */
      /**
       * Returns a database result set of one or many Newsletter records
	
       * @param includeContent     string "1" or "0"; include the full body of the articl
       * @return                   ReturnDB
	
       */
       protected static ReturnDB view (  SqlConnection connUsers
                                    , DetailsLog    log
                                    , UserInfo      uInfo
                                    , string        appName
                                    , int           recViewType
                                    , defineCols dc
                                    , bool          pagedOrTop
                                    , string        idx
                                    , string        canEdit
                                    , string        active
                                    , string        term
                                    , string        includeContent                     = "0"
                                    , string        wIncluJoinsFromDropDownSelections  = "0"
                                     )
       {

	      List<SqlParameter> parms        = new List<SqlParameter>();
          
	      string             viewUDF             = "NEWSLETTER_PAGES_VIEW(@userID, @userGroup, @userRank, @appName, @active, null, @includeContent, @wIncluJoinsFromDropDownSelections, @term, @recID)";
	      Object             vAppName            = Validate.optString  (appName,            Messages.NO_APP_NAME);

	      bool               vIncludeContent     = Validate.reqFlag    (includeContent,     @"Invalid include content flag");

          bool               vIncluJoinsFromDropDownSelections     = Validate.reqFlag    (wIncluJoinsFromDropDownSelections,     @"Include selections?");

	      Object             vTerm               = Validate.optString  (term,               Messages.INVALID_SEARCH_TERM);

	      parms.Add(Database.SqlParm("@appName",            SqlDbType.VarChar, vAppName,            ParameterDirection.Input, 50));

	      parms.Add(Database.SqlParm("@term",               SqlDbType.VarChar, vTerm,               ParameterDirection.Input, 256));

	      parms.Add(Database.SqlParm("@includeContent",                         SqlDbType.Bit, vIncludeContent,               ParameterDirection.Input));
	      parms.Add(Database.SqlParm("@wIncluJoinsFromDropDownSelections",      SqlDbType.Bit, vIncluJoinsFromDropDownSelections,               ParameterDirection.Input));
	
	      return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

       }


      /***************************************************************************
       * viewCombinedSearch */
      /**
       * Calls a UDF that UNIONs results from ManPages and Newsletters, based on the search term.

       * @return                   ReturnDB
	
       ***************************************************************************/ 
       protected static ReturnDB viewCombinedSearch(
                                      SqlConnection connApp
                                    , DetailsLog log
                                    , UserInfo uInfo
                                    , string appName
                                    , int recViewType
                                    , bool pagedOrTop
                                    , string idx
                                    , string term
                                    , defineCols dc)
       {

	        List<SqlParameter> parms = new List<SqlParameter>();

            var vCliID = Validate.optClientID(uInfo, "");

            string viewUDF = "[NEWSLETTER_PAGE_AND_MANPAGE_COMBINED_SEARCH]" +
	          "(@userID, @userGroup, @userRank, @clientID, @appName, @navURLManPage, @navURLMultimediaPage, @term, @recID)";
	        Object vAppName = Validate.optString(appName, Messages.NO_APP_NAME);
	
	        Object vTerm = Validate.optString(term, Messages.INVALID_SEARCH_TERM);

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vCliID, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, vAppName, ParameterDirection.Input, 50));
	
	        parms.Add(Database.SqlParm("@navURLManPage",
	            SqlDbType.VarChar,
	
	            MBA.HttpApplication.createLink(
	              ManPages.URL_MAN_PAGE_PRIVATE ,
	              true,
	              new NameValue("recID", "")
	              )
	            ,
	
	            ParameterDirection.Input, 250)
	            );
	
	        parms.Add(Database.SqlParm("@navURLMultimediaPage",
	            SqlDbType.VarChar,
	
	            MBA.HttpApplication.createLink(
	              NewsletterPages.URL_PAGEVIEW_RAW,
	              true,
	              new NameValue("recID", "")
	              )
	            ,
	
	            ParameterDirection.Input, 250)
	            );
	
	        parms.Add(Database.SqlParm("@term", SqlDbType.VarChar, vTerm, ParameterDirection.Input, 256));
	
	        return Entities.view(connApp, log, uInfo, recViewType, pagedOrTop, idx, "" /* canEdit */, "" /* active */, viewUDF, ref parms, null, dc);

       }


      /***************************************************************************
       * viewTblRecipListReportAll */
      /**
       * Calls the view() method and populates a ReturnDataTable object

       * @return                   ReturnDataTable
	
       ***************************************************************************/ 
       public static ReturnDataTable viewTbl (  SqlConnection connUsers
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , bool          paged
                                              , string        pageNumber
                                              
                                              , string        canEdit
                                              , string        active )
       {

	
	      string     appName  =  Constants.APP_NAME;
	
	      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
	      {
	
	        ss.addDisplayColumn ("id as [id]", true);
	
	        ss.addDisplayColumn ("created              as [Created At]");
	        ss.addDisplayColumn ("title                as [Title]");
	        ss.addDisplayColumn ("revisionNum          as [Revision Num]");
	        ss.addDisplayColumn ("lastModified               as [Last Modified]");
	        ss.addDisplayColumn ("readyToSend                as [Ready to Send?]");
            ss.addDisplayColumn ("isResourceLibraryTopicStr  as [Resource Library Topic?]");
	        ss.addDisplayColumn ("sentToAll                  as [Sent?]");
	        ss.addDisplayColumn ("mustResend                 as [Will Re-send?]");
	
	        //ss.addDisplayColumn ("rowOrder",true);
	
	        pageroworder = ss.pageRowOrder();
	      };
	
	      return Entities.viewTbl(connUsers, log, uInfo, paged, pageNumber,
	        delegate{return NewsletterPages.view (connUsers,log,uInfo, appName, Entities.REC_VIEW_TBL, dc, paged, pageNumber, canEdit, active, null);}
	        , @"Newsletters - View"
	        , Messages.CONFIDENTIAL
	        );

       }


      /***************************************************************************
       * logSaveMessageSentNow */
      /**
       * Persists in the database rows and flag updates pertaining to sent messages.
       * Called from batch mailer.

       * @return                   ReturnSaveRecord
	
       ***************************************************************************/ 
       public static ReturnSaveRecord logSaveMessageSentNow (  SqlConnection connApp
	                                                         , DetailsLog    log
											                 , UserInfo      uInfo
											                 , string        appName
											                 , string        emailAddy

                                                             , string        clientID
                                                             , string        contactID
                                                             , string        recipUserID

                                                             , string        revisionNum
                                                             , string        taskComplete

                                                             , string        recID )
       {
            List<SqlParameter> parms = new List<SqlParameter>();

            string saveSproc = "NEWSLETTER_PAGES_LOG_SENT_NOW";

            string vAppName  = Validate.reqString(appName, Messages.NO_APP_NAME);

            var vClient      = Validate.optInteger(clientID, "invalid client id", true);

            var vEmailAddy   = Validate.reqEmail(emailAddy, "req email address");

            var vContactID   = Validate.optInteger(contactID, "invalid contact ID",  true);

            var vRecipUserID = Validate.optInteger(recipUserID, "invalid user ID", true);

            var vRevision    = Validate.reqInteger(revisionNum, "req revision number");
             
            var vComplete    = Validate.reqFlag(taskComplete, "complete?");

           
            parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, vAppName, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@emailAddy", SqlDbType.VarChar, vEmailAddy, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt,  vClient, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@contactID", SqlDbType.BigInt, vContactID, ParameterDirection.Input, -1));
            parms.Add(Database.SqlParm("@recipUserID", SqlDbType.BigInt, vRecipUserID, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@revisionNum", SqlDbType.BigInt, vRevision, ParameterDirection.Input, -1));

            parms.Add(Database.SqlParm("@taskComplete", SqlDbType.Bit, vComplete, ParameterDirection.Input));


            ReturnSaveRecord so = Entities.save(connApp
                                                 , log
                                                 , uInfo
                                                 , "1" // saveType
                                                 , "0" //validateRec
                                                 , "" //editDelReason
                                                 , recID
                                                 , saveSproc
                                                 , @"Duplicate content"
                                                 , ref parms
                                                 , delegate () { });

            return so;
       }

      /***************************************************************************
       * viewRecipListReportAll */
      /**
       * A statistical report of messages sent, per newsletter and per destination address.

       * @return                   ReturnDB
	
       ***************************************************************************/ 
       protected static ReturnDB viewRecipListReportAll (  SqlConnection connUsers
                                    , DetailsLog    log
                                    , UserInfo      uInfo
                                    , string        appName
                                    , int           recViewType
                                    , bool          pagedOrTop
                                    , string        idx
                                    , string        canEdit

                                    , string        pageID

                                    , string        active

                                    , defineCols    dc )
       {

	      List<SqlParameter> parms        = new List<SqlParameter>();
	
	      string             viewUDF             = "NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL(@userID, @userGroup, @userRank, null, @pageID, @appName)";
	      Object             vAppName            = Validate.optString  (appName,            Messages.NO_APP_NAME);
	
	      Object            vPageID                = Validate.reqInteger(pageID, "requires valid message ID");
	
	      parms.Add(Database.SqlParm("@appName",            SqlDbType.VarChar, vAppName,            ParameterDirection.Input, 50));
	
	      parms.Add(Database.SqlParm("@pageID", SqlDbType.BigInt, vPageID, ParameterDirection.Input, -1)) ;
	
	      return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

       }


      /***************************************************************************
       * viewTblRecipListReportAll */
      /**
       * Calls viewRecipListReportAll() and populates a ReturnDataTable object

       * @return                   ReturnDataTable
	
       ***************************************************************************/ 
       public static ReturnDataTable viewTblRecipListReportAll (  SqlConnection connUsers
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , bool          paged
                                              , string        pageNumber
                                              
                                              , string        canEdit

                                              , string        recid

                                              , string        active )
       {


	      string     appName  =  Constants.APP_NAME;
	
	      defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
	      {
	
	        //ss.addDisplayColumn ("id as [id]", true);
	        ss.addDisplayColumn ("id as [msg_id]", false);
	
	        ss.addDisplayColumn ("recipientClientID" );
	
	        ss.addDisplayColumn ("email" );
	        ss.addDisplayColumn ("contactName" );
	
	        ss.addDisplayColumn ("contactID" );
	        ss.addDisplayColumn ("recipUserID" );
	
	        ss.addDisplayColumn ("title                as [Title]");
	
	        ss.addDisplayColumn ("created              as [Created At]");
	
	        ss.addDisplayColumn ("revisionNum          as [Curr Revision Num]");
	        ss.addDisplayColumn ("lastModified         as [Last Modified]");
	
	        ss.addDisplayColumn ("readyToSend          as [Curr Rev Ready to Send?]");
	        ss.addDisplayColumn ("sentToAll            as [Curr Or Past Rev\nSent To All?]");
	
	        ss.addDisplayColumn ("sentRevisionNum      as [Sent Revision Num]");
	
	
	        ss.addDisplayColumn ("notifiedByEmailFirstTime       as [thisRecipNotifiedWSentRevisionFirstTime]");
	        ss.addDisplayColumn ("notifiedByEmailLastTime        as [thisRecipNotifiedWSentRevisionLastTime]");
	        ss.addDisplayColumn ("notifiedByEmailNumTimes        as [thisRecipNotifiedWSentRevisionNumTimes]");
	
	        ss.addDisplayColumn ("mustResend           as [Will Re-send Curr Revision?]");
	
	        //ss.addDisplayColumn ("rowOrder",true);
	
	        //pageroworder = ss.pageRowOrder();
	
	        pageroworder = "id DESC, sentRevisionNum DESC, v_cliID ASC, email ASC";
	
	      };
	
	      return Entities.viewTbl(connUsers, log, uInfo, paged, pageNumber,
	        delegate{return NewsletterPages.viewRecipListReportAll(connUsers,log,uInfo, appName, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, recid, active, dc);}
	        , @"Newsletters - All Recipients Sent And Pending"
	        , Messages.CONFIDENTIAL
	        );
       }


      /***************************************************************************
       * viewManPageContentUserResponsePendingMultiMediaEmailNotificationList */
      /**
       * runs database JOIN logic that finds newsletter records (without the message bodies)
       * along with 1 individual recipient name and email address, per-row.
       * Also includes the is_last_iter_per_batch flag, which triggers important UPDATE logic
       * called from the batch mailer.

       * param                     appName string
       * @return                   List<NewsletterPageContentUserResponsePendingEmailNotification>
	
       ***************************************************************************/ 
       public static List<NewsletterPageContentUserResponsePendingEmailNotification> viewManPageContentUserResponsePendingMultiMediaEmailNotificationList (
												       SqlConnection connApp
												     , DetailsLog    log
												     , UserInfo      uInfo
												     , string        appName )

       {

	     List<NewsletterPageContentUserResponsePendingEmailNotification> Notifications = new List<NewsletterPageContentUserResponsePendingEmailNotification>();
	     List<SqlParameter>                                       parms         = new List<SqlParameter>();
	
	     string  sql     = "select * from dbo.NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL (@userID, @userGroup, @userRank, null, @appName)";
	     Object vAppName = Validate.optString (appName, Messages.NO_APP_NAME);
	
	     parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
	     parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
	     parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
	     parms.Add(Database.SqlParm("@appName",    SqlDbType.VarChar,  vAppName,         ParameterDirection.Input, 50));
	
	     ReturnDB rd = Database.execQuery (  connApp
	                                       , log
	                                       , sql
	                                       , false
	                                       , parms
	                                      );
	
	      List<Object> slo = Database.convertRecordsToList (   ref rd.records
	                                                         , typeof(NewsletterPageContentUserResponsePendingEmailNotification)
	                                                       );
	
	      foreach (Object o in slo) {
	        Notifications.Add ( (NewsletterPageContentUserResponsePendingEmailNotification) o) ;
	      }
	
	      return Notifications;

       }

      /***************************************************************************
       * getStringContentMultiMediaEmailNotification */
      /**
       * returns the body of a newsletter as a string.  Called iteratively from the batch mailer task.

       * param                     appName string
       * @return                   string
	
       ***************************************************************************/ 
       public static string getStringContentMultiMediaEmailNotification (
												       SqlConnection connApp
												     , DetailsLog    log
												     //, UserInfo      uInfo
												     , string        recid
												     , string        appName )

       {

		     List<NewsletterPageContentUserResponsePendingEmailNotification> Notifications = new List<NewsletterPageContentUserResponsePendingEmailNotification>();
		     List<SqlParameter>                                       parms         = new List<SqlParameter>();
		
		     string  sql     = "select * from " +
		                "dbo.NEWSLETTER_PAGES_DATA_CORE" +
		                "(@appName, null, null, 1, null, null, null, null, @recID)";
		     Object vAppName = Validate.optString (appName, Messages.NO_APP_NAME);
		     Object vrecid   = Validate.reqInteger(recid, Messages.INVALID_RECORD_ID);
		
		     //parms.Add(Database.SqlParm("@userID",     SqlDbType.BigInt,   uInfo.userid,     ParameterDirection.Input));
		     //parms.Add(Database.SqlParm("@userGroup",  SqlDbType.Int,      uInfo.userGroup,  ParameterDirection.Input));
		     //parms.Add(Database.SqlParm("@userRank",   SqlDbType.Int,      uInfo.userRank,   ParameterDirection.Input));
		
		     parms.Add(Database.SqlParm("@appName",    SqlDbType.VarChar,  vAppName,         ParameterDirection.Input, 50));
		     parms.Add(Database.SqlParm("@recID",      SqlDbType.BigInt,   vrecid,         ParameterDirection.Input, 50));
		
		     ReturnDB rd = Database.execQuery (  connApp
		                                       , log
		                                       , sql
		                                       , false
		                                       , parms
		                                      );
		
		      NewsletterPage mmon = (NewsletterPage) Database.convertRecord(rd.records, typeof(NewsletterPage));
		      return mmon.content ;

       }


      /***************************************************************************
       * load */
      /**
       * called the view() method and returns exactly one record as a NewsletterPage object.

       * param                     appName string
       * @return                   NewsletterPage
	
       ***************************************************************************/ 
       public static NewsletterPage load(SqlConnection connApp, DetailsLog log, UserInfo uInfo, string appName, string recID)
       {

	        return (NewsletterPage)Entities.load(connApp, log, uInfo, recID, typeof(NewsletterPage),
	        delegate
	        {
	            return NewsletterPages.view(connApp, log, uInfo, appName, Entities.REC_VIEW_LOAD, null, false, recID, null, null, null, "1", "1");
	        });

       }


      /***************************************************************************
       * load */
      /**
       * called the view() method and returns exactly one record as a NewsletterPage object.
       *  appName string autofilled from app constants.

       * @return                   NewsletterPage
	
       ***************************************************************************/
       public static NewsletterPage load (SqlConnection connApp, DetailsLog log, UserInfo uInfo, string recID)
       { 
           return NewsletterPages.load(connApp, log, uInfo, Constants.APP_NAME, recID);
       }

 
      /***************************************************************************
       * resetAndRepublish */
      /**
       * updates the relevant flags on the Newsletter record to cause it to be re-sent
       * to all recipients
       	
       * @return                   ReturnSaveRecord
	
       ***************************************************************************/ 

       public static ReturnSaveRecord resetAndRepublish (   SqlConnection connApp , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        recID )
       {

	        string vAppName = Constants.APP_NAME;
	
	        var opSproc = "NEWSLETTER_PAGES_RESET_AND_REPUBLISH";
	        var parms = new List<SqlParameter>();
	        parms.Add(Database.SqlParm("@appName", SqlDbType.VarChar, vAppName, ParameterDirection.Input, 50));
	        return Entities.recordOp(connApp, log, uInfo, "", "0", recID, opSproc, ref parms);

       }


       /***************************************************************************
         * viewObjects */
       /**
         * Returns a database result set of newsletter records for REST handlers
         * @return                   ReturnObjects
	
       ***************************************************************************/ 
       public static ReturnObjects viewObjects(SqlConnection connSpedmon
                                                   , DetailsLog log
                                                   , UserInfo uInfo
                                                   , bool pageObjectList
                                                   , string pageOrder
                                                   , string idx
                                                   , string active
                                                   , string term
                                                   , string includeContent)
       {
            /* Default page order */

            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = NewsletterPage.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            var rd = Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(NewsletterPage)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate {
                                              return NewsletterPages.view
                                                                                  ( connSpedmon
                                                                                   , log
                                                                                   , uInfo
                                                                                   , Constants.APP_NAME
                                                                                   , Entities.REC_VIEW_OBJECTS
                                                                                   , dc
                                                                                   , pageObjectList
                                                                                   , idx
                                                                                   , null
                                                                                   , "Y" /* Active */
                                                                                   , term
                                                                                   );                                             
                                          });

            return rd;
       }



      /***************************************************************************
       * returnContentSelection */
      /**
       * Calls the load() method; returns the value in a ReturnNewsletterPage
       * suitable to populate a iframe page response
       	
       * @return                   ReturnNewsletterPage
	
       ***************************************************************************/ 

       public static ReturnNewsletterPage returnContentSelection(SqlConnection connApp
                                                               , DetailsLog log
                                                               , UserInfo uInfo
                                                               //, string appName
                                                               , string recID)
       {
            ReturnNewsletterPage rd = new ReturnNewsletterPage();
            rd.multimediaPage = Spedmon.NewsletterPages.load(
                connApp, log, uInfo, recID);

            //logUserResponse(connUsers, log, uInfo, appName, USER_RESP_TYPE_SEEN, recID);

            return rd;
       }


      /***************************************************************************
       * viewSel */
      /**
       * Calls viewCombinedSearch() and returns a database result set of one or many Newsletter records
       * for populating a dropdown selection
	
       * @return                   ReturnSel
	
       ***************************************************************************/ 
       public static ReturnSel viewSel(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string term )
       {


	        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
	        {
	            ss.addDisplayColumn("[contentFrom] as recData1");
                ss.addDisplayColumn("[navToURL] as recData2");
                ss.addDisplayColumn("convert(varchar(256),[id]) as recData3");
                ss.addDisplayColumn("[tooltip]  as context1");
            };
	
	        return Entities.viewSel(connSpedmon, log, uInfo, false /* top */, "" /* topSize */,
	        delegate {
	            return NewsletterPages.viewCombinedSearch(connSpedmon
	                                    , log
	                                    , uInfo
	                                    , Constants.APP_NAME
	                                    , Entities.REC_VIEW_SEL
	                                    , true
	                                    , ""
	                                    , term
	                                    , dc);
	        });

       }


    }
}