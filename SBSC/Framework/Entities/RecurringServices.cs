using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using MBA;

namespace Spedmon
{
  
  /***************************************************************************
   * RecurringServiceDetail */
  /**
   * Base class for detail record
   ***************************************************************************/
  
  public abstract class RecurringServiceDetail
  {
        
    protected static bool checkBoxOK (bool? value)
    {
      bool isOK = false;
      if (value.HasValue)
        isOK = true;
        
      return isOK;
    }
    
    [IsDataGridCol(1)]
    [DataGridColTitle("ID")]
    [DataGridColIsInputLabel(true)]
    [DataGridColIsInputKey(true)]
    [DataGridColIsHidden(true)]
    [DataGridColWidth(1)]    
    public int pracID;
        
    [IsDataGridCol(2)]
    [DataGridColGroup("Practitioner")]
    [DataGridColTitle("SpEdCare Name")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(200)]    
    public string pracName;
    
    [IsDataGridCol(3)]
    [DataGridColGroup("Practitioner")]
    [DataGridColTitle("Title")]
    [DataGridColIsInputLabel(true)]
    [DataGridColWidth(200)]    
    public string pracTitle;
  }
  
  /***************************************************************************
   * RecurringServiceDetailPracInfo */
  /**
   * Base class for detail record containing additional information about the
   * practitioner providing the service
   ***************************************************************************/
  
  public abstract class RecurringServiceDetailPracInfo:RecurringServiceDetail
  {
    
    public bool Valid()
    {
      
      if (!checkBoxOK(tmtBS))      return false;
      if (!checkBoxOK(tmtDSInd))   return false;
      if (!checkBoxOK(tmtDSGrp))   return false;
      if (!checkBoxOK(tmtAS))      return false;
      if (!checkBoxOK(transHmSs))  return false;
      if (!checkBoxOK(transSsHm))  return false;
      if (!checkBoxOK(transSsOs))  return false;
      if (!checkBoxOK(transOsSs))  return false;

      if ((tmtBS.Value     == false) &&
          (tmtDSInd.Value  == false) &&
          (tmtDSGrp.Value  == false) &&
          (tmtAS.Value     == false) &&
          (transHmSs.Value == false) &&
          (transHmSs.Value == false) &&
          (transSsOs.Value == false) &&
          (transOsSs.Value == false))
      return false;
      
      if ((tmtBS.Value     == true) &&
          (tmtDSInd.Value  == true) &&
          (tmtDSGrp.Value  == true) &&
          (tmtAS.Value     == true) &&
          (transHmSs.Value == true) &&
          (transHmSs.Value == true) &&
          (transSsOs.Value == true) &&
          (transOsSs.Value == true))
      return false;
      
      return true;
    }
        
    public long? pracDispGrpID;
    
    [IsDataGridCol(4)]
    [DataGridColGroup("Provides<br/>Treatment or TCM")]
    [DataGridColTitle("Before<br/>School")]
    [DataGridColWidth(25)]    
    public bool? tmtBS;
    
    [IsDataGridCol(5)]
    [DataGridColGroup("Provides<br/>Treatment or TCM")]
    [DataGridColTitle("During<br/>School<br/>Individual<br/>Service")]
    [DataGridColWidth(25)]    
    public bool? tmtDSInd;

    [IsDataGridCol(6)]
    [DataGridColGroup("Provides<br/>Treatment or TCM")]
    [DataGridColTitle("During<br/>School<br/>Group<br/>Treatment")]
    [DataGridColWidth(25)]    
    public bool? tmtDSGrp;
    
    [IsDataGridCol(7)]
    [DataGridColGroup("Provides<br/>Treatment or TCM")]
    [DataGridColTitle("After<br/>School")]
    [DataGridColWidth(25)]    
    public bool? tmtAS;

    [IsDataGridCol(8)]
    [DataGridColGroup("Provides<br/>Transportation")]
    [DataGridColTitle("Home<br/>to<br/>School")]
    [DataGridColWidth(25)]    
    public bool? transHmSs;

    [IsDataGridCol(9)]
    [DataGridColGroup("Provides<br/>Transportation")]
    [DataGridColTitle("School<br/>to<br/>Home")]
    [DataGridColWidth(25)]    
    public bool? transSsHm;

    [IsDataGridCol(10)]
    [DataGridColGroup("Provides<br/>Transportation")]
    [DataGridColTitle("School<br/>to<br/>Offsite<br/>Service")]
    [DataGridColWidth(25)]    
    public bool? transSsOs;

    [IsDataGridCol(11)]
    [DataGridColGroup("Provides<br/>Transportation")]
    [DataGridColTitle("Back<br/>From<br/>Offsite<br/>Service")]
    [DataGridColWidth(25)]    
    public bool? transOsSs;

    [IsDataGridCol(12)]
    [DataGridColTitle("Real Names")]
    [DataGridColWidth(150)]
    public string realNames;    
  
  }  
           
  /***************************************************************************
   * RecurringServiceDetailSvc */
  /**
   * Base class for detail record containing SerViCe details
   ***************************************************************************/

  public abstract class RecurringServiceDetailSvc:RecurringServiceDetail
  {              
    
    protected static bool numberBoxOK (int? value)
    {
      bool isOK = false;
      
      if (value.HasValue)
        if (value.Value >= 0)
          isOK = true;     
     return isOK;
    }
             
    
    [IsDataGridCol(4)]
    [DataGridColGroup("Service")]
    [DataGridColTitle("In IEP/IFSP")]
    [DataGridColWidth(30)]
    public bool? inIEP;

