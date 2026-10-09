namespace System.Web.UI.Design {
    using System;
    using System.ComponentModel;
    using System.ComponentModel.Design;
    using System.Diagnostics;
    using System.Web;

    public class UpdatePanelTriggerCollectionEditor : CollectionEditorBase {
        private static readonly Type[] TriggerTypes = new Type[] {
            typeof(AsyncPostBackTrigger),
            typeof(PostBackTrigger),
        };

        public UpdatePanelTriggerCollectionEditor(Type type)
            : base(type) {
        }

        protected override bool CanSelectMultipleInstances() {
            return false;
        }

        protected override Type CreateCollectionItemType() {
            
            
            return typeof(UpdatePanelTrigger);
        }

        protected override Type[] CreateNewItemTypes() {
            return TriggerTypes;
        }

        public override object EditValue(ITypeDescriptorContext context, IServiceProvider provider, object value) {
            UpdatePanelDesigner designer = null;
            if (context != null) {
                UpdatePanel updatePanel = null;
                updatePanel = context.Instance as UpdatePanel;
                IDesignerHost host = null;
                if (provider != null) {
                    host = (IDesignerHost)provider.GetService(typeof(IDesignerHost));
                    if (host != null) {
                        designer = host.GetDesigner(updatePanel) as UpdatePanelDesigner;
                    }
                }
            }

            
            if (designer != null) {
                designer.EnterTriggerEditor();
            }

            value = base.EditValue(context, provider, value);

            if (designer != null) {
                designer.ExitTriggerEditor();
            }

            return value;
        }

        
        
        
        
        
        
        private sealed class UpdatePanelTrigger : System.Web.UI.UpdatePanelTrigger {
            private int _dummyProperty;

            public int DummyProperty {
                get {
                    Debug.Fail("DummyProperty should never be accessed.");
                    return _dummyProperty;
                }
                set {
                    _dummyProperty = value;
                    Debug.Fail("DummyProperty should never be accessed.");
                }
            }

            protected override bool HasTriggered() {
                return false;
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
