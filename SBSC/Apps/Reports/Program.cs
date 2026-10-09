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

namespace Spedmon
{
  
  /***************************************************************************
   * ReportsApp */
  /**
   * A windows forms application for generating bulk reports for clients.
   ***************************************************************************/   

  partial class ReportsApp:WinFormsApplication
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
      
        
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);      
    
        /*----------------------------
         * Create instance of our
         * main form (Form1)
         *----------------------------*/

        wf.Form mainform = new ReportsAppFormMain();
      
        /*----------------------------
         * Define our main delegate
         *----------------------------*/
      
        GenericCallBack main = delegate
        {        
          clients = getClients();      // Fetch client list
          Application.Run(mainform);   // Start our main form        
        };
      
        /*----------------------------
         * Start our application
         *----------------------------*/       

        string appname = Spedmon.Constants.APP_NAME;
        string appvers = Spedmon.Constants.APP_VERSION;

        enter(appname, "Reports",  appvers, ref args, ref main, mainform);
      }
      catch (Exception e)
      {
        WinFormsApplication.DisplayNotice(Return.RET_FATAL, e.Message);
      }      
    }
  }
}
