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

namespace Spedmon
{
  /***************************************************************************
   * CaseLoadsSvc */
  /*
   * Web services end point for Caseload methods.
   *
   * Unless indicated, each of these methods require that the caller is 
   * logged in.
   * 
   * Each end point method provides a wrapper for a coresponding framework
   * method that is not accessible from the outside.
   * 
   * These wrappers handle access control and parameter replacement.
   * 
   * The method is restricted to calls for given user groups
   * 
   * Parameter replacement is used to enforce additional access control within
   * the user group but this is limited.
   *
   * The final line of defense for access control are the database udfs or 
   * sprocs that return or save data
   ***************************************************************************/

  [WebService(Namespace = "http://spedcare.com/")]
  [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
  [ScriptService]
  
  public class CaseLoadsSvc : MBA.WebSvc
  {

    /***************************************************************************
     * delete */
    /**
     * "delete" a caseload record
     * 
     * @param  validaterec   Required, True=Yes, False=No
     * @param  editDelReason Reason for delete
     * @param  recid         Record id to delete
     ***************************************************************************/

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord delete(
                                  string editDelReason,
                                  string validaterec,
                                  string recid,
                                  string enddate)
    {
      return (ReturnSaveRecord)
      callMethod(typeof(ReturnSaveRecord),
      delegate()
      {
        return Spedmon.CaseLoads.delete(this.dbConnApp,
                                           this.log,
                                           this.uInfo,
                                           editDelReason,
                                           validaterec,
                                           enddate,
                                           recid);
      },
        Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }


   /***************************************************************************
    * generateTmtSchedStr */
    /**
    * Generates treatment schedule string 
    ***************************************************************************/    
  
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord generateTmtSchedStr 
      (string tpytmtfrqind2,
       string tpytmtdurind2,
       string tpytmtfrqgrp2,
       string tpytmtdurgrp2,

       string tpytmtfrqind3,
       string tpytmtdurind3,
       string tpytmtfrqgrp3,
       string tpytmtdurgrp3,

       string tpytmtfrqind4,
       string tpytmtdurind4,
       string tpytmtfrqgrp4,
       string tpytmtdurgrp4,

       string tpytmtfrqind5,
       string tpytmtdurind5,
       string tpytmtfrqgrp5,
       string tpytmtdurgrp5,
       
       string tpytmtfrqind6,
       string tpytmtdurind6,
       string tpytmtfrqgrp6,
       string tpytmtdurgrp6)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnValue),       
      delegate()
      {    
        return Spedmon.CaseLoads.generateTmtSchedStr (
          this.dbConnApp,
          this.log,
          this.uInfo,
          tpytmtfrqind2,
          tpytmtdurind2,
          tpytmtfrqgrp2,
          tpytmtdurgrp2,

          tpytmtfrqind3,
          tpytmtdurind3,
          tpytmtfrqgrp3,
          tpytmtdurgrp3,

          tpytmtfrqind4,
          tpytmtdurind4,
          tpytmtfrqgrp4,
          tpytmtdurgrp4,

          tpytmtfrqind5,
          tpytmtdurind5,
          tpytmtfrqgrp5,
          tpytmtdurgrp5,

          tpytmtfrqind6,
          tpytmtdurind6,
          tpytmtfrqgrp6,
          tpytmtdurgrp6);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }               
  
   /***************************************************************************
    * save */
    /**
    * Save patient records
    ***************************************************************************/    

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public ReturnSaveRecord save 
      (string clientid,
       string pracid,
       string patid,
       string startdate,
       
       string asmtdueann,
       string asmtduetriann,
       
       string tmteffdate,
       
       string tpytmtfrqind2,
       string tpytmtdurind2,
       string tpytmtfrqgrp2,
       string tpytmtdurgrp2,

       string tpytmtfrqind3,
       string tpytmtdurind3,
       string tpytmtfrqgrp3,
       string tpytmtdurgrp3,

       string tpytmtfrqind4,
       string tpytmtdurind4,
       string tpytmtfrqgrp4,
       string tpytmtdurgrp4,

       string tpytmtfrqind5,
       string tpytmtdurind5,
       string tpytmtfrqgrp5,
       string tpytmtdurgrp5,
       
       string tpytmtfrqind6,
       string tpytmtdurind6,
       string tpytmtfrqgrp6,
       string tpytmtdurgrp6,

       string editDelReason,
       string validaterec,
       string savetype,
       string recid)
    {
      return (ReturnSaveRecord) 
     
      callMethod(typeof(ReturnSaveRecord),       
      delegate()
      {    
        return Spedmon.CaseLoads.save
         (this.dbConnApp,
          this.log,
          this.uInfo,
          clientid,
          pracid,
          patid,
          startdate,
          asmtdueann,
          asmtduetriann,
          tmteffdate,
          tpytmtfrqind2,
          tpytmtdurind2,
          tpytmtfrqgrp2,
          tpytmtdurgrp2,

          tpytmtfrqind3,
          tpytmtdurind3,
          tpytmtfrqgrp3,
          tpytmtdurgrp3,

          tpytmtfrqind4,
          tpytmtdurind4,
          tpytmtfrqgrp4,
          tpytmtdurgrp4,

          tpytmtfrqind5,
          tpytmtdurind5,
          tpytmtfrqgrp5,
          tpytmtdurgrp5,

          tpytmtfrqind6,
          tpytmtdurind6,
          tpytmtfrqgrp6,
          tpytmtdurgrp6,
          
          editDelReason,
          validaterec,
          savetype,
          recid);
      },
      Constants.ROLE_ALL_PCAL_AND_CLIENT);  // Who can call this method           
    }               
  }
}
