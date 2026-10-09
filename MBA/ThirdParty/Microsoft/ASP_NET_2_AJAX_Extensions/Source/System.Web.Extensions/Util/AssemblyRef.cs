namespace System.Web.Util {
    using System;
    using System.Reflection;

    internal static class AssemblyRef {
        
        public static readonly Assembly SystemWebExtensions = typeof(AssemblyRef).Assembly;

        private const string Version = "1.0.61025.0";
        private const string PublicKeyToken = "31bf3856ad364e35";
        public const string SystemWebExtensionsDesign = "System.Web.Extensions.Design, " +
            "Version=" + Version + ", Culture=neutral, PublicKeyToken=" + PublicKeyToken;
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
