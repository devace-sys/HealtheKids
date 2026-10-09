using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{                                                              
  
  public enum PublicationDataSourceType:int
  {
    Rpt  = 1,
    View = 2
  }
  
  public enum PublicationsClass:int
  {
    ClientFinancialReport = 1,
    PartnerReport         = 2
  }
  
  /***************************************************************************
   * Publication */
  /**
   * 
   **************************************************************************/
  
  public class Publication
  {
    public long   ID;
    public PublicationsClass PublicationClass; /* 1 = Client financial report, 2 = Partner report */
    public string Name;
    public int    DataSource;
    public PublicationDataSourceType    DataSourceType; /* 1= RptData, 2= Datatable */
    public int    Format;
    public string Schedule;
    public string DistEmailTitleTemplate; /* Distribution email template */
    public string DistEmailBodyTemplate;
    public string DistEmailFooterTemplate;
    public bool   Active;
  }
}
