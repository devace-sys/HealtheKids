using System;
using System.Collections;
using System.Globalization;
using System.Threading;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Text.RegularExpressions;

namespace MBA
{
  
  /**************************************************************************
   * FieldSetUSPSAddress */
  /**
   * US Postal Service Address
   **************************************************************************/

  public class FieldSetUSPSAddress:FieldSet
  {            
    
	protected string  _fmtAddressSingleLine        = @"{0} {1}, {2}, {3}, {4}-{5}";
	protected string  _parmNameAutoCompleteAddress = @"auto_complete_address";
	  
    protected MBA.LabelBox  _ctrlAutoCompleteAddrLbl = new MBA.LabelBox();
    
	protected MBA.DataEntryBoxText _ctrlStreet1Inp      = new MBA.DataEntryBoxText();
    protected MBA.DataEntryBoxText _ctrlStreet2Inp      = new MBA.DataEntryBoxText();
	protected MBA.DataEntryBoxText _ctrlCityInp         = new MBA.DataEntryBoxText();
	protected MBA.DataEntryBoxText _ctrlStateInp        = new MBA.DataEntryBoxText();
	protected MBA.DataEntryBoxText _ctrlZip5Inp         = new MBA.DataEntryBoxText();
	protected MBA.DataEntryBoxText _ctrlZip4Inp         = new MBA.DataEntryBoxText();	  		  
	
    protected MBA.CheckBox  _ctrlAutoCompleteAddrInp = new MBA.CheckBox();
	  	  
	protected string        _parmNameStreet1   = @"street1";
	protected string        _parmNameStreet2   = @"street2";
	protected string        _parmNameCity      = @"city";
	protected string        _parmNameState     = @"state";
	protected string        _parmNameZip5      = @"zip5";
	protected string        _parmNameZip4      = @"zip4";
		
    public string parmNameStreet1   { get { return _parmNameStreet1;      }  set { _parmNameStreet1       = value; }}
	public string parmNameStreet2   { get { return _parmNameStreet2;      }  set { _parmNameStreet2       = value; }}
	public string parmNameCity      { get { return _parmNameCity;         }  set { _parmNameCity          = value; }}
	public string parmNameState     { get { return _parmNameState;        }  set { _parmNameState         = value; }}
	public string parmNameZip5      { get { return _parmNameZip5;         }  set { _parmNameZip5          = value; }}
	public string parmNameZip4      { get { return _parmNameZip4;         }  set { _parmNameZip4          = value; }}
    public string parmValueStreet1  { get { return _ctrlStreet1Inp.value; }  set { _ctrlStreet1Inp.value  = value; }}
	public string parmValueStreet2  { get { return _ctrlStreet2Inp.value; }  set { _ctrlStreet2Inp.value  = value; }}
	public string parmValueCity     { get { return _ctrlCityInp.value;    }  set { _ctrlCityInp.value     = value; }}
	public string parmValueState    { get { return _ctrlStateInp.value;   }  set { _ctrlStateInp.value    = value; }}
	public string parmValueZip5     { get { return _ctrlZip5Inp.value;    }  set { _ctrlZip5Inp.value     = value; }}
	public string parmValueZip4     { get { return _ctrlZip4Inp.value;    }  set { _ctrlZip4Inp.value     = value; }}
    
