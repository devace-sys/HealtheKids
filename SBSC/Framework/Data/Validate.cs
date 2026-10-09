using System;
using System.Collections.Generic;
using System.Text;
using MBA;

namespace Spedmon
{
  /***************************************************************************
   * Validate */
  /**
   * Commonly used data validation tools.  Used for checking incoming data.
   * and providing enforced defaults based on userInfo.  In general the
   * following defaults are enforced.
   * 
   * User Group    User Role       ClientID    PractitionerID    Reference
   * ------------- --------------- ----------- ----------------  -------------
   * Client        Practitioner    Their own   Their own         Not required
   * Client        LEA Coordinator Their own   Any in their      Not required 
   *                                           clientID
   * SBS           Any             Any         Any               Required
   * 
   * All methods throw an exception if problems are found.
   ***************************************************************************/

  public class Validate:MBA.Validate
  {
    
   /***************************************************************************
    * reqSvcRecReference */
    /**
    * Validates service record reference and provides default
    * 
    * @param  userInfo         User information
    * @param  svcRecReference  Ref
    * @return                  Value of ref
    ***************************************************************************/
    
    public static string reqSvcRecReference (UserInfo userInfo, string svcRecReference)
    {
      string retStr;

      /*-------------------------------
       * Clients do not need to provide
       * a reference number (we substitute
       * their IP address) but SBSC users
       * must provide a reference number.
       * TODO: See if we can peform
       * some regex validation on the
       * reference number format
       *------------------------------*/
      
      if (userInfo.userGroup == Constants.USER_GROUP_CLIENT)
        retStr = userInfo.userIP;
      else
        retStr = Validate.reqString(svcRecReference, Messages.INVALID_SVC_REC_REF);
      
      return retStr;
    
    }

   /***************************************************************************
    * reqCDSDistrict */
   /**
    * Checks to see if value is a valid California School District code 
    * Note: This is for the district code only, not site codes.
    * 
    * Accepts 0000000 - 9999999 (7 digit #)
    * 
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

   public static string reqCDSDistrict (string value, string msg)
   {
     value = reqString(value, msg);
     if (Util.isNDigitInteger(value, 7)) return value; else throw new Critical(msg);
   }
       
   /***************************************************************************
    * reqSelpaCode */
    /**
    * Validates selpa code and provides default
    * 
    * @param  userInfo        User information
    * @param  selpaCode       Selpa code passed in
    * @return                 Value of selpa copde
    ***************************************************************************/
       
    public static int reqSelpaCode (UserInfo userInfo, string selpaCode)
    {
      return Convert.ToInt32(valSelpaCode (userInfo, selpaCode, false));
    }
    
    public static object optSelpaCode (UserInfo userInfo, string selpaCode)
    {
      return valSelpaCode(userInfo, selpaCode, true);
    }

    protected static object valSelpaCode (UserInfo userInfo, string selpaCode, bool optional)
    {
       Object retID;

      /*-------------------------------
       * SELPAS are restricted to their
       * own selpa code
       *------------------------------*/
      
      if (userInfo.userRoleID == Constants.ROLE_SELPA_USER_ID)
      {
        retID = userInfo.userSelpaCode;          
        return retID;
      }

      /*-------------------------------
       * Clients are restricted to their
       * own related selpa code
       *------------------------------*/

      if (userInfo.userGroup == Constants.USER_GROUP_CLIENT)
      { 
        retID = userInfo.userSelpaCode;
        return retID;
      }

       
     if (optional)
        retID = Validate.optInteger(selpaCode, Messages.INVALID_SELPA_CODE, true);
      else
        retID = Validate.reqInteger(selpaCode, Messages.INVALID_SELPA_CODE, true);
      
     return retID;
    }
   


   /***************************************************************************
    * reqPracID */
    /**
    * Validates practitioner id and provides default
    * 
    * @param  userInfo        User information
    * @param  pracID          Practitioner id passed in
    * @return                 Value of id
    ***************************************************************************/    
    
