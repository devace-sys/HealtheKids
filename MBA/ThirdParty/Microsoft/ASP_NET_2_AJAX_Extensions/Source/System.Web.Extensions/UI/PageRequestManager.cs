
namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.Collections.Specialized;
    using System.Diagnostics;
    using System.Globalization;
    using System.IO;
    using System.Security;
    using System.Text;
    using System.Web;
    using System.Web.Configuration;
    using System.Web.UI;
    using System.Web.UI.HtmlControls;
    using System.Web.Resources;
    using System.Web.Script.Serialization;
    using System.Reflection;
    using System.Security.Permissions;

    internal sealed class PageRequestManager {

        
        internal const string PageRedirectToken = "pageRedirect";
        internal const string HiddenFieldToken = "hiddenField";
        private const string AsyncPostBackControlIDsToken = "asyncPostBackControlIDs";
        private const string PostBackControlIDsToken = "postBackControlIDs";
        private const string UpdatePanelIDsToken = "updatePanelIDs";
        private const string AsyncPostBackTimeoutToken = "asyncPostBackTimeout";
        private const string ChildUpdatePanelIDsToken = "childUpdatePanelIDs";
        private const string UpdatePanelsToRefreshToken = "panelsToRefreshIDs";
        private const string FormActionToken = "formAction";
        private const string DataItemToken = "dataItem";
        private const string DataItemJsonToken = "dataItemJson";
        internal const string ArrayDeclarationToken = "arrayDeclaration";
        internal const string ExpandoToken = "expando";
        internal const string OnSubmitToken = "onSubmit";
        internal const string ScriptBlockToken = "scriptBlock";
        internal const string ScriptDisposeToken = "scriptDispose";
        private const string ErrorToken = "error";
        private const string PageTitleToken = "pageTitle";
        private const string FocusToken = "focus";

        private const char LengthEncodeDelimiter = '|';
        private static readonly Version MinimumW3CDomVersion = new Version(1, 0);
        private static readonly Version MinimumEcmaScriptVersion = new Version(1, 0);

        private ScriptManager _owner;

        private List<UpdatePanel> _allUpdatePanels;
        private List<UpdatePanel> _updatePanelsToRefresh;
        private List<UpdatePanel> _childUpdatePanelsToRefresh;
        private List<Control> _asyncPostBackControls;
        private List<Control> _postBackControls;
        private ScriptDataItemCollection _scriptDataItems;
        private string _updatePanelRequiresUpdate;
        private HtmlTextWriter _updatePanelWriter;
        private bool _panelsInitialized;
        private string _asyncPostBackSourceElementID;

        
        private static readonly Version FocusMinimumEcmaVersion = new Version("1.4");
        private static readonly Version FocusMinimumJScriptVersion = new Version("3.0");
        private string _focusedControlID;
        private Control _focusedControl;
        private bool _requireFocusScript;

        private static readonly object _reflectionLock = new object();
        private static PropertyInfo _enableLegacyRenderingPropertyInfo;

        public PageRequestManager(ScriptManager owner) {
            Debug.Assert(owner != null);
            _owner = owner;
        }


        public string AsyncPostBackSourceElementID {
            get {
                if (_asyncPostBackSourceElementID == null) {
                    return String.Empty;
                }
                return _asyncPostBackSourceElementID;
            }
        }

        
        private bool ClientSupportsFocus {
            get {
                IHttpBrowserCapabilities browser = _owner.IPage.Request.Browser;
                return
                    (browser.EcmaScriptVersion >= FocusMinimumEcmaVersion) ||
                    (browser.JScriptVersion >= FocusMinimumJScriptVersion);
            }
        }

        private bool EnableLegacyRendering {
            [
            ReflectionPermission(SecurityAction.Assert, Unrestricted = true),
            SecurityCritical,
            SecurityTreatAsSafe
            ]
            get {
                if (_enableLegacyRenderingPropertyInfo == null) {
                    lock (_reflectionLock) {
                        if (_enableLegacyRenderingPropertyInfo == null) {
                            _enableLegacyRenderingPropertyInfo = typeof(ScriptManager).GetProperty("EnableLegacyRendering", BindingFlags.NonPublic | BindingFlags.Instance);
                        }
                    }
                }
                return (bool)_enableLegacyRenderingPropertyInfo.GetValue(_owner, null);
            }
        }

        [SecurityCritical()]
        [SecurityTreatAsSafe()]
        private bool CustomErrorsSectionHasRedirect(int httpCode) {
            bool hasRedirect = (_owner.CustomErrorsSection.DefaultRedirect != null);
            if (!hasRedirect) {
                if (_owner.CustomErrorsSection.Errors != null) {
                    foreach (CustomError error in _owner.CustomErrorsSection.Errors) {
                        if (error.StatusCode == httpCode) {
                            hasRedirect = true;
                            break;
                        }
                    }
                }
            }
            return hasRedirect;
        }

        
        
        
        internal static void EncodeString(TextWriter writer, string type, string id, string content) {
            Debug.Assert(!String.IsNullOrEmpty(type), "Type should always be specified");
            if (id == null) {
                id = String.Empty;
            }
            if (content == null) {
                content = String.Empty;
            }
            Debug.Assert(type.IndexOf(LengthEncodeDelimiter) == -1, "Should not be a " + LengthEncodeDelimiter + " in type");
            Debug.Assert(id.IndexOf(LengthEncodeDelimiter) == -1, "Should not be a " + LengthEncodeDelimiter + " in id");

            
            
            int charsToBeEncoded = 0;
            for (int i = 0; i < content.Length; i++) {
                if (content[i] == '\u00FF') {
                    charsToBeEncoded += 1;
                }
                else {
                    if (content[i] == '\u0000') {
                        charsToBeEncoded += 2;
                    }
                }
            }

            
            

            writer.Write((content.Length + charsToBeEncoded).ToString(CultureInfo.InvariantCulture));
            writer.Write(LengthEncodeDelimiter);
            writer.Write(type);
            writer.Write(LengthEncodeDelimiter);
            writer.Write(id);
            writer.Write(LengthEncodeDelimiter);

            int writtenUpToIndex = 0;

            char[] contentArray = content.ToCharArray();

            for (int i = 0; i < contentArray.Length; i++) {
                if (contentArray[i] == '\u00FF') {
                    writer.Write(contentArray, writtenUpToIndex, i - writtenUpToIndex);
                    writer.Write("\u00FF\u00FF");
                    writtenUpToIndex = i + 1;
                }
                else {
                    if (contentArray[i] == '\u0000') {
                        writer.Write(contentArray, writtenUpToIndex, i - writtenUpToIndex);
                        writer.Write("\\\u00FF\\");
                        writtenUpToIndex = i + 1;
                    }
                }
            }
            writer.Write(contentArray, writtenUpToIndex, contentArray.Length - writtenUpToIndex);

            writer.Write(LengthEncodeDelimiter);
        }

        private string GetAllUpdatePanelIDs() {
            return GetUpdatePanelIDsFromList(_allUpdatePanels, true);
        }

        private string GetAsyncPostBackControlIDs(bool includeQuotes) {
            return GetControlIDsFromList(_asyncPostBackControls, includeQuotes);
        }

        private string GetChildUpdatePanelIDs() {
            return GetUpdatePanelIDsFromList(_childUpdatePanelsToRefresh, false);
        }

        private static string GetControlIDsFromList(List<Control> list, bool includeQuotes) {
            if (list != null && list.Count > 0) {
                StringBuilder asyncPostBackControlIDs = new StringBuilder();
                bool first = true;
                for (int i = 0; i < list.Count; i++) {
                    if (!list[i].Visible) {
                        
                        continue;
                    }
                    if (!first) {
                        asyncPostBackControlIDs.Append(',');
                    }
                    first = false;
                    if (includeQuotes) {
                        asyncPostBackControlIDs.Append('\'');
                    }
                    asyncPostBackControlIDs.Append(list[i].UniqueID);
                    if (includeQuotes) {
                        asyncPostBackControlIDs.Append('\'');
                    }
                }
                return asyncPostBackControlIDs.ToString();
            }
            return String.Empty;
        }

        private static Exception GetControlRegistrationException(Control control) {
            if (control == null) {
                return new ArgumentNullException("control");
            }
            if (control is Page) {
                return new ArgumentException(AtlasWeb.ScriptManager_CannotRegisterPage);
            }
            if (!(control is INamingContainer) &&
                !(control is IPostBackDataHandler) &&
                !(control is IPostBackEventHandler)) {
                return new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptManager_InvalidControlRegistration, control.ID));
            }
            return null;
        }

        
        private static int GetHttpCodeForException(Exception e) {
            HttpException he = e as HttpException;
            if (he != null) {
                return he.GetHttpCode();
            }
            else if (e is UnauthorizedAccessException) {
                return 401;
            }
            else if (e is PathTooLongException) {
                return 414;
            }

            
            if (e.InnerException != null)
                return GetHttpCodeForException(e.InnerException);

            
            return 500;
        }

        private string GetPostBackControlIDs(bool includeQuotes) {
            return GetControlIDsFromList(_postBackControls, includeQuotes);
        }

        private string GetRefreshingUpdatePanelIDs() {
            return GetUpdatePanelIDsFromList(_updatePanelsToRefresh, false);
        }

        private static string GetUpdatePanelIDsFromList(List<UpdatePanel> list, bool includeChildrenAsTriggersPrefix) {
            if (list != null && list.Count > 0) {
                StringBuilder updatePanelIDs = new StringBuilder();
                bool first = true;
                for (int i = 0; i < list.Count; i++) {
                    if (!list[i].Visible) {
                        
                        continue;
                    }
                    if (!first) {
                        updatePanelIDs.Append(',');
                    }
                    first = false;
                    
                    
                    

                    
                    
                    if (includeChildrenAsTriggersPrefix) {
                        updatePanelIDs.Append(list[i].ChildrenAsTriggers ? 't' : 'f');
                    }
                    updatePanelIDs.Append(list[i].UniqueID);
                }
                return updatePanelIDs.ToString();
            }
            return String.Empty;
        }

        internal static bool IsAsyncPostBackRequest(NameValueCollection headers) {
            
            
            
            

            
            
            
            string[] headerValues = headers.GetValues("X-MicrosoftAjax");
            if (headerValues != null) {
                for (int i = 0; i < headerValues.Length; i++) {
                    string[] headerContents = headerValues[i].Split(',');
                    for (int j = 0; j < headerContents.Length; j++) {
                        if (headerContents[j].Trim() == "Delta=true") {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        private static bool IsBuiltInHiddenField(string hiddenFieldName) {
            
            
            
            

            
            if (hiddenFieldName.Length <= 2) {
                return false;
            }

            
            if (hiddenFieldName[0] != '_' ||
                hiddenFieldName[1] != '_') {
                return false;
            }

            
            
            
            
            return
                hiddenFieldName.StartsWith("__VIEWSTATE", StringComparison.Ordinal) ||
                String.Equals(hiddenFieldName, "__EVENTVALIDATION", StringComparison.Ordinal) ||
                String.Equals(hiddenFieldName, "__LASTFOCUS", StringComparison.Ordinal) ||
                String.Equals(hiddenFieldName, "__SCROLLPOSITIONX", StringComparison.Ordinal) ||
                String.Equals(hiddenFieldName, "__SCROLLPOSITIONY", StringComparison.Ordinal) ||
                String.Equals(hiddenFieldName, "__EVENTTARGET", StringComparison.Ordinal) ||
                String.Equals(hiddenFieldName, "__EVENTARGUMENT", StringComparison.Ordinal) ||
                String.Equals(hiddenFieldName, "__PREVIOUSPAGE", StringComparison.Ordinal);
        }

        internal void LoadPostData(string postDataKey, NameValueCollection postCollection) {
            
            
            
            
            
            string postBackSourceInfo = postCollection[postDataKey];
            if (postBackSourceInfo != null) {
                string postBackTarget; 

                int indexOfPipe = postBackSourceInfo.IndexOf('|');
                if (indexOfPipe != -1) {
                    
                    postBackTarget = postBackSourceInfo.Substring(0, indexOfPipe);
                    _asyncPostBackSourceElementID = postBackSourceInfo.Substring(indexOfPipe + 1);
                }
                else {
                    
                    postBackTarget = postBackSourceInfo;
                    _asyncPostBackSourceElementID = String.Empty;
                }

                if (postBackTarget != _owner.UniqueID) {
                    _updatePanelRequiresUpdate = postBackTarget;
                }
            }

            
            
            
            
            
            
            
            if ((_allUpdatePanels != null) && (_allUpdatePanels.Count != 0)) {
                foreach (UpdatePanel panel in _allUpdatePanels) {
                    panel.Initialize();
                }
            }

            _panelsInitialized = true;
        }

        internal void OnInit() {
            
            
            if (_owner.EnablePartialRendering && !_owner._supportsPartialRenderingSetByUser) {
                IHttpBrowserCapabilities browser = _owner.IPage.Request.Browser;
                
                
                
                
                bool supportsPartialRendering =
                    (browser.W3CDomVersion >= MinimumW3CDomVersion) &&
                    (browser.EcmaScriptVersion >= MinimumEcmaScriptVersion) &&
                    browser.SupportsCallback;
                if (supportsPartialRendering) {
                    
                    
                    supportsPartialRendering = !EnableLegacyRendering;
                }
                _owner.SupportsPartialRendering = supportsPartialRendering;
            }

            if (_owner.IsInAsyncPostBack) {
                _owner.IPage.Error += OnPageError;
            }
        }

        private void OnPageError(object sender, EventArgs e) {
            Exception ex = _owner.IPage.Server.GetLastError();
            _owner.OnAsyncPostBackError(new AsyncPostBackErrorEventArgs(ex));

            string errorMessage = _owner.AsyncPostBackErrorMessage;
            if (String.IsNullOrEmpty(errorMessage) && !_owner.Control.Context.IsCustomErrorEnabled) {
                
                errorMessage = ex.Message;
            }

            int httpCode = GetHttpCodeForException(ex);

            bool showAsyncErrorMessage = false;

            if (_owner.AllowCustomErrorsRedirect && _owner.Control.Context.IsCustomErrorEnabled) {
                
                bool hasRedirect = CustomErrorsSectionHasRedirect(httpCode);
                if (!hasRedirect) {
                    
                    showAsyncErrorMessage = true;
                }
                
                
                
            }
            else {
                
                showAsyncErrorMessage = true;
            }

            if (showAsyncErrorMessage) {
                _owner.IPage.Response.Clear();
                EncodeString(_owner.IPage.Response.Output, ErrorToken, httpCode.ToString(CultureInfo.InvariantCulture), errorMessage);
                _owner.IPage.Response.End();
            }
        }

        internal void OnPreRender() {
            _owner.IPage.SetRenderMethodDelegate(RenderPageCallback);
        }

        private void ProcessFocus(HtmlTextWriter writer) {
            
            if (_requireFocusScript) {
                Debug.Assert(ClientSupportsFocus, "If ClientSupportsFocus is false then we never should have set _requireFocusScript to true.");
                string focusedControlId = String.Empty;

                
                if (!String.IsNullOrEmpty(_focusedControlID)) {
                    focusedControlId = _focusedControlID;
                }
                else {
                    if (_focusedControl != null && _focusedControl.Visible) {
                        focusedControlId = _focusedControl.ClientID;
                    }
                }
                if (focusedControlId.Length > 0) {
                    
                    string focusResourceUrl = _owner.GetScriptResourceUrl("Focus.js", typeof(HtmlForm).Assembly);
                    EncodeString(writer, ScriptBlockToken, "ScriptPath", focusResourceUrl);

                    
                    EncodeString(writer, FocusToken, String.Empty, focusedControlId);
                }
            }
        }

        private void ProcessScriptRegistration(HtmlTextWriter writer) {
            _owner.ScriptRegistration.RenderActiveArrayDeclarations(_updatePanelsToRefresh, writer);
            _owner.ScriptRegistration.RenderActiveScripts(_updatePanelsToRefresh, writer);
            _owner.ScriptRegistration.RenderActiveSubmitStatements(_updatePanelsToRefresh, writer);
            _owner.ScriptRegistration.RenderActiveExpandos(_updatePanelsToRefresh, writer);
            _owner.ScriptRegistration.RenderActiveHiddenFields(_updatePanelsToRefresh, writer);
            _owner.ScriptRegistration.RenderActiveScriptDisposes(_updatePanelsToRefresh, writer);
        }

        private void ProcessUpdatePanels() {
            Debug.Assert(_owner.IsInAsyncPostBack);
            Debug.Assert(_updatePanelsToRefresh == null);

            if (_allUpdatePanels != null) {
                _updatePanelsToRefresh = new List<UpdatePanel>(_allUpdatePanels.Count);
                _childUpdatePanelsToRefresh = new List<UpdatePanel>(_allUpdatePanels.Count);

                
                

                
                
                
                
                
                
                
                

                HtmlForm form = _owner.Page.Form;

                for (int i = 0; i < _allUpdatePanels.Count; i++) {
                    UpdatePanel panel = _allUpdatePanels[i];

                    
                    
                    
                    
                    
                    

                    bool panelUpdatedByClient =
                        _updatePanelRequiresUpdate != null &&
                        String.Equals(panel.UniqueID, _updatePanelRequiresUpdate, StringComparison.Ordinal);
                    bool requiresUpdate = panelUpdatedByClient || panel.RequiresUpdate;

                    
                    
                    
                    
                    
                    
                    
                    Control parent = panel.Parent;
                    while (parent != form) {
                        UpdatePanel parentUpdatePanel = parent as UpdatePanel;
                        if ((parentUpdatePanel != null) &&
                            (_updatePanelsToRefresh.Contains(parentUpdatePanel) || _childUpdatePanelsToRefresh.Contains(parentUpdatePanel))) {
                            
                            
                            requiresUpdate = false;
                            _childUpdatePanelsToRefresh.Add(panel);
                            break;
                        }

                        parent = parent.Parent;

                        if (parent == null) {
                            
                            
                            
                            
                            requiresUpdate = false;
                            break;
                        }
                    }

                    if (requiresUpdate) {
                        panel.SetAsyncPostBackMode(true);
                        _updatePanelsToRefresh.Add(panel);
                    }
                    else {
                        panel.SetAsyncPostBackMode(false);
                    }
                }
            }
        }

        public void RegisterAsyncPostBackControl(Control control) {
            Exception ex = GetControlRegistrationException(control);
            if (ex != null) {
                throw ex;
            }
            if (_postBackControls != null && _postBackControls.Contains(control)) {
                throw new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptManager_CannotRegisterBothPostBacks, control.ID));
            }
            if (_asyncPostBackControls == null) {
                _asyncPostBackControls = new List<Control>();
            }
            
            
            if (!_asyncPostBackControls.Contains(control)) {
                _asyncPostBackControls.Add(control);
            }
        }

        public void RegisterDataItem(Control control, string dataItem, bool isJsonSerialized) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (!_owner.IsInAsyncPostBack) {
                throw new InvalidOperationException(AtlasWeb.PageRequestManager_RegisterDataItemInNonAsyncRequest);
            }
            if (_scriptDataItems == null) {
                _scriptDataItems = new ScriptDataItemCollection();
            }
            else {
                if (_scriptDataItems.ContainsControl(control)) {
                    throw new ArgumentException(
                        String.Format(
                            CultureInfo.InvariantCulture,
                            AtlasWeb.PageRequestManager_RegisterDataItemTwice,
                            control.ID),
                        "control");
                }
            }
            _scriptDataItems.Add(new ScriptDataItem(control, dataItem, isJsonSerialized));
        }

        private void RegisterFocusScript() {
            if (ClientSupportsFocus && !_requireFocusScript) {
                _requireFocusScript = true;
            }
        }

        public void RegisterPostBackControl(Control control) {
            Exception ex = GetControlRegistrationException(control);
            if (ex != null) {
                throw ex;
            }
            if (_asyncPostBackControls != null && _asyncPostBackControls.Contains(control)) {
                throw new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptManager_CannotRegisterBothPostBacks, control.ID));
            }
            if (_postBackControls == null) {
                _postBackControls = new List<Control>();
            }
            
            
            if (!_postBackControls.Contains(control)) {
                _postBackControls.Add(control);
            }
        }

        internal void RegisterUpdatePanel(UpdatePanel updatePanel) {
            Debug.Assert(updatePanel != null);
            if (_allUpdatePanels == null) {
                _allUpdatePanels = new List<UpdatePanel>();
            }
            Debug.Assert(!_allUpdatePanels.Contains(updatePanel),
                String.Format(CultureInfo.InvariantCulture, "The UpdatePanel with ID '{0}' has already been registered with the ScriptManager.", updatePanel.ID));
            _allUpdatePanels.Add(updatePanel);

            if (_panelsInitialized) {
                
                
                Debug.Assert(_owner.IsInAsyncPostBack, "Catch-up initialization should only be done in async posts.");
                updatePanel.Initialize();
            }
        }

        internal void Render(HtmlTextWriter writer) {
            if (!((IControl)_owner).DesignMode && !_owner.IsInAsyncPostBack && _owner.SupportsPartialRendering) {
                _owner.IPage.VerifyRenderingInServerForm(_owner);
                RenderPageRequestManagerScript(writer);
            }
        }

        private void RenderFormCallback(HtmlTextWriter writer, Control containerControl) {

            Debug.Assert(_updatePanelWriter != null, "_updatePanelWriter should be set by RenderPageCallback before RenderFormCallback is called.");

            ParserStringWriter parserWriter = writer.InnerWriter as ParserStringWriter;
            
            parserWriter.ParseWrites = false;


            
            
            if (_updatePanelsToRefresh != null) {
                foreach (UpdatePanel panel in _updatePanelsToRefresh) {
                    if (panel.Visible) {
                        
                        
                        
                        panel.RenderControl(_updatePanelWriter);
                    }
                }
            }

            if (_owner.IPage.EnableEventValidation) {
                
                
                
                
                

                
                
                
                
                _owner.IPage.Response.Flush();
                NullStream nullStream = new NullStream(_owner.IPage.Response.Filter);
                nullStream.AllowWrites = false;
                try {
                    _owner.IPage.Response.Filter = nullStream;

                    HtmlTextWriter dummyWriter = new HtmlTextWriter(TextWriter.Null);
                    foreach (Control control in containerControl.Controls) {
                        control.RenderControl(dummyWriter);
                    }
                }
                finally {
                    
                    
                    _owner.IPage.Response.Flush();
                    nullStream.AllowWrites = true;
                }
            }

            
            parserWriter.ParseWrites = true;
        }

        private void RenderPageCallback(HtmlTextWriter writer, Control pageControl) {
            ProcessUpdatePanels();

            
            
            

            IHttpResponse response = _owner.IPage.Response;

            response.ContentType = "text/plain";
            response.Cache.SetNoServerCaching();

            
            
            
            IHtmlForm formControl = _owner.IPage.Form;
            formControl.SetRenderMethodDelegate(RenderFormCallback);

            
            _updatePanelWriter = writer;

            
            ParserStringWriter parserWriter = new ParserStringWriter();
            ParserHtmlTextWriter formWriter = new ParserHtmlTextWriter(parserWriter);
            parserWriter.ParseWrites = true;
            formControl.RenderControl(formWriter);
            parserWriter.ParseWrites = false;

            
            
            
            foreach (KeyValuePair<string, string> hiddenField in parserWriter.HiddenFields) {
                if (IsBuiltInHiddenField(hiddenField.Key)) {
                    EncodeString(writer, HiddenFieldToken, hiddenField.Key, hiddenField.Value);
                }
            }

            
            
            
            EncodeString(writer, AsyncPostBackControlIDsToken, String.Empty, GetAsyncPostBackControlIDs(false));
            EncodeString(writer, PostBackControlIDsToken, String.Empty, GetPostBackControlIDs(false));
            EncodeString(writer, UpdatePanelIDsToken, String.Empty, GetAllUpdatePanelIDs());
            EncodeString(writer, ChildUpdatePanelIDsToken, String.Empty, GetChildUpdatePanelIDs());
            EncodeString(writer, UpdatePanelsToRefreshToken, String.Empty, GetRefreshingUpdatePanelIDs());
            EncodeString(writer, AsyncPostBackTimeoutToken, String.Empty, _owner.AsyncPostBackTimeout.ToString(CultureInfo.InvariantCulture));
            if (formWriter.FormAction != null) {
                EncodeString(writer, FormActionToken, String.Empty, formWriter.FormAction);
            }
            if (_owner.IPage.Header != null) {
                string pageTitle = _owner.IPage.Title;
                if (!String.IsNullOrEmpty(pageTitle)) {
                    EncodeString(writer, PageTitleToken, String.Empty, pageTitle);
                }
            }
            RenderDataItems(writer);

            ProcessScriptRegistration(writer);

            
            
            
            ProcessFocus(writer);
        }

        private void RenderDataItems(HtmlTextWriter writer) {
            if (_scriptDataItems != null) {
                foreach (ScriptDataItem dataItem in _scriptDataItems) {
                    EncodeString(
                        writer,
                        dataItem.IsJsonSerialized ? DataItemJsonToken : DataItemToken,
                        dataItem.Control.ClientID,
                        dataItem.DataItem);
                }
            }
        }

        internal void RenderPageRequestManagerScript(HtmlTextWriter writer) {
            
            
            
            
            
            

            
            
            
            
            
            
            
            

            
            

            writer.Write(@"<script type=""text/javascript"">
//<![CDATA[
Sys.WebForms.PageRequestManager._initialize('");
            writer.Write(_owner.UniqueID);
            writer.Write(@"', document.getElementById('");
            writer.Write(_owner.IPage.Form.ClientID);
            writer.Write(@"'));
Sys.WebForms.PageRequestManager.getInstance()._updateControls([");
            RenderUpdatePanelIDsFromList(writer, _allUpdatePanels);
            writer.Write("], [");
            writer.Write(GetAsyncPostBackControlIDs(true));
            writer.Write("], [");
            writer.Write(GetPostBackControlIDs(true));
            writer.Write("], ");
            writer.Write(_owner.AsyncPostBackTimeout.ToString(CultureInfo.InvariantCulture));
            writer.WriteLine(");");
            writer.Write(@"//]]>
</script>
");
        }

        private static void RenderUpdatePanelIDsFromList(HtmlTextWriter writer, List<UpdatePanel> list) {
            
            
            if (list != null && list.Count > 0) {
                bool first = true;
                for (int i = 0; i < list.Count; i++) {
                    if (!list[i].Visible) {
                        
                        continue;
                    }
                    if (!first) {
                        writer.Write(',');
                    }
                    first = false;
                    writer.Write('\'');

                    
                    
                    

                    
                    
                    writer.Write(list[i].ChildrenAsTriggers ? 't' : 'f');
                    writer.Write(list[i].UniqueID);

                    writer.Write('\'');
                }
            }
        }

        public void SetFocus(Control control) {
            
            _owner.IPage.SetFocus(control);

            
            
            if (_owner.IsInAsyncPostBack) {
                _focusedControl = control;
                _focusedControlID = null;
                RegisterFocusScript();
            }
        }

        public void SetFocus(string clientID) {
            
            _owner.IPage.SetFocus(clientID);

            
            
            if (_owner.IsInAsyncPostBack) {
                _focusedControlID = clientID.Trim();
                _focusedControl = null;
                RegisterFocusScript();
            }
        }

        internal void UnregisterUpdatePanel(UpdatePanel updatePanel) {
            Debug.Assert(updatePanel != null);
            if ((_allUpdatePanels == null) || !_allUpdatePanels.Contains(updatePanel)) {
                throw new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptManager_UpdatePanelNotRegistered, updatePanel.ID), "updatePanel");
            }
            _allUpdatePanels.Remove(updatePanel);
        }

        
        
        
        
        private sealed class ParserStringWriter : StringWriter {
            private enum ParserState {
                Ready = 0,
                ReadHiddenFieldNameValue = 1,
                ReadHiddenFieldIdAttribute = 2,
                ReadHiddenFieldIdValue = 3,
                ReadHiddenFieldValueAttribute = 4,
                ReadHiddenFieldValueValue = 5,
            }

            private bool _parseWrites;

            private List<string> _pendingWrites = new List<string>();

            private ParserState _parserState = ParserState.Ready;
            private bool _secondTry; 
            private string _proposedHiddenFieldName = String.Empty;
            private string _matchingHiddenFieldName = String.Empty;
            private StringBuilder _proposedHiddenFieldValue = new StringBuilder();

            private Dictionary<string, string> _hiddenFields = new Dictionary<string, string>();

            public ParserStringWriter()
                : base(CultureInfo.CurrentCulture) {
            }

            
            public IDictionary<string, string> HiddenFields {
                get {
                    return _hiddenFields;
                }
            }

            
            
            public bool ParseWrites {
                get {
                    return _parseWrites;
                }
                set {
                    _parseWrites = value;
                }
            }

            private void FlushPendingWrites() {
                if (_pendingWrites.Count > 0) {
                    foreach (string pendingWrite in _pendingWrites) {
                        base.Write(pendingWrite);
                    }
                    _pendingWrites.Clear();
                }
            }

            private void ParseString(string s) {
                switch (_parserState) {
                    case ParserState.Ready:
                        if (s == "<input type=\"hidden\" name=\"") {
                            _parserState = ParserState.ReadHiddenFieldNameValue;
                            _pendingWrites.Add(s);
                            break;
                        }
                        else {
                            goto default;
                        }

                    case ParserState.ReadHiddenFieldNameValue:
                    RetryHiddenFieldName:
                        _proposedHiddenFieldName += s;
                        _pendingWrites.Add(s);
                        _parserState = ParserState.ReadHiddenFieldIdAttribute;
                        break;

                    case ParserState.ReadHiddenFieldIdAttribute:
                        if (s == "\" id=\"") {
                            _parserState = ParserState.ReadHiddenFieldIdValue;
                            _pendingWrites.Add(s);
                            _secondTry = false;
                            break;
                        }
                        else {
                            if (!_secondTry) {
                                
                                
                                _secondTry = true;
                                goto RetryHiddenFieldName;
                            }
                            
                            
                            _parserState = ParserState.Ready;
                            goto default;
                        }

                    case ParserState.ReadHiddenFieldIdValue:
                    RetryHiddenFieldId:
                        _matchingHiddenFieldName += s;
                        _pendingWrites.Add(s);
                        _parserState = ParserState.ReadHiddenFieldValueAttribute;
                        break;

                    case ParserState.ReadHiddenFieldValueAttribute:
                        if ((_matchingHiddenFieldName == _proposedHiddenFieldName) &&
                            (s == "\" value=\"")) {
                            _parserState = ParserState.ReadHiddenFieldValueValue;
                            _pendingWrites.Add(s);
                            _secondTry = false;
                            break;
                        }
                        else {
                            if (!_secondTry) {
                                
                                
                                _secondTry = true;
                                goto RetryHiddenFieldId;
                            }
                            _parserState = ParserState.Ready;
                            goto default;
                        }

                    case ParserState.ReadHiddenFieldValueValue:
                        if (s != "\" />") {
                            _proposedHiddenFieldValue.Append(s);
                        }
                        else {
                            
                            _pendingWrites.Clear();
                            _hiddenFields.Add(_proposedHiddenFieldName, _proposedHiddenFieldValue.ToString());
                            _proposedHiddenFieldName = String.Empty;
                            _matchingHiddenFieldName = String.Empty;
                            _proposedHiddenFieldValue = new StringBuilder();
                            _parserState = ParserState.Ready;
                        }
                        break;

                    default:
                        _secondTry = false;
                        FlushPendingWrites();
                        base.Write(s);
                        break;
                }
            }

            public override void Write(string s) {
                if (!ParseWrites) {
                    base.Write(s);
                    return;
                }

                ParseString(s);
            }

            public override void WriteLine(string value) {
                if (!ParseWrites) {
                    base.WriteLine(value);
                    return;
                }

                
                
                ParseString(value);
                ParseString(NewLine);
            }
        }

        private sealed class ParserHtmlTextWriter : HtmlTextWriter {
            private bool _writingForm;
            private string _formAction;

            public string FormAction {
                get {
                    return _formAction;
                }
            }


            public ParserHtmlTextWriter(TextWriter writer)
                : base(writer) {
            }


            public override void WriteBeginTag(string tagName) {
                base.WriteBeginTag(tagName);

                
                _writingForm = (tagName == "form");
            }

            public override void WriteAttribute(string name, string value, bool fEncode) {
                base.WriteAttribute(name, value, fEncode);

                
                if (_writingForm) {
                    if (name == "action") {
                        _formAction = value;
                    }
                }
            }
        }

        private sealed class ScriptDataItem {
            private Control _control;
            private string _dataItem;
            private bool _isJsonSerialized;

            public ScriptDataItem(Control control, string dataItem, bool isJsonSerialized) {
                _control = control;
                _dataItem = (dataItem == null) ? String.Empty : dataItem;
                _isJsonSerialized = isJsonSerialized;
            }

            public Control Control {
                get {
                    return _control;
                }
            }

            public string DataItem {
                get {
                    return _dataItem;
                }
            }

            public bool IsJsonSerialized {
                get {
                    return _isJsonSerialized;
                }
            }
        }

        private sealed class ScriptDataItemCollection : List<ScriptDataItem> {
            public bool ContainsControl(Control control) {
                foreach (ScriptDataItem dataItem in this) {
                    if (dataItem.Control == control) {
                        return true;
                    }
                }
                return false;
            }
        }

        private sealed class NullStream : Stream {
            private bool _allowWrites;
            private Stream _oldStream;

            public NullStream(Stream oldStream) {
                _oldStream = oldStream;
            }

            public bool AllowWrites {
                get {
                    return _allowWrites;
                }
                set {
                    _allowWrites = value;
                }
            }

            public override bool CanRead {
                get {
                    return _oldStream.CanRead;
                }
            }

            public override bool CanSeek {
                get {
                    return _oldStream.CanSeek;
                }
            }

            public override bool CanWrite {
                get {
                    return _oldStream.CanWrite;
                }
            }

            public override long Length {
                get {
                    return _oldStream.Length;
                }
            }

            public override long Position {
                get {
                    return _oldStream.Position;
                }
                set {
                    _oldStream.Position = value;
                }
            }

            public override void Flush() {
                _oldStream.Flush();
            }

            public override int Read(byte[] buffer, int offset, int count) {
                return _oldStream.Read(buffer, offset, count);
            }

            public override long Seek(long offset, SeekOrigin origin) {
                return _oldStream.Seek(offset, origin);
            }

            public override void SetLength(long value) {
                _oldStream.SetLength(value);
            }

            public override void Write(byte[] buffer, int offset, int count) {
                if (AllowWrites) {
                    _oldStream.Write(buffer, offset, count);
                }
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
