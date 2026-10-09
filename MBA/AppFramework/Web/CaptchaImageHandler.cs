 using System.Drawing;
 using System.Drawing.Imaging;
 using System.Web;
 using System.Web.SessionState;
    
namespace MBA
{
  
  /***************************************************************************
   * CaptchaImaageHandler */
  /**
   * Image handler for CaptchaImage class
   * Based on code courtesey of Mateusz Chodyła
   * 
   ****************************************************************************/
   
    public class CaptchaImageHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable
        {
            get { return true; }
        }

        public void ProcessRequest(HttpContext context)
        {
            System.Web.HttpApplication application = context.ApplicationInstance;
            
            string guid = application.Request.QueryString[CaptchaImage.PARM_CAPTCHA_REQUEST_ID];

            if (string.IsNullOrEmpty(guid) == false)
            {
                CaptchaImage captchaImage;
                captchaImage = (CaptchaImage)HttpRuntime.Cache.Get(guid);
                                
                if (captchaImage != null)
                {                
                  Bitmap bitmap = captchaImage.GenerateImage();
                  bitmap.Save(application.Context.Response.OutputStream, ImageFormat.Jpeg);
                  bitmap.Dispose();
                  application.Response.ContentType = "image/jpeg";
                  application.Response.StatusCode = 200;
                }
                else
                {
                }
            }
            else
            {
                application.Response.StatusCode = 404;
            }

            context.ApplicationInstance.CompleteRequest();
        }
    }
}