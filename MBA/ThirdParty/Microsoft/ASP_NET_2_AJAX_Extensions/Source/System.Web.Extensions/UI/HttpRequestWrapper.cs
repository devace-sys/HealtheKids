using System;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Web;

namespace System.Web.UI {
    internal sealed class HttpRequestWrapper : IHttpRequest {
        private HttpRequest _httpRequest;

        public HttpRequestWrapper(HttpRequest httpRequest) {
            Debug.Assert(httpRequest != null);
            _httpRequest = httpRequest;
        }

        #region IHttpRequest Members
        IHttpBrowserCapabilities IHttpRequest.Browser {
            get {
                return new HttpBrowserCapabilitiesWrapper(_httpRequest.Browser);
            }
        }

        string IHttpRequest.Path {
            get {
                return _httpRequest.Path;
            }
        }

        string IHttpRequest.FilePath {
            get {
                return _httpRequest.FilePath;
            }
        }

        NameValueCollection IHttpRequest.Headers {
            get {
                return _httpRequest.Headers;
            }
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
