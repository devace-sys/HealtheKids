
namespace System.Web.UI {
    using System;
    using System.Collections.Specialized;
    using System.IO;

    internal interface IHttpResponse {
        IHttpCachePolicy Cache {
            get;
        }

        string ContentType {
            set;
        }

        Stream Filter {
            get;
            set;
        }

        TextWriter Output {
            get;
        }

        void Clear();

        void End();

        void Flush();

        void Write(string s);
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
