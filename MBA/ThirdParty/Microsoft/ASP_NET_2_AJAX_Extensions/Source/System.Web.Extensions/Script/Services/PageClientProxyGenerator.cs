namespace System.Web.Script.Services {
    using System;
    using System.Web;
    using System.Web.UI;
    using System.Text;

    internal class PageClientProxyGenerator : ClientProxyGenerator {
        IPage _page;
        internal PageClientProxyGenerator(IPage page, bool debug) {
            _page = page;
            _debugMode = debug;
        }

        internal static string GetClientProxyScript(HttpContext context, IPage page, bool debug) {
            
            if (context == null || page == null) return null;

            WebServiceData webServiceData = WebServiceData.GetWebServiceData(context,
                page.AppRelativeVirtualPath,
                false ,
                true );
            if (webServiceData == null)
                return null;

            PageClientProxyGenerator proxyGenerator = new PageClientProxyGenerator(page, debug);
            return proxyGenerator.GetClientProxyScript(webServiceData);
        }

        protected override void GenerateTypeDeclaration(WebServiceData webServiceData, bool genClass) {
            if (genClass) {
                _builder.Append("PageMethods.prototype = ");
            }
            else {
                _builder.Append("var PageMethods = ");
            }
        }

        protected override string GetProxyTypeName(WebServiceData data) {
            return "PageMethods";
        }

        protected override string GetProxyPath() {
            return _page.Request.FilePath;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
