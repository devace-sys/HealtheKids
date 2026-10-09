using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * PlanWriterRecord */
  /**
   *
   ***************************************************************************/

  public class PlanWriterRecord : Entity
  {
  
  }
      
  /***************************************************************************
   * PlanWriterRecords */
  /**
   *
   ***************************************************************************/
  
  public class PlanWriterRecords : Entities
  {
    public const string SEL_LABEL                          = @"Care Plans";    
    public const string SEL_LABEL_MANAGE                   = @"Create and Manage Plans";
    public const string SEL_LABEL_SUBSCRIPTION_NOTICE      = @"Subscription Needed";
    public const string PARM_NAME_GROUP_SVC_CLASS_NAME_ID  = @"groupsvcclassnameid";
    public const string PARM_NAME_PLAN_ID                  = @"planid";
    public const string PARM_NAME_CONDITION_ID             = @"conditionid";
    public const string PARM_NAME_CLIENT_ID                = @"clientid";            
    public const string URL_SBS_ALL_SELECT_CLIENT          = @"sbs_all_plan_writer_select_client.aspx";  
    public const string URL_CLIENT_COOR_SELECT_GROUP       = @"client_coor_plan_writer_select_group.aspx";
    public const string URL_USER_ALL_MANAGE_PLANS          = @"user_all_plan_writer_manage_components_and_plans.aspx";
    public const string URL_USER_ALL_SUBSCRIPTION_NOTICE   = @"user_all_plan_writer_subscription_notice.aspx";
  
    public const string CSS_CLASS_PLAN_WRITER_PAGE           = @"mba-pdf-section plan-writer-page";
    public const string CSS_CLASS_PLAN_WRITER_SECTION_HEADER = @"plan-writer-section text-center mb-2";
    
    public const string ORP_ATTEST_STATEMENT = @"I herby attest by completing and returning this form that : 1. I have proper authority to approve or decline this authorization request. 2. If I approve this request I also understand that : a. the procedures will be implemented in accordance with state laws and regulations. b. services may be performed by school personnel under the training and supervision provided by a licensed or credentialed practitioner. c. this authorization is effective for a maximum of one year. d. a new authorization request will be submitted if changes are made to the services requested.";

    /***************************************************************************
     * clientHasAccess */
    /**
     *  
     *
     ***************************************************************************/

    public static bool clientHasAccess (  SqlConnection   connSpedmon
                                        , DetailsLog      log
                                        , UserInfo        uInfo
                                        , string          clientID)
    {
    
      bool accessGranted = false;  
      Client c = Clients.load(connSpedmon,log,uInfo,clientID);            
      accessGranted = c.planWriterAccessGranted;
      /* TODO: Access grant date check */
      return accessGranted;
    }
    
    /***************************************************************************
     * validateClientAccessForMethodOrHandler */
    /**
     * 
     *
     ***************************************************************************/

    public static bool validateClientAccessForMethodOrHandler (   SqlConnection   connSpedmon
                                                                , DetailsLog      log
                                                                , UserInfo        uInfo
                                                                , string          clientID)
    {
      bool hasAccess = clientHasAccess (connSpedmon,log,uInfo,clientID);
      if (hasAccess == false) throw new MBA.Critical(@"Subscription required");
      return hasAccess;
    }
    
    /***************************************************************************
     * validateClientAccessForPage */
    /**
     *  
     *
     ***************************************************************************/

    public static void validateClientAccessForPage (   SqlConnection   connSpedmon
                                                     , DetailsLog      log
                                                     , UserInfo        uInfo
                                                     , string          clientID
                                                     , HttpResponse    Response
                                                     , HttpContext     Context )
    {           	     
      
      bool hasAccess = clientHasAccess (connSpedmon,log,uInfo,clientID);     
      if (hasAccess == false)
      {
        string url = MBA.HttpApplication.createLink(PlanWriterRecords.URL_USER_ALL_SUBSCRIPTION_NOTICE,true);
        Response.Redirect(url,false);
        Context.ApplicationInstance.CompleteRequest();
      }   
    }
    
    /***************************************************************************
     * generateSignatureLine */
    /**
     *
     ***************************************************************************/

    public static string generateSignatureLine (int lineNumber, string participantTitle, string participantName, bool signed, string signedName, string signatureImg, string dateSigned)
    {
       StringBuilder sb = new StringBuilder();
      
       string signature = @"";
       string emptySlot = @"<div class=""w-100 p-3 border font-weight-bolder""> </div>";    
            
       if (signed)
       {
         signature = @"Electronically Signed By " + signedName;
         if (signatureImg != null)
           signature = signature + @"<br><img style=""height: 50px"" src=""" + signatureImg + @""">";
       }
       
       sb.Append(@"<div class=""row mt-1"">");
       sb.AppendFormat(@"<div class=""col-12 mt-1 mb-1""><strong>{0}. {1} - {2}</strong></div>", lineNumber, participantName, participantTitle);

       sb.AppendFormat(@"<div class=""col-5""><div class=""mb-1"">Name (Please Print)</div><div class=""mt-1"">{0}</div></div>", ((signed) ? signedName : emptySlot));
       sb.AppendFormat(@"<div class=""col-5""><div class=""mb-1"">Signature</div><div class=""mt-1"">{0}</div></div>", ((signed) ? (signature) : emptySlot));
       sb.AppendFormat(@"<div class=""col-2""><div class=""mb-1"">Date</div><div class=""mt-1"">{0}</div></div>", ((signed) ? (dateSigned) : emptySlot));
       sb.Append(@"</div>");
       return sb.ToString();
    }
        
    /***************************************************************************
     * generateSignaturesSectionHTML */
    /**
     *  
     *
     ***************************************************************************/
    public static string generateSignaturesSectionHTML ( 
        PlanWriterPlan                      plan
	  , List<PlanWriterPlansPatientPerson>  participants    
    )
    {
       StringBuilder sb = new StringBuilder();
       sb.AppendFormat(@"<section class=""{0}"">",CSS_CLASS_PLAN_WRITER_PAGE);
       sb.AppendFormat(@"<h2 class=""{0}"">Participants</h2>",CSS_CLASS_PLAN_WRITER_SECTION_HEADER);
    
                               
       sb.Append(@"<div class=""container"">");
       
       sb.Append(generateSignatureLine(1, "Plan Author",plan.planCreatorSignedName,plan.planCreatorSigned,plan.planCreatorSignedName, plan.planCreatorSignatureImg,plan.planCreatorSignedDate));

  
       int ln = 2;

       foreach (var person in participants)
       { 
         if (person.action == 0)
         {                             
           sb.Append(generateSignatureLine(ln,person.className2,person.name,person.signed,person.name, null, person.signedDateStr));
           ln++;
         }
       }
       sb.Append(@"</div>");
       sb.Append(@"</section>");
       return sb.ToString();
     }

    /***************************************************************************
     * generateOrderOrServiceSectionHTML */
    /**
     *  
     *
     ***************************************************************************/
    public static string generateOrderOrServiceSectionHTML ( 
          string patName
        , string patDobStr
        , string orderOrServiceName
        , string formBuilderQuestionsJSON
        , string formBuilderAnswersJSON
        , string serviceDescription
        , string lastApprovalExpirationMessage
        , string lastApprovalOrpName
        , string lastApprovalEffectiveDateStr
        , int lastApprovalExpirationState
        , bool firstSection = false)
    {
       StringBuilder sb = new StringBuilder();
       sb.AppendFormat(@"<section class=""{0} plan-writer-service"">",CSS_CLASS_PLAN_WRITER_PAGE);
       if (firstSection) 
         sb.AppendFormat(@"<h2 class=""{0}"">Services</h2>",CSS_CLASS_PLAN_WRITER_SECTION_HEADER);
       
       sb.AppendFormat(@"<h3 class=""care-plan-service-name"">{0}</h3>", orderOrServiceName);
       
       sb.AppendFormat(@"<h4 class=""care-plan-service-auth"">Service Authorization</h4>");
       
       sb.AppendFormat(@"<div class=""text-center mt-1""><strong>Service authorization as of {0} is {1}{2}{3}</strong></div>"
                      , DateTime.Today.ToShortDateString()
                      , lastApprovalExpirationMessage
                      , (!String.IsNullOrEmpty(lastApprovalOrpName) ? " - Last authorized by " + lastApprovalOrpName : @"" )
                      , (!String.IsNullOrEmpty(lastApprovalEffectiveDateStr) ? (" on " + lastApprovalEffectiveDateStr) : @"")
       );
                
       sb.Append(@"<div class=""container border mt-2 mb-2 bg-baby-blue"">");
       
       sb.Append(@"<div class=""row border border-top-0 border-left-0 border-right-0"">");
       sb.AppendFormat(@"<div class=""col-12""><h5 class=""text-center"">Service Authorization Request - {0}</h5></div>",orderOrServiceName);
       sb.Append(@"<div class=""col-12""><h5 class=""text-center"">For Ordering, Referring or Prescribing Practitioner (ORP) Use Only</h5></div>");
       sb.AppendFormat(@"<div class=""col-6""><h6 class=""text-center"">Patient Name (Last, First): {0}</h6></div>",patName);
       sb.AppendFormat(@"<div class=""col-6""><h6 class=""text-center"">Patient Date of Birth: {0}</h6></div>", patDobStr);
       sb.Append(@"</div>");

       sb.Append(@"<div class=""row mt-4"">");
       sb.AppendFormat(@"<div class=""col-6"">{0}</div>", Spedmon.ServiceAuthorizationCommon.LABEL_I_HAVE_REVIEWED_RESPONSE);       
       sb.Append(@"<div class=""col-3"">Approve this request : <input type=""checkbox"" disabled=""disabled""/></div>");
       sb.Append(@"<div class=""col-3"">Decline this request : <input type=""checkbox"" disabled=""disabled""/></div>");
       sb.Append(@"</div>");

       sb.Append(@"<div class=""row mt-2"">");
       sb.Append(@"<div class=""col-8""><span>ORP Signature</span><br/><div class=""bg-light p-4 border""> </div></div>");
       sb.Append(@"<div class=""col-4""><span>Authorization Effective Date</span><br/><div class=""bg-light p-4 border""> </div></div>");
       sb.Append(@"</div>");
       
       sb.Append(@"<div class=""row mt-1"">");
       sb.Append(@"<div class=""col-8""><span>ORP Name (Please Print)</span><br/><div class=""bg-light p-4 border""> </div></div>");
       sb.Append(@"<div class=""col-4""><span>ORP NPI #</span><br/><div class=""bg-light p-4 border""> </div></div>");
       sb.Append(@"</div>");
       
       sb.Append(@"<div class=""row mt-2"">");       
       sb.AppendFormat(@"<div class=""col-12""><em>{0}</em></div>",ORP_ATTEST_STATEMENT);
       sb.Append(@"</div>");
       
       sb.Append(@"</div>");
       sb.Append(@"</section>");
       
       sb.AppendFormat(@"<section class=""{0} plan-writer-service"">",CSS_CLASS_PLAN_WRITER_PAGE);

       sb.AppendFormat(@"<h4 class=""care-plan-service-desc"">Service Description</h4>");
                   
       if ( (!String.IsNullOrEmpty(formBuilderQuestionsJSON)) && (!String.IsNullOrEmpty(formBuilderAnswersJSON))) { 
         sb.AppendFormat(@"<textarea hidden class=""form-builder-questions"">{0}</textarea>",formBuilderQuestionsJSON);
         sb.AppendFormat(@"<textarea hidden class=""form-builder-answers"">{0}</textarea>",formBuilderAnswersJSON);
         sb.Append(@"<div class=""form-builder-section""></div>");
       } 
       else {
          sb.AppendFormat(@"<pre class=""html-to-pdf-element-replacement"">{0}</pre>",serviceDescription);
       }
       sb.Append(@"</section>");
       return sb.ToString();
    }
  }
}