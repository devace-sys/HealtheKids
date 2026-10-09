using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;


namespace MBA
{

    /**************************************************************************
     * NotificationsAndMessagePriority */
    /**
     *
     *
     ****************************************************************************/
    public enum NotificationMessagePriority
    {
          MESSAGE = 0
        , WARNING = 1
        , DANGER  = 2
        , SUCCESS = 3
    }

    /**************************************************************************
     * NotificationMessageWithPriority */
    /**
     *
     *
     ****************************************************************************/

    public class NotificationMessageWithPriority : Entity
    {
        public string previewMsg;
        public UserMessage msg;
        public string senderUserID;
        public bool   replyModeOn;
        public bool   allowDelete;
        public bool   allowModalView;
        public NotificationMessagePriority priority = NotificationMessagePriority.MESSAGE;

        public NotificationMessageWithPriority() { }
        public NotificationMessageWithPriority(
            string PreviewMsg
          , UserMessage Msg
          , NotificationMessagePriority Priority
          , bool replyModeOn
          , bool AllowDelete
          , bool AllowModalView
        ) {
            this.previewMsg     = PreviewMsg;
            this.msg            = Msg;
            this.priority       = Priority;
            this.replyModeOn    = replyModeOn;
            this.allowDelete    = AllowDelete;
            this.allowModalView = AllowModalView;
        }

