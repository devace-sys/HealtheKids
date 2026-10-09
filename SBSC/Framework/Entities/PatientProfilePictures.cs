using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using MBA;

namespace Spedmon
{
 
    /**************************************************************************
     * ReturnPatientProfilePicture */
    /**
     **************************************************************************/

    public class ReturnPatientProfilePicture : Return
    {
        public ReturnPatientProfilePicture() : base() { }
        public ReturnPatientProfilePicture(string msg) : base(msg) { }
        public ReturnPatientProfilePicture(Exception e) : base(e) { }
        public ReturnPatientProfilePicture(Warning e) : base(e) { }
        public ReturnPatientProfilePicture(Critical e) : base(e) { }
        public ReturnPatientProfilePicture(SessionExpired e) : base(e) { }

        public PatientProfilePicture dataobj;
    }

    /**************************************************************************
     * PatientProfilePicture */
    /**
     **************************************************************************/
    public class PatientProfilePicture
    {
        public long      id;
        public long      clientID;
        public long      patID;
        public string    fileName;
        public string    profilePictureBase64;
        public DateTime  created;
        public long      createdBy;
        public DateTime? lastModified;
        public long?     lastModifiedBy;
        public bool      active;
    }

    /**************************************************************************
     * PatientProfilePictures */
    /**
     *
     **************************************************************************/

    public class PatientProfilePictures : Entities
    {
        public const string URL_WEB_SVC           = @"patient_profile_pictures.asmx";
        public const string URL_SVC_SAVE          = URL_WEB_SVC + @"/save";
        public const string URL_SVC_SAVE_THEN_GET = URL_WEB_SVC + @"/savethenget";
        public const string URL_SVC_GET           = URL_WEB_SVC + @"/get";
        
        public static string URL_SVC_SAVE_OR_REPLACE_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_SAVE_THEN_GET,true);
        }
        public static string URL_SVC_GET_BASE()
        {
            return MBA.HttpApplication.createLink(URL_SVC_GET,true);
        }
        
        /**************************************************************************
         * load */
        /**
         * 
         **************************************************************************/
        public static PatientProfilePicture load (
              SqlConnection connSpedmon
            , DetailsLog    log
            , UserInfo      uInfo
            , string        clientID
            , string        patID
            , string        recID )
        {
            return (PatientProfilePicture) Entities.load(connSpedmon, log, uInfo, typeof(PatientProfilePicture),
            delegate {
                return PatientProfilePictures.view (
                      connSpedmon
                    , log
                    , uInfo
                    , Entities.REC_VIEW_RAW
                    , false
                    , recID
                    , ""
                    , clientID
                    , patID
                    , @"Y"
                    , null );
            });
        }

        /**************************************************************************
         * view */
        /**
         * 
         **************************************************************************/
        protected static ReturnDB view (
             SqlConnection connSpedmon
           , DetailsLog    log
           , UserInfo      uInfo
           , int           recViewType
           , bool          pagedOrTop
           , string        idx
           , string        canEdit
           , string        clientID
           , string        patID
           , string        active
           , defineCols    dc )
        {
        
           /*----------------------------
             * Validate parameters specific
             * to this entity.view
             * and populate their
             * coresponding database
             * parameters
             *----------------------------*/

            var vClientID = Validate.reqClientID(uInfo, clientID);
            var vPatID    = Validate.reqPatID   (uInfo, patID);
            
            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID", SqlDbType.Int, vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID", SqlDbType.Int, vPatID, ParameterDirection.Input));

            string viewUDF = "PATIENT_PROFILE_PICTURES_VIEW ( @userID, @userGroup, @userRank, @clientID, @patID, @recID)";
            
            /*----------------------------
             * Call base method which
             * handles the rest and return
             * results
             *----------------------------*/

            return Entities.view (connSpedmon, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);
            
        }

        /**************************************************************************
         * get */
        /**
         * 
         **************************************************************************/

        public static ReturnPatientProfilePicture get (
             SqlConnection connSpedmon
           , DetailsLog    log
           , UserInfo      uInfo
           , string        clientID
           , string        patID
           , string        recID )
        {
            ReturnPatientProfilePicture so = new ReturnPatientProfilePicture();

            try { 
              so.dataobj = PatientProfilePictures.load(connSpedmon,log,uInfo,clientID,patID,recID);
            } 
            catch
            {
                so.dataobj = new PatientProfilePicture();
            }
            return so;
        }

        /***************************************************************************
         * save */
        /**
         * 
         **************************************************************************/
      
        public static ReturnSaveOrReplaceRecord save (
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        patID
          , string        fileName
          , string        profilePictureBase64
          , string        validateRec )
        {
            ReturnSaveOrReplaceRecord rd = new ReturnSaveOrReplaceRecord();
            
            var vClientID                = Validate.reqClientID(uInfo, clientID);
            var vPatID                   = Validate.reqInteger(patID, @"Invalid patient ID");
            var vFileName                = Validate.reqString(fileName, @"Invalid file name");           
            var vProfilePictureBase64    = Validate.reqBase64String(profilePictureBase64,@"Invalid file data");
            var vProfilePictureBase64Png = Util.base64ImageToBase64PngImage(vProfilePictureBase64,5000000);

            var parms = new List<SqlParameter>();

            parms.Add(Database.SqlParm("@clientID",             SqlDbType.BigInt,  vClientID, ParameterDirection.Input));
            parms.Add(Database.SqlParm("@patID",                SqlDbType.BigInt,  vPatID,    ParameterDirection.Input));
            parms.Add(Database.SqlParm("@fileName",             SqlDbType.VarChar, vFileName, ParameterDirection.Input, 256));
            parms.Add(Database.SqlParm("@profilePictureBase64", SqlDbType.VarChar, vProfilePictureBase64Png, ParameterDirection.Input, -1));

            rd = saveOrReplaceRecord(connSpedmon,log,uInfo,validateRec,"PATIENT_PROFILE_PICTURES_SAVE_OR_REPLACE",ref parms, null);
            return rd;            
        }

        /**************************************************************************
         * saveThenGet */
        /**
         * 
         **************************************************************************/

        public static ReturnPatientProfilePicture saveThenGet (
            SqlConnection connSpedmon
          , DetailsLog    log
          , UserInfo      uInfo
          , string        clientID
          , string        patID
          , string        fileName
          , string        profilePictureBase64         
          , string        validateRec )
        {

            ReturnPatientProfilePicture so = new ReturnPatientProfilePicture();
            
            var sorr = PatientProfilePictures.save (
                  connSpedmon
                , log
                , uInfo
                , clientID
                , patID
                , fileName
                , profilePictureBase64
                , validateRec );
             
             so = PatientProfilePictures.get(connSpedmon,log,uInfo,clientID,patID,sorr.recordID.ToString());
             return so;

        }
    }
}