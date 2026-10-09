using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;

using MBA.Reporting;
using Ical.Net;
using Ical.Net.DataTypes;
//using Ical.Net.Serialization.iCalendar.Serializers;
using Ical.Net.Serialization;

using System.Net.Mime;

using System.Text.RegularExpressions;
//using System.Linq;

namespace MBA
{  
  
  /***************************************************************************
   * Email */
  /**
   * Our base class for email communication
   * 
   ****************************************************************************/

  public class Email
  {        
    
    public static char[] COMMON_EMAIL_DELIMITERS = new char[]{';',','};
    
    /***************************************************************************
     * sendMail */
    /**
     * Send a simple mail message.
     * 
     * @param    host     SMTP host (default is localhost)
     * @param    port     SMTP port (default is 25)
     * @param    from     Send from email address
     * @param    to       Send to email address
     * @param    subject  Subject of messsage
     * @param    body     Body of message
     ***************************************************************************/  
    
    public static bool sendMail(string to, string subject, string body, bool isHTML,  out string retStatus)
    {
      return sendMail(Constants.APP_EMAIL_FROM, to, subject, body, isHTML, out retStatus);
    }

    public static bool sendMail(string from, string to, string subject, string body, bool isHTML,  out string retStatus)
    {
      return sendMail(Constants.APP_SMTP_HOST, Constants.APP_SMTP_PORT, from,to,subject,body, isHTML, out retStatus);
    }

    public static string defaultEmailHTMLBody(string subject_txt, string body_txt)
    {

            StringBuilder sb = new StringBuilder();

            sb.AppendLine(@"<!doctype html>");
            sb.AppendLine(@"<html>");
            sb.AppendLine(@"<head>");    // TODO: are there any email clients where <head><title> is actually honored, rather than the email Subject header?
            sb.AppendLine(@"<title>");   // Could the <head></head> possibly be removed completely?
            sb.AppendLine(subject_txt);
            sb.AppendLine(@"</title>");
            sb.AppendLine(@"</head>");
            sb.AppendLine(@"<body>");
            sb.AppendLine(@"<div>");
            sb.AppendLine(body_txt);
            sb.AppendLine(@"</div>");
            sb.AppendLine(@"<br/>");
            sb.AppendLine(@"<hr/>");
            sb.AppendLine(@"<div>");
            sb.AppendLine(@"<em style=""font-style:italic;color:red;"">");  // the font-size style attribute badly breaks in Outlook when we are using an Html AlternateView in multi-part/mixed
            sb.AppendLine(Messages.CONFIDENTIAL_EMAIL);
            sb.AppendLine(@"</em>");
            sb.AppendLine(@"</div>");
            sb.AppendLine(@"</body>");
            sb.AppendLine(@"</html>");

            return sb.ToString();

    }

    public static bool sendMail(   string host
                                 , int    port
                                 , string from
                                 , string to
                                 , string subject
                                 , string body
                                 , bool   isHTML
                                 , out string retStatus )
    {
      bool retState = true;
      retStatus     = "";
      
      //TODO: HARDCODING TEST EMAIL DESTINATION
      //      REMOVE BEFORE DEPLOY

      // to = "jmiles@help4schools.com";
      
      MailMessage m = null;
      
      m = new MailMessage(from, to, subject, body);  
      m.IsBodyHtml = isHTML;      
      
      SmtpClient c = new SmtpClient (host, port);
      
      try
      {
        c.Send(m);
        retState = true;
      }
      catch (SmtpFailedRecipientException e)
      {
        retStatus = e.Message;
        retState = false;
      }
      catch (Exception e)
      {
        retStatus = e.Message;
        retState = false;
      }
      finally
      {
        m.Dispose();
      }
      return retState;
      
    }



    public static MailMessage prepareMailMessage(string from, string to, string cc, string bcc, string fileName, ref byte[] fileBytes, string subject, string prepared_body, ref MemoryStream ms ) { 

            /*----------------------------
             * Parse to, cc, and bcc
             *----------------------------*/

            string[] emailsTo = parseEmailString(to);
            string[] emailsCC = parseEmailString(cc);
            string[] emailsBCC = parseEmailString(bcc);

            /*----------------------------
             * Create attachment
             *----------------------------*/

            System.Net.Mail.Attachment fa;
            if (fileBytes != null)
            {
                ms = new MemoryStream(fileBytes);
            }


            /*----------------------------
             * Create mail message
             *----------------------------*/

            MailMessage mm = new MailMessage();

            mm.BodyEncoding = System.Text.Encoding.UTF8;
            mm.SubjectEncoding = System.Text.Encoding.UTF8;
            mm.IsBodyHtml = true;

            /*----------------------------
             * Attach file
             *----------------------------*/
            if (fileBytes != null)
            {
                fa = new System.Net.Mail.Attachment(ms, fileName);
                mm.Attachments.Add(fa);
            }

            /*----------------------------
             * From and subject
             *----------------------------*/

            mm.From = new MailAddress(from);
            mm.Subject = subject;

            /*----------------------------
             * To
             *----------------------------*/

            if (emailsTo != null)
            {
                foreach (string email in emailsTo)
                {
                    mm.To.Add(email);
                }
            }

            /*----------------------------
             * CC
             *----------------------------*/

            if (emailsCC != null)
            {
                foreach (string email in emailsCC)
                {
                    mm.CC.Add(email);
                }
            }

            /*----------------------------
             * BCC
             *----------------------------*/

            if (emailsBCC != null)
            {
                foreach (string email in emailsBCC)
                {
                    mm.Bcc.Add(email);
                }
            }

            mm.Body = prepared_body;

            return mm;
        }

