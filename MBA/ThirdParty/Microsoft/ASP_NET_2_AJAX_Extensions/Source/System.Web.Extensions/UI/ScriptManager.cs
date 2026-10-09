namespace System.Web.UI {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Collections.Specialized;
    using System.ComponentModel;
    using System.Configuration;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Drawing;
    using System.Drawing.Design;
    using System.Globalization;
    using System.IO;
    using System.Reflection;
    using System.Security;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;
    using System.Web.Configuration;
    using System.Web.UI;
    using System.Web.UI.HtmlControls;
    using System.Web.Globalization;
    using System.Web.Handlers;
    using System.Web.Resources;
    using System.Web.Script.Serialization;
    using System.Web.Script.Services;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Scripts"),
    Designer("System.Web.UI.Design.ScriptManagerDesigner, " + AssemblyRef.SystemWebExtensionsDesign),
    NonVisualControl(),
    ParseChildren(true),
    PersistChildren(false),
    ToolboxBitmap(typeof(EmbeddedResourceFinder), "System.Web.Resources.ScriptManager.bmp"),
    ]
    public class ScriptManager : Control, IPostBackDataHandler, IControl, IScriptManagerInternal {
        private readonly IPage _page;
        private readonly IControl _control;
        private readonly ICompilationSection _appLevelCompilationSection;
        private readonly IDeploymentSection _deploymentSection;
        private readonly ICustomErrorsSection _customErrorsSection;

        private const int AsyncPostBackTimeoutDefault = 90;

        private ScriptMode _scriptMode;
        private string _scriptPath;
        private ScriptReferenceCollection _scripts;
        private ServiceReferenceCollection _services;
        private List<ScriptManagerProxy> _proxies;
        private bool _enablePartialRendering = true;
        private bool _supportsPartialRendering = true;
        internal bool _supportsPartialRenderingSetByUser;
        private bool _enableScriptGlobalization;
        private bool _enableScriptLocalization;
        private bool _enablePageMethods;
        private bool _loadScriptsBeforeUI = true;
        private bool _initCompleted;
        private bool _isInAsyncPostBack;
        private int _asyncPostBackTimeout = AsyncPostBackTimeoutDefault;
        private bool _allowCustomErrorsRedirect = true;
        private string _asyncPostBackErrorMessage;
        private bool _zip;
        private bool _zipSet;
        private int _uniqueScriptCounter;

        private static readonly object AsyncPostBackErrorEvent = new object();
        private static readonly object ResolveScriptReferenceEvent = new object();
        private ScriptRegistrationManager _scriptRegistration;
        private PageRequestManager _pageRequestManager;

        private ScriptControlManager _scriptControlManager;

        private ProfileServiceManager _profileServiceManager;
        private AuthenticationServiceManager _authenticationServiceManager;
#if ORCAS
        private RoleServiceManager _roleServiceManager;
#endif

        public ScriptManager() {
        }

        internal ScriptManager(IControl control,
                               IPage page,
                               ICompilationSection appLevelCompilationSection,
                               IDeploymentSection deploymentSection,
                               ICustomErrorsSection customErrorsSection) {
            _control = control;
            _page = page;
            _appLevelCompilationSection = appLevelCompilationSection;
            _deploymentSection = deploymentSection;
            _customErrorsSection = customErrorsSection;
        }

        [
        DefaultValue(true),
        ResourceDescription("ScriptManager_AllowCustomErrorsRedirect"),
        Category("Behavior"),
        ]
        public bool AllowCustomErrorsRedirect {
            get {
                return _allowCustomErrorsRedirect;
            }
            set {
                _allowCustomErrorsRedirect = value;
            }
        }

        private ICompilationSection AppLevelCompilationSection {
            get {
                if (_appLevelCompilationSection != null) {
                    return _appLevelCompilationSection;
                }
                else {
                    return AppLevelCompilationSectionCache.Instance;
                }
            }
        }

        [
        DefaultValue(""),
        ResourceDescription("ScriptManager_AsyncPostBackErrorMessage"),
        Category("Behavior"),
        ]
        public string AsyncPostBackErrorMessage {
            get {
                if (_asyncPostBackErrorMessage == null) {
                    return String.Empty;
                }
                return _asyncPostBackErrorMessage;
            }
            set {
                _asyncPostBackErrorMessage = value;
            }
        }

        
        
        
        [
        Browsable(false),
        SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")
        ]
        public string AsyncPostBackSourceElementID {
            get {
                return PageRequestManager.AsyncPostBackSourceElementID;
            }
        }

        [
        ResourceDescription("ScriptManager_AsyncPostBackTimeout"),
        Category("Behavior"),
        DefaultValue(AsyncPostBackTimeoutDefault),
        ]
        public int AsyncPostBackTimeout {
            get {
                return _asyncPostBackTimeout;
            }
            set {
                if (value < 0) {
                    throw new ArgumentOutOfRangeException("value");
                }
                _asyncPostBackTimeout = value;
            }
        }

        [
        ResourceDescription("ScriptManager_AuthenticationService"),
        Category("Behavior"),
        DefaultValue(null),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Content),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public AuthenticationServiceManager AuthenticationService {
            get {
                if (_authenticationServiceManager == null) {
                    _authenticationServiceManager = new AuthenticationServiceManager();
                }
                return _authenticationServiceManager;
            }
        }

        internal IControl Control {
            get {
                if (_control != null) {
                    return _control;
                }
                else {
                    return this;
                }
            }
        }

        internal ICustomErrorsSection CustomErrorsSection {
            [SecurityCritical()]
            get {
                if (_customErrorsSection != null) {
                    return _customErrorsSection;
                }
                else {
                    return GetCustomErrorsSectionWithAssert();
                }
            }
        }

        private IDeploymentSection DeploymentSection {
            get {
                if (_deploymentSection != null) {
                    return _deploymentSection;
                }
                else {
                    return DeploymentSectionCache.Instance;
                }
            }
        }

        internal bool DeploymentSectionRetail {
            get {
                return DeploymentSection.Retail;
            }
        }

        [
        ResourceDescription("ScriptManager_EnablePageMethods"),
        Category("Behavior"),
        DefaultValue(false),
        ]
        public bool EnablePageMethods {
            get {
                return _enablePageMethods;
            }
            set {
                _enablePageMethods = value;
            }
        }

        [
        ResourceDescription("ScriptManager_EnablePartialRendering"),
        Category("Behavior"),
        DefaultValue(true),
        ]
        public bool EnablePartialRendering {
            get {
                return _enablePartialRendering;
            }
            set {
                if (_initCompleted) {
                    throw new InvalidOperationException(AtlasWeb.ScriptManager_CannotChangeEnablePartialRendering);
                }
                _enablePartialRendering = value;
            }
        }

        [
        ResourceDescription("ScriptManager_EnableScriptGlobalization"),
        Category("Behavior"),
        DefaultValue(false),
        ]
        public bool EnableScriptGlobalization {
            get {
                return _enableScriptGlobalization;
            }
            set {
                if (_initCompleted) {
                    throw new InvalidOperationException(AtlasWeb.ScriptManager_CannotChangeEnableScriptGlobalization);
                }
                _enableScriptGlobalization = value;
            }
        }

        [
        ResourceDescription("ScriptManager_EnableScriptLocalization"),
        Category("Behavior"),
        DefaultValue(false),
        ]
        public bool EnableScriptLocalization {
            get {
                return _enableScriptLocalization;
            }
            set {
                _enableScriptLocalization = value;
            }
        }

        internal bool HasAuthenticationServiceManager {
            get {
                return this._authenticationServiceManager != null;
            }
        }

        internal bool HasProfileServiceManager {
            get {
                return this._profileServiceManager != null;
            }
        }

#if ORCAS
        internal bool HasRoleServiceManager {
            get {
                return this._roleServiceManager != null;
            }
        }
#endif

        [Browsable(false)]
        public bool IsDebuggingEnabled {
            get {
                
                
                
                

                if (DeploymentSectionRetail) {
                    return false;
                }
                if (ScriptMode == ScriptMode.Auto || ScriptMode == ScriptMode.Inherit) {
                    return AppLevelCompilationSection.Debug;
                }
                return (ScriptMode == ScriptMode.Debug);
            }
        }

        [
        Browsable(false),
        SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")
        ]
        public bool IsInAsyncPostBack {
            get {
                return _isInAsyncPostBack;
            }
        }

        internal IPage IPage {
            get {
                if (_page != null) {
                    return _page;
                }
                else {
                    Page page = Page;
                    if (page == null) {
                        throw new InvalidOperationException(AtlasWeb.Common_PageCannotBeNull);
                    }
                    return new PageWrapper(page);
                }
            }
        }

        
        [
        ResourceDescription("ScriptManager_LoadScriptsBeforeUI"),
        Category("Behavior"),
        DefaultValue(true),
        ]
        public bool LoadScriptsBeforeUI {
            get {
                return _loadScriptsBeforeUI;
            }
            set {
                _loadScriptsBeforeUI = value;
            }
        }

        private PageRequestManager PageRequestManager {
            get {
                if (_pageRequestManager == null) {
                    _pageRequestManager = new PageRequestManager(this);
                }
                return _pageRequestManager;
            }
        }

        [
        ResourceDescription("ScriptManager_ProfileService"),
        Category("Behavior"),
        DefaultValue(null),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Content),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public ProfileServiceManager ProfileService {
            get {
                if (_profileServiceManager == null) {
                    _profileServiceManager = new ProfileServiceManager();
                }
                return _profileServiceManager;
            }
        }

        internal List<ScriptManagerProxy> Proxies {
            get {
                if (_proxies == null) {
                    _proxies = new List<ScriptManagerProxy>();
                }
                return _proxies;
            }
        }

        [
        Category("Action"),
        ResourceDescription("ScriptManager_AsyncPostBackError"),
        ]
        public event EventHandler<AsyncPostBackErrorEventArgs> AsyncPostBackError {
            add {
                Events.AddHandler(AsyncPostBackErrorEvent, value);
            }
            remove {
                Events.RemoveHandler(AsyncPostBackErrorEvent, value);
            }
        }

        [
        Category("Action"),
        ResourceDescription("ScriptManager_ResolveScriptReference"),
        ]
        public event EventHandler<ScriptReferenceEventArgs> ResolveScriptReference {
            add {
                Events.AddHandler(ResolveScriptReferenceEvent, value);
            }
            remove {
                Events.RemoveHandler(ResolveScriptReferenceEvent, value);
            }
        }

#if ORCAS
        [
        ResourceDescription("ScriptManager_RoleService"),
        Category("Behavior"),
        DefaultValue(null),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Content),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public RoleServiceManager RoleService {
            get {
                if(_roleServiceManager == null) {
                    _roleServiceManager = new RoleServiceManager();
                }
                return _roleServiceManager;
            }
        }
#endif

        internal ScriptControlManager ScriptControlManager {
            get {
                if (_scriptControlManager == null) {
                    _scriptControlManager = new ScriptControlManager(this);
                }
                return _scriptControlManager;
            }
        }

        [
        ResourceDescription("ScriptManager_ScriptMode"),
        Category("Behavior"),
        DefaultValue(ScriptMode.Auto),
        ]
        public ScriptMode ScriptMode {
            get {
                return _scriptMode;
            }
            set {
                if (value < ScriptMode.Auto || value > ScriptMode.Release) {
                    throw new ArgumentOutOfRangeException("value");
                }
                _scriptMode = value;
            }
        }

        internal ScriptRegistrationManager ScriptRegistration {
            get {
                if (_scriptRegistration == null) {
                    _scriptRegistration = new ScriptRegistrationManager(this);
                }
                return _scriptRegistration;
            }
        }

        [
        ResourceDescription("ScriptManager_Scripts"),
        Category("Behavior"),
        Editor("System.Web.UI.Design.CollectionEditorBase, " +
            AssemblyRef.SystemWebExtensionsDesign, typeof(UITypeEditor)),
        DefaultValue(null),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public ScriptReferenceCollection Scripts {
            get {
                if (_scripts == null) {
                    _scripts = new ScriptReferenceCollection();
                }
                return _scripts;
            }
        }

        [
        ResourceDescription("ScriptManager_ScriptPath"),
        Category("Behavior"),
        DefaultValue(""),
        ]
        public string ScriptPath {
            get {
                return (_scriptPath == null) ? String.Empty : _scriptPath;
            }
            set {
                _scriptPath = value;
            }
        }

        [
        ResourceDescription("ScriptManager_Services"),
        Category("Behavior"),
        Editor("System.Web.UI.Design.CollectionEditorBase, " +
            AssemblyRef.SystemWebExtensionsDesign, typeof(UITypeEditor)),
        DefaultValue(null),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public ServiceReferenceCollection Services {
            get {
                if (_services == null) {
                    _services = new ServiceReferenceCollection();
                }
                return _services;
            }
        }

        [
        Browsable(false),
        DefaultValue(true),
        SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")
        ]
        public bool SupportsPartialRendering {
            get {
                if (!EnablePartialRendering) {
                    
                    
                    return false;
                }
                return _supportsPartialRendering;
            }
            set {
                if (!EnablePartialRendering) {
                    throw new InvalidOperationException(AtlasWeb.ScriptManager_CannotSetSupportsPartialRenderingWhenDisabled);
                }
                if (_initCompleted) {
                    throw new InvalidOperationException(AtlasWeb.ScriptManager_CannotChangeSupportsPartialRendering);
                }
                _supportsPartialRendering = value;

                
                
                _supportsPartialRenderingSetByUser = true;
            }
        }

        [
        Browsable(false),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden),
        EditorBrowsable(EditorBrowsableState.Never)
        ]
        public override bool Visible {
            get {
                return base.Visible;
            }
            set {
                throw new NotImplementedException();
            }
        }

        internal bool Zip {
            get {
                if (!_zipSet) {
                    _zip = HeaderUtility.IsEncodingInAcceptList(IPage.Request.Headers["Accept-encoding"], "gzip");
                    _zipSet = true;
                }
                return _zip;
            }
        }

        private static void AddFrameworkScript(ScriptReference frameworkScript, List<ScriptReference> scripts, int scriptIndex) {
            
            
            if (scripts.Count > scriptIndex) {
                
                
                
                
                foreach (ScriptReference script in scripts) {
                    if (script.Name == frameworkScript.Name &&
                        script.GetAssembly() == frameworkScript.GetAssembly()) {
                        frameworkScript = script;
                        scripts.Remove(script);
                        break;
                    }
                }
            }

            frameworkScript.AlwaysLoadBeforeUI = true;
            scripts.Insert(scriptIndex, frameworkScript);
        }

        
        private void CollectScripts(List<ScriptReference> scripts) {
            
            
            if (_scripts != null) {
                foreach (ScriptReference scriptReference in _scripts) {
                    scriptReference.ClientUrlResolver = Control;
                    scriptReference.ContainingControl = this;
                    scriptReference.IsStaticReference = true;
                    scripts.Add(scriptReference);
                }
            }

            
            
            if (_proxies != null) {
                foreach (ScriptManagerProxy proxy in _proxies) {
                    proxy.CollectScripts(scripts);
                }
            }

            
            ScriptControlManager.AddScriptReferences(scripts);
        }

        private void ConfigureApplicationServices() {
            StringBuilder sb = null;

            
            ProfileServiceManager.ConfigureProfileService(ref sb, Context, this, _proxies);
            AuthenticationServiceManager.ConfigureAuthenticationService(ref sb, Context, this, _proxies);
#if ORCAS
            RoleServiceManager.ConfigureRoleService(sb, this.Context, );
#endif

            if (sb != null && sb.Length > 0) {
                this.IPage.ClientScript.RegisterClientScriptBlock(typeof(ScriptManager),  "AppServicesConfig", sb.ToString(), true);
            }
        }

        internal string CreateUniqueScriptKey() {
            _uniqueScriptCounter++;
            return "UniqueScript_" + _uniqueScriptCounter.ToString(CultureInfo.InvariantCulture);
        }

        public static ScriptManager GetCurrent(Page page) {
            if (page == null) {
                throw new ArgumentNullException("page");
            }

            return page.Items[typeof(ScriptManager)] as ScriptManager;
        }

        [SecurityCritical()]
        [ConfigurationPermission(SecurityAction.Assert, Unrestricted = true)]
        private static ICustomErrorsSection GetCustomErrorsSectionWithAssert() {
            return new CustomErrorsSectionWrapper(
                (CustomErrorsSection)WebConfigurationManager.GetSection("system.web/customErrors"));
        }

        internal string GetScriptResourceUrl(string resourceName, Assembly assembly) {
            return ScriptResourceHandler.GetScriptResourceUrl(
                assembly,
                resourceName,
                (EnableScriptLocalization ? CultureInfo.CurrentUICulture : CultureInfo.InvariantCulture),
                Zip, true);
        }

        protected virtual bool LoadPostData(string postDataKey, NameValueCollection postCollection) {
            PageRequestManager.LoadPostData(postDataKey, postCollection);

            return false;
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected internal virtual void OnAsyncPostBackError(AsyncPostBackErrorEventArgs e) {
            EventHandler<AsyncPostBackErrorEventArgs> handler =
                (EventHandler<AsyncPostBackErrorEventArgs>)Events[AsyncPostBackErrorEvent];
            if (handler != null) {
                handler(this, e);
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnInit(EventArgs e) {
            base.OnInit(e);

            if (!DesignMode) {
                IPage page = IPage;
                ScriptManager existingInstance = ScriptManager.GetCurrent(Page);

                if (existingInstance != null) {
                    throw new InvalidOperationException(AtlasWeb.ScriptManager_OnlyOneScriptManager);
                }
                page.Items[typeof(ScriptManager)] = this;

                page.InitComplete += OnPageInitComplete;
                page.PreRenderComplete += OnPagePreRenderComplete;

                if (page.IsPostBack) {
                    _isInAsyncPostBack = PageRequestManager.IsAsyncPostBackRequest(page.Request.Headers);
                }

                
                PageRequestManager.OnInit();

                page.PreRender += ScriptControlManager.OnPagePreRender;
            }
        }

        private void OnPagePreRenderComplete(object sender, EventArgs e) {
            if (!IsInAsyncPostBack) {
                if (SupportsPartialRendering) {
                    
                    
                    
                    
                    
                    IPage.ClientScript.GetPostBackEventReference(new PostBackOptions(this, null, null, false, false, false, false, true, null));
                }

                
                RegisterGlobalizationScriptBlock();
                
                RegisterScripts();
                
                RegisterServices();
            }
            else {
                
                RegisterScripts();
            }
        }

        private void OnPageInitComplete(object sender, EventArgs e) {
            if (IPage.IsPostBack) {
                if (IsInAsyncPostBack && !SupportsPartialRendering) {
                    throw new InvalidOperationException(AtlasWeb.ScriptManager_AsyncPostBackNotInPartialRenderingMode);
                }
            }

            _initCompleted = true;
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnPreRender(EventArgs e) {
            base.OnPreRender(e);

            if (IsInAsyncPostBack) {
                PageRequestManager.OnPreRender();
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected virtual void OnResolveScriptReference(ScriptReferenceEventArgs e) {
            EventHandler<ScriptReferenceEventArgs> handler =
                (EventHandler<ScriptReferenceEventArgs>)Events[ResolveScriptReferenceEvent];
            if (handler != null) {
                handler(this, e);
            }
        }

        [SuppressMessage("Microsoft.Design", "CA1030:UseEventsWhereAppropriate",
            Justification = "Matches IPostBackDataHandler interface.")]
        protected virtual void RaisePostDataChangedEvent() {
        }

        
        
        


        [SuppressMessage("Microsoft.Design", "CA1011:ConsiderPassingBaseTypesAsParameters", Justification = "The overload specifically exists to strengthen the support for passing in a Page parameter.")]
        public static void RegisterArrayDeclaration(Page page, string arrayName, string arrayValue) {
            ScriptRegistrationManager.RegisterArrayDeclaration(page, arrayName, arrayValue);
        }

        public static void RegisterArrayDeclaration(Control control, string arrayName, string arrayValue) {
            ScriptRegistrationManager.RegisterArrayDeclaration(control, arrayName, arrayValue);
        }

        
        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        public void RegisterAsyncPostBackControl(Control control) {
            PageRequestManager.RegisterAsyncPostBackControl(control);
        }

        
        internal virtual void RegisterClientScriptBlockInternal(Control control, Type type, string key, string script, bool addScriptTags) {
            RegisterClientScriptBlock(control, type, key, script, addScriptTags);
        }

        [SuppressMessage("Microsoft.Design", "CA1011:ConsiderPassingBaseTypesAsParameters", Justification = "The overload specifically exists to strengthen the support for passing in a Page parameter.")]
        public static void RegisterClientScriptBlock(Page page, Type type, string key, string script, bool addScriptTags) {
            ScriptRegistrationManager.RegisterClientScriptBlock(page, type, key, script, addScriptTags);
        }

        public static void RegisterClientScriptBlock(Control control, Type type, string key, string script, bool addScriptTags) {
            ScriptRegistrationManager.RegisterClientScriptBlock(control, type, key, script, addScriptTags);
        }

        
        internal virtual void RegisterClientScriptIncludeInternal(Control control, Type type, string key, string url) {
            RegisterClientScriptInclude(control, type, key, url);
        }

        [SuppressMessage("Microsoft.Design", "CA1054:UriParametersShouldNotBeStrings",
            Justification = "Needs to take same parameters as ClientScriptManager.RegisterClientScriptInclude()." +
            "We could provide an overload that takes a System.Uri parameter, but then FxCop rule " +
            "StringUriOverloadsCallSystemUriOverloads would require that the string overload call the Uri overload. " +
            "But we cannot do this, because the ClientScriptManager API allows any string, even invalid Uris. " +
            "We cannot start throwing exceptions on input we previously passed to the browser. So it does not make " +
            "sense to add an overload that takes System.Uri.")]
        [SuppressMessage("Microsoft.Design", "CA1011:ConsiderPassingBaseTypesAsParameters", Justification = "The overload specifically exists to strengthen the support for passing in a Page parameter.")]
        public static void RegisterClientScriptInclude(Page page, Type type, string key, string url) {
            ScriptRegistrationManager.RegisterClientScriptInclude(page, type, key, url);
        }

        [SuppressMessage("Microsoft.Design", "CA1054:UriParametersShouldNotBeStrings",
            Justification = "Needs to take same parameters as ClientScriptManager.RegisterClientScriptInclude()." +
            "We could provide an overload that takes a System.Uri parameter, but then FxCop rule " +
            "StringUriOverloadsCallSystemUriOverloads would require that the string overload call the Uri overload. " +
            "But we cannot do this, because the ClientScriptManager API allows any string, even invalid Uris. " +
            "We cannot start throwing exceptions on input we previously passed to the browser. So it does not make " +
            "sense to add an overload that takes System.Uri.")]
        public static void RegisterClientScriptInclude(Control control, Type type, string key, string url) {
            ScriptRegistrationManager.RegisterClientScriptInclude(control, type, key, url);
        }

        [SuppressMessage("Microsoft.Design", "CA1011:ConsiderPassingBaseTypesAsParameters", Justification = "The overload specifically exists to strengthen the support for passing in a Page parameter.")]
        public static void RegisterClientScriptResource(Page page, Type type, string resourceName) {
            ScriptRegistrationManager.RegisterClientScriptResource(page, type, resourceName);
        }

        public static void RegisterClientScriptResource(Control control, Type type, string resourceName) {
            ScriptRegistrationManager.RegisterClientScriptResource(control, type, resourceName);
        }

        public void RegisterDataItem(Control control, string dataItem) {
            RegisterDataItem(control, dataItem, false);
        }

        public void RegisterDataItem(Control control, string dataItem, bool isJsonSerialized) {
            PageRequestManager.RegisterDataItem(control, dataItem, isJsonSerialized);
        }

        public void RegisterDispose(Control control, string disposeScript) {
            ScriptRegistration.RegisterDispose(control, disposeScript);
        }

        public static void RegisterExpandoAttribute(Control control, string controlId, string attributeName, string attributeValue, bool encode) {
            ScriptRegistrationManager.RegisterExpandoAttribute(control, controlId, attributeName, attributeValue, encode);
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        public void RegisterExtenderControl<TExtenderControl>(TExtenderControl extenderControl, Control targetControl)
            where TExtenderControl : Control, IExtenderControl {
            ScriptControlManager.RegisterExtenderControl(extenderControl, targetControl);
        }

        private void RegisterGlobalizationScriptBlock() {
            if (EnableScriptGlobalization) {
                string script = ClientCultureInfo.GetClientCultureScriptBlock(CultureInfo.CurrentCulture);
                if (script != null) {
                    ScriptRegistrationManager.RegisterClientScriptBlock(this, typeof(ScriptManager), "CultureInfo", script, true);
                }
            }
        }

        [SuppressMessage("Microsoft.Design", "CA1011:ConsiderPassingBaseTypesAsParameters", Justification = "The overload specifically exists to strengthen the support for passing in a Page parameter.")]
        public static void RegisterHiddenField(Page page, string hiddenFieldName, string hiddenFieldInitialValue) {
            ScriptRegistrationManager.RegisterHiddenField(page, hiddenFieldName, hiddenFieldInitialValue);
        }

        public static void RegisterHiddenField(Control control, string hiddenFieldName, string hiddenFieldInitialValue) {
            ScriptRegistrationManager.RegisterHiddenField(control, hiddenFieldName, hiddenFieldInitialValue);
        }

        [SuppressMessage("Microsoft.Design", "CA1011:ConsiderPassingBaseTypesAsParameters", Justification = "The overload specifically exists to strengthen the support for passing in a Page parameter.")]
        public static void RegisterOnSubmitStatement(Page page, Type type, string key, string script) {
            ScriptRegistrationManager.RegisterOnSubmitStatement(page, type, key, script);
        }

        public static void RegisterOnSubmitStatement(Control control, Type type, string key, string script) {
            ScriptRegistrationManager.RegisterOnSubmitStatement(control, type, key, script);
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        public void RegisterScriptControl<TScriptControl>(TScriptControl scriptControl)
            where TScriptControl : Control, IScriptControl {
            ScriptControlManager.RegisterScriptControl(scriptControl);
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        public void RegisterScriptDescriptors(IExtenderControl extenderControl) {
            ScriptControlManager.RegisterScriptDescriptors(extenderControl);
        }

        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        public void RegisterScriptDescriptors(IScriptControl scriptControl) {
            ScriptControlManager.RegisterScriptDescriptors(scriptControl);
        }

        
        [SuppressMessage("Microsoft.Security", "CA2123:OverrideLinkDemandsShouldBeIdenticalToBase")]
        public void RegisterPostBackControl(Control control) {
            PageRequestManager.RegisterPostBackControl(control);
        }

        private void RegisterScripts() {
            List<ScriptReference> scripts = new List<ScriptReference>();

            
            CollectScripts(scripts);

            

            
            
            
            
            
            
            ScriptReference atlasCore = new ScriptReference("MicrosoftAjax.js", this, this);
            AddFrameworkScript(atlasCore, scripts, 0);

            if (SupportsPartialRendering) {
                ScriptReference atlasWebForms = new ScriptReference("MicrosoftAjaxWebForms.js", this, this);
                AddFrameworkScript(atlasWebForms, scripts, 1);
            }

            
            foreach (ScriptReference script in scripts) {
                OnResolveScriptReference(new ScriptReferenceEventArgs(script));
            }

            
            List<ScriptReference> uniqueScripts = RemoveDuplicates(scripts);

            bool appServicesInit = false;
            bool loadScriptsBeforeUI = this.LoadScriptsBeforeUI;
            foreach (ScriptReference script in uniqueScripts) {
                string url = script.GetUrl(this, Control, Zip);

                if (loadScriptsBeforeUI || script.AlwaysLoadBeforeUI) {
                    RegisterClientScriptIncludeInternal(script.ContainingControl, typeof(ScriptManager), url, url);
                }
                else {
                    
                    string scriptTag = "\r\n<script src=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" type=\"text/javascript\"></script>";
                    RegisterStartupScriptInternal(script.ContainingControl, typeof(ScriptManager), url, scriptTag, false);
                }

                
                if (!appServicesInit && script.IsFrameworkAssembly()) {
                    ConfigureApplicationServices();
                    appServicesInit = true;
                }
            }
        }

        private void RegisterServices() {
            if (_services != null) {
                foreach (ServiceReference serviceReference in _services) {
                    serviceReference.Register(this, Context, this, IsDebuggingEnabled);
                }
            }

            if (_proxies != null) {
                foreach (ScriptManagerProxy proxy in _proxies) {
                    proxy.RegisterServices(this);
                }
            }

            if (EnablePageMethods) {
                string pageMethods = PageClientProxyGenerator.GetClientProxyScript(Context, IPage, IsDebuggingEnabled);
                if (!string.IsNullOrEmpty(pageMethods)) {
                    RegisterClientScriptBlockInternal(this, typeof(ScriptManager), pageMethods, pageMethods, true);
                }
            }
        }

        private static List<ScriptReference> RemoveDuplicates(List<ScriptReference> scripts) {
            
            
            
            
            
            
            
            

            
            
            
            
            
            
            
            
            
            

            
            
            
            
            
            
            int numScripts = scripts.Count;
            if (numScripts == 1) {
                return scripts;
            }
            else if (numScripts == 2) {
                ScriptReference script1 = scripts[0];
                ScriptReference script2 = scripts[1];
                bool scriptsUnique = (script1.Name != script2.Name) || (script1.Assembly != script2.Assembly);
                if (scriptsUnique) {
                    return scripts;
                }
            }

            
            
            
            HybridDictionary uniqueScriptDict = new HybridDictionary(numScripts);
            List<ScriptReference> filteredScriptList = new List<ScriptReference>(numScripts);

            foreach (ScriptReference script in scripts) {
                if (String.IsNullOrEmpty(script.Name)) {
                    filteredScriptList.Add(script);
                }
                else {
                    Pair<string, Assembly> key = new Pair<string, Assembly>(script.Name, script.GetAssembly());
                    if (!uniqueScriptDict.Contains(key)) {
                        if (script.IsStaticReference) {
                            
                            uniqueScriptDict.Add(key, script);
                        }
                        filteredScriptList.Add(script);
                    }
                }
            }

            return filteredScriptList;
        }

        
        internal virtual void RegisterStartupScriptInternal(Control control, Type type, string key, string script, bool addScriptTags) {
            RegisterStartupScript(control, type, key, script, addScriptTags);
        }

        [SuppressMessage("Microsoft.Design", "CA1011:ConsiderPassingBaseTypesAsParameters", Justification = "The overload specifically exists to strengthen the support for passing in a Page parameter.")]
        public static void RegisterStartupScript(Page page, Type type, string key, string script, bool addScriptTags) {
            ScriptRegistrationManager.RegisterStartupScript(page, type, key, script, addScriptTags);
        }

        public static void RegisterStartupScript(Control control, Type type, string key, string script, bool addScriptTags) {
            ScriptRegistrationManager.RegisterStartupScript(control, type, key, script, addScriptTags);
        }

        protected override void Render(HtmlTextWriter writer) {
            PageRequestManager.Render(writer);

            if (!IsInAsyncPostBack) {
                
                IPage.ClientScript.RegisterStartupScript(typeof(ScriptManager), "AppInitialize", "Sys.Application.initialize();\r\n", true);
            }

            base.Render(writer);
        }

        public void SetFocus(Control control) {
            PageRequestManager.SetFocus(control);
        }

        [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase", MessageId = "0#")]
        public void SetFocus(string clientID) {
            PageRequestManager.SetFocus(clientID);
        }

        #region IControl Members
        IHttpContext IControl.Context {
            get {
                return new HttpContextWrapper(Context);
            }
        }

        bool IControl.DesignMode {
            get {
                return DesignMode;
            }
        }
        #endregion

        #region IScriptManagerInternal Members
        void IScriptManagerInternal.RegisterProxy(ScriptManagerProxy proxy) {
            
            
            
            if (!Proxies.Contains(proxy)) {
                Proxies.Add(proxy);
            }
        }

        void IScriptManagerInternal.RegisterUpdatePanel(UpdatePanel updatePanel) {
            PageRequestManager.RegisterUpdatePanel(updatePanel);
        }

        void IScriptManagerInternal.UnregisterUpdatePanel(UpdatePanel updatePanel) {
            PageRequestManager.UnregisterUpdatePanel(updatePanel);
        }
        #endregion

        #region IPostBackDataHandler Members
        bool IPostBackDataHandler.LoadPostData(string postDataKey, NameValueCollection postCollection) {
            return LoadPostData(postDataKey, postCollection);
        }

        void IPostBackDataHandler.RaisePostDataChangedEvent() {
            RaisePostDataChangedEvent();
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