    [IsDataGridCol(5)]
    [DataGridColGroup("Service")]
    [DataGridColTitle("Is Med Nec")]
    [DataGridColWidth(30)]
    public bool? isMedNesc;   
  }
    
  /***************************************************************************
   * RecurringServiceDetailSvcMinuteBased */
  /**
   * Base class for detail record containing SerViCe details for minute based
   * services
   ***************************************************************************/

  public abstract class RecurringServiceDetailSvcMinuteBased:RecurringServiceDetailSvc
  { 
    public bool Valid()
    {
      
      if (!checkBoxOK(inIEP))         return false;
      if (!checkBoxOK(isMedNesc))     return false;
      if (!numberBoxOK(numMinsDaily)) return false;
      if (!numberBoxOK(numMinsMon))   return false;
      if (!numberBoxOK(numMinsTue))   return false;
      if (!numberBoxOK(numMinsWed))   return false;
      if (!numberBoxOK(numMinsThu))   return false;
      if (!numberBoxOK(numMinsFri))   return false;
      
      if ((numMinsDaily.Value == 0) &&
         (numMinsMon.Value    == 0) &&
         (numMinsTue.Value    == 0) &&
         (numMinsWed.Value    == 0) &&
         (numMinsThu.Value    == 0) &&
         (numMinsFri.Value    == 0))
      {
        return false;
      }
              
      return true;
    }
        
    [IsDataGridCol(6)]
    [DataGridColGroup("Every Day")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(50)]    
    [DataGridColCopyValueRight(true)]
    public int? numMinsDaily;

    [IsDataGridCol(7)]
    [DataGridColGroup("Mon")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(50)]    
    public int? numMinsMon;
    
    [IsDataGridCol(8)]
    [DataGridColGroup("Tue")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(50)]    
    public int? numMinsTue;   
    
    [IsDataGridCol(9)]
    [DataGridColGroup("Wed")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(50)]
    public int? numMinsWed;
    
    [IsDataGridCol(10)]
    [DataGridColGroup("Thu")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(50)]
    public int? numMinsThu;

    [IsDataGridCol(11)]
    [DataGridColGroup("Fri")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(50)]
    public int? numMinsFri;
    
  }

  /***************************************************************************
   * RecurringServiceDetailSvcScheduleOrMinuteBased */
  /**
   * Base class for detail record containing SerViCe details for schedule or
   * minute based services
   ***************************************************************************/
   
  public abstract class RecurringServiceDetailSvcScheduleOrMinuteBased:RecurringServiceDetailSvc
  { 
               
    protected bool dayOK (bool? checkBox, int? numberBox)
    {
      if (!checkBoxOK(checkBox))   return false;
      if (!numberBoxOK(numberBox)) return false;      
      
      if ((checkBox.Value == true) && (numberBox.Value >  0))  return false;
      
      return true;            
    }

    public bool hasAllDay()
    {
      if (scheduleDaily.Value == true) return true;
      if (scheduleMon.Value   == true) return true;
      if (scheduleTue.Value   == true) return true;
      if (scheduleWed.Value   == true) return true;
      if (scheduleThu.Value   == true) return true;
      if (scheduleFri.Value   == true) return true;
      return false;
    }
    
    public bool Valid()
    {
      
      if (!checkBoxOK(inIEP))         return false;
      if (!checkBoxOK(isMedNesc))     return false;
    
      if (!dayOK(scheduleDaily, numMinsDaily)) return false;
      if (!dayOK(scheduleMon,   numMinsMon))   return false;
      if (!dayOK(scheduleTue,   numMinsTue))   return false;
      if (!dayOK(scheduleWed,   numMinsWed))   return false;
      if (!dayOK(scheduleThu,   numMinsThu))   return false;
      if (!dayOK(scheduleFri,   numMinsFri))   return false;

        
      if (scheduleDaily.Value == false &&
          scheduleMon.Value   == false &&
          scheduleTue.Value   == false &&
          scheduleWed.Value   == false &&
          scheduleThu.Value   == false &&
          scheduleFri.Value   == false &&
          numMinsDaily.Value  == 0     &&
          numMinsMon.Value    == 0     &&
          numMinsTue.Value    == 0     &&
          numMinsWed.Value    == 0     &&
          numMinsThu.Value    == 0     &&
          numMinsFri.Value    == 0)
      {
        return false;
      }
              
      return true;
    }
    
    [IsDataGridCol(6)]
    [DataGridColGroup("Every Day")]
    [DataGridColTitle("All<br/>Day")]
    [DataGridColWidth(25)]
    [DataGridColCopyValueRight(true)]
    public bool? scheduleDaily;
    
    [IsDataGridCol(7)]
    [DataGridColGroup("Every Day")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(50)]    
    [DataGridColCopyValueRight(true)]
    public int? numMinsDaily;
        
    [IsDataGridCol(8)]
    [DataGridColGroup("Mon")]
    [DataGridColTitle("All<br/>Day")]
    [DataGridColWidth(25)]
    public bool? scheduleMon;
     
    [IsDataGridCol(9)]
    [DataGridColGroup("Mon")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(30)]    
    public int? numMinsMon;
    