    public static bool sendMail(string host, 
                                int port, 
                                string from, 
                                string to, 
                                string cc,
                                string bcc, 
                                string fileName, 
                                ref byte[] fileBytes, 
                                string subject, 
                                string body)  //TODO: maybe this sendMail() method should have an OUT string retStatus, like the others?
    {
      
      bool retState = true;
      
      MemoryStream ms = new MemoryStream();
      
            // TODO: HARDCODING EMAIL TEST DESTINATION
            //       REMOVE BEFORE GOING LIVE

            // to = "jmiles@help4schools.com";
      
      try
      {

        MailMessage mm = prepareMailMessage(from, to, cc, bcc, fileName, ref fileBytes, subject, Email.defaultEmailHTMLBody(subject, body), ref ms);

        new SmtpClient(host,port).Send(mm);
        retState = true;                                                                                                                      
     }
     catch (Exception e)
     {
       throw(e);
     }
     finally     
     {
       ms.Dispose();
     }
     
     return retState;
     
    }
        
    /***************************************************************************
     * parseEmailString */
    /**
     * Parses a delimited string of emails
     * 
     * @param    emails   Delimited string of emails
     ***************************************************************************/  

    public static string[] parseEmailString (string emails)
    {    
      return parseEmailString(emails, COMMON_EMAIL_DELIMITERS);
    }
    
    public static string[] parseEmailString (string emails, char[] delimiters)
    {
      string[] emailsout = null;
      emailsout = emails.Split(delimiters,StringSplitOptions.RemoveEmptyEntries);                            
      return emailsout;   
    }

    public static byte[] genIcalAttachment(string from, string to, InvitableContent content)
    {
      // see https://esausilva.com/2016/11/17/create-ical-ics-files-in-c-asp-net-mvc-several-methods/
      var calendar = new Ical.Net.Calendar();
      calendar.Method = "REQUEST";
      var e = new Ical.Net.CalendarComponents.CalendarEvent();
      e.Class = "PUBLIC"; 
      e.Summary = content.title;
      e.Description = content.description_body;

      e.Created = new CalDateTime(Convert.ToDateTime(content.created_date));
      e.Start   = new CalDateTime(Convert.ToDateTime(content.attend_date));
      e.End     = new CalDateTime(Convert.ToDateTime(content.session_end));

      //e.IsAllDay      = true;  // TODO: add an end-time into the CanBeInvitableContent interface
      

      calendar.Events.Add(e);
      return Encoding.UTF8.GetBytes(
        new CalendarSerializer(new SerializationContext()).SerializeToString(calendar)
      );
      //calendar.Events.Add(new Ical.Net.DataTypes.Event())
    }

