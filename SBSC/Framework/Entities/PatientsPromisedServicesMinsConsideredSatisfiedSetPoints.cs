using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;
 
namespace Spedmon
{    
  /***************************************************************************
   * PatientsPromisedServicesMinsConsideredSatisfiedSetPoint */
  /**
   *
   ***************************************************************************/
   
  public class PatientsPromisedServicesMinsConsideredSatisfiedSetPoint : Entity
  {
    public long     clientID;
    public int      minMinsPerFreqDaily;
    public int      minMinsPerFreqWeekly;
    public int      minMinsPerFreqMonthly;
  }  
  
  /***************************************************************************
   * PatientsPromisedServicesMinsConsideredSatisfiedSetPoints */
  /**
   *
   ***************************************************************************/

  public class PatientsPromisedServicesMinsConsideredSatisfiedSetPoints: Entities
  {

    public const string URL_SERVICE_BASE       = @"patients_promised_services_mins_considered_satisfied_setpoints.asmx";
    public const string URL_SERVICE_SAVE_BASE  = URL_SERVICE_BASE + @"/save";
    public const string URL_SERVICE_GET_BASE   = URL_SERVICE_BASE + @"/get";
                                                                   
    /***************************************************************************
     * URL_SERVICE_SAVE */
    /**
     * 
     **************************************************************************/ 
    
	public static string URL_SERVICE_SAVE()
    {
      return MBA.HttpApplication.createLink(PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.URL_SERVICE_SAVE_BASE, true);
    }
	
    /***************************************************************************
     * URL_SERVICE_GET */
    /**
     * 
     **************************************************************************/     
	public static string URL_SERVICE_GET()
    {
      return MBA.HttpApplication.createLink(PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.URL_SERVICE_GET_BASE, true);
    }

   /*************************************************************************
    * view */
   /**
    * Base method for viewing data.  Not meant for direct use.
    * 
    * NOTE: At present there is only one record per client.  This will change
    * when we can expand the management of this data.  At this time this note
    * should be removed.
    **************************************************************************/   

   public static ReturnDB view (   SqlConnection connSpedmon
                                  , DetailsLog    log
                                  , UserInfo      uInfo
                                  , int           recViewType
                                  , bool          pagedOrTop
                                  , string        idx
                                  , string        canEdit
                                  , string        active   
                                  , string        clientID
                                  , defineCols    dc )
    {
      
      string viewUDF = "dbo.Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_View (@userID, @userGroup, @userRank, @clientID)";

      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      var vClientID = Validate.reqClientID (uInfo, clientID);

      var parms = new List<SqlParameter>();   
      
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
      
    }
 
    /***************************************************************************
     * load */
    /**
     * Load current record
     * 
     * TODO: Refactor into a regular load method when we can expand the 
     * management of this data.  Until then there is only one record per client.
     *
     **************************************************************************/
 
    public static PatientsPromisedServicesMinsConsideredSatisfiedSetPoint load (  SqlConnection connSpedmon
                                                                                 , DetailsLog    log
                                                                                 , UserInfo      uInfo
                                                                                 , string        clientID )
    {
        var so = new PatientsPromisedServicesMinsConsideredSatisfiedSetPoint();

        so = (PatientsPromisedServicesMinsConsideredSatisfiedSetPoint) Entities.loadNRecord (  connSpedmon
                                                      , log
                                                      , uInfo
                                                      , 0
                                                      , typeof(PatientsPromisedServicesMinsConsideredSatisfiedSetPoint)
                                                      , delegate { 
                                                          return PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.view ( 
                                                                                                  connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_RAW                                                                                           
                                                                                                , false
                                                                                                , ""
                                                                                                , ""
                                                                                                , ""
                                                                                                , clientID
                                                                                                , null );});               
        return so;
      }
        
      /***************************************************************************
       * get */
      /**
       * Load current record and put in a ReturnEntity class for easy transport.
       * 
       * TODO: This is a temporary method until we can expand the management of
       * this data.  Until then there is only one record per client.
       **************************************************************************/
 
      public static ReturnEntity get (  SqlConnection connSpedmon
                                        , DetailsLog    log
                                        , UserInfo      uInfo
                                        , string        clientID)
      {
        var so = new ReturnEntity();
        so.entity = PatientsPromisedServicesMinsConsideredSatisfiedSetPoints.load(connSpedmon,log,uInfo,clientID);
        return so;
      }

     /***************************************************************************
      * save */
     /**      
      * Saves new or replaces existing record based on clientID.
      * 
      * @parm minMinsPerFreqDaily   The min num of minutes for daily plans
      * @parm minMinsPerFreqWeekly  The min num of minutes for weekly plans
      * @parm minMinsPerFreqMonthly The min num of minutes for monthly plans
      *
      * TODO: Convert this from a saveOrReplace style procedure to a normal 
      * save procedure once we are able to expand the management of this data.
      * Until then there is only one record per client.
      ***************************************************************************/   

      public static ReturnSaveOrReplaceRecord save  (   SqlConnection connSpedmon
                                                      , DetailsLog    log
                                                      , UserInfo      uInfo
                                                      , string        clientID
                                                      , string        minMinsPerFreqDaily
                                                      , string        minMinsPerFreqWeekly
                                                      , string        minMinsPerFreqMonthly
                                                      , string        notes
                                                      , string        validateRec )
      {           
            
       string saveOrReplaceSproc = "Patients_Promised_Services_Mins_Considered_Satisfied_Set_Points_Save";                

       /*-------------------------------
        * Validate parameters
        *----------------------------*/
		   
       long     vClientID              = Validate.reqClientID (uInfo, clientID);
       Object   vMinMinsPerFreqDaily   = Validate.optInteger  (minMinsPerFreqDaily,   @"Invalid daily minutes",  true);
       Object   vMinMinsPerFreqWeekly  = Validate.optInteger  (minMinsPerFreqWeekly,  @"Invalid weekly minutes", true);
       Object   vMinMinsPerFreqMonthly = Validate.optInteger  (minMinsPerFreqMonthly, @"Invalid monthly minutes",true);
       string   vNotes                 = Validate.optString   (notes,                 Messages.INVALID_NOTES);

       /*----------------------------
        * Pass parm values to sp
        *----------------------------*/  

       var parms = new List<SqlParameter>();  

 	   parms.Add(Database.SqlParm ("@clientID",               SqlDbType.BigInt,  vClientID,               ParameterDirection.Input));
       parms.Add(Database.SqlParm ("@minMinsPerFreqDaily",    SqlDbType.Int,     vMinMinsPerFreqDaily,    ParameterDirection.Input));
       parms.Add(Database.SqlParm ("@minMinsPerFreqWeekly",   SqlDbType.Int,     vMinMinsPerFreqWeekly,   ParameterDirection.Input));
       parms.Add(Database.SqlParm ("@minMinsPerFreqMonthly",  SqlDbType.Int,     vMinMinsPerFreqMonthly,  ParameterDirection.Input));
       parms.Add(Database.SqlParm ("@notes",                  SqlDbType.VarChar, vNotes,                  ParameterDirection.Input,-1));
                       
       /*----------------------------
        * Call base method which 
        * handles the rest and return
        * results
        *----------------------------*/  

       ReturnSaveOrReplaceRecord so = Entities.saveOrReplaceRecord ( connSpedmon
                                             , log
                                             , uInfo
                                             , validateRec
                                             , saveOrReplaceSproc
                                             , ref parms
                                             , delegate(){});
            
       return so;

    }
  }
}