    public FieldSetUSPSAddress () : base()
    {  	    	    	  
  	
  	  this.title                      = @"Enter USPS address";
  	  this.includeLegend              = true;
  	  this.legendText                 = @"Enter address";  	    	  
	    
      this._ctrlStreet1Inp.label      = "Street Address 1";
      this._ctrlStreet1Inp.title      = @"Enter the street address";
	  this._ctrlStreet1Inp.maxLen     = 512;	  
	    	      
      this._ctrlStreet2Inp.label      = "Street Address 2";
      this._ctrlStreet2Inp.title      = @"Enter additional address information such as apartment#, suite#, etc.";
	  this._ctrlStreet2Inp.maxLen     = 512;	  
	    
	  this._ctrlCityInp.label         = @"City";
      this._ctrlCityInp.title         = @"Enter the city";
	  this._ctrlCityInp.maxLen        = 100;	  
  	      	    
      this._ctrlStateInp.label        = @"State";
	  this._ctrlStateInp.title        = @"Enter the state.  For example, CA for California.";
	  this._ctrlStateInp.maxLen       = 4;
	  this._ctrlStateInp.size         = 2;

      this._ctrlZip5Inp.label         = @"Zip (First 5)";
      this._ctrlZip5Inp.title         = @"First 5 characters of zip code";
	  this._ctrlZip5Inp.maxLen        = 5;
  	  this._ctrlZip5Inp.size          = 6; 

      this._ctrlZip4Inp.label         = @"Zip (Last 4)";
  	  this._ctrlZip4Inp.title         = @"Last 4 characters of zip code";
	  this._ctrlZip4Inp.maxLen        = 4;	  	  
  	  this._ctrlZip4Inp.size          = 5; 

  	  this._ctrlAutoCompleteAddrLbl.text            = "Autocomplete Address?";
  	  this._ctrlAutoCompleteAddrLbl.title           = "Autocomplete Address Using USPS Data?";  	  
  	  this._ctrlAutoCompleteAddrInp.title           = "Autocomplete Address Using USPS Data?";
  	  this._ctrlAutoCompleteAddrInp.useDefaultValue = true;
  	  this._ctrlAutoCompleteAddrInp.defaultValue    = true;
  	  this._ctrlAutoCompleteAddrInp.noSubmit        = true;  	  
  	}
  	
  	public string generateStepLabel ()
  	{  	  
  	  string lbl = String.Format(  this._fmtAddressSingleLine
  	                             , this.parmValueStreet1
  	                             , this.parmValueStreet2
  	                             , this.parmValueCity
  	                             , this.parmValueState
  	                             , this.parmValueZip5
  	                             , this.parmValueZip4);  	 
  	  return lbl;
  	}
  	
  	public Step setParentStepLabel()
  	{
  	  return this.setParentStepLabel ( generateStepLabel() );
  	}
  
    /***************************************************************************
     * isAutoCompleteAddressNeeded */
    /**
     * Determine if address should be in autocomplete mode
     ***************************************************************************/
 
  	protected bool isAutoCompleteAddressNeeded ()
  	{
  	  if ((Util.IsNullOrEmpty(_ctrlStreet1Inp.value)) && (Util.IsNullOrEmpty(_ctrlZip5Inp.value))) return true;
  	  return false;
  	}
  	
  	/***************************************************************************
     * Render */
    /**
     * Render control
     ***************************************************************************/

