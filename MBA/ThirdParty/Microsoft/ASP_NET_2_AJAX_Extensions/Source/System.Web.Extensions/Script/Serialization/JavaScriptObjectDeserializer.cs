using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Globalization;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Resources;

namespace System.Web.Script.Serialization {

    internal class JavaScriptObjectDeserializer {
        private const string DateTimePrefix = @"""\/Date(";
        private const int DateTimePrefixLength = 8;

        internal JavaScriptString _s;
        private JavaScriptSerializer _serializer;
        private int _depthLimit;

        internal static object BasicDeserialize(string input, int depthLimit, JavaScriptSerializer serializer) {
            JavaScriptObjectDeserializer jsod = new JavaScriptObjectDeserializer(input, depthLimit, serializer);
            object result = jsod.DeserializeInternal(0);
            if (jsod._s.GetNextNonEmptyChar() != null) {
                throw new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_IllegalPrimitive, jsod._s.ToString()));
            }
            return result;
        }

        private JavaScriptObjectDeserializer(string input, int depthLimit, JavaScriptSerializer serializer) {
            _s = new JavaScriptString(input);
            _depthLimit = depthLimit;
            _serializer = serializer;
        }

        private object DeserializeInternal(int depth) {
            if (++depth > _depthLimit) {
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_DepthLimitExceeded));
            }

            Nullable<Char> c = _s.GetNextNonEmptyChar();
            if (c == null) {
                return null;
            }

            _s.MovePrev();

            if (IsNextElementDateTime()) {
                return DeserializeStringIntoDateTime();
            }

            if (IsNextElementObject(c)) {
                IDictionary<string, object> dict = DeserializeDictionary(depth);
                
                if (dict.ContainsKey(JavaScriptSerializer.ServerTypeFieldName)) {
                    return ObjectConverter.ConvertObjectToType(dict, null, _serializer);
                }
                return dict;
            }

            if (IsNextElementArray(c)) {
                return DeserializeList(depth);
            }

            if (IsNextElementString(c)) {
                return DeserializeString();
            }

            return DeserializePrimitiveObject();
        }

        private IList DeserializeList(int depth) {
            IList list = new ArrayList();
            Nullable<Char> c = _s.MoveNext();
            if (c != '[') {
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidArrayStart));
            }

            bool expectMore = false;
            while ((c = _s.GetNextNonEmptyChar()) != null && c != ']') {
                _s.MovePrev();
                object o = DeserializeInternal(depth);
                list.Add(o);

                expectMore = false;
                
                c = _s.GetNextNonEmptyChar();
                if (c == ']') {
                    break;
                }

                expectMore = true;
                if (c != ',') {
                    throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidArrayExpectComma));
                }
            }
            if (expectMore) {
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidArrayExtraComma));
            }
            if (c != ']') {
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidArrayEnd));
            }
            return list;
        }

        private IDictionary<string, object> DeserializeDictionary(int depth) {
            IDictionary<string, object> dictionary = null;
            Nullable<Char> c = _s.MoveNext();
            if (c != '{') {
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_ExpectedOpenBrace));
            }

            
            while ((c = _s.GetNextNonEmptyChar()) != null) {
                _s.MovePrev();

                if (c == ':') {
                    throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidMemberName));
                }

                string memberName = null;
                if (c != '}') {
                    
                    memberName = DeserializeMemberName();
                    if (String.IsNullOrEmpty(memberName)) {
                        throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidMemberName));
                    }
                    c = _s.GetNextNonEmptyChar();
                    if (c != ':') {
                        throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidObject));
                    }
                }

                if (dictionary == null) {
                    dictionary = new Dictionary<string, object>();

                    
                    if (String.IsNullOrEmpty(memberName)) {
                        
                        c = _s.GetNextNonEmptyChar();
                        Debug.Assert(c == '}');
                        break;
                    }
                }

                
                object propVal = DeserializeInternal(depth);
                dictionary[memberName] = propVal;
                c = _s.GetNextNonEmptyChar();
                if (c == '}') {
                    break;
                }

                if (c != ',') {
                    throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidObject));
                }
            }

            if (c != '}') {
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_InvalidObject));
            }

            return dictionary;
        }

        
        
        
        
        private string DeserializeMemberName() {

            
            Nullable<Char> c = _s.GetNextNonEmptyChar();
            if (c == null) {
                return null;
            }

            _s.MovePrev();

            
            if (IsNextElementString(c)) {
                return DeserializeString();
            }

            
            return DeserializePrimitiveToken();
        }

        private object DeserializePrimitiveObject() {
            string input = DeserializePrimitiveToken();
            if (input.Equals("null")) {
                return null;
            }

            if (input.Equals("true")) {
                return true;
            }

            if (input.Equals("false")) {
                return false;
            }

            
            bool hasDecimalPoint = input.IndexOf('.') >= 0;
            if (!hasDecimalPoint) {
                
                int n;
                if (Int32.TryParse(input, NumberStyles.Integer, CultureInfo.InvariantCulture, out n)) {
                    return n;
                }

                
                long l;
                if (Int64.TryParse(input, NumberStyles.Integer, CultureInfo.InvariantCulture, out l)) {
                    return l;
                }
            }

            decimal dec;
            if (decimal.TryParse(input, NumberStyles.Number, CultureInfo.InvariantCulture, out dec)) {
                return dec;
            }

            Double d;
            if (Double.TryParse(input, NumberStyles.Float, CultureInfo.InvariantCulture, out d)) {
                return d;
            }

            throw new ArgumentException(String.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_IllegalPrimitive, input));
        }

        private string DeserializePrimitiveToken() {
            StringBuilder sb = new StringBuilder();
            Nullable<Char> c = null;
            while ((c = _s.MoveNext()) != null) {
                if (Char.IsLetterOrDigit(c.Value) || c.Value == '.' ||
                    c.Value == '-' || c.Value == '_' || c.Value == '+') {

                    sb.Append(c);
                }
                else {
                    _s.MovePrev();
                    break;
                }
            }

            return sb.ToString();
        }

        private string DeserializeString() {
            StringBuilder sb = new StringBuilder();
            bool escapedChar = false;

            Nullable<Char> c = _s.MoveNext();

            
            Char quoteChar = CheckQuoteChar(c);
            while ((c = _s.MoveNext()) != null) {
                if (c == '\\') {
                    if (escapedChar) {
                        sb.Append('\\');
                        escapedChar = false;
                    }
                    else {
                        escapedChar = true;
                    }

                    continue;
                }

                if (escapedChar) {
                    AppendCharToBuilder(c, sb);
                    escapedChar = false;
                }
                else {
                    if (c == quoteChar) {
                        return sb.ToString();
                    }

                    sb.Append(c);
                }
            }

            throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_UnterminatedString));
        }

        private void AppendCharToBuilder(char? c, StringBuilder sb) {
            if (c == '"' || c == '\'' || c == '/') {
                sb.Append(c);
            }
            else if (c == 'b') {
                sb.Append('\b');
            }
            else if (c == 'f') {
                sb.Append('\f');
            }
            else if (c == 'n') {
                sb.Append('\n');
            }
            else if (c == 'r') {
                sb.Append('\r');
            }
            else if (c == 't') {
                sb.Append('\t');
            }
            else if (c == 'u') {
                sb.Append((char)int.Parse(_s.MoveNext(4), NumberStyles.HexNumber, CultureInfo.InvariantCulture));
            }
            else {
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_BadEscape));
            }
        }

        private char CheckQuoteChar(char? c) {
            Char quoteChar = '"';
            if (c == '\'') {
                quoteChar = c.Value;
            }
            else if (c != '"') {
                
                throw new ArgumentException(_s.GetDebugString(AtlasWeb.JSON_StringNotQuoted));
            }

            return quoteChar;
        }

        private object DeserializeStringIntoDateTime() {
            
            
            Match match = Regex.Match(_s.ToString(), @"^""\\/Date\((?<ticks>-?[0-9]+)\)\\/""");
            string ticksStr = match.Groups["ticks"].Value;

            long ticks;
            if (long.TryParse(ticksStr, out ticks)) {
                _s.MoveNext(match.Length);

                
                DateTime dt = new DateTime(ticks * 10000 + JavaScriptSerializer.DatetimeMinTimeTicks, DateTimeKind.Utc);
                return dt;
            }
            else {
                
                return DeserializeString();
            }
        }

        private static bool IsNextElementArray(Nullable<Char> c) {
            return c == '[';
        }

        private bool IsNextElementDateTime() {
            String next = _s.MoveNext(DateTimePrefixLength);
            if (next != null) {
                _s.MovePrev(DateTimePrefixLength);
                return String.Equals(next, DateTimePrefix, StringComparison.Ordinal);
            }

            return false;
        }

        private static bool IsNextElementObject(Nullable<Char> c) {
            return c == '{';
        }

        private static bool IsNextElementString(Nullable<Char> c) {
            return c == '"' || c == '\'';
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
