namespace System.Web.UI {
    using System;
    using System.ComponentModel;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Drawing;
    using System.Drawing.Design;
    using System.Globalization;
    using System.IO;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Triggers"),
    Designer("System.Web.UI.Design.UpdatePanelDesigner, " + AssemblyRef.SystemWebExtensionsDesign),
    ParseChildren(true),
    PersistChildren(false),
    ToolboxBitmap(typeof(EmbeddedResourceFinder), "System.Web.Resources.UpdatePanel.bmp"),
    ]
    public class UpdatePanel : Control {

        private const string UpdatePanelToken = "updatePanel";

        private IPage _page;
        private IScriptManagerInternal _scriptManager;

        private bool _childrenAsTriggers = true;
        private ITemplate _contentTemplate;
        private Control _contentTemplateContainer;
        private bool _asyncPostBackMode;
        private bool _asyncPostBackModeInitialized;
        private UpdatePanelUpdateMode _updateMode = UpdatePanelUpdateMode.Always;
        private bool _rendered;
        private bool _explicitUpdate;
        private UpdatePanelRenderMode _renderMode = UpdatePanelRenderMode.Block;
        private UpdatePanelTriggerCollection _triggers;

        
        
        
        
        private bool _panelRegistered;

        public UpdatePanel() {
        }

        internal UpdatePanel(IScriptManagerInternal scriptManager, IPage page) {
            _scriptManager = scriptManager;
            _page = page;
        }

        [
        ResourceDescription("UpdatePanel_ChildrenAsTriggers"),
        Category("Behavior"),
        DefaultValue(true),
        ]
        public bool ChildrenAsTriggers {
            get {
                return _childrenAsTriggers;
            }
            set {
                _childrenAsTriggers = value;
            }
        }

        [
        Browsable(false),
        PersistenceMode(PersistenceMode.InnerProperty),
        TemplateInstance(TemplateInstance.Single),
        ]
        public ITemplate ContentTemplate {
            get {
                return _contentTemplate;
            }
            set {
                if (!DesignMode) {
                    if (_contentTemplateContainer != null) {
                        throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_CannotSetContentTemplate, ID));
                    }
                    _contentTemplate = value;
                }
                else {
                    _contentTemplate = value;
                    CreateContents(true);
                }
            }
        }

        public sealed override ControlCollection Controls {
            get {
                
                
                return base.Controls;
            }
        }

        [
        Browsable(false),
        ]
        public Control ContentTemplateContainer {
            get {
                if (_contentTemplateContainer == null) {
                    _contentTemplateContainer = CreateContentTemplateContainer();
                    AddContentTemplateContainer();
                }
                return _contentTemplateContainer;
            }
        }

        [
        Browsable(false),
        ]
        public bool IsInPartialRendering {
            get {
                return _asyncPostBackMode;
            }
        }

        private IPage IPage {
            get {
                if (_page != null) {
                    return _page;
                }
                else {
                    Page page = Page;
                    if (page == null) {
                        throw new InvalidOperationException(AtlasWeb.Common_PageCannotBeNull);
                    }
                    return new PageWrapper(page);
                }
            }
        }

        protected internal virtual bool RequiresUpdate {
            get {
                if (_explicitUpdate || (UpdateMode == UpdatePanelUpdateMode.Always)) {
                    return true;
                }

                if ((_triggers == null) || (_triggers.Count == 0)) {
                    return false;
                }
                return _triggers.HasTriggered();
            }
        }

        [
        ResourceDescription("UpdatePanel_RenderMode"),
        Category("Layout"),
        DefaultValue(UpdatePanelRenderMode.Block),
        ]
        public UpdatePanelRenderMode RenderMode {
            get {
                return _renderMode;
            }
            set {
                if (value < UpdatePanelRenderMode.Block || value > UpdatePanelRenderMode.Inline) {
                    throw new ArgumentOutOfRangeException("value");
                }
                _renderMode = value;
            }
        }

        internal IScriptManagerInternal ScriptManager {
            get {
                if (_scriptManager == null) {
                    Page page = Page;
                    if (page == null) {
                        throw new InvalidOperationException(AtlasWeb.Common_PageCannotBeNull);
                    }
                    _scriptManager = UI.ScriptManager.GetCurrent(page);
                    if (_scriptManager == null) {
                        throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.Common_ScriptManagerRequired, ID));
                    }
                }
                return _scriptManager;
            }
        }

        [
        Category("Behavior"),
        DefaultValue(null),
        Editor("System.Web.UI.Design.UpdatePanelTriggerCollectionEditor, " +
            AssemblyRef.SystemWebExtensionsDesign, typeof(UITypeEditor)),
        ResourceDescription("UpdatePanel_Triggers"),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public UpdatePanelTriggerCollection Triggers {
            get {
                if (_triggers == null) {
                    
                    
                    
                    
                    
                    _triggers = new UpdatePanelTriggerCollection(this);
                }
                return _triggers;
            }
        }

        [
        ResourceDescription("UpdatePanel_UpdateMode"),
        Category("Behavior"),
        DefaultValue(UpdatePanelUpdateMode.Always),
        ]
        public UpdatePanelUpdateMode UpdateMode {
            get {
                return _updateMode;
            }
            set {
                if (value < UpdatePanelUpdateMode.Always || value > UpdatePanelUpdateMode.Conditional) {
                    throw new ArgumentOutOfRangeException("value");
                }
                _updateMode = value;
            }
        }

        private SingleChildControlCollection ChildControls {
            get {
                SingleChildControlCollection singleChildCollection = Controls as SingleChildControlCollection;
                Debug.Assert(singleChildCollection != null, "The Controls property did not return the expected control collection instance.");
                return singleChildCollection;
            }
        }

        private void AddContentTemplateContainer() {
            
            
            ChildControls.AddSingleChild(_contentTemplateContainer);
        }

        private void CreateContents(bool recreate) {
            if (recreate) {
                
                ContentTemplateContainer.Controls.Clear();
                _contentTemplateContainer = null;
                ChildControls.ClearInternal();
            }

            
            
            
            
            if (_contentTemplateContainer == null) {
                
                
                _contentTemplateContainer = CreateContentTemplateContainer();


                
                
                
                
                if (_contentTemplate != null) {
                    _contentTemplate.InstantiateIn(_contentTemplateContainer);
                }

                AddContentTemplateContainer();
            }
            else {
                if (ContentTemplate != null) {
                    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_CannotHaveTemplateAfterContainerCreated, ID));
                }
            }
        }

        protected virtual Control CreateContentTemplateContainer() {
            return new Control();
        }

        protected sealed override ControlCollection CreateControlCollection() {
            
            
            return new SingleChildControlCollection(this);
        }

        protected internal virtual void Initialize() {
            if (_triggers != null) {
                if (ScriptManager.SupportsPartialRendering) {
                    
                    
                    _triggers.Initialize();
                }
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnInit(EventArgs e) {
            base.OnInit(e);

            RegisterPanel();

            CreateContents(DesignMode);
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnLoad(EventArgs e) {
            base.OnLoad(e);

            if (!DesignMode) {
                if (!ScriptManager.IsInAsyncPostBack) {
                    
                    

                    
                    
                    
                    
                    Initialize();
                }
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnPreRender(EventArgs e) {
            base.OnPreRender(e);

            if (!ChildrenAsTriggers && UpdateMode == UpdatePanelUpdateMode.Always) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_ChildrenTriggersAndUpdateAlways, ID));
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnUnload(EventArgs e) {
            if (!DesignMode && _panelRegistered) {
                ScriptManager.UnregisterUpdatePanel(this);
            }

            base.OnUnload(e);
        }

        private void RegisterPanel() {
            
            if (!DesignMode && !_panelRegistered) {
                
                
                
                Control parent = Parent;
                while (parent != null) {
                    UpdatePanel parentUpdatePanel = parent as UpdatePanel;
                    if (parentUpdatePanel != null) {
                        parentUpdatePanel.RegisterPanel();
                        break;
                    }

                    parent = parent.Parent;
                }

                
                ScriptManager.RegisterUpdatePanel(this);
                _panelRegistered = true;
            }
        }

        protected override void Render(HtmlTextWriter writer) {
            IPage.VerifyRenderingInServerForm(this);

            base.Render(writer);
        }

        protected override void RenderChildren(HtmlTextWriter writer) {
            if (_asyncPostBackMode) {
                Debug.Assert(!DesignMode, "Shouldn't be in DesignMode");
                
                
                if (_rendered) {
                    return;
                }

                HtmlTextWriter childWriter = new HtmlTextWriter(new StringWriter(CultureInfo.CurrentCulture));
                base.RenderChildren(childWriter);

                PageRequestManager.EncodeString(writer, UpdatePanelToken, ClientID, childWriter.InnerWriter.ToString());
            }
            else {
                Debug.Assert(!_rendered);

                writer.AddAttribute(HtmlTextWriterAttribute.Id, ClientID);
                if (RenderMode == UpdatePanelRenderMode.Block) {
                    writer.RenderBeginTag(HtmlTextWriterTag.Div);
                }
                else {
                    writer.RenderBeginTag(HtmlTextWriterTag.Span);
                }
                base.RenderChildren(writer);
                writer.RenderEndTag();
            }

            _rendered = true;
        }

        internal void SetAsyncPostBackMode(bool asyncPostBackMode) {
            if (_asyncPostBackModeInitialized) {
                throw new InvalidOperationException(AtlasWeb.UpdatePanel_SetPartialRenderingModeCalledOnce);
            }

            _asyncPostBackMode = asyncPostBackMode;
            _asyncPostBackModeInitialized = true;
        }

        public void Update() {
            if (UpdateMode == UpdatePanelUpdateMode.Always) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_UpdateConditional, ID));
            }

            if (_asyncPostBackModeInitialized) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_UpdateTooLate, ID));
            }

            _explicitUpdate = true;
        }

        private sealed class SingleChildControlCollection : ControlCollection {
            private bool _allowClear;

            public SingleChildControlCollection(Control owner)
                : base(owner) {
            }

            internal void AddSingleChild(Control child) {
                Debug.Assert(Count == 0, "The collection must be empty if this is called");
                base.Add(child);
            }

            public override void Add(Control child) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_CannotModifyControlCollection, Owner.ID));
            }

            public override void AddAt(int index, Control child) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_CannotModifyControlCollection, Owner.ID));
            }

            public override void Clear() {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_CannotModifyControlCollection, Owner.ID));
            }

            internal void ClearInternal() {
                try {
                    _allowClear = true;
                    base.Clear();
                }
                finally {
                    _allowClear = false;
                }
            }

            public override void Remove(Control value) {
                if (!_allowClear) {
                    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_CannotModifyControlCollection, Owner.ID));
                }
                base.Remove(value);
            }

            public override void RemoveAt(int index) {
                if (!_allowClear) {
                    throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.UpdatePanel_CannotModifyControlCollection, Owner.ID));
                }
                base.RemoveAt(index);
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
