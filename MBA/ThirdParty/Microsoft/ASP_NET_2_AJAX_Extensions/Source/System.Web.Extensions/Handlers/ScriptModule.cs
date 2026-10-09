namespace System.Web.Handlers {
    using System;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Script.Services;
    using System.Web.Security;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class ScriptModule : IHttpModule {
        private static Type _authenticationServiceType = typeof(AuthenticationService);

        private static bool ShouldSkipAuthorization(HttpContext context) {
            if (context == null || context.Request == null) {
                return false;
            }

            string path = context.Request.FilePath;

            if ((path != null) && path.EndsWith("/scriptresource.axd", StringComparison.OrdinalIgnoreCase)) {
                return true;
            }

            
            
            
            if(!AuthenticationService.Enabled || !RestHandlerFactory.IsRestRequest(context)) {
                return false;
            }

            if(context.SkipAuthorization) {
                return true;
            }

            
            if((path == null) || !path.EndsWith(".axd", StringComparison.OrdinalIgnoreCase)) {
                return false;
            }

            
            
            
            WebServiceData wsd = WebServiceData.GetWebServiceData(context, path, false, false);
            if((wsd != null) && (_authenticationServiceType == wsd.TypeData.Type)) {
                return true;
            }

            return false;
        }

        protected virtual void Dispose() {
        }

        private void AuthenticateRequestHandler(object sender, EventArgs e) {
            
            
            HttpApplication app = (HttpApplication)sender;
            if (app != null && ShouldSkipAuthorization(app.Context)) {
                app.Context.SkipAuthorization = true;
            }
        }

        protected virtual void Init(HttpApplication context) {
            context.PreSendRequestHeaders += new EventHandler(PreSendRequestHeadersHandler);
            context.PostAcquireRequestState += new EventHandler(OnPostAcquireRequestState);
            context.AuthenticateRequest += new EventHandler(AuthenticateRequestHandler);
        }

        private void OnPostAcquireRequestState(object sender, EventArgs eventArgs) {
            HttpApplication app = (HttpApplication)sender;
            HttpRequest request = app.Context.Request;

            if (app.Context.Handler is Page && RestHandlerFactory.IsRestMethodCall(request)) {
                
                WebServiceData webServiceData = WebServiceData.GetWebServiceData(HttpContext.Current, request.FilePath, false, true);

                
                string methodName = request.PathInfo.Substring(1);

                
                WebServiceMethodData methodData = webServiceData.GetMethodData(methodName);
                RestHandler.ExecuteWebServiceCall(HttpContext.Current, methodData);

                
                app.CompleteRequest();
            }
        }

        private void PreSendRequestHeadersHandler(object sender, EventArgs args) {
            HttpApplication application = (HttpApplication)sender;
            HttpResponse response = application.Response;

            if (response.StatusCode == 302) {
                
                if (PageRequestManager.IsAsyncPostBackRequest(application.Request.Headers)) {

                    
                    string redirectLocation = response.RedirectLocation;
                    List<HttpCookie> cookies = new List<HttpCookie>(response.Cookies.Count);
                    for (int i = 0; i < response.Cookies.Count; i++) {
                        cookies.Add(response.Cookies[i]);
                    }

                    
                    response.ClearContent();
                    response.ClearHeaders();
                    for (int i = 0; i < cookies.Count; i++) {
                        response.AppendCookie(cookies[i]);
                    }
                    response.Cache.SetCacheability(HttpCacheability.NoCache);
                    response.ContentType = "text/plain";
                    PageRequestManager.EncodeString(response.Output, PageRequestManager.PageRedirectToken, String.Empty, redirectLocation);
                }
                else if (RestHandlerFactory.IsRestRequest(application.Context)) {
                    
                    RestHandler.WriteExceptionJsonString(application.Context, new InvalidOperationException(AtlasWeb.WebService_RedirectError));
                }
            }
        }

        #region IHttpModule Members
        void IHttpModule.Dispose() {
            Dispose();
        }

        void IHttpModule.Init(HttpApplication context) {
            Init(context);
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
