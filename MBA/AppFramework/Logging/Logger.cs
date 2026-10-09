/*******************************************************************************
* $Id: Logger.cs 1806 2009-09-18 17:07:43Z sthames $
*******************************************************************************/
using System;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Web.Mail;

/*------------------------------------------------*/
/* Disable 'obsolete' warning on System.Web.Mail. */
/*------------------------------------------------*/
#pragma warning disable 0618

namespace MBA
  {
  /*****************************************************************************
  * Logger Class */
  /**
  * Superclass for handling logging. A logging level is set to indicate what 
  * messages should be written to the log. All messages logged at or below the 
  * specified level are written to the event log. 
  * <p>
  * The logging levels from lowest to highest are Emerg, Alert, Crit, Err, Warn
  * Notice, Info, Summary, Detail, and Debug.
  * <p>
  * If the current logging level is set to "Notice" and a logSummary is called
  * to log a message, no message will be written.  Calls to logNotice, logWarn, 
  * logErr, logCrit, logAlert, and logEmerg will all write to the log.
  * <p>
  * All logging methods take a message in the form of a string and a set of
  * optional parameters.  The message is built using String.Format and written
  * to the log with the level prepended.  i.e. "Notice: My Message".
  * <p>
  * This class will also email log messages according the the email 
  * configuration.  This feature has a separate log level.  If the email 
  * configuration is not set, no email is sent.
  * <p>
  * Synopsis:
  * <pre>
  * Logger elog = new Logger("MyProcess", "MyLog");
  * elog.setLogLevel(Logger.LogLevel.Notice);
  * elog.logNotice("MyProcess started at {0}!",DateTime.Now);
  * elog.setLogLevel(Logger.LogLevel.Info);
  * elog.logInfo("My Process is Still Running!"); 
  * elog.logNotice("MyProcess ended at {0}!",DateTime.Now); 
  * </pre>
  *****************************************************************************/
  public abstract class Logger : DisposableBase 
    { 
    /***************************************************************************
    * Types 
    ***************************************************************************/
    /** Logging Levels. */
    public enum LogLevel : int 
      { 
      /** Emergency */   Emerg   = 0, 
      /** Alert */       Alert   = 100, 
      /** Critical */    Crit    = 200, 
      /** Error */       Err     = 300, 
      /** Warning */     Warn    = 400, 
      /** Notice */      Notice  = 500, 
      /** Information */ Info    = 600, 
      /** Summary */     Summary = 700, 
      /** Detail */      Detail  = 800, 
      /** Debug */       Debug   = 900 
      } 

    /** Email Configuration. */
    public class EMailConfig
      {
      /** Local Machine Name. */ public string machineName;
      /** Mail Server Name. */   public string mailServer;
      /** From Address. */       public string from;
      /** To Address. */         public string to;
      /** CC Addresses. */       public string cc;
      /** Subject. */            public string subject;
      }

    /***************************************************************************
    * Properties
    ***************************************************************************/
    /** Log level. */           protected LogLevel    m_LogLevel      = LogLevel.Notice; 
    /** Email Log Level. */     protected LogLevel    m_EMailLogLevel = LogLevel.Emerg;
    /** Email Configuration. */ public    EMailConfig m_EMailConfig   = null;

    /** Logging Level. */       public object logLevel      { set { m_LogLevel      = convertLogLevel(value); }}
    /** EMail Log Level. */     public object emailLogLevel { set { m_EMailLogLevel = convertLogLevel(value); }}

    /** EMail Configuration. */ 
    public EMailConfig emailConfig
      {
      get { return m_EMailConfig; }
      set { m_EMailConfig = value; }
      }
    
    /***************************************************************************
    /* Sugar
    ***************************************************************************/
    /** Log at Emergency Level. */ public void logEmerg  (string msg, params object[] parms) { log(LogLevel.Emerg,   msg, parms); }
    /** Log at Alert Level. */     public void logAlert  (string msg, params object[] parms) { log(LogLevel.Alert,   msg, parms); }
    /** Log at Critical Level. */  public void logCrit   (string msg, params object[] parms) { log(LogLevel.Crit,    msg, parms); }
    /** Log at Error Level. */     public void logErr    (string msg, params object[] parms) { log(LogLevel.Err,     msg, parms); }
    /** Log at Warning Level. */   public void logWarn   (string msg, params object[] parms) { log(LogLevel.Warn,    msg, parms); }
    /** Log at Notice Level. */    public void logNotice (string msg, params object[] parms) { log(LogLevel.Notice,  msg, parms); }
    /** Log at Info Level. */      public void logInfo   (string msg, params object[] parms) { log(LogLevel.Info,    msg, parms); }
    /** Log at Summary Level. */   public void logSummary(string msg, params object[] parms) { log(LogLevel.Summary, msg, parms); }
    /** Log at Detail Level. */    public void logDetail (string msg, params object[] parms) { log(LogLevel.Detail,  msg, parms); }
    /** Log at Debug Level. */     public void logDebug  (string msg, params object[] parms) { log(LogLevel.Debug,   msg, parms); }

    /***************************************************************************
    * log */
    /**
    * Writes a log message. If <code>level</code> is greater than the current 
    * logging level, no message is written. Message is built from 
    * <code>msg</code> and <code>parms</code> using String.Format and then 
    * written to the log.
    * <p>
    * This method is called by all the logging methods in this class (logEmerg,
    * logAlert, etc.).  However, this method checks the log level, formats the
    * message, and calls writeLog().  writeLog should be overridden if writing
    * to another device is desired.
    * <p>
    * If there is an email configuration, an email with the log message will be
    * sent unless <code>level</code> is greater than the email logging level.
    *
    * @param  level  Logging Level
    * @param  msg    Log Message
    * @param  parms  Message Parameters
    ***************************************************************************/
    public void log(LogLevel level, string msg, params object[] parms)
      {
      if (level <= m_LogLevel)
        writeLog(level, string.Format(msg, parms));

      if (m_EMailConfig != null && level <= m_EMailLogLevel)
        new EMailLogMessage(this, level, String.Format(msg, parms));
      }

    /***************************************************************************
    * convertLogLevel */
    /**
    * Returns the LogLevel for the object.  Valid objects are string and
    * LogLevel.
    *
    * @param  level  Log Level
    * @return        Log Level
    ***************************************************************************/
    protected LogLevel convertLogLevel(object level)
      {
      if (level is LogLevel)
        return (LogLevel)level;

      try   { return (LogLevel)Enum.Parse(typeof(LogLevel), (string)level, true); }
      catch { throw new Exception("Bad log level specified."); }
      }

    /***************************************************************************
    * writeLog */
    /**
    * Performs the actual write to the log.  This method must be provided by the
    * subclass.
    *
    * @param  level  Logging Level
    * @param  msg    Log Message
    ***************************************************************************/
    public abstract void writeLog(LogLevel level, string msg);

    /***************************************************************************
    * EMailLogMessage Class */
    /**
    * EMails a log message according to the email configuration of the logger.
    * Starts a thread to send the email so emailing problems will not slow the
    * log caller.
    ***************************************************************************/
    protected class EMailLogMessage
      {
      /*************************************************************************
      * Properties
      *************************************************************************/
      /** Logger. */      protected Logger          m_Logger;
      /** Log Level. */   protected Logger.LogLevel m_Level;
      /** Log Message. */ protected string          m_Message;
   
      /*************************************************************************
      * Constructor */
      /**
      * Starts the send thread.
      *
      * @param  logger   Logger Object
      * @param  level    Logging Level
      * @param  message  Log Message
      *************************************************************************/
      public EMailLogMessage(Logger logger, Logger.LogLevel level, string message)
        {
        m_Logger  = logger;
        m_Level   = level;
        m_Message = message;
   
        new Thread(send).Start();
        }
   
      /*************************************************************************
      * send */
      /**
      * Sends the email message.  Runs in a separate thread.
      *************************************************************************/
      protected void send()
        {
        MailMessage msg  = new MailMessage();
   
        msg.From         = m_Logger.emailConfig.from;
        msg.To           = m_Logger.emailConfig.to;
        msg.Cc           = (m_Logger.emailConfig.cc != null ? m_Logger.emailConfig.cc : null);
        msg.Subject      = String.Format(m_Logger.emailConfig.subject, m_Level, m_Logger.emailConfig.machineName);
        msg.Body         = m_Message;
        msg.BodyFormat   = MailFormat.Text;
        msg.BodyEncoding = Encoding.GetEncoding("iso-8859-2");
   
        try
          {
          if (m_Logger.emailConfig.mailServer != null && m_Logger.emailConfig.mailServer.Trim().Length != 0)
        	  SmtpMail.SmtpServer = m_Logger.emailConfig.mailServer;

          SmtpMail.Send(msg);
   
          m_Logger.writeLog(m_Level, "email sent to: "+m_Logger.emailConfig.to);
          }
        catch(Exception ex)
          {
          m_Logger.writeLog(Logger.LogLevel.Crit, "email failed: "+ex.Message);
          }
        }
      }
    }
  }











