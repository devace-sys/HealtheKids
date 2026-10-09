
namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.Collections.Specialized;
    using System.Diagnostics;
    using System.Globalization;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Web.UI;
    using System.Web.Resources;
    using System.Web.Script.Serialization;

    internal sealed class ScriptRegistrationManager {
        private static Regex ScriptTagRegex = new Regex(
            @"<script" +
            @"(" +
                @"\s+(?<attrname>\w[-\w:]*)" +          
                @"(" +
                    @"\s*=\s*""(?<attrval>[^""]*)""|" + 
                    @"\s*=\s*'(?<attrval>[^']*)'" +     
                @")" +
            @")*" +
            @"\s*(?<empty>/)?>",
            RegexOptions.Singleline | RegexOptions.Multiline | RegexOptions.IgnoreCase | RegexOptions.Compiled);

        private ScriptManager _scriptManager;
        private List<ScriptDisposeEntry> _scriptDisposes;
        private Dictionary<Control, List<ScriptArrayEntry>> _scriptArrays;
        private Dictionary<Control, List<ScriptBlockEntry>> _scriptBlocks;
        private Dictionary<Control, List<ScriptHiddenFieldEntry>> _scriptHiddenFields;
        private Dictionary<Control, List<ScriptExpandoEntry>> _scriptExpandos;
        private Dictionary<Control, List<ScriptBlockEntry>> _scriptStartupBlocks;
        private Dictionary<Control, List<ScriptSubmitStatementEntry>> _scriptSubmitStatements;

        public ScriptRegistrationManager(ScriptManager scriptManager) {
            _scriptManager = scriptManager;
        }


        private Dictionary<Control, List<ScriptArrayEntry>> ScriptArrays {
            get {
                if (_scriptArrays == null) {
                    _scriptArrays = new Dictionary<Control, List<ScriptArrayEntry>>();
                }
                return _scriptArrays;
            }
        }

        private Dictionary<Control, List<ScriptBlockEntry>> ScriptBlocks {
            get {
                if (_scriptBlocks == null) {
                    _scriptBlocks = new Dictionary<Control, List<ScriptBlockEntry>>();
                }
                return _scriptBlocks;
            }
        }

        private List<ScriptDisposeEntry> ScriptDisposes {
            get {
                if (_scriptDisposes == null) {
                    _scriptDisposes = new List<ScriptDisposeEntry>();
                }
                return _scriptDisposes;
            }
        }

        private Dictionary<Control, List<ScriptExpandoEntry>> ScriptExpandos {
            get {
                if (_scriptExpandos == null) {
                    _scriptExpandos = new Dictionary<Control, List<ScriptExpandoEntry>>();
                }
                return _scriptExpandos;
            }
        }

        private Dictionary<Control, List<ScriptHiddenFieldEntry>> ScriptHiddenFields {
            get {
                if (_scriptHiddenFields == null) {
                    _scriptHiddenFields = new Dictionary<Control, List<ScriptHiddenFieldEntry>>();
                }
                return _scriptHiddenFields;
            }
        }

        private Dictionary<Control, List<ScriptBlockEntry>> ScriptStartupBlocks {
            get {
                if (_scriptStartupBlocks == null) {
                    _scriptStartupBlocks = new Dictionary<Control, List<ScriptBlockEntry>>();
                }
                return _scriptStartupBlocks;
            }
        }

        private Dictionary<Control, List<ScriptSubmitStatementEntry>> ScriptSubmitStatements {
            get {
                if (_scriptSubmitStatements == null) {
                    _scriptSubmitStatements = new Dictionary<Control, List<ScriptSubmitStatementEntry>>();
                }
                return _scriptSubmitStatements;
            }
        }

        private static void CheckScriptTagTweenSpace(ScriptBlockEntry entry, string text, int start, int length) {
            
            string tweenSpace = text.Substring(start, length);
            if (tweenSpace.Trim().Length != 0) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptRegistrationManager_InvalidChars, entry.Type.FullName, entry.Key, tweenSpace));
            }
        }

        private bool IsControlRegistrationActive(Control parent, Control child, bool pageAlwaysActive) {
            if (pageAlwaysActive) {
                Page childAsPage = child as Page;
                if (childAsPage == _scriptManager.Page) {
                    return true;
                }
            }

            if (parent != null) {
                while (child != null) {
                    if (child == parent) {
                        return true;
                    }
                    child = child.Parent;
                }
            }
            return false;
        }

        public static void RegisterArrayDeclaration(Control control, string arrayName, string arrayValue) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            control.Page.ClientScript.RegisterArrayDeclaration(arrayName, arrayValue);

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm != null && sm.IsInAsyncPostBack) {
                sm.ScriptRegistration.RegisterArrayDeclarationInternal(control, arrayName, arrayValue);
            }
        }

        private void RegisterArrayDeclarationInternal(Control control, string arrayName, string arrayValue) {
            ScriptArrayEntry entry = new ScriptArrayEntry(arrayName, arrayValue);
            Debug.Assert(control != null, "control should not be null");
            List<ScriptArrayEntry> registrationsForControl;
            if (!ScriptArrays.TryGetValue(control, out registrationsForControl)) {
                registrationsForControl = new List<ScriptArrayEntry>();
                ScriptArrays[control] = registrationsForControl;
            }
            registrationsForControl.Add(entry);
        }

        public static void RegisterClientScriptBlock(Control control, Type type, string key, string script, bool addScriptTags) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            control.Page.ClientScript.RegisterClientScriptBlock(type, key, script, addScriptTags);

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm != null && sm.IsInAsyncPostBack) {
                sm.ScriptRegistration.RegisterClientScriptBlockInternal(control, type, key, script, addScriptTags);
            }
        }

        private void RegisterClientScriptBlockInternal(Control control, Type type, string key, string script, bool addScriptTags) {
            ScriptBlockEntry entry = new ScriptBlockEntry(type, key, script, addScriptTags);
            Debug.Assert(control != null, "control should not be null");
            List<ScriptBlockEntry> registrationsForControl;
            if (!ScriptBlocks.TryGetValue(control, out registrationsForControl)) {
                registrationsForControl = new List<ScriptBlockEntry>();
                ScriptBlocks[control] = registrationsForControl;
            }
            registrationsForControl.Add(entry);
        }

        public static void RegisterClientScriptInclude(Control control, Type type, string key, string url) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            control.Page.ClientScript.RegisterClientScriptInclude(type, key, url);

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm != null && sm.IsInAsyncPostBack) {
                sm.ScriptRegistration.RegisterScriptIncludeInternal(control, type, key, url);
            }
        }

        public static void RegisterClientScriptResource(Control control, Type type, string resourceName) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm == null) {
                control.Page.ClientScript.RegisterClientScriptResource(type, resourceName);
            }
            else {
                string resourceUrl = sm.GetScriptResourceUrl(resourceName, type.Assembly);
                control.Page.ClientScript.RegisterClientScriptInclude(type, resourceName, resourceUrl);
                sm.ScriptRegistration.RegisterScriptIncludeInternal(control, type, resourceName, resourceUrl);
            }
        }

        internal void RegisterDispose(Control control, string disposeScript) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }
            if (disposeScript == null) {
                throw new ArgumentNullException("disposeScript");
            }

            
            Control parent = control.Parent;
            UpdatePanel parentUpdatePanel = null;
            while (parent != null) {
                parentUpdatePanel = parent as UpdatePanel;
                if (parentUpdatePanel != null) {
                    break;
                }
                parent = parent.Parent;
            }
            if (parentUpdatePanel != null) {
                if (_scriptManager.IsInAsyncPostBack) {
                    
                    
                    
                    ScriptDisposes.Add(new ScriptDisposeEntry(disposeScript, parentUpdatePanel));
                }
                else {
                    
                    
                    
                    
                    JavaScriptSerializer serializer = new JavaScriptSerializer();
                    
                    StringBuilder sb = new StringBuilder(256);
                    sb.Append("Sys.WebForms.PageRequestManager.getInstance()._registerDisposeScript(");
                    serializer.Serialize(parentUpdatePanel.ClientID, sb);
                    sb.Append(", ");
                    serializer.Serialize(disposeScript, sb);
                    sb.AppendLine(");");
                    _scriptManager.RegisterStartupScriptInternal(control, typeof(ScriptRegistrationManager), _scriptManager.CreateUniqueScriptKey(), sb.ToString(), true);
                }
            }
        }

        public static void RegisterExpandoAttribute(Control control, string controlId, string attributeName, string attributeValue, bool encode) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            control.Page.ClientScript.RegisterExpandoAttribute(controlId, attributeName, attributeValue, encode);

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm != null && sm.IsInAsyncPostBack) {
                sm.ScriptRegistration.RegisterExpandoAttributeInternal(control, controlId, attributeName, attributeValue, encode);
            }
        }

        private void RegisterExpandoAttributeInternal(Control control, string controlId, string attributeName, string attributeValue, bool encode) {
            if (encode) {
                attributeValue = JavaScriptString.QuoteString(attributeValue);
            }
            ScriptExpandoEntry entry = new ScriptExpandoEntry(controlId, attributeName, attributeValue);
            Debug.Assert(control != null, "control should not be null");
            List<ScriptExpandoEntry> registrationsForControl;
            if (!ScriptExpandos.TryGetValue(control, out registrationsForControl)) {
                registrationsForControl = new List<ScriptExpandoEntry>();
                ScriptExpandos[control] = registrationsForControl;
            }
            registrationsForControl.Add(entry);
        }

        public static void RegisterHiddenField(Control control, string hiddenFieldName, string hiddenFieldInitialValue) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            control.Page.ClientScript.RegisterHiddenField(hiddenFieldName, hiddenFieldInitialValue);

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm != null && sm.IsInAsyncPostBack) {
                sm.ScriptRegistration.RegisterHiddenFieldInternal(control, hiddenFieldName, hiddenFieldInitialValue);
            }
        }

        private void RegisterHiddenFieldInternal(Control control, string hiddenFieldName, string hiddenFieldInitialValue) {
            ScriptHiddenFieldEntry entry = new ScriptHiddenFieldEntry(hiddenFieldName, hiddenFieldInitialValue);
            Debug.Assert(control != null, "control should not be null");
            List<ScriptHiddenFieldEntry> registrationsForControl;
            if (!ScriptHiddenFields.TryGetValue(control, out registrationsForControl)) {
                registrationsForControl = new List<ScriptHiddenFieldEntry>();
                ScriptHiddenFields[control] = registrationsForControl;
            }
            registrationsForControl.Add(entry);
        }

        public static void RegisterOnSubmitStatement(Control control, Type type, string key, string script) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            control.Page.ClientScript.RegisterOnSubmitStatement(type, key, script);

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm != null && sm.IsInAsyncPostBack) {
                sm.ScriptRegistration.RegisterOnSubmitStatementInternal(control, type, key, script);
            }
        }

        private void RegisterOnSubmitStatementInternal(Control control, Type type, string key, string script) {
            ScriptSubmitStatementEntry entry = new ScriptSubmitStatementEntry(type, key, script);
            Debug.Assert(control != null, "control should not be null");
            List<ScriptSubmitStatementEntry> registrationsForControl;
            if (!ScriptSubmitStatements.TryGetValue(control, out registrationsForControl)) {
                registrationsForControl = new List<ScriptSubmitStatementEntry>();
                ScriptSubmitStatements[control] = registrationsForControl;
            }
            registrationsForControl.Add(entry);
        }

        private void RegisterScriptIncludeInternal(Control control, Type type, string key, string includePath) {
            ScriptBlockEntry entry = new ScriptBlockEntry(type, key, includePath);
            Debug.Assert(control != null, "control should not be null");
            List<ScriptBlockEntry> registrationsForControl;
            if (!ScriptBlocks.TryGetValue(control, out registrationsForControl)) {
                registrationsForControl = new List<ScriptBlockEntry>();
                ScriptBlocks[control] = registrationsForControl;
            }
            registrationsForControl.Add(entry);
        }

        public static void RegisterStartupScript(Control control, Type type, string key, string script, bool addScriptTags) {
            if (control == null) {
                throw new ArgumentNullException("control");
            }
            if (control.Page == null) {
                throw new ArgumentException(AtlasWeb.ScriptRegistrationManager_ControlNotOnPage, "control");
            }

            control.Page.ClientScript.RegisterStartupScript(type, key, script, addScriptTags);

            ScriptManager sm = ScriptManager.GetCurrent(control.Page);
            if (sm != null && sm.IsInAsyncPostBack) {
                sm.ScriptRegistration.RegisterStartupScriptInternal(control, type, key, script, addScriptTags);
            }
        }

        private void RegisterStartupScriptInternal(Control control, Type type, string key, string script, bool addScriptTags) {
            ScriptBlockEntry entry = new ScriptBlockEntry(type, key, script, addScriptTags);
            Debug.Assert(control != null, "control should not be null");
            List<ScriptBlockEntry> registrationsForControl;
            if (!ScriptStartupBlocks.TryGetValue(control, out registrationsForControl)) {
                registrationsForControl = new List<ScriptBlockEntry>();
                ScriptStartupBlocks[control] = registrationsForControl;
            }
            registrationsForControl.Add(entry);
        }


        public void RenderActiveArrayDeclarations(List<UpdatePanel> updatePanels, HtmlTextWriter writer) {
            Debug.Assert(writer != null, "Should always have a writer");
            List<ScriptArrayEntry> entriesToRender = new List<ScriptArrayEntry>();

            
            
            foreach (KeyValuePair<Control, List<ScriptArrayEntry>> entry in ScriptArrays) {
                if (updatePanels != null) {
                    
                    foreach (UpdatePanel panel in updatePanels) {
                        if (IsControlRegistrationActive(panel, entry.Key, true)) {
                            
                            
                            foreach (ScriptArrayEntry entryToRender in entry.Value) {
                                if (!entriesToRender.Contains(entryToRender)) {
                                    entriesToRender.Add(entryToRender);
                                }
                            }
                        }
                    }
                }
                else {
                    
                    if (IsControlRegistrationActive(null, entry.Key, true)) {
                        
                        
                        foreach (ScriptArrayEntry entryToRender in entry.Value) {
                            if (!entriesToRender.Contains(entryToRender)) {
                                entriesToRender.Add(entryToRender);
                            }
                        }
                    }
                }
            }

            foreach (ScriptArrayEntry activeRegistration in entriesToRender) {
                PageRequestManager.EncodeString(writer, PageRequestManager.ArrayDeclarationToken, activeRegistration.ArrayName, activeRegistration.ArrayValue);
            }
        }

        public void RenderActiveExpandos(List<UpdatePanel> updatePanels, HtmlTextWriter writer) {
            Debug.Assert(writer != null, "Should always have a writer");
            if (updatePanels == null) {
                return;
            }
            List<ScriptExpandoEntry> entriesToRender = new List<ScriptExpandoEntry>();

            
            
            foreach (KeyValuePair<Control, List<ScriptExpandoEntry>> entry in ScriptExpandos) {
                foreach (UpdatePanel panel in updatePanels) {
                    if (IsControlRegistrationActive(panel, entry.Key, false)) {
                        
                        
                        foreach (ScriptExpandoEntry entryToRender in entry.Value) {
                            if (!entriesToRender.Contains(entryToRender)) {
                                entriesToRender.Add(entryToRender);
                            }
                        }
                    }
                }
            }

            foreach (ScriptExpandoEntry activeRegistration in entriesToRender) {
                string propertyReference = "document.getElementById('" + activeRegistration.ControlId + "')['" + activeRegistration.AttributeName + "']";
                string value = "null";
                if (activeRegistration.AttributeValue != null) {
                    value = "\"" + activeRegistration.AttributeValue + "\"";
                }
                PageRequestManager.EncodeString(writer, PageRequestManager.ExpandoToken, propertyReference, value);
            }
        }

        public void RenderActiveHiddenFields(List<UpdatePanel> updatePanels, HtmlTextWriter writer) {
            Debug.Assert(writer != null, "Should always have a writer");
            List<ScriptHiddenFieldEntry> entriesToRender = new List<ScriptHiddenFieldEntry>();

            
            
            foreach (KeyValuePair<Control, List<ScriptHiddenFieldEntry>> entry in ScriptHiddenFields) {
                if (updatePanels != null) {
                    
                    foreach (UpdatePanel panel in updatePanels) {
                        if (IsControlRegistrationActive(panel, entry.Key, true)) {
                            
                            
                            foreach (ScriptHiddenFieldEntry entryToRender in entry.Value) {
                                if (!entriesToRender.Contains(entryToRender)) {
                                    entriesToRender.Add(entryToRender);
                                }
                            }
                        }
                    }
                }
                else {
                    
                    if (IsControlRegistrationActive(null, entry.Key, true)) {
                        
                        
                        foreach (ScriptHiddenFieldEntry entryToRender in entry.Value) {
                            if (!entriesToRender.Contains(entryToRender)) {
                                entriesToRender.Add(entryToRender);
                            }
                        }
                    }
                }
            }

            foreach (ScriptHiddenFieldEntry activeRegistration in entriesToRender) {
                PageRequestManager.EncodeString(writer, PageRequestManager.HiddenFieldToken, activeRegistration.HiddenFieldName, activeRegistration.HiddenFieldInitialValue);
            }
        }

        private void RenderActiveScriptBlocks(List<UpdatePanel> updatePanels, HtmlTextWriter writer, Dictionary<Control, List<ScriptBlockEntry>> scriptRegistrations) {
            List<ScriptBlockEntry> entriesToRender = new List<ScriptBlockEntry>();

            
            
            foreach (KeyValuePair<Control, List<ScriptBlockEntry>> entry in scriptRegistrations) {
                if (updatePanels != null) {
                    
                    foreach (UpdatePanel panel in updatePanels) {
                        if (IsControlRegistrationActive(panel, entry.Key, true)) {
                            
                            
                            foreach (ScriptBlockEntry entryToRender in entry.Value) {
                                if (!entriesToRender.Contains(entryToRender)) {
                                    entriesToRender.Add(entryToRender);
                                }
                            }
                        }
                    }
                }
                else {
                    
                    if (IsControlRegistrationActive(null, entry.Key, true)) {
                        
                        
                        foreach (ScriptBlockEntry entryToRender in entry.Value) {
                            if (!entriesToRender.Contains(entryToRender)) {
                                entriesToRender.Add(entryToRender);
                            }
                        }
                    }
                }
            }

            foreach (ScriptBlockEntry activeRegistration in entriesToRender) {
                if (String.IsNullOrEmpty(activeRegistration.IncludePath)) {
                    if (activeRegistration.AddScriptTags) {
                        PageRequestManager.EncodeString(writer, PageRequestManager.ScriptBlockToken, "ScriptContentNoTags", activeRegistration.Script);
                    }
                    else {
                        WriteScriptWithTags(writer, activeRegistration);
                    }
                }
                else {
                    PageRequestManager.EncodeString(writer, PageRequestManager.ScriptBlockToken, "ScriptPath", activeRegistration.IncludePath);
                }
            }
        }

        public void RenderActiveScriptDisposes(List<UpdatePanel> updatePanels, HtmlTextWriter writer) {
            Debug.Assert(writer != null, "Should always have a writer");
            if (updatePanels == null) {
                return;
            }
            List<ScriptDisposeEntry> entriesToRender = new List<ScriptDisposeEntry>();

            
            
            foreach (ScriptDisposeEntry entry in ScriptDisposes) {
                foreach (UpdatePanel panel in updatePanels) {
                    if (IsControlRegistrationActive(panel, entry.ParentUpdatePanel, false)) {
                        
                        entriesToRender.Add(entry);
                    }
                }
            }

            foreach (ScriptDisposeEntry activeRegistration in entriesToRender) {
                PageRequestManager.EncodeString(
                    writer,
                    PageRequestManager.ScriptDisposeToken,
                    activeRegistration.ParentUpdatePanel.ClientID,
                    activeRegistration.DisposeScript);
            }
        }

        public void RenderActiveScripts(List<UpdatePanel> updatePanels, HtmlTextWriter writer) {
            Debug.Assert(writer != null, "Should always have a writer");
            
            RenderActiveScriptBlocks(updatePanels, writer, ScriptBlocks);

            
            RenderActiveScriptBlocks(updatePanels, writer, ScriptStartupBlocks);
        }

        public void RenderActiveSubmitStatements(List<UpdatePanel> updatePanels, HtmlTextWriter writer) {
            Debug.Assert(writer != null, "Should always have a writer");
            List<ScriptSubmitStatementEntry> entriesToRender = new List<ScriptSubmitStatementEntry>();

            
            
            foreach (KeyValuePair<Control, List<ScriptSubmitStatementEntry>> entry in ScriptSubmitStatements) {
                if (updatePanels != null) {
                    
                    foreach (UpdatePanel panel in updatePanels) {
                        if (IsControlRegistrationActive(panel, entry.Key, true)) {
                            
                            
                            foreach (ScriptSubmitStatementEntry entryToRender in entry.Value) {
                                if (!entriesToRender.Contains(entryToRender)) {
                                    entriesToRender.Add(entryToRender);
                                }
                            }
                        }
                    }
                }
                else {
                    
                    if (IsControlRegistrationActive(null, entry.Key, true)) {
                        
                        
                        foreach (ScriptSubmitStatementEntry entryToRender in entry.Value) {
                            if (!entriesToRender.Contains(entryToRender)) {
                                entriesToRender.Add(entryToRender);
                            }
                        }
                    }
                }
            }

            foreach (ScriptSubmitStatementEntry activeRegistration in entriesToRender) {
                PageRequestManager.EncodeString(writer, PageRequestManager.OnSubmitToken, null, activeRegistration.Script);
            }
        }

        private static void WriteScriptWithTags(HtmlTextWriter writer, ScriptBlockEntry activeRegistration) {
            
            
            
            string scriptContent = activeRegistration.Script;

            int lastIndex = 0;
            for (Match match = ScriptTagRegex.Match(scriptContent, lastIndex); match.Success; match = ScriptTagRegex.Match(scriptContent, lastIndex)) {
                CheckScriptTagTweenSpace(activeRegistration, scriptContent, lastIndex, match.Index - lastIndex);

                OrderedDictionary attrs = new OrderedDictionary();

                if (match.Groups["empty"].Captures.Count > 0) {
                    

                    
                    lastIndex = match.Index + match.Length;
                }
                else {
                    

                    
                    int indexOfEndOfScriptBeginTag = match.Index + match.Length;
                    int indexOfScriptEndTag = scriptContent.IndexOf("</script>", indexOfEndOfScriptBeginTag, StringComparison.OrdinalIgnoreCase);
                    if (indexOfScriptEndTag == -1) {
                        throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptRegistrationManager_NoCloseTag, activeRegistration.Type.FullName, activeRegistration.Key));
                    }
                    string scriptBlockContents = scriptContent.Substring(indexOfEndOfScriptBeginTag, (indexOfScriptEndTag - indexOfEndOfScriptBeginTag));

                    
                    attrs.Add("text", scriptBlockContents);

                    lastIndex = indexOfScriptEndTag + 9;
                }

                
                CaptureCollection attrnames = match.Groups["attrname"].Captures;
                CaptureCollection attrvalues = match.Groups["attrval"].Captures;
                for (int i = 0; i < attrnames.Count; i++) {
                    string attribName = attrnames[i].ToString();
                    string attribValue = attrvalues[i].ToString();
                    attrs.Add(attribName, attribValue);
                }

                
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                string attrText = serializer.Serialize(attrs);
                PageRequestManager.EncodeString(writer, PageRequestManager.ScriptBlockToken, "ScriptContentWithTags", attrText);
            }

            CheckScriptTagTweenSpace(activeRegistration, scriptContent, lastIndex, scriptContent.Length - lastIndex);

            if (lastIndex == 0) {
                throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.ScriptRegistrationManager_NoTags, activeRegistration.Type.FullName, activeRegistration.Key));
            }
        }


        private sealed class ScriptArrayEntry {
            private string _arrayName;
            private string _arrayValue;

            public ScriptArrayEntry(string arrayName, string arrayValue) {
                _arrayName = arrayName;
                _arrayValue = arrayValue;
            }

            public string ArrayName {
                get {
                    return _arrayName;
                }
            }

            public string ArrayValue {
                get {
                    return _arrayValue;
                }
            }
        }

        private sealed class ScriptBlockEntry {
            private string _key;
            private string _script;
            private Type _type;
            private bool _addScriptTags;
            private string _includePath;

            public ScriptBlockEntry(Type type, string key, string includePath) {
                _type = type;
                _key = key;
                _includePath = includePath;
            }

            public ScriptBlockEntry(Type type, string key, string script, bool addScriptTags) {
                _type = type;
                _key = key;
                _script = script;
                _addScriptTags = addScriptTags;
            }

            public bool AddScriptTags {
                get {
                    return _addScriptTags;
                }
            }

            public string IncludePath {
                get {
                    return _includePath;
                }
            }

            public string Key {
                get {
                    return _key;
                }
            }

            public string Script {
                get {
                    return _script;
                }
            }

            public Type Type {
                get {
                    return _type;
                }
            }

            public override bool Equals(object obj) {
                ScriptBlockEntry other = obj as ScriptBlockEntry;
                if (other == null) {
                    return false;
                }
                return
                    String.Equals(Key, other.Key, StringComparison.Ordinal) &&
                    (Type == other.Type);
            }

            public override int GetHashCode() {
                
                return
                    Key.GetHashCode() ^
                    Type.GetHashCode();
            }
        }

        private sealed class ScriptExpandoEntry {
            private string _attributeName;
            private string _attributeValue;
            private string _controlId;

            public ScriptExpandoEntry(string controlId, string attributeName, string attributeValue) {
                _controlId = controlId;
                _attributeName = attributeName;
                _attributeValue = attributeValue;
            }

            public string AttributeName {
                get {
                    return _attributeName;
                }
            }

            public string AttributeValue {
                get {
                    return _attributeValue;
                }
            }

            public string ControlId {
                get {
                    return _controlId;
                }
            }
        }

        private sealed class ScriptSubmitStatementEntry {
            private string _key;
            private string _script;
            private Type _type;

            public ScriptSubmitStatementEntry(Type type, string key, string script) {
                _type = type;
                _key = key;
                _script = script;
            }

            public string Key {
                get {
                    return _key;
                }
            }

            public string Script {
                get {
                    return _script;
                }
            }

            public Type Type {
                get {
                    return _type;
                }
            }

            public override bool Equals(object obj) {
                ScriptSubmitStatementEntry other = obj as ScriptSubmitStatementEntry;
                if (other == null) {
                    return false;
                }
                return
                    String.Equals(Key, other.Key, StringComparison.Ordinal) &&
                    (Type == other.Type);
            }

            public override int GetHashCode() {
                
                return
                    Key.GetHashCode() ^
                    Type.GetHashCode();
            }
        }

        private sealed class ScriptHiddenFieldEntry {
            private string _hiddenFieldName;
            private string _hiddenFieldInitialValue;

            public ScriptHiddenFieldEntry(string hiddenFieldName, string hiddenFieldInitialValue) {
                _hiddenFieldName = hiddenFieldName;
                _hiddenFieldInitialValue = hiddenFieldInitialValue;
            }

            public string HiddenFieldInitialValue {
                get {
                    return _hiddenFieldInitialValue;
                }
            }

            public string HiddenFieldName {
                get {
                    return _hiddenFieldName;
                }
            }

            public override bool Equals(object obj) {
                ScriptHiddenFieldEntry other = obj as ScriptHiddenFieldEntry;
                if (other == null) {
                    return false;
                }
                return String.Equals(HiddenFieldName, other.HiddenFieldName, StringComparison.Ordinal);
            }

            public override int GetHashCode() {
                
                return HiddenFieldName.GetHashCode();
            }
        }

        private sealed class ScriptDisposeEntry {
            private UpdatePanel _parentUpdatePanel;
            private string _disposeScript;

            public ScriptDisposeEntry(string disposeScript, UpdatePanel parentUpdatePanel) {
                _disposeScript = disposeScript;
                _parentUpdatePanel = parentUpdatePanel;
            }

            public string DisposeScript {
                get {
                    return _disposeScript;
                }
            }

            public UpdatePanel ParentUpdatePanel {
                get {
                    return _parentUpdatePanel;
                }
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
