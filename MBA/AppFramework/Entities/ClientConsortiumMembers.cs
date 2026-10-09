using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace MBA
{
    
  /***************************************************************************
   * ClientConsortiumMember */
  /**
   *
   ***************************************************************************/

  public class ClientConsortiumMember
  {
    public long    id;     /* client id*/
    public string  name;   /* client name */
    public string  idStr;
    public bool    leadClient;    
  }     

}
