using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;
using System.IO;


namespace MBA
{

  /* presumably, we want to eventually be able to send invitations for things other than TeleCom sessions. */
  /* Here, any class that contains these fields could conceivably be passed as an argument to SendableInvitation.SendInvitation() */
  public class InvitableContent {
    public string title { set;  get; }
    public string invitee_name { set;  get; }
    public string description_body { set; get; }
    public long node_id { /* set; */  get; }
    public string node_url { /* set; */ get; }

    public string security_code { set; get; }
    //

    public DateTime created_date { set; get; }
    public DateTime attend_date { set;  get; }
    public DateTime session_end {set; get; }
    public DateTime must_confirm_by_date { set; get; }
    public DateTime must_cancel_by_date { set; get; }

    public string rsvp_addy { /* set; */ get; }
    public string auto_signature_str { /* set; */ get; }  /* Something like "Kindly Regards," followed by the practitioner name, teacher name, consultant name.... */

    //string add_g_calendar_url { set; get; }

    //TODO:
    //string add_apple_calendar_ur; {get;}

    //string from_field { set; get; }
  }


  /* someday if we have SMS, or Facebook DMs/updates, or other messaging functionality,
     then we want to be able to send  invitations/notifications through those intermediaries */

        /*
  public abstract class SendableInvitation {

        /* Sends a "Thanks for Signing Up!  You have signed up for ... "
        public static readonly string default_templ_thanks_for_signing_up_subj= "Thanks for signing up, {1}!";
        public static readonly string default_templ_thanks_for_signing_up_body= "Hello {1},<br/><br/>On {4} you signed up and agreed to attend the {0}.  You will need to attend on {5}.<br/><br/>If you have any questions, please reach out to {8}.<br/><br/>{9}";

        /* Sends a "You are invited!  Your teacher/counsellor/social worker has asked you to participate in ... "
        public static readonly string default_templ_orig_invitation_subj= "You are invited, {1}! - {0} - {5}";
        public static readonly string default_templ_orig_invitation_body= "Hello {1},<br/><br/>You have been asked to attend {0} on {5}.  If you have any questions, please reach out to {8}.<br/><br/>{9}";

        /* Sends a "Don't forget!  You are scheduled to attend something on ... "
        public static readonly string default_templ_reminder_subj= "Don't forget!  You are scheduled for {0} on {5}";
        public static readonly string default_templ_reminder_body= "Hello {1},<br/><br/>You are scheduled to attend {0} on {5}.  If you have any questions, please reach out to {8}.<br/><br/>{9}";

        /* Sends a "Are you still interested?  To confirm, you must respond. "
        public static readonly string default_templ_please_confirm_subj= "{0} - Are you still interested, {1}?  To confirm, you must respond.";
        public static readonly string default_templ_please_confirm_body= "Hello {1},<br/><br/>Do you still wish to attend {0} on {5}?<br/><br/>If so, please finish signing up by clicking this link: {3}<br/><br/>If you have any questions, please reach out to {8}.<br/><br/>{9}";

        /* Sends a "Are you still interested?  To confirm, you must respond by ... "
        public static readonly string default_templ_notif_must_confirm_by_date_subj= "{0} - Are you still interested, {1}?  To confirm, you must respond by {6}.";
        public static readonly string default_templ_notif_must_confirm_by_date_body= "Hello {1},<br/><br/>Do you still wish to attend {0} on {5}?  If so, you must respond on or before {6}.<br/><br/>Please finish signing up by clicking this link: {3}<br/><br/>If you have any questions, please reach out to {8}.<br/><br/>{9}";

        /* Sends a "Are you still interested?  If you wish to cancel, you must respond by ... "
        public static readonly string default_templ_notif_must_cancel_by_date_subj= "{0} - Are you still interested, {1}?  If not, please cancel by {7}.";
        public static readonly string default_templ_notif_must_cancel_by_date_body= "Hello {1},<br/><br/>Do you still wish to attend {0} on {5}?  If not, you must respond on or before {7}.<br/><br/>Please mark your cancellation by clicking the cancel button on this page: {3}<br/><br/>If you have any questions, please reach out to {8}.<br/><br/>{9}";

        /* TODO: let's maybe also create subject and body templates for "So-and-so and cancelled the event" and "you have withdrawn from/cancelled your participation in the event"

        public static string Generate_invitation_wording(CanBeInvitableContent content, string tmpl)
        {
            return String.Format(
              tmpl,
              content.title,
              content.invitee_name,
              content.node_id,
              content.node_url,
              content.created_date,
              content.attend_date,
              content.must_confirm_by_date,
              content.must_cancel_by_date,
              content.rsvp_addy,
              content.auto_signature_str//,
                                        //content.add_g_calendar_url//,
                                        //content.from_field
            );
        }

    }

*/

}
