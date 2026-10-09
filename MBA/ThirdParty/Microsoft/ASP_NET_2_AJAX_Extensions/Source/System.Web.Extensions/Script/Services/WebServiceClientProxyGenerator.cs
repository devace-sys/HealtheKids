namespace System.Web.Script.Services {
    using System;
    using System.IO;
    using System.Reflection;
    using System.Text;
    using System.Web;

    internal class WebServiceClientProxyGenerator : ClientProxyGenerator {
        private string _path;

        
        internal static string GetInlineClientProxyScript(string path, HttpContext context, bool debug) {
            WebServiceData webServiceData = WebServiceData.GetWebServiceData(context, path);
            WebServiceClientProxyGenerator proxyGenerator = new WebServiceClientProxyGenerator(path, debug);
            return proxyGenerator.GetClientProxyScript(webServiceData);
        }

        private static DateTime GetAssemblyModifiedTime(Assembly assembly) {
            AssemblyName assemblyName = assembly.GetName();
            DateTime writeTime = File.GetLastWriteTime(new Uri(assemblyName.CodeBase).LocalPath);
            return new DateTime(writeTime.Year, writeTime.Month, writeTime.Day, writeTime.Hour, writeTime.Minute, 0);
        }

        
        internal static string GetClientProxyScript(HttpContext context) {
            WebServiceData webServiceData = WebServiceData.GetWebServiceData(context, context.Request.FilePath);
            DateTime lastModifiedDate = GetAssemblyModifiedTime(webServiceData.TypeData.Type.Assembly);

            
            string modifiedSince = context.Request.Headers["If-Modified-Since"];
            if (modifiedSince != null) {
                DateTime header;
                if (DateTime.TryParse(modifiedSince, out header)) {
                    
                    if (header >= lastModifiedDate) {
                        context.Response.StatusCode = 304;
                        return null;
                    }
                }
            }
            bool debug = RestHandlerFactory.IsClientProxyDebugRequest(context.Request.PathInfo);
            
            if (!debug) {
                
                if (lastModifiedDate.ToUniversalTime() < DateTime.UtcNow) {
                    
                    HttpCachePolicy cachePolicy = context.Response.Cache;
                    cachePolicy.SetCacheability(HttpCacheability.Public);
                    cachePolicy.SetLastModified(lastModifiedDate);
                }
            }

            WebServiceClientProxyGenerator proxyGenerator = new WebServiceClientProxyGenerator(context.Request.FilePath, debug);
            return proxyGenerator.GetClientProxyScript(webServiceData);
        }

        private WebServiceClientProxyGenerator(string path, bool debug) {
            _path = path;
            _debugMode = debug;
        }

        protected override string GetProxyPath() {
            return _path;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
