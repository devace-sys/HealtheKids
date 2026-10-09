using System;
using System.Web.UI;
using System.Text;
using System.ComponentModel; 

namespace MBA
{

	/**************************************************************************
     * DataEntryBoxSelectAssociatedPatients */
	/**
     * 
     **************************************************************************/
	public class DataEntryBoxSelectAssociatedPatients : DataEntryBoxSelectBase
	{
		public DataEntryBoxSelectAssociatedPatients() {                
        }
        
		protected override void Render(HtmlTextWriter writer)
        { 
	       if (this.rd.wu.usr.roleID == Constants.ROLE_PARENT_GUARDIAN_ID)
           { 
             foreach (var associatedPatientPerson in this.rd.wu.associatedPatientPersons) { 
                this.addSelection(new NameValue(  associatedPatientPerson.patientName
                                                , associatedPatientPerson.patientID
                                                , associatedPatientPerson.clientName));
             }
           }
           base.Render(writer);
        }			
    }
}