    [IsDataGridCol(10)]
    [DataGridColGroup("Tue")]
    [DataGridColTitle("All<br/>Day")]
    [DataGridColWidth(25)]
    public bool? scheduleTue;
     
    [IsDataGridCol(11)]
    [DataGridColGroup("Tue")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(30)]    
    public int? numMinsTue;
        
    [IsDataGridCol(12)]
    [DataGridColGroup("Wed")]
    [DataGridColTitle("All<br/>Day")]
    [DataGridColWidth(25)]
    public bool? scheduleWed;
     
    [IsDataGridCol(13)]
    [DataGridColGroup("Wed")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(30)]    
    public int? numMinsWed;
            
    [IsDataGridCol(14)]
    [DataGridColGroup("Thu")]
    [DataGridColTitle("All<br/>Day")]
    [DataGridColWidth(25)]
    public bool? scheduleThu;
     
    [IsDataGridCol(15)]
    [DataGridColGroup("Thu")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(30)]    
    public int? numMinsThu;
    
    [IsDataGridCol(16)]
    [DataGridColGroup("Fri")]
    [DataGridColTitle("All<br/>Day")]
    [DataGridColWidth(25)]
    public bool? scheduleFri;
     
    [IsDataGridCol(17)]
    [DataGridColGroup("Fri")]
    [DataGridColTitle("Mins")]
    [DataGridColWidth(30)]    
    public int? numMinsFri;
                       
  }
     
  /***************************************************************************
   * RecurringServiceDetailSvcMileBased */
  /**
   * Base class for detail record containing SerViCe details for mile based
   * services (transportation)
   ***************************************************************************/

  public abstract class RecurringServiceDetailSvcMileBased:RecurringServiceDetailSvc
  {      
    
    public bool Valid()
    {
      
      if (!checkBoxOK(inIEP))          return false;
      if (!checkBoxOK(isMedNesc))      return false;
      
      if (!numberBoxOK(numMilesDaily)) return false;
      if (!numberBoxOK(numMilesMon))   return false;
      if (!numberBoxOK(numMilesTue))   return false;
      if (!numberBoxOK(numMilesWed))   return false;
      if (!numberBoxOK(numMilesThu))   return false;
      if (!numberBoxOK(numMilesFri))   return false;
      
      if ((numMilesDaily.Value == 0) &&
         (numMilesMon.Value    == 0) &&
         (numMilesTue.Value    == 0) &&
         (numMilesWed.Value    == 0) &&
         (numMilesThu.Value    == 0) &&
         (numMilesFri.Value    == 0))
      {
        return false;
      }    
      
      return true;
    }
    
    [IsDataGridCol(6)]
    [DataGridColGroup("Every Day")]
    [DataGridColTitle("Miles")]
    [DataGridColWidth(50)]
    [DataGridColCopyValueRight(true)]    
    public int? numMilesDaily;
    
    [IsDataGridCol(7)]
    [DataGridColGroup("Mon")]
    [DataGridColTitle("Miles")]
    [DataGridColWidth(50)]
    public int? numMilesMon;

    [IsDataGridCol(8)]
    [DataGridColGroup("Tue")]
    [DataGridColTitle("Miles")]
    [DataGridColWidth(50)]
    public int? numMilesTue;   

    [IsDataGridCol(9)]
    [DataGridColGroup("Wed")]
    [DataGridColTitle("Miles")]
    [DataGridColWidth(50)]
    public int? numMilesWed;
    
    [IsDataGridCol(10)]
    [DataGridColGroup("Thu")]
    [DataGridColTitle("Miles")]
    [DataGridColWidth(50)]
    public int? numMilesThu;

    [IsDataGridCol(11)]
    [DataGridColGroup("Fri")]
    [DataGridColTitle("Miles")]
    [DataGridColWidth(50)]
    public int? numMilesFri;

  }


  /***************************************************************************
   * RecurringServiceDetailPracInfoAll */
  /**
   * Detail record for prac info
   ***************************************************************************/
  
  public class RecurringServiceDetailPracInfoAll:RecurringServiceDetailPracInfo
  {
  }  
       
  /***************************************************************************
   * RecurringServiceDetailTmtBeforeSchool */
  /**
   * Detail record for any treatment provided before school
   ***************************************************************************/

  public class RecurringServiceDetailTmtBeforeSchool:RecurringServiceDetailSvcMinuteBased
  {
  }
  
  /***************************************************************************
   * RecurringServiceDetailTmtAfterSchool */
  /**
   * Detail record for any treatment provided after school
   ***************************************************************************/
  
  public class RecurringServiceDetailTmtAfterSchool:RecurringServiceDetailSvcMinuteBased
  {
  }

  /***************************************************************************
   * RecurringServiceDetailTmtAtSchoolInd */
  /**
   * Detail record for any individual treatment provided during school
   ***************************************************************************/
  
  public class RecurringServiceDetailTmtDuringSchoolInd:RecurringServiceDetailSvcScheduleOrMinuteBased
  {
  }
  
  /***************************************************************************
   * RecurringServiceDetailTmtAtSchoolGrp */
  /**
   * Detail record for any group treatment provided during school
   ***************************************************************************/

  public class RecurringServiceDetailTmtDuringSchoolGrp:RecurringServiceDetailSvcScheduleOrMinuteBased
  {
  }
  
  /***************************************************************************
   * RecurringServiceDetailTransFromHomeToSchool */
  /**
   * Detail record for transportation from home to school
   ***************************************************************************/

