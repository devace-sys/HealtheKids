namespace System.Web.UI.Design {
    using System;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Diagnostics;
    using System.Web.UI;
    using System.Web.UI.Design;

    internal static class TriggerDesignUtil {
        internal static bool IsValidTarget(IComponent component, IComponent rootComponent, bool requireSite) {
            
            
            
            
            
            Control control = component as Control;
            return ((control != null) &&
                (!requireSite || control.Site != null) &&
                (control != rootComponent) &&
                !String.IsNullOrEmpty(control.ID) &&
                (control is INamingContainer ||
                control is IPostBackDataHandler ||
                control is IPostBackEventHandler));
        }

        private static bool WalkChildren(IComponent rootComponent, Control control, bool requireSite, Predicate<IComponent> visitor, Control walkLimit) {
            if (control == walkLimit) {
                return false;
            }

            if (IsValidTarget(control, rootComponent, requireSite) && visitor(control)) {
                return false;
            }

            foreach (Control child in control.Controls) {
                if (WalkChildren(rootComponent, child, requireSite, visitor, walkLimit)) {
                    return true;
                }
            }

            return false;
        }

        internal static void WalkControlTree(Control startControl, Predicate<IComponent> visitor, bool requireSite, Control walkLimit) {
            Debug.Assert(startControl != null, "startControl must not be null");
            Debug.Assert(visitor != null, "visitor must not be null");
            Debug.Assert(requireSite == (walkLimit != null), "If requireSite is true there should be a walkLimit. There's no technical reason for this but these are the only scenarios considered.");

            IDesignerHost host = (IDesignerHost)startControl.Site.GetService(typeof(IDesignerHost));
            IComponent rootComponent = host.RootComponent;

            WalkChildren(rootComponent, startControl, requireSite, visitor, walkLimit);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
