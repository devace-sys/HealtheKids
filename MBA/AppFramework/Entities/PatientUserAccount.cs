using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
    
  /***************************************************************************
   * PatientUserAccount */
  /**
   *
   ***************************************************************************/

  public class PatientUserAccount : Person
  {
  	public long    patID;
	public string  patName;   
  }
     
}
