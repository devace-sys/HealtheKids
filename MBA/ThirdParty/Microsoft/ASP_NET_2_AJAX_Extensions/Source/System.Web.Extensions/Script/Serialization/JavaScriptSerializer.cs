namespace System.Web.Script.Serialization {
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Collections.Specialized;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.IO;
    using System.Reflection;
    using System.Security.Permissions;
    using System.Text;
    using System.Web;
    using System.Web.UI;
    using System.Xml.Serialization;
    using System.Web.Resources;
    using System.Web.Script.Services;

    [
    AspNetHostingPermission(SecurityAction.LinkDemand, Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand, Level = AspNetHostingPermissionLevel.Minimal)
    ]
    public class JavaScriptSerializer {
        internal const string ServerTypeFieldName = "__type";
        internal const int DefaultRecursionLimit = 100;
        internal const int DefaultMaxJsonLength = 2097152;

        internal static string SerializeInternal(object o) {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(o);
        }

        internal static object Deserialize(JavaScriptSerializer serializer, string input, Type type, int depthLimit) {
            if (input == null) {
                throw new ArgumentNullException("input");
            }
            if (input.Length > serializer.MaxJsonLength) {
                throw new ArgumentException(AtlasWeb.JSON_MaxJsonLengthExceeded, "input");
            }

            object o = JavaScriptObjectDeserializer.BasicDeserialize(input, depthLimit, serializer);
            return ObjectConverter.ConvertObjectToType(o, type, serializer);
        }

        
        private JavaScriptTypeResolver _typeResolver;
        private int _recursionLimit;
        private int _maxJsonLength;

        public JavaScriptSerializer() : this(null) { }

        public JavaScriptSerializer(JavaScriptTypeResolver resolver) {
            _typeResolver = resolver;
            RecursionLimit = DefaultRecursionLimit;
            MaxJsonLength = DefaultMaxJsonLength;
        }

        public int MaxJsonLength {
            get {
                return _maxJsonLength;
            }
            set {
                if (value < 1) {
                    throw new ArgumentOutOfRangeException(AtlasWeb.JSON_InvalidMaxJsonLength);
                }
                _maxJsonLength = value;
            }
        }

        public int RecursionLimit {
            get {
                return _recursionLimit;
            }
            set {
                if (value < 1) {
                    throw new ArgumentOutOfRangeException(AtlasWeb.JSON_InvalidRecursionLimit);
                }
                _recursionLimit = value;
            }
        }

        internal JavaScriptTypeResolver TypeResolver {
            get {
                return _typeResolver;
            }
        }

        private Dictionary<Type, JavaScriptConverter> _converters;
        private Dictionary<Type, JavaScriptConverter> Converters {
            get {
                if (_converters == null) {
                    _converters = new Dictionary<Type, JavaScriptConverter>();
                }
                return _converters;
            }
        }

        public void RegisterConverters(IEnumerable<JavaScriptConverter> converters) {
            if (converters == null) {
                throw new ArgumentNullException("converters");
            }

            foreach (JavaScriptConverter converter in converters) {
                IEnumerable<Type> supportedTypes = converter.SupportedTypes;
                if (supportedTypes != null) {
                    foreach (Type supportedType in supportedTypes) {
                        Converters[supportedType] = converter;
                    }
                }
            }
        }

        private JavaScriptConverter GetConverter(Type t) {
            if (_converters != null) {
                while (t != null) {
                    if (_converters.ContainsKey(t)) {
                        return _converters[t];
                    }
                    t = t.BaseType;
                }
            }
            return null;
        }

        internal bool ConverterExistsForType(Type t, out JavaScriptConverter converter) {
            converter = GetConverter(t);
            return converter != null;
        }

        public object DeserializeObject(string input) {
            return Deserialize(this, input, null , RecursionLimit);
        }

        [SuppressMessage("Microsoft.Design", "CA1004:GenericMethodsShouldProvideTypeParameter",
            Justification = "Generic parameter is preferable to forcing caller to downcast. " +
                "Has has been approved by API review board.")]
        public T Deserialize<T>(string input) {
            return (T)Deserialize(this, input, typeof(T), RecursionLimit);
        }

        [SuppressMessage("Microsoft.Design", "CA1004:GenericMethodsShouldProvideTypeParameter",
            Justification = "Generic parameter is preferable to forcing caller to downcast. " +
                "Has has been approved by API review board.")]
        public T ConvertToType<T>(object obj) {
            return (T)ObjectConverter.ConvertObjectToType(obj, typeof(T), this);
        }

        public string Serialize(object obj) {
            StringBuilder sb = new StringBuilder();
            Serialize(obj, sb);
            return sb.ToString();
        }

        public void Serialize(object obj, StringBuilder output) {
            SerializeValue(obj, output, 0, null);
            if (output.Length > MaxJsonLength) {
                throw new InvalidOperationException(AtlasWeb.JSON_MaxJsonLengthExceeded);
            }
        }

        private static void SerializeBoolean(bool o, StringBuilder sb) {
            if (o) {
                sb.Append("true");
            }
            else {
                sb.Append("false");
            }
        }

        private static void SerializeUri(Uri uri, StringBuilder sb) {
            sb.Append("\"").Append(uri.GetComponents(UriComponents.SerializationInfoString, UriFormat.UriEscaped)).Append("\"");
        }

        private static void SerializeGuid(Guid guid, StringBuilder sb) {
            sb.Append("\"").Append(guid.ToString()).Append("\"");
        }

        internal static readonly long DatetimeMinTimeTicks = (new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).Ticks;
        private static void SerializeDateTime(DateTime datetime, StringBuilder sb) {
            
            
            sb.Append(@"""\/Date(");
            sb.Append((datetime.ToUniversalTime().Ticks - DatetimeMinTimeTicks) / 10000);
            sb.Append(@")\/""");
        }

        
        private void SerializeCustomObject(object o, StringBuilder sb, int depth, Hashtable objectsInUse) {
            bool first = true;
            Type type = o.GetType();
            sb.Append('{');

            
            if (TypeResolver != null) {

                
                string typeString = TypeResolver.ResolveTypeId(type);
                if (typeString != null) {
                    SerializeString(ServerTypeFieldName, sb);
                    sb.Append(':');
                    SerializeValue(typeString, sb, depth, objectsInUse);
                    first = false;
                }
            }

            FieldInfo[] fields = type.GetFields(BindingFlags.Public | BindingFlags.Instance);
            foreach (FieldInfo fieldInfo in fields) {

                
                if (fieldInfo.IsDefined(typeof(ScriptIgnoreAttribute), true )) continue;

                if (!first) sb.Append(',');
                SerializeString(fieldInfo.Name, sb);
                sb.Append(':');
                SerializeValue(fieldInfo.GetValue(o), sb, depth, objectsInUse);
                first = false;
            }

            PropertyInfo[] props = type.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.GetProperty);
            foreach (PropertyInfo propInfo in props) {

                
                if (propInfo.IsDefined(typeof(ScriptIgnoreAttribute), true ))
                    continue;

                MethodInfo getMethodInfo = propInfo.GetGetMethod();

                
                if (getMethodInfo == null) {
                    continue;
                }

                
                if (getMethodInfo.GetParameters().Length > 0) continue;

                if (!first) sb.Append(',');
                SerializeString(propInfo.Name, sb);
                sb.Append(':');
                SerializeValue(getMethodInfo.Invoke(o, null), sb, depth, objectsInUse);
                first = false;
            }

            sb.Append('}');
        }

        private void SerializeDictionary(IDictionary o, StringBuilder sb, int depth, Hashtable objectsInUse) {
            sb.Append('{');
            bool isFirstElement = true;
            foreach (DictionaryEntry entry in (IDictionary)o) {
                if (!isFirstElement) {
                    sb.Append(',');
                }
                string key = entry.Key as string;
                if (key == null) {
                    throw new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_DictionaryTypeNotSupported, o.GetType().FullName));
                }
                SerializeString((string)entry.Key, sb);
                sb.Append(':');
                SerializeValue(entry.Value, sb, depth, objectsInUse);
                isFirstElement = false;
            }
            sb.Append('}');
        }

        private void SerializeEnumerable(IEnumerable enumerable, StringBuilder sb, int depth, Hashtable objectsInUse) {
            sb.Append('[');
            bool isFirstElement = true;
            foreach (object o in enumerable) {
                if (!isFirstElement) {
                    sb.Append(',');
                }

                SerializeValue(o, sb, depth, objectsInUse);
                isFirstElement = false;
            }
            sb.Append(']');
        }

        private static void SerializeString(string input, StringBuilder sb) {
            sb.Append('"');
            sb.Append(JavaScriptString.QuoteString(input));
            sb.Append('"');
        }

        private void SerializeValue(object o, StringBuilder sb, int depth, Hashtable objectsInUse) {
            if (++depth > _recursionLimit) {
                throw new ArgumentException(AtlasWeb.JSON_DepthLimitExceeded);
            }

            
            JavaScriptConverter converter = null;
            if (o != null && ConverterExistsForType(o.GetType(), out converter)) {
                IDictionary<string, object> dict = converter.Serialize(o, this);

                if (TypeResolver != null) {
                    string typeString = TypeResolver.ResolveTypeId(o.GetType());
                    if (typeString != null) {
                        dict[ServerTypeFieldName] = typeString;
                    }
                }

                sb.Append(Serialize(dict));
                return;
            }

            SerializeValueInternal(o, sb, depth, objectsInUse);
        }

        
        private class ReferenceComparer : IEqualityComparer {
            bool IEqualityComparer.Equals(object x, object y) {
                return x == y;
            }

            int IEqualityComparer.GetHashCode(object obj) {
                return System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(obj);
            }
        }

        private void SerializeValueInternal(object o, StringBuilder sb, int depth, Hashtable objectsInUse) {
            
            if (o == null || DBNull.Value.Equals(o)) {
                sb.Append("null");
                return;
            }

            
            string os = o as String;
            if (os != null) {
                SerializeString(os, sb);
                return;
            }

            if (o is Char) {
                
                if ((char)o == '\0') {
                    sb.Append("null");
                    return;
                }
                SerializeString(o.ToString(), sb);
                return;
            }

            
            if (o is bool) {
                SerializeBoolean((bool)o, sb);
                return;
            }

            if (o is DateTime) {
                SerializeDateTime((DateTime)o, sb);
                return;
            }

            if (o is Guid) {
                SerializeGuid((Guid)o, sb);
                return;
            }

            Uri uri = o as Uri;
            if (uri != null) {
                SerializeUri(uri, sb);
                return;
            }

            
            if (o is double) {
                sb.Append(((double)o).ToString("r", CultureInfo.InvariantCulture));
                return;
            }

            if (o is float) {
                sb.Append(((float)o).ToString("r", CultureInfo.InvariantCulture));
                return;
            }

            
            if (o.GetType().IsPrimitive || o is Decimal) {
                IConvertible convertible = o as IConvertible;
                if (convertible != null) {
                    sb.Append(convertible.ToString(CultureInfo.InvariantCulture));
                }
                else {
                    
                    Debug.Assert(false);
                    sb.Append(o.ToString());
                }
                return;
            }

            
            Type type = o.GetType();
            if (type.IsEnum) {
                sb.Append((int)o);
                return;
            }

            try {
                
                if (objectsInUse == null) {
                    
                    objectsInUse = new Hashtable(new ReferenceComparer());
                }
                else if (objectsInUse.ContainsKey(o)) {
                    
                    throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, AtlasWeb.JSON_CircularReference, type.FullName));
                }
                
                objectsInUse.Add(o, null);

                
                IDictionary od = o as IDictionary;
                if (od != null) {
                    SerializeDictionary(od, sb, depth, objectsInUse);
                    return;
                }

                
                IEnumerable oenum = o as IEnumerable;
                if (oenum != null) {
                    SerializeEnumerable(oenum, sb, depth, objectsInUse);
                    return;
                }

                
                SerializeCustomObject(o, sb, depth, objectsInUse);
            }
            finally {
                
                if (objectsInUse != null) {
                    objectsInUse.Remove(o);
                }
            }
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