  public class RecurringServiceDetailTransFromHomeToSchool:RecurringServiceDetailSvcMileBased
  {
  }
  
  /***************************************************************************
   * RecurringServiceDetailTransFromSchoolToHome */
  /**
   * Detail record for transportation from school to home
   ***************************************************************************/

  public class RecurringServiceDetailTransFromSchoolToHome:RecurringServiceDetailSvcMileBased
  {
  }

  /***************************************************************************
   * RecurringServiceDetailTransFromSchoolToOffSiteSvc */
  /**
   * Detail record for transportation from school to offsite service
   ***************************************************************************/

  public class RecurringServiceDetailTransFromSchoolToOffSiteSvc:RecurringServiceDetailSvcMileBased
  {
  }

  /***************************************************************************
   * RecurringServiceDetailTransFromOffSiteSvcToSchool */
  /**
   * Detail record for transportation back from offsite service.
   * Note: The destination could be school or home.
   ***************************************************************************/
   
  public class RecurringServiceDetailTransFromOffSiteSvcToSchool:RecurringServiceDetailSvcMileBased
  {
  }

  /***************************************************************************
   * RecurringServiceDetails */
  /**
   * Detail lists
   ***************************************************************************/
  
  public class RecurringServiceDetails
  {    
    
    public List<RecurringServiceDetailPracInfoAll>                 details_pracs_all;
    public List<RecurringServiceDetailTmtBeforeSchool>             details_tmt_bs;
    public List<RecurringServiceDetailTmtDuringSchoolInd>          details_tmt_ds_ind;  
    public List<RecurringServiceDetailTmtDuringSchoolGrp>          details_tmt_ds_grp;
    public List<RecurringServiceDetailTmtAfterSchool>              details_tmt_as;  
    public List<RecurringServiceDetailTransFromHomeToSchool>       details_trans_hm_ss;
    public List<RecurringServiceDetailTransFromSchoolToHome>       details_trans_ss_hm;
    public List<RecurringServiceDetailTransFromSchoolToOffSiteSvc> details_trans_ss_os;
    public List<RecurringServiceDetailTransFromOffSiteSvcToSchool> details_trans_os_ss;       
  }

  /***************************************************************************
   * RecurringService */
  /**
   * Recurring service
   ***************************************************************************/

  public class RecurringService:Entity
  {    
    public string      clientName;
    public string      patientName;
    public long        clientID;
    public long        patID;
    public long        fiscalYearID;
    public string      fiscalYearName;
    public long        calendarID;
    public string      calendarName;
    public long        scheduleID;
    public string      scheduleName;
    public string      startDateStr;
    public string      endDateStr;   
    public string      pracNamesStr;
    public string      pracIDsStr;
    public string      pracTitlesStr;
    
    public string      detailsPracsStr;        
    public string      detailsTmtBSStr;
    public string      detailsTmtDSIndStr;
    public string      detailsTmtDSGrpStr;
    public string      detailsTmtASStr;
    public string      detailsTransHmSsStr;
    public string      detailsTransSsHmStr;
    public string      detailsTransSsOsStr;
    public string      detailsTransOsSsStr;
  }

  /***************************************************************************
   * RecurringServices */
  /**
   * Recurring services
   ***************************************************************************/

  public class RecurringServices:MBA.Entities
  {
    /***************************************************************************
     * SEL_LABEL */
    /**
     * Selection labels for menus and screens
     ***************************************************************************/       
    
    public const string SEL_LABEL                  = "Recurring Services";
    public const string SEL_LABEL_ADD              = "Create New List for A Patient";
    public const string SEL_LABEL_VIEW             = "View Existing Lists";
    public const string SEL_LABEL_OPS              = "Manage Existing Lists";
    public const string SEL_LABEL_EDIT             = "Edit Exiting List";   
    public const string SEL_LABEL_COPY             = "End and Start New";   
    public const string SEL_LABEL_DEACTIVATE       = "End";                     
    public const string SEL_LABEL_DELETE           = "Delete";
    
    /***************************************************************************
     * load */
    /**
     * Outputs data for a single recurring service record
     * 
     * Note: This calls the view method and the view method takes care of
     * enforcing the client id.
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/

    public static RecurringService load(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, string recID)
    {
      return (RecurringService) Entities.load(connSpedmon, log, uInfo, recID, typeof(RecurringService),
      delegate { return RecurringServices.view(connSpedmon, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", "", "", "", "", "", null); });
    } 
    
    /***************************************************************************
     * activateDeactivate */
    /**
     * Toggles 
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
    
    public static ReturnSaveRecord opEnd (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                                       string editDelReason, 
                                                       string validateRec, 
                                                       string recID, 
                                                       string effectiveDate)
    {
      
      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object   vClientID      = Validate.optClientID (uInfo, "");
      DateTime vEffectiveDate = Validate.reqDate     (effectiveDate, Messages.INVALID_EFFECTIVE_DATE);      
      
      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      
      parms.Add(Database.SqlParm("@clientID",       SqlDbType.Int,      vClientID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@effectiveDate",  SqlDbType.DateTime, vEffectiveDate,  ParameterDirection.Input));

      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.recordOp (connSpedmon, log, uInfo, editDelReason, validateRec, recID, "RECURRING_SERVICES_OpEnd", ref parms);
    }
    
    /***************************************************************************
     * delete */
    /**
     * Permanent delete
     * 
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @return                 ReturnEntity
     ***************************************************************************/
     
