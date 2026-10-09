namespace System.Web.UI {
    using System;
    using System.Security.Permissions;
    using System.Web;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class AsyncPostBackErrorEventArgs : EventArgs {
        private readonly Exception _exception;

        public AsyncPostBackErrorEventArgs(Exception exception) {
            if (exception == null) {
                throw new ArgumentNullException("exception");
            }
            _exception = exception;
        }

        public Exception Exception {
            get {
                return _exception;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
