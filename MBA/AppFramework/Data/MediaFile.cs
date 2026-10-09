using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace MBA
{
 
  /***************************************************************************
   * MediaFileClass */
  /**
   * Everything in a file system is a file.  What basic form of file is this?
   * 
   ****************************************************************************/
  
  public enum MediaFileForm
  {
    UNSUPPORTED   = 0,
    FOLDER        = 1,
    FILE          = 2
  }
  
  /***************************************************************************
   * MediaFileBasicTypee */
  /**
   * What basic type of file is this
   * 
   ****************************************************************************/
  
  public enum MediaFileBasicType
  {
    UNSUPPORTED   = 1,
    FOLDER        = 2,
    IMAGE         = 3,
    VIDEO         = 4,
    AUDIO         = 5,
    DOCUMENT      = 6,
    MARKUP        = 7,
    TEXT          = 8,
    CONTAINER     = 9,
    APPLICATION   = 10
  }
 
   
  /**************************************************************************
   * MediaFile */
  /**
   * File data for a media file
   ****************************************************************************/

  public class MediaFile
  {
     
     public const string ICON_FOLDER   = "ui-icon-folder-collapsed";
     public const string ICON_FILE     = "ui-icon-disk";

     public const string ICON_IMAGE    = "ui_icon_image";
     public const string ICON_VIDEO    = "ui_icon_video";
     public const string ICON_AUDIO    = "ui-icon-volume-off";
     public const string ICON_DOCUMENT = "ui-icon-document";
     
     
     public static readonly Dictionary <string, MediaFileBasicType> ExtensionBasicTypeMap = new Dictionary <string, MediaFileBasicType>
     {
       // Images 
       
       {".png",  MediaFileBasicType.IMAGE},
       {".gif",  MediaFileBasicType.IMAGE},
       {".jpg",  MediaFileBasicType.IMAGE},
       {".jpeg", MediaFileBasicType.IMAGE},
       {".jpe",  MediaFileBasicType.IMAGE},
       {".bmp",  MediaFileBasicType.IMAGE},
       {".tif",  MediaFileBasicType.IMAGE},
       {".tiff", MediaFileBasicType.IMAGE},

       // Documents
       
       {".pdf",  MediaFileBasicType.DOCUMENT},
       
       // Markup
       
       {".htm",  MediaFileBasicType.MARKUP},
       {".html", MediaFileBasicType.MARKUP},
       {".svg",  MediaFileBasicType.MARKUP},
       
       // Text
       
       {".txt",  MediaFileBasicType.TEXT},
       
       // Audio
       
       {".mp3",  MediaFileBasicType.AUDIO},
       {".wma",  MediaFileBasicType.AUDIO},
       {".aac",  MediaFileBasicType.AUDIO},
       
       // Video
       
       {".mp4",  MediaFileBasicType.VIDEO},
       {".flv",  MediaFileBasicType.VIDEO},
       
       // Container/archive
       
       {".zip",  MediaFileBasicType.CONTAINER}
       
     };
     
    public static MediaFileBasicType ExtensionToBasicMediaType (string extension)
    {
      if (Util.IsNullOrEmpty(extension)) 
        return MediaFileBasicType.UNSUPPORTED;
            
      string key = extension.Trim().ToLower();
      
      if (ExtensionBasicTypeMap.ContainsKey(key))
        return ExtensionBasicTypeMap[key];
        
      return MediaFileBasicType.UNSUPPORTED;
    }
    
    public static string BasicMediaTypeToIcon (MediaFileForm ff, MediaFileBasicType bt)
    {
      if (ff == MediaFileForm.FOLDER) return ICON_FOLDER;
      
      if (ff == MediaFileForm.FILE)
      {
        if (bt == MediaFileBasicType.DOCUMENT) return ICON_DOCUMENT;
        if (bt == MediaFileBasicType.IMAGE)    return ICON_IMAGE;
        if (bt == MediaFileBasicType.AUDIO)    return ICON_AUDIO;
        if (bt == MediaFileBasicType.VIDEO)    return ICON_VIDEO;
      }     
      return ICON_FILE;
    }
  
     DirectoryInfo           _parent_di     = null;
     DirectoryInfo           _di            = null;
     FileInfo                _fi            = null;
     string                  _label         = "";
     bool                    _hidden        = false;
     int                     _depth         = 0;
     MediaFileForm           _fileClass     = MediaFileForm.UNSUPPORTED;
     MediaFileBasicType      _fileBasicType = MediaFileBasicType.UNSUPPORTED;
     string                  _mimeType      = MIMEAssistant.UNKNOWN_MIME_TYPE;
     string                  _iconClass     = ICON_FILE;
     
     public DirectoryInfo           parent_di      {get {return _parent_di;}}
     public DirectoryInfo           di             {get {return _di;}}
     public FileInfo                fi             {get {return _fi;}}
     public string                  label          {get {return _label;}}
     public bool                    hidden         {get {return _hidden;}}
     public MediaFileForm           fileClass      {get {return _fileClass;}}
     public int                     depth          {get {return _depth;}}
     public string                  mimeType       {get {return _mimeType;}}
     
     public MediaFile (DirectoryInfo di, int depth)
     {
       _parent_di          = di.Parent;
       _di                 = di;
       _fi                 = null;
       this._label         = Path.GetFileNameWithoutExtension(_di.Name);
       this._depth         = depth;       
       this._fileClass     = MediaFileForm.FOLDER;
       this._fileBasicType = MediaFileBasicType.FOLDER; 
       this._iconClass     = BasicMediaTypeToIcon(this._fileClass, this._fileBasicType);
     }
          
     public MediaFile(FileInfo fi, int depth)
     {
       this._parent_di     = fi.Directory;
       this._fi            = fi;
       this._di            = null;       
       this._label         = Path.GetFileNameWithoutExtension(_fi.Name);
       this._depth         = depth;
       this._fileClass     = MediaFileForm.FILE;
       this._fileBasicType = ExtensionToBasicMediaType(fi.Extension);
       this._iconClass     = BasicMediaTypeToIcon(this._fileClass, this._fileBasicType);       
       this._iconClass     = ICON_FILE;
     }
     
     public bool isHidden()
     {
       bool hidden = false;
       return hidden;
       
       /*if (this.fileClass == MediaFileForm.FILE)
         if ((this._fi.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden) hidden = true;
                
       DirectoryInfo pdi = this.parent_di;
       
       
       while (hidden == false)
       {         
         if ((pdi.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden) hidden = true;                  
         pdi = this._parent_di;
       }
      
       return hidden;
       */
     }
     
     public bool canDisplay ()
     {
       if (isHidden()) return false;            
       return true;
       // Folder is hidden?
       //if ((di.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden)        _hidden = true;
       
       // Parent is hidden?  Yes then file is considered hidden
       // TODO: Recurse up parents until        
       //if ((di.Parent.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden) _hidden = true;
       //_canDisplay = !(_hidden) && !(_fileClass == MediaFileForm.UNSUPPORTED) && !(_fileBasicType == MediaFileBasicType.UNSUPPORTED);
     }          
  }
}