    public static ReturnSaveRecord delete(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          string editDelReason, string validateRec, string recID)
    {

      /*----------------------------
       * Check for required and 
       * optional parameters
       * and validate data integrity
       * of all supplied parameters
       *----------------------------*/

      Object vClientID = Validate.optClientID(uInfo, "");

      /*----------------------------
       * Collect all of the parameters
       * that are specific to this
       * delete method.
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
      parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));

      /*----------------------------
       * Call base method 
       *----------------------------*/

      return Entities.delete(connSpedmon, log, uInfo, editDelReason, validateRec, recID, "RECURRING_SERVICES_Delete", ref parms);
    }
        
    /***************************************************************************
     * save */
    /**
     * Save a recurring service record
     *
     * @param  userID          User id of who is recording service
     * @param  userGroup       1 = Client, 2 = SBSC (from users db)
     * @param  userRank        Users role ranking
     * @param  clientID        Client id
     * @param  pracID          Practitioner id
     * @param  patIDs          Patient ids
    
     * @param  distributionNotes     Any notes about the distribution (fax only, send with invoice, etc)
     * 
     * @param  editDelReason   Reason for record edit or delete
     * @param  validateRec     1 = Performs data integrity validation tasks
     *                             Perform advisory validation tasks that can
     *                             only be conducted by referencing data from the
     *                             database and then exits WITHOUT saving the record
     *                         0 = Peform data integrity validation tasks and
     *                             if these tasks succeed peforms the desired
     *                             operation (saveType) on the record and exits
     * @param  saveType        Type of operation to perform
     *                         1 = New, 2 = Edit, 3 = Delete, 4 = Copy
     * @param  recID           Record id of existing patient record to edit or
     *                         delete.
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord save (SqlConnection connSpedmon, 
                                         DetailsLog    log, 
                                         UserInfo      uInfo,
                                         string        clientID, 
                                         string        patID,                           
                                         string        fiscalYearID,                                         
                                         string        startDate,
                                         string        endDate,
                                         string        calendarID,
                                         string        scheduleID,
                                         string        pracIDs,
                                         string        detailsPracsAll,
                                         string        detailsTmtBS,
                                         string        detailsTmtDSInd,   
                                         string        detailsTmtDSGrp,
                                         string        detailsTmtAS,
                                         string        detailsTransHmSs,
                                         string        detailsTransSsHm,
                                         string        detailsTransSsOs,
                                         string        detailsTransOsSs,
                                         string        notes,   
                                         string        editDelReason,
                                         string        validateRec,
                                         string        saveType, 
                                         string        recID)
    {           
            
        
      /*============================================================
       * Validate required and optional simple parameters
       *============================================================*/   
      
      int       vClientID      = Validate.reqClientID  (uInfo,  clientID);            
      int       vPatID         = Validate.reqInteger   (patID,              Messages.INVALID_PAT_ID);      
      int       vFiscalYearID  = Validate.reqInteger   (fiscalYearID,       Messages.INVALID_FISCAL_YEAR_ID);
     
      DateTime[] vDates        = Validate.reqStartAndEndDate (startDate, endDate, Messages.INVALID_DATE_RANGE);
      
      DateTime  vStartDate     = vDates[0];
      DateTime  vEndDate       = vDates[1];
            
      Object    vCalendarID     = Validate.optInteger  (calendarID,       Messages.INVALID_CALENDAR_ID);
      Object    vScheduleID     = Validate.optInteger  (scheduleID,       Messages.INVALID_SCHEDULE_ID);      
      string    vNotes          = Validate.optString   (notes,            Messages.INVALID_NOTES);      
      int       vSaveType       = Validate.reqInteger  (saveType,         Messages.INVALID_SAVE_TYPE);
      bool      vValidateRec    = Validate.reqFlag     (validateRec,      Messages.INVALID_VALIDATE_FLAG);      


      /*============================================================
       * Validate required and optional complex parameters
       *============================================================*/   
      
      /*----------------------------
       * Validate practitioner ids
       * and put them into structures
       * 
       * Note: We check to make sure
       * they are valid integers here.
       * In the sproc we will check
       * to see if they are valid 
       * values.
       *----------------------------*/
       
      int[]     vPracIDsArr  = Validate.reqRecIDMulti (pracIDs, Messages.INVALID_PRAC_ID);
      string    vPracIDsStr  = Parse.createMultiInt   (vPracIDsArr);
      List<int> vPracIDsLst  = new List<int> (vPracIDsArr);
      
      /*----------------------------
       * Combine detail parameters
       * into a single json string
       *----------------------------*/
       
      string detailsCombined = "{" + Util.removeFirstAndLastCharacter(detailsPracsAll)  + 
                               "," + Util.removeFirstAndLastCharacter(detailsTmtBS)     +
                               "," + Util.removeFirstAndLastCharacter(detailsTmtDSInd)  +
                               "," + Util.removeFirstAndLastCharacter(detailsTmtDSGrp)  +
                               "," + Util.removeFirstAndLastCharacter(detailsTmtAS)     +
                               "," + Util.removeFirstAndLastCharacter(detailsTransHmSs) +
                               "," + Util.removeFirstAndLastCharacter(detailsTransSsHm) +
                               "," + Util.removeFirstAndLastCharacter(detailsTransSsOs) +
                               "," + Util.removeFirstAndLastCharacter(detailsTransOsSs) +
                               "}";
            
