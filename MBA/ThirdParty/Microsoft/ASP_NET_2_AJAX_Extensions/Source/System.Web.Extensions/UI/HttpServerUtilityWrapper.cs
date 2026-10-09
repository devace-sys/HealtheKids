namespace System.Web.UI {
    using System;
    using System.Diagnostics;
    using System.Web;

    internal sealed class HttpServerUtilityWrapper : IHttpServerUtility {
        private HttpServerUtility _httpServerUtility;

        public HttpServerUtilityWrapper(HttpServerUtility httpServerUtility) {
            Debug.Assert(httpServerUtility != null);
            _httpServerUtility = httpServerUtility;
        }

        #region IHttpServerUtility Members
        Exception IHttpServerUtility.GetLastError() {
            return _httpServerUtility.GetLastError();
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
