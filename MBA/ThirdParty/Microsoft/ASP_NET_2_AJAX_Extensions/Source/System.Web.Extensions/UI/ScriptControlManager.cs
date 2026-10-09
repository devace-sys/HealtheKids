namespace System.Web.UI {
    using System;
    using System.Collections.ObjectModel;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.Text;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Util;

    internal class ScriptControlManager {
        private OrderedDictionary<IExtenderControl, List<Control>> _extenderControls;
        private bool _pagePreRenderRaised;
        private OrderedDictionary<IScriptControl, int> _scriptControls;
        private ScriptManager _scriptManager;
        private bool _scriptReferencesRegistered;

        public ScriptControlManager(ScriptManager scriptManager) {
            _scriptManager = scriptManager;
        }

        private OrderedDictionary<IExtenderControl, List<Control>> ExtenderControls {
            get {
                if (_extenderControls == null) {
                    _extenderControls = new OrderedDictionary<IExtenderControl, List<Control>>();
                }
                return _extenderControls;
            }
        }

        private OrderedDictionary<IScriptControl, int> ScriptControls {
            get {
                if (_scriptControls == null) {
                    _scriptControls = new OrderedDictionary<IScriptControl, int>();
                }
                return _scriptControls;
            }
        }

        public void AddScriptReferences(List<ScriptReference> scriptReferences) {
#if DEBUG
            if (_scriptReferencesRegistered) {
                Debug.Fail("AddScriptReferences should only be called once per request but it was already called during this request.");
            }
#endif
            AddScriptReferencesForScriptControls(scriptReferences);
            AddScriptReferencesForExtenderControls(scriptReferences);

            _scriptReferencesRegistered = true;
        }

        private void AddScriptReferencesForScriptControls(List<ScriptReference> scriptReferences) {
            
            if (_scriptControls != null) {
                foreach (IScriptControl scriptControl in _scriptControls.Keys) {
                    AddScriptReferenceForScriptControl(scriptReferences, scriptControl);
                }
            }
        }

        private static void AddScriptReferenceForScriptControl(List<ScriptReference> scriptReferences,
                                                               IScriptControl scriptControl) {
            IEnumerable<ScriptReference> scriptControlReferences = scriptControl.GetScriptReferences();

            if (scriptControlReferences != null) {
                Control scriptControlAsControl = (Control)scriptControl;
                ClientUrlResolverWrapper urlResolverWrapper = null;
                foreach (ScriptReference scriptControlReference in scriptControlReferences) {
                    if (scriptControlReference != null) {
                        if (urlResolverWrapper == null) {
                            urlResolverWrapper = new ClientUrlResolverWrapper(scriptControlAsControl);
                        }
                        
                        scriptControlReference.ClientUrlResolver = urlResolverWrapper;
                        scriptControlReference.IsStaticReference = false;
                        scriptControlReference.ContainingControl = scriptControlAsControl;

                        
                        scriptReferences.Add(scriptControlReference);
                    }
                }
            }
        }

        private void AddScriptReferencesForExtenderControls(List<ScriptReference> scriptReferences) {
            
            if (_extenderControls != null) {
                foreach (IExtenderControl extenderControl in _extenderControls.Keys) {
                    AddScriptReferenceForExtenderControl(scriptReferences, extenderControl);
                }
            }
        }

        private static void AddScriptReferenceForExtenderControl(List<ScriptReference> scriptReferences, IExtenderControl extenderControl) {
            IEnumerable<ScriptReference> extenderControlReferences = extenderControl.GetScriptReferences();
            if (extenderControlReferences != null) {
                Control extenderControlAsControl = (Control)extenderControl;
                ClientUrlResolverWrapper urlResolverWrapper = null;
                foreach (ScriptReference extenderControlReference in extenderControlReferences) {
                    if (extenderControlReference != null) {
                        if (urlResolverWrapper == null) {
                            urlResolverWrapper = new ClientUrlResolverWrapper(extenderControlAsControl);
                        }
                        
                        extenderControlReference.ClientUrlResolver = urlResolverWrapper;
                        extenderControlReference.IsStaticReference = false;
                        extenderControlReference.ContainingControl = extenderControlAsControl;

                        
                        scriptReferences.Add(extenderControlReference);
                    }
                }
            }
        }

        private bool InControlTree(Control targetControl) {
            for (Control parent = targetControl.Parent; parent != null; parent = parent.Parent) {
                if (parent == _scriptManager.Page) {
                    return true;
                }
            }
            return false;
        }

        public void OnPagePreRender(object sender, EventArgs e) {
            _pagePreRenderRaised = true;
        }

        public void RegisterExtenderControl<TExtenderControl>(TExtenderControl extenderControl, Control targetControl)
            where TExtenderControl : Control, IExtenderControl {

            if (extenderControl == null) {
                throw new ArgumentNullException("extenderControl");
            }
            if (targetControl == null) {
                throw new ArgumentNullException("targetControl");
            }

            VerifyTargetControlType(extenderControl, targetControl);

            if (!_pagePreRenderRaised) {
                throw new InvalidOperationException(AtlasWeb.ScriptControlManager_RegisterExtenderControlTooEarly);
            }
            if (_scriptReferencesRegistered) {
                throw new InvalidOperationException(AtlasWeb.ScriptControlManager_RegisterExtenderControlTooLate);
            }

            
            List<Control> targetControls;
            if (!ExtenderControls.TryGetValue(extenderControl, out targetControls)) {
                targetControls = new List<Control>();
                ExtenderControls[extenderControl] = targetControls;
            }
            targetControls.Add(targetControl);
        }

        public void RegisterScriptControl<TScriptControl>(TScriptControl scriptControl)
            where TScriptControl : Control, IScriptControl {

            if (scriptControl == null) {
                throw new ArgumentNullException("scriptControl");
            }

            if (!_pagePreRenderRaised) {
                throw new InvalidOperationException(AtlasWeb.ScriptControlManager_RegisterScriptControlTooEarly);
            }
            if (_scriptReferencesRegistered) {
                throw new InvalidOperationException(AtlasWeb.ScriptControlManager_RegisterScriptControlTooLate);
            }

            
            int timesRegistered;
            ScriptControls.TryGetValue(scriptControl, out timesRegistered);
            timesRegistered++;
            ScriptControls[scriptControl] = timesRegistered;
        }

        public void RegisterScriptDescriptors(IExtenderControl extenderControl) {
            if (extenderControl == null) {
                throw new ArgumentNullException("extenderControl");
            }

            Control extenderControlAsControl = extenderControl as Control;
            if (extenderControlAsControl == null) {
                throw new ArgumentException(
                    String.Format(CultureInfo.InvariantCulture,
                                  AtlasWeb.Common_ArgumentInvalidType,
                                  typeof(Control).FullName),
                    "extenderControl");
            }

            List<Control> targetControls;
            if (!ExtenderControls.TryGetValue(extenderControl, out targetControls)) {
                throw new ArgumentException(
                    String.Format(CultureInfo.InvariantCulture,
                                  AtlasWeb.ScriptControlManager_ExtenderControlNotRegistered,
                                  extenderControlAsControl.ID),
                    "extenderControl");
            }

            Debug.Assert(targetControls != null && targetControls.Count > 0);

            
            foreach (Control targetControl in targetControls) {
                
                
                if (targetControl.Visible && InControlTree(targetControl)) {
                    IEnumerable<ScriptDescriptor> scriptDescriptors = extenderControl.GetScriptDescriptors(targetControl);
                    RegisterScriptsForScriptDescriptors(scriptDescriptors, extenderControlAsControl);
                }
            }
        }

        public void RegisterScriptDescriptors(IScriptControl scriptControl) {
            if (scriptControl == null) {
                throw new ArgumentNullException("scriptControl");
            }

            Control scriptControlAsControl = scriptControl as Control;
            if (scriptControlAsControl == null) {
                throw new ArgumentException(
                    String.Format(CultureInfo.InvariantCulture,
                                  AtlasWeb.Common_ArgumentInvalidType,
                                  typeof(Control).FullName),
                    "scriptControl");
            }

            
            int timesRegistered;
            if (!ScriptControls.TryGetValue(scriptControl, out timesRegistered)) {
                throw new ArgumentException(
                    String.Format(CultureInfo.InvariantCulture,
                                  AtlasWeb.ScriptControlManager_ScriptControlNotRegistered,
                                  scriptControlAsControl.ID),
                    "scriptControl");
            }

            
            for (int i = 0; i < timesRegistered; i++) {
                IEnumerable<ScriptDescriptor> scriptDescriptors = scriptControl.GetScriptDescriptors();
                RegisterScriptsForScriptDescriptors(scriptDescriptors, scriptControlAsControl);
            }
        }

        private void RegisterScriptsForScriptDescriptors(IEnumerable<ScriptDescriptor> scriptDescriptors,
                                                         Control control) {
            if (scriptDescriptors != null) {
                StringBuilder initBuilder = null;
                foreach (ScriptDescriptor scriptDescriptor in scriptDescriptors) {
                    if (scriptDescriptor != null) {
                        if (initBuilder == null) {
                            initBuilder = new StringBuilder();
                            initBuilder.AppendLine("Sys.Application.add_init(function() {");
                        }

                        initBuilder.Append("    ");
                        initBuilder.AppendLine(scriptDescriptor.GetScript());

                        
                        scriptDescriptor.RegisterDisposeForDescriptor(_scriptManager, control);
                    }
                }

                
                if (initBuilder != null) {
                    initBuilder.AppendLine("});");

                    string initScript = initBuilder.ToString();
                    _scriptManager.RegisterStartupScriptInternal(
                        control, typeof(ScriptManager), initScript, initScript, true);
                }
            }
        }

        private static void VerifyTargetControlType<TExtenderControl>(
            TExtenderControl extenderControl, Control targetControl)
            where TExtenderControl : Control, IExtenderControl {

            Type extenderControlType = extenderControl.GetType();

            
            
            Type[] types = TargetControlTypeCache.GetTargetControlTypes(extenderControlType);

            if (types.Length == 0) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture,
                    AtlasWeb.ScriptControlManager_NoTargetControlTypes,
                    extenderControlType, typeof(TargetControlTypeAttribute)));
            }

            Type targetControlType = targetControl.GetType();
            foreach (Type type in types) {
                if (type.IsAssignableFrom(targetControlType)) {
                    return;
                }
            }

            throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture,
                AtlasWeb.ScriptControlManager_TargetControlTypeInvalid,
                extenderControl.ID, targetControl.ID, extenderControlType, targetControlType));
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
