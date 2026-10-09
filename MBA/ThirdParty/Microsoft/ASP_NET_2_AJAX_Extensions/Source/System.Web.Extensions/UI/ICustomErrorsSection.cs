namespace System.Web.UI {
    using System;
    using System.Web.Configuration;

    internal interface ICustomErrorsSection {
        string DefaultRedirect {
            get;
        }

        CustomErrorCollection Errors {
            get;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
