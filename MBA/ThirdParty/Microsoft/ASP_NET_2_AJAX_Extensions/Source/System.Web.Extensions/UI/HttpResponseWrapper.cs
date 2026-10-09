namespace System.Web.UI {
    using System;
    using System.Collections.Specialized;
    using System.Diagnostics;
    using System.Web;
    using System.IO;
    using System.Security;
    using System.Security.Permissions;

    internal sealed class HttpResponseWrapper : IHttpResponse {
        private HttpResponse _httpResponse;

        public HttpResponseWrapper(HttpResponse httpResponse) {
            Debug.Assert(httpResponse != null);
            _httpResponse = httpResponse;
        }

        #region IHttpResponse Members
        IHttpCachePolicy IHttpResponse.Cache {
            get {
                return new HttpCachePolicyWrapper(_httpResponse.Cache);
            }
        }

        string IHttpResponse.ContentType {
            set {
                _httpResponse.ContentType = value;
            }
        }

        Stream IHttpResponse.Filter {
            get {
                return _httpResponse.Filter;
            }
            set {
                _httpResponse.Filter = value;
            }
        }

        TextWriter IHttpResponse.Output {
            get {
                return _httpResponse.Output;
            }
        }

        void IHttpResponse.Clear() {
            _httpResponse.Clear();
        }

        void IHttpResponse.End() {
            _httpResponse.End();
        }

        [SecurityPermission(SecurityAction.Assert, Flags = SecurityPermissionFlag.UnmanagedCode),SecurityCritical,SecurityTreatAsSafe]
        void IHttpResponse.Flush() {
            _httpResponse.Flush();
        }

        void IHttpResponse.Write(string s) {
            _httpResponse.Write(s);
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
