namespace System.Web.UI {
    using System;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Security.Permissions;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Web;
    using System.Web.Resources;
    using System.Web.Script.Serialization;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class ScriptComponentDescriptor : ScriptDescriptor {
        
        
        private string _elementIDInternal;
        private SortedList<string, string> _events;
        private string _id;
        private SortedList<string, Expression> _properties;
        private bool _registerDispose = true;
        private JavaScriptSerializer _serializer;
        private string _type;

        public ScriptComponentDescriptor(string type) {
            if (String.IsNullOrEmpty(type)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "type");
            }
            _type = type;
        }

        
        internal ScriptComponentDescriptor(string type, string elementID)
            : this(type) {
            if (String.IsNullOrEmpty(elementID)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "elementID");
            }
            _elementIDInternal = elementID;
        }

        [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")]
        public virtual string ClientID {
            get {
                return ID;
            }
        }

        internal string ElementIDInternal {
            get {
                return _elementIDInternal;
            }
        }

        private SortedList<string, string> Events {
            get {
                if (_events == null) {
                    _events = new SortedList<string, string>(StringComparer.Ordinal);
                }
                return _events;
            }
        }

        [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")]
        public virtual string ID {
            get {
                return _id ?? String.Empty;
            }
            set {
                _id = value;
            }
        }

        private SortedList<string, Expression> Properties {
            get {
                if (_properties == null) {
                    _properties = new SortedList<string, Expression>(StringComparer.Ordinal);
                }
                return _properties;
            }
        }

        internal bool RegisterDispose {
            get {
                return _registerDispose;
            }
            set {
                _registerDispose = value;
            }
        }

        private JavaScriptSerializer Serializer {
            get {
                if (_serializer == null) {
                    _serializer = new JavaScriptSerializer();
                }
                return _serializer;
            }
        }

        public string Type {
            get {
                return _type;
            }
            set {
                if (String.IsNullOrEmpty(value)) {
                    throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "value");
                }
                _type = value;
            }
        }

        [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")]
        public void AddComponentProperty(string name, string componentID) {
            if (String.IsNullOrEmpty(componentID)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "componentID");
            }
            AddProperty(name, new ComponentReference(componentID));
        }

        [SuppressMessage("Microsoft.Naming", "CA1706:ShortAcronymsShouldBeUppercase")]
        public void AddElementProperty(string name, string elementID) {
            if (String.IsNullOrEmpty(elementID)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "elementID");
            }
            AddProperty(name, new ElementReference(elementID));
        }

        public void AddEvent(string name, string handler) {
            if (String.IsNullOrEmpty(name)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "name");
            }
            if (String.IsNullOrEmpty(handler)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "handler");
            }
            Events[name] = handler;
        }

        public void AddProperty(string name, object value) {
            AddProperty(name, new ObjectReference(value));
        }

        private void AddProperty(string name, Expression value) {
            if (String.IsNullOrEmpty(name)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "name");
            }
            Debug.Assert(value != null);
            Properties[name] = value;
        }

        public void AddScriptProperty(string name, string script) {
            if (String.IsNullOrEmpty(script)) {
                throw new ArgumentException(AtlasWeb.Common_NullOrEmpty, "script");
            }
            AddProperty(name, new ScriptExpression(script));
        }

        private void AppendEventsScript(StringBuilder builder) {
            
            if (_events != null && _events.Count > 0) {
                builder.Append('{');
                bool first = true;

                
                
                foreach (KeyValuePair<string, string> e in _events) {
                    if (first) {
                        first = false;
                    }
                    else {
                        builder.Append(',');
                    }
                    builder.Append('"');
                    builder.Append(JavaScriptString.QuoteString(e.Key));
                    builder.Append('"');
                    builder.Append(':');
                    builder.Append(e.Value);
                }

                builder.Append("}");
            }
            else {
                builder.Append("null");
            }
        }

        private void AppendPropertiesScript(StringBuilder builder) {
            bool first = true;

            
            if (_properties != null && _properties.Count > 0) {
                foreach (KeyValuePair<string, Expression> p in _properties) {
                    if (p.Value.Type == ExpressionType.Script) {
                        if (first) {
                            builder.Append("{");
                            first = false;
                        }
                        else {
                            builder.Append(",");
                        }
                        builder.Append('"');
                        builder.Append(JavaScriptString.QuoteString(p.Key));
                        builder.Append('"');
                        builder.Append(':');
                        p.Value.AppendValue(Serializer, builder);
                    }
                }
            }

            if (first) {
                
                builder.Append("null");
            }
            else {
                
                builder.Append("}");
            }
        }

        private void AppendReferencesScript(StringBuilder builder) {
            bool first = true;

            
            if (_properties != null && _properties.Count > 0) {
                foreach (KeyValuePair<string, Expression> p in _properties) {
                    if (p.Value.Type == ExpressionType.ComponentReference) {
                        if (first) {
                            builder.Append("{");
                            first = false;
                        }
                        else {
                            builder.Append(",");
                        }
                        builder.Append('"');
                        builder.Append(JavaScriptString.QuoteString(p.Key));
                        builder.Append('"');
                        builder.Append(':');
                        p.Value.AppendValue(Serializer, builder);
                    }
                }
            }

            if (first) {
                
                builder.Append("null");
            }
            else {
                
                builder.Append("}");
            }
        }

        protected internal override string GetScript() {
            const string separator = ", ";

            if (!String.IsNullOrEmpty(ID)) {
                AddProperty("id", ID);
            }

            StringBuilder builder = new StringBuilder();
            builder.Append("$create(");

            builder.Append(Type);

            builder.Append(separator);
            AppendPropertiesScript(builder);

            builder.Append(separator);
            AppendEventsScript(builder);

            builder.Append(separator);
            AppendReferencesScript(builder);

            if (ElementIDInternal != null) {
                builder.Append(separator);
                builder.Append("$get(\"");
                builder.Append(JavaScriptString.QuoteString(ElementIDInternal));
                builder.Append("\")");
            }

            builder.Append(");");

            return builder.ToString();
        }

        internal override void RegisterDisposeForDescriptor(ScriptManager scriptManager, Control owner) {
            if (RegisterDispose && scriptManager.SupportsPartialRendering) {
                
                
                
                
                scriptManager.RegisterDispose(owner, "$find('" + ID + "').dispose();");
            }
        }

        private abstract class Expression {
            public abstract ExpressionType Type { get; }
            public abstract void AppendValue(JavaScriptSerializer serializer, StringBuilder builder);
        }

        private enum ExpressionType {
            Script,
            ComponentReference
        }

        private sealed class ComponentReference : Expression {
            private string _componentID;

            public ComponentReference(string componentID) {
                _componentID = componentID;
            }

            public override ExpressionType Type {
                get {
                    return ExpressionType.ComponentReference;
                }
            }

            public override void AppendValue(JavaScriptSerializer serializer, StringBuilder builder) {
                builder.Append('"');
                builder.Append(JavaScriptString.QuoteString(_componentID));
                builder.Append('"');
            }
        }

        private sealed class ElementReference : Expression {
            private string _elementID;

            public ElementReference(string elementID) {
                _elementID = elementID;
            }

            public override ExpressionType Type {
                get {
                    return ExpressionType.Script;
                }
            }

            public override void AppendValue(JavaScriptSerializer serializer, StringBuilder builder) {
                builder.Append("$get(\"");
                builder.Append(JavaScriptString.QuoteString(_elementID));
                builder.Append("\")");
            }
        }

        private sealed class ObjectReference : Expression {
            private object _value;

            public ObjectReference(object value) {
                _value = value;
            }

            public override ExpressionType Type {
                get {
                    return ExpressionType.Script;
                }
            }

            public override void AppendValue(JavaScriptSerializer serializer, StringBuilder builder) {
                serializer.Serialize(_value, builder);
            }
        }

        private sealed class ScriptExpression : Expression {
            private string _script;

            public ScriptExpression(string script) {
                _script = script;
            }

            public override ExpressionType Type {
                get {
                    return ExpressionType.Script;
                }
            }

            public override void AppendValue(JavaScriptSerializer serializer, StringBuilder builder) {
                builder.Append(_script);
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