    public static int reqPracID (UserInfo userInfo, string pracID)
    {
      return Convert.ToInt32(valPracID(userInfo, pracID, false));
    }
    
    public static object optPracID(UserInfo userInfo, string pracID)
    {
      return valPracID(userInfo, pracID, true);
    }

    protected static object valPracID(UserInfo userInfo, string pracID, bool optional)
    {
      
      Object retID;

      /*-------------------------------
       * Practitioners are restricted to
       * their own practitioner ID
       * unless they supervise other
       * pracs
       *------------------------------*/

      if ((userInfo.userGroup == Constants.USER_GROUP_CLIENT) && (userInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID))      
      {         
        retID = userInfo.userPracID;
      }
      else
        if (optional)
          retID = Validate.optInteger(pracID, Messages.INVALID_PRAC_ID, true);
        else
          retID = Validate.reqInteger(pracID, Messages.INVALID_PRAC_ID);
      
      return retID;
    }
    
    /***************************************************************************
     * reqPatID */
    /**
     * Validates patient id and provides default
     * 
     * @param  userInfo        User information
     * @param  patID           Patient id passed in
     * @return                 Value of id
     ***************************************************************************/    
  
    public static int reqPatID (UserInfo userInfo, string patID)
    {
      return Convert.ToInt32(valPatID(userInfo, patID, false));
    }
    
    public static object optPatID(UserInfo userInfo, string patID)
    {
      return valPatID(userInfo, patID, true);
    }

    protected static object valPatID(UserInfo userInfo, string patID, bool optional)
    {
      
      Object retID = null;

      if (userInfo.userGroup == Constants.USER_GROUP_THIRD_PARTY_PERSON)       
      {         
        retID = null;

        /*-------------------------------
         * Patients are associated
         * to patients that they are 
         * associated with, no exceptions.
         *------------------------------*/

        if (userInfo.userRoleID == Constants.ROLE_PATIENT_ID)
        {
          foreach (var patientUserAccount in userInfo.associatedPatientUserAccounts)
          {
            if (patientUserAccount.patID.ToString() == patID)
            { 
              retID = patientUserAccount.patID;
              break;
            }
          } 
          if (retID == null) throw new Warning(Messages.INVALID_PAT_ID);
        }
        
        /*-------------------------------
         * Parent/guardians are restricted
         * to patients that they are 
         * associated with, no exceptions.
         *------------------------------*/

        else if (userInfo.userRoleID == Constants.ROLE_PARENT_GUARDIAN_ID)
        { 
          foreach (var patientPerson in userInfo.associatedPatientPersons)
          {
            if (patientPerson.patientID.ToString() == patID)
            { 
              retID = patientPerson.patientID;
              break;
            }
          } 
          if (retID == null) throw new Warning(Messages.INVALID_PAT_ID);
        }
        
        else
        {
          if (optional)
            retID = Validate.optInteger(patID, Messages.INVALID_PAT_ID, true);
          else
            retID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
        }
      }
      else
      { 
        if (optional)
          retID = Validate.optInteger(patID, Messages.INVALID_PAT_ID, true);
        else
          retID = Validate.reqInteger(patID, Messages.INVALID_PAT_ID);
      }
      return retID;
    }


    /***************************************************************************
     * reqPlanWriterGroupSvcClassNameID */
    /**
     * Validates and returns default
     * 
     * @param  userInfo              User information
     * @param  groupSvcClassNameID   Plan writer group id         
     * @return                       Value of id
     ***************************************************************************/    
    
    public static long reqPlanWriterGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID)
    {
      return Convert.ToInt64(valPlanWriterGroupSvcClassNameID (userInfo, groupSvcClassNameID, false));
    }
    
