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
   * TransportationMgmtRecord */
  /**
   *
   ***************************************************************************/

  public class TransportationMgmtRecord : Entity
  {
    public long    clientID;
    public string  clientName;
    public long    pracID;
    public string  pracName;
    public int     sasSubscriptionType = 0; /* 0 = Free */        
  }
      
  /***************************************************************************
   * TransportationMgmtRecords */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtRecords : Entities
  {
    public const string SEL_LABEL                               = @"Transportation Services";
    public const string SEL_LABEL_MANAGE                        = @"Manage Patients and Routes";
    public const string SEL_LABEL_PROCESS_INCOMING_SHEET        = @"Enter Completed SpEdCare Route Sheet";
    public const string SEL_LABEL_MANAGE_SERVICE_RECORDS        = @"Manage Held Transportation Records";
    
    public const string PARM_NAME_TMGMT_SCREEN                  = @"tmgmtscrn";
    public const string PARM_VALUE_TMGMT_SCREEN_1               = @"1";
    public const string PARM_VALUE_TMGMT_SCREEN_2               = @"2";
          
    public const string URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES = @"user_all_transportation_patients_and_routes_manage.aspx";        
    public const string URL_USER_ALL_MANAGE_PATIENTS_AND_ROUTES_OLD = @"user_all_transport_mgmt_manage_patients_and_routes.aspx";        
    public const string URL_USER_ALL_MANAGE_SERVICE_RECORDS     = @"user_all_transport_mgmt_manage_svc_recs.aspx";
 
    public const string URL_SBS_ALL_PROCESS_INCOMING_SHEET      = @"sbs_all_transport_mgmt_process_incoming_route_sheet.aspx";    
    public const string URL_CLIENT_COOR_PROCESS_INCOMING_SHEET  = @"client_coor_transport_mgmt_process_incoming_route_sheet.aspx";
    public const string URL_CLIENT_PROV_PROCESS_INCOMING_SHEET  = @"client_prov_transport_mgmt_process_incoming_route_sheet.aspx";

    public const string URL_USER_ALL_MANAGE                     = @"user_all_transport_manage.aspx";
         
    /***************************************************************************
     * view */
    /**
     *
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
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_VIEW (@userID, @userGroup, @userRank, @clientID, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long  vClientID  = Validate.reqClientID (uInfo, clientID); 
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));

      /*----------------------------
       * Call base method which
       * handles the rest and return
       * results
       *----------------------------*/
       
      return Entities.view (  connSpedmon
                            , log
                            , uInfo
                            , recViewType
                            , pagedOrTop
                            , idx
                            , canEdit
                            , active
                            , viewUDF
                            , ref parms
                            , null
                            , dc );    
    }

    /***************************************************************************
     * loadCurrent */
    /**
     *
     **************************************************************************/  

    public static TransportationMgmtRecord loadCurrent (   SqlConnection connSpedmon
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo
                                                        , string        clientID )
    {
    
         int n = 0;
         return (TransportationMgmtRecord) Entities.loadNRecord (  connSpedmon
                                                       , log
                                                       , uInfo
                                                       , n
                                                       , typeof (TransportationMgmtRecord)
                                                       , delegate { 
                                                         return TransportationMgmtRecords.view (   connSpedmon
                                                                                                 , log
                                                                                                 , uInfo
                                                                                                 , Entities.REC_VIEW_LOAD_N
                                                                                                 , false
                                                                                                 , "" 
                                                                                                 , ""
                                                                                                 , "Y"
                                                                                                 , clientID
                                                                                                 , null ); 
          });
 
    }
    
    /***************************************************************************
     * autoCreateOrUpdate */
    /**
     *
     **************************************************************************/  

    public static ReturnSaveRecord autoCreateOrUpdate (   SqlConnection connSpedmon
                                                        , DetailsLog    log
                                                        , UserInfo      uInfo    
                                                        , string        clientID ) 
    {
        
      
      ReturnSaveRecord rd = new ReturnSaveRecord();
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.save
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/
       
      List<SqlParameter> parms = new List<SqlParameter>();
     
      long  vClientID = Validate.reqClientID (uInfo, clientID);
	  
      parms.Add(Database.SqlParm("@clientID", SqlDbType.BigInt, vClientID, ParameterDirection.Input));
	  
      return Entities.save (  connSpedmon
                            , log
                            , uInfo
                            , Constants.SAVE_TYPE_NEW.ToString()
                            , "0"
                            , ""
                            , ""
                            , "TRANSPORTATION_MGMT_RECORD_AUTO_CREATE_OR_UPDATE"
                            , "Duplicate record"
                            , ref parms
                            , null );
    }
    
 
  }
}