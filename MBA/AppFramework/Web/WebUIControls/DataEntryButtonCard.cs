using System;
using System.Web.UI;
using System.Text;
using System.ComponentModel;

namespace MBA
{
    /**************************************************************************
     * DataEntryButtonCard */
    /**
     **************************************************************************/
    public class DataEntryButtonCard : DataEntryButtonBase
    {
        public DataEntryButtonCard()
        {
        }

        protected string _cardIcon = "fas fa-star";
        public string cardIcon
        {
            get { return _cardIcon; }
            set { _cardIcon = value; }
        }

        protected string _cardAccentStyle = "purple";
        public string cardAccentStyle
        {
            get { return _cardAccentStyle; }
            set { _cardAccentStyle = value; }
        }

        protected bool _useBackground = true;
        public bool useBackground
        {
            get { return _useBackground; }
            set { _useBackground = value; }
        }

        protected string _onclick = String.Empty;
        public string onclick
        {
            get { return _onclick; }
            set { _onclick = value; }
        }

        protected override void Render(HtmlTextWriter writer)
        {
            string accentClass = "mba-card-accent-blue";
            string iconClass = "mba-card-icon-blue";
            string cardColor = "#1E55C9";
            string cardBgColor = "rgba(30, 85, 201, 0.08)";

            switch (_cardAccentStyle.ToLower())
            {
                case "blue":
                    accentClass = "mba-card-accent-blue";
                    iconClass = "mba-card-icon-blue";
                    cardColor = "#1E55C9";
                    cardBgColor = "rgba(30, 85, 201, 0.08)";
                    break;
                case "purple":
                    accentClass = "mba-card-accent-purple";
                    iconClass = "mba-card-icon-purple";
                    cardColor = "#520652";
                    cardBgColor = "rgba(82, 6, 82, 0.08)";
                    break;
                case "teal":
                    accentClass = "mba-card-accent-teal";
                    iconClass = "mba-card-icon-teal";
                    cardColor = "#00C5E0";
                    cardBgColor = "rgba(0, 197, 224, 0.08)";
                    break;
                case "green":
                    accentClass = "mba-card-accent-green";
                    iconClass = "mba-card-icon-green";
                    cardColor = "#00D0A0";
                    cardBgColor = "rgba(0, 208, 160, 0.08)";
                    break;
                case "red":
                    accentClass = "mba-card-accent-red";
                    iconClass = "mba-card-icon-red";
                    cardColor = "#FF3B30";
                    cardBgColor = "rgba(255, 59, 48, 0.08)";
                    break;
                case "orange":
                    accentClass = "mba-card-accent-orange";
                    iconClass = "mba-card-icon-orange";
                    cardColor = "#FF9500";
                    cardBgColor = "rgba(255, 149, 0, 0.08)";
                    break;
                case "yellow":
                    accentClass = "mba-card-accent-yellow";
                    iconClass = "mba-card-icon-yellow";
                    cardColor = "#FFCC00";
                    cardBgColor = "rgba(255, 204, 0, 0.08)";
                    break;
                case "beige":
                    accentClass = "mba-card-accent-beige";
                    iconClass = "mba-card-icon-beige";
                    cardColor = "#D2B48C";
                    cardBgColor = "rgba(210, 180, 140, 0.08)";
                    break;
                case "emerald":
                    accentClass = "mba-card-accent-emerald";
                    iconClass = "mba-card-icon-emerald";
                    cardColor = "#046307";
                    cardBgColor = "rgba(4, 99, 7, 0.08)";
                    break;
                default:
                    if (this.style == DataEntryButtonStyle.PRIMARY)
                    {
                        accentClass = "mba-card-accent-purple";
                        iconClass = "mba-card-icon-purple";
                        cardColor = "#520652";
                        cardBgColor = "rgba(82, 6, 82, 0.08)";
                    }
                    else if (this.style == DataEntryButtonStyle.INFO)
                    {
                        accentClass = "mba-card-accent-teal";
                        iconClass = "mba-card-icon-teal";
                        cardColor = "#00C5E0";
                        cardBgColor = "rgba(0, 197, 224, 0.08)";
                    }
                    else if (this.style == DataEntryButtonStyle.SUCCESS)
                    {
                        accentClass = "mba-card-accent-green";
                        iconClass = "mba-card-icon-green";
                        cardColor = "#00D0A0";
                        cardBgColor = "rgba(0, 208, 160, 0.08)";
                    }
                    else
                    {
                        accentClass = "mba-card-accent-custom";
                        iconClass = "mba-card-icon-custom";
                        cardColor = _cardAccentStyle;
                        cardBgColor = "rgba(128, 128, 128, 0.08)";

                        writer.Write("<style>");
                        writer.Write($"#{this.ClientID}_card .mba-card-accent-custom {{ background: {_cardAccentStyle}; }}");
                        writer.Write($"#{this.ClientID}_card .mba-card-icon-custom .mba-card-icon-bg {{ background-color: {_cardAccentStyle}; opacity: 0.15; background-image: radial-gradient(circle at center, rgba(255, 255, 255, 0.9), transparent 70%); }}");
                        writer.Write($"#{this.ClientID}_card .mba-card-icon-custom .mba-card-icon {{ color: {_cardAccentStyle}; }}");
                        if (_useBackground)
                        {
                            writer.Write($"#{this.ClientID}_card {{ background: {cardBgColor}; }}");
                        }
                        writer.Write("</style>");
                    }
                    break;
            }

            writer.Write("<style>");
            if (_useBackground)
            {
                writer.Write($"#{this.ClientID}_card {{ background: {cardBgColor}; }}");
                writer.Write($"#{this.ClientID}_card:hover {{ background: {cardBgColor.Replace("0.08", "0.12")}; }}");
            }
            writer.Write($"#{this.ClientID}_card:hover .mba-card-arrow {{ color: {cardColor}; transform: translateX(3px); }}");
            writer.Write($"#{this.ClientID}_card .mba-card-icon-bg {{ background-image: radial-gradient(circle at center, rgba(255, 255, 255, 0.9), transparent 70%); }}");
            writer.Write("</style>");

            writer.AddAttribute("id", this.ClientID + "_card");
            writer.AddAttribute("class", "mba-action-card");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);

