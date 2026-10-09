using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{   
  /***************************************************************************
   * ClientAttendance */
  /**
   * Client attendance data
   **************************************************************************/
   
  public abstract class ClientAttendance:Entity
  {            
    public   long     clientID;
    public   string   clientName;
    public   string   description;
    public   string   attendanceDayType;

  }
  
  /***************************************************************************
   * ClientAttendanceYearlyData */
  /**
   * Client attendance data that changes every fiscal year.  Header level.
   **************************************************************************/

  public abstract class ClientAttendanceYearlyData:ClientAttendance
  {
    public int    fiscalYearID;
    public string fiscalYearName;
  }
  
  /***************************************************************************
   * ClientAttendanceYearlyDataDetail */
  /**
   * Client attendance data that changes every fiscal year.  Detail level.
   **************************************************************************/

  public abstract class ClientAttendanceYearlyDataDetail:ClientAttendanceYearlyData
  {
    public long attendanceDayTypeID;
  }
  
  /***************************************************************************
   * ClientAttendanceEntities */
  /**
   * Client attendance entities
   **************************************************************************/
  
  public abstract class ClientAttendanceEntities:Entities
  {
    public const string ENTITY_LABEL          = "Cal & Bell Sched";
    
    public const string SEL_LABEL_ADD         = "Add New";
    public const string SEL_LABEL_VIEW        = "View";
    public const string SEL_LABEL_EDIT_DELETE = "Edit or Deactive";
    
    public const string SEL_LABEL_EDIT        = "Edit";   
    public const string SEL_LABEL_DELETE      = "Deactivate";
  }  
}