      /*----------------------------
       * Create validation delegate
       * to validate detail parameters
       *----------------------------*/
                                
      AdditionalValidation av = delegate(Object o){
          
        /*============================================================
         * Note: We are just validating the INTEGRITY of the data
         * at this level.  We will check for incorrect values at the
         * database level.
         *============================================================*/         
      
        /*-------------------------------
         * Cast o to 
         * RecurringServiceDetails
         *-------------------------------*/ 

        RecurringServiceDetails vDtls = (RecurringServiceDetails) o;
                            
        /*-------------------------------
         * Check practitioner details
         * 
         * Number of rows should be the
         * same as the practitoner selected
         * list
         *-------------------------------*/
                
        if (vPracIDsLst.Count() != vDtls.details_pracs_all.Count())        
          throw new Warning("Mismatch between practitioners selected and additional details data"); 

        /*-------------------------------
         * Check practitioner details
         * 
         * Prac ids in both lists should
         * match.
         *-------------------------------*/
        
        var dpRes = 
        from pid in vPracIDsLst
        join dp  in vDtls.details_pracs_all on pid equals dp.pracID
        where dp.Valid() == true
        select dp;
                        
        if (dpRes .Count() != vPracIDsLst.Count())
          throw new Warning("Practitioners details has misssing or incorrect data"); 
             
        /*-------------------------------
         * Check treatment before school
         * against practitioner details
         * 
         * Are the rows correctly assigned
         *-------------------------------*/
        
        var tmtBSRes = 
        from dp     in dpRes
        join tmtBS  in vDtls.details_tmt_bs on dp.pracID equals tmtBS.pracID
        where 
             ((dp.tmtBS.Value == true) && (tmtBS.Valid() == true))
             
        select tmtBS;

        if (tmtBSRes.Count() != vDtls.details_tmt_bs.Count())
          throw new Warning("Before school treatment details has missing or incorrect data");  
               
        /*-------------------------------
         * Check treatment during school
         * (individual) against 
         * practitioner details and check
         * for missing or invalid values
         *-------------------------------*/
        
        var tmtDSIndRes = 
        from dp        in dpRes
        join tmtDSInd  in vDtls.details_tmt_ds_ind on dp.pracID equals tmtDSInd.pracID
        where 
          ((dp.tmtDSInd.Value == true) && (tmtDSInd.Valid() == true))   
        select tmtDSInd;

        if (tmtDSIndRes.Count() != vDtls.details_tmt_ds_ind.Count())
          throw new Warning("During school individual treatment details has missing or incorrect data");  
       
        /*-------------------------------
         * Check treatment during school
         * (group) against practitioner 
         * details and check for missing
         * or invalid values
         *-------------------------------*/
        
        var tmtDSGrpRes = 
        from dp        in dpRes
        join tmtDSGrp  in vDtls.details_tmt_ds_grp on dp.pracID equals tmtDSGrp.pracID
        where 
          ((dp.tmtDSGrp.Value == true) && (tmtDSGrp.Valid() == true))  
        select tmtDSGrp;

        if (tmtDSGrpRes.Count() != vDtls.details_tmt_ds_grp.Count())
          throw new Warning("During school group treatment details has missing or incorrect data");  

        /*-------------------------------
         * Check treatment during school
         * details for all day flags
         *-------------------------------*/

        var tmtDSIndResHasAllDay =
        from tmtDSInd in vDtls.details_tmt_ds_ind 
        where tmtDSInd.hasAllDay() == true
        select tmtDSInd;
        
        var tmtDSGrpResHasAllDay =
        from tmtDSGrp in vDtls.details_tmt_ds_grp 
        where tmtDSGrp.hasAllDay() == true
        select tmtDSGrp;

        /*-------------------------------
         * If we have all day flags
         * selected then a calendar and
         * bell schedule must be selected
         *-------------------------------*/

        if ((tmtDSIndResHasAllDay.Count() > 0) | (tmtDSIndResHasAllDay.Count() > 0))
        {
          vCalendarID = Validate.reqInteger(calendarID, "You must provide a valid calendar");
          vScheduleID = Validate.reqInteger(scheduleID, "You must provide a valid bell schedule");           
        }

        /*-------------------------------
         * Check treatment after school
         * against practitioner details
         * and check for missing or invalid
         * values
         *-------------------------------*/
        
        var tmtASRes = 
        from dp     in dpRes
        join tmtAS  in vDtls.details_tmt_as on dp.pracID equals tmtAS.pracID
        where 
           ((dp.tmtAS.Value == true) && (tmtAS.Valid() == true))
        select tmtAS;

        if (tmtASRes.Count() != vDtls.details_tmt_as.Count())
          throw new Warning("After school treatment details has missing or incorrect data");
        
        /*-------------------------------
         * Check transporation 
         * from home to school site
         * against practitioner details
         * and check for missing or invalid
         * values
         *-------------------------------*/
        
        var transHmSsRes = 
        from dp         in dpRes
        join transHmSs  in vDtls.details_trans_hm_ss on dp.pracID equals transHmSs.pracID
        where 
             dp.transHmSs.Value == true && transHmSs.Valid() == true
        select transHmSs;

        if (transHmSsRes.Count() != vDtls.details_trans_hm_ss.Count())
          throw new Warning("Transportation from home to school details has missing or incorrect data");  
           
        /*-------------------------------
         * Check transporation 
         * from school site to home
         * against practitioner details
         * 
         * Are the rows correctly assigned
         *-------------------------------*/
        
        var transSsHmRes = 
        from dp         in dpRes
        join transSsHm  in vDtls.details_trans_ss_hm on dp.pracID equals transSsHm.pracID
        where 
             dp.transSsHm.Value == true && transSsHm.Valid() == true
        select transSsHm;

        if (transSsHmRes.Count() != vDtls.details_trans_ss_hm.Count())
          throw new Warning("Transportation from school to home details has missing or incorrect data");  

        /*-------------------------------
         * Check transporation 
         * from school site to offsite svc
         * against practitioner details
         * 
         * Are the rows correctly assigned
         *-------------------------------*/
        
        var transSsOsRes = 
        from dp         in dpRes
        join transSsOs  in vDtls.details_trans_ss_os on dp.pracID equals transSsOs.pracID
        where 
             dp.transSsOs.Value == true && transSsOs.Valid() == true 
        select transSsOs;

        if (transSsOsRes.Count() != vDtls.details_trans_ss_os.Count())
          throw new Warning("Transportation from school to offsite details has missing or incorrect data");  

        /*-------------------------------
         * Check transporation 
         * from offsite to school
         * against practitioner details
         * 
         * Are the rows correctly assigned
         *-------------------------------*/
        
        var transOsSsRes = 
        from dp         in dpRes
        join transOsSs  in vDtls.details_trans_os_ss on dp.pracID equals transOsSs.pracID
        where 
             dp.transOsSs.Value == true && transOsSs.Valid() == true
        select transOsSs;

        if (transOsSsRes.Count() != vDtls.details_trans_os_ss.Count())
          throw new Warning("Transportation from offsite to school details has missing or incorrect data");  

      };      

