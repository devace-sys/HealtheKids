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
   * SitePlaces */
  /**
   *
   ***************************************************************************/
  
  public class SitePlaces : Entities
  {
    
    public const string URL_SERVICE_BASE            = @"site_places.asmx";
    public const string URL_VIEW_SEL                = URL_SERVICE_BASE + @"/viewSel";

    public static string URL_VIEW_SEL_BASE()
    {
      return MBA.HttpApplication.createLink(SitePlaces.URL_VIEW_SEL, true);
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
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.SITE_PLACES_VIEW (@userID, @userGroup, @userRank, @clientID, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long    vClientID  = Validate.reqClientID (uInfo, clientID);
      string  vTerm      = Validate.optString   (term,  @"Invalid search term");

      parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,  vClientID,  ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",      SqlDbType.VarChar, vTerm,     ParameterDirection.Input, 255));

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
                                  return SitePlaces.view (  connSpedmon
                                                           , log
                                                           , uInfo
                                                           , Entities.REC_VIEW_SEL
                                                           , top
                                                           , topSize
                                                           , ""
                                                           , "Y"
                                                           , clientID
                                                           , term
	                                                         , dc ); 
                                });
                                                                    
    }


  }
}
