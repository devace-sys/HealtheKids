namespace System.Web.UI {
    using System;
    using System.Web.UI;

    internal sealed class ClientUrlResolverWrapper : IClientUrlResolver {
        private readonly Control _control;

        public ClientUrlResolverWrapper(Control control) {
            _control = control;
        }

        #region IClientUrlResolver Members
        string IClientUrlResolver.ResolveClientUrl(string relativeUrl) {
            IClientUrlResolver resolver = _control as IClientUrlResolver;
            if (resolver != null) {
                return resolver.ResolveClientUrl(relativeUrl);
            }
            else {
                return _control.ResolveClientUrl(relativeUrl);
            }
        }
        #endregion
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
