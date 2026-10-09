namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Drawing;
    using System.Drawing.Design;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Web;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Util;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("Scripts"),
    Designer("System.Web.UI.Design.ScriptManagerProxyDesigner, " + AssemblyRef.SystemWebExtensionsDesign),
    NonVisualControl(),
    ParseChildren(true),
    PersistChildren(false),
    ToolboxBitmap(typeof(EmbeddedResourceFinder), "System.Web.Resources.ScriptManagerProxy.bmp"),
    ]
    public class ScriptManagerProxy : Control, IControl {

        private IScriptManagerInternal _scriptManager;
        private ScriptReferenceCollection _scripts;
        private ServiceReferenceCollection _services;

        private ProfileServiceManager _profileServiceManager;
        private AuthenticationServiceManager _authenticationServiceManager;
#if ORCAS
        private RoleServiceManager _roleServiceManager;
#endif

        public ScriptManagerProxy() {
        }

        internal ScriptManagerProxy(IScriptManagerInternal scriptManager) {
            _scriptManager = scriptManager;
        }

        [
        ResourceDescription("ScriptManager_AuthenticationService"),
        Category("Behavior"),
        DefaultValue(null),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Content),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public AuthenticationServiceManager AuthenticationService {
            get {
                if(_authenticationServiceManager == null) {
                    _authenticationServiceManager = new AuthenticationServiceManager();
                }
                return _authenticationServiceManager;
            }
        }

        internal bool HasProfileServiceManager {
            get {
                return this._profileServiceManager != null;
            }
        }
        internal bool HasAuthenticationServiceManager {
            get {
                return this._authenticationServiceManager != null;
            }
        }

        [
        ResourceDescription("ScriptManager_ProfileService"),
        Category("Behavior"),
        DefaultValue(null),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Content),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public ProfileServiceManager ProfileService {
            get {
                if(_profileServiceManager == null) {
                    _profileServiceManager = new ProfileServiceManager();
                }
                return _profileServiceManager;
            }
        }

#if ORCAS
        [
        ResourceDescription("ScriptManager_RoleService"),
        Category("Behavior"),
        DefaultValue(null),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Content),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public RoleServiceManager RoleService {
            get {
                if(_roleServiceManager == null) {
                    _roleServiceManager = new RoleServiceManager();
                }
                return _roleServiceManager;
            }
        }

        internal bool HasRoleServiceManager {
            get { return this._roleServiceManager != null; }
        }
#endif

        private IScriptManagerInternal ScriptManager {
            get {
                if (_scriptManager == null) {
                    Page page = Page;
                    if (page == null) {
                        throw new InvalidOperationException(AtlasWeb.Common_PageCannotBeNull);
                    }
                    _scriptManager = UI.ScriptManager.GetCurrent(Page);
                    if (_scriptManager == null) {
                        throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.Common_ScriptManagerRequired, ID));
                    }
                }
                return _scriptManager;
            }
        }

        [
        ResourceDescription("ScriptManager_Scripts"),
        Category("Behavior"),
        DefaultValue(null),
        Editor("System.Web.UI.Design.CollectionEditorBase, " +
            AssemblyRef.SystemWebExtensionsDesign, typeof(UITypeEditor)),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public ScriptReferenceCollection Scripts {
            get {
                if (_scripts == null) {
                    _scripts = new ScriptReferenceCollection();
                }
                return _scripts;
            }
        }

        [
        ResourceDescription("ScriptManager_Services"),
        Category("Behavior"),
        DefaultValue(null),
        Editor("System.Web.UI.Design.CollectionEditorBase, " +
            AssemblyRef.SystemWebExtensionsDesign, typeof(UITypeEditor)),
        PersistenceMode(PersistenceMode.InnerProperty),
        MergableProperty(false),
        ]
        public ServiceReferenceCollection Services {
            get {
                if (_services == null) {
                    _services = new ServiceReferenceCollection();
                }
                return _services;
            }
        }

        [
        Browsable(false),
        DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden),
        EditorBrowsable(EditorBrowsableState.Never)
        ]
        public override bool Visible {
            get {
                return base.Visible;
            }
            set {
                throw new NotImplementedException();
            }
        }

        internal void CollectScripts(List<ScriptReference> scripts) {
            
            if (_scripts != null) {
                foreach (ScriptReference scriptReference in _scripts) {
                    scriptReference.ClientUrlResolver = this;
                    scriptReference.ContainingControl = this;
                    scriptReference.IsStaticReference = true;
                    scripts.Add(scriptReference);
                }
            }
        }

        [SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers")]
        protected override void OnInit(EventArgs e) {
            base.OnInit(e);

            if (!DesignMode) {
                ScriptManager.RegisterProxy(this);
            }
        }

        internal void RegisterServices(ScriptManager scriptManager) {
            
            if (_services != null) {
                foreach (ServiceReference serviceReference in _services) {
                    serviceReference.Register(this, Context, scriptManager, scriptManager.IsDebuggingEnabled);
                }
            }
        }

        #region IControl Members
        IHttpContext IControl.Context {
            get {
                return new HttpContextWrapper(Context);
            }
        }

        bool IControl.DesignMode {
            get {
                return DesignMode;
            }
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
