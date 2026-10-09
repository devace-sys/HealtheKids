using System;
using System.Collections.Generic;
using System.Web;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * plan_writer_plans_file.ashx.cs */
  /*
   ***************************************************************************/
   
  public class PlanWriterPlansFileViw : MBA.WebCustomFile
  {
    
    public PlanWriterPlansFileViw()
    {
      /*-------------------------------
       * Define permitted roles 
       * Call framework method
       * _reportEditView;
       * _reportPageView;
       * _reportPageNumber;
       *------------------------------*/

      this._permittedRoles = Spedmon.Constants.ROLE_ALL_PCAL_AND_CLIENT;
      
	  string clientID            = MBA.HttpApplication.getParameter(@"organizationid");	    
      string groupSvcClassNameID = MBA.HttpApplication.getParameter(@"ownerid");
      string planID              = MBA.HttpApplication.getParameter(@"groupid");      
      string publishPlan         = MBA.HttpApplication.getParameter(@"publishplan");
	  
	    this._cbGenerateFileBytes = delegate()
      {
        return PlanWriterPlans.pdfGeneratePlanFile ( dbConnApp
                                                     , log
                                                     , uInfo
                                                     , clientID
                                                     , groupSvcClassNameID
                                                     , planID);       
      };
    }
  }
}