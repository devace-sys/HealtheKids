using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.ComponentModel;
using System.Windows.Forms;
using System.Diagnostics;
using wf = System.Windows.Forms;
using MBA;

namespace MBA
{     
  
  /***************************************************************************
   * ControlOperation */
  /**
   * This is for Windows control operations
   ***************************************************************************/   

  public delegate void ControlOperation (Control c);
  public delegate void BackgroundWork   ();
  
  /***************************************************************************
   * WinFormsApplication */
  /**
   * Base class for windows forms applications
   ***************************************************************************/ 
  
  public abstract class WinFormsApplication:WindowsApplication
  {        
    protected static wf.Form FormWait;
   
    protected static void OnWaitComplete (object sender, EventArgs e)
    {
      Application.Idle -= OnWaitComplete;
      FormWait.Close();
    }
    
    /*************************************************************************
     * ShowWaitForm */
    /**
     * Show a please wait form
     ***************************************************************************/ 

    public static void ShowWaitForm ()
    {
      ShowWaitForm(null);
    }
    
    public static void ShowWaitForm (string message)
    {
      // Based on code from http://stackoverflow.com/a/9072956
      // don't display more than one wait form at a time
      
      if (FormWait != null && ! FormWait.IsDisposed) return;

      string WaitMessage = "";
     
      if (String.IsNullOrEmpty(message)) 
        WaitMessage = "Please wait"; 
      else
        WaitMessage = message;
                
      FormWait                   = new wf.Form();
      FormWait.TopMost           = true;
      FormWait.Width             = 300;
      FormWait.Height            = 200;
      FormWait.FormBorderStyle   = wf.FormBorderStyle.FixedSingle;
      FormWait.ControlBox        = false;
      FormWait.StartPosition     = wf.FormStartPosition.CenterScreen;
      FormWait.TopMost           = true;
      FormWait.ShowInTaskbar     = false;
      
      wf.Label LabelWaitMessage  = new wf.Label();
      LabelWaitMessage.Text      = WaitMessage;
      LabelWaitMessage.Dock      = wf.DockStyle.Fill;
      LabelWaitMessage.Width     = 200;
      LabelWaitMessage.Height    = 100;
      LabelWaitMessage.TextAlign = ContentAlignment.MiddleCenter;

      FormWait.Controls.Add(LabelWaitMessage);

      FormWait.Show();
      FormWait.Refresh();

      // force the wait window to display for at least 700ms so it doesn't just flash on the screen
        
      System.Threading.Thread.Sleep(700);         
      Application.Idle += OnWaitComplete;
    }
    
   /*************************************************************************
     * GetUserStatusLabelText */
    /**
     * Get text for user status label
     ***************************************************************************/       
   
    public static string GetUserStatusLabelText ()
    {
      string statusLabel = dbConnInfoSummary               + " | " + 
                           MBA.Machine.GetMachineName()    + " | " +
                           networkUserName                 + " | " + 
                           uInfo.userRole;
      return statusLabel;     
    }
    
    /*************************************************************************
     * DisplayNotice */
    /**
     * Displays a notice in a message box
     ***************************************************************************/       
    
     public static void DisplayNotice (int severity, string message)
     {
       
       MessageBoxIcon icon = MessageBoxIcon.None;
       
       if      (severity == Return.RET_SUCCESS)  icon = MessageBoxIcon.Asterisk;
       else if (severity == Return.RET_INFO)     icon = MessageBoxIcon.Information;
       else if (severity == Return.RET_WARNING)  icon = MessageBoxIcon.Exclamation;
       else if (severity == Return.RET_CRITICAL) icon = MessageBoxIcon.Error;
       else if (severity == Return.RET_FATAL)    icon = MessageBoxIcon.Stop;
       else                                      icon = MessageBoxIcon.Warning;
                    
       wf.MessageBox.Show(message, appName, MessageBoxButtons.OK, icon);                     
     
     }
    
    /***************************************************************************
     * ControlWalker */
    /**
     * For walking control collections
     ***************************************************************************/  
    
    public static void ControlWalker(Control control, ControlOperation op)
    {
      op(control);

      if (control.HasChildren)
        foreach (Control c in control.Controls)
          ControlWalker(c,op);
      
    }
    
    /***************************************************************************
     * OpenFolderOrFile */
    /**
     * Opens folder or file in new window
     ***************************************************************************/      
    
    public static bool OpenFolderOrFile (string path)
    {
      Process p = null;
      return OpenFolderOrFile(path,out p);      
    }
    