    private static string generateHtmlContentWithHeroImage60pct (
                                                              //long msgId,
                                                                // to implement the openmsgmodal URL param in a future release

                                                              bool promptUserToGotoURL,

                                                              string gotoURL,
                                                              string gotoURLAdditionalParams,

                                                              string recipientUserName,
                                                              string custom_msgbody ,
                                                              string subject,
                                                              string subtitle,
                                                              string hero_img_cid,
                                                              string body,

                                                              int respPromptOptionsBitwise,  // TODO: Viz Studio says these two params aren't being used.  Are they needed?
                                                              string respPromptOptionsJSON                                                             
                                                           )
    {

       var css_class_dot_prefx = MBA.Constants.DOT_PREFIX_CSS_CLASSNAME_EMAIL_60PCT;
       var css_class_prefx = MBA.Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT;
       
       StringBuilder sbMkup = new StringBuilder();
       sbMkup.Append(@"<html xmlns=""http://www.w3.org/1999/xhtml"">");
       sbMkup.Append(@"<head>");
	   sbMkup.Append(@"<meta http-equiv=""content-type"" content=""text/html; charset=utf-8"">");
       sbMkup.Append(@"<meta name=""viewport"" content=""width=device-width, initial-scale=1.0;"">");

       
       sbMkup.Append(@"<meta name=""format-detection"" content=""telephone=no"">");
       sbMkup.Append(@"<style>");
       
       sbMkup.Append(css_class_dot_prefx + @"body, " + css_class_dot_prefx + @"table, " + css_class_dot_prefx + @"td, " + css_class_dot_prefx + @"div, " + css_class_dot_prefx + @"p, " + css_class_dot_prefx + @"a {" +
           @"-webkit-font-smoothing: antialiased; text-size-adjust: 100%; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; line-height: 100%; }");
       sbMkup.Append(css_class_dot_prefx + @"table, " + css_class_dot_prefx + @"td {" +
           @"mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-collapse: collapse; border-spacing: 0; }");
                                                           
       sbMkup.Append(css_class_dot_prefx + @"img { border: 0; line-height: 100%; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; }");

       sbMkup.Append(@"#outlook a { padding: 0; }");  // id outlook not used anywhere here in code; is it auto-added somewhere (somehow) by outlook?

       // classes ReadMsgBody and ExternalClass not used anywhere here in code
       //sbMkup.Append(@".ReadMsgBody { width: 100%; } .ExternalClass { width: 100%; }");
       //sbMkup.Append(@".ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div { line-height: 100%; }");

       //class .floater not used

       //sbMkup.Append(@"@media all and (max-width: 600px) {");
	   //sbMkup.Append(@".floater { width: 320px; }");
       //sbMkup.Append(@"}");
       
       /*  https://jennamolby.com/6-tips-on-developing-html-emails-for-the-iphone/  */
 	   
       sbMkup.Append(@"@media screen and (min-device-width: 320px) and (max-device-width: 480px) and (-webkit-min-device-pixel-ratio: 1) {");
       sbMkup.Append(@"#top-heroimg-td {");
       sbMkup.Append(@"max-height: 40vh;");
       sbMkup.Append(@"}");
       sbMkup.Append(@"}");
       sbMkup.Append(@"@media screen and (min-device-width: 320px) and (max-device-width: 568px) and (-webkit-min-device-pixel-ratio: 2) {");
       sbMkup.Append(@"#top-heroimg-td {");
       sbMkup.Append(@"max-height: 30vh;");
       sbMkup.Append(@"}");
       sbMkup.Append(@"}");

       sbMkup.Append(@"#msg-body {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"min-width: 100%; "
                     + @"width: 100%; "
                     + @"height: 100%; "
                     + @"-webkit-font-smoothing: antialiased; "
                     + @"text-size-adjust: 100%; "
                     + @"-ms-text-size-adjust: 100%; "
                     + @"-webkit-text-size-adjust: 100%; "
                     + @"line-height: 100%; "
                     + @"background-color: #FFFFFF; "
                     + @"color: #000000;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#top-heroimg-outerwrap-table {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"width: 100%"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#top-heroimg-outerwrap-td {");
       sbMkup.Append(  @"border-collapse: collapse; "
                    + @"border-spacing: 0; "
                    + @"margin: 0; "
                    + @"padding: 0; "
                    + @"background-color: #fdfdfd;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#top-heroimg-innerwrap-table {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"padding: 0; "
                     + @"width: inherit; "
                     + @"max-width: 600px; "
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#top-heroimg-innerwrap-td {");
       sbMkup.Append(  @"padding-top: 20px; "
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#top-heroimg {");
       sbMkup.Append(  @"-ms-interpolation-mode: bicubic; "
                     + @"width: 60%; "
                     + @"object-fit: scale-down;"
                         );
       sbMkup.Append(@"}");


       sbMkup.Append(@"#td-custom-prepended-msg {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"width: 100%; "
                     + @"color:#000; "
                     + @"font-size: 19px; "
                     + @"font-weight: 400; "
                     + @"line-height: 150%; "
                     + @"padding-top: 20px; "
                     + @"padding-bottom: 20px; "
                     + @"color: #9A9A9A; "
                     + @"font-family: sans-serif; "
                     + @"background-color: white;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#td-wrapper-table-subject {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"padding-left: 6.25%; "
                     + @"padding-right: 6.25%; "
                     + @"width: 87.5%; "
                     + @"font-size: 15px; "
                     + @"font-weight: 400; "
                     + @"line-height: 150%; "
                     + @"padding-top: 20px; "
                     + @"padding-bottom: 20px; "
                     + @"color: #999999; "
                     + @"font-family: sans-serif; "
                     + @"background-color: white;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#tr-outer-wrapper-table-msgbody {");
       sbMkup.Append(  @"background-color: #FFF; "
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#td-outer-wrapper-table-msgbody {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     /*+ @"padding-left: 6.25%; "
                     + @"padding-right: 6.25%;"*/
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#inner-wrapper-table-msgbody {");
       sbMkup.Append(  @"width: inherit; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"border-collapse: collapse; "
                     + @"border-spacing: 0;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#td-donotreply {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"padding-left: 6.25%; "
                     + @"padding-right: 6.25%; "
                     + @"width: 87.5%; "
                     + @"font-size: 17px; "
                     + @"font-weight: 400; "
                     + @"line-height: 160%; "
                     + @"padding-top: 25px; "
                     + @"color: #555; "
                     + @"font-family: sans-serif;"
                         );
       sbMkup.Append(@"}");


       sbMkup.Append(@"#td-wrapper-outer-a-signin {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"padding-left: 6.25%; "
                     + @"padding-right: 6.25%; "
                     + @"width: 87.5%; "
                     + @"padding-top: 25px; "
                     + @"padding-bottom: 35px;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#outer-a-signin {");
       sbMkup.Append(  @"text-decoration: underline;");
       sbMkup.Append(@"}");


       sbMkup.Append(@"#table-wrapper-inner-a-signin {");
       sbMkup.Append(  @"max-width: 240px; "
                     + @"min-width: 120px; "
                     + @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"padding: 0;"
                         );
       sbMkup.Append(@"}");


       sbMkup.Append(@"#td-wrapper-inner-a-signin {");
       sbMkup.Append(  @"padding: 12px 24px; "
                     + @"margin: 0; "
                     + @"text-decoration: underline; "
                     + @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"border-radius: 4px; "
                     + @"background: linear-gradient(180deg, rgb(157 238 246) 0%, rgba(117,183,177,1) 18%, rgba(117,183,177,1) 88%); "
                     + @"-webkit-border-radius: 4px; -moz-border-radius: 4px; -khtml-border-radius: 4px;"
                         );
       sbMkup.Append(@"}");


       sbMkup.Append(@"#inner-a-signin {");
       sbMkup.Append(  @"text-decoration: underline; "
                     + @"color: #FFFFFF; "
                     + @"font-family: sans-serif; "
                     + @"font-size: 17px; "
                     + @"font-weight: 400; "
                     + @"line-height: 120%;"
                         );
       sbMkup.Append(@"}");


       sbMkup.Append(@"#td-bgf0f0f0 {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#wrapper-table-confidential-notice {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"padding: 0; "
                     + @"width: inherit; "
                     + @"max-width: 600px;"
                         );
       sbMkup.Append(@"}");

       sbMkup.Append(@"#td-confidential-notice {");
       sbMkup.Append(  @"border-collapse: collapse; "
                     + @"border-spacing: 0; "
                     + @"margin: 0; "
                     + @"padding: 0; "
                     + @"padding-left: 6.25%; "
                     + @"padding-right: 6.25%; "
                     + @"width: 87.5%; "
                     + @"font-size: 13px; "
                     + @"font-weight: 400; "
                     + @"line-height: 150%; "
                     + @"padding-top: 20px; "
                     + @"padding-bottom: 20px; "
                     + @"color: #999999; "
                     + @"font-family: sans-serif;"
                         );
       sbMkup.Append(@"}");


       sbMkup.Append(@"@media screen and (max-device-width: 414px) and (max-device-height: 776px) {");
	   sbMkup.Append(@"#top-heroimg-td {");
       sbMkup.Append(@"max-height: 20vh;");
       sbMkup.Append(@"}");
       sbMkup.Append(@"}");
       sbMkup.Append(css_class_dot_prefx + @"a, " + css_class_dot_prefx  + @"a:hover {");
	   sbMkup.Append(@"color: #127DB3;");
       sbMkup.Append(@"}");

                      // not really necessary to replace these <a> rules with .classprefix-a rules, since they are already inside of the .footer div
       sbMkup.Append(@".footer a, .footer a:hover {");
       sbMkup.Append(@"color: #999999;");
       sbMkup.Append(@"}");
 	   sbMkup.Append(@"</style>");
	   sbMkup.Append(@"<title>");
       sbMkup.Append(subject);
       sbMkup.Append(@"</title>");
       sbMkup.Append(@"</head>");

       sbMkup.Append(@"<body id=""msg-body"" "
                         + @"class=""" + css_class_prefx + @"body"" "
                         + @"topmargin =""0"" "
                         + @"rightmargin=""0"" "
                         + @"bottommargin =""0"" "
                         + @"leftmargin=""0"" "
                         + @"marginwidth =""0"" "
                         + @"marginheight=""0"" "
                         + @"width =""100%"" "
                         + @"bgcolor=""#FFFFFF"" "
                         + @"text =""#000000"">"); 

       sbMkup.Append(@"<table id=""top-heroimg-outerwrap-table"" "
                          + @"width=""100%"" "
                          + @"align =""center"" "
                          + @"border=""0"" "
                          + @"cellpadding =""0"" "
                          + @"cellspacing=""0"" "
                          + @"class=""" + css_class_prefx + @"table background"">"  // .background rules not defined in stylesheet

                                + @"<tbody  class=""" + css_class_prefx + @"tbody"">"

                                  + @"<tr  class=""" + css_class_prefx + @"tr"">"

                                    + @"<td id=""top-heroimg-outerwrap-td"" "
                                      + @"align=""center"" "
                                      + @"valign=""top"" "
                                      + @"class=""" + css_class_prefx + @"td"" >"
                                      );

       sbMkup.Append(                     @"<table id=""top-heroimg-innerwrap-table""
                                               border=""0""
                                               cellpadding=""0""
                                               cellspacing=""0""
                                               align=""center""
                                               width=""600""
                                               class=""" + css_class_prefx + @"table wrapper"">");  // .wrapper rules not defined in stylesheet

       sbMkup.Append(                           @"<tbody class=""" + css_class_prefx + @"tbody"" >");
       
                                                  /* Hero Image */
       
       sbMkup.Append(                             @"<tr class=""" + css_class_prefx + @"tr"" >");

	   sbMkup.Append(                                 @"<td  id=""top-heroimg-innerwrap-td"" "
                                                         + @"align=""center"" "
                                                         + @"valign =""top"" "
                                                         + @"width=""600"" "
                                                         + @"class=""" + css_class_prefx + @"td header"" >"
                                                         );

       sbMkup.Append(                                     @"<img   id=""top-heroimg"" "
                                                               + @"class=""" + css_class_prefx + @"img"" "
                                                               + @"border=""0"" "
                                                               + @"vspace=""0"" "
                                                               + @"hspace=""0"" "
                                                               + @"src=""cid:" + hero_img_cid + @""" "
                                                               + @"alt=""" + subject + @""" "
                                                               + @"title=""" + subject + @""" "
                                                               + @"height=""180"" >"
                                                               );


       sbMkup.Append                                  (@"</td>");

	   sbMkup.Append(                             @"</tr>");

	   sbMkup.Append(                             @"<tr class=""" + css_class_prefx + @"tr"" ></tr>");

       /*  custom message body */

       if ( !String.IsNullOrEmpty(custom_msgbody)  &&  !String.IsNullOrWhiteSpace(custom_msgbody) )
       {

         sbMkup.Append(                           @"<tr  class=""" + css_class_prefx + @"tr"" >");

         sbMkup.Append(                               @"<td    id=""td-custom-prepended-msg"" "
                                                           + @"align=""center"" "
                                                           + @"valign =""top"" "
                                                           + @"class=""" + css_class_prefx + @"td footer"" >"
                                                           );

           // just realized we are using class footer for headers

         sbMkup.Append(                 Util.textToHTMLStickyNote(custom_msgbody));

         sbMkup.Append(                               @"</td>");

	     sbMkup.Append(                           @"</tr>");

        }
       
       /* Subtitle */

       sbMkup.Append(                             @"<tr  class=""" + css_class_prefx + @"tr"" >");

       sbMkup.Append(                                 @"<td    id=""td-wrapper-table-subject"" "
                                                           + @"align=""center"" "
                                                           + @"valign=""top"" "
                                                           + @"class=""" + css_class_prefx + @"td footer"">"

                                                               + @"<h2  class=""" + css_class_prefx + @"h2"" >" + subject + @"</h2>"
                                                               );

       if (!String.IsNullOrWhiteSpace(subtitle)) { 

         sbMkup.Append(                                            @"<h3  class=""" + css_class_prefx + @"h3"" >");
         sbMkup.Append(                                              subtitle);
         sbMkup.Append(                                            @"</h3>");

       }

       sbMkup.Append(                                 @"</td>");
	   sbMkup.Append(                             @"</tr>");
       
       /* Email Body */
       
       sbMkup.Append(                             @"<tr id=""tr-outer-wrapper-table-msgbody"" "
                                                    + @"class=""" + css_class_prefx + @"tr"" >"
                                                        );

	   sbMkup.Append(                                 @"<td   id=""td-outer-wrapper-table-msgbody"" "
                                                          + @"valign=""top"" "
                                                          + @"class=""" + css_class_prefx + @"td"">"

                                                       + @"<table      id=""inner-wrapper-table-msgbody"" "
                                                                   + @"align=""center"" "
                                                                   + @"border=""0"" "
                                                                   + @"cellspacing=""0"" "
                                                                   + @"cellpadding=""0"" "
                                                                   + @"class=""" + css_class_prefx + @"table"">"
                                                                   );

	   sbMkup.Append(                                           @"<tbody class=""" + css_class_prefx + @"tbody""  >");

       sbMkup.Append(                                             body);

       sbMkup.Append(                                           @"</tbody></table></td></tr>");

       /* No Reply */

	   sbMkup.Append(  @"<tr class=""" + css_class_prefx + @"tr"">");

	   sbMkup.Append(    @"<td    id=""td-donotreply"" "
                              + @"align=""center"" "
                              + @"valign=""top"" "
                              + @"class=""" + css_class_prefx + @"td paragraph"">"
                              );

       //
       sbMkup.Append(              @"<p  class=""" + css_class_prefx + @"p"">");
       sbMkup.Append(                  Messages.DO_NOT_REPLY);
       sbMkup.Append(              @"</p>");

       sbMkup.Append(@"</td>");
       sbMkup.Append(@"</tr>");

       /* Sign In */

       var sign_in_and_redirect_url = @"";
       
       if (promptUserToGotoURL) { 

         if (!String.IsNullOrWhiteSpace(gotoURL))
         { 
           sign_in_and_redirect_url = Credential.generateDirectLoginToPageLink( recipientUserName, gotoURL);
         
         if ( !(Util.IsNullOrEmpty(gotoURLAdditionalParams)))
           sign_in_and_redirect_url += "&" + gotoURLAdditionalParams ;
         }
         else
         {
           sign_in_and_redirect_url = @"https://spedcare.com";  // maybe use a constant somewhere
         }
       }
       else { 

         sign_in_and_redirect_url = @"https://spedcare.com";  // maybe use a constant somewhere

         if ( !(Util.IsNullOrEmpty(gotoURLAdditionalParams)))
           sign_in_and_redirect_url += "?" + gotoURLAdditionalParams ;
       }
       

	   sbMkup.Append(  @"<tr class=""" + css_class_prefx + @"tr"" >");

	       sbMkup.Append( @"<td   id=""td-wrapper-outer-a-signin"" "
                              + @"align=""center"" "
                              + @"valign =""top"" "
                              + @"class=""" + css_class_prefx + @"td button"">"
                              );

       sbMkup.Append(         @"<a      id=""outer-a-signin"" "
                                    + @"class=""" + css_class_prefx + @"a"" "
                                    + @"href=""" + sign_in_and_redirect_url + @""" >"
                                    );  //TODO: idk where the closing </a> is... maybe buggy here

	   sbMkup.Append(         @"<table     id=""table-wrapper-inner-a-signin"" "
                                       + @"class=""" + css_class_prefx + @"table"" "
                                       + @"border=""0"" "
                                       + @"cellpadding=""0"" "
                                       + @"cellspacing=""0"" "
                                       + @"align=""center"" >"

                                     + @"<tbody class=""" + css_class_prefx + @"tbody"" >"
                                         + @"<tr class=""" + css_class_prefx + @"tr"" >"

                                             + @"<td    id=""td-wrapper-inner-a-signin"" "
                                                    + @"class=""" + css_class_prefx + @"td"" "
                                                    + @"align=""center"" "
                                                    + @"valign=""middle"" "
                                                    + @"bgcolor=""#75b7b1"">"

                                               + @"<a  id=""inner-a-signin"" "
                                                   + @"class=""" + css_class_prefx + @"a"" "
                                                   + @"href=""" + sign_in_and_redirect_url + @""">Sign In</a>"

                            + @"</td></tr></tbody></table>"
                                // ??? can an entire <table> be placed inside of <a></a> ??  Is that valid?  mind blown
                                + @"</a> "
                            + @"</td></tr></tbody></table>");

       sbMkup.Append(    @"</td>");
       sbMkup.Append(  @"</tr>");

	   sbMkup.Append(  @"<tr class=""" + css_class_prefx + @"tr"" >"

                      + @"<td id=""td-bgf0f0f0"" "
                          + @"align=""center"" "
                          + @"valign =""top"" "
                          + @"class=""" + css_class_prefx + @"td"" "
                          + @"bgcolor =""#F0F0F0"">"

                   + @"</td></tr>"
                   );

       sbMkup.Append(@"</tbody>");
       sbMkup.Append(@"</table>");

       /* Confidential email */

       sbMkup.Append(@"<table id=""wrapper-table-confidential-notice"" "
                          + @"border =""0"" "
                          + @"cellpadding=""0"" "
                          + @"cellspacing =""0"" "
                          + @"align=""center"" "
                          + @"width =""600"" "
                          + @"class=""" + css_class_prefx + @"table wrapper"">"
                          );


	   sbMkup.Append(    @"<tbody class=""" + css_class_prefx + @"tbody"" >");
	   sbMkup.Append(        @"<tr class=""" + css_class_prefx + @"tr"">");

	   sbMkup.Append(          @"<td    id=""td-confidential-notice"" "
                                    + @"align=""center"" "
                                    + @"valign =""top"" "
                                    + @"class=""" + css_class_prefx + @"td footer"">"
                                    );


       sbMkup.Append(              Messages.CONFIDENTIAL_EMAIL);

	   sbMkup.Append(@"</td>");
	   sbMkup.Append(@"</tr>");
       sbMkup.Append(@"</tbody>");
       sbMkup.Append(@"</table>");
       sbMkup.Append(@"</body>");
       sbMkup.Append(@"</html>");

       return sbMkup.ToString();

    }

    public static bool SendInvitation(string from, string to, string subject, string body, bool isHTML, bool ICS_invitation, InvitableContent content, out string retStatus){
      if (!(ICS_invitation)) return Email.sendMail(
        from,
        to,
        subject,
        body,
        isHTML,
        out retStatus
      );
      else {

        retStatus = null;
        string html = Email.defaultEmailHTMLBody(subject, body);
        byte[] attached = genIcalAttachment(from, to, content);

        MemoryStream memstream_ical_inline = new MemoryStream();

        MailMessage mm = Email.prepareMailMessage(from, to, "", "", "invite.ics", ref attached, subject, html, ref memstream_ical_inline);

        //These are a couple possibly usable implementations


        ContentType contenttype_html = new System.Net.Mime.ContentType("text/html");  // https://docs.microsoft.com/en-us/dotnet/api/system.net.mail.mailmessage.alternateviews
        AlternateView htmlview = AlternateView.CreateAlternateViewFromString(mm.Body,contenttype_html);
        mm.Body = "";     

        ContentType contenttype_cal = new System.Net.Mime.ContentType("text/calendar");  // https://docs.microsoft.com/en-us/dotnet/api/system.net.mail.mailmessage.alternateviews
        //MemoryStream memstream_ical_att = new MemoryStream();
        //memstream_ical_inline.Position = 0;
        //memstream_ical_inline.CopyTo(memstream_ical_att);
        //memstream_ical_inline.Position = 0;
        //memstream_ical_att.Position = 0;

        
        AlternateView icalview = new AlternateView(memstream_ical_inline, contenttype_cal);

        mm.AlternateViews.Clear();
        mm.AlternateViews.Add(htmlview);
        mm.AlternateViews.Add(icalview);

        mm.Attachments.Clear();  // using the ICS AlternateView makes the attachment 0 bytes; we might need to clone a copy of the MemoryStream if we want to do both

                //TODO: attaching HTML onto the email breaks the iCal invite behavior in Outlook.  Attaching the iCal file as well, and sending it first and making it inline, doesn't help.

                //System.Net.Mail.Attachment ical_att = new System.Net.Mail.Attachment(memstream_ical_att, "invite.ics");
                //mm.Attachments.Add(ical_att);
                //mm.Attachments.First().ContentDisposition.Inline = true;  // https://stackoverflow.com/a/14127770 

                //HTML content as additional attachment
                //MemoryStream ms_fa2 = new MemoryStream(Encoding.UTF8.GetBytes(html));  // not sure if this is the correct or best character encoding we should be using in every case
                //System.Net.Mail.Attachment fa2 = new System.Net.Mail.Attachment(ms_fa2, "message.html");
                //mm.Attachments.Add(fa2);

        new SmtpClient(
          Constants.APP_SMTP_HOST,
          Constants.APP_SMTP_PORT
          ).Send(mm);

        return true;

      }
    }


    /***************************************************************************
    * generateHtmlContentWithHeroImageAndImageList */
    /**
    * Creates responsive HTML content that contains a hero image and a <ul><li> HTML list;
    * each list entry has a thumbnail image.
    *
    * @param list_of_descr_objects A list of Objects that implement the ListItemWImage interface
    * @param subject the email; subject; also used in the HTML in an <h2>
    * @param subtitle string; content placed in an HTML <h3>
    * @param hero_img_cid string; the src attribute of the hero image (must be embedded)
    * @param default_list_item_img_cid string; the default src attribute of the rendered images, 1 per list item in the HTML list.  Must be an embedded image
    * @return string the HTML content of the email
    ***************************************************************************/
    private static string generateHtmlContentWithHeroImage60pctAndImageList (
          //long msgId,
          // to implement the openmsgmodal URL param in a future release


          bool promptUserToGotoURL

        , string gotoURL
     // , string gotoURLAdditionalParams

        , string recipientUserName

        , IEnumerable<Object> list_of_desc_objs
        , string subject
        , string subtitle
        , string hero_img_cid
        , string default_list_item_img_cid)
    {

        // TODO: this method also may eventually need the CSS redone, but it is a much lower priority because we aren't passing in any pre-styled HTML.

        string inner_bodycontent = "";

        foreach (ListItemWImage desc_obj in list_of_desc_objs)
        {
            /* Wrap each item in tr and td so its compatible with Email.generateHtmlContentWithHeroImage60pct */
            

            inner_bodycontent += @"<tr  class=""" + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"tr"" >" +
				       @"<td   align=""left"" "
                        +   @"valign=""top"" "
                        +   @"class=""" + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"td"" "
                        +   @"style=""border-collapse: collapse; "
                                  + @"border-spacing: 0; "
					              + @"padding-top: 30px; "
					              + @"padding-right: 20px;"">"
                                  +   @"<img   border=""0"" " 
                        +                   @" vspace=""0"" "
                        +                   @" hspace=""0"" "
                        +                            @"style=""padding: 0; "
                        +                                    @"margin: 0; "
                        +                                    @"outline: none; "
                        +                                    @"text-decoration: none; "
                        +                                    @"-ms-interpolation-mode: bicubic; "
                        +                                    @"border: none; "
                        +                                    @"display: block; "
 					    +                                    @"color: #000000;""  "
                        +                  @" src=""cid:" +
                                                         ( desc_obj.imgSrc != null ?
                                                                                   desc_obj.imgSrc :
                                                                                   default_list_item_img_cid
                                                         ) + @"""  "
                        +                  @" alt=""" + desc_obj.title + '"' 
                        +                  @" title=""" + desc_obj.title + '"'
                        +                  @" width=""50"" height=""50"">"
                 +    @"</td>"
                 +    @"<td     align=""left"" "
                        +     @"valign=""top"" "
                        +     @"class=""" + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"td"" "
                        +               @"  style=""font-size: 17px; "
                        +                         @"font-weight: 400; "
                        +                         @"line-height: 160%; "
                        +                         @"border-collapse: collapse; "
                        +                         @"border-spacing: 0; "
                        +                         @"margin: 0; "
                        +                         @"padding: 0; "
                        +					      @"padding-top: 25px; "
					    +                         @"color: #000000; "
                        +                         @"font-family: sans-serif;"" "
                        +     @"class=""paragraph  " + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"p"">"
						+           @"<b class=""" + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"b"" style=""color: #333333;"">" 
                        +                 desc_obj.title + "</b><br>" + desc_obj.description
                        +           @"<br/>"
                        +           (desc_obj.finePrint != null    ?
                                                                     @"<span class=""" + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"span"" style=""color:#999"">" + desc_obj.finePrint + @"</span>"
                                                                   : ""
                                    )
				        + "</td></tr>";

        }


        return generateHtmlContentWithHeroImage60pct(

            //msgid,

            promptUserToGotoURL, gotoURL, "", //gotoURLAdditionalParams
            recipientUserName,
            "",
            subject,subtitle,hero_img_cid,inner_bodycontent,

            0 /* respPromptOptionsBitwise */, null
        );


   }

    /***************************************************************************
    * sendMessageHtmlWithHeroImage
    */
    /**
    * Creates and send a responsive HTML email message that contains a hero image and a <ul><li> HTML list;
    * each list entry has a thumbnail image.
    *
    * @param list_of_descr_objects A list of Objects that implement the ListItemWImage interface
    * @param to string; to destination email address
    * @param from string; the sender email address
    * @param subject the email subject; also used in the HTML in an <h2>
    * @param subtitle string; content placed in an HTML <h3>
    * @param hero_img string; the filename of the hero image (will be embedded)
    * @param list_item_img string; the default rendered image, 1 per list item in the HTML list.  Will be an embedded image
    * @param retStatus out param; not used, should be removed I guess
    * @return string the HTML content of the email
    ***************************************************************************/
    public static bool sendMessageHtmlWithHeroImage60pct (
          //long msgId,
          // to implement the openmsgmodal URL param in a future release

          bool promptUserToGotoURL

        , string gotoURL
     // , string gotoURLAdditionalParams

        , string recipientUserName
        , string from
        , string to
        , string subject
        , string body
        , string hero_img        
        , int respPromptOptionsBitwise
        , string respPromptOptionsJSON
        , out string retStatus)
    {
        
        retStatus = @"";
        bool retState = true;

        try 
        {
                
          /* See:  https://stackoverflow.com/a/52307018 */
          /* See : https://docs.microsoft.com/en-us/dotnet/api/system.net.mail.mailmessage.alternateviews */

          byte[] attached = null;

          MemoryStream memstream_ical_inline = new MemoryStream();  
          ContentType contenttype_html       = new System.Net.Mime.ContentType("text/html");  

          LinkedResource linkd1              = new LinkedResource(MBA.EmbeddedResources.CommonImages.GetStream(hero_img),"image/png");
          linkd1.ContentId = "linkd1-" + hero_img;

        /* we want the actual HTML to include linkd1- and linkd2-, etc. in the img src attribute.  It makes it just a tad easier for us
          to reverse-engineer our own work, and makes it clear that we're intending to render an embedded resource instead of loading from
          a remote server */
       
       /* Wrap content in tr and td so its compatible with Email.generateHtmlContentWithHeroImage60pct */
         
       string inner_bodycontent = @"<tr  class=""" + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"tr"">" +
                    @"<td  class=""" + Constants.PREFIX_CSS_CLASSNAME_EMAIL_60PCT + @"td"" colspan=""2"">" + body + @"</td></tr>";

       var html = generateHtmlContentWithHeroImage60pct(
           //msgid,
           promptUserToGotoURL, gotoURL, "", //gotoURLAdditionalParams
           recipientUserName,
           "",
           subject, "", linkd1.ContentId, inner_bodycontent,
           respPromptOptionsBitwise, respPromptOptionsJSON
        );

        MailMessage mm         = Email.prepareMailMessage(from, to, "", "", "", ref attached, subject, html, ref memstream_ical_inline);
        AlternateView htmlview = AlternateView.CreateAlternateViewFromString(html, System.Text.Encoding.UTF8, "text/html");        
        htmlview.LinkedResources.Add(linkd1);   
        mm.Body = "";
        mm.AlternateViews.Add(htmlview);
        new SmtpClient(Constants.APP_SMTP_HOST,Constants.APP_SMTP_PORT).Send(mm);
        retState = true;

      }
      catch (Exception err)
      { 
        retStatus = err.Message;
        retState = false;

      }
      return retState;

    }

    /***************************************************************************
    * sendAnnouncementAsHtmlWithHeroImageAndImageList */
    /**
    * Creates and send a responsive HTML email message that contains a hero image and a <ul><li> HTML list;
    * each list entry has a thumbnail image.
    *
    * @param list_of_descr_objects A list of Objects that implement the ListItemWImage interface
    * @param to string; to destination email address
    * @param from string; the sender email address
    * @param subject the email subject; also used in the HTML in an <h2>
    * @param subtitle string; content placed in an HTML <h3>
    * @param hero_img string; the filename of the hero image (will be embedded)
    * @param list_item_img string; the default rendered image, 1 per list item in the HTML list.  Will be an embedded image
    * @param retStatus out param; not used, should be removed I guess
    * @return string the HTML content of the email
    ***************************************************************************/
        public static bool sendAnnouncementAsHtmlWithHeroImage60pctAndImageList(

          //long msgId,
          // to implement the openmsgmodal URL param in a future release

          bool promptUserToGotoURL
        , string gotoURL
        , string recipientUserName

        , string from
        , string to
        , string subject
        , string subtitle
        , IEnumerable<Object> list_of_desc_objs
        , string hero_img
        , string list_item_img
        , out string retStatus)
    {

        retStatus = @"";
        bool retState = true;

      try 
      {

        /* See https://stackoverflow.com/a/52307018 */
        /* See https://docs.microsoft.com/en-us/dotnet/api/system.net.mail.mailmessage.alternateviews */

        byte[] attached = null;

        MemoryStream memstream_ical_inline = new MemoryStream();
        ContentType  contenttype_html      = new System.Net.Mime.ContentType("text/html");  

        LinkedResource linkd1 = new LinkedResource(MBA.EmbeddedResources.CommonImages.GetStream(hero_img),"image/png");
        linkd1.ContentId = "linkd1-" + hero_img;

      LinkedResource linkd2 = new LinkedResource(MBA.EmbeddedResources.CommonImages.GetStream(list_item_img),"image/png");
      linkd2.ContentId = "linkd2-" + list_item_img;

      /* we want the actual HTML to include linkd1- and linkd2-, etc. in the img src attribute.  It makes it just a tad easier for us
         to reverse-engineer our own work, and makes it clear that we're intending to render an embedded resource instead of loading from
         a remote server */


      string html  =
        generateHtmlContentWithHeroImage60pctAndImageList(

            //msgid,

            promptUserToGotoURL, gotoURL, recipientUserName,
            list_of_desc_objs, subject, subtitle, linkd1.ContentId, linkd2.ContentId

        );


      MailMessage mm         = Email.prepareMailMessage(from, to, "", "", "", ref attached, subject, html, ref memstream_ical_inline);
      AlternateView htmlview = AlternateView.CreateAlternateViewFromString(html, System.Text.Encoding.UTF8, "text/html");
        
      htmlview.LinkedResources.Add(linkd1);
      htmlview.LinkedResources.Add(linkd2);

      mm.Body = "";        
      mm.AlternateViews.Add(htmlview);

      new SmtpClient(Constants.APP_SMTP_HOST,Constants.APP_SMTP_PORT).Send(mm);
    }
    catch (Exception err)
    { 
        retStatus = err.Message;
        retState = false;

    }

    return retState;

    }  

    public static List<byte[]> unprocessedRichTextToTextAndImages(string unprocessed_html, out string processed_html)
    {
        //https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regex?view=net-7.0
        Regex rx_1 = new
          Regex(
            @"src=""data:image" + "...g;base64,"

            // TODO: figure out if we need to support data:image/jpeg
            // like so:
                //@"src=""data:image\/(png|jpg|jpeg);base64,"
            ,
            RegexOptions.Compiled | RegexOptions.IgnoreCase);

        MatchCollection matches = rx_1.Matches(unprocessed_html);

        List<Match> reverseOrderedMatches = new List<Match> ();
        foreach (Match match_i in matches ) { reverseOrderedMatches.Add( match_i );  }
        reverseOrderedMatches.Reverse(); // ugh!!

        //matches.Sort

        StringBuilder sb = new StringBuilder(unprocessed_html);
        var retval = new List<byte[]> ();


        foreach  ( Match r_mi in reverseOrderedMatches )
        {
            GroupCollection gc = r_mi.Groups;
            List<System.Text.RegularExpressions.Group> reverseOrderedGroups = new List<System.Text.RegularExpressions.Group>();
            foreach (System.Text.RegularExpressions.Group gx_i in gc ) { reverseOrderedGroups.Add( gx_i ) ;  }
            reverseOrderedGroups.Reverse();

            foreach (System.Text.RegularExpressions.Group r_gxi in reverseOrderedGroups)
            {
              // r_gxi.Index is the zero-indexed position of the start of the string
              // src="data:image/png;base64,

              int src_quot_position = r_gxi.Index + 4;
              int base64_str_start_pos = src_quot_position + 23;
              
              int end_quot_position = unprocessed_html.IndexOf( '"', base64_str_start_pos );
              int len_base64  = end_quot_position - base64_str_start_pos ;

              string base64 = 
                unprocessed_html.Substring(base64_str_start_pos, len_base64);

              byte[] bytes = Convert.FromBase64String(base64);
              
              retval.Add( bytes ) ;  // pretty sure that adding it to a List prevents it from getting garbage collected
                                     // as we interate into the next loop, and then leave the function etc
                                     // yep.. everything works and has been working for a while now

              sb.Remove(src_quot_position
                        ,
                        end_quot_position - src_quot_position
                        );

              sb.Insert(
                  src_quot_position 
                  ,
                  @"""cid:byteblob-" + (retval.Count + 1 ).ToString()  
                  );

            }

        }

        processed_html = sb.ToString();

        return retval;

    }
        
    public static bool sendAnnouncementAsHtmlWithHeroImageAndRichText(

          //long msgId,
          // to implement the openmsgmodal URL param in a future release

          bool promptUserToGotoURL
        , string gotoURL
        , string recipientUserName

        , string from
        , string to
        , string custom_msgbody
        , string subject
        , string subtitle
        , string html_richtext
        , string hero_img

        , out string retStatus)
    {

        retStatus = @"";
        bool retState = true;

        //TODO: HARDCODING EMAIL DESTINATION
        //      REMOVE BEFORE DEPLOY

        // to = "cmuirhead@practi-cal.com";

      try 
      {

        /* See https://stackoverflow.com/a/52307018 */
        /* See https://docs.microsoft.com/en-us/dotnet/api/system.net.mail.mailmessage.alternateviews */

        byte[] attached = null;

        MemoryStream memstream_ical_inline = new MemoryStream();
        ContentType  contenttype_html      = new System.Net.Mime.ContentType("text/html");  

        LinkedResource linkd1 = new LinkedResource(MBA.EmbeddedResources.CommonImages.GetStream(hero_img),"image/png");
        linkd1.ContentId = "linkd1-" + hero_img;



        string       processed_html;
        List<byte[]> processed_bytes = unprocessedRichTextToTextAndImages(html_richtext, out processed_html);

        string processed_html_w_hero = generateHtmlContentWithHeroImage60pct(false, "", "", recipientUserName, custom_msgbody, subject, subtitle, linkd1.ContentId, processed_html, 0, "");


        MailMessage mm         = Email.prepareMailMessage(from, to, "", "", "", ref attached, subject, processed_html_w_hero, ref memstream_ical_inline);
        AlternateView htmlview = AlternateView.CreateAlternateViewFromString(processed_html_w_hero, System.Text.Encoding.UTF8, "text/html");
        
        htmlview.LinkedResources.Add(linkd1);

        int iter_i = 1;  foreach ( var byte_arr in processed_bytes )
      {
          var mem_stream = new MemoryStream( byte_arr );
          iter_i++;

          LinkedResource linkd_arr = new LinkedResource( mem_stream, "image/png");
                                                                                    // TODO: figure out if we need to support image/jpg
                                                                                    // NOTE: this was kind of a ticking... easter egg.  I demo'd this with png images
                                                                                    // and never tested with JPG files, and I don't recall ever warning anyone not to use JPGs.
                                                                                    // Fortunately I've never gotten any complaints about JPGs.
          linkd_arr.ContentId = "byteblob-" + iter_i.ToString();

          htmlview.LinkedResources.Add(linkd_arr);
      }

      //htmlview.LinkedResources.Add(linkd2);

      mm.Body = "";        
      mm.AlternateViews.Add(htmlview);

      new SmtpClient(Constants.APP_SMTP_HOST,Constants.APP_SMTP_PORT).Send(mm);
    }
    catch (Exception err)
    { 
        retStatus = err.Message;
        retState = false;

    }

    return retState;

    }  

  }
}
