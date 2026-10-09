namespace System.Web.UI {
    using System;
    using System.ComponentModel;
    using System.Collections;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Reflection;
    using System.Security;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;
    using System.Web.UI;
    using System.Web.UI.WebControls;
    using System.Web.Handlers;
    using System.Web.Resources;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Path"),
    ]
    public class ScriptReference {
        
        private static readonly Hashtable _scriptPathCache = Hashtable.Synchronized(new Hashtable());

        private bool _alwaysLoadBeforeUI;
        private string _assembly;
        private IClientUrlResolver _clientUrlResolver;
        private bool _isStaticReference;
        private bool _ignoreScriptPath;
        private string _name;
        private bool _notifyScriptLoaded = true;
        private Control _containingControl;
        private string _path;
        private string[] _resourceUICultures;
        private ScriptMode _scriptMode;

        public ScriptReference() {}

        public ScriptReference(string name, string assembly) : this() {
            Name = name;
            Assembly = assembly;
        }

        public ScriptReference(string path) : this() {
            Path = path;
        }

        internal ScriptReference(string name, IClientUrlResolver clientUrlResolver, Control containingControl) {
            Debug.Assert(!String.IsNullOrEmpty(name), "The script's name must be specified.");
            Debug.Assert(clientUrlResolver != null && clientUrlResolver is ScriptManager, "The clientUrlResolver must be the ScriptManager.");
            Name = name;
            ClientUrlResolver = clientUrlResolver;
            IsStaticReference = true;
            ContainingControl = containingControl;
        }

        internal bool AlwaysLoadBeforeUI {
            get {
                return _alwaysLoadBeforeUI;
            }
            set {
                _alwaysLoadBeforeUI = value;
            }
        }

        [
        Category("Behavior"),
        DefaultValue(""),
        ResourceDescription("ScriptReference_Assembly")
        ]
        public string Assembly {
            get {
                return (_assembly == null) ? String.Empty : _assembly;
            }
            set {
                _assembly = value;
            }
        }

        
        
        internal IClientUrlResolver ClientUrlResolver {
            get {
                return _clientUrlResolver;
            }
            set {
                _clientUrlResolver = value;
            }
        }

        internal Control ContainingControl {
            get {
                return _containingControl;
            }
            set {
                _containingControl = value;
            }
        }

        private ScriptMode EffectiveScriptMode {
            get {
                if (ScriptMode == ScriptMode.Auto) {
                    
                    
                    
                    
                    
                    
                    return (String.IsNullOrEmpty(Name) ? ScriptMode.Release : ScriptMode.Inherit);
                }
                else {
                    return ScriptMode;
                }
            }
        }

        [
        Category("Behavior"),
        DefaultValue(false),
        ResourceDescription("ScriptReference_IgnoreScriptPath")
        ]
        public bool IgnoreScriptPath {
            get {
                return _ignoreScriptPath;
            }
            set {
                _ignoreScriptPath = value;
            }
        }

        
        
        internal bool IsStaticReference {
            get {
                return _isStaticReference;
            }
            set {
                _isStaticReference = value;
            }
        }

        [
        Category("Behavior"),
        DefaultValue(""),
        ResourceDescription("ScriptReference_Name")
        ]
        public string Name {
            get {
                return (_name == null) ? String.Empty : _name;
            }
            set {
                _name = value;
            }
        }

        [
        Category("Behavior"),
        DefaultValue(true),
        ResourceDescription("ScriptReference_NotifyScriptLoaded")
        ]
        public bool NotifyScriptLoaded {
            get {
                return _notifyScriptLoaded;
            }
            set {
                _notifyScriptLoaded = value;
            }
        }

        [
        Category("Behavior"),
        DefaultValue(""),
        ResourceDescription("ScriptReference_Path")
        ]
        public string Path {
            get {
                return (_path == null) ? String.Empty : _path;
            }
            set {
                _path = value;
            }
        }

        [
        ResourceDescription("ScriptReference_ResourceUICultures"),
        DefaultValue(null),
        Category("Behavior"),
        MergableProperty(false),
        TypeConverter(typeof(StringArrayConverter)),
        SuppressMessage("Microsoft.Performance", "CA1819:PropertiesShouldNotReturnArrays",
            Justification = "String[] has existing TypeConverter support, which we don't want to add for List<string> to the assembly just for this property and at this point in the product cycle.")
        ]
        public string[] ResourceUICultures {
            get {
                return _resourceUICultures;
            }
            set {
                _resourceUICultures = value;
            }
        }

        [
        Category("Behavior"),
        DefaultValue(ScriptMode.Auto),
        ResourceDescription("ScriptReference_ScriptMode")
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

        private CultureInfo DetermineCulture() {
            if ((ResourceUICultures == null) || (ResourceUICultures.Length == 0)) {
                
                if (!String.IsNullOrEmpty(Name)) {
                    return ScriptResourceHandler
                        .DetermineNearestAvailableCulture(GetAssembly(), Name, CultureInfo.CurrentUICulture);
                }
                return CultureInfo.InvariantCulture;
            }
            CultureInfo currentCulture = CultureInfo.CurrentUICulture;
            while (currentCulture != CultureInfo.InvariantCulture) {
                string cultureName = currentCulture.ToString();
                foreach (string uiCulture in ResourceUICultures) {
                    if (String.Equals(cultureName, uiCulture.Trim(), StringComparison.OrdinalIgnoreCase)) {
                        return currentCulture;
                    }
                }
                currentCulture = currentCulture.Parent;
            }
            return currentCulture;
        }

        internal Assembly GetAssembly() {
            string assemblyName = Assembly;
            if (String.IsNullOrEmpty(assemblyName)) {
                return AssemblyRef.SystemWebExtensions;
            }
            else {
                
                
                return AssemblyCache.Load(assemblyName);
            }
        }

        
        
        private static string GetDebugName(string releaseName) {
            
            
            
            
            if (!releaseName.EndsWith(".js", StringComparison.Ordinal)) {
                throw new InvalidOperationException(
                    String.Format(CultureInfo.CurrentUICulture, AtlasWeb.ScriptReference_InvalidReleaseScriptName, releaseName));
            }

            return ReplaceExtension(releaseName);
        }

        
        
        
        private static string GetDebugPath(string releasePath) {
            
            
            string pathWithoutQuery;
            string query;
            if (releasePath.IndexOf('?') >= 0) {
                int indexOfQuery = releasePath.IndexOf('?');
                pathWithoutQuery = releasePath.Substring(0, indexOfQuery);
                query = releasePath.Substring(indexOfQuery);
            }
            else {
                pathWithoutQuery = releasePath;
                query = null;
            }

            if (!pathWithoutQuery.EndsWith(".js", StringComparison.Ordinal)) {
                throw new InvalidOperationException(
                    String.Format(CultureInfo.CurrentUICulture, AtlasWeb.ScriptReference_InvalidReleaseScriptPath, pathWithoutQuery));
            }

            return ReplaceExtension(pathWithoutQuery) + query;
        }

        private string GetPath(string releasePath, ScriptManager scriptManager) {
            if (String.IsNullOrEmpty(Name)) {
                return GetPathWithoutName(releasePath, scriptManager);
            }
            else {
                return GetPathWithName(releasePath, scriptManager);
            }
        }

        
        private string GetPathWithoutName(string releasePath, ScriptManager scriptManager) {
            if (IsDebuggingEnabled(scriptManager)) {
                return GetDebugPath(releasePath);
            }
            else {
                return releasePath;
            }
        }

        
        
        
        
        
        private string GetPathWithName(string releasePath, ScriptManager scriptManager) {
            if (ShouldUseDebugScript(Name, GetAssembly(), scriptManager)) {
                return GetDebugPath(releasePath);
            }
            else {
                return releasePath;
            }
        }

        private string GetResourceName(string releaseName, Assembly assembly, ScriptManager scriptManager) {
            string resourceName;

            if (ShouldUseDebugScript(releaseName, assembly, scriptManager)) {
                resourceName = GetDebugName(releaseName);
            }
            else {
                resourceName = releaseName;
            }

            return resourceName;
        }

        
        
        
        private static string GetScriptPath(
            string resourceName,
            Assembly assembly,
            CultureInfo culture,
            string scriptPath) {

            return scriptPath + "/" + GetScriptPathCached(resourceName, assembly, culture);
        }

        
        
        private static string GetScriptPathCached(string resourceName, Assembly assembly, CultureInfo culture) {
            Tuple key = new Tuple(resourceName, assembly, culture);
            string scriptPath = (string)_scriptPathCache[key];

            if (scriptPath == null) {
                
                
                
                AssemblyName assemblyName = new AssemblyName(assembly.FullName);

                string name = assemblyName.Name;
                string version = assemblyName.Version.ToString();

                if ((culture != CultureInfo.InvariantCulture) &&
                    resourceName.EndsWith(".js", StringComparison.OrdinalIgnoreCase)) {

                    resourceName = resourceName.Substring(0, resourceName.Length - 3) +
                        "." + culture.Name + ".js";
                }

                
                
                scriptPath = String.Join("/", new string[] {
                    HttpUtility.UrlEncode(name), version, HttpUtility.UrlEncode(resourceName)
                });

                _scriptPathCache[key] = scriptPath;
            }

            return scriptPath;
        }

        internal string GetUrl(ScriptManager scriptManager, IControl scriptManagerControl, bool zip) {
            bool hasName = !String.IsNullOrEmpty(Name);
            bool hasAssembly = !String.IsNullOrEmpty(Assembly);
            bool hasPath = !String.IsNullOrEmpty(Path);

            if (!hasName && !hasPath) {
                throw new InvalidOperationException(AtlasWeb.ScriptReference_NameAndPathCannotBeEmpty);
            }

            if (hasAssembly && !hasName) {
                throw new InvalidOperationException(AtlasWeb.ScriptReference_AssemblyRequiresName);
            }

            
            if (hasPath) {
                return GetUrlFromPath(scriptManager);
            }
            else {
                Debug.Assert(hasName);
                return GetUrlFromName(scriptManager, scriptManagerControl, zip);
            }
        }

        private string GetUrlFromName(ScriptManager scriptManager, IControl scriptManagerControl, bool zip) {
            string releaseName = Name;

            Assembly assembly = GetAssembly();
            
            string resourceName = GetResourceName(releaseName, assembly, scriptManager);

            string url;
            CultureInfo culture = (scriptManager.EnableScriptLocalization ?
                DetermineCulture() : CultureInfo.InvariantCulture);

            if (IgnoreScriptPath || String.IsNullOrEmpty(scriptManager.ScriptPath)) {
                url = ScriptResourceHandler
                    .GetScriptResourceUrl(assembly, resourceName, culture, zip, NotifyScriptLoaded);
            }
            else {
                string path = GetScriptPath(resourceName, assembly, culture, scriptManager.ScriptPath);
                
                
                
                url = scriptManagerControl.ResolveClientUrl(path);
            }

            return url;
        }

        private string GetUrlFromPath(ScriptManager scriptManager) {
            string releasePath = Path;

            string path = GetPath(releasePath, scriptManager);
            
            if (scriptManager.EnableScriptLocalization) {
                CultureInfo culture = DetermineCulture();
                if (culture != CultureInfo.InvariantCulture) {
                    path = (path.Substring(0, path.Length - 2) + culture.ToString() + ".js");
                }
            }
            string resolvedUrl = _clientUrlResolver.ResolveClientUrl(path);

            return resolvedUrl;
        }

        private bool IsDebuggingEnabled(ScriptManager scriptManager) {
            
            if (scriptManager.DeploymentSectionRetail) {
                return false;
            }

            switch (EffectiveScriptMode) {
                case ScriptMode.Inherit:
                    return scriptManager.IsDebuggingEnabled;
                case ScriptMode.Debug:
                    return true;
                case ScriptMode.Release:
                    return false;
                default:
                    Debug.Fail("Invalid value for ScriptReference.EffectiveScriptMode");
                    return false;
            }
        }

        internal bool IsFrameworkAssembly() {
            return (GetAssembly() == AssemblyRef.SystemWebExtensions);
        }

        
        
        private static string ReplaceExtension(string pathOrName) {
            Debug.Assert(pathOrName.EndsWith(".js", StringComparison.Ordinal));
            return (pathOrName.Substring(0, pathOrName.Length - 2) + "debug.js");
        }

        private bool ShouldUseDebugScript(string releaseName, Assembly assembly, ScriptManager scriptManager) {
            bool useDebugScript;
            string debugName = null;

            if (IsDebuggingEnabled(scriptManager)) {
                debugName = GetDebugName(releaseName);

                
                
                
                
                
                if (ScriptMode == ScriptMode.Auto && !WebResourceUtil.AssemblyContainsWebResource(assembly, debugName)) {
                    useDebugScript = false;
                }
                else {
                    useDebugScript = true;
                }
            }
            else {
                useDebugScript = false;
            }

            
            
            WebResourceUtil.VerifyAssemblyContainsReleaseWebResource(assembly, releaseName);
            if (useDebugScript) {
                Debug.Assert(debugName != null);
                WebResourceUtil.VerifyAssemblyContainsDebugWebResource(assembly, debugName);
            }

            return useDebugScript;
        }

        
        
        public override string ToString() {
            if (!String.IsNullOrEmpty(Name)) {
                return Name;
            }
            else if (!String.IsNullOrEmpty(Path)) {
                return Path;
            }
            else {
                return GetType().Name;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
