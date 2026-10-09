using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{
      
  /***************************************************************************
   * DistributionResultFlag */
  /**
   * What happened with the report distribution
   **************************************************************************/
  
  [Flags]
  
  public enum DistributionResultFlag:int
  {
    New               = 1,
    Retry             = 2,
    NotRunDate        = 4,
    IsRunDate         = 8,
    NotOKToPublish    = 16,
    IsOKToPublish     = 32,
    ConfigError       = 64,
    NoRecords         = 128,
    DataError         = 256,
    FileError         = 512,
    EmailError        = 1024,
    ScheduleForRetry  = 2048,
    NoFileDistributed = 4096,    
    FileDistributed   = 8192    
  }
  
  /***************************************************************************
   * DistributionHistory */
  /**
   * 
   **************************************************************************/
   
  public class DistributionHistory:Distribution
  {                    
    public DateTime               RunDate;       /* Actual run date (makeup or actual) */
    public DateTime               ProcRunDate;   /* Processing Run date (makeup or actual)*/
    public int                    Status;        /* Return status */
    public string                 Message;       /* Return message */
    public Exception              Exception;     /* Return exception (if any) */
    public DistributionResultFlag ResultFlags;
    public DateTime               RetryDate;
    public int                    DistNum;       /* x part of x of y */
    public int                    DistTot;       /* y part of x of y */
    public string                 SummaryMsg;
  }

}
