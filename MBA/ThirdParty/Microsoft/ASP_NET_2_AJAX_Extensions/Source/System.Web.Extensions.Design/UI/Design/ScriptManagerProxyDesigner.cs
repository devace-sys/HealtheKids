namespace System.Web.UI.Design {
    using System;
    using System.Web.UI.Design;

    public class ScriptManagerProxyDesigner : ControlDesigner {
        private ScriptManagerProxy ScriptManagerProxy {
            get {
                return (ScriptManagerProxy)Component;
            }
        }

        public override string GetDesignTimeHtml() {
            return DesignUtil.GetStandardDesignTimeHtml(Component.Site, ScriptManagerProxy.GetType().Name, ScriptManagerProxy.ID, false);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
