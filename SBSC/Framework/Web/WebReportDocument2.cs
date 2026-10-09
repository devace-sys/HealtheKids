using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{   
  
  /***************************************************************************
   * WebReportDocument2 */
  /*
   * Base class for Spedmon reports
   * To use create two files report.ashx and report.ashx.cs
   * 
   * report.ashx should have the following line
   * 
   * <%@ WebHandler Language="C#" Class="MBA.EntityNameRpt" CodeBehind="report.ashx.cs"%>
   * 
   * report.ashx.cs should have the following lines
   * Note where you define permitted roles and the method callback
   * 
   * using System;
   * using System.Collections.Generic;
   * using System.Web;
   * 
   * namespace MBA
   * {
   * public class EntiyNameRpt : MBA.MBAReport
   * {    
   *   public EntityNameRpt()
   *   {
   *     this._permittedRoles = MBA.Constants.ROLE_ALL;
   *     this.cbReportData = delegate(){
   *     _cbAccessControl();
   *     return MBA.EntityName.viewPrev(dbConnMBA,log,rest of parms);
   *   };
   *  }
   * }
   *}
   * 
   * If you need to select a different method to return data use reptNum
   ***************************************************************************/

  public abstract class WebReportDocument2 : MBA.WebReportDocument2
  {
   /*-------------------------------
    * Report Parameters
    *------------------------------*/

    protected string clientid;
    protected string pracid;
    protected string groupid;
    protected string roleid;
    protected string patid;
    protected string dos;
    protected string dob;
    protected string isIEP;
    protected string reference;
    protected string recUserID;
    protected string activeLEA;
    protected string activeMAA;
    protected string dateRange2;
    protected string proccode;
    protected string procmod1;
    protected string procmod2;
    protected string procmod3;


    public WebReportDocument2():base()
    { 
      
     /*-------------------------------
      * Retrieve standard report 
      * parameters
      *------------------------------*/
      
      clientid   = MBA.HttpApplication.getParameter("clientid");
      pracid     = MBA.HttpApplication.getParameter("pracid");
      groupid    = MBA.HttpApplication.getParameter("groupid");
      roleid     = MBA.HttpApplication.getParameter("roleid");
      patid      = MBA.HttpApplication.getParameter("patid");
      dos        = MBA.HttpApplication.getParameter("dos");
      dob        = MBA.HttpApplication.getParameter("dob");
      isIEP      = MBA.HttpApplication.getParameter("isiep");
      reference  = MBA.HttpApplication.getParameter("reference");
      recUserID  = MBA.HttpApplication.getParameter("recuserid");
      activeLEA  = MBA.HttpApplication.getParameter("activelea");
      activeMAA  = MBA.HttpApplication.getParameter("activemaa");
      dateRange2 = MBA.HttpApplication.getParameter("daterange2");
      proccode   = MBA.HttpApplication.getParameter("proccode");
      procmod1   = MBA.HttpApplication.getParameter("procmod1");
      procmod2   = MBA.HttpApplication.getParameter("procmod2");
      procmod3   = MBA.HttpApplication.getParameter("procmod3");
      
   }
  }
}