namespace System.Web.UI.Design {
    using System;
    using System.ComponentModel.Design;
    using System.Security.Permissions;
    using System.Windows.Forms;

    public class CollectionEditorBase : CollectionEditor {
        public CollectionEditorBase(Type type)
            : base(type) {
        }

        protected override CollectionForm CreateCollectionForm() {
            CollectionForm form = base.CreateCollectionForm();

            
            UpdatePropertyGridSettings(form);

            return form;
        }

        private bool UpdatePropertyGridSettings(Control control) {
            PropertyGrid grid = control as PropertyGrid;
            if (grid != null) {
                grid.HelpVisible = true;
                return true;
            }
            foreach (Control child in control.Controls) {
                if (UpdatePropertyGridSettings(child)) {
                    return true;
                }
            }
            return false;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
