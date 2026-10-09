using System;
using System.Diagnostics;
using System.Web;

namespace System.Web.UI {
    internal sealed class HttpCachePolicyWrapper : IHttpCachePolicy {
        private HttpCachePolicy _httpCachePolicy;

        public HttpCachePolicyWrapper(HttpCachePolicy httpCachePolicy) {
            Debug.Assert(httpCachePolicy != null);
            _httpCachePolicy = httpCachePolicy;
        }

        #region IHttpCachePolicy Members
        void IHttpCachePolicy.SetNoServerCaching() {
            _httpCachePolicy.SetNoServerCaching();
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
