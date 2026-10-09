namespace System.Web.UI {
    using System;
    using System.Web;
    using System.Diagnostics;

    internal sealed class HttpContextWrapper : IHttpContext {
        private readonly HttpContext _context;

        public HttpContextWrapper(HttpContext context) {
            Debug.Assert(context != null);
            _context = context;
        }

        #region IHttpContext Members
        bool IHttpContext.IsCustomErrorEnabled {
            get {
                return _context.IsCustomErrorEnabled;
            }
        }

        IHttpRequest IHttpContext.Request {
            get {
                return new HttpRequestWrapper(_context.Request);
            }
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
