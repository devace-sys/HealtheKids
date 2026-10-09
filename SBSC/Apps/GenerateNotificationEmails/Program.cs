using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Web;
using Spedmon;
using MBA;
using MBA.Reporting;

namespace Spedmon
{
  
  /***************************************************************************
   * GenerateNotificationEmailsApp */
  /**
   * Application class
   ***************************************************************************/   

  class GenerateNotificationEmailsApp:ProcessEmailNotifications
  {

        
    /***************************************************************************
     * Main */
    /**
     * Entry point
     ***************************************************************************/                             

    static void Main(string[] args)
    {
       
        ProcessEmailNotifications.StartProcessingEmailNotifications(args);
     
       /*============================================================
        * Exit
        *============================================================*/
      
        exit();                
                  
    }
  }
}
