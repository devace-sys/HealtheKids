namespace System.Web.UI.Design {
    using System;
    using System.Globalization;
    using System.Web.UI;

    internal static class DesignUtil {

        
        
        
        
        private const string StandardDesignTimeHtml =
        @"<table style=""border:1px solid #CCCCCC;"" cellspacing=""0"" cellpadding=""0"">
<tr>
<td nowrap style=""font:messagebox;background-color:#ffffff;color:#444444;{0}background-position:bottom;background-repeat:repeat-x;padding:4px;""><strong>{1}</strong>{2}</td>
</tr>{3}
</table>";
        private const string SubtitleContainerHtml = @" - {0}";
        private const string ErrorContainerHtml = @"<span style=""color:red"">{0}</span>";
        private const string ContentHtml = @"
<tr>
<td {1}>{0}</td>
</tr>
";

        internal static string GetContainerDesignTimeHtml(IServiceProvider serviceProvider, string title, string subtitle, string content, string contentAttributes, bool isError) {
            string backgroundStyle = String.Empty;
            if (serviceProvider != null) {
                IResourceUrlGenerator urlGenerator = (IResourceUrlGenerator)serviceProvider.GetService(typeof(IResourceUrlGenerator));
                if (urlGenerator != null) {
                    backgroundStyle = String.Format(
                        CultureInfo.InvariantCulture,
                        "background-image:url({0});",
                        urlGenerator.GetResourceUrl(typeof(ScriptManagerDesigner), "System.Web.Resources.Design.Background.gif"));
                }
            }
            string titleHtml = isError ? String.Format(CultureInfo.InvariantCulture, ErrorContainerHtml, title) : title;
            string subtitleHtml = (!String.IsNullOrEmpty(subtitle)) ? String.Format(CultureInfo.InvariantCulture, SubtitleContainerHtml, subtitle) : String.Empty;
            string contentHtml = String.Empty;
            if (!String.IsNullOrEmpty(content) ||
                !String.IsNullOrEmpty(contentAttributes)) {
                contentHtml = String.Format(CultureInfo.InvariantCulture, ContentHtml, content, contentAttributes);
            }
            return String.Format(CultureInfo.InvariantCulture, StandardDesignTimeHtml, backgroundStyle, titleHtml, subtitleHtml, contentHtml);
        }

        internal static string GetStandardDesignTimeHtml(IServiceProvider serviceProvider, string title, string subtitle, bool isError) {
            return GetContainerDesignTimeHtml(serviceProvider, title, subtitle, null, null, isError);
        }
    }
}

// File provided for Microsoft ASP.NET AJAX.
// Copyright (c) Microsoft Corporation. All rights reserved.
