using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Services.Protocols;
using System.Web.Script.Serialization;
using System.ComponentModel;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using MBA;
using System.IO;


namespace Spedmon
{
    /****************************************************************************
     * ClientInvoicesSvc */
    /*
     * 
     ****************************************************************************/

    [WebService(Namespace = "http://spedcare.com/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ScriptService]
    public class ClientInvoicesSvc : MBA.WebSvc
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savedepositinfo(
             string clientid
           , string recid

           , string depositdate
           , string distributeddate
           , string distributionnotes
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ClientInvoices.save(
                       this.dbConnApp
                    , this.log
                    , this.uInfo

                    , clientid

                    , ""  //  editDelReason
                    , "0" // validateRec
                    , "2" // savetype; add-new not supported
                    , recid

                    , null // notes

                    , false
                    , false    // pmtinfo
                    , true     // deposit info
                    , depositdate

                    , null // datecollected
                    , null //amountpaid
                    , distributeddate
                    , distributionnotes
                    );

            },
            Constants.ROLE_ADMIN);

        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savepmtinfo(
             string clientid
           , string recid
           , string datecollected
           , string amountpaid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                return Spedmon.ClientInvoices.save(
                       this.dbConnApp
                    , this.log
                    , this.uInfo

                    , clientid

                    , ""  //  editDelReason
                    , "0" // validateRec
                    , "2" // savetype; add-new not supported
                    , recid

                    , null // notes

                    , false
                    , true    // pmtinfo
                    , false
                    , null

                    , datecollected
                    , amountpaid
                    );

            },
            Constants.ROLE_ADMIN);

        }

        public ClientInvoicesSvc() : base() { }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord savenotes(
             string clientid
           , string notes
           , string recid
        )
        {
            return (ReturnSaveRecord)

            callMethod(typeof(ReturnSaveRecord),
            delegate ()
            {
                    return Spedmon.ClientInvoices.save(
                           this.dbConnApp
                        ,  this.log
                        ,  this.uInfo

                        ,  clientid

                        ,  ""  //  editDelReason
                        ,  "0" // validateRec
                        ,  "2" // savetype; add-new not supported
                        ,  recid

                        ,  notes

                    );
            },
            Constants.ROLE_MANAGE_INVOICES );

        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnObjects gettotals(
                      string clientid
                    , string daterange
                    , string invoicepaid
                    , string distbpaid
                    //, string distbpaiddaterange

                    , string invcolldaterange

                    , string calcshares

                    , string inclpartner1col
                    , string inclretentioncol 
                    , string inclcybhirows
                    , string inclcybhirowsonly
                    )
        {

            return (ReturnObjects)

            callMethod(typeof(ReturnObjects),
            delegate ()
            {

                return Spedmon.ClientInvoices.getTotals(
                  this.dbConnApp
                , this.log
                , this.uInfo

                ,  clientid

                , invoicepaid

                ,  daterange

                ,  distbpaid

                // ,  distbpaiddaterange

                ,  invcolldaterange

                , calcshares

                ,  inclpartner1col
                ,  inclretentioncol
                ,  inclcybhirows
                ,  inclcybhirowsonly
                );
            },
            Constants.ROLE_MANAGE_INVOICES);
        }

        /***************************************************************************
         * deletemultiinline */
        /**
         *        
         ***************************************************************************/

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public ReturnSaveRecord bulkupdatedistribdate(
              string  clientid
            , string  distbpaid
            , string  recids )
        {
            return (ReturnSaveRecord) callMethod(
                typeof(ReturnSaveRecord),
                delegate ()
                {
                    return Spedmon.ClientInvoices.saveBulkUpdateDistribDate(
                    this.dbConnApp
                  , this.log
                  , this.uInfo
                  , clientid
                  , distbpaid
                  , ""   
                  , "0"  
                  , recids );
                },
                Constants.ROLE_ADMIN);  
        }


    }



}

