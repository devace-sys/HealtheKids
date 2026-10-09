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
   * PatientPractitioner */
  /**
   *
   ***************************************************************************/

  public class PatientPractitioner : Entity
  {
  }
    

  /***************************************************************************
   * PatientPractitioners */
  /**
   *
   ***************************************************************************/
  
  public class PatientPractitioners : Entities
  {
    
    public const string SEL_LABEL             = "Patient Practitioner";
    public const string SEL_LABEL_VIEW        = "View";

    public const string URL_ASMX           = @"patient_practitioner.asmx";
    public const string URL_VIEW_SEL       = URL_ASMX + @"/viewSel";

    public static string URL_VIEW_SEL_BASE()
    {
        return MBA.HttpApplication.createLink(URL_VIEW_SEL, true);
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
                                  , string        term
                                  , defineCols    dc )
    {
      
      string viewUDF = @"dbo.PATIENT_PRACTITIONERS_VIEW (@userID, @userGroup, @userRank, @clientID, @patID, @term, @active, @recID)";
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/

      List<SqlParameter> parms = new List<SqlParameter>();
       
      long   vClientID       = Validate.reqClientID (uInfo, clientID);
      long   vPatID          = Validate.reqInteger  (patID,          Messages.INVALID_PAT_ID);
      Object vTerm           = Validate.optString   (term,           @"Invalid search term");
      
      parms.Add(Database.SqlParm("@clientID",   SqlDbType.BigInt,  vClientID,    ParameterDirection.Input));
      parms.Add(Database.SqlParm("@patID",      SqlDbType.BigInt,  vPatID,       ParameterDirection.Input));
      parms.Add(Database.SqlParm("@term",       SqlDbType.VarChar, vTerm,        ParameterDirection.Input, 256));
      
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
        * Returns a data table of records for preview or record selection.
        *
        * @return                 ReturnDataTable
        ***************************************************************************/

    public static ReturnSel viewSel(SqlConnection connSpedmon
                                        , DetailsLog log
                                        , UserInfo uInfo
                                        , bool top
                                        , string topSize
                                        , string clientID
                                        , string patientID
                                        , string term)
    {

        /*----------------------------
            * Define our context column
            *----------------------------*/

        defineCols dc = delegate (ref SQLStatement ss, ref string pageroworder, ref List<SqlParameter> parms)
        {
            ss.addDisplayColumn("email                            as [recData4]");
            ss.addDisplayColumn("role                             as [recData5]");
        };

        /*----------------------------
            * Call base method which
            * handles the rest and return
            * results
            *----------------------------*/

        return Entities.viewSel(connSpedmon
                                , log
                                , uInfo
                                , top
                                , topSize
                                , delegate
                                {
                                    return PatientPractitioners.view(connSpedmon
                                                                    , log
                                                                    , uInfo
                                                                    , Entities.REC_VIEW_SEL
                                                                    , top
                                                                    , topSize
                                                                    , ""
                                                                    , "Y"
                                                                    , clientID
                                                                    , patientID
                                                                    , term
                                                                    , dc);


                                });
    }
    
    

    /*************************************************************************
    * viewList */
   /**
    * Return a list of patient contact records
    * 
    ***************************************************************************/

    public static List<PatientPerson> viewList( SqlConnection connSpedmon
                                                         , DetailsLog    log
                                                         , UserInfo      uInfo
                                                         , string        clientID
                                                         , string        patID
                                                         , string        active)
      
     {
        var recs = new List<PatientPerson>();
        ReturnDB rd = PatientPersons.view(connSpedmon, log, uInfo, Entities.REC_VIEW_RAW, false, null, null, active, clientID, patID, null, null, null, null);       
        List<Object>  slo = Database.convertRecordsToList (ref rd.records, typeof(PatientPerson));
        foreach (var o in slo) {
            recs.Add((PatientPerson) o);
        }
        return recs;
    }

  }
}
