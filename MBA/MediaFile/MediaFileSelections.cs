using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.ComponentModel;
using TagLib;
using TagLib.Image;


namespace EAW.MediaFile
{
  
  /***************************************************************************
   * MediaFileSelections */
  /**
   * Media file selections
   *
   ***************************************************************************/

  public class MediaFileSelections:MediaFileItems
  {
    
    #region Contructors

    /*###########################################################################
      #
      # Constructors
      #
      ###########################################################################*/	

    public MediaFileSelections ()
    {
    }

    public MediaFileSelections (string id, string filesroot, string folderptrn, string fileptrn, string filehandler)
    {
      this.ID           = id;
      this._filesRoot   = filesroot;
      this._folder      = folderptrn;  
      this._file        = fileptrn;
      this._fileHandler = filehandler;
    }

    #endregion

    #region Methods
    
    /*###########################################################################
      #
      # Methods
      #
      ###########################################################################*/

    /***************************************************************************
     * MediaFileTraverse */
    /**
     * Recursive folder and file traverse used to generate nested file selections
     *
     * @param    path         Physical path to start at
     * @param    folderptrn   Folder pattern to use (default *.*)
     * @param    fileptrn     File pattern to use
     * @param    depth        Current depth 
     * @param    foldercount  Folder count
     * @param    filecount    File count
     * @param    writer       HtmlTextWriter
     ***************************************************************************/
		
    protected void MediaFileTraverse (string path, 
                                      string folderptrn,
                                      string fileptrn, 
                                      int depth, 
                                      ref int foldercount,
                                      ref int filecount, 
                                      ref HtmlTextWriter writer)
    {
      /*============================================================
       * Get list of files
       *============================================================*/	

      string[] files = null;

      try
      {
        files = Directory.GetFiles (path, fileptrn);
      }
      catch
      {
        files = null;
      }
		    
      /*============================================================
       * If we have files create list of selections
       *============================================================*/	
			
      if ((files != null) && (files.Length > 0))
      {
        
        /*============================================================
         * Render selections container
         *============================================================*/

        writer.Write (@"<ul class=""{0}"">"
                      , MediaFileCommon.CSS_SELECTIONS
                      );
    
        /*============================================================
         * Render selections
         *============================================================*/
           
        int _selcount = 0;

        foreach (string f in files)
        {

          /*============================================================
           * Get info about file
           *============================================================*/
          
          FileInfo fi = new FileInfo (f);

          /*============================================================
           * See if it is hidden
           *============================================================*/

          bool _isHidden = (((fi.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden));

          /*============================================================
           * If the file is not hidden 
           *============================================================*/

	      if (!_isHidden)
          { 
            
            /*============================================================
             * Create selection
             *============================================================*/

            MediaFileSelection mfs = new MediaFileSelection (this.ID, 
                                                             filecount, 
                                                             _selcount, 
                                                             this._filesRoot, 
                                                             f, 
                                                             this._fileHandler,
                                                             "color:blue;");

            
            /*============================================================
             * If the file is supported
             *============================================================*/		  

            if (mfs.mfi.fileSupported)
            {
              mfs.RenderControl(writer);
             _selcount++;
		     filecount++;
			}
                   
               
          } // Not hidden
	    } // Files
	    
        writer.Write(@"</ul>");
                
      }

      /*============================================================
       * Get list of folders
       *============================================================*/	

      string[] dirs = null;

      try
      {
        dirs = Directory.GetDirectories (path, folderptrn);
      }
      catch
      {
        dirs = null;
      }

      /*============================================================
       * If we have folders create a folder container
       *============================================================*/	

      if ((dirs != null) && (dirs.Length > 0))
      {
        
        foreach (string d in dirs)
        {
          /*============================================================
           * Get info about directory
           *============================================================*/

          DirectoryInfo di = new DirectoryInfo (d);
				
          /*============================================================
           * See if it is hidden
           *============================================================*/

          bool _isHidden = ((di.Attributes & FileAttributes.Hidden) == FileAttributes.Hidden);
					
          /*============================================================
           * If it is not hidden
           *============================================================*/

          if (!_isHidden)
          {     
            
            /*============================================================
             * Update our counts
             *============================================================*/

		    foldercount++;
       
            /*============================================================
             * Render folder container
             *============================================================*/

            writer.Write (@"<div class=""{0} depth-{1}"">"
                          , MediaFileCommon.CSS_FOLDER_CONTAINER
                          , depth);

            /*============================================================
             * Render folder header
             *============================================================*/

            
            writer.Write (@"<h3 class=""{0} depth-{1}"">{2}</h3>"
                          , MediaFileCommon.CSS_FOLDER_HEADER
                          , depth
                          , di.Name);

            /*============================================================
             * Render folder content
             *============================================================*/

            writer.Write (@"<div class=""{0} depth-{1}"">"
                          , MediaFileCommon.CSS_FOLDER_CONTENT
                          , depth);                    

            depth++;

            MediaFileTraverse (d, 
                               folderptrn, 
                               fileptrn, 
                               depth, 
                               ref foldercount, 
                               ref filecount, 
                               ref writer);
            depth--;
            
            writer.Write (@"</div>"); // Content
            writer.Write (@"</div>"); // Container

          }
        }
      }
    }

    /***************************************************************************
     * CreateFolderFileList */
    /**
     * Starts process of rendering folder and file list
     *
     * @param    writer     HtmlTextWriter
     ***************************************************************************/

    protected void CreateFolderFileList (ref HtmlTextWriter writer)
    {

      int depth       = 0;
      int foldercount = 0;
      int filecount   = 0;
         
      writer.Write (@"<div id=""{0}"" class=""{1}"">"
                    , this.ID
                    , MediaFileCommon.CSS_CTRL_CONTAINER);  
      
      MediaFileTraverse (  _filesRoot
                         , _folder
                         , _file 
                         , depth
                         , ref foldercount
                         , ref filecount
                         , ref writer);

      writer.Write (@"</div>");
    }

    /***************************************************************************
     * Render */
    /**
     * Renders control
     *
     * @param    writer     HtmlTextWriter
     ***************************************************************************/

    protected override void Render (HtmlTextWriter writer)
    {            
      if (String.IsNullOrEmpty (_folder)) _folder = "*.*";
      if (String.IsNullOrEmpty (_file))   _file   = "*.*";  
  
      CreateFolderFileList (ref writer);  
  
      base.Render(writer);
    }

    #endregion
  }
}

