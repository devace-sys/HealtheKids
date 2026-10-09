using System;
using System.Diagnostics;
using System.Web;

namespace System.Web.UI {
    internal class HttpBrowserCapabilitiesWrapper : IHttpBrowserCapabilities {
        private HttpBrowserCapabilities _browser;

        public HttpBrowserCapabilitiesWrapper(HttpBrowserCapabilities browser) {
            Debug.Assert(browser != null);
            _browser = browser;
        }

        #region IHttpBrowserCapabilities Members
        string IHttpBrowserCapabilities.Browser {
            get {
                return _browser.Browser;
            }
        }

        Version IHttpBrowserCapabilities.EcmaScriptVersion {
            get {
                return _browser.EcmaScriptVersion;
            }
        }

        Version IHttpBrowserCapabilities.JScriptVersion {
            get {
                return _browser.JScriptVersion;
            }
        }

        bool IHttpBrowserCapabilities.SupportsCallback {
            get {
                return _browser.SupportsCallback;
            }
        }

        Version IHttpBrowserCapabilities.W3CDomVersion {
            get {
                return _browser.W3CDomVersion;
            }
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
