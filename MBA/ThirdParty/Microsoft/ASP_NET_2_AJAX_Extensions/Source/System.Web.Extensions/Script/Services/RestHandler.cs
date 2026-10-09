namespace System.Web.Script.Services {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Collections.Specialized;
    using System.ComponentModel;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.IO;
    using System.Net;
    using System.Reflection;
    using System.Text;
    using System.Xml;
    using System.Xml.Serialization;
    using System.Web;
    using System.Web.Compilation;
    using System.Web.Services;
    using System.Web.SessionState;
    using System.Web.Resources;
    using System.Web.Script.Serialization;
    using System.Security;

    internal class RestHandler : IHttpHandler {
        private WebServiceMethodData _webServiceMethodData;

        internal static IHttpHandler CreateHandler(HttpContext context) {
            
            if (context.Request.PathInfo.Length < 2 || context.Request.PathInfo[0] != '/') {
                throw new InvalidOperationException(AtlasWeb.WebService_InvalidWebServiceCall);
            }

            
            WebServiceData webServiceData = WebServiceData.GetWebServiceData(context, context.Request.FilePath);
            string methodName = context.Request.PathInfo.Substring(1);
            return CreateHandler(webServiceData, methodName);
        }

        private static IHttpHandler CreateHandler(WebServiceData webServiceData, string methodName) {

            
            WebServiceMethodData methodData = webServiceData.GetMethodData(methodName);

            
            RestHandler handler;
            if (methodData.RequiresSession)
                handler = new RestHandlerWithSession();
            else
                handler = new RestHandler();

            
            handler._webServiceMethodData = methodData;
            return handler;
        }

        
        
        
        
        
        
        private static void InitializeCachePolicy(WebServiceMethodData methodData, HttpContext context) {
            int cacheDuration = methodData.CacheDuration;
            if (cacheDuration > 0) {
                context.Response.Cache.SetCacheability(HttpCacheability.Server);
                context.Response.Cache.SetExpires(DateTime.Now.AddSeconds(cacheDuration));
                context.Response.Cache.SetSlidingExpiration(false);
                context.Response.Cache.SetValidUntilExpires(true);

                
                if (methodData.ParameterDatas.Count > 0) {
                    context.Response.Cache.VaryByParams["*"] = true;
                }
                else {
                    context.Response.Cache.VaryByParams.IgnoreParams = true;
                }
            }
            else {
                context.Response.Cache.SetNoServerCaching();
                context.Response.Cache.SetMaxAge(TimeSpan.Zero);
            }
        }

        private static IDictionary<string, object> GetRawParamsFromGetRequest(HttpContext context, JavaScriptSerializer serializer, WebServiceMethodData methodData) {
            
            NameValueCollection queryString = context.Request.QueryString;
            Dictionary<string, object> rawParams = new Dictionary<string, object>();
            foreach (WebServiceParameterData param in methodData.ParameterDatas) {
                string name = param.ParameterInfo.Name;
                string val = queryString[name];
                if (val != null) {
                    rawParams.Add(name, serializer.DeserializeObject(val));
                }
            }
            return rawParams;
        }

        private static IDictionary<string, object> GetRawParamsFromPostRequest(HttpContext context, JavaScriptSerializer serializer) {
            
            TextReader reader = new StreamReader(context.Request.InputStream);
            string bodyString = reader.ReadToEnd();

            
            if (String.IsNullOrEmpty(bodyString)) {
                return new Dictionary<string, object>();
            }

            
            return serializer.Deserialize<IDictionary<string, object>>(bodyString);
        }

        private static IDictionary<string, object> GetRawParams(WebServiceMethodData methodData, HttpContext context) {
            if (methodData.UseGet) {
                if (context.Request.HttpMethod == "GET") {
                    return GetRawParamsFromGetRequest(context, methodData.Owner.Serializer, methodData);
                }
                else {
                    throw new InvalidOperationException(
                        String.Format(CultureInfo.CurrentCulture, AtlasWeb.WebService_InvalidVerbRequest,
                            methodData.MethodName, "POST"));
                }
            }
            else if (context.Request.HttpMethod == "POST") {
                return GetRawParamsFromPostRequest(context, methodData.Owner.Serializer);
            } else {
                throw new InvalidOperationException(
                    String.Format(CultureInfo.CurrentCulture, AtlasWeb.WebService_InvalidVerbRequest,
                        methodData.MethodName, "GET"));
            }
        }

        private static void InvokeMethod(HttpContext context, WebServiceMethodData methodData, IDictionary<string, object> rawParams) {
            
            InitializeCachePolicy(methodData, context);

            
            object target = null;
            if (!methodData.IsStatic) target = Activator.CreateInstance(methodData.Owner.TypeData.Type);

            
            object retVal = methodData.CallMethodFromRawParams(target, rawParams);

            string contentType;
            string responseString = null;
            if (methodData.UseXmlResponse) {
                responseString = retVal as string;

                
                if (responseString == null || methodData.XmlSerializeString) {
                    
                    try {
                        responseString = ServicesUtilities.XmlSerializeObjectToString(retVal);
                    }
                    catch (Exception e) {
                        
                        throw new InvalidOperationException(
                            String.Format(CultureInfo.CurrentCulture, AtlasWeb.WebService_InvalidXmlReturnType,
                                methodData.MethodName, retVal.GetType().FullName, e.Message));
                    }
                }

                contentType = "text/xml";
            }
            else {

                
                responseString = methodData.Owner.Serializer.Serialize(retVal);
                contentType = "application/json";
            }

            
            context.Response.ContentType = contentType;

            
            if (responseString != null)
                context.Response.Write(responseString);
        }

        private static NamedPermissionSet s_permissionSet;
        private static bool s_permissionSetChecked;
        [SuppressMessage("Microsoft.Design", "CA1031:DoNotCatchGeneralExceptionTypes",
            Justification="All exceptions need to be reported to the client")]
        [SuppressMessage("Microsoft.Security", "CA2107:ReviewDenyAndPermitOnlyUsage",
           Justification = "Fix for DevDiv 39162 GAC'd non-APTCA types can instantiate in networking stack in Medium trust")]
        internal static void ExecuteWebServiceCall(HttpContext context, WebServiceMethodData methodData) {
            try {
                
                if (!s_permissionSetChecked) {
                    PropertyInfo prop = typeof(HttpRuntime).GetProperty("NamedPermissionSet", BindingFlags.Static | BindingFlags.NonPublic);
                    s_permissionSet = (NamedPermissionSet)prop.GetValue(null, null);
                    s_permissionSetChecked = true;
                }
                if (s_permissionSet != null) {
                    s_permissionSet.PermitOnly();
                }

                
                IDictionary<string, object> rawParams = GetRawParams(methodData, context);
                InvokeMethod(context, methodData, rawParams);
            }
            catch (Exception ex) {
                WriteExceptionJsonString(context, ex);
            }
        }

        internal class WebServiceError {
            public string Message;
            public string StackTrace;
            public string ExceptionType;

            public WebServiceError(string msg, string stack, string type) {
                Message = msg;
                StackTrace = stack;
                ExceptionType = type;
            }
        }

        internal static void WriteExceptionJsonString(HttpContext context, Exception ex) {
            context.Response.ClearHeaders();
            context.Response.ClearContent();
            context.Response.Clear();
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            context.Response.StatusDescription = HttpWorkerRequest.GetStatusDescription((int)HttpStatusCode.InternalServerError);
            context.Response.ContentType = "application/json";
            context.Response.AddHeader("jsonerror", "true");
            using (StreamWriter writer = new StreamWriter(context.Response.OutputStream, new UTF8Encoding(false))) {
                if (ex is TargetInvocationException) {
                    ex = ex.InnerException;
                }

                
                if (context.IsCustomErrorEnabled) {
                    writer.Write(JavaScriptSerializer.SerializeInternal(new WebServiceError(AtlasWeb.WebService_Error, String.Empty, String.Empty)));
                }
                else {
                    writer.Write(JavaScriptSerializer.SerializeInternal(new WebServiceError(ex.Message, ex.StackTrace, ex.GetType().FullName)));
                }
                writer.Flush();
            }
        }

        public void ProcessRequest(HttpContext context) {
            ExecuteWebServiceCall(context, _webServiceMethodData);
        }

        public bool IsReusable {
            get {
                return false;
            }
        }
    }

    
    internal class RestHandlerWithSession: RestHandler, IRequiresSessionState {
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
