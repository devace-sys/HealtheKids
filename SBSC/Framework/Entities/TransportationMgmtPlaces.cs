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
   * TransportationMgmtPlace */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtPlace
  {
    public string  placeID;
    public long    placeClass;
    public string  name;
    public string  address1;
    public string  address2;
    public string  city;
    public string  state;
    public string  zip5;
    public string  zip4;
    public bool    active;
    public string  placeAddress;
    public long    id;
  }
  
  /***************************************************************************
   * TransportationMgmtPlaces */
  /**
   *
   ***************************************************************************/
  
  public class TransportationMgmtPlaces : Entities
  {
  
    public const string URL_WEB_SERVICE  = @"transport_mgmt_places.asmx";
    public const string URL_VIEW_SEL     = URL_WEB_SERVICE + @"/viewSel";

    public static string URL_VIEW_SEL_BASE()
    {
        return MBA.HttpApplication.createLink(TransportationMgmtPlaces.URL_VIEW_SEL, true);
    }

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
								                  , string        patID
                                  , string        placeID
                                  , bool          quickPlaceIdLookup
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.TRANSPORTATION_MGMT_PLACES_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @term, @active, @placeID, @quickPlaceIdLookup)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      Object    vClientID  = Validate.optClientID (uInfo,   clientID);
      Object    vPatID     = Validate.optInteger  (patID,   @"Invalid patient id"); 
      string    vPlaceID   = Validate.optString   (placeID, @"Invalid place id");
      string    vTerm      = Validate.optString   (term,    @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,  vClientID,          ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt,  vPatID,             ParameterDirection.Input));      
      parms.Add(Database.SqlParm("@placeID",              SqlDbType.VarChar, vPlaceID,           ParameterDirection.Input, 255));
      parms.Add(Database.SqlParm("@term",                 SqlDbType.VarChar, vTerm,              ParameterDirection.Input, 255));
      parms.Add(Database.SqlParm("@quickPlaceIdLookup",   SqlDbType.Bit,     quickPlaceIdLookup, ParameterDirection.Input));

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
     * viewSel */
    /**
     *
     * @return                 ReturnDataTable
     ***************************************************************************/

    public static ReturnSel viewSel (   SqlConnection connSpedmon
                                      , DetailsLog    log
                                      , UserInfo      uInfo
                                      , bool          top
                                      , string        topSize
                                      , string        clientID
									                    , string        patID
									                    , string        placeID                                      
                                      , string        term )
    {

        /*----------------------------
         * Define our context column
         *----------------------------*/

        defineCols dc = delegate(ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {                     
           ss.addDisplayColumn("placeAddress as context1"); 
           ss.addDisplayColumn("placeAddress as recData1");
           ss.addDisplayColumn("placeID      as recData2");
           
        };

        /*----------------------------
         * Call base method which
         * handles the rest and return
         * results
         *----------------------------*/

        return Entities.viewSel(  connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate { 
                                  return TransportationMgmtPlaces.view (   connSpedmon
                                                                         , log
                                                                         , uInfo
                                                                         , Entities.REC_VIEW_SEL
                                                                         , top
                                                                         , topSize
                                                                         , ""
                                                                         , "Y"
                                                                         , clientID
																					                               , patID																					                               
                                                                         , placeID
                                                                         , false
                                                                         , term                                                                         
                                                                         , dc ); 
                                });
                                                                    
    }

    /***************************************************************************
     * load */
    /**
     *
     * @return  TransportationMgmtPlace 
     ***************************************************************************/
    
    public static TransportationMgmtPlace load (  SqlConnection connSpedmon
                                                , DetailsLog    log
                                                , UserInfo      uInfo
                                                , string        clientID
									                              , string        patID
									                              , string        placeID )
    
    {
      
      return (TransportationMgmtPlace) Entities.load(   connSpedmon
                                                      , log
                                                      , uInfo
                                                      , typeof (TransportationMgmtPlace)
                                                      , delegate {          
                                                        return TransportationMgmtPlaces.view (    connSpedmon
                                                                                                , log
                                                                                                , uInfo
                                                                                                , Entities.REC_VIEW_RAW
                                                                                                , false
                                                                                                , null
                                                                                                , ""
                                                                                                , "Y"
                                                                                                , clientID
                                                                                                , patID
                                                                                                , placeID
                                                                                                , true /* Quick lookup */
                                                                                                , null                                                               
                                                                                                , null ); 
                                                     });  
    }    
  }
}
