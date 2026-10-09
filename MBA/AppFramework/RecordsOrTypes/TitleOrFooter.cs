using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MBA
{

   
  /***************************************************************************
   * TitleOrFooterAttribute */
  /**
   * 
   ***************************************************************************/  
  
  public enum TitleOrFooterAttribute
  {
    Contains_Organization_Name = 1, // Note: 1 is not used right now
    Contains_Report_Name       = 2,
    Contains_Parameter_Dates   = 4
  }
  
  /***************************************************************************
   * TitleOrFooter */
  /**
   * A result set title row
   ***************************************************************************/  

  public class TitleOrFooter: IComparable<TitleOrFooter>
  {

    public string                   name;
    public int                      position;
    public TitleOrFooterAttribute[] attributes;
    
    public TitleOrFooter(string name, int position):this(name,position,null){}
    
    public TitleOrFooter (string name, int position, params TitleOrFooterAttribute[] attributes)
    {
      this.name       = name;
      this.position   = position;
      this.attributes = attributes;    
    }

    public bool hasAttributes ()
    {
      if (this.attributes == null)     return false;
      if (this.attributes.Length == 0) return false;
      return true;
    }
    
    public bool hasAttribute (TitleOrFooterAttribute attribute)
    {
      if (!hasAttributes()) return false;
      bool found = false;
      foreach (TitleOrFooterAttribute a in attributes)
      {  
        if (a == attribute)
        {
          found = true;
          break;
        }
      }
      return found;     
    }
    
    /*---------------------------------
	   * Interface methods
	   *--------------------------------*/		 	
	
	  /**************************************************************************
     * CompareTo */
    /**
     * Implements CompareTo method required by IComparable
     ***************************************************************************/

	  public int CompareTo (TitleOrFooter other)
	  {
	    return this.position.CompareTo(other.position);
	  }	      
  }
}
