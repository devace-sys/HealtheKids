using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.IO;

// PDF

using iTextSharp;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.html;

using MBA;
using System.Web;

namespace Spedmon
{

    /***************************************************************************
        * ServiceAuthorizationRequestOrResponseReturnData */
    /**
        * 
        **************************************************************************/
    public class PatientPersonPortalInviteReturnData
    {
        public List<NewUserAccount> accounts;
        public List<NotificationMessage> messages;
        public bool accountAlreadyExists;
        public string clientName;
    }

    public class PatientPersonPortalInviteClientReturnData
    {
        public bool accountAlreadyExists;
        public bool inviteEmailSent;
        public string message;
    }


    /***************************************************************************
    * PatientPersonPortalCommon*/
    /**
    * 
    **************************************************************************/
    public class PatientPersonPortalCommon
    {
        public static ReturnSaveRecordWithJSONData ExtractAndProcessReturnData(ref ReturnSaveRecordWithJSONData so, bool validateRec)
        {
            PatientPersonPortalInviteClientReturnData r2 = new PatientPersonPortalInviteClientReturnData();

            if ((!validateRec) && (so.status == Return.RET_SUCCESS))
            {
                PatientPersonPortalInviteReturnData r1 =
                    (PatientPersonPortalInviteReturnData)JSON.fromJSONString(
                        so.jsonData,
                        typeof(PatientPersonPortalInviteReturnData));

                if (r1 != null)
                {
                    if (r1.accounts != null && r1.accounts.Count > 0)
                    {
                        List<NotificationMessage> messages = new List<NotificationMessage>();

                        foreach (NewUserAccount acct in r1.accounts)
                        {
                            string displayName = String.IsNullOrWhiteSpace(acct.firstName)
                                ? "there"
                                : acct.firstName.Trim();

                            string districtName = String.IsNullOrWhiteSpace(r1.clientName)
                                ? "the secure patient portal"
                                : r1.clientName.Trim() + " secure patient portal";

                            string loginName = String.IsNullOrWhiteSpace(acct.userName)
                                ? acct.email
                                : acct.userName;

                            string pwd = String.IsNullOrWhiteSpace(acct.pwd)
                                ? ""
                                : acct.pwd;

                            string loginUrl = MBA.HttpApplication.createLink(MBA.Constants.CHANGE_MY_PASSWORD, new NameValue(Constants.PARM_CMD, Constants.CMD_LOGIN), new NameValue(Constants.PARM_UID, acct.userName), new NameValue(Constants.PARM_PWD, acct.pwd));

                            NotificationMessage msg = new NotificationMessage();
                            msg.forEmail = acct.email;
                            msg.msgTitle = "You’ve Been Invited to Access the Secure Patient Portal";
                            msg.msgIsHTML = true;

                            msg.msgBody =
                                  "<html><body style=\"font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#222;line-height:1.5;\">"
                                + "<p>Hello <b>" + HttpUtility.HtmlEncode(displayName) + ",</b></p>"
                                + "<p>You have been invited to create an account for the <b>" + HttpUtility.HtmlEncode(districtName) + "</b> secure patient portal.</p>"
                                + "<p>This portal gives you convenient online access to important information and actions related to school-based health and support services. Depending on your role and permissions, you may be able to:</p>"
                                + "<ul>"
                                + "<li>View messages and requests</li>"
                                + "<li>Complete forms and authorizations</li>"
                                + "<li>Review referrals, notices, or service-related information</li>"
                                + "<li>Access available portal features and updates</li>"
                                + "</ul>"
                                + "<p>Your account has been created for you. Use the information below to sign in and get started:</p>"
                                + "<table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"margin:12px 0 16px 0;\">"
                                + "<tr><td><strong>Username:</strong></td><td style=\"padding-left:8px;\">" + HttpUtility.HtmlEncode(loginName) + "</td></tr>"
                                + "<tr><td><strong>Temporary Password:</strong></td><td style=\"padding-left:8px;\">" + HttpUtility.HtmlEncode(pwd) + "</td></tr>"
                                + "</table>"
                                + "<p>To get started, please click the secure link below and follow the instructions to set up your account:</p>"
                                + "<table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"margin:16px 0;\">"
                                + "<tr>"
                                + "<td align=\"center\" bgcolor=\"#2563eb\" style=\"border-radius:6px;padding:10px\">"
                                + "<a href=\"" + HttpUtility.HtmlAttributeEncode(loginUrl) + "\" "
                                + "style=\"display:inline-block;padding:12px 20px;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:bold;color:#ffffff;text-decoration:none;border-radius:6px;background:#2563eb;\">"
                                + "Create My Account / Accept Invitation"
                                + "</a>"
                                + "</td>"
                                + "</tr>"
                                + "</table>"
                                + "<p>This account setup is a one-time process. After your account is created, you can return to the portal at any time using your login credentials.</p>"
                                + "<p>If you were expecting a specific request, form, or authorization, it will be available in the portal after you complete your account setup.</p>"
                                /*+ "<p>If you need help setting up your account or have questions, please contact: </p>"*/
                                + "<p><b>Thank you,</b></p>"
                                + "</body></html>";

                            messages.Add(msg);
                        }

                        NotificationMessages.emailNotificationMessages(messages);

                        r2.inviteEmailSent = true;
                        r2.accountAlreadyExists = false;
                        r2.message = "Portal invitation email sent successfully.";
                    }
                    else
                    {
                        r2.inviteEmailSent = false;
                        r2.accountAlreadyExists = true;
                        r2.message = "This parent/guardian already has a portal account.";
                    }

                    if (r1.messages != null && r1.messages.Count > 0)
                    {
                        NotificationMessages.emailNotificationMessages(r1.messages);
                    }
                }
            }

            so.jsonData = JSON.toJSONString(r2);
            return so;
        }
    }
}