  	protected override void Render(HtmlTextWriter writer)
  	{                  
      
	    this._ctrlStreet1Inp.ID            = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameStreet1 , this.ID);
	    this._ctrlStreet1Inp.name          = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameStreet1);      	    
	    this._ctrlStreet2Inp.ID            = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameStreet2, this.ID);
	    this._ctrlStreet2Inp.name          = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameStreet2);	          
	    this._ctrlCityInp.ID               = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameCity, this.ID);
	    this._ctrlCityInp.name             = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameCity);	  
	    this._ctrlStateInp.ID              = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameState, this.ID);
	    this._ctrlStateInp.name            = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameState);	  
	    this._ctrlZip5Inp.ID               = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameZip5, this.ID);
	    this._ctrlZip5Inp.name             = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameZip5);	  
	    this._ctrlZip4Inp.ID               = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameZip4, this.ID);
	    this._ctrlZip4Inp.name             = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameZip4);	        	        
        this._ctrlAutoCompleteAddrInp.ID   = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameAutoCompleteAddress, this.ID);
        this._ctrlAutoCompleteAddrInp.name = Util.createFormFieldIdOrName (_fieldNamePrefix, _parmNameAutoCompleteAddress);
            
        this._ctrlAutoCompleteAddrInp.value = this.isAutoCompleteAddressNeeded();
	    	    	    	               
        string fnDefNameDoValidateAddress = String.Format(
                                        @"doValidateAddress_{0}"
                                        , this.ID);
                                        
      string fnVarDefRetOK = String.Format(@"function (returnData, mkup) {{
                                           $('#{0}').val(returnData.addressOut.Street1);
                                           $('#{1}').val(returnData.addressOut.Street2);
                                           $('#{2}').val(returnData.addressOut.City);
                                           $('#{3}').val(returnData.addressOut.State);
                                           $('#{4}').val(returnData.addressOut.Zip5);
                                           $('#{5}').val(returnData.addressOut.Zip4);                                           
                                           $('#{6}').spedmonInput_setValue('false');
                                           }};"
                                           
                                           , this._ctrlStreet1Inp.ID
                                           , this._ctrlStreet2Inp.ID
                                           , this._ctrlCityInp.ID
                                           , this._ctrlStateInp.ID
                                           , this._ctrlZip5Inp.ID
                                           , this._ctrlZip4Inp.ID
                                           , this._ctrlAutoCompleteAddrInp.ID);

      string fnDefBodyDoValidateAddress = String.Format (
                                          @"var tknValIn = null;
                                          var street1ValIn = $('#{0}').val();
                                          var street2ValIn = $('#{1}').val();
                                          var cityValIn    = $('#{2}').val();
                                          var stateValIn   = $('#{3}').val();
                                          var zip5ValIn    = $('#{4}').val();
                                          var zip4ValIn    = $('#{5}').val();
                                          var fnRetOK = {6};
                                          var fnRetNotOK = function (returnData, mkup) {{ }}; 
                                          var autoCompAddrVal = $('#{7}').val();                                          
                                          if (autoCompAddrVal == 'false') return;                                          
                                          if (!zip5ValIn)    return;
                                          if (!street1ValIn) return;
                                          
                                          $.spedmonWebUI.validateAddress ( tknValIn
                                                                          , street1ValIn
                                                                          , street2ValIn
                                                                          , cityValIn
                                                                          , stateValIn
                                                                          , zip5ValIn
                                                                          , zip4ValIn
                                                                          , fnRetOK 
                                                                          , fnRetNotOK
                                                                         );"
                                        , this._ctrlStreet1Inp.ID
                                        , this._ctrlStreet2Inp.ID
                                        , this._ctrlCityInp.ID
                                        , this._ctrlStateInp.ID
                                        , this._ctrlZip5Inp.ID
                                        , this._ctrlZip4Inp.ID
                                        , fnVarDefRetOK 
                                        , this._ctrlAutoCompleteAddrInp.ID
                                        );
                 
      string fnDefDoValidateAddress = String.Format(
                                    @"function {0}() {{ {1} }};"
                                    , fnDefNameDoValidateAddress
                                    , fnDefBodyDoValidateAddress);
           
      string fnOnBlurAssignCalls = String.Format(
                                   @"$('#{1}').blur({0});
                                     $('#{2}').blur({0});"                                     
                                   , fnDefNameDoValidateAddress
                                   , this._ctrlZip5Inp.ID
                                   , this._ctrlStreet1Inp.ID                                   
                                   );
                                               
      string fnCallCreateAddressSingleLine = String.Format(@"$.spedmonWebUI.stringFormat('{0}',$('#{1}').val(),$('#{2}').val(),$('#{3}').val(),$('#{4}').val(),$('#{5}').val(),$('#{6}').val())"
                                           , this._fmtAddressSingleLine
                                           , this._ctrlStreet1Inp.ID
                                           , this._ctrlStreet2Inp.ID
                                           , this._ctrlCityInp.ID
                                           , this._ctrlStateInp.ID
                                           , this._ctrlZip5Inp.ID
                                           , this._ctrlZip4Inp.ID);
                                                 
      
      this.fnControlValue = String.Format(@"var vl = {0}; return vl;"
                                           , fnCallCreateAddressSingleLine);
      
      this.fnControlLabel = String.Format(@"var lbl = {0}; return lbl;"
                                          , fnCallCreateAddressSingleLine);


       /*-------------------------------
         * Add controls
         *------------------------------*/

       this.Controls.Add(new MBA.Wrapper(@"span", _ctrlAutoCompleteAddrLbl, _ctrlAutoCompleteAddrInp));

       this.Controls.Add(_ctrlZip5Inp);
       this.Controls.Add(_ctrlStreet1Inp);
       this.Controls.Add(_ctrlStreet2Inp);
       this.Controls.Add(_ctrlCityInp);
       this.Controls.Add(_ctrlStateInp);                                                              
       this.Controls.Add(_ctrlZip4Inp);

      /*-------------------------------
       * Render child controls
       *------------------------------*/

      base.Render(writer);
       
      /*-------------------------------
       * Render handlers
       *------------------------------*/

      writer.Write(@"<script type=""text/javascript"">");
      writer.Write(fnDefDoValidateAddress);
      writer.Write(@"$(function(){"); 
	    writer.Write(fnOnBlurAssignCalls);
      writer.Write(@"});");
      writer.Write(@"</script>");
      
       
  	}
  	
  }
}