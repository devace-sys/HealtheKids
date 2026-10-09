namespace System.Web.Script.Serialization {
    using System;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Text;

    internal class JavaScriptString {
        private string _s;
        private int _index;

        internal JavaScriptString(string s) {
            _s = s;
        }

        internal Nullable<char> GetNextNonEmptyChar() {
            while (_s.Length > _index) {
                char c = _s[_index++];
                if (!Char.IsWhiteSpace(c)) {
                    return c;
                }
            }

            return null;
        }

        internal Nullable<char> MoveNext() {
            if (_s.Length > _index) {
                return _s[_index++];
            }

            return null;
        }

        internal string MoveNext(int count) {
            if (_s.Length >= _index + count) {
                string result = _s.Substring(_index, count);
                _index += count;

                return result;
            }

            return null;
        }

        internal void MovePrev() {
            if (_index > 0) {
                _index--;
            }
        }

        internal void MovePrev(int count) {
            while (_index > 0 && count > 0) {
                _index--;
                count--;
            }
        }

        private static void AppendCharAsUnicode(StringBuilder builder, char c) {
            builder.Append("\\u");
            builder.AppendFormat(CultureInfo.InvariantCulture, "{0:x4}", (int)c);
        }

        [SuppressMessage("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity",
            Justification="Method would be more complex if split into separate pieces.")]
        internal static string QuoteString(string value) {
            StringBuilder b = null;

            if (String.IsNullOrEmpty(value)) {
                return String.Empty;
            }

            int startIndex = 0;
            int count = 0;
            for (int i = 0; i < value.Length; i++) {
                char c = value[i];

                
                
                if (c == '\r' || c == '\t' || c == '\"' || c == '\'' || c == '<' || c == '>' ||
                    c == '\\' || c == '\n' || c == '\b' || c == '\f' || c < ' ') {
                    if (b == null) {
                        b = new StringBuilder(value.Length + 5);
                    }

                    if (count > 0) {
                        b.Append(value, startIndex, count);
                    }

                    startIndex = i+1;
                    count = 0;
                }

                switch (c) {
                case '\r':
                    b.Append("\\r");
                    break;
                case '\t':
                    b.Append("\\t");
                    break;
                case '\"':
                    b.Append("\\\"");
                    break;
                case '\\':
                    b.Append("\\\\");
                    break;
                case '\n':
                    b.Append("\\n");
                    break;
                case '\b':
                    b.Append("\\b");
                    break;
                case '\f':
                    b.Append("\\f");
                    break;
                case '\'':
                case '>':
                case '<':
                    AppendCharAsUnicode(b, c);
                    break;
                default:
                    if (c < ' ') {
                        AppendCharAsUnicode(b, c);
                    } else {
                        count++;
                    }
                    break;
                }
            }

            if (b == null) {
                return value;
            }

            if (count > 0) {
                b.Append(value, startIndex, count);
            }

            return b.ToString();
        }

        internal static string QuoteString(string value, bool addQuotes) {
            string s = QuoteString(value);
            if (addQuotes) {
                s = "\"" + s + "\"";
            }
            return s;
        }

        public override string ToString() {
            if (_s.Length > _index) {
                return _s.Substring(_index);
            }

            return String.Empty;
        }

        internal string GetDebugString(string message) {
            return message + " (" + _index + "): " + _s;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
