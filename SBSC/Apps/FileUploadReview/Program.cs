using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using MBA;
using Spedmon;
using System.IO;
using System.Threading;
using wf = System.Windows.Forms;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Configuration;
using FileUploadReview;

namespace Spedmon
{
  
  /***************************************************************************
   * FileUploadReviewApp */
  /**
   * A windows forms application for browsing and reviewing uploaded files
   ***************************************************************************/   

  partial class FileUploadReviewApp:WinFormsApplication
  {
              
    
    /***************************************************************************
     * Main */
    /**
     * Our entry point for this application from the operating system.
     ***************************************************************************/   
        
    [STAThread]
    
    static void Main(string[] args)
    {
      
      try
      {
      
        /*----------------------------
         * Set application wide 
         * settings
         *----------------------------*/
      
        //AppConfigExists();          
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);      
    
        /*----------------------------
         * Create instance of our
         * main form (Form1)
         *----------------------------*/

        FileUploadReviewAppFormMain mainform = new FileUploadReviewAppFormMain();
        
        /*----------------------------
         * Define our main delegate
         *----------------------------*/
      
        GenericCallBack main = delegate
        {        
          Application.Run(mainform);   // Start our main form        
        };
      
        /*----------------------------
         * Start our application
         *----------------------------*/       

         string appname = Spedmon.Constants.APP_NAME;   
         enter(appname, "File Upload Review", Spedmon.Constants.APP_VERSION, ref args, ref main, mainform);
      }
      catch (Exception e)
      {
        WinFormsApplication.DisplayNotice(Return.RET_FATAL, e.Message);
      }      
    }
  }
}