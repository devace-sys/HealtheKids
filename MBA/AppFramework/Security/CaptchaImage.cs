using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * CaptchaImaage */
  /**
   * CAPTCHA image generator
   * Based on code courtesey of Mateusz Chodyła
   * 
   ****************************************************************************/

    /// <summary>
    /// Represents CAPTCHA image.
    /// </summary>
    [Serializable]
    public class CaptchaImage
    {        

        public const string CAPTCHA_URL_BASE        = "captcha.ashx";
        public const string PARM_CAPTCHA_REQUEST_ID = "guid";
        
        public static string generateImgUrl(string request_id)
        {
          string url = MBA.HttpApplication.createLink(CAPTCHA_URL_BASE,new NameValue(PARM_CAPTCHA_REQUEST_ID,request_id));
          return url;
        }
        
        
        #region Fields

        private Random random;

        private FontWarpFactor fontWarp; // = change shape    
        private BackgroundNoiseLevel backgroundNoise;
        private LineNoiseLevel lineNoise;
        private int width;
        private int height;
                
        private string fontWhitelist;        
        private int randomTextLength;
        private string randomTextChars;
        private string fontFamilyName;
        private string randomText;

        private DateTime generatedAt;
        private string guid;

        #endregion

        /// <summary>
        /// Initializes a new instance of the CaptchaImage class. Sets all properties and fields to defaults.
        /// </summary>
        public CaptchaImage()
        {
            this.random = new Random();
            
            this.FontWarp = FontWarpFactor.Low;
            this.BackgroundNoise = BackgroundNoiseLevel.Low;
            this.LineNoise = LineNoiseLevel.None;            
            this.Width = 180;
            this.Height = 50;

            //// a list of known good fonts in on both Windows XP and Windows Server 2003
            this.FontWhitelist = "arial;arial black;comic sans ms;courier new;estrangelo edessa;franklin gothic medium;" +
                "georgia;lucida console;lucida sans unicode;mangal;microsoft sans serif;palatino linotype;" +
                "sylfaen;tahoma;times new roman;trebuchet ms;verdana";
            this.randomTextLength = 5; // do not use property - setter generates random text
            this.randomTextChars = "ACDEFGHJKLMNPQRTUVWXY34679"; // excluded: 1 - l, B - 8, Z - 2, S - 5; do not use property - setter generates random text
            this.fontFamilyName = string.Empty; // do not use property - it will search for valid font name
            this.randomText = this.GenerateRandomText();
            
            this.generatedAt = DateTime.Now;
            this.guid = Guid.NewGuid().ToString();
        }

        #region Enums

        /// <summary>
        /// Amount of random font warping to apply to rendered text.
        /// </summary>
        public enum FontWarpFactor
        {
            None, Low, Medium, High, Extreme
        }

        /// <summary>
        /// Amount of background noise to add to rendered image.
        /// </summary>
        public enum BackgroundNoiseLevel
        {
            None, Low, Medium, High, Extreme
        }

        /// <summary>
        /// Amount of curved line noise to add to rendered image.
        /// </summary>
        public enum LineNoiseLevel
        {
            None, Low, Medium, High, Extreme
        }

        #endregion

        #region Properties

        /// <summary>
        /// Gets a GUID that uniquely identifies this CAPTCHA.
        /// </summary>
        public string UniqueId
        {
            get
            {
                return this.guid;
            }
        }

        /// <summary>
        /// Gets the date and time this image was last rendered. 
        /// </summary>
        public DateTime RenderedAt
        {
            get
            {
                return this.generatedAt;
            }
        }

        /// <summary>
        /// Gets or sets font family to use when drawing the CAPTCHA text. If no font is provided, a random font will be chosen from the font whitelist for each character.
        /// </summary>
        public string FontFamilyName
        {
            get
            {
                return this.fontFamilyName;
            }

            set
            {
                Font font = new Font(value, 12); // checking existance - if the familyName parameter specifies a font that is not installed on the machine running the application or is not supported, Microsoft Sans Serif will be substituted.
                font.Dispose();

                if (font.Name == FontFamily.GenericSansSerif.Name)
                {
                    this.fontFamilyName = font.Name;
                }
                else
                {
                    this.fontFamilyName = value;
                }
            }
        }

        /// <summary>
        /// Gets or sets amount of random warping to apply to the CAPTCHA text. 
        /// </summary>
        public FontWarpFactor FontWarp
        {
            get
            {
                return this.fontWarp;
            }

            set
            {
                this.fontWarp = value;
            }
        }

        /// <summary>
        /// Gets or sets amount of background noise to apply to the CAPTCHA image. 
        /// </summary>
        public BackgroundNoiseLevel BackgroundNoise
        {
            get
            {
                return this.backgroundNoise;
            }

            set
            {
                this.backgroundNoise = value;
            }
        }

        /// <summary>
        /// Gets or sets amount of curved line noise to add to the CAPTCHA image.
        /// </summary>
        public LineNoiseLevel LineNoise
        {
            get
            {
                return this.lineNoise;
            }

            set
            {
                this.lineNoise = value;
            }
        }

        /// <summary>
        /// Gets or sets string of valid characters to use in the CAPTCHA text. A random character will be selected from this string for each character. Setter also generates random text.
        /// </summary>
        public string TextChars
        {
            get
            {
                return this.randomTextChars;
            }

            set
            {
                this.randomTextChars = value;
                this.randomText = this.GenerateRandomText();
            }
        }

        /// <summary>
        /// Gets or sets number of characters to use in the CAPTCHA text. Setter also generates random text.
        /// </summary>
        public int TextLength
        {
            get
            {
                return this.randomTextLength;
            }

            set
            {
                this.randomTextLength = value;
                this.randomText = this.GenerateRandomText();
            }
        }

        /// <summary>
        /// Gets the randomly generated CAPTCHA text. 
        /// </summary>
        public string Text
        {
            get
            {
                return this.randomText;
            }
        }

        /// <summary>
        /// Gets or sets width of CAPTCHA image to generate, in pixels. 
        /// </summary>
        public int Width
        {
            get
            {
                return this.width;
            }

            set
            {
                if (value <= 60)
                {
                    throw new ArgumentOutOfRangeException("Width", value, "width must be greater than 60.");
                }
                else
                {
                    this.width = value;
                }
            }
        }

        /// <summary>
        /// Gets or sets height of CAPTCHA image to generate, in pixels.
        /// </summary>
        public int Height
        {
            get
            {
                return this.height;
            }

            set
            {
                if (value <= 30)
                {
                    throw new ArgumentOutOfRangeException("Height", value, "height must be greater than 30.");
                }
                else
                {
                    this.height = value;
                }
            }
        }

        /// <summary>
        /// Gets or sets a semicolon-delimited list of valid fonts to use when no font is provided.
        /// </summary>
        public string FontWhitelist
        {
            get
            {
                return this.fontWhitelist;
            }

            set
            {
                this.fontWhitelist = value;
            }
        }

        #endregion

        /// <summary>
        /// Forces a new CAPTCHA image to be generated using current property value settings.
        /// </summary>
        /// <returns>CAPTCHA image.</returns>
        public Bitmap GenerateImage()
        {
            Font font = null;
            Rectangle rectangle;
            Brush brush = null;

            Bitmap bitmap = null;
            Graphics graphics = null;

            GraphicsPath pathWithChar = null;
            StringFormat stringFormat = null;

            try
            {
                bitmap = new Bitmap(this.Width, this.Height, PixelFormat.Format32bppArgb);
                graphics = Graphics.FromImage(bitmap);
                graphics.SmoothingMode = SmoothingMode.AntiAlias;

                //// fill an empty white rectangle
                rectangle = new Rectangle(0, 0, this.Width, this.Height);
                brush = new SolidBrush(Color.White);
                graphics.FillRectangle(brush, rectangle);

                int charOffset = 0;
                double charWidth = this.Width / this.TextLength;
                Rectangle charRectangle;

                foreach (char c in this.Text.ToCharArray())
                {
                    //// establish font and draw area
                    font = this.GetFont();
                    charRectangle = new Rectangle((int)(charOffset * charWidth), 0, (int)charWidth, this.Height);

                    //// warp the character
                    pathWithChar = new GraphicsPath();

                    stringFormat = new StringFormat();
                    stringFormat.Alignment = StringAlignment.Near;
                    stringFormat.LineAlignment = StringAlignment.Near;

                    pathWithChar.AddString(c.ToString(), font.FontFamily, (int)font.Style, font.Size, charRectangle, stringFormat);

                    this.WarpChar(pathWithChar, charRectangle);

                    //// draw the character
                    brush = new SolidBrush(Color.Black);
                    graphics.FillPath(brush, pathWithChar);

                    charOffset += 1;
                }

                this.AddNoise(graphics, rectangle);
                this.AddLines(graphics, rectangle);
            }
            finally
            {
                if (stringFormat != null)
                {
                    stringFormat.Dispose();
                }

                if (pathWithChar != null)
                {
                    pathWithChar.Dispose();
                }

                if (font != null)
                {
                    font.Dispose();
                }

                if (brush != null)
                {
                    brush.Dispose();
                }
                
                if (graphics != null)
                {
                    graphics.Dispose();
                }
            }

            return bitmap;
        }
        
        /// <summary>
        /// Generates random text for the CAPTCHA.
        /// </summary>
        /// <returns>Random text.</returns>
        private string GenerateRandomText()
        {
            StringBuilder randomTextBuilder = new StringBuilder(this.TextLength);

            for (int i = 0; i < this.TextLength; i++)
            {
                randomTextBuilder.Append(this.TextChars.Substring(this.random.Next(this.TextChars.Length), 1));
            }

            return randomTextBuilder.ToString();
        }

        /// <summary>
        /// Returns a random point within the specified x and y ranges.
        /// </summary>
        /// <param name="xmin">Inclusive lower bound for x.</param>
        /// <param name="xmax">Exclusive upper bound for x.</param>
        /// <param name="ymin">Inclusive lower bound for y.</param>
        /// <param name="ymax">Exclusive upper bound for y.</param>
        /// <returns>Random point.</returns>
        private PointF GenerateRandomPoint(int xmin, int xmax, int ymin, int ymax)
        {
            return new PointF(this.random.Next(xmin, xmax), this.random.Next(ymin, ymax));
        }

        /// <summary>
        /// Returns the CAPTCHA font in an appropriate size. 
        /// </summary>
        /// <returns>CAPTCHA font.</returns>
        private Font GetFont()
        {
            int fontSize;
            string fontName = this.FontFamilyName;

            if (string.IsNullOrEmpty(fontName) == true)
            {
                 string[] fontFamilies = this.FontWhitelist.Split(';');
                 fontName = fontFamilies[this.random.Next(0, fontFamilies.Length)]; // min value - inclusive, max value - exclusive
            }

            switch (this.FontWarp)
            {
                case FontWarpFactor.None:
                    fontSize = (int)(this.Height * 0.7);
                    break;
                case FontWarpFactor.Low:
                    fontSize = (int)(this.Height * 0.8);
                    break;
                case FontWarpFactor.Medium:
                    fontSize = (int)(this.Height * 0.85);
                    break;
                case FontWarpFactor.High:
                    fontSize = (int)(this.Height * 0.9);
                    break;
                case FontWarpFactor.Extreme:
                    fontSize = (int)(this.Height * 0.95);
                    break;
                default:
                    throw new ArgumentException("Unknown FontWarpFactor member", "FontWarp");
            }

            return new Font(fontName, fontSize, FontStyle.Bold);
        }

        /// <summary>
        /// Warp the provided text by a variable amount.
        /// </summary>
        /// <param name="pathWithText">Provided text.</param>
        /// <param name="textRectangle">Text rectangle.</param>
        private void WarpChar(GraphicsPath pathWithText, Rectangle textRectangle)
        {
            float warpDivisor, rangeModifier;

            switch (this.FontWarp)
            {
                case FontWarpFactor.None:
                    return;
                case FontWarpFactor.Low:
                    warpDivisor = 6;
                    rangeModifier = 1;
                    break;
                case FontWarpFactor.Medium:
                    warpDivisor = 5;
                    rangeModifier = 1.3f;
                    break;
                case FontWarpFactor.High:
                    warpDivisor = 4.5f;
                    rangeModifier = 1.4f;
                    break;
                case FontWarpFactor.Extreme:
                    warpDivisor = 4;
                    rangeModifier = 1.5f;
                    break;
                default:
                    throw new ArgumentException("Unknown FontWarpFactor member", "FontWarp");
            }

            RectangleF textRectangleFloat = new RectangleF(textRectangle.Left, textRectangle.Top, textRectangle.Width, textRectangle.Height);

            int heightRatio = Convert.ToInt32(textRectangle.Height / warpDivisor);
            int widthRatio = Convert.ToInt32(textRectangle.Width / warpDivisor);
            
            int leftTextRectangle = textRectangle.Left - (int)(widthRatio * rangeModifier);
            int topTextRectangle = textRectangle.Top - (int)(heightRatio * rangeModifier);
            int widthTextRectangle = textRectangle.Left + textRectangle.Width + (int)(widthRatio * rangeModifier);
            int heightTextRectangle = textRectangle.Top + textRectangle.Height + (int)(heightRatio * rangeModifier);

            if (leftTextRectangle < 0)
            {
                leftTextRectangle = 0;
            }

            if (topTextRectangle < 0)
            {
                topTextRectangle = 0;
            }

            if (widthTextRectangle > this.Width)
            {
                widthTextRectangle = this.Width;
            }

            if (heightTextRectangle > this.Height)
            {
                heightTextRectangle = this.Height;
            }

            PointF leftTop = this.GenerateRandomPoint(leftTextRectangle, leftTextRectangle + widthRatio, topTextRectangle, topTextRectangle + heightRatio);
            PointF rightTop = this.GenerateRandomPoint(widthTextRectangle - widthRatio, widthTextRectangle, topTextRectangle, topTextRectangle + heightRatio);
            PointF leftBottom = this.GenerateRandomPoint(leftTextRectangle, leftTextRectangle + widthRatio, heightTextRectangle - heightRatio, heightTextRectangle);
            PointF rightBottom = this.GenerateRandomPoint(widthTextRectangle - widthRatio, widthTextRectangle, heightTextRectangle - heightRatio, heightTextRectangle);
            PointF[] points = new PointF[] { leftTop, rightTop, leftBottom, rightBottom };
            
            Matrix matrix = new Matrix();
            matrix.Translate(0, 0);
            pathWithText.Warp(points, textRectangleFloat, matrix, WarpMode.Perspective, 0);
            matrix.Dispose();
        }

        /// <summary>
        /// Adds a variable level of graphic noise to the image.
        /// </summary>
        /// <param name="graphics">Drawing surface.</param>
        /// <param name="rectangle">Image rectangle.</param>
        private void AddNoise(Graphics graphics, Rectangle rectangle)
        {
            int density, size;

            switch (this.BackgroundNoise)
            {
                case BackgroundNoiseLevel.None:
                    return;
                case BackgroundNoiseLevel.Low:
                    density = 30;
                    size = 40;
                    break;
                case BackgroundNoiseLevel.Medium:
                    density = 18;
                    size = 40;
                    break;
                case BackgroundNoiseLevel.High:
                    density = 16;
                    size = 39;
                    break;
                case BackgroundNoiseLevel.Extreme:
                    density = 12;
                    size = 38;
                    break;
                default:
                    throw new ArgumentException("Unknown BackgroundNoiseLevel member", "BackgroundNoise");
            }

            SolidBrush brush = new SolidBrush(Color.Black);
            int max = (int)(Math.Max(rectangle.Width, rectangle.Height) / size);

            for (int i = 0; i < (int)((rectangle.Width * rectangle.Height) / density); i++)
            {
                graphics.FillEllipse(brush, this.random.Next(rectangle.Width), this.random.Next(rectangle.Height), this.random.Next(max), this.random.Next(max));
            }

            brush.Dispose();
        }

        /// <summary>
        /// Adds variable level of curved lines to the image.
        /// </summary>
        /// <param name="graphics">Drawing surface.</param>
        /// <param name="rectangle">Image rectangle.</param>
        private void AddLines(Graphics graphics, Rectangle rectangle)
        {
            int pointsCount, lineCount;
            float lineWidth;

            switch (this.LineNoise)
            {
                case LineNoiseLevel.None:
                    return;
                case LineNoiseLevel.Low:
                    pointsCount = 4;
                    lineWidth = (float)(this.Height / 31.25);
                    lineCount = 1;
                    break;
                case LineNoiseLevel.Medium:
                    pointsCount = 5;
                    lineWidth = (float)(this.Height / 27.7777);
                    lineCount = 1;
                    break;
                case LineNoiseLevel.High:
                    pointsCount = 3;
                    lineWidth = (float)(this.Height / 25);
                    lineCount = 2;
                    break;
                case LineNoiseLevel.Extreme:
                    pointsCount = 3;
                    lineWidth = (float)(this.Height / 22.7272);
                    lineCount = 3;
                    break;
                default:
                    throw new ArgumentException("Unknown LineNoiseLevel member", "LineNoise");
            }

            PointF[] points = new PointF[pointsCount];
            Pen pen = new Pen(Color.Black, lineWidth);

            for (int i = 1; i <= lineCount; i++)
            {
                for (int j = 0; j < pointsCount; j++)
                {
                    points[j] = this.GenerateRandomPoint(rectangle.Left, rectangle.Width, rectangle.Top, rectangle.Bottom);
                }

                graphics.DrawCurve(pen, points, 1.75f);
            }

            pen.Dispose();
        }
    }
}