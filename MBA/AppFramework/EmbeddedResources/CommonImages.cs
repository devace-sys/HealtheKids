using System;
using System.Drawing;
using System.ComponentModel;
using System.IO;
using System.Reflection;
using MBA;

namespace MBA.EmbeddedResources
{

  /***************************************************************************
   * CommonImages */
  /**
   * Common image files  
   * All of the images are embedded resources in the MBA.dll 
   ***************************************************************************/   
   
  public class CommonImages
  {          
        
    public const string RESOURCE_NAMESPACE       = "MBA.EmbeddedResources.Images";    

    public const string IMAGE_NAME_CRITICAL      = "critical.png";
    public const string IMAGE_NAME_ERROR         = "error.png";
    public const string IMAGE_NAME_EXIT          = "exit.png";
    public const string IMAGE_NAME_FOLDER_CLOSE  = "folder-close.png";
    public const string IMAGE_NAME_FOLDER_OPEN   = "folder-open.png";
    public const string IMAGE_NAME_INFO          = "info.png";
    public const string IMAGE_NAME_PROCEED       = "proceed.png";
    public const string IMAGE_NAME_REFRESH       = "refresh.png";        
    public const string IMAGE_NAME_START         = "start.png";
    public const string IMAGE_NAME_SUCCESS       = "success.png";
    public const string IMAGE_NAME_UNKNOWN       = "unknown.png";
    public const string IMAGE_NAME_WARNING       = "warning.png";
    public const string IMAGE_NAME_LOGO          = "logo.jpg";
    public const string IMAGE_NAME_LOGO_SPEDCARE = "spedcare-logo.png";

    //public const string IMAGE_NAME_BLOCKTOWER_BG = "blocktower-bg.png";

    public const string IMAGE_NAME_LIST_ITEM_DOCTOR_SPEAKING = "doctor-speaking-list-item.png";
    public const string IMAGE_NAME_PCA_LOGO_W_PENCIL         = "practi-Cal_logo_pencil.png";

    /***************************************************************************
     * GetImage */
        /**
         * Retrieve the image
         ***************************************************************************/

   public static Stream GetStream(string filename) { 
      if (String.IsNullOrEmpty(filename)) return null;
      
      string rs             = String.Format("{0}.{1}",RESOURCE_NAMESPACE,filename);
      Assembly assembly     = Assembly.GetExecutingAssembly();      
      Stream   stream  = assembly.GetManifestResourceStream(rs);     
      return stream;
  }    

    public static Image GetImage (string imagefile)
    {
      if (String.IsNullOrEmpty(imagefile)) return null;
          
      Stream   imageStream  = GetStream(imagefile);
      Image    image        = Image.FromStream(imageStream);    
      return image;
    }
    
    /***************************************************************************
     * GetReturnStateImage */
    /**
     * Retrieve the image associated with a returnState
     ***************************************************************************/   

    public static Image GetReturnStateImage (long returnState)
    {
      if      (returnState == Return.RET_SUCCESS)         return GetImage(IMAGE_NAME_SUCCESS);
      else if (returnState == Return.RET_INFO)            return GetImage(IMAGE_NAME_INFO);
      else if (returnState == Return.RET_WARNING)         return GetImage(IMAGE_NAME_WARNING);
      else if (returnState == Return.RET_CRITICAL)        return GetImage(IMAGE_NAME_CRITICAL);
      else if (returnState == Return.RET_ERROR)           return GetImage(IMAGE_NAME_ERROR);
      else if (returnState == Return.RET_ABORT_OR_CANCEL) return GetImage(IMAGE_NAME_EXIT);   
      else if (returnState == Return.RET_FATAL)           return GetImage(IMAGE_NAME_ERROR);

      else                                                return GetImage(IMAGE_NAME_UNKNOWN);         
    }
  
  }
}
