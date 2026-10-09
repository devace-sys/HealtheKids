using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;

namespace MBA
{
  
  /***************************************************************************
   * Distribution */
  /**
   * 
   **************************************************************************/
  
  public class Distribution // defined as a class... but used like a struct.
  {                         // TODO:   Maybe we can put some constructors in here, eventually, if nothing else.                 
    public bool                        IsRetry;
    public long                        PublicationID;
    public PublicationsClass           PublicationClass;
    public DateTime                    ReferenceDate;
    public DateTime                    OKToPublishUpToDate;
    public string                      PublicationName;
    public string                      PublicationDescription;
    public int                         DataSource;        
    public PublicationDataSourceType   DataSourceType;
    public string                      PublicationTrackingSheetDescription;
    public string                      PublicationDistributionDateFormat; /* DateTime.ToString("format") */
    public string                      PublicationDistributionDescription1;
    public string                      PublicationDistributionDescription2;
    //public int    Format;                                   /* Format is based on Datasource type*/
                                   
    public string Schedule;                                 /* Cron tab */
    public string DistEmailTitleTemplate;                   /* Distribution email template */
    public string DistEmailBodyTemplate;
    public string DistEmailFooterTemplate;
    public string DistributeToEmails;                       /* ; delimited */
    public bool   isInternal;
    public short  fileTypeRequested;
    //public string ManagedByEmails; // not used
    public long?  ClientID;          //must be nullable
    public string ClientName;
    public string RepNameFirst;
    public string RepNameLast;
    public string RepEmail;
    public string RepPhone;
    public string RelativeDateRange1;
    public string RelativeDateRange2; 
    public string ActualDateRange1;
    public string ActualDateRange2;
  }

}
