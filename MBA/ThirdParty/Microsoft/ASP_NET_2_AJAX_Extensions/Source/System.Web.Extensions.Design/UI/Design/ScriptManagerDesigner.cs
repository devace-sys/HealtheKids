namespace System.Web.UI.Design {
    using System;
    using System.Web.UI.Design;

    public class ScriptManagerDesigner : ControlDesigner {
        private ScriptManager ScriptManager {
            get {
                return (ScriptManager)Component;
            }
        }

        public override string GetDesignTimeHtml() {
            return DesignUtil.GetStandardDesignTimeHtml(Component.Site, ScriptManager.GetType().Name, ScriptManager.ID, false);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
