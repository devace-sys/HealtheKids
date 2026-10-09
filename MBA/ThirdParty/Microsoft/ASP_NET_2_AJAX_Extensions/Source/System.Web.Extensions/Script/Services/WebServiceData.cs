namespace System.Web.Script.Services {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Globalization;
    using System.IO;
    using System.Reflection;
    using System.Threading;
    using System.Text;
    using System.Web;
    using System.Web.Caching;
    using System.Web.Compilation;
    using System.Web.Configuration;
    using System.Web.Hosting;
    using System.Web.Services;
    using System.Xml.Serialization;
    using System.Web.Resources;
    using System.Web.Script.Serialization;
    using System.Security;

    internal class WebServiceData : JavaScriptTypeResolver {
        private WebServiceTypeData _typeData;
        private bool _pageMethods; 
        private Dictionary<string, WebServiceMethodData> _methods;

        
        private Dictionary<string, string> _typeResolverSpecials = new Dictionary<string,string>();
        private Dictionary<string, Type> _clientTypesDictionary;
        private Dictionary<Type, object> _enumTypesDictionary;
        private Hashtable _processedTypes;
        private bool _clientTypesProcessed;

        private JavaScriptSerializer _serializer;
        internal JavaScriptSerializer Serializer {
            get {
                return _serializer;
            }
        }

        internal const string _profileServiceFileName = "Profile_JSON_AppService.axd";
        internal const string _authenticationServiceFileName = "Authentication_JSON_AppService.axd";

        private static WebServiceData GetApplicationService(string appRelativePath) {
            
            
            
            
            
            
            int slashIndex = appRelativePath.LastIndexOf('/');
            if(slashIndex == 1) { 
                
                string name = Path.GetFileName(appRelativePath);

                if(name.Equals(_profileServiceFileName, StringComparison.OrdinalIgnoreCase)) {
                    return new WebServiceData(typeof(System.Web.Profile.ProfileService), false);
                }
                else if(name.Equals(_authenticationServiceFileName, StringComparison.OrdinalIgnoreCase)) {
                    return new WebServiceData(typeof(System.Web.Security.AuthenticationService), false);
                }
            }

            return null;
        }

        internal static WebServiceData GetWebServiceData(HttpContext context, string virtualPath) {
            return GetWebServiceData(context, virtualPath, true , false );
        }

        private static string GetCacheKey(string virtualPath) {
            return "System.Web.Script.Services.WebServiceData:" + virtualPath;
        }

        internal static WebServiceData GetWebServiceData(HttpContext context, string virtualPath, bool failIfNoData, bool pageMethods) {
            
            virtualPath = VirtualPathUtility.ToAbsolute(virtualPath);

            string cacheKey = GetCacheKey(virtualPath);
            WebServiceData data = context.Cache[cacheKey] as WebServiceData;
            
            if (data == null) {
                if (HostingEnvironment.VirtualPathProvider.FileExists(virtualPath)) {
                    Type compiledType = null;
                    try {
                        compiledType = BuildManager.GetCompiledType(virtualPath);

                        
                        if (compiledType == null) {
                            object page = BuildManager.CreateInstanceFromVirtualPath(virtualPath, typeof(System.Web.UI.Page));
                            compiledType = page.GetType();
                        }

                    }
                    catch (SecurityException) {
                        
                        
                    }

                    if (compiledType != null) {
                        data = new WebServiceData(compiledType, pageMethods);

                        
                        BuildDependencySet deps = BuildManager.GetCachedBuildDependencySet(context, virtualPath);
                        IEnumerable virtualPaths = deps.VirtualPaths;
                        if (virtualPaths != null) {
                            List<string> paths = new List<string>();
                            foreach (string path in virtualPaths) {
                                paths.Add(Path.Combine(context.Request.PhysicalApplicationPath, VirtualPathUtility.GetFileName(path)));
                            }
                            context.Cache.Insert(cacheKey, data, new CacheDependency(paths.ToArray()));
                        }
                        else {
                            context.Cache.Insert(cacheKey, data);
                        }
                    }
                }
                else if (virtualPath.EndsWith("_AppService.axd", StringComparison.OrdinalIgnoreCase)) {
                    
                    data = WebServiceData.GetApplicationService(context.Request.AppRelativeCurrentExecutionFilePath);
                    if(data != null) {
                        context.Cache.Insert(cacheKey, data);
                    }
                }
            }

            if (data == null) {
                if (failIfNoData)
                    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.WebService_NoWebServiceData, virtualPath));
                else
                    return null;
            }

            return data;
        }

        private WebServiceData(WebServiceTypeData typeData) {
            _typeData = typeData;
            _serializer = new JavaScriptSerializer(this);
            ScriptingJsonSerializationSection.ApplicationSettings settings = new ScriptingJsonSerializationSection.ApplicationSettings();
            _serializer.MaxJsonLength = settings.MaxJsonLimit;
            _serializer.RecursionLimit = settings.RecursionLimit;
            _serializer.RegisterConverters(settings.Converters);
        }

        
        private WebServiceData(Type type, bool pageMethods) : this(new WebServiceTypeData(type.FullName, type.Namespace, type)) {
            _pageMethods = pageMethods;
            
            if (!_pageMethods) {
                object[] attribs = type.GetCustomAttributes(typeof(ScriptServiceAttribute), true);
                if (attribs.Length == 0)
                    throw new InvalidOperationException(AtlasWeb.WebService_NoScriptServiceAttribute);
            }
        }

        
        internal WebServiceData(WebServiceTypeData typeData, Dictionary<string, WebServiceMethodData> methods)
            : this(typeData) {
            _methods = methods;
        }

        private void AddMethod(Dictionary<string, WebServiceMethodData> methods, MethodInfo method) {
            object[] wmAttribs = method.GetCustomAttributes(typeof(WebMethodAttribute), true);

            
            if (wmAttribs.Length == 0)
                return;

            ScriptMethodAttribute sm = null;
            object[] responseAttribs = method.GetCustomAttributes(typeof(ScriptMethodAttribute), true);
            if (responseAttribs.Length > 0) {
                sm = (ScriptMethodAttribute)responseAttribs[0];
            }

            
            WebServiceMethodData wmd = new WebServiceMethodData(this, method, (WebMethodAttribute)wmAttribs[0], sm);
            methods[wmd.MethodName] = wmd;
        }

        private void EnsureMethods() {
            
            if (_methods != null || _typeData.Type == null)
                return;

            
            lock (this) {

                
                List<Type> typeList = new List<Type>();
                Type current = _typeData.Type;
                typeList.Add(current);
                while (current.BaseType != null) {
                    current = current.BaseType;
                    typeList.Add(current);
                }
                Dictionary<string, WebServiceMethodData> methods = new Dictionary<string, WebServiceMethodData>(StringComparer.OrdinalIgnoreCase);
                BindingFlags flags = BindingFlags.Public | BindingFlags.DeclaredOnly;
                if (_pageMethods) flags |= BindingFlags.Static;
                else flags |= BindingFlags.Instance;

                
                for (int i = typeList.Count - 1; i >= 0; --i) {
                    MethodInfo[] methodInfos = typeList[i].GetMethods(flags);
                    foreach (MethodInfo method in methodInfos) {
                        AddMethod(methods, method);
                    }
                }
                _methods = methods;
            }
        }

        internal WebServiceTypeData TypeData {
            get { return _typeData; }
        }

        internal ICollection<WebServiceMethodData> MethodDatas {
            get {
                EnsureMethods();
                return _methods.Values;
            }
        }

        internal WebServiceMethodData GetMethodData(string methodName) {
            EnsureMethods();

            
            WebServiceMethodData methodData = null;
            if (!_methods.TryGetValue(methodName, out methodData)) {
                throw new ArgumentException(
                    String.Format(CultureInfo.CurrentCulture, AtlasWeb.WebService_UnknownWebMethod, methodName), "methodName");
            }

            EnsureClientTypesProcessed();
            return methodData;
        }

        private void EnsureClientTypesProcessed() {
            if (_clientTypesProcessed)
                return;

            lock (this) {
                if (_clientTypesProcessed)
                    return;
                ProcessClientTypes();
            }
        }

        private void ProcessClientTypes() {

            
            _clientTypesDictionary = new Dictionary<string, Type>();
            _enumTypesDictionary = new Dictionary<Type, object>();

            try {
                
                _processedTypes = new Hashtable();

                
                ProcessIncludeAttributes((GenerateScriptTypeAttribute[])_typeData.Type.GetCustomAttributes(typeof(GenerateScriptTypeAttribute), true));

                foreach (WebServiceMethodData methodData in MethodDatas) {

                    
                    ProcessIncludeAttributes((GenerateScriptTypeAttribute[])methodData.MethodInfo.GetCustomAttributes(typeof(GenerateScriptTypeAttribute), true));

                    
                    foreach (WebServiceParameterData paramData in methodData.ParameterDatas) {
                        ProcessClientType(paramData.ParameterInfo.ParameterType);
                    }

                    
                    if (methodData.UseXmlResponse) continue;
                    ProcessClientType(methodData.ReturnType);
                }
            }
            catch {
                
                _clientTypesDictionary = null;
                _enumTypesDictionary = null;
                throw;
            }
            finally {
                _processedTypes = null;
                _clientTypesProcessed = true;
            }
        }

        private void ProcessIncludeAttributes(GenerateScriptTypeAttribute[] attributes) {
            foreach (GenerateScriptTypeAttribute attribute in attributes) {
                if (!string.IsNullOrEmpty(attribute.ScriptTypeId))
                    _typeResolverSpecials[attribute.Type.FullName] = attribute.ScriptTypeId;

                Type t = attribute.Type;
                if (t.IsPrimitive || t == typeof(object) || t == typeof(string) || 
                    t == typeof(DateTime) || t == typeof(Guid) ||
                    typeof(IEnumerable).IsAssignableFrom(t) || typeof(IDictionary).IsAssignableFrom(t) ||
                    (t.IsGenericType && t.GetGenericArguments().Length > 1) ||
                    !ObjectConverter.IsClientInstantiatableType(t, _serializer))
                    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture,
                        AtlasWeb.WebService_InvalidGenerateScriptType, t.FullName));

                ProcessClientType(t, true);
            }
        }

        private void ProcessClientType(Type t) {
            ProcessClientType(t, false);
        }

        
        private void ProcessClientType(Type t, bool force) {
            if (!force && _processedTypes.Contains(t))
                return;
            _processedTypes[t] = null;

            
            if (t.IsEnum) {
                _enumTypesDictionary[t] = null;
                return;
            }

            
            if (t.IsGenericType) {
                Type[] genericArgs = t.GetGenericArguments();
                if (genericArgs.Length > 1) {
                    return;
                }
                ProcessClientType(genericArgs[0]);
            }
            
            else if (t.IsArray) {
                ProcessClientType(t.GetElementType());
            }
            else {
                
                
                
                if (t.IsPrimitive || t == typeof(object) || t == typeof(string) || t == typeof(DateTime) ||
                    t == typeof(void) || t == typeof(System.Decimal) || t == typeof(Guid) ||
                    typeof(IEnumerable).IsAssignableFrom(t) || typeof(IDictionary).IsAssignableFrom(t) ||
                    !ObjectConverter.IsClientInstantiatableType(t, _serializer))
                    return;

                
                
                _clientTypesDictionary[GetTypeStringRepresentation(t.FullName, false)] = t;
            }
        }

        internal IEnumerable<Type> ClientTypes {
            get {
                return ClientTypeDictionary.Values;
            }
        }

        internal Dictionary<string, Type> ClientTypeDictionary {
            get {
                EnsureClientTypesProcessed();
                return _clientTypesDictionary;
            }
            set {
                _clientTypesDictionary = value;
            }
        }

        internal IEnumerable<Type> EnumTypes {
            get {
                EnsureClientTypesProcessed();
                return _enumTypesDictionary.Keys;
            }
        }

        internal Dictionary<Type, object> EnumTypeDictionary {
            get {
                EnsureClientTypesProcessed();
                return _enumTypesDictionary;
            }
            set {
                _enumTypesDictionary = value;
            }
        }

        public override Type ResolveType(string id) {
            Type type = null;
            if (ClientTypeDictionary.TryGetValue(id, out type)) {
                return type;
            }
            return null;
        }

        public override string ResolveTypeId(Type type) {
            string typeString = GetTypeStringRepresentation(type.FullName);

            
            if (!ClientTypeDictionary.ContainsKey(typeString))
                return null;

            return typeString;
        }

        internal string GetTypeStringRepresentation(string typeName) {
            return GetTypeStringRepresentation(typeName, true);
        }

        internal string GetTypeStringRepresentation(string typeName, bool ensure) {
            if (ensure) {
                EnsureClientTypesProcessed();
            }

            
            string typeString;
            if (_typeResolverSpecials.TryGetValue(typeName, out typeString)) {
                return typeString;
            }

            return typeName;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
