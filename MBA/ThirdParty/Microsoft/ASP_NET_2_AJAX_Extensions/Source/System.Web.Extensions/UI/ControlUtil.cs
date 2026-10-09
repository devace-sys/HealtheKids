using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Resources;
using System.Web.UI;

namespace System.Web.UI {
    internal class ControlUtil {
        internal static Control FindTargetControl(string controlID, Control control, bool searchNamingContainers) {
            Control foundControl;
            if (searchNamingContainers) {
                Control currentContainer = control;
                foundControl = null;
                while (foundControl == null && currentContainer != control.Page) {
                    currentContainer = currentContainer.NamingContainer;
                    if (currentContainer == null) {
                        break;
                    }
                    foundControl = currentContainer.FindControl(controlID);
                }
            }
            else {
                foundControl = control.FindControl(controlID);
            }
            return foundControl;
        }

    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