    public static bool OpenFolderOrFile (string path, out Process pOut)
    {
      
      Process p     = null;
      bool    state = false;

      if (String.IsNullOrEmpty(path))
      {
        pOut = p;
        return state;
      }

      try
      {         
        p = System.Diagnostics.Process.Start(path);        
        state = true;
      }
      catch (Exception e)
      {
        p     = null;
        state = false;        
        DisplayNotice(Return.RET_WARNING,e.Message);               
      }
      
      pOut = p;
      return state;      
    }
     
    /***************************************************************************
     * enter */
    /**
     * Entry point for Windows Forms applications
     ***************************************************************************/                      
    
     public static void enter (string appname,
                               string apptitle,
                               string version, 
                               ref string[] args,
                               ref GenericCallBack main,
                               wf.Form mainform)
     {
       enter(appname, apptitle, version, ref args, false, ref main, mainform);
     }
     
     public static void enter (string appname,
                               string apptitle,
                               string version, 
                               ref string[] args,
                               bool batchapp,
                               ref GenericCallBack main,
                               wf.Form mainform)
     {
       
       GenericCallBack start = delegate()
       {         
                            
        /*----------------------------
         * Set mainform title to 
         * our app name
         *----------------------------*/
         
         mainform.Text = appName;

        /*----------------------------
         * Reset colors to fit our 
         * color standard
         *----------------------------*/

        /* mainform.BackColor = Color.FromArgb(126,188,66);
         
         ControlOperation op = delegate (Control c){
           
           Type ct = c.GetType();
           
           if      (ct == typeof(wf.Form))                 c.BackColor = Color.FromArgb (126, 188, 66);
           else if (ct == typeof(wf.TableLayoutPanel))     c.BackColor = Color.FromArgb (238, 238, 238);
           else if (ct == typeof(wf.FlowLayoutPanel))      c.BackColor = Color.FromArgb (238, 238, 238);
           else if (ct == typeof(wf.Panel))                c.BackColor = Color.FromArgb (238, 238, 238);
           else if (ct == typeof(wf.ListBox))              c.BackColor = Color.FromArgb (238, 238, 238);
           else if (ct == typeof(wf.TextBox))              c.BackColor = Color.FromArgb (238, 238, 238);
           else if (ct == typeof(wf.Label))                c.BackColor = Color.FromArgb (238, 238, 238);           
           else if (ct == typeof(wf.DateTimePicker))       c.BackColor = Color.FromArgb (238, 238, 238);
           else if (ct == typeof(wf.Button))               c.BackColor = Color.FromArgb (238, 238, 238);
           else if (ct == typeof(wf.ToolStrip))            c.BackColor = Color.FromArgb (208, 208, 208);
           else if (ct == typeof(wf.MenuStrip))            c.BackColor = Color.FromArgb (208, 208, 208);
           else if (ct == typeof(wf.StatusStrip))          c.BackColor = Color.FromArgb (208, 208, 208);
           else if (ct == typeof(wf.ToolStripProgressBar)) c.BackColor = Color.FromArgb (208, 208, 208);
           else if (ct == typeof(wf.ToolStripStatusLabel)) c.BackColor = Color.FromArgb (208, 208, 208);
           else if (ct == typeof(wf.SplitContainer))       c.BackColor = Color.FromArgb (126, 188, 66);           
           else if (ct == typeof(wf.TreeView))             c.BackColor = Color.FromArgb (126, 188, 66);
           else if (ct == typeof(wf.TreeNode))             c.BackColor = Color.FromArgb (126, 188, 66);          
           else                                            c.BackColor = Color.FromArgb (126, 188, 66); 

         };
         
         ControlWalker(mainform , op);
         */
       };
       
       GenericCallBack end = delegate()
       {         
       };
       
       NoticeHandler noticehdlr = delegate(int severity, string message)
       {
         DisplayNotice(severity, message);         
       };
                            
       ExceptionCallBack except = delegate(Exception e)
       {         
         string msg = e.Message + "\n" + e.StackTrace;
         DisplayNotice(Return.RET_ERROR, msg);
       };

       GenericCallBack final = delegate()
       {
       };
              
       /*----------------------------
        * Start the app
        *----------------------------*/

       WindowsApplication.enter(appname,
                                apptitle,
                                version,                                
                                ref args,
                                batchapp,
                                ref start,
                                ref main,
                                ref end,
                                ref noticehdlr,
                                ref except,
                                ref final);
     }                              
  }
}