        // generates mkup for a given notification message
        public string generateNotificationMessageMkup(string cssID = "", string cssClasses = "")
        {
            string cssColorClass = "";

            switch (this.priority)
            {
                case (NotificationMessagePriority.WARNING):
                    cssColorClass = "mba-background-color-warning";
                    break;

                case (NotificationMessagePriority.DANGER):
                    cssColorClass = "mba-background-color-danger";
                    break;

                case (NotificationMessagePriority.SUCCESS):
                    cssColorClass = "mba-background-color-success";
                    break;

                default:
                    cssColorClass = "mba-background-color-message";
                    break;
            }
            return @"<div id=""" + cssID + @""" class=""" + cssClasses + @" " + cssColorClass + @""">" + previewMsg + @"</div>";
        }

    }

    /**************************************************************************
     * NotificationsAndMessagesWidget */
    /**
     *
     *
     ****************************************************************************/

    public class NotificationsAndMessagesWidget : ControlBase
    {

        /*-------------------------------
         * Note: We do not store this
         * controls value in an
         * attribute.  Therefore we
         * override the value property.
         *------------------------------*/

        public NotificationsAndMessagesWidget() : base() { }

        protected string                                _title                   = @"Notifications & Messages";
        protected string                                _sendMessageAjaxURL      = @"";
        protected string                                _deleteMessageAjaxURL    = @"";
        protected string                                _messagesViewAjaxURL     = @"";
        protected string                                _sentMessagesAjaxData    = @"";
        protected string                                _deletedMessagesAjaxData = @"";
        protected string                                _recipientSrcURL         = @"";
        protected bool                                  _hidden                  = false;
        protected List<NotificationMessageWithPriority> _messages                = new List<NotificationMessageWithPriority> { };

        public string title                   { get { return _title;                    } set { _title                   = value; } }
        public string sendMessageAjaxURL      { get { return _sendMessageAjaxURL;       } set { _sendMessageAjaxURL      = value; } }
        public string deleteMessageAjaxURL    { get { return _deleteMessageAjaxURL;     } set { _deleteMessageAjaxURL    = value; } }
        public string messagesViewAjaxURL     { get { return _messagesViewAjaxURL;      } set { _messagesViewAjaxURL     = value; } }
        public string sentMessagesAjaxData    { get { return _sentMessagesAjaxData;     } set { _sentMessagesAjaxData    = value; } }
        public string deletedMessagesAjaxData { get { return _deletedMessagesAjaxData;  } set { _deletedMessagesAjaxData = value; } }
        public string recipientSrcURL         { get { return _recipientSrcURL;          } set { _recipientSrcURL         = value; } }
        public bool   hidden                  { get { return _hidden;                   } set { _hidden                  = value; } }

        // adds a message to the _messages list
        public void addMessage(string previewMsg, UserMessage msg, NotificationMessagePriority priority, bool replyModeOn, bool allowDelete, bool allowModalView)
        {
            _messages.Add(new NotificationMessageWithPriority(previewMsg, msg, priority, replyModeOn, allowDelete, allowModalView));
        }

        // sets _messages to a passed in list
        public void setMessagesList(List<NotificationMessageWithPriority> messages)
        {
            _messages = messages; // this is setting the reference so if original list changes, so will the list in this class
        }

        protected override void Render(HtmlTextWriter writer)
        {
            if (_hidden)
            {
                return;
            }

            // render outer container
            writer.Write(@"<div class=""mba-messages-widget-container container"">");

            string randomGUID            = Guid.NewGuid().ToString();
            string _messageIconID        = this.ID + "_messages_"         + randomGUID;
            string _deletedMessageIconID = this.ID + "_deleted_messages_" + randomGUID;
            string _sentMessageIconID    = this.ID + "_sent_messages_"    + randomGUID;

            writer.Write(@"<div class=""mba-messages-widget-title-and-options-row row mb-3"">"); /*top row*/

            // render title
            writer.Write(@"<div class=""col-2"">"
                       + @"<i id=""" + _messageIconID  + @""" class=""fas fa-comment fa-2x"" title=""Send a Message""></i>"
                       + @"</div>"
                       + @"<div class=""col-8 text-center"">"
                       + @"<h4 class=""d-inline-block"">" + _title + @"</h4>"
                       + @"<span id=""mba-user-messages-count-badge-pill"" class=""badge badge-pill badge-danger align-top ml-1"">" + _messages.Count + @"</span>"
                       + @"</div>"
                       + @"<div class=""col-2"">"
                       + @"<span class=""d-flex"">"
                       + @"<i id=""" + _deletedMessageIconID + @""" class=""fas fa-trash-alt fa-1-2em mr-2 mt-1"" title=""View deleted messages""></i>"
                       + @"<i id=""" + _sentMessageIconID    + @""" class=""fas fa-share-square mt-1"" title=""View sent messages""></i>"
                       + "</span>"
                       + "</div>");

            writer.Write(@"</div>"); /* Top row */

            writer.Write(@"<div class=""mba-messages-widget-messages-row row"">"); /* Messages*/

            // render user messages first
            int _salt = 1;
            foreach (NotificationMessageWithPriority msg in _messages)
            {
                string _messageDivID = _messageIconID + "_mba-single-message-div_" + _salt++;
                string _messageOpts = @"{"

                                        + @"'clientID':""" + rd.wu.usr.clientID + @""""
                                        + @",'siteBaseUrl':"""          + MBA.HttpApplication.currentServerApp()          + @""""
                                        
                                        + @",'sendMessageAjaxURL':""" + _sendMessageAjaxURL + @""""
                                        + @",'deleteMessageAjaxURL':""" + _deleteMessageAjaxURL + @""""
                                        + @",'recipientSrcURL':""" + _recipientSrcURL + @""""
                                        + @",'replyModeOn':" + Util.netBoolToJSBool(msg.replyModeOn)
                                        + @",'allowDelete':" + Util.netBoolToJSBool(msg.allowDelete)
                                        + @",'viewModeSubject':'" + msg.msg.subject.Replace("'", @"\'").Replace("\n", @"<br>") + @"'"
                                        + @",'viewModeBody':'" + msg.msg.body.Replace("'", @"\'").Replace("\n", @"<br>") + @"'"
                                        + @",'isSendOnly':" + Util.netBoolToJSBool(false)
                                        + @",'senderUserID':" + msg.msg.senderUserID
                                        + @",'senderName':'" + msg.msg.senderName.Replace("'", @"\'") + @"'"
                                        + @",'messageID':" + msg.msg.id

                                        + @", 'promptUserToGotoURL':" + Convert.ToInt32( msg.msg.promptUserToGotoURL )


                                        + (
                                            msg.msg.promptUserToGotoURL
                                            ?
                                              @", 'gotoURL': '" +
                                              MBA.HttpApplication.createLink( msg.msg.gotoURL, true )
                                              +
                                              (
                                                Util.IsNullOrEmpty(msg.msg.gotoURLAdditionalParams)
                                                  ?
                                                    ""
                                                  :
                                                    ( "&" + msg.msg.gotoURLAdditionalParams )
                                              )
                                              + @"'"
                                            :
                                            ""
                                          )

                                        + @", 'respPromptOptions':" + msg.msg.respPromptOptionsBitwise
                                        // if we are going to a URL where the user needs the message data, don't allow them to close the widget
                                        + ((msg.msg.respPromptOptionsBitwise != 0) ? @", 'allowCloseWidget': false" : @"" )
                                        + @", 'respPromptOptionsJSON':" + @"`" + msg.msg.respPromptOptionsJSON + @"`"

                                              /* pass in the $ of the new window after the message opens in a new window;
                                                  we want the filebox rendering in the new window, not the old one */
                                        + @", 'FnRmtsRespPromptFileupbox':    function( www_$ ) { www_$.spedmonWebUI.fileList('RMTS Supporting Documentation', " +
                                                                               @"'" + MBA.StoredFiles.LIST_HANDLER_PRIVATE() + @"'," +
                                                                               @"'" + MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE() + @"'," +
                                                                               @"'" + MBA.StoredFiles.PARAM_FILE_ID + @"', 3," +
                                                                               @"'" + MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE() + @"'" +
                                                                              ", 625, '', '', '', " +
                                                                              @"`" + msg.msg.respPromptOptionsJSON + @"`" +
                                                                              ", true , true); }" +

                                        @"} ";

                /* generates a div with a col-12 */
                writer.Write(msg.generateNotificationMessageMkup(_messageDivID, "mba-messages-widget-message col-12 mb-1 rounded text-left p-1"));

                if (msg.allowModalView)
                {
                    writer.Write("<script>$( document ).ready(function(){ $('#" + _messageDivID + "').messagesWidget(" + _messageOpts + ");})</script>");
                }

            }
            writer.Write(@"</div>"); /* messages row */
            writer.Write(@"</div>"); /* container */

            string _opts = @"{"

                + @"'clientID':"""             + rd.wu.usr.clientID                              + @""""
                //+ @",'siteBaseUrl':"""          + MBA.HttpApplication.currentServerApp()          + @""""

                + @",'sendMessageAjaxURL':"""   + _sendMessageAjaxURL           + @""""
                + @",'deleteMessageAjaxURL':""" + _deleteMessageAjaxURL         + @""""
                + @",'recipientSrcURL':"""      + _recipientSrcURL              + @""""
                + @",'replyModeOn':"            + Util.netBoolToJSBool(false)
                + @",'allowDelete':"            + Util.netBoolToJSBool(false)
             + @"}";

            writer.Write("<script>$( document ).ready(function(){ $('#" + _messageIconID + @"').messagesWidget("
                         + _opts + ");");

            writer.Write("$('#"   + _deletedMessageIconID     + @"').renderDeletedMessages("
                        + @"'"    + _messagesViewAjaxURL      + @"'"
                        + @",'"   + _deletedMessagesAjaxData  + @"'"
                        + @",'"   + _deleteMessageAjaxURL     + @"');");

            writer.Write("$('#"   + _sentMessageIconID        + @"').renderSentMessages("
                        + @"'"    + _messagesViewAjaxURL      + @"'"
                        + @",'"   + _sentMessagesAjaxData     + @"'"
                        + @",'"   + _deleteMessageAjaxURL     + @"');});</script>");

            base.Render(writer);
        }

        protected static string generatePreviewMsgContent (string msgFaIcon, string msgTitle, string msgDate, string msgText, string senderEmail = "", string senderClientName = "", bool isPcalStaff = false)
        {
             return
                     @"<div class=""mba-messages-widget-message-preview-content d-flex-flex-col"">"
                   + @"<div class=""mba-messages-widget-message-preview-content-row-1 d-flex flex-row justify-content-between"">"
                   + @"<i aria-hidden=""true"" class=""mba-messages-widget-message-preview-content-msg-icon ml-auto " + msgFaIcon + @"""></i>"
                   + @"<span class=""ml-1 flex-grow-1 text-left mr-1"">"
                   + @"<span class=""mba-messages-widget-message-preview-content-msg-title"" >" + msgTitle + @"</span>"
                   + (
                       isPcalStaff && !(Util.IsNullOrEmpty(senderClientName)) ? 
                         @"<span class=""mba-messages-widget-message-preview-content-msg-title-faded-secondary"" >  &#8212 " + senderClientName + @"</span>"
                       : ""
                     )
                   + @"</br>"
                   + @"<span class=""mba-messages-widget-message-preview-content-msg-title-faded-secondary-lowerc"" >" + senderEmail + @"</span>"
                   + @"</span>"
                   + @"<span class=""mba-messages-widget-message-preview-content-msg-date mr-auto"">" + msgDate + @"</span>"
                   + @"</div>" /* row-1*/
                   + @"<div class=""mba-messages-widget-message-preview-content-row-2 d-flex flex-row mt-1"">"
                   + @"<span class=""mba-messages-widget-message-preview-content-msg-text"">" + msgText  + @"</span>"
                   + @"</div>" /* row-2*/
                   + @"</div>";
        }
        public static string generatePreviewMsg (string msgFaIcon, string msgTitle, string msgDate, string msgText, string msgToolTip, string actionUrl, bool actionUrlIsNewTab = false)
        {
            string _targetMkup = @"";
            if (String.IsNullOrWhiteSpace(msgDate)) msgDate = DateTime.Now.ToShortDateString();
            if (actionUrlIsNewTab == true) _targetMkup = @" target=""_blank""";
            string _previewMsg = @"<a class=""mba-messages-widget-message-preview-container"" title="""+ msgToolTip + @""" href=""" + actionUrl + @""""
                                 + _targetMkup
                                 + @">"
                                 + generatePreviewMsgContent(msgFaIcon,msgTitle,msgDate,msgText)
                                 + @"</a>";
            return _previewMsg;
        }
        public static string generateNotificationPreviewMsg (string msgTitle, string msgDate, string msgText, string msgToolTip, string actionUrl)
        {
            return generatePreviewMsg (@"fas fa-bell", msgTitle, msgDate, msgText, msgToolTip, actionUrl);
        }
        public static string generateAnnouncementPreviewMsg (string msgDate, string msgText, string actionUrl)
        {
            return generatePreviewMsg (@"fa fa-bullhorn", @"New Announcement", msgDate, msgText, @"Click here to read the rest of the announcement", actionUrl, true);
        }

        public static string generateMessagePreviewMsg (string msgSenderName, string msgCreatedStr, string msgSubject, string senderEmail = "" ,  string senderClientName = "", bool isPcalStaff = false )
        {
            string _previewMsg = @"<span class=""mba-messages-widget-message-preview-container"" title=""Click here to read the rest of the message"">"
                               + generatePreviewMsgContent(@"fa fa-envelope","Message From " + msgSenderName, msgCreatedStr, msgSubject, senderEmail, senderClientName, isPcalStaff )
                               + @"</span>";
            return _previewMsg;
        }

    }

}