      /*----------------------------
       * Validate details
       *----------------------------*/
       
      RecurringServiceDetails vDetails = (RecurringServiceDetails) Validate.reqObject (detailsCombined,  Messages.INVALID_RCR_SVC_DETAIL, "Spedmon", "Spedmon.RecurringServiceDetails", av);

      /*============================================================
       * Create db parameters and load values passed in
       *============================================================*/   
      
      List<SqlParameter> parms = new List<SqlParameter>();
   
      parms.Add(Database.SqlParm("@clientID",       SqlDbType.Int,      vClientID,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",          SqlDbType.Int,      vPatID,         ParameterDirection.Input)); 
      parms.Add(Database.SqlParm("@fiscalYearID",   SqlDbType.Int,      vFiscalYearID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",      SqlDbType.DateTime, vStartDate,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",        SqlDbType.DateTime, vEndDate,       ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@calendarID",     SqlDbType.Int,      vCalendarID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@scheduleID",     SqlDbType.Int,      vScheduleID,    ParameterDirection.Input));  
      parms.Add(Database.SqlParm("@pracIDsStr",     SqlDbType.VarChar,  vPracIDsStr,    ParameterDirection.Input, 8000));
      parms.Add(Database.SqlParm("@notes",          SqlDbType.VarChar,  vNotes,         ParameterDirection.Input, 8000));
      
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailPracInfoAll>          ("@detailsPracs",     vDetails.details_pracs_all,  "RecurringServiceDetailsPracInfoAll"));    
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTmtBeforeSchool>      ("@detailsTmtBS",     vDetails.details_tmt_bs,     "RecurringServiceDetailsSvcMinuteBased"));               
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTmtDuringSchoolInd>   ("@detailsTmtDSInd",  vDetails.details_tmt_ds_ind, "RecurringServiceDetailsSvcScheduleOrMinuteBased"));           
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTmtDuringSchoolGrp>   ("@detailsTmtDSGrp",  vDetails.details_tmt_ds_grp, "RecurringServiceDetailsSvcScheduleOrMinuteBased"));           
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTmtAfterSchool>       ("@detailsTmtAS",     vDetails.details_tmt_as,     "RecurringServiceDetailsSvcMinuteBased"));     
       
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTransFromHomeToSchool>       ("@detailsTransHmSs",  vDetails.details_trans_hm_ss, "RecurringServiceDetailsSvcMileBased"));     
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTransFromSchoolToHome>       ("@detailsTransSsHm",  vDetails.details_trans_ss_hm, "RecurringServiceDetailsSvcMileBased"));  
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTransFromSchoolToOffSiteSvc> ("@detailsTransSsOs",  vDetails.details_trans_ss_os, "RecurringServiceDetailsSvcMileBased"));  
      parms.Add(Database.SqlParmDataTable <RecurringServiceDetailTransFromOffSiteSvcToSchool> ("@detailsTransOsSs",  vDetails.details_trans_os_ss, "RecurringServiceDetailsSvcMileBased"));  

      parms.Add(Database.SqlParm("@MsgNoClient",  SqlDbType.VarChar,  Messages.INVALID_CLIENT_ID,   ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoPat",     SqlDbType.VarChar,  Messages.INVALID_PAT_ID,      ParameterDirection.Input, 1000));
      parms.Add(Database.SqlParm("@MsgNoPrac",    SqlDbType.VarChar,  Messages.INVALID_PRAC_ID,     ParameterDirection.Input, 1000));

      /*============================================================
       * Call base method which hadles the rest and return results
       *============================================================*/                         

      return Entities.save(connSpedmon, 
                           log, 
                           uInfo, 
                           saveType, 
                           validateRec, 
                           editDelReason, 
                           recID, 
                           "RECURRING_SERVICES_Save", 
                           Messages.DUP_RCR_SVC_ASSIGN, 
                           ref parms, 
                           null);
     
    }
    
   
    /***************************************************************************
     * viewPossibleDups */
    /**
     * Looks for possible duplicate records
     * 
     * @param  connSpedmon     Spedmon database connection object
     * @param  log             Logging object
     * @param  clientID        Client ID
     * @param  patID           PatientID
     * @return                 ReturnInfoTable
     ***************************************************************************/ 
     
    public static ReturnInfoTable viewPossibleDups (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                                    string clientID,
                                                    string patID,
                                                    string fiscalYearID,
                                                    string startDate,
                                                    string endDate,
                                                    string recID)
    {
           
     /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();

      string      viewUDF       = "RECURRING_SERVICES_CHECK_DUPS (@userID,@userGroup,@userRank,@clientID,@patID,@fiscalYearID,@startDate,@endDate,@recID)";
      
      int         vClientID     = Validate.reqClientID (uInfo, clientID);
      int         vPatID        = Validate.reqInteger  (patID,        Messages.INVALID_PAT_ID);
      int         vFiscalYearID = Validate.reqInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
      
      DateTime[]  vDates        = Validate.reqStartAndEndDate (startDate, endDate, Messages.INVALID_DATE_RANGE);      
      DateTime    vStartDate    = vDates[0];
      DateTime    vEndDate      = vDates[1];
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int,      vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.Int,      vPatID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.Int,      vFiscalYearID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",    SqlDbType.DateTime, vStartDate,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",      SqlDbType.DateTime, vEndDate,      ParameterDirection.Input));
                                    
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.viewInfoTbl (connSpedmon, log, uInfo, viewUDF, recID, parms);
         
    }

   
   
   /***************************************************************************
    * view */
   /**
    * Returns a list of recurring service records for given criteria
    * 
    ***************************************************************************/   

    public static ReturnDB view (SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo, 
                                 int    recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string clientID,
                                 string patID,
                                 string fiscalYearID,
                                 string startDate,
                                 string endDate,
                                 defineCols dc)
    { 
      
      string viewUDF = "RECURRING_SERVICES_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @fiscalYearID, @startDate, @endDate, @active, @recID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms = new List<SqlParameter>();
      
           
      Object vClientID     = Validate.optClientID (uInfo, clientID);
      Object vPatID        = Validate.optInteger  (patID,        Messages.INVALID_PAT_ID);
      Object vFiscalYearID = Validate.optInteger  (fiscalYearID, Messages.INVALID_FISCAL_YEAR_ID);
      
      Object[]  vDates     = Validate.optStartAndEndDate (startDate, endDate, Messages.INVALID_DATE_RANGE);      
      Object    vStartDate = vDates[0];
      Object    vEndDate   = vDates[1];
      
      parms.Add(Database.SqlParm("@clientID",     SqlDbType.Int,      vClientID,     ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",        SqlDbType.Int,      vPatID,        ParameterDirection.Input));
      parms.Add(Database.SqlParm("@fiscalYearID", SqlDbType.Int,      vFiscalYearID, ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",    SqlDbType.DateTime, vStartDate,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",      SqlDbType.DateTime, vEndDate,      ParameterDirection.Input));
    
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
      
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      

    }  
   
   /***************************************************************************
    * viewTbl */
   /**
    * Returns a data table of records for preview or record selection.
    * 
    * @return                 ReturnDataTable
    ***************************************************************************/

   public static ReturnDataTable viewTbl(SqlConnection connSpedmon, DetailsLog log, UserInfo uInfo,
                                          bool   paged,
                                          string pageNumber,
                                          string clientID,
                                          string patID,
                                          string fiscalYearID,
                                          string startDate,
                                          string endDate,
                                          string canEdit,
                                          string active)
   {
     ReturnDataTable so = new ReturnDataTable();
     
     /*----------------------------
      * Define our columns and
      * set the page order for 
      * paging
      * 
      * TODO: Rewrite 
      *----------------------------*/

     defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
     {
       ss.addDisplayColumn("id");
       ss.addDisplayColumn("clientName as [Client]",                       true);       
       ss.addDisplayColumn("patientName as [Patient Name (Last, First)]",  true);
       ss.addDisplayColumn("startDateStr as [Start Date]",                 true);
       ss.addDisplayColumn("endDateStr as [End Date]",                     true);          
       ss.addDisplayColumn("fiscalYearName as [Fiscal Year]",              true);
       pageroworder = ss.pageRowOrder();

     };

     /*----------------------------
      * Call base method which
      * handles the rest 
      *----------------------------*/

     so = Entities.viewTbl(connSpedmon, log, uInfo, paged, pageNumber,
       delegate { return RecurringServices.view(connSpedmon, log, uInfo, Entities.REC_VIEW_TBL, paged, pageNumber, canEdit, active, clientID, patID, fiscalYearID, startDate, endDate, dc); });
   
     /*----------------------------
      * Add a title and footer
      *----------------------------*/
                   
     so.tableName   = "Recurring Services";
     so.tableFooter = Messages.CONFIDENTIAL;
     
     /*----------------------------
      * Done
      *----------------------------*/

     return so;
     
    }            
  }
} 

