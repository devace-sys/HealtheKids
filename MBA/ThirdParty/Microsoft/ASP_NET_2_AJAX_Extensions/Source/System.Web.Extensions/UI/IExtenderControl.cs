namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.Diagnostics.CodeAnalysis;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.UI;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public interface IExtenderControl {
        IEnumerable<ScriptDescriptor> GetScriptDescriptors(Control targetControl);

        [SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate",
            Justification = "Implementation will likely return a new collection, which is too slow for a property")]
        IEnumerable<ScriptReference> GetScriptReferences();
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
