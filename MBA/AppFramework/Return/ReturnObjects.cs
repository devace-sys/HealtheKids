using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
 
 /***************************************************************************
  * ReturnObjects */
 /**
  * Return results of a view as an entity list
  ***************************************************************************/   
  
  public class ReturnObjects : Return
  {
    public ReturnObjects ()            : base(){}
    public ReturnObjects (string msg)  : base(msg){}
    public ReturnObjects (Exception e) : base(e){}
    public ReturnObjects (Warning e)   : base(e){}
    public ReturnObjects (Critical e)  : base(e){}
    public ReturnObjects (SessionExpired e):base(e){}
        
    public int      draw;    
    public bool     hasRecords;
    public string   objectFullName;
    public bool     recordsPaged;
    public long     recordsReturned;
    public long     recordsTotal;
    public long     recordsFiltered;

    public int      pageCount;
    public int      pageSize;
    public int      pageNumber;
    public string   pageOrder;

    public string   header1;
    public string   header2;
    public string   header3;
    public string   header4;

    public string   footer1;
    public string   footer2;

    public Object referenceObject1;
    public string referenceObject1FullName;

    public Object referenceObject2;
    public string referenceObject2FullName;

    public Object referenceObject3;
    public string referenceObject3FullName;

    public Object[] data;

    
  }
}
