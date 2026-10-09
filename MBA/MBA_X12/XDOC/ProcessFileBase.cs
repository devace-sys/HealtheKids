using System;
using System.Text;
using System.Xml;
using System.Linq;
using System.Xml.Linq;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using OopFactory.X12.Parsing;
using OopFactory.X12.Parsing.Model;

namespace MBA.X12.XDOC
{
      
   /// <summary>
   /// Processing status event arguments.
   /// </summary>

   public class ProcessingStatusEventArgs : EventArgs
   {  
      public ProcessingStatusEventArgs (string s)  
      {  
        msg = s;  
      }  
    
      private string msg;  
      public string Message  
      {  
        get { return msg; }  
      }   
    }
  
   /// <summary>
   /// Common base for processing files
   /// </summary>
   /// 
   public abstract class ProcessFileBase
   {
  	  /// <summary>
      /// Lock for parsingStatusEvent delegate access.
      /// https://stackoverflow.com/a/3669588 */
      /// </summary>
    
      private readonly object processingStatusEventLock = new object();

      /// <summary>
      /// Delegate variable backing the ParsingStatusEvent event.
      /// https://stackoverflow.com/a/3669588 */
      /// </summary>
    
      private EventHandler<ProcessingStatusEventArgs> processingStatusEvent;

      /// <summary>
      /// Parsing status message event
      /// https://stackoverflow.com/a/3669588 */
      /// </summary>

      public event EventHandler <ProcessingStatusEventArgs> ProcessingStatusEvent
      {
        add
        {
          lock (this.processingStatusEventLock)
          {
            this.processingStatusEvent += value;
          }
        }
        remove
        {
          lock (this.processingStatusEventLock)
          {
            this.processingStatusEvent -= value;
          }
        }
    }

    /// <summary>
    /// Raises the OnSomeEvent event.
    /// /* https://stackoverflow.com/a/3669588 */
    /// </summary>
    
    public void RaiseProcessingStatusEvent (ProcessingStatusEventArgs eventArgs)
    {
       this.OnProcessingStatusEvent(eventArgs);
    }
    
    public void RaiseProcessingStatusEvent (string message)
    {
      RaiseProcessingStatusEvent(new ProcessingStatusEventArgs(message));
    }
    
    /// <summary>
    /// Raises the SomeEvent event.
    /// </summary>
    /// <param name="e">The event arguments.</param>

    protected virtual void OnProcessingStatusEvent (ProcessingStatusEventArgs e)
    {
        EventHandler<ProcessingStatusEventArgs> handler;

        lock (this.processingStatusEventLock)
        {
            handler = this.processingStatusEvent;
        }

        if (handler != null)
        {
            handler(this, e);
        }
    }

  }

}