            writer.AddAttribute("class", "mba-card-accent " + accentClass);
            writer.RenderBeginTag(HtmlTextWriterTag.Div);

            writer.AddAttribute("class", "mba-card-accent-pulse");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            writer.RenderEndTag();

            writer.RenderEndTag();

            writer.AddAttribute("class", "mba-card-icon-area");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);

            writer.AddAttribute("class", "mba-card-icon-wrapper " + iconClass);
            writer.RenderBeginTag(HtmlTextWriterTag.Div);

            writer.AddAttribute("class", "mba-card-icon-bg");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            writer.RenderEndTag();

            writer.AddAttribute("class", _cardIcon + " mba-card-icon");
            writer.RenderBeginTag(HtmlTextWriterTag.I);
            writer.RenderEndTag();

            writer.RenderEndTag();

            writer.RenderEndTag();

            writer.AddAttribute("class", "mba-card-content");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);

            writer.AddAttribute("class", "mba-card-text");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            writer.Write(this.label);
            writer.RenderEndTag();

            writer.AddAttribute("class", "mba-card-arrow");
            writer.RenderBeginTag(HtmlTextWriterTag.Div);
            writer.AddAttribute("class", "fas fa-chevron-right");
            writer.RenderBeginTag(HtmlTextWriterTag.I);
            writer.RenderEndTag();
            writer.RenderEndTag();

            writer.RenderEndTag();

            writer.RenderEndTag();

            writer.Write("<script>$(document).ready(function(){");
            writer.Write("$('#" + this.ClientID + "_card').click(function(e){" + _onclick + "});");
            writer.Write("});</script>");
        }
    }
}