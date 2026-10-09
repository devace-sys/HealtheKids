namespace System.Web.UI {
    using System;
    using System.ComponentModel;
    using System.Diagnostics;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Compilation;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Script.Services;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Path")
    ]
    public class ServiceReference {
        private string _path;
        private bool _inlineScript;

        public ServiceReference() {
        }

        public ServiceReference(string path) {
            Path = path;
        }

        [
        ResourceDescription("ServiceReference_InlineScript"),
        DefaultValue(false),
        Category("Behavior")
        ]
        public bool InlineScript {
            get {
                return _inlineScript;
            }
            set {
                _inlineScript = value;
            }
        }

        [
        ResourceDescription("ServiceReference_Path"),
        DefaultValue(""),
        Category("Behavior")
        ]
        public string Path {
            get {
                if (_path == null) {
                    return String.Empty;
                }
                return _path;
            }
            set {
                _path = value;
            }
        }

        private string GetInlineScript(Control containingControl, HttpContext context, bool debug) {
            
            if (RestHandlerFactory.IsRestMethodCall(context.Request)) {
                return String.Empty;
            }
            string servicePath = GetServicePath(containingControl, false);
            try {
                servicePath = VirtualPathUtility.Combine(context.Request.FilePath, servicePath);
            }
            catch {
                throw new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.WebService_InvalidInlineVirtualPath, servicePath));
            }
            return WebServiceClientProxyGenerator.GetInlineClientProxyScript(servicePath, context, debug);
        }

        private string GetServicePath(Control containingControl, bool encodeSpaces) {
            string path = Path;
            if (String.IsNullOrEmpty(path)) {
                throw new InvalidOperationException(AtlasWeb.ServiceReference_PathCannotBeEmpty);
            }
            if (encodeSpaces) {
                path = containingControl.ResolveClientUrl(path);
            }
            else {
                path = containingControl.ResolveUrl(path);
            }
            return path;
        }

        private string GetProxyPath(Control containingControl, bool debug) {
            if (debug)
                return GetServicePath(containingControl, true) + RestHandlerFactory.ClientDebugProxyRequestPathInfo;
            else
                return GetServicePath(containingControl, true) + RestHandlerFactory.ClientProxyRequestPathInfo;
        }

        internal void Register(Control containingControl, HttpContext context, ScriptManager scriptManager, bool debug) {
            if (InlineScript) {
                RenderClientScriptBlock(GetInlineScript(containingControl, context, debug), scriptManager);
            }
            else {
                RegisterClientScriptInclude(GetProxyPath(containingControl, debug), scriptManager);
            }
        }

        private static void RegisterClientScriptInclude(string path, ScriptManager scriptManager) {
            scriptManager.RegisterClientScriptIncludeInternal(scriptManager, typeof(ScriptManager), path, path);
        }

        private static void RenderClientScriptBlock(string script, ScriptManager scriptManager) {
            scriptManager.RegisterClientScriptBlockInternal(scriptManager, typeof(ScriptManager), script, script, true);
        }

        public override string ToString() {
            if (!String.IsNullOrEmpty(Path)) {
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
