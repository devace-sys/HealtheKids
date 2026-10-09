namespace System.Web.Handlers {
    using System;
    using System.Collections;
    using System.Collections.Specialized;
    using System.Diagnostics;
    using System.Globalization;
    using System.IO;
    using System.IO.Compression;
    using System.Reflection;
    using System.Resources;
    using System.Security;
    using System.Security.Cryptography;
    using System.Security.Permissions;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Threading;
    using System.Web;
    using System.Web.UI;
    using System.Web.Configuration;
    using System.Web.Handlers;
    using System.Web.Hosting;

    using System.Web.Script.Serialization;
    using System.Web.Resources;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    ]
    public class ScriptResourceHandler : IHttpHandler {

        private const string _scriptResourceUrl = "~/ScriptResource.axd";
        private static readonly IDictionary _assemblyInfoCache = Hashtable.Synchronized(new Hashtable());
        private static readonly IDictionary _cultureCache = Hashtable.Synchronized(new Hashtable());
        private static MethodInfo _decryptString;
        private static MethodInfo _encryptString;
        private static readonly Object _getMethodLock = new Object();
        private static MethodInfo _getWebResourceUrl;
        private static IScriptResourceHandler _scriptResourceHandler = new RuntimeScriptResourceHandler();
        private static readonly Regex _webResourceRegEx = new Regex(
            @"<%\s*=\s*(?<resourceType>WebResource|ScriptResource)\(""(?<resourceName>[^""]*)""\)\s*%>",
            RegexOptions.Singleline | RegexOptions.Multiline);

        private static void CheckPath(string path) {
            if (!String.Equals(path,
                VirtualPathUtility.ToAbsolute(_scriptResourceUrl),
                StringComparison.OrdinalIgnoreCase)) {

                Throw404();
            }
        }

        private static void CopyScriptToStreamWithSubstitution(
            string content, Assembly assembly, bool zip, bool notifyScriptLoaded, StreamWriter writer) {

            
            MatchCollection matches = _webResourceRegEx.Matches(content);
            int startIndex = 0;
            foreach (Match match in matches) {
                writer.Write(content.Substring(startIndex, match.Index - startIndex));

                Group group = match.Groups["resourceName"];
                string embeddedResourceName = group.Value;
                bool isScriptResource = String.Equals(
                    match.Groups["resourceType"].Value, "ScriptResource", StringComparison.Ordinal);
                try {
                    if (isScriptResource) {
                        writer.Write(GetScriptResourceUrl(
                            assembly, embeddedResourceName, CultureInfo.CurrentCulture, zip, notifyScriptLoaded));
                    }
                    else {
                        writer.Write(GetWebResourceUrl(assembly, embeddedResourceName));
                    }
                }
                catch (HttpException e) {
                    throw new HttpException(String.Format(CultureInfo.CurrentCulture,
                        AtlasWeb.ScriptResourceHandler_UnknownResource,
                        embeddedResourceName), e);
                }

                startIndex = match.Index + match.Length;
            }

            writer.Write(content.Substring(startIndex, content.Length - startIndex));
        }

        private static Exception Create404(Exception innerException) {
            return new HttpException(404, AtlasWeb.ScriptResourceHandler_InvalidRequest, innerException);
        }

        private static string DecryptParameter(NameValueCollection queryString) {
            string encryptedData = queryString["d"];
            if (String.IsNullOrEmpty(encryptedData)) {
                Throw404();
            }

            try {
                return DecryptString(encryptedData);
            }
            catch (CryptographicException ex) {
                throw Create404(ex);
            }
        }

        [
        ReflectionPermission(SecurityAction.Assert, Unrestricted = true),
        SecurityCritical,
        SecurityTreatAsSafe
        ]
        private static string DecryptString(string s) {
            if (_decryptString == null) {
                lock (_getMethodLock) {
                    if (_decryptString == null) {
                        _decryptString = typeof(Page)
                            .GetMethod("DecryptString", BindingFlags.Static | BindingFlags.NonPublic);
                    }
                }
            }
            return (string)_decryptString.Invoke(null, new object[] { s });
        }

        internal static CultureInfo DetermineNearestAvailableCulture(
            Assembly assembly,
            string scriptResourceName,
            CultureInfo culture) {

            if (String.IsNullOrEmpty(scriptResourceName)) return CultureInfo.InvariantCulture;

            Tuple cacheKey = new Tuple(assembly, scriptResourceName, culture);
            CultureInfo cachedCulture = (CultureInfo)_cultureCache[cacheKey];
            if (cachedCulture == null) {

                string releaseResourceName =
                    scriptResourceName.EndsWith(".debug.js", StringComparison.OrdinalIgnoreCase) ?
                    scriptResourceName.Substring(0, scriptResourceName.Length - 9) + ".js" :
                    null;

                ScriptResourceInfo resourceInfo = ScriptResourceInfo.GetInstance(assembly, scriptResourceName);
                ScriptResourceInfo releaseResourceInfo = (releaseResourceName != null) ?
                    ScriptResourceInfo.GetInstance(assembly, releaseResourceName) : null;

                if (!String.IsNullOrEmpty(resourceInfo.ScriptResourceName) ||
                    ((releaseResourceInfo != null) && !String.IsNullOrEmpty(releaseResourceInfo.ScriptResourceName))) {

                    ResourceManager resourceManager = GetResourceManager(assembly, resourceInfo.ScriptResourceName);
                    ResourceManager releaseResourceManager = (releaseResourceInfo != null) ?
                        GetResourceManager(assembly, releaseResourceInfo.ScriptResourceName) : null;

                    ResourceSet localizedSet = null;
                    ResourceSet releaseSet = null;
                    if (resourceManager != null) {
                        resourceManager.GetResourceSet(CultureInfo.InvariantCulture, true, true);
                        
                        localizedSet = resourceManager.GetResourceSet(culture, true, false);
                    }
                    if (releaseResourceManager != null) {
                        releaseResourceManager.GetResourceSet(CultureInfo.InvariantCulture, true, true);
                        
                        releaseSet = releaseResourceManager.GetResourceSet(culture, true, false);
                    }
                    if ((resourceManager != null) || (releaseResourceManager != null)) {
                        while ((localizedSet == null) && (releaseSet == null)) {
                            culture = culture.Parent;
                            if (culture == CultureInfo.InvariantCulture) break;
                            localizedSet = resourceManager.GetResourceSet(culture, true, false);
                            releaseSet = (releaseResourceManager != null) ?
                                releaseResourceManager.GetResourceSet(culture, true, false) : null;
                        }
                    }
                    else {
                        culture = CultureInfo.InvariantCulture;
                    }
                }
                else {
                    culture = CultureInfo.InvariantCulture;
                }
                cachedCulture = culture;
                _cultureCache[cacheKey] = cachedCulture;
            }
            return cachedCulture;
        }

        [
        ReflectionPermission(SecurityAction.Assert, Unrestricted = true),
        SecurityCritical,
        SecurityTreatAsSafe
        ]
        private static string EncryptString(string s) {
            if (_encryptString == null) {
                lock (_getMethodLock) {
                    if (_encryptString == null) {
                        _encryptString = typeof(Page)
                            .GetMethod("EncryptString", BindingFlags.Static | BindingFlags.NonPublic);
                    }
                }
            }
            return (string)_encryptString.Invoke(null, new object[] { s });
        }

        private static Assembly GetAssembly(string assemblyName) {
            string[] parts = assemblyName.Split(',');

            if ((parts.Length != 1) && (parts.Length != 4)) {
                Throw404();
            }

            AssemblyName realName = new AssemblyName();
            realName.Name = parts[0];
            if (parts.Length == 4) {
                realName.Version = new Version(parts[1]);
                string cultureString = parts[2];
                realName.CultureInfo = (cultureString.Length > 0) ?
                    new CultureInfo(cultureString) :
                    CultureInfo.InvariantCulture;
                realName.SetPublicKeyToken(HexParser.Parse(parts[3]));
            }
            Assembly assembly = null;
            try {
                assembly = Assembly.Load(realName);
            }
            catch (FileNotFoundException fnf) {
                Throw404(fnf);
            }
            catch (FileLoadException fl) {
                Throw404(fl);
            }
            catch (BadImageFormatException badImage) {
                Throw404(badImage);
            }

            return assembly;
        }

        private static Pair<AssemblyName, DateTime> GetAssemblyInfo(Assembly assembly) {
            Pair<AssemblyName, DateTime> assemblyInfo =
                (Pair<AssemblyName, DateTime>)_assemblyInfoCache[assembly];
            if (assemblyInfo == null) {
                assemblyInfo = GetAssemblyInfoInternal(assembly);
                _assemblyInfoCache[assembly] = assemblyInfo;
            }
            Debug.Assert(assemblyInfo != null, "Assembly info should not be null");
            return assemblyInfo;
        }

        private static Pair<AssemblyName, DateTime> GetAssemblyInfoInternal(Assembly assembly) {
            AssemblyName assemblyName = new AssemblyName(assembly.FullName);
            return new Pair<AssemblyName, DateTime>(assemblyName, GetLastWriteTime(assembly));
        }

        [
        FileIOPermission(SecurityAction.Assert, AllFiles = FileIOPermissionAccess.PathDiscovery),
        SecurityCritical
        ]
        private static string GetCodeBaseWithAssert(Assembly assembly) {
            return assembly.CodeBase;
        }

        [
        SecurityCritical,
        SecurityTreatAsSafe
        ]
        private static DateTime GetLastWriteTime(Assembly assembly) {
            string codeBase = GetCodeBaseWithAssert(assembly);
            Uri codeBaseUri = new Uri(codeBase);
            if (!codeBaseUri.IsFile) return DateTime.MinValue;
            string localPath = codeBaseUri.LocalPath;

            FileIOPermission p = new FileIOPermission(FileIOPermissionAccess.Read, localPath);
            p.Assert();
            return File.GetLastWriteTime(localPath);
        }

        private static ResourceSet GetNeutralSet(ResourceManager resourceManager) {
            try {
                return resourceManager.GetResourceSet(CultureInfo.InvariantCulture, true, true);
            }
            catch (MissingManifestResourceException ex) {
                throw Create404(ex);
            }
        }

        private static ResourceManager GetResourceManager(Assembly assembly, string resourceName) {
            if (String.IsNullOrEmpty(resourceName)) {
                return null;
            }
            return new ResourceManager(GetResourceName(resourceName), assembly);
        }

        private static string GetResourceName(string rawResourceName) {
            if (rawResourceName.EndsWith(".resources", StringComparison.OrdinalIgnoreCase)) {
                return rawResourceName.Substring(0, rawResourceName.Length - 10);
            }
            return rawResourceName;
        }

        internal static string GetScriptResourceUrl(
            Assembly assembly,
            string resourceName,
            CultureInfo culture,
            bool zip,
            bool notifyScriptLoaded) {

            return _scriptResourceHandler
                .GetScriptResourceUrl(assembly, resourceName, culture, zip, notifyScriptLoaded);
        }

        [
        ReflectionPermission(SecurityAction.Assert, Unrestricted = true),
        SecurityCritical,
        SecurityTreatAsSafe
        ]
        private static string GetWebResourceUrl(Assembly assembly, string resourceName) {
            if (_getWebResourceUrl == null) {
                lock (_getMethodLock) {
                    if (_getWebResourceUrl == null) {
                        _getWebResourceUrl = typeof(AssemblyResourceLoader)
                            .GetMethod("GetWebResourceUrlInternal", BindingFlags.Static | BindingFlags.NonPublic);
                    }
                }
            }
            return (string)_getWebResourceUrl.Invoke(null, new object[] { assembly, resourceName, false });
        }

        protected virtual bool IsReusable {
            get {
                return true;
            }
        }

        private static bool IsCompressionEnabled(HttpContext context) {
            return ScriptingScriptResourceHandlerSection.ApplicationSettings.EnableCompression &&
                ((context == null) ||
                !context.Request.Browser.IsBrowser("IE") ||
                (context.Request.Browser.MajorVersion > 6));
        }

        private static void PrepareResponseCache(HttpResponse response, Assembly assembly) {
            HttpCachePolicy cachePolicy = response.Cache;
            cachePolicy.SetCacheability(HttpCacheability.Public);
            cachePolicy.VaryByParams["d"] = true;
            cachePolicy.SetOmitVaryStar(true);
            cachePolicy.SetExpires(DateTime.Now + TimeSpan.FromDays(365));
            cachePolicy.SetValidUntilExpires(true);
            cachePolicy.SetLastModified((DateTime)GetAssemblyInfo(assembly).Second);
        }

        private static void PrepareResponseNoCache(HttpResponse response, Assembly assembly) {
            HttpCachePolicy cachePolicy = response.Cache;
            cachePolicy.SetCacheability(HttpCacheability.Public);
            cachePolicy.SetExpires(DateTime.Now + TimeSpan.FromDays(365));
            cachePolicy.SetValidUntilExpires(true);
            cachePolicy.SetLastModified((DateTime)GetAssemblyInfo(assembly).Second);
            cachePolicy.SetNoServerCaching();
        }

        protected virtual void ProcessRequest(HttpContext context) {
            HttpResponse response = context.Response;
            response.Clear();

            
            CheckPath(context.Request.Path);

            string decryptedString = DecryptParameter(context.Request.QueryString);

            bool zip = false;
            bool notifyScriptLoaded = true;
            
            switch(decryptedString[0]) {
                case 'Z':
                    zip = true;
                    break;
                case 'z':
                    zip = true;
                    notifyScriptLoaded = false;
                    break;
                case 'u':
                    notifyScriptLoaded = false;
                    break;
            }

            string[] decryptedData = decryptedString.Substring(1).Split('|');

            Debug.Assert(decryptedData.Length == 3, "The decrypted data must have three parts separated by pipes.");

            string assemblyName = decryptedData[0];
            string resourceName = decryptedData[1];
            string cultureName = decryptedData[2];

            if (String.IsNullOrEmpty(resourceName) ||
                String.IsNullOrEmpty(assemblyName)) {

                Throw404();
            }

            Assembly assembly = GetAssembly(assemblyName);

            if (assembly != null) {
                ScriptResourceInfo resourceInfo = ScriptResourceInfo.GetInstance(assembly, resourceName);
                ScriptResourceInfo releaseResourceInfo = null;
                if (resourceName.EndsWith(".debug.js", StringComparison.OrdinalIgnoreCase)) {
                    
                    
                    string releaseResourceName = resourceName.Substring(0, resourceName.Length - 9) + ".js";
                    releaseResourceInfo = ScriptResourceInfo.GetInstance(assembly, releaseResourceName);
                }
                if ((resourceInfo == ScriptResourceInfo.Empty) &&
                    ((releaseResourceInfo == null) || (releaseResourceInfo == ScriptResourceInfo.Empty))) {

                    Throw404();
                }

                ResourceManager resourceManager = null;
                ResourceSet neutralSet = null;
                ResourceManager releaseResourceManager = null;
                ResourceSet releaseNeutralSet = null;
                CultureInfo previousCulture = Thread.CurrentThread.CurrentUICulture;

                try {
                    Thread.CurrentThread.CurrentUICulture = String.IsNullOrEmpty(cultureName) ?
                        CultureInfo.InvariantCulture :
                        new CultureInfo(cultureName);

                    if (!String.IsNullOrEmpty(resourceInfo.ScriptResourceName)) {
                        resourceManager = GetResourceManager(assembly, resourceInfo.ScriptResourceName);
                        neutralSet = GetNeutralSet(resourceManager);
                    }
                    if ((releaseResourceInfo != null) &&
                        !String.IsNullOrEmpty(releaseResourceInfo.ScriptResourceName)) {

                        releaseResourceManager = GetResourceManager(assembly, releaseResourceInfo.ScriptResourceName);
                        releaseNeutralSet = GetNeutralSet(releaseResourceManager);
                    }
                    if ((releaseResourceInfo != null) &&
                        !String.IsNullOrEmpty(releaseResourceInfo.ScriptResourceName) &&
                        !String.IsNullOrEmpty(resourceInfo.ScriptResourceName) &&
                        (releaseResourceInfo.TypeName != resourceInfo.TypeName)) {
                        throw new HttpException(String.Format(
                            CultureInfo.CurrentCulture,
                            AtlasWeb.ScriptResourceHandler_TypeNameMismatch,
                            releaseResourceInfo.ScriptResourceName));
                    }

                    if (ScriptingScriptResourceHandlerSection.ApplicationSettings.EnableCaching) {
                        PrepareResponseCache(response, assembly);
                    }
                    else {
                        PrepareResponseNoCache(response, assembly);
                    }

                    response.ContentType = resourceInfo.ContentType;

                    if (zip) {
                        using (MemoryStream zipped = new MemoryStream()) {
                            using (Stream outputStream = new GZipStream(zipped, CompressionMode.Compress)) {

                                WriteScript(assembly,
                                    resourceInfo, releaseResourceInfo,
                                    resourceManager, neutralSet,
                                    releaseResourceManager, releaseNeutralSet,
                                    zip, notifyScriptLoaded, outputStream);

                                byte[] zippedBytes = zipped.ToArray();
                                response.AddHeader("Content-encoding", "gzip");
                                response.OutputStream.Write(zippedBytes, 0, zippedBytes.Length);
                            }
                        }
                    }
                    else {
                        WriteScript(assembly,
                            resourceInfo, releaseResourceInfo,
                            resourceManager, neutralSet,
                            releaseResourceManager, releaseNeutralSet,
                            zip, notifyScriptLoaded, response.OutputStream);
                    }
                }
                finally {
                    Thread.CurrentThread.CurrentUICulture = previousCulture;

                    if (releaseNeutralSet != null) {
                        releaseNeutralSet.Dispose();
                    }
                    if (neutralSet != null) {
                        neutralSet.Dispose();
                    }
                }
            }
            else {
                Throw404();
            }
        }

        private static void RegisterNamespace(StreamWriter writer, string typeName) {
            int lastDot = typeName.LastIndexOf('.');
            if (lastDot != -1) {
                writer.Write("Type.registerNamespace('");
                writer.Write(typeName.Substring(0, lastDot));
                writer.WriteLine("');");
            }
        }

        internal static void SetScriptResourceHandler(IScriptResourceHandler scriptResourceHandler) {
            _scriptResourceHandler = scriptResourceHandler;
        }

        private static void Throw404() {
            throw Create404(null);
        }

        private static void Throw404(Exception innerException) {
            throw Create404(innerException);
        }

        private static void WriteNotificationToStream(bool notifyScriptLoaded, StreamWriter writer) {
            if (notifyScriptLoaded) {
                writer.WriteLine();
                writer.Write("if(typeof(Sys)!=='undefined')Sys.Application.notifyScriptLoaded();");
            }
        }

        private static bool WriteResource(
            StreamWriter writer,
            ResourceManager resourceManager,
            ResourceSet neutralSet,
            bool first) {

            foreach (DictionaryEntry res in neutralSet) {
                string key = (string)res.Key;
                string value = resourceManager.GetString(key);
                if (value != null) {
                    if (first) {
                        first = false;
                    }
                    else {
                        writer.Write(',');
                    }
                    writer.WriteLine();
                    writer.Write('"');
                    writer.Write(JavaScriptString.QuoteString(key));
                    writer.Write("\":\"");
                    writer.Write(JavaScriptString.QuoteString(value));
                    writer.Write('"');
                }
            }
            return first;
        }

        private static void WriteResources(StreamWriter writer, string typeName,
            ResourceManager resourceManager, ResourceSet neutralSet,
            ResourceManager releaseResourceManager, ResourceSet releaseNeutralSet) {

            writer.WriteLine();
            RegisterNamespace(writer, typeName);
            writer.Write(typeName);
            writer.Write("={");
            bool first = true;
            if (resourceManager != null) {
                first = WriteResource(writer, resourceManager, neutralSet, first);
            }
            if (releaseResourceManager != null) {
                WriteResource(writer, releaseResourceManager, releaseNeutralSet, first);
            }
            writer.WriteLine();
            writer.WriteLine("};");
        }

        private static void WriteResourceToStream(ScriptResourceInfo resourceInfo, ScriptResourceInfo releaseResourceInfo, ResourceManager resourceManager, ResourceSet neutralSet, ResourceManager releaseResourceManager, ResourceSet releaseNeutralSet, StreamWriter writer) {
            if ((resourceManager != null) || (releaseResourceManager != null)) {
                string typeName = resourceInfo.TypeName;
                if (String.IsNullOrEmpty(typeName)) {
                    typeName = releaseResourceInfo.TypeName;
                }
                WriteResources(writer, typeName, resourceManager, neutralSet,
                    releaseResourceManager, releaseNeutralSet);
            }
        }

        private static void WriteScript(Assembly assembly,
            ScriptResourceInfo resourceInfo, ScriptResourceInfo releaseResourceInfo,
            ResourceManager resourceManager, ResourceSet neutralSet,
            ResourceManager releaseResourceManager, ResourceSet releaseNeutralSet,
            bool zip, bool notifyScriptLoaded, Stream outputStream) {

            string content = null;
            using (StreamReader reader = new StreamReader(
                assembly.GetManifestResourceStream(resourceInfo.ScriptName), true)) {

                using (StreamWriter writer = new StreamWriter(outputStream, reader.CurrentEncoding)) {

                    if (resourceInfo.PerformSubstitution) {
                        content = reader.ReadToEnd();
                        CopyScriptToStreamWithSubstitution(
                            content, assembly, zip, notifyScriptLoaded, writer);
                        WriteResourceToStream(resourceInfo, releaseResourceInfo,
                            resourceManager, neutralSet,
                            releaseResourceManager, releaseNeutralSet,
                            writer);
                        WriteNotificationToStream(notifyScriptLoaded, writer);
                    }
                    else {
                        writer.Write(reader.ReadToEnd());
                        WriteResourceToStream(resourceInfo, releaseResourceInfo, resourceManager, neutralSet, releaseResourceManager, releaseNeutralSet, writer);
                        WriteNotificationToStream(notifyScriptLoaded, writer);
                    }
                }
            }
        }

        #region IHttpHandler implementation
        void IHttpHandler.ProcessRequest(HttpContext context) {
            ProcessRequest(context);
        }

        bool IHttpHandler.IsReusable {
            get {
                return IsReusable;
            }
        }
        #endregion

        private class RuntimeScriptResourceHandler : IScriptResourceHandler {

            private static readonly IDictionary _urlCache = Hashtable.Synchronized(new Hashtable());
            private static string _absoluteScriptResourceUrl;

            string IScriptResourceHandler.GetScriptResourceUrl(
                Assembly assembly, string resourceName, CultureInfo culture, bool zip, bool notifyScriptLoaded) {

                if (!IsCompressionEnabled(HttpContext.Current)) {
                    zip = false;
                }

                Tuple cacheKey = new Tuple(assembly, resourceName, culture, zip, notifyScriptLoaded);

                string url = (string)_urlCache[cacheKey];
                
                if (url == null) {
                    
                    ScriptResourceInfo resourceInfo = ScriptResourceInfo.GetInstance(assembly, resourceName);
                    if (resourceInfo == ScriptResourceInfo.Empty) {
                        ThrowUnknownResource(resourceName);
                    }
                    Stream scriptStream = assembly.GetManifestResourceStream(resourceInfo.ScriptName);
                    if ((scriptStream == null) || (scriptStream.ReadByte() == -1)) {
                        ThrowUnknownResource(resourceName);
                    }
                    culture = DetermineNearestAvailableCulture(assembly, resourceName, culture);

                    Pair<AssemblyName, DateTime> assemblyInfo = GetAssemblyInfo(assembly);

                    AssemblyName assemblyName = (AssemblyName)assemblyInfo.First;
                    DateTime assemblyDate = (DateTime)assemblyInfo.Second;

                    string urlAssemblyName;

                    if (assembly.GlobalAssemblyCache) {
                        
                        
                        StringBuilder builder = new StringBuilder();
                        builder.Append(assemblyName.Name);
                        builder.Append(',');
                        builder.Append(assemblyName.Version);
                        builder.Append(',');
                        if (assemblyName.CultureInfo != null) {
                            builder.Append(assemblyName.CultureInfo);
                        }
                        builder.Append(',');
                        builder.Append(HexParser.ToString(assemblyName.GetPublicKeyToken()));
                        urlAssemblyName = builder.ToString();
                    }
                    else {
                        
                        urlAssemblyName = assemblyName.Name;
                    }

                    
                    
                    
                    
                    

                    if (_absoluteScriptResourceUrl == null) {
                        _absoluteScriptResourceUrl = VirtualPathUtility.ToAbsolute(_scriptResourceUrl);
                    }

                    url = _absoluteScriptResourceUrl + "?d=" +
                        EncryptString(
                            (zip ? (notifyScriptLoaded ? "Z" : "z") : (notifyScriptLoaded ? "U" : "u")) +
                            urlAssemblyName + "|" +
                            resourceName + "|" +
                            culture.ToString()) +
                        "&t=" + assemblyDate.Ticks;

                    _urlCache[cacheKey] = url;
                }

                return url;
            }

            private static void ThrowUnknownResource(string resourceName) {
                throw new HttpException(String.Format(CultureInfo.CurrentCulture,
                    AtlasWeb.ScriptResourceHandler_UnknownResource, resourceName));
            }
        }

        private class ScriptResourceInfo {
            private string _contentType;
            private bool _performSubstitution;
            private string _scriptName;
            private string _scriptResourceName;
            private string _typeName;

            private static readonly IDictionary _scriptCache = Hashtable.Synchronized(new Hashtable());

            public static readonly ScriptResourceInfo Empty = new ScriptResourceInfo();

            public ScriptResourceInfo() {
                _contentType = "application/x-javascript";
            }

            public ScriptResourceInfo(ScriptResourceAttribute attr) : this() {
                _scriptName = attr.ScriptName;
                _scriptResourceName = attr.ScriptResourceName;
                _typeName = attr.TypeName;
            }

            public string ContentType {
                get { return _contentType; }
                set { _contentType = value; }
            }

            public bool PerformSubstitution {
                get { return _performSubstitution; }
                set { _performSubstitution = value; }
            }

            public string ScriptName {
                get { return _scriptName; }
                set { _scriptName = value; }
            }

            public string ScriptResourceName {
                get { return _scriptResourceName; }
            }

            public string TypeName {
                get { return _typeName; }
            }

            public static ScriptResourceInfo GetInstance(Assembly assembly, string resourceName) {
                Pair<Assembly, string> cacheKey = new Pair<Assembly, string>(assembly, resourceName);
                ScriptResourceInfo resourceInfo = (ScriptResourceInfo)_scriptCache[cacheKey];
                if (resourceInfo == null) {
                    resourceInfo = ScriptResourceInfo.Empty;
                    object[] attrs = assembly.GetCustomAttributes(typeof(ScriptResourceAttribute), false);
                    
                    for (int i = 0; i < attrs.Length; i++) {
                        ScriptResourceAttribute sra = (ScriptResourceAttribute)attrs[i];
                        if (String.Equals(sra.ScriptName, resourceName, StringComparison.Ordinal)) {
                            resourceInfo = new ScriptResourceInfo(sra);
                            break;
                        }
                    }
                    
                    attrs = assembly.GetCustomAttributes(typeof(WebResourceAttribute), false);
                    for (int i = 0; i < attrs.Length; i++) {
                        WebResourceAttribute wra = (WebResourceAttribute)attrs[i];
                        if (String.Equals(wra.WebResource, resourceName, StringComparison.Ordinal)) {
                            if (resourceInfo == ScriptResourceInfo.Empty) {
                                resourceInfo = new ScriptResourceInfo();
                                resourceInfo.ScriptName = resourceName;
                            }
                            resourceInfo.ContentType = wra.ContentType;
                            resourceInfo.PerformSubstitution = wra.PerformSubstitution;
                            break;
                        }
                    }

                    
                    _scriptCache[cacheKey] = resourceInfo;
                }
                return resourceInfo;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
