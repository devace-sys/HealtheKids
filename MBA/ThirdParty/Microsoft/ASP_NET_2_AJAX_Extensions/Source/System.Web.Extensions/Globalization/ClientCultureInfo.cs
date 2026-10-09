namespace System.Web.Globalization {
    using System;
    using System.Collections;
    using System.Globalization;
    using System.Text;
    using System.Web.Script.Serialization;

    internal class ClientCultureInfo {

        private static Hashtable cultureScriptBlockCache = Hashtable.Synchronized(new Hashtable());

        public string name;
        public NumberFormatInfo numberFormat;
        public DateTimeFormatInfo dateTimeFormat;

        private ClientCultureInfo(CultureInfo cultureInfo) {
            name = cultureInfo.Name;
            numberFormat = cultureInfo.NumberFormat;
            dateTimeFormat = cultureInfo.DateTimeFormat;
        }

        internal static string GetClientCultureScriptBlock() {
            return GetClientCultureScriptBlock(CultureInfo.CurrentCulture);
        }

        internal static string GetClientCultureScriptBlock(CultureInfo cultureInfo) {
            if ((cultureInfo == null) ||
                cultureInfo.Equals(CultureInfo.GetCultureInfo(0x409))) {
                return null;
            }

            object cached = cultureScriptBlockCache[cultureInfo];
            if (cached == null) {
                ClientCultureInfo clientCultureInfo = new ClientCultureInfo(cultureInfo);
                string rawJsonString = JavaScriptSerializer.SerializeInternal(clientCultureInfo);
                if (rawJsonString.Length > 0) {
                    cached = "var __cultureInfo = '" + rawJsonString + "';";
                }
                cultureScriptBlockCache[cultureInfo] = cached;
            }
            return (string)cached;
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
