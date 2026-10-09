using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Security;

namespace System.Web.Script.Services {
    internal class RestClientProxyHandler : IHttpHandler {
        public void ProcessRequest(HttpContext context) {
            if (context == null) {
                throw new ArgumentNullException("context");
            }

            string clientProxyString = WebServiceClientProxyGenerator.GetClientProxyScript(context);
            if (clientProxyString != null) {
                context.Response.ContentType = "application/x-javascript";
                context.Response.Write(clientProxyString);
            }
        }

        public bool IsReusable {
            get {
                return false;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
