using System;
using System.Data;
using System.Configuration;
using System.Diagnostics;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

namespace System.Web.Script.Services {

    internal class RestHandlerFactory : IHttpHandlerFactory {
        internal const string ClientProxyRequestPathInfo = "/js";
        internal const string ClientDebugProxyRequestPathInfo = "/jsdebug";

        public virtual IHttpHandler GetHandler(HttpContext context, string requestType, string url, string pathTranslated) {
            if (context == null) {
                throw new ArgumentNullException("context");
            }

            if (IsClientProxyRequest(context.Request.PathInfo)) {
                
                return new RestClientProxyHandler();
            }
            else {
                
                return RestHandler.CreateHandler(context);
            }
        }

        public virtual void ReleaseHandler(IHttpHandler handler) {
        }

        
        internal static bool IsRestRequest(HttpContext context) {
            return IsRestMethodCall(context.Request) || IsClientProxyRequest(context.Request.PathInfo);
        }

        
        internal static bool IsRestMethodCall(HttpRequest request) {
            return
                !String.IsNullOrEmpty(request.PathInfo) &&
                (request.ContentType.StartsWith("application/json;", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(request.ContentType, "application/json", StringComparison.OrdinalIgnoreCase));
        }

        internal static bool IsClientProxyDebugRequest(string pathInfo) {
            return string.Equals(pathInfo, ClientDebugProxyRequestPathInfo, StringComparison.OrdinalIgnoreCase);
        }

        internal static bool IsClientProxyRequest(string pathInfo) {
            return (string.Equals(pathInfo, ClientProxyRequestPathInfo, StringComparison.OrdinalIgnoreCase) ||
                IsClientProxyDebugRequest(pathInfo));
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
