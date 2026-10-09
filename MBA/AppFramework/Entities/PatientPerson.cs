using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
    
  /***************************************************************************
   * PatientPerson */
  /**
   *
   ***************************************************************************/

  public class PatientPerson : Person
  {
    //public long    clientID;
  	public long    patientID;
  	public long    personID;
	  public long    classID1;
  	public long    classID2;
	  public string  className1;
	  public string  className2;
	//  public string  lastName;
	//  public string  firstName;
	  //public string  middleName;
	 // public string  email;
  //	public string  phone;
  //	public string  fax;
  	public string  address1;
    public string  address2;
    //public string  city;
    //public string  state;
    //public string  zip5;
    //public string  zip4;
    public string  additionalData1;
	public string  additionalData2;	
	public string  relationshipWithPatientLabel;
    public string patientName;
    public int serviceAuthorizationRequestsPendingCount = 0;  /* Only populated by Credential.retrieveUserData */
   
  }
     
}
