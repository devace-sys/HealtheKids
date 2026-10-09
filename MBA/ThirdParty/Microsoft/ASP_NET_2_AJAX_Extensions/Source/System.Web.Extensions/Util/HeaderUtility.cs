namespace System.Web.Util {
    using System;

    internal static class HeaderUtility {
        public static bool IsEncodingInAcceptList(string acceptEncodingHeader, string expectedEncoding) {
            if (String.IsNullOrEmpty(acceptEncodingHeader)) {
                return false;
            }

            foreach (string encoding in acceptEncodingHeader.Split(',')) {
                string e = encoding.Trim();

                
                
                
                
                
                
                
                
                if (String.Equals(e, expectedEncoding, StringComparison.Ordinal)) {
                    return true;
                }
            }

            
            return false;
        }

    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
