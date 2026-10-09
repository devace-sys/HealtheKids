
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
    /***************************************************************************
     * PractitionerSite */
    /**
     * 
     *************************************************************************/

    public class PractitionerSite : Entity
    {
        public const string DEFAULT_PAGING_ORDER = @"clientName asc, id desc";
        
	    public long    clientID;
        public long    pracID;
        public long    siteID;  
        public string  clientName;
	    public string  pracName;
	    public string  siteName;
    }

    /***************************************************************************
     * PractitionerSites */
    /**
     * 
     *************************************************************************/

    public class PractitionerSites:Entities
    {

        public const string URL_WEB_SERVICE                  = @"practitioner_sites.asmx";
        public const string URL_REST_PRACSITES_SAVE_INLINE  = URL_WEB_SERVICE + @"/saveinline";
        public const string URL_PRACTITIONER_SITES_REST_VIEW   = "api/v1/practitionersites";
        
		public static string URL_REST_PRACSITES_SAVE_INLINE_BASE()
        {
            return MBA.HttpApplication.createLink( URL_REST_PRACSITES_SAVE_INLINE, true);
        }

        public static string URL_PRACTITIONER_SITES_REST_VIEW_BASE()
        {
            return MBA.HttpApplication.createLink(URL_PRACTITIONER_SITES_REST_VIEW, true);
        }

        /***************************************************************************
         * view */
        /**
         * 
         *************************************************************************/

        public static ReturnDB view (  SqlConnection connSpedmon
		                              , DetailsLog   log
									  , UserInfo     uInfo
                                      , int          recViewType
                                      , bool         pagedOrTop
                                      , string       idx
                                      , string       canEdit
                                      , string       clientID
                                      , string       pracID
                                      , string       active
                                      , defineCols   dc )
        {

            /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            int vClientID = Validate.reqClientID (uInfo, clientID);
            int vPracID    = Validate.reqPracID    (uInfo, pracID);
            //int vSiteID    = Validate.reqSiteID    (uInfo, siteID);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@pracID",    SqlDbType.Int, vPracID,    ParameterDirection.Input));
			//parms.Add(Database.SqlParm("@siteID",    SqlDbType.Int, vSiteID,    ParameterDirection.Input));


            string viewUDF = " dbo.PRACTITIONER_SITES_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @active, @recID )";

            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view(connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);

        }
        
        /***************************************************************************
         * viewObjects */
        /**
         * 
         *************************************************************************/

        public static ReturnObjects viewObjects (  SqlConnection connSpedmon
                                                  , DetailsLog   log
                                                  , UserInfo     uInfo
                                                  , bool         pageObjectList
                                                  , string       pageOrder
                                                  , string       idx
                                                  , string       active
                                                  , string       clientID
                                                  , string       pracID
												  )
        {

            /* Default page order */
            
            if (String.IsNullOrWhiteSpace(pageOrder)) pageOrder = PractitionerSite.DEFAULT_PAGING_ORDER;

            /* Define columns delegate is used to specify columns and page order 
             * We pass in the desired page row order here */

            defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
            {
                pageroworder = pageOrder;
            };

            return Entities.viewObjects(connSpedmon
                                          , log
                                          , uInfo
                                          , typeof(PractitionerSite)
                                          , pageObjectList
                                          , pageOrder
                                          , delegate
                                          {
                                              return PractitionerSites.view (  connSpedmon
                                                                                    , log
                                                                                    , uInfo
                                                                                    , Entities.REC_VIEW_OBJECTS
                                                                                    , pageObjectList
                                                                                    , idx
                                                                                    , "" /*canEdit*/
                                                                                    , clientID
                                                                                    , pracID                                                                                   
                                                                                    , active
                                                                                    , dc);
                                          });

        }
        
        /***************************************************************************
         * save */
        /**
         * 
         *************************************************************************/
		
        public static ReturnSaveRecord save (   SqlConnection connSpedmon
                                              , DetailsLog    log
                                              , UserInfo      uInfo
                                              , string        clientID
                                              , string        pracID
                                              , string        siteID
                                              , string        editDelReason
                                              , string        validateRec
                                              , string        saveType
                                              , string        recID  )
        {

            string saveSproc = @"PRACTITIONER_SITES_SAVE";

            string dupRecMsg = @"Entry already exists";  
            
            var  vClientID  = Validate.reqClientID  (uInfo, clientID);
            var  vPracID    = Validate.reqPracID    (uInfo, pracID);
            var  vSiteID    = Validate.reqInteger   (siteID,   @"Please select a valid site");
            
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",  SqlDbType.BigInt,  vClientID,   ParameterDirection.Input));          
            parms.Add(Database.SqlParm("@pracID",    SqlDbType.BigInt,  vPracID,     ParameterDirection.Input));
            parms.Add(Database.SqlParm("@siteID",    SqlDbType.BigInt,  vSiteID,     ParameterDirection.Input));

            return Entities.save(connSpedmon, log, uInfo, saveType, validateRec, editDelReason, recID, saveSproc, dupRecMsg, ref parms, null);

        }
		
    }

}
