namespace System.Web.UI.Design {
    using System;
    using System.ComponentModel;

    public class TimerDesigner : ControlDesigner {
        private Timer Timer {
            get {
                return (Timer)Component;
            }
        }

        public override string GetDesignTimeHtml() {;
            return DesignUtil.GetStandardDesignTimeHtml(Component.Site, Timer.GetType().Name, Timer.ID, false);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
