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
     * ParentPortalMessagePractitioner */
    /**
     * Representa un practitioner/therapist para el portal de padres
     **************************************************************************/
    public class ParentPortalMessagePractitioner
    {
        public string practitionerUserID;
        public string practitionerName;
        public string practitionerEmail;
        public string roleName;

        public ParentPortalMessagePractitioner() { }

        public ParentPortalMessagePractitioner(string userID, string name, string email = "", string role = "")
        {
            practitionerUserID = userID;
            practitionerName = name;
            practitionerEmail = email;
            roleName = role;
        }
    }

    /**************************************************************************
     * NotificationMessageWithPriority2 */
    /**
     *
     *
     ****************************************************************************/

    public class NotificationMessageWithPriority2 : Entity
    {
        public string previewMsg;
        public UserMessage msg;
        public string senderUserID;
        public bool replyModeOn;
        public bool allowDelete;
        public bool allowModalView;
        public NotificationMessagePriority priority = NotificationMessagePriority.MESSAGE;

        public NotificationMessageWithPriority2() { }
        public NotificationMessageWithPriority2(string PreviewMsg, UserMessage Msg, NotificationMessagePriority Priority, bool replyModeOn, bool AllowDelete, bool AllowModalView)
        {
            this.previewMsg = PreviewMsg;
            this.msg = Msg;
            this.priority = Priority;
            this.replyModeOn = replyModeOn;
            this.allowDelete = AllowDelete;
            this.allowModalView = AllowModalView;
        }

        // generates mkup for a given notification message
        public string generateNotificationMessageMkup(string cssID = "", string cssClasses = "")
        {
            string cssColorClass = "";
            string accentColor = "#3b82f6";
            string glowColor = "rgba(59, 130, 246, 0.4)";
            string iconGradient = "linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)";

            switch (this.priority)
            {
                case NotificationMessagePriority.WARNING:
                    cssColorClass = "mba-background-color-warning";
                    accentColor = "#f59e0b";
                    glowColor = "rgba(245, 158, 11, 0.4)";
                    iconGradient = "linear-gradient(135deg, #f59e0b 0%, #d97706 100%)";
                    break;

                case NotificationMessagePriority.DANGER:
                    cssColorClass = "mba-background-color-danger";
                    accentColor = "#ef4444";
                    glowColor = "rgba(239, 68, 68, 0.4)";
                    iconGradient = "linear-gradient(135deg, #ef4444 0%, #dc2626 100%)";
                    break;

                case NotificationMessagePriority.SUCCESS:
                    cssColorClass = "mba-background-color-success";
                    accentColor = "#10b981";
                    glowColor = "rgba(16, 185, 129, 0.4)";
                    iconGradient = "linear-gradient(135deg, #10b981 0%, #059669 100%)";
                    break;

                default: // MESSAGE
                    cssColorClass = "mba-background-color-message";
                    accentColor = "#3b82f6";
                    glowColor = "rgba(59, 130, 246, 0.4)";
                    iconGradient = "linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)";
                    break;
            }

            // Estilo glassmorphism con backdrop-filter y efectos 3D - más compacto
            string containerStyle = "position:relative;" +
                "border-radius:16px;" +
                "background:rgba(255, 255, 255, 0.85);" +
                "backdrop-filter:blur(10px);" +
                "-webkit-backdrop-filter:blur(10px);" +
                "border:1px solid rgba(255, 255, 255, 0.4);" +
                "box-shadow:0 8px 32px 0 rgba(31, 38, 135, 0.15), inset 0 1px 0 rgba(255,255,255,0.5);" +
                "padding:1rem 1.25rem;" +
                "margin:0.5rem 0;" +
                "width:100%;" +
                "box-sizing:border-box;" +
                "cursor:pointer;" +
                "transition:all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);" +
                "overflow:visible;" +
                "transform:translateZ(0);";

            // Barra de acento animada a la izquierda
            string accentBar = "<div style=\"position:absolute;left:0;top:20%;height:60%;width:5px;" +
                "background:" + iconGradient + ";" +
                "border-radius:0 10px 10px 0;" +
                "box-shadow:0 0 20px " + glowColor + ";" +
                "transition:all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);" +
                "\" class=\"accent-bar\"></div>";

            // Efecto de brillo animado en hover
            string shineEffect = "<div style=\"position:absolute;top:-50%;left:-50%;width:200%;height:200%;" +
                "background:linear-gradient(45deg, transparent 30%, rgba(255,255,255,0.3) 50%, transparent 70%);" +
                "transform:translateX(-100%);" +
                "transition:transform 0.6s;" +
                "pointer-events:none;" +
                "\" class=\"shine-effect\"></div>";

            // Efectos hover más sutiles
            string hoverEffects = "onmouseover=\"" +
                "this.style.transform='translateY(-2px) scale(1.01)';" +
                "this.style.boxShadow='0 12px 40px 0 rgba(31, 38, 135, 0.2), 0 0 30px " + glowColor + ", inset 0 1px 0 rgba(255,255,255,0.6)';" +
                "this.querySelector('.accent-bar').style.height='80%';" +
                "this.querySelector('.accent-bar').style.top='10%';" +
                "this.querySelector('.shine-effect').style.transform='translateX(100%)';" +
                "this.querySelector('.status-dot').style.transform='scale(1.2) rotate(180deg)';" +
                "\" " +
                "onmouseout=\"" +
                "this.style.transform='translateY(0) scale(1)';" +
                "this.style.boxShadow='0 8px 32px 0 rgba(31, 38, 135, 0.15), inset 0 1px 0 rgba(255,255,255,0.5)';" +
                "this.querySelector('.accent-bar').style.height='60%';" +
                "this.querySelector('.accent-bar').style.top='20%';" +
                "this.querySelector('.shine-effect').style.transform='translateX(-100%)';" +
                "this.querySelector('.status-dot').style.transform='scale(1) rotate(0deg)';" +
                "\" " +
                "onfocus=\"" +
                "this.style.transform='translateY(-2px) scale(1.01)';" +
                "this.style.boxShadow='0 12px 40px 0 rgba(31, 38, 135, 0.2), 0 0 30px " + glowColor + "';" +
                "\" " +
                "onblur=\"" +
                "this.style.transform='translateY(0) scale(1)';" +
                "this.style.boxShadow='0 8px 32px 0 rgba(31, 38, 135, 0.15), inset 0 1px 0 rgba(255,255,255,0.5)';" +
                "\"";

            // Indicador de estado pulsante
            string statusDot = "<div class=\"status-dot\" style=\"position:absolute;right:1.5rem;top:50%;transform:translateY(-50%);" +
                "width:12px;height:12px;border-radius:50%;" +
                "background:" + accentColor + ";" +
                "box-shadow:0 0 0 0 " + glowColor + ", 0 0 15px " + glowColor + ";" +
                "animation:pulse-dot 2s infinite;" +
                "transition:transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);" +
                "\"></div>";

            // Badge flotante con micro-animación
            string newBadge = "";
            if (this.msg != null && (DateTime.Now - this.msg.created).TotalHours < 24)
            {
                newBadge = "<span style=\"position:absolute;top:-8px;right:1rem;" +
                    "background:" + iconGradient + ";" +
                    "color:#fff;font-size:0.7rem;font-weight:700;padding:0.3rem 0.8rem;" +
                    "border-radius:20px;text-transform:uppercase;letter-spacing:0.8px;" +
                    "box-shadow:0 4px 15px " + glowColor + ", 0 2px 8px rgba(0,0,0,0.2);" +
                    "animation:bounce-subtle 2s infinite;" +
                    "border:2px solid rgba(255,255,255,0.3);" +
                    "\">New</span>";
            }

            // CSS Animations
            string animations = "<style>" +
                "@keyframes pulse-dot {" +
                "  0%, 100% { box-shadow: 0 0 0 0 " + glowColor + ", 0 0 15px " + glowColor + "; }" +
                "  50% { box-shadow: 0 0 0 8px rgba(0,0,0,0), 0 0 25px " + glowColor + "; }" +
                "}" +
                "@keyframes bounce-subtle {" +
                "  0%, 100% { transform: translateY(0); }" +
                "  50% { transform: translateY(-3px); }" +
                "}" +
                "</style>";

            return animations
                 + @"<div id=""" + cssID + @""" class=""" + cssClasses + @" " + cssColorClass + @""" "
                 + @"role=""button"" tabindex=""0"" aria-label=""Open message"" "
                 + hoverEffects
                 + @"style=""" + containerStyle + @""">"
                 + accentBar
                 + shineEffect
                 + newBadge
                 + statusDot
                 + previewMsg
                 + @"</div>";
        }

    }

    /**************************************************************************
     * ParentPortalMessagesWidget */
    /**
     *
     *
     ****************************************************************************/

    public class ParentPortalMessagesWidget : ControlBase
    {

        public ParentPortalMessagesWidget() : base() { }

        protected string _title = @"Notifications & Messages";
        protected string _sendMessageAjaxURL = @"";
        protected string _deleteMessageAjaxURL = @"";
        protected string _messagesViewAjaxURL = @"";
        protected string _sentMessagesAjaxData = @"";
        protected string _deletedMessagesAjaxData = @"";
        protected string _recipientSrcURL = @"";
        protected bool _hidden = false;
        protected List<NotificationMessageWithPriority2> _messages = new List<NotificationMessageWithPriority2> { };

        // NUEVO: lista de practitioners / therapists
        protected List<ParentPortalMessagePractitioner> _practitioners = new List<ParentPortalMessagePractitioner>();

        public string title { get { return _title; } set { _title = value; } }
        public string sendMessageAjaxURL { get { return _sendMessageAjaxURL; } set { _sendMessageAjaxURL = value; } }
        public string deleteMessageAjaxURL { get { return _deleteMessageAjaxURL; } set { _deleteMessageAjaxURL = value; } }
        public string messagesViewAjaxURL { get { return _messagesViewAjaxURL; } set { _messagesViewAjaxURL = value; } }
        public string sentMessagesAjaxData { get { return _sentMessagesAjaxData; } set { _sentMessagesAjaxData = value; } }
        public string deletedMessagesAjaxData { get { return _deletedMessagesAjaxData; } set { _deletedMessagesAjaxData = value; } }
        public string recipientSrcURL { get { return _recipientSrcURL; } set { _recipientSrcURL = value; } }
        public bool hidden { get { return _hidden; } set { _hidden = value; } }

        // NUEVO: propiedad para practitioners
        public List<ParentPortalMessagePractitioner> practitioners
        {
            get { return _practitioners; }
            set { _practitioners = (value == null ? new List<ParentPortalMessagePractitioner>() : value); }
        }

        // adds a message to the _messages list
        public void addMessage(string previewMsg, UserMessage msg, NotificationMessagePriority priority, bool replyModeOn, bool allowDelete, bool allowModalView)
        {
            _messages.Add(new NotificationMessageWithPriority2(previewMsg, msg, priority, replyModeOn, allowDelete, allowModalView));
        }

        // sets _messages to a passed in list
        public void setMessagesList(List<NotificationMessageWithPriority2> messages)
        {
            _messages = messages; // this is setting the reference so if original list changes, so will the list in this class
        }

        // NUEVO: helper para agregar practitioners
        public void addPractitioner(string practitionerUserID, string practitionerName, string practitionerEmail = "", string role = "")
        {
            if (_practitioners == null)
            {
                _practitioners = new List<ParentPortalMessagePractitioner>();
            }

            _practitioners.Add(new ParentPortalMessagePractitioner(practitionerUserID, practitionerName, practitionerEmail, role));
        }

        protected override void Render(HtmlTextWriter writer)
        {
            if (_hidden)
            {
                return;
            }

            // CONTENEDOR EXTERNO: ahora ocupa todo el ancho y alto disponible del tab
            writer.Write(
                @"<div class=""mba-messages-widget-container container-fluid my-3 px-0"" " +
                @"style=""width:100%;height:100%;"">"
            );

            // CARD: full width y un poco más alta
            writer.Write(
                @"<div class=""card border-0 shadow-sm w-100 h-100"" " +
                @"style=""border-radius:0.9rem; overflow:hidden; " +
                @"background:linear-gradient(135deg,#f5f7ff,#ffffff); " +
                @"min-height:180px;"">"
            );

            string randomGUID = Guid.NewGuid().ToString();
            string _messageIconID = this.ID + "_messages_" + randomGUID;
            string _deletedMessageIconID = this.ID + "_deleted_messages_" + randomGUID;
            string _sentMessageIconID = this.ID + "_sent_messages_" + randomGUID;
            string practitionerJsAll = "";

            // HEADER
            writer.Write(
                @"<div class=""mba-messages-widget-title-and-options-row row align-items-center mb-0 px-4 py-3"" " +
                @"style=""background:linear-gradient(135deg,#f5f7ff,#ffffff);"">"
            ); /*top row*/

            // render title / header
            writer.Write(
                   @"<div class=""col-2 d-flex align-items-center"">"
                 + @"<span class=""d-inline-flex align-items-center justify-content-center rounded-circle"" "
                 + @"style=""width:40px;height:40px;background-color:transparent;"">"
                 + @"<buttom clas=""btn btndirectmessage""><i id=""" + _messageIconID + @""" class=""fas fa-comment fa-2x text-success"" title=""Send a Message""></i></buttom>"
                 + @"</span>"
                 + @"</div>"
                 + @"<div class=""col-8 text-center text-dark"">"
                 + @"<h4 class=""d-inline-block mb-0 font-weight-bold"">" + _title + @"</h4>"
                 + @"<span id=""mba-user-messages-count-badge-pill"" class=""badge badge-pill badge-danger align-top ml-2 px-3 py-1 shadow-sm"" "
                 + @"style=""font-size:.87rem;background-color:red;color:#fff;"">" + _messages.Count + @"</span>"
                 + @"<div class=""mt-1 small text-muted"" style=""opacity:.85;"">You have " + _messages.Count + @" message(s)</div>"
                 + @"</div>"
                 + @"<div class=""col-2 d-flex justify-content-end align-items-center"">"
                 + @"<span class=""d-flex"">"
                 + @"<i id=""" + _deletedMessageIconID + @""" class=""fas fa-trash-alt fa-2x mr-3 text-danger"" style=""cursor:pointer;opacity:.9;"" title=""View deleted messages""></i>"
                 + @"<i id=""" + _sentMessageIconID + @""" class=""fas fa-paper-plane fa-2x text-success"" style=""cursor:pointer;opacity:.9;"" title=""View sent messages""></i>"
                 + @"</span>"
                 + @"</div>"
            );

            writer.Write(@"</div>"); /* Top row */

            /******************************************************************
             * NEW SECTION: PRACTITIONERS / THERAPISTS
             ******************************************************************/
            if (_practitioners != null && _practitioners.Count > 0)
            {
                int pIndex = 1;
                var sbPractitionerJs = new System.Text.StringBuilder();

                writer.Write(
                    @"<div class=""row px-4 pt-3 pb-1"">" +
                    @"<div class=""col-12"" style=""max-height:100px; overflow-y:auto; padding-right:.5rem;"">" +
                    @"<div class=""d-flex flex-column"">"
                );

                foreach (ParentPortalMessagePractitioner p in _practitioners)
                {
                    string practitionerIconID = this.ID + "_practitioner_msg_" + randomGUID + "_" + pIndex++;

                    string safeName = HttpUtility.HtmlEncode(p.practitionerName ?? "");
                    string safeEmail = HttpUtility.HtmlEncode(p.roleName ?? "");

                    // ==== HTML del practitioner + icono de mensaje ====
                    writer.Write(
                        @"<div class=""d-flex align-items-center mb-1"">"
                      + @"<span class=""mr-2"" style=""font-size:.88rem;color:#333;"">"
                      + safeName
                      + @"</span>"
                      + (String.IsNullOrEmpty(safeEmail)
                            ? ""
                            : @"<span class=""text-muted mr-2"" style=""font-size:.75rem;"">"
                              + safeEmail
                              + @"</span>")
                      + @"<i id=""" + practitionerIconID + @""" class=""fas fa-comment-dots ml-1"" "
                      + @"style=""cursor:pointer;font-size:0.95rem;color:#28a745;"" "
                      + @"title=""Send a Message""></i>"
                      + @"</div>"
                    );

                    // ==== JS para preseleccionar a ESTE practitioner como destinatario ====
                    string jsSafeName = p.practitionerName == null
                                            ? ""
                                            : p.practitionerName.Replace("'", "\\'");
                    string jsSafeID = (p.practitionerUserID ?? "").Replace("'", "\\'");

                    string practOpts =
                        "{"
                        + "'clientID':\"" + rd.wu.usr.clientID + "\""
                        + ",'sendMessageAjaxURL':\"" + _sendMessageAjaxURL + "\""
                        + ",'deleteMessageAjaxURL':\"" + _deleteMessageAjaxURL + "\""
                        + ",'recipientSrcURL':\"" + _recipientSrcURL + "\""
                        + ",'replyModeOn':" + Util.netBoolToJSBool(false)
                        + ",'allowDelete':" + Util.netBoolToJSBool(false)
                        + ",'recipientIDs':'" + jsSafeID + "'"
                        + ",'recipientNames':'" + jsSafeName + "'"
                        + "}";

                    sbPractitionerJs.Append(
                        "$('#" + practitionerIconID + "').messagesWidget(" + practOpts + ");"
                    );
                }

                writer.Write(
                    @"</div>" +  // flex-column
                    @"</div>" +  // col-12
                    @"</div>"    // row
                );

                // Guardamos ese JS para emitirlo junto con el resto al final:
                practitionerJsAll = sbPractitionerJs.ToString();
                // Lo usaremos más abajo cuando escribamos el <script> general.
            }

            // FILA DE MENSAJES: más padding y una altura mínima
            writer.Write(
                            @"<div class=""mba-messages-widget-messages-row row no-gutters px-4 py-3"" " +
                            @"style=""background:linear-gradient(135deg,#fafbfc,#ffffff);" +
                            @"min-height:140px;max-height:400px;overflow-y:auto;overflow-x:hidden;" +
                            @"padding-right:0.5rem;scroll-behavior:smooth;"">"
                        ); /* Messages*/

            // render user messages first
            int _salt = 1;
            foreach (NotificationMessageWithPriority2 msg in _messages)
            {
                string _messageDivID = _messageIconID + "_mba-single-message-div_" + _salt++;
                string _messageOpts = @"{"

                                        + @"'clientID':""" + rd.wu.usr.clientID + @""""
                                        + @",'siteBaseUrl':""" + MBA.HttpApplication.currentServerApp() + @""""

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

                                        + @", 'promptUserToGotoURL':" + Convert.ToInt32(msg.msg.promptUserToGotoURL)

                                        + (
                                            msg.msg.promptUserToGotoURL
                                            ?
                                              @", 'gotoURL': '" +
                                              MBA.HttpApplication.createLink(msg.msg.gotoURL, true)
                                              +
                                              (
                                                Util.IsNullOrEmpty(msg.msg.gotoURLAdditionalParams)
                                                  ?
                                                    ""
                                                  :
                                                    ("&" + msg.msg.gotoURLAdditionalParams)
                                              )
                                              + @"'"
                                            :
                                            ""
                                          )

                                        + @", 'respPromptOptions':" + msg.msg.respPromptOptionsBitwise
                                        + ((msg.msg.respPromptOptionsBitwise != 0) ? @", 'allowCloseWidget': false" : @"")
                                        + @", 'respPromptOptionsJSON':" + @"`" + msg.msg.respPromptOptionsJSON + @"`"

                                        + @", 'FnRmtsRespPromptFileupbox':    function( www_$ ) { www_$.spedmonWebUI.fileList('RMTS Supporting Documentation', " +
                                                           @"'" + MBA.StoredFiles.LIST_HANDLER_PRIVATE() + @"'," +
                                                           @"'" + MBA.StoredFiles.DOWNLOAD_HANDLER_PRIVATE() + @"'," +
                                                           @"'" + MBA.StoredFiles.PARAM_FILE_ID + @"', 3," +
                                                           @"'" + MBA.StoredFiles.UPLOAD_HANDLER_PRIVATE() + @"'" +
                                                          ", 625, '', '', '', " +
                                                          @"`" + msg.msg.respPromptOptionsJSON + @"`" +
                                                          ", true , true); }" +

                                        @"} ";

                /* genera la tarjeta del mensaje */
                writer.Write(msg.generateNotificationMessageMkup(
                    _messageDivID,
                    "mba-messages-widget-message col-12 mb-2 p-0"
                ));

                if (msg.allowModalView)
                {
                    writer.Write("<script>$( document ).ready(function(){ $('#" + _messageDivID + "').messagesWidget(" + _messageOpts + ");})</script>");
                }

            }
            writer.Write(@"</div>"); /* messages row */
            writer.Write(@"</div>"); /* card */
            writer.Write(@"</div>"); /* container */

            string _opts = @"{"

                + @"'clientID':""" + rd.wu.usr.clientID + @""""
                + @",'sendMessageAjaxURL':""" + _sendMessageAjaxURL + @""""
                + @",'deleteMessageAjaxURL':""" + _deleteMessageAjaxURL + @""""
                + @",'recipientSrcURL':""" + _recipientSrcURL + @""""
                + @",'replyModeOn':" + Util.netBoolToJSBool(false)
                + @",'allowDelete':" + Util.netBoolToJSBool(false)
             + @"}";

            // Script: header icon + practitioners + deleted/sent
            writer.Write("<script>$( document ).ready(function(){ $('#" + _messageIconID + @"').messagesWidget("
                         + _opts + ");");

            writer.Write(practitionerJsAll);

            writer.Write("$('#" + _deletedMessageIconID + @"').renderDeletedMessages("
                        + @"'" + _messagesViewAjaxURL + @"'"
                        + @",'" + _deletedMessagesAjaxData + @"'"
                        + @",'" + _deleteMessageAjaxURL + @"');");

            writer.Write("$('#" + _sentMessageIconID + @"').renderSentMessages("
                        + @"'" + _messagesViewAjaxURL + @"'"
                        + @",'" + _sentMessagesAjaxData + @"'"
                        + @",'" + _deleteMessageAjaxURL + @"');});</script>");

            base.Render(writer);
        }


        protected static string generatePreviewMsgContent(string msgFaIcon, string msgTitle, string msgDate, string msgText, string senderEmail = "", string senderClientName = "", bool isPcalStaff = false)
        {
            return
                @"<div class=""mba-messages-widget-message-preview-content d-flex flex-column"" " +
                @"style=""padding:0.25rem 2.5rem 0.25rem 0.75rem;"">"
              // Header con icono flotante más compacto
              + @"<div class=""d-flex align-items-start mb-2"">"
              + @"<span class=""d-inline-flex align-items-center justify-content-center rounded-circle mr-3"" " +
                @"style=""width:40px;height:40px;min-width:40px;" +
                @"background:linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);" +
                @"box-shadow:0 6px 16px rgba(59, 130, 246, 0.4), inset 0 1px 0 rgba(255,255,255,0.3);" +
                @"border:2px solid rgba(255,255,255,0.5);" +
                @"transition:all 0.3s ease;"">"
              + @"<i aria-hidden=""true"" class=""text-white " + msgFaIcon + @""" " +
                @"style=""font-size:1.1rem;filter:drop-shadow(0 2px 4px rgba(0,0,0,0.3));""></i>"
              + @"</span>"
              + @"<div class=""flex-grow-1"">"
              // Título con gradiente azul
              + @"<div class=""d-flex flex-wrap align-items-baseline mb-1"">"
              + @"<span style=""font-size:1rem;font-weight:700;color:#1e293b;line-height:1.3;" +
                @"background:linear-gradient(135deg, #1e293b 0%, #334155 100%);" +
                @"-webkit-background-clip:text;-webkit-text-fill-color:transparent;" +
                @"background-clip:text;"">" + msgTitle + @"</span>"
              + (
                  isPcalStaff && !(Util.IsNullOrEmpty(senderClientName)) ?
                    @"<span style=""font-size:0.85rem;color:#64748b;margin-left:0.5rem;font-weight:500;" +
                    @"opacity:0.8;"">— " + senderClientName + @"</span>"
                  : ""
                )
              + @"</div>"
              // Email con icono
              + (String.IsNullOrEmpty(senderEmail) ? "" :
                  @"<div class=""d-flex align-items-center"">" +
                  @"<i class=""fas fa-envelope"" style=""font-size:0.7rem;color:#94a3b8;margin-right:0.35rem;""></i>" +
                  @"<span style=""font-size:0.8rem;color:#64748b;font-weight:500;"">" + senderEmail + @"</span>" +
                  @"</div>"
                )
              + @"</div>"
              // Fecha con badge estilo
              + @"<div style=""margin-left:auto;padding-left:1rem;"">"
              + @"<span style=""font-size:0.75rem;color:#475569;font-weight:600;" +
                @"background:rgba(100, 116, 139, 0.1);padding:0.2rem 0.6rem;" +
                @"border-radius:10px;white-space:nowrap;"">" + msgDate + @"</span>"
              + @"</div>"
              + @"</div>"
              // Texto del mensaje con separador sutil
              + @"<div style=""margin-top:0.25rem;padding-left:0.75rem;border-left:2px solid rgba(59, 130, 246, 0.2);"">"
              + @"<span style=""font-size:0.9rem;color:#475569;line-height:1.5;display:block;" +
                @"font-weight:400;letter-spacing:0.01em;"">" + msgText + @"</span>"
              + @"</div>"
              + @"</div>";
        }

        public static string generatePreviewMsg(string msgFaIcon, string msgTitle, string msgDate, string msgText, string msgToolTip, string actionUrl, bool actionUrlIsNewTab = false)
        {
            string _targetMkup = @"";
            if (String.IsNullOrWhiteSpace(msgDate)) msgDate = DateTime.Now.ToShortDateString();
            if (actionUrlIsNewTab == true) _targetMkup = @" target=""_blank""";
            string _previewMsg = @"<a class=""mba-messages-widget-message-preview-container"" title=""" + msgToolTip + @""" href=""" + actionUrl + @""""
                                 + _targetMkup
                                 + @">"
                                 + generatePreviewMsgContent(msgFaIcon, msgTitle, msgDate, msgText)
                                 + @"</a>";
            return _previewMsg;
        }
        public static string generateNotificationPreviewMsg(string msgTitle, string msgDate, string msgText, string msgToolTip, string actionUrl)
        {
            return generatePreviewMsg(@"fas fa-bell", msgTitle, msgDate, msgText, msgToolTip, actionUrl);
        }
        public static string generateAnnouncementPreviewMsg(string msgDate, string msgText, string actionUrl)
        {
            return generatePreviewMsg(@"fa fa-bullhorn", @"New Announcement", msgDate, msgText, @"Click here to read the rest of the announcement", actionUrl, true);
        }

        public static string generateMessagePreviewMsg(string msgSenderName, string msgCreatedStr, string msgSubject, string senderEmail = "", string senderClientName = "", bool isPcalStaff = false)
        {
            string _previewMsg = @"<span class=""mba-messages-widget-message-preview-container"" title=""Click here to read the rest of the message"">"
                               + generatePreviewMsgContent(@"fa fa-envelope", "Message From " + msgSenderName, msgCreatedStr, msgSubject, senderEmail, senderClientName, isPcalStaff)
                               + @"</span>";
            return _previewMsg;
        }

    }

}
