namespace System.Web.Script.Serialization {
    using System;
    using System.Collections.Generic;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    ]
    public class SimpleTypeResolver : JavaScriptTypeResolver {
        public override Type ResolveType(string id) {
            return Type.GetType(id);
        }

        public override string ResolveTypeId(Type type) {
            if (type == null) {
                throw new ArgumentNullException("type");
            }

            return type.AssemblyQualifiedName;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
