namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.ComponentModel;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;
    using System.Web.Script.Serialization;
    using System.Web.Security;
    using System.Diagnostics;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Path"),
    TypeConverter(typeof(EmptyStringExpandableObjectConverter))
    ]
    public class AuthenticationServiceManager {
        private const int StringBuilderCapacity = 128;

        private string _path;

        internal static void ConfigureAuthenticationService(ref StringBuilder sb, HttpContext context, ScriptManager scriptManager, List<ScriptManagerProxy> proxies) {
            string authServiceUrl = null;
            AuthenticationServiceManager authManager;

            if(scriptManager.HasAuthenticationServiceManager) {
                authManager = scriptManager.AuthenticationService;

                
                authServiceUrl = authManager.Path.Trim();
                if(authServiceUrl.Length > 0) {
                    authServiceUrl = scriptManager.ResolveUrl(authServiceUrl);
                }
            }

            
            if(proxies != null) {
                foreach(ScriptManagerProxy proxy in proxies) {
                    if(proxy.HasAuthenticationServiceManager) {
                        authManager = proxy.AuthenticationService;

                        
                        authServiceUrl = ApplicationServiceManager.MergeServiceUrls(authManager.Path, authServiceUrl, proxy);
                    }
                }
            }
            AuthenticationServiceManager.GenerateInitializationScript(ref sb, context, scriptManager, authServiceUrl);
        }

        private static void GenerateInitializationScript(ref StringBuilder sb, HttpContext context, ScriptManager scriptManager, string serviceUrl) {
            bool authEnabled = AuthenticationService.Enabled;

            if(authEnabled) {
                if (sb == null) {
                    sb = new StringBuilder(StringBuilderCapacity);
                }

                
                
                
                
                string defaultServicePath = scriptManager.ResolveClientUrl("~/" + System.Web.Script.Services.WebServiceData._authenticationServiceFileName);
                sb.Append("Sys.Services._AuthenticationService.DefaultWebServicePath = '");
                sb.Append(JavaScriptString.QuoteString(defaultServicePath));
                sb.Append("';\n");
            }

            bool pathSpecified = !string.IsNullOrEmpty(serviceUrl);
            if(pathSpecified) {
                if (sb == null) {
                    sb = new StringBuilder(StringBuilderCapacity);
                }

                sb.Append("Sys.Services.AuthenticationService.set_path('");
                sb.Append(JavaScriptString.QuoteString(serviceUrl));
                sb.Append("');\n");
            }

            
            if ((authEnabled || pathSpecified) &&
                (context != null && context.Request.IsAuthenticated)) {
                Debug.Assert(sb != null);
                sb.Append("Sys.Services.AuthenticationService._setAuthenticated(true);\n");
            }
        }

        [
        DefaultValue(""),
        Category("Behavior"),
        NotifyParentProperty(true),
        ResourceDescription("ApplicationServiceManager_Path")
        ]
        public string Path {
            get { return _path ?? string.Empty; }
            set { _path = value; }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