    public static object optPlanWriterGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID)
    {
      return valPlanWriterGroupSvcClassNameID (userInfo, groupSvcClassNameID, true);;
    }

    protected static object valPlanWriterGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID, bool optional)
    {
      
      Object retID;

      /*-------------------------------
       * Practitioners are restricted to
       * their own plan writer group id
       *------------------------------*/

      if ((userInfo.userGroup == Constants.USER_GROUP_CLIENT) && (userInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID))
      {         
        retID = userInfo.userPracPlanWriterGroupID;
      }
      else
        if (optional)
          retID = Validate.optInteger (groupSvcClassNameID, Messages.INVALID_PWGID, true);
        else
          retID = Validate.reqInteger (groupSvcClassNameID, Messages.INVALID_PWGID);      
      return retID;
    }


    /***************************************************************************
     * reqOrpGroupSvcClassNameID */
    /**
     * Validates and returns default
     * 
     * @param  userInfo              User information
     * @param  groupSvcClassNameID   Orp svc class name id         
     * @return                       Value of id
     ***************************************************************************/    
    
    public static long reqOrpGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID)
    {
      return Convert.ToInt64(valOrpGroupSvcClassNameID (userInfo, groupSvcClassNameID, false));
    }
    
    public static object optOrpGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID)
    {
      return valOrpGroupSvcClassNameID (userInfo, groupSvcClassNameID, true);
    }

    protected static object valOrpGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID, bool optional)
    {
      
      Object retID;

      /*-------------------------------
       * Practitioners are restricted to
       * their own orp group id
       *------------------------------*/

      if ((userInfo.userGroup == Constants.USER_GROUP_CLIENT) && (userInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID))
      {         
        retID = userInfo.userPracOrpServiceClassNameID;
      }
      else
        if (optional)
          retID = Validate.optInteger (groupSvcClassNameID, Messages.INVALID_GFID, true);
        else
          retID = Validate.reqInteger (groupSvcClassNameID, Messages.INVALID_GFID);      
      return retID;
    }

    /***************************************************************************
     * reqStdGroupSvcClassNameID */
    /**
     * Validates and returns default practioner standard group service class
     * name id (group family).  This is for partition 100.
     * 
     * @param  userInfo              User information
     * @param  groupSvcClassNameID   Std svc class name id         
     * @return                       Value of id
     ***************************************************************************/    
    
    public static long reqStdGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID)
    {
      return Convert.ToInt64(valStdGroupSvcClassNameID (userInfo, groupSvcClassNameID, false));
    }
    
    public static object optStdGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID)
    {
      return valStdGroupSvcClassNameID (userInfo, groupSvcClassNameID, true);
    }

    protected static object valStdGroupSvcClassNameID (UserInfo userInfo, string groupSvcClassNameID, bool optional)
    {
      
      Object retID;

      /*-------------------------------
       * Practitioners are restricted to
       * their own std group id
       *------------------------------*/

      if ((userInfo.userGroup == Constants.USER_GROUP_CLIENT) && (userInfo.userRoleID == Constants.ROLE_LEA_PROVIDER_ID))
      {         
        retID = userInfo.userPracStdSvcClassNameID;
      }
      else
        if (optional)
          retID = Validate.optInteger (groupSvcClassNameID, Messages.INVALID_GFID, true);
        else
          retID = Validate.reqInteger (groupSvcClassNameID, Messages.INVALID_GFID);      
      return retID;
    }

    public static string optNPI(string value, string msg)
    {
        if (Util.IsNullOrEmpty(value)) return null;
        return reqNPI(value, msg);
    }
    
   /***************************************************************************
    * reqNPI */
   /**
    * Checks to see if value is a valid National Provider ID (NPI)
    * Accepts 0000000000 - 9999999999 (10 digit #)
    * 
    * @param  value           Incoming value
    * @param  msg             Invalid value message
    * @return                 value as string
    ***************************************************************************/

   public static string reqNPI (string value, string msg)
   {
     value = reqString(value, msg);
     if (Util.isNDigitInteger(value, 10)) return value; else throw new Critical(msg);
   }


  }
}
