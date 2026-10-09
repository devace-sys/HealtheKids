namespace System.Web.Script.Serialization {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.Configuration;
    using System.Web.Compilation;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public abstract class JavaScriptConverter {
        public abstract IEnumerable<Type> SupportedTypes {
            get;
        }

        public abstract object Deserialize(IDictionary<string, object> dictionary, Type type, JavaScriptSerializer serializer);
        public abstract IDictionary<string, object> Serialize(object obj, JavaScriptSerializer serializer);
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
