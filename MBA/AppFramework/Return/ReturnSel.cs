using System;
using System.Collections.Generic;
using System.Text;

namespace MBA
{
  /***************************************************************************
   * ReturnSel */
  /**
   * Return structure for WebUIControl ComboBox or SearchBox requests
   * This structure can be efficiently parsed by the client side code
   ***************************************************************************/   
  
  public class ReturnSel : Return
  {
    public ReturnSel ()            : base(){}
    public ReturnSel (string msg)  : base(msg){}
    public ReturnSel (Exception e) : base(e){}
    public ReturnSel (Warning e)   : base(e){}
    public ReturnSel (Critical e)  : base(e){}
    public ReturnSel (SessionExpired e):base(e){}
    
    public SelRec[] SelRecs;
  }

  /***************************************************************************
   * SelRec */
  /**
   * WebUIControl ComboBox or SearchBox elements.  The data members for this
   * class were chosen to be compatible with what the jQuery UI Autocomplete
   * framework expects.
   ***************************************************************************/   

  public class SelRec
  {
    public long     id;             // Database record unique id
    public string   label;          // Selection to display to the user
    public string   value;          // Selections value (this is what is searched against client side)
    public int      flag1;          // Selection flag 1 (used to decide whether or not to display additional info [hidden])
    public string   class1;         // Selection class 1 (used to decide whether or not to display addtional info)
    public string   showOptions1;   // Show options1 (used to decide whether or not to display additional info)
	  public string   showOptions2;   // Show options2 (used to decide whether or not to display additional info)
	  public string   showOptions3;   // Show options3 (used to decide whether or not to display additional info)
    public string   context1;       // Contextual information field 1 (used to display additional infomation)
    public string   notes;          // Notes    
    
    public string   recData1;       // Extra data about selection record
    public string   recData2;
    public string   recData3;
    public string   recData4;
    public string   recData5;
    public string   recData6;
    public string   recData7;
    public string   recData8;
    public string   recData9;
    public string   recData10;
    public string   recData11;
    public string   recData12;    
    public string   recData13;
    public string   recData14;
    public string   recData15;
    public string   recData16;    
    public bool    recFlagged;  // Record flagged for something
   }

}
