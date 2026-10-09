using System;
using System.Web.UI;
using System.Text;
using System.ComponentModel; 

namespace MBA
{

	/**************************************************************************
     * DataEntryBoxSelect */
	/**
     * 
     **************************************************************************/
	public class DataEntryBoxSelect : DataEntryBoxSelectBase
	{
		public DataEntryBoxSelect() {}
        
		public bool addSelectOneSelection { get { return _addSelectOneSelection; } set { _addSelectOneSelection = value; } }
					
    }
}
