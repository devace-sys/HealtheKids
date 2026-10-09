using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnWebUser */
  /**
   * Return class for user authentication.  Contains information about the 
   * person who is logged in. 
   ***************************************************************************/   
   
  public class ReturnWebUser: Return
  {
    public ReturnWebUser()            : base()  {}
    public ReturnWebUser(Exception e) : base(e) {} 

    public User                        usr;
    public Practitioner                pr;
    public List<PatientPerson>         associatedPatientPersons;
    public List<SelpaRelatedClient>    relatedClients;
    public List<PatientUserAccount>    associatedPatientUserAccounts;
    public bool cybhiConsortiumIsLead = false; /* Important default */
    public List<ClientConsortiumMember> cybhiConsortiumMembers;

    public List<UserPreference>        preferences;
    public int                         CredentialProvided;
  }
  
  
     
}
