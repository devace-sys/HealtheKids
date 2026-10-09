namespace System.Web.UI.Design {
    using System;
    using System.Web.UI.Design;

    public class ExtenderControlDesigner : ControlDesigner {
        private ExtenderControl ExtenderControl {
            get {
                return (ExtenderControl)Component;
            }
        }

        public override string GetDesignTimeHtml() {
            return DesignUtil.GetStandardDesignTimeHtml(Component.Site, ExtenderControl.GetType().Name, ExtenderControl.ID, false);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
