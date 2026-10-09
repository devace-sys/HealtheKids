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
     * userSignatures */
    /**
     *
     ***************************************************************************/

    public class UserSignatures : Entities
    {

        /***************************************************************************
         * loadN */
        /**
         * Outputs data for a single record
         *
         * Note: This calls the view method and the view method takes care of
         * enforcing the client id.
         *
         * @param  connSpedmon     Spedmon database connection object
         * @param  log             Logging object
         * @param  clientID        Client ID
         * @param  patID           PatID
         * @return                 ReturnEntity
         ***************************************************************************/

        public static userSignature loadN(SqlConnection connUser
                                       , DetailsLog log
                                       , UserInfo uInfo
                                       , int    n
                                       , string signatureUserID
                                       , string signaturePersonID
                                       , string recID)
        {
            return MBA.UserSignatures.loadN(connUser, log, uInfo, Constants.APP_NAME, n, signatureUserID, signaturePersonID, recID);
        }
        
    }
}
