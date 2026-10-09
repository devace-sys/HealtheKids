using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;


namespace MBA
{      
  /***************************************************************************
   * Person */
  /**
   ***************************************************************************/   
  
  public class Person:Entity
  {
    
    public const string DEFAULT_PAGING_ORDER = @"clientName, lastName, firstName";
      
    public string   lastName;        // Persons last and first name
    public string   firstName;
    public string   middleName;
    public string   phone;           // Primary #
    public string   fax;
    public string   email;
    public string   street1;         // Primary address
    public string   street2;
    public string   city;
    public string   state;
    public string   zip5;
    public string   zip4;
    public string   placeAddress;    // Primary address
    public long     clientID;        // Client (district) id
    public string   clientName;      // Client (district) name
    public long     selpaCode   = 0;
    public string   selpaName = "";
    public long     roleID;
    public string   role;
    public int      source;
    public long     sourceID;
    public long?    userIDInt; 
    public int      preferredContactMethodCode;
    public string   preferredContactMethodName;    
  }
  
  /***************************************************************************
   * Persons */
  /**
   * People.
   ***************************************************************************/

  public class Persons:Entities
  {

   /***************************************************************************
    * load */
   /**
    * Outputs data for a single person
    * 
    * Note: This calls the view method and the view method takes care of
    * enforcing the client id.
    * 
    * @param  connSpedmon     Spedmon database connection object
    * @param  log             Logging object
    * @param  clientID        Client ID
    * @param  pracID          PractitionerID
    * @return                 ReturnEntity
    ***************************************************************************/ 
    
    public static Person load (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, string recID, string email, string source)
    { 
      /* Note: recId is not used yet so we are forcing it to be a 1 */
      recID = "1";
      return (Person) Entities.load (connUsers, log, uInfo , recID, typeof(Person),
      delegate{return Persons.view(connUsers, log, uInfo, Entities.REC_VIEW_LOAD, false, recID, "", "", email, source , null);});      
    }     
    
    /***************************************************************************
     * view */
    /**
     * View persons
     * 
     * @param  email      User's email
     * @return            ReturnDB
     ***************************************************************************/   

    protected static ReturnDB view (SqlConnection connUsers, DetailsLog log, UserInfo uInfo, int recViewType,
                                 bool   pagedOrTop,
                                 string idx,
                                 string canEdit,
                                 string active,
                                 string email,
                                 string source,
                                 defineCols dc)
    {
      
      /*----------------------------
       * Validate parameters specific
       * to this entity.view
       * and populate their
       * coresponding database
       * parameters
       *----------------------------*/  
      
      List<SqlParameter> parms      = new List<SqlParameter>();
      
      string             viewUDF    = "dbo.PERSONS_VIEW(@userID, @userGroup, @userRank, @recID, @email, @source, @active, @canEdit)";      
      string             vEmail     = Validate.reqEmail    (email,  Messages.INVALID_EMAIL);
      int                vSource    = Validate.reqInteger  (source, Messages.INVALID_PERSON_SOURCE);

      parms.Add(Database.SqlParm("@email",   SqlDbType.NVarChar, vEmail,   ParameterDirection.Input, 256));
      parms.Add(Database.SqlParm("@source",  SqlDbType.Int,      vSource,  ParameterDirection.Input));

      /*----------------------------
       * Call base method which 
       * handles the rest and return
       * results
       *----------------------------*/

      return Entities.view (connUsers, log, uInfo, recViewType, pagedOrTop, idx, canEdit, active, viewUDF, ref parms, null, dc);      
      
    }
  
  }
}
