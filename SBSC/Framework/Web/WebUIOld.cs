using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;
using MBA;

namespace Spedmon
{

 /***************************************************************************
  * WebUI */
 /**
  * Base class for all web user interface (UI) pages.  This class generates a
  * standard framework of HTML markup, CSS includes, and Javascript includes
  * for every page that inherits from it.  It also renders any content that
  * the subclasses provide.  This provides a uniform "look and feel" for
  * all UI pages. 
  *
  * @param bodyid         The id you wish to give to the body tag.  If none is
  * @param subtitle       The subtitle you wish to give to the page.  The page 
  *                       title will be Application Name - Subtitle
  * @param css            Additional external css files
  * @param js             Additional external js files
  * @param permittedRoles User roles that are allowed to access the page
   *
  ****************************************************************************/
  
  public class WebUI: MBA.WebUI
  {                 
        
    /*===============================
     * Delegates
     *===============================*/ 

   /*-------------------------------
     * App bar icons public
     *
     *------------------------------*/ 

    static handleAppSpecificResponse rAppBarIconsPublic= new handleAppSpecificResponse ( delegate ( HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {
                            
    });
    
    /*-------------------------------
     * App bar icons private
     *
     *------------------------------*/ 

    static handleAppSpecificResponse rAppBarIconsPrivate= new handleAppSpecificResponse ( delegate ( HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {
                            
    });

    
    /*-------------------------------
     * Public menu
     *------------------------------*/ 

    static renderMenuPublic rmenuPublic  = new renderMenuPublic(delegate(ref HtmlTextWriter writer){
    

      writer.Write(@"<li class=""menu-item-common""><a href=""" + Constants.REQUEST_ACCOUNT            + @""">Request Account</a></li>");
      writer.Write(@"<li class=""menu-item-common""><a href=""" + Constants.FORGOT_MY_PASSWORD         + @""">Forgot My Password</a></li>");      
      writer.Write(@"<li class=""menu-item-common""><a href=""" + Messages.CONTACT_US_LINK             + @""">Contact Us</a></li>");
      writer.Write(@"<li class=""menu-item-common""><a href=""" + Messages.ABOUT_US_LINK               + @""">About Us</a></li>");
      writer.Write(@"<li class=""menu-item-common""><a href=""" + Constants.REQUEST_FILE_UPLOAD_PUBLIC + @""">Send Us A File</a></li>");

      return;
    });

    /*-------------------------------
     * Private menu
     *------------------------------*/ 

    static renderMenuPrivate rmenuPrivate = new renderMenuPrivate(delegate(ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer){
      
      
      string roleNameLower = rd.wu.usr.roleName.ToLower();
       
      switch (roleNameLower)
      {


        /*********************************************************************************************
         *                          Third Party Person - ORP Professional 
         *********************************************************************************************/ 

        case Constants.ROLE_ORP_PROFFESIONAL:
        {
          break;
        }

        /*********************************************************************************************
         *                                   Client Role - Practitioner
         *********************************************************************************************/ 
          
         case Constants.ROLE_LEA_PROVIDER:
         {      
           
             if (ServiceJournals.isPracSomeoneWhoCanManagePatientServices(ref rd))
             {
            
               /*------------------------ 
                * Manage Patient Services 
                *------------------------*/

               renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES); 

               /*------------------------ 
                * Approve Svc Recs
                *------------------------*/

               if (ServiceRecordsApproval.isSupervisorPrac(ref rd))
               {
                 writer.Write(@"<li><a id=""supervisesvcreclink"" href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_CLIENT_PROV_SVC_REC_APPROVAL_SUMMARY, true) + @""">" + ServiceRecordsApproval.SEL_LABEL_PRAC_SUPERVISOR_REV_SVC + @"</a></li>");
               }


               /**** Patient Profiles ****/
               
               if (ServiceJournals.isPracSomeoneWhoCanManageSvcDescr(ref rd))
               {  
                 renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_PROV_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);
                 
                 /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

                 renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                 renderMenuListItem(ref writer, @"managesvcdescrlink",  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_PROV_SAVE_SERVICE_DESCRIPTION, true, true);
                 renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE,     ServiceJournals.URL_PROV_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                 renderMenuListItem(ref writer, @"viewsvcdescrlink",    ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW,            ServiceJournals.URL_PROV_SERVICE_DESCRIPTIONS_VIEW, true, true);
                 renderSubMenuListEnd(ref writer);
               }
               
               /**** Orders ****/

               if (ServiceJournals.isPracSomeoneWhoCanManageOrders(ref rd))
               {
                 renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);                   
 
                 /**** Old Orders Menu -- Render hidden to preserve compatability ****/
              
                 renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                 renderMenuListItem(ref writer, @"manageordersnewlink",        ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW,         ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                 renderMenuListItem(ref writer, @"manageordersviewlink",       ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW,        ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);                
                 renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_PROV_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                 renderSubMenuListEnd(ref writer);
  
               }
               
               /**** Request Name ****/

               writer.Write(  @"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                          , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                          , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                          , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);

               renderTopMenuListEnd(ref writer);

             }                      
                      
           if (ServiceJournals.isPracSomeoneWhoCanRecordServiceRecords(ref rd)) 
           {
    
             /*------------------------ 
              * Service Records 
              * Complete Menu
              *------------------------*/

             renderTopMenuListStart(ref writer, @"Service Records");  
             writer.Write(@"<li><a id=""addnewsvcreclink""   href=""" + Spedmon.ServiceRecordEntryExitRequest.GenerateUrlClientProvEnter(0) + @""">Record New</a></li>");
             writer.Write(@"<li><a id=""batchnewsvcreclink"" href=""" + Spedmon.ServiceRecordEntryExitRequest.GenerateUrlClientProvEnter(1) + @""">Record Multiple New</a></li>");
             writer.Write(@"<li><a id=""caseloadandgroupsvcrec"" href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_caseload_or_group_save.aspx", true) + @""">Record Services for My Caseload or Patient Groups</a></li>");
             writer.Write(@"<li><a id=""viewsvcrecslink""    href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_view.aspx",        true) + @""">View</a></li>");
             writer.Write(@"<li><a id=""editdelsvcrecslink"" href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
             writer.Write(@"<li><a id=""viewsvcsrendcomponepat"" href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_CLIENT_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");
             writer.Write(@"<li><a id=""svcnotepreflink""    href=""" + Spedmon.ServiceNotesPreferenceRequest.GenerateUrlClientProv(ServiceNoteCommon.NoteRequestMode.LOAD) + @""">Where Do I Keep My Progress Notes</a></li>");           
             writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_svcnote_view.aspx", true) + @""">View My Progress Notes I Have Saved in SpEdCare</a></li>");
             // TODO: Uncomment when we are read to support practitioner trans
             //writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_CLIENT_PROV_PROCESS_INCOMING_SHEET,  true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
             renderTopMenuListEnd(ref writer);
           }
           
          
           else
           {
    
             /*------------------------ 
               * Service Records 
               * Views Only
               *------------------------*/
    
             renderTopMenuListStart(ref writer, @"Service Records");
             writer.Write(@"<li><a id=""viewsvcrecslink""    href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_view.aspx",        true) + @""">View</a></li>");
             writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_prov_svcrec_svcnote_view.aspx", true) + @""">View My Progress Notes I Have Saved in SpEdCare</a></li>");
             renderTopMenuListEnd(ref writer);           
    
           }
           
           
           if (ServiceRecordsApproval.doesPracHavePracsAssignedToSuperviseDirectly (ref rd)) 
           {

            /*------------------------ 
             * Direct Supervision
             * Review
             *------------------------*/

             writer.Write(@"<li><a id=""directsupsvcrevlink"" href=""" 
                        + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_RPT_CLIENT_PROV_SVC_REC_REVIEW_FOR_DIRECT_SUP, true) + @""">" 
                        + ServiceRecordsApproval.SEL_LABEL_RPT_SVC_REC_REVIEW_FOR_DIRECT_SUP 
                        + @"</a></li>");

           }
           
                      
           if (ServiceJournals.isPracSomeoneWhoWouldUseJournal(ref rd))
           {

             /*------------------------ 
              * Service Journals
              *------------------------*/

             renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL );             
             writer.Write(@"<li><a id=""svcjournalrecordproclink""   href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_REC_PROC))      + @""">" + ServiceJournals.SEL_LABEL_RECORD_PROC  + @"</a></li>");
             writer.Write(@"<li><a id=""svcjournalrecordtranslink""  href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_REC_TRAN_AIDE)) + @""">" + ServiceJournals.SEL_LABEL_RECORD_TRANS + @"</a></li>");
             writer.Write(@"<li><a id=""svcjournalbeginam""          href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_BEGIN_AM))      + @""">" + ServiceJournals.SEL_LABEL_BEGIN_AM     + @"</a></li>");
             writer.Write(@"<li><a id=""svcjournalendam""            href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_QUICK_SELECT_OPEN_JOURNAL, true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_END_AM))        + @""">" + ServiceJournals.SEL_LABEL_END_AM       + @"</a></li>");
             writer.Write(@"<li><a id=""svcjournalrecordleftcarelink""  href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_LEFT_CARE))     + @""">"  + ServiceJournals.SEL_LABEL_LEFT_CARE    + @"</a></li>");
             writer.Write(@"<li><a id=""svcjournalrecorddailylivinglink""  href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_DAILY_LIVING))     + @""">"  + ServiceJournals.SEL_LABEL_DAILY_LIVING    + @"</a></li>");
             writer.Write(@"<li><a id=""svcjournalrecordmonmultipatslink""  href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_MON_MULTI_PATS))     + @""">"  + ServiceJournals.SEL_LABEL_MON_MULTI_PATS    + @"</a></li>");
             writer.Write(@"<li><a id=""svcjournalrecordaddionalnoteslink""  href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_ADDITIONAL_NOTES))     + @""">"  + ServiceJournals.SEL_LABEL_ADDITIONAL_NOTES    + @"</a></li>"); 
             writer.Write(@"<li><a id=""svcjournalrecordtcmlink""  href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_OPEN_NEW,             true, new NameValue(ServiceJournals.PARAM_EVENT_TYPE_ID, ServiceJournals.VAL_EVENT_TYPE_TCM))     + @""">"  + ServiceJournals.SEL_LABEL_TCM    + @"</a></li>");                          
             writer.Write(@"<li><a id=""workwithopenjournallink""    href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_WORK_WITH_OPEN,       true) + @""">" + ServiceJournals.SEL_LABEL_WORK_WITH_OPEN   + @"</a></li>");
             writer.Write(@"<li><a id=""workwithclosedjournallink""  href=""" + MBA.HttpApplication.createLink(ServiceJournals.URL_PROV_WORK_WITH_CLOSED,     true) + @""">" + ServiceJournals.SEL_LABEL_WORK_WITH_CLOSED + @"</a></li>");
             renderTopMenuListEnd(ref writer);
           }
           

           if (ServiceJournals.isPracSomeoneWhoCanRecordServiceRecords(ref rd)) 
           {
                      
             /*------------------------ 
              * Patients
              *------------------------*/

             renderTopMenuListStart(ref writer, @"Patients");             
             writer.Write(@"<li><a id=""addnewpatlink""       href=""" +  MBA.HttpApplication.createLink("client_all_pat_save.aspx",true) + @""">Record New</a></li>");
             writer.Write(@"<li><a id=""editdelpatrecslink""  href=""" +  MBA.HttpApplication.createLink("client_all_pat_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
             renderTopMenuListEnd(ref writer);
                        
             /*------------------------ 
              * Caseloads
              *------------------------*/
             
             renderTopMenuListStart(ref writer, @"Caseload & Groups");
             writer.Write(@"<li><a id=""caseloadandgroupmgmt""   href=""" + MBA.HttpApplication.createLink("client_prov_caseload_and_patient_group_mgmt.aspx", true) + @""">Manage My Caseload and Patient Groups</a></li>");
             renderTopMenuListEnd(ref writer);

             /*------------------------ 
              * Plan Writer
              *------------------------*/
             
             renderTopMenuListStart(ref writer,  PlanWriterRecords.SEL_LABEL); 
             writer.Write(@"<li><a id=""planwritemanageplanslink"" href=""" + MBA.HttpApplication.createLink (PlanWriterRecords.URL_USER_ALL_MANAGE_PLANS, true) + @""">"  + PlanWriterRecords.SEL_LABEL_MANAGE + @"</a></li>");
             renderTopMenuListEnd(ref writer);                                                         
           }
                      
           break;
           
         }

         /*********************************************************************************************
          *                                  Client Role - File Manager
          *        Note: This role can only upload and view files so that is why there are no items
          *********************************************************************************************/ 
           
         case Constants.ROLE_LEA_FILE_MANAGER:
         {
           break;
         }

         /*********************************************************************************************
          *                                  Client Role - LEA Input Staff 
          *********************************************************************************************/ 

         case Constants.ROLE_LEA_INPUT_STAFF:
         {

           /*------------------------ 
            * Service Records              
            *------------------------*/

           renderTopMenuListStart(ref writer, @"Service Records");   
           writer.Write(@"<li><a id=""addnewsvcreclink""     href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_save.aspx",        true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""batchnewsvcreclink""   href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_batch_save.aspx",  true) + @""">Record Multiple New</a></li>");
           writer.Write(@"<li><a id=""caseloadandgroupsvcreclink""       href=""" + MBA.HttpApplication.createLink(ServiceRecords.URL_CLIENT_COOR_SVCREC_CSLD_OR_GRP_SEL_PRAC, true)   + @""">" + ServiceRecords.SEL_LABEL_SVREC_NON_PRAC + @"</a></li>");
           writer.Write(@"<li><a id=""viewsvcrecslink""      href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_view.aspx",        true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
           writer.Write(@"<li><a id=""editdelsvcrecslink""   href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);
             
           /*------------------------ 
            * Practitioners
            *------------------------*/
                            
           renderTopMenuListStart(ref writer, @"Practitioners");              
           writer.Write(@"<li><a id=""addnewpraclink""        href=""" + MBA.HttpApplication.createLink("client_coor_prac_save.aspx", true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewpraclink""           href=""" +  MBA.HttpApplication.createLink("client_coor_prac_view.aspx",true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdelpracrecslink""   href=""" + MBA.HttpApplication.createLink("client_coor_prac_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);

           /*------------------------ 
            * Patients
            *------------------------*/
                                          
           renderTopMenuListStart(ref writer, @"Patients");
           writer.Write(@"<li><a id=""addnewpatlink""          href=""" +  MBA.HttpApplication.createLink("client_all_pat_save.aspx",true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewpatlink""           href=""" + MBA.HttpApplication.createLink("client_coor_pat_view.aspx", true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdelpatrecslink""     href=""" +  MBA.HttpApplication.createLink("client_all_pat_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");                  
           renderTopMenuListEnd(ref writer);           
           
           /*------------------------ 
            * Caseloads
            *------------------------*/
             
           writer.Write(@"<li><a id=""caseloadandgroupmgmtlink""   href=""" + MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_CLIENT_COOR_CSLD_PT_GRP_MGMT_SEL_PRAC, true) + @""">" + PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC + @"</a></li>");
                          
           /*------------------------ 
            * Transportation
            *------------------------*/
             
           renderTopMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
           writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
           writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_CLIENT_COOR_PROCESS_INCOMING_SHEET,  true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
           writer.Write(@"<li><a id=""manageheldtranslink""            href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_SERVICE_RECORDS,     true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE_SERVICE_RECORDS + @"</a></li>");
           renderTopMenuListEnd(ref writer);           


           /*------------------------ 
            * Manage Patient Services 
            *------------------------*/
            
           renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);
                        
           /**** Patient Profiles ****/
              
           renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_COOR_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

           /**** Orders ****/

           renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);    
          
           /**** Request Name ****/

           writer.Write(  @"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                          , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                          , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                          , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);
                            
           /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

           renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
           renderMenuListItem(ref writer, @"managesvcdescrlink",  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_COOR_SAVE_SERVICE_DESCRIPTION, true, true);
           renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE,     ServiceJournals.URL_COOR_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
           renderMenuListItem(ref writer, @"viewsvcdescrlink",    ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW,            ServiceJournals.URL_COOR_SERVICE_DESCRIPTIONS_VIEW, true, true);
           renderSubMenuListEnd(ref writer);

           /**** Old Orders Menu -- Render hidden to preserve compatability ****/
              
           renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
           renderMenuListItem(ref writer, @"manageordersnewlink",        ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW,         ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
           renderMenuListItem(ref writer, @"manageordersviewlink",       ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW,        ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);                
           renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
           renderSubMenuListEnd(ref writer);
  
           renderTopMenuListEnd(ref writer);           

           /*------------------------ 
            * Plan Writer
            *------------------------*/
             
           renderTopMenuListStart(ref writer,  PlanWriterRecords.SEL_LABEL);                                        
           writer.Write(@"<li><a id=""planwritemanageplanslink"" href=""" + MBA.HttpApplication.createLink (PlanWriterRecords.URL_CLIENT_COOR_SELECT_GROUP, true) + @""">"  + PlanWriterRecords.SEL_LABEL_MANAGE + @"</a></li>");
           renderTopMenuListEnd(ref writer);        
                                     
           /*------------------------ 
            * Sites
            *------------------------*/

           renderTopMenuListStart(ref writer, @"Sites");                          
           writer.Write(@"<li><a id=""addsitelink""           href=""" + MBA.HttpApplication.createLink("client_all_sites_save.aspx", true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewsitelink""          href=""" + MBA.HttpApplication.createLink("client_all_sites_view.aspx", true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdelsiteslink""      href=""" + MBA.HttpApplication.createLink("client_all_sites_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);

           /*------------------------ 
            * Users
            *------------------------*/
              
           renderTopMenuListStart(ref writer, @"Users");              
           writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("client_coor_user_save.aspx", true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("client_coor_user_view.aspx", true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("client_coor_user_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);
                                        
           /*------------------------ 
            * Reports
            *------------------------*/
              
           renderTopMenuListStart(ref writer, @"Reports");                                    
           writer.Write(@"<li><a id=""rptpracrevlink""         href=""" + MBA.HttpApplication.createLink("client_coor_rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
           renderTopMenuListEnd(ref writer);
             
           break;

             
             
         }
           
         /*********************************************************************************************
          *                                Client Role - LEA Coordinators 
          *********************************************************************************************/ 

         case Constants.ROLE_LEA_CORDINATOR:
         {

           /*------------------------ 
            * Service Records              
            *------------------------*/

           renderTopMenuListStart(ref writer, @"Service Records");   
           writer.Write(@"<li><a id=""addnewsvcreclink""     href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_save.aspx",        true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""batchnewsvcreclink""   href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_batch_save.aspx",  true) + @""">Record Multiple New</a></li>");
           writer.Write(@"<li><a id=""caseloadandgroupsvcreclink""       href=""" + MBA.HttpApplication.createLink(ServiceRecords.URL_CLIENT_COOR_SVCREC_CSLD_OR_GRP_SEL_PRAC, true)   + @""">" + ServiceRecords.SEL_LABEL_SVREC_NON_PRAC + @"</a></li>");
           writer.Write(@"<li><a id=""viewsvcrecslink""      href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_view.aspx",        true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("client_coor_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
           writer.Write(@"<li><a id=""editdelsvcrecslink""   href=""" +  MBA.HttpApplication.createLink("client_coor_svcrec_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);
             
           /*------------------------ 
            * Practitioners
            *------------------------*/
                            
           renderTopMenuListStart(ref writer, @"Practitioners");              
           writer.Write(@"<li><a id=""addnewpraclink""        href=""" + MBA.HttpApplication.createLink("client_coor_prac_save.aspx", true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewpraclink""           href=""" +  MBA.HttpApplication.createLink("client_coor_prac_view.aspx",true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdelpracrecslink""   href=""" + MBA.HttpApplication.createLink("client_coor_prac_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);

           /*------------------------ 
            * Patients
            *------------------------*/
                                          
           renderTopMenuListStart(ref writer, @"Patients");
           writer.Write(@"<li><a id=""addnewpatlink""          href=""" +  MBA.HttpApplication.createLink("client_all_pat_save.aspx",true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewpatlink""           href=""" + MBA.HttpApplication.createLink("client_coor_pat_view.aspx", true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdelpatrecslink""     href=""" +  MBA.HttpApplication.createLink("client_all_pat_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");                  
           renderTopMenuListEnd(ref writer);           
           
           /*------------------------ 
            * Caseloads
            *------------------------*/
             
           writer.Write(@"<li><a id=""caseloadandgroupmgmtlink""   href=""" + MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_CLIENT_COOR_CSLD_PT_GRP_MGMT_SEL_PRAC, true) + @""">" + PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC + @"</a></li>");
                          
           /*------------------------ 
            * Transportation
            *------------------------*/
             
           renderTopMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
           writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES, true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
           writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_CLIENT_COOR_PROCESS_INCOMING_SHEET,  true) + @""">" + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
           writer.Write(@"<li><a id=""manageheldtranslink""            href=""" + MBA.HttpApplication.createLink(TransportationMgmtRecords.URL_USER_ALL_MANAGE_SERVICE_RECORDS,     true) + @""">" + TransportationMgmtRecords.SEL_LABEL_MANAGE_SERVICE_RECORDS + @"</a></li>");
           renderTopMenuListEnd(ref writer);           

           /*------------------------ 
            * Manage Patient Services 
            *------------------------*/
            
           renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);
                        
           /**** Patient Profiles ****/
              
           renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_COOR_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

           /**** Orders ****/

           renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);    
          
           /**** Request Name ****/

           writer.Write(  @"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                          , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                          , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                          , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);
                            
           /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

           renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
           renderMenuListItem(ref writer, @"managesvcdescrlink",  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_COOR_SAVE_SERVICE_DESCRIPTION, true, true);
           renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE,     ServiceJournals.URL_COOR_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
           renderMenuListItem(ref writer, @"viewsvcdescrlink",    ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW,            ServiceJournals.URL_COOR_SERVICE_DESCRIPTIONS_VIEW, true, true);
           renderSubMenuListEnd(ref writer);

           /**** Old Orders Menu -- Render hidden to preserve compatability ****/
              
           renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
           renderMenuListItem(ref writer, @"manageordersnewlink",        ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW,         ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
           renderMenuListItem(ref writer, @"manageordersviewlink",       ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW,        ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);                
           renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_COOR_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
           renderSubMenuListEnd(ref writer);
  
           renderTopMenuListEnd(ref writer);           

           /*------------------------ 
            * Plan Writer
            *------------------------*/
             
           renderTopMenuListStart(ref writer,  PlanWriterRecords.SEL_LABEL);                                        
           writer.Write(@"<li><a id=""planwritemanageplanslink"" href=""" + MBA.HttpApplication.createLink (PlanWriterRecords.URL_CLIENT_COOR_SELECT_GROUP, true) + @""">"  + PlanWriterRecords.SEL_LABEL_MANAGE + @"</a></li>");
           renderTopMenuListEnd(ref writer);        
                                     
           /*------------------------ 
            * Sites
            *------------------------*/

           renderTopMenuListStart(ref writer, @"Sites");                          
           writer.Write(@"<li><a id=""addsitelink""           href=""" + MBA.HttpApplication.createLink("client_all_sites_save.aspx", true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewsitelink""          href=""" + MBA.HttpApplication.createLink("client_all_sites_view.aspx", true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdelsiteslink""      href=""" + MBA.HttpApplication.createLink("client_all_sites_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);

           /*------------------------ 
            * Users
            *------------------------*/
              
           renderTopMenuListStart(ref writer, @"Users");              
           writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("client_coor_user_save.aspx", true) + @""">Record New</a></li>");
           writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("client_coor_user_view.aspx", true) + @""">View</a></li>");
           writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("client_coor_user_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
           renderTopMenuListEnd(ref writer);
                                        
           /*------------------------ 
            * Reports
            *------------------------*/
              
           renderTopMenuListStart(ref writer, @"Reports");                                    
           writer.Write(@"<li><a id=""rptclmpaidbycheckdate""  href=""" + MBA.HttpApplication.createLink("client_all_rpt_claims_paid.aspx",true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
           writer.Write(@"<li><a id=""rptclmpaidbyservicedate""         href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_by_dos.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
           writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""   href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
           writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared"" href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
           writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""        href=""" + MBA.HttpApplication.createLink("client_coor_rpt_combined_1on1_by_svc_date.aspx", true) + @""">By Patient for One Practitioner by Service Date</a></li>");
           writer.Write(@"<li><a id=""viewtattlelink""         href=""" + MBA.HttpApplication.createLink(Practitioners.URL_LEA_COORD_RPT_TATTLETALE, true) + @""">Tattle Tale</a></li>");
           writer.Write(@"<li><a id=""rptpracrevlink""         href=""" + MBA.HttpApplication.createLink("client_coor_rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
           writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""        href=""" + MBA.HttpApplication.createLink("client_coor_rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
           writer.Write(@"<li><a id=""rptbyeligpatdos2p""               href=""" + MBA.HttpApplication.createLink("client_coor_rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");
           //writer.Write(@"<li><a id=""rptfilesuploaded""       href=""" + MBA.HttpApplication.createLink("client_all_rpt_file_uploads_view.aspx", true)   + @""">Files Uploaded to SpEdCare</a></li>");
           writer.Write(@"<li><a id=""viewsvcsrendcomponepat"" href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_CLIENT_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");
           renderTopMenuListEnd(ref writer);

           /*------------------------ 
            * Report Distribution
            *------------------------*/
              
           renderTopMenuListStart(ref writer,  Publications.SEL_LABEL);

           /**** Subscribers ****/
              
           renderSubMenuListStart(ref writer,  Subscribers.SEL_LABEL);              
           writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("client_coor_subscriber_save.aspx", true) + @""">" + Subscribers.SEL_LABEL_ADD + @"</a></li>");
           writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("client_coor_subscribers_view.aspx", true) + @""">" + Subscribers.SEL_LABEL_VIEW + @"</a></li>");
           writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("client_coor_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
           renderSubMenuListEnd(ref writer);
           
           /**** Subscriptions *****/
               
           renderSubMenuListStart(ref writer,  Subscriptions.SEL_LABEL);                          
           writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("client_coor_subscription_save.aspx", true) + @""">" + Subscriptions.SEL_LABEL_ADD + @"</a></li>");
           writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("client_coor_subscriptions_view.aspx", true) + @""">" + Subscriptions.SEL_LABEL_VIEW + @"</a></li>");
           writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("client_coor_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
           renderSubMenuListEnd(ref writer);               
           
           renderTopMenuListEnd(ref writer);
           
           break;
         }
                   
           /*********************************************************************************************
            *                                Practi-Cal Role - Input Staff
            *********************************************************************************************/ 
           
            case Constants.ROLE_INPUT_STAFF:
            {

             /*------------------------ 
               * Service Records              
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Service Records");  
              writer.Write(@"<li><a id=""addnewsvcreclink""    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""batchnewsvcreclink""                    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save.aspx",true) + @""">Record Multiple New</a></li>");
              //writer.Write(@"<li><a id=""batchnewsvcreconeononelink""          href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_one_on_one_save.aspx",true) + @""">Record Multiple New 1:1</a></li>");
              writer.Write(@"<li><a id=""batchnewsvcrecmultiencountlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save_multi_encounter.aspx",true) + @""">Record Multiple New - Multiple Encounters</a></li>");
              writer.Write(@"<li><a id=""viewsvcrecslink""                       href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelsvcrecslink""                    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_edit_delete.aspx",true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""batcheditdelsvcrecslink""               href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_edit_delete.aspx",true) + @""">Batch Delete</a></li>");
              writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""               href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
              writer.Write(@"<li><a id=""processincomingroutesheetslink""        href=""" + MBA.HttpApplication.createLink (TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET  , true) + @""">"  + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
              renderMenuListItem(ref writer,@"svcrecorpdocasclink",  @"Associate ORP Documents",  @"sbs_all_orp_doc_svc_rec_asc.aspx");
              renderTopMenuListEnd(ref writer);

             /*------------------------ 
               * Clients
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Clients");
              writer.Write(@"<li><a id=""viewclientlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_client_view.aspx", true) + @""">View</a></li>");
              renderTopMenuListEnd(ref writer);
             
              /*------------------------ 
               * Practitioners
               *------------------------*/
                            
              renderTopMenuListStart(ref writer, @"Practitioners");              
              writer.Write(@"<li><a id=""addnewpraclink""        href=""" + MBA.HttpApplication.createLink("sbs_all_prac_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpraclink""          href=""" + MBA.HttpApplication.createLink("sbs_all_prac_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpracrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_prac_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Patients
               *------------------------*/
                                          
              renderTopMenuListStart(ref writer, @"Patients");
              writer.Write(@"<li><a id=""addnewpatlink""         href=""" + MBA.HttpApplication.createLink("sbs_all_pat_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpatlink""           href=""" + MBA.HttpApplication.createLink("sbs_all_pat_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpatrecslink""    href=""" + MBA.HttpApplication.createLink("sbs_all_pat_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx",  true) + @""">Merge Data</a></li>");
              renderTopMenuListEnd(ref writer);
 
              /*------------------------ 
               * Manage Patient Services 
               *------------------------*/
            
              renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);
              
              /**** Patient Profiles ****/
              
              renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

              /**** Orders ****/

              renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
    
              /**** Recurring Services ****/
               
              renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
              renderSubMenuListEnd(ref writer);
         
              /**** Request Name ****/

              writer.Write(  @"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                            , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                            , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                            , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);
                            
              /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                renderMenuListItem(ref writer, @"managesvcdescrlink",  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE,     ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"viewsvcdescrlink",    ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW,            ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
              renderSubMenuListEnd(ref writer);

              /* Old Orders Menu -- Render hidden to preserve compatability*/
              
              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                renderMenuListItem(ref writer, @"manageordersnewlink",        ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW,         ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                renderMenuListItem(ref writer, @"manageordersviewlink",       ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW,        ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);                
              renderSubMenuListEnd(ref writer);
              
              renderTopMenuListEnd(ref writer);
                                                        
              /*------------------------ 
               * Reports
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Reports");              
              writer.Write(@"<li><a id=""rptclmpaidbycheckdate""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx",true)                                                    + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""            href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true)                                          + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbyservicedate""                  href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true)                                            + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared""          href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true)                                   + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
              writer.Write(@"<li><a id=""rptcountofbatchesinprocessbystatus""       href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS + @"</a></li>");
              writer.Write(@"<li><a id=""rptcountbatchesreadytoassignbytypeofwork"" href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK + @"</a></li>");
              writer.Write(@"<li><a id=""rptbatchesneedingpriorityreview""          href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW, true)               + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW + @"</a></li>");
              writer.Write(@"<li><a id=""rptbatchesabt2ageout""                     href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_ABOUT_TO_AGE_OUT, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT + @"</a></li>");
              writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""                 href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true)                                     + @""">By Patient for One Practitioner by Service Date</a></li>");
              //writer.Write(@"<li><a id=""viewtattlelink""                         href=""" + MBA.HttpApplication.createLink("rpt_svcrec_tattle.aspx",true)                                                  + @""">Tattle Tale</a></li>");
              writer.Write(@"<li><a id=""rptpracrevlink""                           href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true)                                                   + @""">Practitioner Review</a></li>");
              //writer.Write(@"<li><a id=""rptrecentanifiles""                      href=""" + MBA.HttpApplication.createLink("rpt_recent_ani_files.aspx", true)                                              + @""">" + Workflow.RPT_NAME_RECENT_ANI + @"</a></li>");              
              writer.Write(@"<li><a id=""rptfilesuploaded""                         href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true)                                             + @""">Files Uploaded to SpEdCare</a></li>");
              renderTopMenuListEnd(ref writer);
              
              /*------------------------ 
               * Production
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Production");
              writer.Write(@"<li><a id=""traininglink"" href=""" + MBA.HttpApplication.createLink("sbs_all_training.aspx", true) + @""" target=""_blank"">Production Documents</a></li>");
              renderTopMenuListEnd(ref writer);
              
              break;
            }
             
           /*********************************************************************************************
            *                                Practi-Cal Role - Work Leaders
            *********************************************************************************************/ 

            case Constants.ROLE_WORK_LEADER:
            {

             /*------------------------ 
               * Service Records              
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Service Records");  
              writer.Write(@"<li><a id=""addnewsvcreclink""    href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""batchnewsvcreclink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save.aspx",true) + @""">Record Multiple New</a></li>");
              //writer.Write(@"<li><a id=""batchnewsvcreconeononelink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_one_on_one_save.aspx",true) + @""">Record Multiple New 1:1</a></li>");
              writer.Write(@"<li><a id=""batchnewsvcrecmultiencountlink"" href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save_multi_encounter.aspx",true) + @""">Record Multiple New - Multiple Encounters</a></li>");
              writer.Write(@"<li><a id=""viewsvcrecslink""     href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_edit_delete.aspx",true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""batcheditdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_edit_delete.aspx",true) + @""">Batch Delete</a></li>");
              writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
              writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink (TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET  , true) + @""">"  + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
              renderMenuListItem(ref writer,@"svcrecorpdocasclink",  @"Associate ORP Documents",  @"sbs_all_orp_doc_svc_rec_asc.aspx");
              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Clients
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Clients");
              writer.Write(@"<li><a id=""editdelclientrecslink"" href=""" + MBA.HttpApplication.createLink("sbs_mgmt_client_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""viewclientlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_client_view.aspx", true) + @""">View</a></li>");
              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Practitioners
               *------------------------*/
                            
              renderTopMenuListStart(ref writer, @"Practitioners");              
              writer.Write(@"<li><a id=""addnewpraclink""        href=""" + MBA.HttpApplication.createLink("sbs_all_prac_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpraclink""          href=""" + MBA.HttpApplication.createLink("sbs_all_prac_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpracrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_prac_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);

             /*------------------------ 
               * Patients
               *------------------------*/
                                          
              renderTopMenuListStart(ref writer, @"Patients");
              writer.Write(@"<li><a id=""addnewpatlink""         href=""" + MBA.HttpApplication.createLink("sbs_all_pat_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpatlink""           href=""" + MBA.HttpApplication.createLink("sbs_all_pat_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpatrecslink""    href=""" + MBA.HttpApplication.createLink("sbs_all_pat_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx",  true) + @""">Merge Data</a></li>");
              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Manage Patient Services 
               *------------------------*/
            
              renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);
              
              /**** Patient Profiles ****/
              
              renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

              /**** Orders ****/

              renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
    
              /**** Recurring Services ****/
               
              renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
              renderSubMenuListEnd(ref writer);
    
              /**** Request Name ****/

              writer.Write(  @"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                            , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                            , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                            , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);
                            
              /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                renderMenuListItem(ref writer, @"managesvcdescrlink",  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE,     ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"viewsvcdescrlink",    ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW,            ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
              renderSubMenuListEnd(ref writer);

              /* Old Orders Menu -- Render hidden to preserve compatability*/
              
              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                renderMenuListItem(ref writer, @"manageordersnewlink",        ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW,         ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                renderMenuListItem(ref writer, @"manageordersviewlink",       ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW,        ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);                
              renderSubMenuListEnd(ref writer);
              
              renderTopMenuListEnd(ref writer);
              
             /*------------------------ 
               * Sites
               *------------------------*/

              renderTopMenuListStart(ref writer, @"Sites");
              writer.Write(@"<li><a id=""addsitelink""           href=""" + MBA.HttpApplication.createLink("sbs_all_sites_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewsitelink""          href=""" + MBA.HttpApplication.createLink("sbs_all_sites_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelsiteslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_sites_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);
                                                              
             /*------------------------ 
               * Users
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Users");
              writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_user_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_user_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_user_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);

             /*------------------------ 
               * Reports
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Reports");
              writer.Write(@"<li><a id=""rptclmpaidbycheckdate""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx",true)                  + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""            href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true)        + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbyservicedate""                  href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true)          + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared""          href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
              writer.Write(@"<li><a id=""rptpotlostreimburse""                      href=""" + MBA.HttpApplication.createLink(Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE, true) + @""">" + Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE + @"</a></li>");
              renderMenuListItem(ref writer, "rptorpdocslink", ORPDocuments.SEL_LABEL_RPT, ORPDocuments.URL_SBS_VIEW);
              renderMenuListItem(ref writer, "rptspedcareweekly", Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT, Clients.URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT);                             
              writer.Write(@"<li><a id=""rptcountofbatchesinprocessbystatus""       href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS + @"</a></li>");
              writer.Write(@"<li><a id=""rptcountbatchesreadytoassignbytypeofwork"" href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK + @"</a></li>");
              renderMenuListItem(ref writer, "rptbatchesassignednotdonelink", Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE, Clients.URL_SBS_ALL_RPT_BATCHES_ASSIGNED_NOT_DONE);
              writer.Write(@"<li><a id=""rptbatchesabt2ageout""                     href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_ABOUT_TO_AGE_OUT, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT + @"</a></li>");
              writer.Write(@"<li><a id=""rptbatchesneedingpriorityreview""          href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW + @"</a></li>");
              renderMenuListItem(ref writer, "rptbatchesinprocess", Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS, Clients.URL_SBS_ALL_RPT_BATCHES_IN_PROCESS);
              writer.Write(@"<li><a id=""rptinputstafftraininginprocesslink""           href=""" + MBA.HttpApplication.createLink(InputBatchesStatus.URL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS, true) + @""">" + InputBatchesStatus.SEL_LABEL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS + @"</a></li>");
              writer.Write(@"<li><a id=""viewclmslink""                             href=""" + MBA.HttpApplication.createLink("rpt_claims_view.aspx", true) + @""">Claims View</a></li>");
              writer.Write(@"<li><a id=""viewtattlelink""                           href=""" + MBA.HttpApplication.createLink(Practitioners.URL_SBS_ALL_RPT_TATTLETALE, true) + @""">Tattle Tale</a></li>");                           
              writer.Write(@"<li><a id=""rptpracrevlink""                           href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
              writer.Write(@"<li><a id=""viewworknotreceivedlink""                  href=""" + MBA.HttpApplication.createLink("rpt_client_work_not_received.aspx", true) + @""">Client Work Not Received</a></li>");
              writer.Write(@"<li><a id=""rptpracleamaaxrefsetupissues""             href=""" + MBA.HttpApplication.createLink("rpt_prac_lea_maa_xref_issues.aspx", true) + @""">Miscoded MAA Participants</a></li>");
              writer.Write(@"<li><a id=""rptbyeligpatdos2p""                        href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");              
              writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""                 href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
              writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""                 href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true)   + @""">By Patient for One Practitioner by Service Date</a></li>");
              writer.Write(@"<li><a id=""rptfilesuploaded""                         href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true)   + @""">Files Uploaded to SpEdCare</a></li>");
              renderTopMenuListEnd(ref writer);
              
              /*------------------------ 
               * Report Distribution
               *------------------------*/
              
              renderTopMenuListStart(ref writer,  Publications.SEL_LABEL);

              /**** Subscribers *****/
              
              renderSubMenuListStart(ref writer,  Subscribers.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscriber_save.aspx",        true) + @""">" + Subscribers.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_view.aspx",        true) + @""">" + Subscribers.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              /**** Subscriptions ****/

              renderSubMenuListStart(ref writer,  Subscriptions.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscription_save.aspx",        true) + @""">"  + Subscriptions.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_view.aspx",        true) + @""">" + Subscriptions.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Claim Management
               *------------------------*/
                            
              renderTopMenuListStart(ref writer, @"Claim Management");
              writer.Write(@"<li><a id=""viewclaimprocedureslink""         href=""" + MBA.HttpApplication.createLink("sbs_all_claim_procedures_view.aspx", true) + @""">View Procedure Codes</a></li>");
              writer.Write(@"<li><a id=""viewclaimprocedurefeeslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_claim_procedure_fees_view.aspx", true) + @""">View Procedure Fees</a></li>");
              writer.Write(@"<li><a id=""addnewclaimexceptionslink""       href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exception_save.aspx", true) + @""">Record New Claim Exception</a></li>");
              writer.Write(@"<li><a id=""viewclaimexceptionslink""         href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exceptions_view.aspx", true) + @""">View Claim Exceptions</a></li>");
              writer.Write(@"<li><a id=""editdelclaimexceptionslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exception_edit_delete.aspx", true) + @""">Review, Edit or Delete Claim Exception</a></li>");
              renderTopMenuListEnd(ref writer);
    
              /*------------------------ 
               * Production
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Production");
              writer.Write(@"<li><a id=""traininglink"" href=""" + MBA.HttpApplication.createLink("sbs_all_training.aspx", true) + @""" target=""_blank"">Production Documents</a></li>");
              renderTopMenuListEnd(ref writer);
              
              /*---------------------- 
               * Manage Help Library 
               *---------------------*/
                
              renderTopMenuListStart(ref writer, ManPages.SEL_LABEL);              
              writer.Write(@"<li><a id=""adminaddnewmanpagelink""        href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_SAVE,                 true) + @""">" + ManPages.SEL_LABEL_ADD                  + @"</a></li>");
              writer.Write(@"<li><a id=""admineditdeletemanpagelink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_EDIT_DEL,             true) + @""">" + ManPages.SEL_LABEL_EDIT_DELETE          + @"</a></li>");
              writer.Write(@"<li><a id=""adminviewmanpagelink""          href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_VIEW,                 true) + @""">" + ManPages.SEL_LABEL_VIEW                 + @"</a></li>");
              writer.Write(@"<li><a id=""adminrptreviewuserresplink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_RPT_USER_RESP_REVIEW, true) + @""">" + ManPages.SEL_LABEL_RPT_USER_RESP_REVIEW + @"</a></li>");
              writer.Write(@"<li><a target=""_blank"" id=""adminreviewmanpagecontentlink"" href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_REVIEW_CONTENT,       true) + @""">" + ManPages.SEL_LABEL_REVIEW_CONTENT       + @"</a></li>");
              renderTopMenuListEnd (ref writer);
                            
              break;
            }
            
           /*********************************************************************************************
            *                              Practi-Cal Role - Client Consultants
            *********************************************************************************************/ 

            case Constants.ROLE_CLIENT_CONSULTANT:
            {

              /*---------------------- 
               * Manage Help Library 
               *---------------------*/
                
              renderTopMenuListStart(ref writer, ManPages.SEL_LABEL);              
              writer.Write(@"<li><a id=""adminaddnewmanpagelink""        href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_SAVE,                 true) + @""">" + ManPages.SEL_LABEL_ADD                  + @"</a></li>");
              writer.Write(@"<li><a id=""admineditdeletemanpagelink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_EDIT_DEL,             true) + @""">" + ManPages.SEL_LABEL_EDIT_DELETE          + @"</a></li>");
              writer.Write(@"<li><a id=""adminviewmanpagelink""          href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_VIEW,                 true) + @""">" + ManPages.SEL_LABEL_VIEW                 + @"</a></li>");
              writer.Write(@"<li><a id=""adminrptreviewuserresplink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_RPT_USER_RESP_REVIEW, true) + @""">" + ManPages.SEL_LABEL_RPT_USER_RESP_REVIEW + @"</a></li>");
              writer.Write(@"<li><a target=""_blank"" id=""adminreviewmanpagecontentlink"" href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_REVIEW_CONTENT,       true) + @""">" + ManPages.SEL_LABEL_REVIEW_CONTENT       + @"</a></li>");
              renderTopMenuListEnd(ref writer);
              
              /*------------------------ 
               * Manage Patient Services 
               *------------------------*/
            
              renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);
              
              /**** Patient Profiles ****/
              
              renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

              /**** Orders ****/

              renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);
    
              /**** Special Authorization ****/
             
              renderSubMenuListStart(ref writer, ClientPBSDocumentation.SEL_LABEL);              
              writer.Write(@"<li><a id=""newclientpbslink""     href="""  + MBA.HttpApplication.createLink (ClientPBSDocumentation.URL_SBS_SAVE,        true) + @""">" + ClientPBSDocumentation.SEL_LABEL_NEW         + @"</a></li>");
              writer.Write(@"<li><a id=""editdelclientpbslink"" href="""  + MBA.HttpApplication.createLink (ClientPBSDocumentation.URL_SBS_EDIT_DELETE, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              writer.Write(@"<li><a id=""viewclientpbslink""    href="""  + MBA.HttpApplication.createLink (ClientPBSDocumentation.URL_SBS_VIEW,        true) + @""">" + ClientPBSDocumentation.SEL_LABEL_VIEW        + @"</a></li>");              
              renderSubMenuListEnd(ref writer);

              /**** Recurring Services ****/
               
              renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              /**** Request Name ****/

              writer.Write(  @"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                            , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                            , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                            , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);
                            
              /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                renderMenuListItem(ref writer, @"managesvcdescrlink",  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE,     ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"viewsvcdescrlink",    ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW,            ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
              renderSubMenuListEnd(ref writer);

              /* Old Orders Menu -- Render hidden to preserve compatability*/
              
              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                renderMenuListItem(ref writer, @"manageordersnewlink",        ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW,         ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                renderMenuListItem(ref writer, @"manageordersviewlink",       ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW,        ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);                
              renderSubMenuListEnd(ref writer);
               
              renderTopMenuListEnd(ref writer);
                            
              /*------------------------ 
               * Reports
               *------------------------*/
                            
              renderTopMenuListStart(ref writer, @"Reports");

              renderSubMenuListStart(ref writer, @"Potential Lost Reimbursement");

                renderMenuListItem(ref writer, "rptpotlostreimbursedailydetlnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS);
                renderMenuListItem(ref writer, "rptpotlostreimburseoverlnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_OVERVIEW, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_OVERVIEW);
                renderMenuListItem(ref writer, "rptpotlostreimburselnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE);
                renderMenuListItem(ref writer, "rptpotlostreimburseorpdetlnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS);

              renderSubMenuListEnd(ref writer);

              renderSubMenuListStart(ref writer, @"Financial");
              writer.Write(@"<li><a id=""rptclmpaidbycheckdate""           href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx",true)                  + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""   href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true)        + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbyservicedate""         href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true)          + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
              writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared"" href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              writer.Write(@"<li><a id=""viewtattlelink""                  href=""" + MBA.HttpApplication.createLink(Practitioners.URL_SBS_ALL_RPT_TATTLETALE, true) + @""">Tattle Tale</a></li>");
              writer.Write(@"<li><a id=""rptpracrevlink""                  href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");
              writer.Write(@"<li><a id=""viewworknotreceivedlink""         href=""" + MBA.HttpApplication.createLink("rpt_client_work_not_received.aspx", true) + @""">Client Work Not Received</a></li>");
              writer.Write(@"<li><a id=""viewcrcclaimslink""               href=""" + MBA.HttpApplication.createLink("rpt_crc_claims.aspx", true) + @""">CRCS Claims</a></li>");


              renderMenuListItem(ref writer, "rptorpdocslink"                , ORPDocuments.SEL_LABEL_RPT, ORPDocuments.URL_SBS_VIEW);
              renderMenuListItem(ref writer, "rptspedcareweekly"             , Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT, Clients.URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT);

              renderMenuListItem(ref writer, "rptcountofbatchesinprocessbystatus", InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS);
              renderMenuListItem(ref writer, "rptcountbatchesreadytoassignbytypeofwork", InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK);
              renderMenuListItem(ref writer, "rptbatchesinprocess", Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS, Clients.URL_SBS_ALL_RPT_BATCHES_IN_PROCESS);
              renderMenuListItem(ref writer, "rptbatchesassignednotdonelink" , Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE, Clients.URL_SBS_ALL_RPT_BATCHES_ASSIGNED_NOT_DONE);
                                        
              writer.Write(@"<li><a id=""viewclmslink""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_view.aspx", true) + @""">Claims View</a></li>");              
              writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
              writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true) + @""">By Patient for One Practitioner by Service Date</a></li>");
              writer.Write(@"<li><a id=""rptpracleamaaxrefsetupissues""    href=""" + MBA.HttpApplication.createLink("rpt_prac_lea_maa_xref_issues.aspx", true)   + @""">Miscoded MAA Participants</a></li>");
              writer.Write(@"<li><a id=""rptbyeligpatdos2p""               href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");
              // writer.Write(@"<li><a id=""rptrecentanifiles""               href=""" + MBA.HttpApplication.createLink("rpt_recent_ani_files.aspx", true) + @""">" + Workflow.RPT_NAME_RECENT_ANI + @"</a></li>");              
              writer.Write(@"<li><a id=""rptpracsupsvcsstillheld""         href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_RPT_SVC_REC_PENDING_APPROVAL_OR_HELD, true) + @""">" + ServiceRecordsApproval.SEL_LABEL_PRAC_SVC_REC_PENDING_APPROVAL_OR_HELD + @"</a></li>");
              writer.Write(@"<li><a id=""rptfilesuploaded""                href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true)   + @""">Files Uploaded to SpEdCare</a></li>");              
              writer.Write(@"<li><a id=""viewsvcsrendcomponepat""          href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_SBSC_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");

              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Report Distribution
               *------------------------*/
              
              renderTopMenuListStart(ref writer,  Publications.SEL_LABEL);

              /**** Subscribers *****/
              
              renderSubMenuListStart(ref writer,  Subscribers.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscriber_save.aspx",        true) + @""">" + Subscribers.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_view.aspx",        true) + @""">" + Subscribers.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              /**** Subscriptions ****/

              renderSubMenuListStart(ref writer,  Subscriptions.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscription_save.aspx",        true) + @""">"  + Subscriptions.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_view.aspx",        true) + @""">" + Subscriptions.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              renderTopMenuListEnd(ref writer);

             
              /*------------------------ 
               * Caseloads
               *------------------------*/
             
              writer.Write(@"<li><a id=""caseloadandgroupmgmtlink""   href=""" + MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_SBS_CSLD_PT_GRP_SEL_CLIENT_PRAC, true) + @""">" + PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC + @"</a></li>");                                     
             
              /*------------------------ 
               * Transportation
               *------------------------*/
              
              renderTopMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
              writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink (TransportationMgmtRecords.URL_SBS_ALL_SELECT_CLIENT           , true, new NameValue(TransportationMgmtRecords.PARM_NAME_TMGMT_SCREEN, TransportationMgmtRecords.PARM_VALUE_TMGMT_SCREEN_1)) + @""">"  + TransportationMgmtRecords.SEL_LABEL_MANAGE                 + @"</a></li>");
              writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink (TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET  , true) + @""">"  + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");
              renderTopMenuListEnd(ref writer);
         
              /*------------------------ 
               * Service Records              
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Service Records");
              writer.Write(@"<li><a id=""viewsvcrecslink""     href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
              renderTopMenuListEnd(ref writer);
              
              /*------------------------ 
               * Clients
               *------------------------*/              
              
              renderTopMenuListStart(ref writer, @"Clients");
              writer.Write(@"<li><a id=""viewclientlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_client_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelclientrecslink"" href=""" + MBA.HttpApplication.createLink("sbs_mgmt_client_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");                            
              renderTopMenuListEnd(ref writer);
              
              /*------------------------ 
               * Practitioners
               *------------------------*/
             
              renderTopMenuListStart(ref writer, @"Practitioners");
              writer.Write(@"<li><a id=""addnewpraclink""        href=""" + MBA.HttpApplication.createLink("sbs_all_prac_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpraclink""          href=""" + MBA.HttpApplication.createLink("sbs_all_prac_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpracrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_prac_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Patients
               *------------------------*/
                            
              renderTopMenuListStart(ref writer, @"Patients");
              writer.Write(@"<li><a id=""addnewpatlink""         href=""" + MBA.HttpApplication.createLink("sbs_all_pat_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpatlink""           href=""" + MBA.HttpApplication.createLink("sbs_all_pat_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpatrecslink""    href=""" + MBA.HttpApplication.createLink("sbs_all_pat_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx",  true) + @""">Merge Data</a></li>");
              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Sites
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Sites");
              writer.Write(@"<li><a id=""addsitelink""           href=""" + MBA.HttpApplication.createLink("sbs_all_sites_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewsitelink""          href=""" + MBA.HttpApplication.createLink("sbs_all_sites_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelsiteslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_sites_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);
                            
              /*------------------------ 
               * Users
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Users");
              writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_user_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_user_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_user_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);         

             
              break;
            }
            
           /*********************************************************************************************
            *                              Practi-Cal Role - Administrators
            *********************************************************************************************/ 

            case Constants.ROLE_ADMIN:
            {              
              
              /*---------------------- 
               * Manage Help Library 
               *---------------------*/
                
              renderTopMenuListStart(ref writer, ManPages.SEL_LABEL);              
              writer.Write(@"<li><a id=""adminaddnewmanpagelink""        href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_SAVE,                 true) + @""">" + ManPages.SEL_LABEL_ADD                  + @"</a></li>");
              writer.Write(@"<li><a id=""admineditdeletemanpagelink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_EDIT_DEL,             true) + @""">" + ManPages.SEL_LABEL_EDIT_DELETE          + @"</a></li>");
              writer.Write(@"<li><a id=""adminviewmanpagelink""          href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_VIEW,                 true) + @""">" + ManPages.SEL_LABEL_VIEW                 + @"</a></li>");
              writer.Write(@"<li><a id=""adminrptreviewuserresplink""    href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_RPT_USER_RESP_REVIEW, true) + @""">" + ManPages.SEL_LABEL_RPT_USER_RESP_REVIEW + @"</a></li>");
              writer.Write(@"<li><a target=""_blank"" id=""adminreviewmanpagecontentlink"" href=""" + MBA.HttpApplication.createLink(ManPages.URL_MAN_PAGE_REVIEW_CONTENT,       true) + @""">" + ManPages.SEL_LABEL_REVIEW_CONTENT       + @"</a></li>");
              renderTopMenuListEnd (ref writer);
              
              /*------------------------ 
               * Manage Patient Services 
               *------------------------*/
            
              renderTopMenuListStart(ref writer, ServiceJournals.SEL_LABEL_MANAGE_PATIENT_SERVICES);
              
              /**** Patient Profiles ****/
              
              renderMenuListItem(ref writer, "managesvcdescrsmanagelink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_MANAGE, ServiceJournals.URL_SBS_MANAGE_SERVICE_DESCRIPTIONS_MANAGE);

              /**** Orders ****/

              renderMenuListItem(ref writer, "manageordersmanagelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_MANAGE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPLATE_MANAGE);

              /**** Special Authorization ****/
             
              renderSubMenuListStart(ref writer, ClientPBSDocumentation.SEL_LABEL);              
              writer.Write(@"<li><a id=""newclientpbslink""     href="""  + MBA.HttpApplication.createLink (ClientPBSDocumentation.URL_SBS_SAVE,        true) + @""">" + ClientPBSDocumentation.SEL_LABEL_NEW         + @"</a></li>");
              writer.Write(@"<li><a id=""editdelclientpbslink"" href="""  + MBA.HttpApplication.createLink (ClientPBSDocumentation.URL_SBS_EDIT_DELETE, true) + @""">" + ClientPBSDocumentation.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              writer.Write(@"<li><a id=""viewclientpbslink""    href="""  + MBA.HttpApplication.createLink (ClientPBSDocumentation.URL_SBS_VIEW,        true) + @""">" + ClientPBSDocumentation.SEL_LABEL_VIEW        + @"</a></li>");              
              renderSubMenuListEnd(ref writer);

              /**** Recurring Services ****/
               
              renderSubMenuListStart(ref writer, RecurringServices.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewrcrsvcloadlink""    href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_save.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewrcrsvcloadlink""      href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_view.aspx",        true) + @""">" + RecurringServices.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelrcrsvcrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_recurring_services_edit_delete.aspx", true) + @""">" + RecurringServices.SEL_LABEL_OPS + @"</a></li>");
              renderSubMenuListEnd(ref writer);
                       
              /**** Transportation ****/
             
              renderSubMenuListStart(ref writer, TransportationMgmtRecords.SEL_LABEL);
              writer.Write(@"<li><a id=""managetranspatientsrouteslink""  href=""" + MBA.HttpApplication.createLink (TransportationMgmtRecords.URL_SBS_ALL_SELECT_CLIENT           , true, new NameValue(TransportationMgmtRecords.PARM_NAME_TMGMT_SCREEN, TransportationMgmtRecords.PARM_VALUE_TMGMT_SCREEN_1)) + @""">"  + TransportationMgmtRecords.SEL_LABEL_MANAGE + @"</a></li>");
              writer.Write(@"<li><a id=""processincomingroutesheetslink"" href=""" + MBA.HttpApplication.createLink (TransportationMgmtRecords.URL_SBS_ALL_PROCESS_INCOMING_SHEET  , true) + @""">"  + TransportationMgmtRecords.SEL_LABEL_PROCESS_INCOMING_SHEET + @"</a></li>");                            
              renderSubMenuListEnd(ref writer);

              /**** Plan Writer ****/

              renderSubMenuListStart(ref writer, PlanWriterRecords.SEL_LABEL);             
              writer.Write(@"<li><a id=""planwritemanageplanslink"" href=""" + MBA.HttpApplication.createLink (PlanWriterRecords.URL_SBS_ALL_SELECT_CLIENT, true) + @""">"  + PlanWriterRecords.SEL_LABEL_MANAGE + @"</a></li>");
              renderSubMenuListEnd(ref writer);
              
              /**** ORP Document Standard Selection Names ****/

              renderSubMenuListStart (ref writer, ORPDocumentsStandardSelectionNames.SEL_LABEL);
                renderMenuListItem(ref writer,@"orpdocstdselnamenewlink",     ORPDocumentsStandardSelectionNames.SEL_LABEL_NEW,         ORPDocumentsStandardSelectionNames.URL_SBS_SAVE);
                renderMenuListItem(ref writer,@"orpdocstdselnameeditdellink", ORPDocumentsStandardSelectionNames.SEL_LABEL_EDIT_DELETE, ORPDocumentsStandardSelectionNames.URL_SBS_EDIT_DELETE);
                renderMenuListItem(ref writer,@"orpdocstdselnameviewlink",    ORPDocumentsStandardSelectionNames.SEL_LABEL_VIEW,        ORPDocumentsStandardSelectionNames.URL_SBS_VIEW);
              renderSubMenuListEnd(ref writer);
    
              /**** Request Name ****/

              writer.Write(  @"<li><a id=""{0}"" target=""_blank"" href=""{1}"">{2}</a></li>"
                            , Constants.REQUEST_OPR_DOC_STD_NAME_MENU_ID
                            , Constants.REQUEST_ORP_DOC_STD_NAME_URL
                            , Constants.REQUEST_ORP_DOC_STD_NAME_LBL);
                            
              /**** Old Patient Profiles Menu -- Render hidden to preserve compatability ****/

              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION, true);
                renderMenuListItem(ref writer, @"managesvcdescrlink",  ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_ADD_NEW_OR_EDIT, ServiceJournals.URL_SBS_SAVE_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"editdelsvcdescrlink", ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_EDIT_DELETE,     ServiceJournals.URL_SBS_EDIT_DEL_SERVICE_DESCRIPTION, true, true);
                renderMenuListItem(ref writer, @"viewsvcdescrlink",    ServiceJournals.SEL_LABEL_MANAGE_SERVICE_DESCRIPTION_VIEW,            ServiceJournals.URL_SBS_SERVICE_DESCRIPTIONS_VIEW, true, true);
              renderSubMenuListEnd(ref writer);

              /* Old Orders Menu -- Render hidden to preserve compatability*/
              
              renderSubMenuListStart (ref writer, ServiceJournals.SEL_LABEL_MANAGE_ORDERS, true);
                renderMenuListItem(ref writer, @"manageordersnewlink",        ServiceJournals.SEL_LABEL_MANAGE_ORDERS_NEW,         ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_NEW, true, true);
                renderMenuListItem(ref writer, @"manageorderseditdeletelink", ServiceJournals.SEL_LABEL_MANAGE_ORDERS_EDIT_DELETE, ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_EDIT_DELETE, true, true);
                renderMenuListItem(ref writer, @"manageordersviewlink",       ServiceJournals.SEL_LABEL_MANAGE_ORDERS_VIEW,        ServiceJournals.URL_SBS_MANAGE_ORDERS_NOTE_TEMPATE_VIEW, true, true);                
              renderSubMenuListEnd(ref writer);
              
              renderTopMenuListEnd(ref writer);
              
         
             /*------------------------ 
               * Reports
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Reports");
                            
              renderSubMenuListStart(ref writer, @"Financial");              
                writer.Write(@"<li><a id=""rptclmpaidbycheckdate""           href=""" + MBA.HttpApplication.createLink("rpt_claims_paid.aspx",true)                  + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_1P + @"</a></li>");
                writer.Write(@"<li><a id=""rptclmpaidbycheckdatecompared""   href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_compared.aspx", true)        + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_WD_2P + @"</a></li>");
                writer.Write(@"<li><a id=""rptclmpaidbyservicedate""         href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos.aspx", true)          + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_1P + @"</a></li>");
                writer.Write(@"<li><a id=""rptclmpaidbyservicedatecompared"" href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_PRAC_SD_2P + @"</a></li>");
                writer.Write(@"<li><a id=""rptcombined1on1bypmtdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_pmt_date.aspx", true) + @""">By Patient for One Practitioner by Payment Date</a></li>");
                writer.Write(@"<li><a id=""rptcombined1on1bysvcdate""        href=""" + MBA.HttpApplication.createLink("rpt_combined_1on1_by_svc_date.aspx", true)   + @""">By Patient for One Practitioner by Service Date</a></li>");
                writer.Write(@"<li><a id=""rptbyeligpatdos2p""               href=""" + MBA.HttpApplication.createLink("rpt_claims_paid_by_elig_pat_dos_compared.aspx", true) + @""">" + Reports.Fianancial.RPT_NAME_AMTS_BY_ELIG_PAT_SD_2P + @"</a></li>");              
              renderSubMenuListEnd(ref writer);


              renderSubMenuListStart(ref writer, @"Production Reports");
                renderMenuListItem(ref writer, "rptcountofbatchesinprocessbystatus", InputBatchesStatus.SEL_LABEL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS, InputBatchesStatus.URL_RPT_COUNT_OF_BATCHES_IN_PROCESS_BY_STATUS);
                renderMenuListItem(ref writer, "rptcountbatchesreadytoassignbytypeofwork", InputBatchesStatus.SEL_LABEL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK, InputBatchesStatus.URL_RPT_COUNT_BATCHES_READY_TO_ASSIGN_BY_TYPE_OF_WORK);
                renderMenuListItem(ref writer, "rptbatchesinprocess", Clients.SEL_LABEL_RPT_BATCHES_IN_PROCESS, Clients.URL_SBS_ALL_RPT_BATCHES_IN_PROCESS);
                renderMenuListItem(ref writer, "rptbatchesassignednotdonelink", Clients.SEL_LABEL_RPT_BATCHES_ASSIGNED_NOT_DONE, Clients.URL_SBS_ALL_RPT_BATCHES_ASSIGNED_NOT_DONE);
                renderMenuListItem(ref writer, "rptbatchesneedingpriorityreview", InputBatchesStatus.SEL_LABEL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW, InputBatchesStatus.URL_RPT_BATCHES_NEEDING_PRIORITY_REVIEW);
                renderMenuListItem(ref writer, "rptbatchesabt2ageout", InputBatchesStatus.SEL_LABEL_RPT_BATCHES_ABOUT_TO_AGE_OUT, InputBatchesStatus.URL_RPT_BATCHES_ABOUT_TO_AGE_OUT);
                renderMenuListItem(ref writer, "rptinputstafftraininginprocesslink", InputBatchesStatus.SEL_LABEL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS, InputBatchesStatus.URL_RPT_INPUT_STAFF_TRAINING_IN_PROCESS);
              renderSubMenuListEnd(ref writer);
              

              renderSubMenuListStart(ref writer, @"Potential Lost Reimbursement");
              
                renderMenuListItem(ref writer, "rptpotlostreimbursedailydetlnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_DAILY_DETAILS);
                renderMenuListItem(ref writer, "rptpotlostreimburseoverlnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_OVERVIEW, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_OVERVIEW);                            
                renderMenuListItem(ref writer, "rptpotlostreimburselnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE);                            
                renderMenuListItem(ref writer, "rptpotlostreimburseorpdetlnk", Claims.SEL_LABEL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS, Claims.URL_SBS_ALL_RPT_POT_LOST_REIMBURSE_ORP_DETAILS);

              renderSubMenuListEnd(ref writer);

              renderSubMenuListStart(ref writer, @"SpEdCare Weekly");              

                renderMenuListItem(ref writer, "rptspedcareweekly",         Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT, Clients.URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT);
                renderMenuListItem(ref writer, "rptspedcareweeklyextended", Clients.SEL_LABEL_RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED, Clients.URL_SBS_ALL_RPT_SPEDCARE_WEEKLY_REPORT_EXTENDED);                            

              renderSubMenuListEnd(ref writer);

              renderSubMenuListStart(ref writer, @"Claims Transmission Summaries");

                renderMenuListItem(ref writer, "clmswaitingfortxsummaryrptlink", Claims.SEL_LABEL_RPT_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY, Claims.URL_CLAIMS_WAITING_FOR_NEXT_TRANSMISSION_SUMMARY_REPORT);
                renderMenuListItem(ref writer, "clmstxsummaryrptlink",           Claims.SEL_LABEL_RPT_CLAIM_TRANSMISSION_SUMMARY,                   Claims.URL_CLAIM_TRANSMISSION_SUMMARY_REPORT);

              renderSubMenuListEnd(ref writer);

              writer.Write(@"<li><a id=""viewsvcsrendcomponepat""          href=""" + MBA.HttpApplication.createLink(ServiceRecords.PAGE_SBSC_ALL_SVC_COMP_REPT, true) + @""">" + ServiceRecords.SEL_LABEL_PLAN_SVC_COMP_REPT + @"</a></li>");
              renderMenuListItem(ref writer, "rptorpdocslink",            ORPDocuments.SEL_LABEL_RPT, ORPDocuments.URL_SBS_VIEW);                                                                                                                
              writer.Write(@"<li><a id=""viewclmslink""                    href=""" + MBA.HttpApplication.createLink("rpt_claims_view.aspx", true) + @""">Claims View</a></li>");
              writer.Write(@"<li><a id=""viewtattlelink""                  href=""" + MBA.HttpApplication.createLink(Practitioners.URL_SBS_ALL_RPT_TATTLETALE, true) + @""">Tattle Tale</a></li>");              
              writer.Write(@"<li><a id=""rptpracrevlink""            href=""" + MBA.HttpApplication.createLink("rpt_prac_review.aspx", true) + @""">Practitioner Review</a></li>");              
              writer.Write(@"<li><a id=""viewworknotreceivedlink""         href=""" + MBA.HttpApplication.createLink("rpt_client_work_not_received.aspx", true) + @""">Client Work Not Received</a></li>");
              writer.Write(@"<li><a id=""viewcrcsclaimslink""              href=""" + MBA.HttpApplication.createLink("rpt_crc_claims.aspx", true) + @""">CRCS Claims</a></li>");
              writer.Write(@"<li><a id=""rptpracleamaaxrefsetupissues""    href=""" + MBA.HttpApplication.createLink("rpt_prac_lea_maa_xref_issues.aspx", true)   + @""">Miscoded MAA Participants</a></li>");
              writer.Write(@"<li><a id=""rptpracsupsvcsstillheld""         href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_RPT_SVC_REC_PENDING_APPROVAL_OR_HELD, true) + @""">" + ServiceRecordsApproval.SEL_LABEL_PRAC_SVC_REC_PENDING_APPROVAL_OR_HELD + @"</a></li>");
              writer.Write(@"<li><a id=""rptfilesuploaded""                href=""" + MBA.HttpApplication.createLink("rpt_file_uploads_view.aspx", true)   + @""">Files Uploaded to SpEdCare</a></li>");
              
              renderTopMenuListEnd(ref writer);
                                       
              /*------------------------ 
               * Report Distribution
               *------------------------*/
              
              renderTopMenuListStart(ref writer,  Publications.SEL_LABEL);

              /**** Subscribers *****/
              
              renderSubMenuListStart(ref writer,  Subscribers.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewsbrlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscriber_save.aspx",        true) + @""">" + Subscribers.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewsbrlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_view.aspx",        true) + @""">" + Subscribers.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelsbrlink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscribers_edit_delete.aspx", true) + @""">" + Subscribers.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              /**** Subscriptions ****/

              renderSubMenuListStart(ref writer,  Subscriptions.SEL_LABEL);
              writer.Write(@"<li><a id=""addnewsublink""        href=""" + MBA.HttpApplication.createLink("sbs_all_subscription_save.aspx",        true) + @""">"  + Subscriptions.SEL_LABEL_ADD         + @"</a></li>");
              writer.Write(@"<li><a id=""viewsublink""          href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_view.aspx",        true) + @""">" + Subscriptions.SEL_LABEL_VIEW        + @"</a></li>");
              writer.Write(@"<li><a id=""editdelsublink""       href=""" + MBA.HttpApplication.createLink("sbs_all_subscriptions_edit_delete.aspx", true) + @""">" + Subscriptions.SEL_LABEL_EDIT_DELETE + @"</a></li>");
              renderSubMenuListEnd(ref writer);

              renderTopMenuListEnd(ref writer);
                                       
              /*------------------------ 
               * Service Records              
               *------------------------*/

              renderTopMenuListStart(ref writer, @"Service Records");              
              writer.Write(@"<li><a id=""addnewsvcreclink""            href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""batchnewsvcreclink""          href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save.aspx",true) + @""">Record Multiple New</a></li>");
              writer.Write(@"<li><a id=""batchnewsvcrecmultiencountlink"" href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_save_multi_encounter.aspx",true) + @""">Record Multiple New - Multiple Encounters</a></li>");
              writer.Write(@"<li><a id=""viewsvcrecslink""     href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_edit_delete.aspx",true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""batcheditdelsvcrecslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_batch_edit_delete.aspx",true) + @""">Batch Delete</a></li>");
              writer.Write(@"<li><a id=""viewsvcrecssvcnoteslink""  href=""" + MBA.HttpApplication.createLink("sbs_all_svcrec_svcnote_view.aspx", true) + @""">View Progress Notes Saved in SpEdCare</a></li>");
              renderMenuListItem(ref writer,@"svcrecorpdocasclink",  @"Associate ORP Documents",  @"sbs_all_orp_doc_svc_rec_asc.aspx");              
              renderTopMenuListEnd(ref writer);
                                         
              /*------------------------ 
               * Clients
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Clients");
              
              /**** Manage ****/
              
              writer.Write(@"<li><a id=""addnewclientlink""      href=""" + MBA.HttpApplication.createLink("sbs_mgmt_client_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewclientlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_client_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelclientrecslink"" href=""" + MBA.HttpApplication.createLink("sbs_mgmt_client_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");                            

              /**** Sites ****/

              renderSubMenuListStart(ref writer, @"Sites");
              writer.Write(@"<li><a id=""addsitelink""           href=""" + MBA.HttpApplication.createLink("sbs_all_sites_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewsitelink""          href=""" + MBA.HttpApplication.createLink("sbs_all_sites_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelsiteslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_sites_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderSubMenuListEnd(ref writer);

              renderTopMenuListEnd(ref writer);
                            
              /*------------------------ 
               * Practitioners
               *------------------------*/
                            
              renderTopMenuListStart(ref writer, @"Practitioners");              
             
              /**** Management ****/
              
              writer.Write(@"<li><a id=""addnewpraclink""        href=""" + MBA.HttpApplication.createLink("sbs_all_prac_save.aspx", true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpraclink""          href=""" + MBA.HttpApplication.createLink("sbs_all_prac_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpracrecslink""   href=""" + MBA.HttpApplication.createLink("sbs_all_prac_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");

              /**** Caseloads ****/               
             
              writer.Write(@"<li><a id=""caseloadandgroupmgmtlink""   href=""" + MBA.HttpApplication.createLink(PractitionerCaseloadMembers.URL_SBS_CSLD_PT_GRP_SEL_CLIENT_PRAC, true) + @""">" + PractitionerCaseloadMembers.SEL_LABEL_NON_PRAC + @"</a></li>");

              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Patients
               *------------------------*/
                                          
              renderTopMenuListStart(ref writer, @"Patients");
              writer.Write(@"<li><a id=""addnewpatlink""         href=""" + MBA.HttpApplication.createLink("sbs_all_pat_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewpatlink""           href=""" + MBA.HttpApplication.createLink("sbs_all_pat_view.aspx", true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdelpatrecslink""    href=""" + MBA.HttpApplication.createLink("sbs_all_pat_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              writer.Write(@"<li><a id=""mergepatrecslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_patients_merge.aspx",  true) + @""">Merge Data</a></li>");
              renderTopMenuListEnd(ref writer);

              /*------------------------ 
               * Users
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Users");
              writer.Write(@"<li><a id=""addnewuserlink""        href=""" + MBA.HttpApplication.createLink("sbs_all_user_save.aspx",true) + @""">Record New</a></li>");
              writer.Write(@"<li><a id=""viewuserlink""          href=""" + MBA.HttpApplication.createLink("sbs_all_user_view.aspx",true) + @""">View</a></li>");
              writer.Write(@"<li><a id=""editdeluserslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_user_edit_delete.aspx", true) + @""">Review, Edit or Delete</a></li>");
              renderTopMenuListEnd(ref writer);
              
                                            
              /*------------------------ 
               * Other
               *------------------------*/
              
              renderTopMenuListStart(ref writer, @"Other");
              
              /* Claim Management */

              renderSubMenuListStart(ref writer, @"Claim Management");              
              writer.Write(@"<li><a id=""addnewclaimprocedurelink""        href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedures_save.aspx", true) + @""">Record New Procedure Code</a></li>");
              writer.Write(@"<li><a id=""viewclaimprocedureslink""         href=""" + MBA.HttpApplication.createLink("sbs_all_claim_procedures_view.aspx", true) + @""">View Procedure Codes</a></li>");
              writer.Write(@"<li><a id=""editdelclaimprocedureslink""      href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedures_edit_delete.aspx", true) + @""">Review, Edit or Delete Procedure Code</a></li>");
              writer.Write(@"<li><a id=""addnewprocedurefeelink""          href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedure_fees_save.aspx", true) + @""">Record New Procedure Fee</a></li>");
              writer.Write(@"<li><a id=""viewclaimprocedurefeeslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_claim_procedure_fees_view.aspx", true) + @""">View Procedure Fees</a></li>");
              writer.Write(@"<li><a id=""editdelclaimprocedurefeeslink""   href=""" + MBA.HttpApplication.createLink("sbs_mgmt_claim_procedure_fees_edit_delete.aspx", true) + @""">Review, Edit or Delete Procedure Fee</a></li>");
              writer.Write(@"<li><a id=""addnewclaimexceptionslink""       href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exception_save.aspx", true) + @""">Record New Claim Exception</a></li>");
              writer.Write(@"<li><a id=""viewclaimexceptionslink""         href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exceptions_view.aspx", true) + @""">View Claim Exceptions</a></li>");
              writer.Write(@"<li><a id=""editdelclaimexceptionslink""      href=""" + MBA.HttpApplication.createLink("sbs_all_claim_processing_exception_edit_delete.aspx", true) + @""">Review, Edit or Delete Claim Exception</a></li>");
              renderSubMenuListEnd(ref writer);

              /* Production */
              
              renderSubMenuListStart(ref writer,  @"Production");
              writer.Write(@"<li><a id=""traininglink"" href=""" + MBA.HttpApplication.createLink("sbs_all_training.aspx", true) + @""" target=""_blank"">Production Documents</a></li>");
              renderSubMenuListEnd(ref writer);                           
              
              /**** System Admin ****/

              renderSubMenuListStart(ref writer,  @"System Admin Tools");              
              renderMenuListItem(ref writer,@"sysadminviewloginslink",@"View Current Logins",@"sbs_system_admin_view_current_logins.aspx");
              renderMenuListItem(ref writer,@"sysadminlink", @"Test Third Party API",@"sbs_system_admin.aspx");
              renderSubMenuListEnd(ref writer);                       

              renderTopMenuListEnd(ref writer);                           

              break;
            }

            default:
            {
              // No default menu
              break;
            }
          }
    
    });
    
          
    /*-------------------------------
     * Header public
     *------------------------------*/ 

    static renderHeaderPublic rheaderPublic = new renderHeaderPublic(delegate(string homelink, ref HtmlTextWriter writer)
    {          
 
    });
    
    /*-------------------------------
     * Header private
     *------------------------------*/ 

    static renderHeaderPrivate rheaderPrivate = new renderHeaderPrivate (delegate (string homelink, string helplink, ref SqlConnection dbConnUser, ref SqlConnection dbConnApp, ref DetailsLog log, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {    
            
      /* If the user is a client then we add the teach me button and client rep contact info */

      if (rd.wu.usr.userGroupID == Constants.USER_GROUP_CLIENT)      
      {
                              
         /* Section */

         writer.Write(@"<div class=""header-section header-section-center"">");                  
        
         writer.Write(@"<div class=""header-section-row"">");                                  
         writer.Write(@"<div class=""header-section-col header-section-col-left"">");
         writer.Write(@"Need Help?");
         writer.Write(@"</div>"); /* Col */         
         
         writer.Write(@"<div class=""header-section-col header-section-col-right"">");
         writer.Write(@"<a id=""but-teach-me"" href=""{0}"">Teach Me</a>", helplink); 
         writer.Write(@"</div>"); /* Col */         
                
         writer.Write(@"</div>");
         
         writer.Write(@"<div class=""header-section-row"">");                          
         
         writer.Write(@"</div>");         
                  
         writer.Write(@"</div>");
         
         /* Section */
         
         writer.Write(@"<div class=""header-section header-section-right"">");                  

         writer.Write(@"<div class=""header-section-row"">");                 
         
         writer.Write(@"<div class=""header-section-col header-section-col-left"">");
         writer.Write(@"Need More Help?");
         writer.Write(@"</div>"); /* Col */         
         
         writer.Write(@"<div class=""header-section-col header-section-col-right"">");                  
         writer.Write(@"{0} {1}", rd.wu.usr.clientRepFirstName, rd.wu.usr.clientRepLastName);
         writer.Write(@"</div>"); /* Col */
         
         writer.Write(@"</div>"); 
         
         writer.Write(@"<div class=""header-section-row"">");                  
         writer.Write(@"<div class=""header-section-col header-section-col-left"">");         
         writer.Write(@"<a href=""mailto:{0}"">{1}</a>",rd.wu.usr.clientRepEmail,rd.wu.usr.clientRepEmail);
         writer.Write(@"</div>"); /* Col */
                  
         writer.Write(@"<div class=""header-section-col header-section-col-right"">");
         writer.Write(@"<a href=""tel:{0}"">{1}</a>",rd.wu.usr.clientRepPhone,rd.wu.usr.clientRepPhone);
         writer.Write(@"</div>"); /* Col */
         
         writer.Write(@"</div>"); /* Row 2 */
         writer.Write(@"</div>"); /* Section*/
                    
      }
      
      
    });


    /*-------------------------------
     * Public footer
     *------------------------------*/ 

    static renderFooterPublic rfooterPublic = new renderFooterPublic(delegate(ref HtmlTextWriter writer)
    {
    });


    /*-------------------------------
     * Private footer
     *------------------------------*/ 

    static renderFooterPrivate rfooterPrivate = new renderFooterPrivate(delegate(ref HtmlTextWriter writer, string roleNameLower){     
    });
        
        
    /*-------------------------------
     * To Do Messages for User
     *------------------------------*/ 

    static handleAppSpecificResponse rAppUserToDoMsgs = new handleAppSpecificResponse ( delegate ( HttpRequest req, HttpResponse rsp, ref RequestResponse rd, ref UserInfo uInfo, ref HtmlTextWriter writer) {
                       
            
      // Is a prac
      
      if (ServiceRecordsApproval.isPracWithClientThatUsesApprovalSystem(ref rd)) 
      {
              
       // Supervised with no assigned supervisor
       
       //if (ServiceRecordsApproval.isSupervisedPracWithNoAssignedSupervisor(ref rd)) {
       //  writer.Write(@"<div>");
       //  writer.Write (@"As a part of the LBO program your services require supervision. ");
       //  writer.Write (@"<a href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_CLIENT_PROV_SVC_REC_SUPERVISED_SUPERVISOR_PREF, true) + @""">Click here to select a supervisor</a>");
       //  writer.Write (@"</div>");
      // }
               
      
       // Supervised with held services
       
       if (ServiceRecordsApproval.isSupervisedPracWithHeldServices (ref rd)) {
         writer.Write(@"<div>");
         writer.Write (@"Your supervisor has returned some records for correction. ");
         writer.Write (@"<a href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_CLIENT_PROV_SVC_REC_HELD_FOR_CHANGE_DETAILS, true) + @""">Click here to make the changes</a>");
         writer.Write (@"</div>");
       }
              
       // Supervisor with services to review
     
       if (ServiceRecordsApproval.isSupervisorPracWithServicesToReviewFromAssigned (ref rd)) {
         writer.Write (@"<div>");
         writer.Write (@"You are qualified to supervise health care services for other practitioners. ");
         writer.Write (@"<a href=""" + MBA.HttpApplication.createLink(ServiceRecordsApproval.PAGE_CLIENT_PROV_SVC_REC_APPROVAL_SUMMARY, true) + @""">Click here to review pending services</a>");
         writer.Write (@"</div>");
       }
     
     }
          
    });
    
    /* Not used but included for refactoring purposes */
    
    static handleAppendingUserSpecificNotifications aUserSpecificNotifications =
    new handleAppendingUserSpecificNotifications(delegate (ref RequestResponse rd, ref UserInfo uInfo, ref MBA.WebUI3Controls.Notifications notificationsControl) {  
    });

    /*===============================
     * Constructors
     *===============================*/ 

    public WebUI(
        string bodyid
      , string subtitle
      , params string[] permittedroles):this(bodyid,subtitle,null,null,permittedroles){}   
    public WebUI(
        string bodyid
      , string subtitle
      , string css
      , string js
      , params string[] permittedroles):base(
            bodyid
          , subtitle
          , rAppBarIconsPublic
          , rAppBarIconsPrivate   
          , rheaderPublic
          , rheaderPrivate
          , rmenuPublic
          , rmenuPrivate
          , rfooterPublic
          , rfooterPrivate
          , rAppUserToDoMsgs
          , aUserSpecificNotifications
          , css
          , js
          , permittedroles)
    {
      this.appName       = Constants.APP_NAME;
      this.appVersion    = Constants.APP_VERSION;  
      this.appLogoMarkup = Messages.APP_LOGO_MKUP;
    }
  }
}