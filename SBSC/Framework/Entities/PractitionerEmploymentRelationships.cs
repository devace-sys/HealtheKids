using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
 
  /***************************************************************************
   * PractitionerEmploymentRelationship */
  /**
   * 
   **************************************************************************/  
  public class PractitionerEmploymentRelationship : Entity
  {
    public const string DEFAULT_PAGING_ORDER = @"startDate asc";

    public long   clientID;
	public long   pracID;
	public long   employeeRelationshipID;
    public string employeeRelationshipName;
    public string startDateStr;
    public string endDateStr;
    public string startDateYYYYMMDDStr;
    public string endDateYYYYMMDDStr;
  }
  
  /***************************************************************************
   * PractitionerEmploymentRelationships */
  /**
   * 
   **************************************************************************/

  public class PractitionerEmploymentRelationships: Entities
  {
    public const string SEL_LABEL                   = @"Practitioner Employment Relationships";
    public const string URL_SERVICE_BASE            = @"practitioner_employment_relationships.asmx";
    public const string URL_SAVE_INLINE_BASE        = URL_SERVICE_BASE + @"/saveinline";
    public const string URL_DELETE_INLINE_BASE      = URL_SERVICE_BASE + @"/deleteinline";
    public const string URL_REST_VIEW_BASE          = @"api/v1/practitioneremploymentrelationships";

    /***************************************************************************
     * URL_SAVE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_SAVE_INLINE()
    {
      return MBA.HttpApplication.createLink ( PractitionerEmploymentRelationships.URL_SAVE_INLINE_BASE
                                             , true
                                            );
    }

    /***************************************************************************
     * URL_DELETE_INLINE */
    /**
     * 
     **************************************************************************/ 

    public static string URL_DELETE_INLINE()
    {
        return MBA.HttpApplication.createLink( PractitionerEmploymentRelationships.URL_DELETE_INLINE_BASE
                                              , true
                                              );
    }

    /***************************************************************************
     * URL_REST_VIEW */
    /**
     * 
     **************************************************************************/  
    public static string URL_REST_VIEW()
    { 
       return MBA.HttpApplication.createLink(  PractitionerEmploymentRelationships.URL_REST_VIEW_BASE
                                             , true
                                             );
    }
 
    /***************************************************************************
     * generateEmploymentRelationshipSelectionNvpString */
    /**
     * 
     **************************************************************************/ 
 
    public static string generateEmploymentRelationshipSelectionNvpString ()
    {
      var sb = new StringBuilder();
      sb.Append       (@"[{name:'',value:''}");
      sb.AppendFormat (@",{{name:'{0}',value:'{1}'}}", "Employee",        (int) EmploymentRelationship.EMPLOYEE); 
      sb.AppendFormat (@",{{name:'{0}',value:'{1}'}}", "Contractor",      (int) EmploymentRelationship.CONTRACTOR); 
      sb.AppendFormat (@",{{name:'{0}',value:'{1}'}}", "No Relationship", (int) EmploymentRelationship.NONE); 
      sb.Append       (@"]");
      return sb.ToString();
    }

    /***************************************************************************
     * view */
    /**
     * Returns ReturnDB.  Base method use for other views.
     **************************************************************************/

    public static ReturnDB view (  SqlConnection connSpedmon
                                 , DetailsLog    log
                                 , UserInfo      uInfo
                                 , int           recViewType
                                 , bool          pagedOrTop
                                 , string        idx
                                 , string        canEdit
                                 , string        active
                                 , string        clientID
                                 , string        pracID                                 
                                 , defineCols    dc)
    {
                  
      var viewUDF = "PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @recID, @canEdit, @active)";
      var parms   = new List<SqlParameter>();
 
      /*----------------------------
       * Validate parameters specific
       * to this entity.view that 
       * will be used in all cases
       *----------------------------*/  
      
      long  vClientID  = Validate.reqClientID (uInfo, clientID);
      long  vPracID    = Validate.reqPracID   (uInfo, pracID);
              
      /*----------------------------
       * Populate database parameters
       *----------------------------*/
      
      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt, vClientID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt, vPracID,     ParameterDirection.Input));
      
      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
        
      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
    }

    
    /***************************************************************************
     * viewObjects 
     *
     * Returns a list of objects
     * 
     ***************************************************************************/

    public static ReturnObjects viewObjects ( SqlConnection connSpedmon
                                             , DetailsLog log
                                             , UserInfo uInfo
                                             , bool pageObjectList
                                             , string pageOrder
                                             , string idx
                                             , string active
                                             , string clientID 
                                             , string pracID )
 
    {
 
        /* Default page order */
 
        if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerEmploymentRelationship.DEFAULT_PAGING_ORDER;
 
        /* Define columns delegate is used to specify columns and page order 
         * We pass in the desired page row order here */
 
        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            pageroworder = pageOrder;
        };
 
        return Entities.viewObjects (   connSpedmon
                                      , log
                                      , uInfo
                                      , typeof(PractitionerEmploymentRelationship)
                                      , pageObjectList
                                      , pageOrder
                                      , delegate {
                                          return PractitionerEmploymentRelationships.view (   connSpedmon
                                                                                            , log
                                                                                            , uInfo
                                                                                            , Entities.REC_VIEW_OBJECTS
                                                                                            , pageObjectList
                                                                                            , idx
                                                                                            , "" /* Can edit */
                                                                                            , active
                                                                                            , clientID
                                                                                            , pracID
                                                                                            , dc);
                                      });
 
 
    }
 
    /***************************************************************************
     * delete */
    /**
     * "Deletes" record
     * 
     * @param  editDelReason   Reason for edit/delete 
     * @param  validateRec     Perform validation for this record?
     * @param  recID           Record id reference for edit and delete
     * @return                 ReturnSaveNewRecord
     ***************************************************************************/   
  
    public static ReturnSaveRecord delete (  SqlConnection   connSpedmon
                                           , DetailsLog      log
                                           , UserInfo        uInfo
                                           , string          editDelReason
                                           , string          validateRec
                                           , string          clientID
                                           , string          pracID
                                           , string          recID )
    {           
                
      var deleteSproc = @"PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_DELETE";
    
      /*###########################################################################
        # Validate parameters specific to this entity delete and create their 
        # database parameters.
        ###########################################################################*/  

      /*----------------------------
       * Validate parameters specific
       * to this entity.view that 
       * will be used in all cases
       *----------------------------*/  
      
      long  vClientID  = Validate.reqClientID (uInfo, clientID);
      long  vPracID    = Validate.reqPracID   (uInfo, pracID);
              
      /*----------------------------
       * Populate database parameters
       *----------------------------*/

      var parms = new List<SqlParameter>();      

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt, vClientID,   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt, vPracID,     ParameterDirection.Input));
      
      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.delete(connSpedmon,log,uInfo,editDelReason,validateRec,recID,deleteSproc,ref parms);

    }

    /***************************************************************************
     * save 
     *
     * Returns ReturnSaveRecord
     * 
     ***************************************************************************/

    public static ReturnSaveRecord save (  SqlConnection connSpedmon
                                         , DetailsLog    log
                                         , UserInfo      uInfo
                                         , string        clientID
										 , string        pracID
                                         , string        employeeRelationshipID
										 , string        startDate
										 , string        endDate
                                         , string        notes
                                         , string        editDelReason
                                         , string        validateRec
                                         , string        saveType
                                         , string        recID )
    {

        var saveSproc = @"PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_SAVE";
        
      /*###########################################################################
        # Validate parameters specific to this entity save and create their 
        # database parameters.
        ###########################################################################*/  

      /*----------------------------
       * Validate parameters specific
       * to this entity.view that 
       * will be used in all cases
       *----------------------------*/  
      
      long     vClientID              = Validate.reqClientID (uInfo, clientID);
      long     vPracID                = Validate.reqPracID   (uInfo, pracID);
      long     vEmployeeRelationship  = Validate.reqInteger  (employeeRelationshipID,  Messages.INVALID_EMPLOYEE_RELATIONSHIP);
      DateTime vStartDate             = Validate.reqDate     (startDate,               Messages.INVALID_START_DATE, Constants.VAL_OPT_DATE_NO_FUTURE);
      DateTime vEndDate               = Validate.reqDate     (endDate,                 Messages.INVALID_END_DATE,   Constants.VAL_OPT_DATE_NO_FUTURE);
      string   vNotes                 = Validate.optString   (notes,                   Messages.INVALID_NOTES);

      /*----------------------------
       * Populate database parameters
       *----------------------------*/

      var parms = new List<SqlParameter>();      

      parms.Add(Database.SqlParm("@clientID",                 SqlDbType.BigInt,   vClientID,                  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@pracID",                   SqlDbType.BigInt,   vPracID,                    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@employeeRelationship",     SqlDbType.BigInt,   vEmployeeRelationship,      ParameterDirection.Input));
      parms.Add(Database.SqlParm("@startDate",                SqlDbType.DateTime, vStartDate,                 ParameterDirection.Input));
      parms.Add(Database.SqlParm("@endDate",                  SqlDbType.DateTime, vEndDate,                   ParameterDirection.Input));
      parms.Add(Database.SqlParm("@notes",                    SqlDbType.VarChar,  vNotes,                     ParameterDirection.Input, -1));

      /*###########################################################################
        # Call base method which handles the rest and returns the results
        ###########################################################################*/  

      return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, @"This relationship already exists for this practitioner or it overlaps an existing", ref parms, null);
    }
  }
}