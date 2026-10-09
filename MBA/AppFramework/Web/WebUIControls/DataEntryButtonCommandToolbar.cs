using System;
using System.Web.UI;
using System.ComponentModel;
using System.Text;
using System.Collections.Generic;

namespace MBA
{
    /**************************************************************************
     * DataEntryButtonCommandToolbar */
    /**
     **************************************************************************/
    public class DataEntryButtonCommandToolbar : DataEntryButtonBase
    {
        private static readonly Dictionary<string, string> colorMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "PRIMARY", "#8A2BE2" },
            { "SECONDARY", "#6C757D" },
            { "SUCCESS", "#00CCAA" },
            { "DANGER", "#B71C1C" },
            { "WARNING", "#E55A00" },
            { "INFO", "#00E0FF" },
            { "LIGHT", "#F8F9FA" },
            { "DARK", "#010326" }
        };

        private static readonly Dictionary<string, string> colorMapLight = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "PRIMARY", "#E2D6F8" },
            { "SECONDARY", "#E9ECEF" },
            { "SUCCESS", "#D0F4EA" },
            { "DANGER", "#FFEBEE" },
            { "WARNING", "#FFF3E0" },
            { "INFO", "#E1F5FE" },
            { "LIGHT", "#FFFFFF" },
            { "DARK", "#E0E0E0" }
        };



        public DataEntryButtonCommandToolbar() { }

        protected string _onclick = String.Empty;
        public string onclick
        {
            get { return _onclick; }
            set { _onclick = value; }
        }
        public string IconHtml { get; set; }

        protected string _customGlowColor = String.Empty;
        public string CustomGlowColor
        {
            get { return _customGlowColor; }
            set { _customGlowColor = value; }
        }

        protected string _customTextColor = String.Empty;
        public string CustomTextColor
        {
            get { return _customTextColor; }
            set { _customTextColor = value; }
        }

        protected string _hoverEffects = "glow,shimmer";
        public string HoverEffects
        {
            get { return _hoverEffects; }
            set { _hoverEffects = value; }
        }

        protected override void Render(HtmlTextWriter writer)
        {
            assignCssClasses();

            bool isLightTheme = _cssClasses.Contains("-light");
            bool isPrimaryAction = _cssClasses.Contains("mba-cmd-tbar-btn-primary") || _cssClasses.Contains("mba-cmd-tbar-btn-primary-light");
            bool isCustomColor = !String.IsNullOrEmpty(_customGlowColor);

            string textColor = !String.IsNullOrEmpty(_customTextColor)
                ? _customTextColor
                : (isLightTheme ? "#333" : "#FFF");

            if (this.style == DataEntryButtonStyle.LIGHT && String.IsNullOrEmpty(_customTextColor))
            {
                textColor = isLightTheme ? "#212121" : "#1D1942";
            }

            if (isCustomColor || !String.IsNullOrEmpty(_customTextColor)
             || !String.IsNullOrEmpty(_hoverEffects))
            {
                writer.Write("<style>");

                if (isCustomColor && !isPrimaryAction)
                {
                    string opacity = isLightTheme ? "0.15" : "0.5";
                    string btnGlowClass = isLightTheme ? "mba-cmd-tbar-btn-glow-light" : "mba-cmd-tbar-btn-glow";
                }

                if (!String.IsNullOrEmpty(_customTextColor))
                {
                    string btnContentClass = isLightTheme ? "mba-cmd-tbar-btn-content-light" : "mba-cmd-tbar-btn-content";
                    writer.Write($"#{this.ClientID} .{btnContentClass} {{ color: {_customTextColor}; }}");
                }

                if (!String.IsNullOrEmpty(_hoverEffects))
                {
                    string[] effects = _hoverEffects.Split(',');
                    string btnGlowClass = isLightTheme ? "mba-cmd-tbar-btn-glow-light" : "mba-cmd-tbar-btn-glow";

                    foreach (string effect in effects)
                    {
                        string trimmedEffect = effect.Trim().ToLower();

                        if (trimmedEffect == "noglow")
                        {
                            string opacity = isLightTheme ? "0.3" : "0.5";
                        }

                        if (trimmedEffect == "noshimmer")
                        {
                            writer.Write($"#{this.ClientID}::after {{ display: none; }}");
                        }
                    }
                }

                if (isPrimaryAction && !String.IsNullOrEmpty(_customTextColor))
                {
                    string btnContentClass = isLightTheme ? "mba-cmd-tbar-btn-content-light" : "mba-cmd-tbar-btn-content";
                    writer.Write($"#{this.ClientID} .{btnContentClass}::after {{ color: {_customTextColor}; }}");
                }

                writer.Write("</style>");
            }

            writer.AddAttribute("id", this.ClientID);
            writer.AddAttribute("type", this.type);
            writer.AddAttribute("class", _cssClasses);

            if (!String.IsNullOrEmpty(this.title))
                writer.AddAttribute("title", this.title);

            if (!String.IsNullOrEmpty(_onclick))
                writer.AddAttribute("onclick", _onclick);

            writer.RenderBeginTag(HtmlTextWriterTag.Button);

            string backdropClass = isLightTheme ? "mba-cmd-tbar-btn-backdrop-light" : "mba-cmd-tbar-btn-backdrop";
            string glowClass = isLightTheme ? "mba-cmd-tbar-btn-glow-light" : "mba-cmd-tbar-btn-glow";
            string contentClass = isLightTheme ? "mba-cmd-tbar-btn-content-light" : "mba-cmd-tbar-btn-content";
            string iconClass = isLightTheme ? "mba-cmd-tbar-btn-icon-light" : "mba-cmd-tbar-btn-icon";

            writer.Write($"<div class=\"{backdropClass}\"></div>");
            writer.Write($"<div class=\"{glowClass}\"></div>");
            writer.Write($"<div class=\"{contentClass}\">");

            if (!iconOnly)
            {
                if (!String.IsNullOrEmpty(IconHtml))
                    writer.Write($"<div class=\"{iconClass}\">{IconHtml}</div>");
                else if (!String.IsNullOrEmpty(faIcon))
                    writer.Write($"<div class=\"{iconClass}\"><i class=\"{faIcon}\"></i></div>");
            }

            if (!iconOnly)
                writer.Write(label);

            writer.Write("</div>");
            writer.RenderEndTag();
        }

        private string AdjustBrightness(string hexColor, float factor)
        {
            try
            {
                if (hexColor.StartsWith("#"))
                    hexColor = hexColor.Substring(1);

                if (hexColor.Length == 3)
                {
                    hexColor = $"{hexColor[0]}{hexColor[0]}{hexColor[1]}{hexColor[1]}{hexColor[2]}{hexColor[2]}";
                }

                int r = Convert.ToInt32(hexColor.Substring(0, 2), 16);
                int g = Convert.ToInt32(hexColor.Substring(2, 2), 16);
                int b = Convert.ToInt32(hexColor.Substring(4, 2), 16);

                r = Math.Min(255, Math.Max(0, (int)(r + (r * factor))));
                g = Math.Min(255, Math.Max(0, (int)(g + (g * factor))));
                b = Math.Min(255, Math.Max(0, (int)(b + (b * factor))));

                return $"#{r:X2}{g:X2}{b:X2}";
            }
            catch
            {
                return hexColor;
            }
        }

        private string AddAlpha(string hexColor, double alpha)
        {
            try
            {
                if (hexColor.StartsWith("#"))
                    hexColor = hexColor.Substring(1);

                if (hexColor.Length == 3)
                {
                    hexColor = $"{hexColor[0]}{hexColor[0]}{hexColor[1]}{hexColor[1]}{hexColor[2]}{hexColor[2]}";
                }

                int r = Convert.ToInt32(hexColor.Substring(0, 2), 16);
                int g = Convert.ToInt32(hexColor.Substring(2, 2), 16);
                int b = Convert.ToInt32(hexColor.Substring(4, 2), 16);

                return $"rgba({r}, {g}, {b}, {alpha})";
            }
            catch
            {
                return $"rgba(0, 0, 0, {alpha})";
            }
        }
    }
}