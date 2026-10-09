using System;
using System.Linq;

namespace MBA.X12.X835
{
	
  /// <summary>
	/// Provider level balance adjustment
	/// </summary>
	/// <description>
	/// Adjustments to the warrant amount that are NOT specific to a particular claim or service.
  /// These adjustments can either:  
  /// 1. decrease the payment (a positive number)
  /// 2. increase the payment (a negative number). 
	/// Zero dollar adjustments are not allowed. 
	/// </description>
	
  public interface IPlbAdjustment
	{
    Char                  Delimiter                    { get; set; }
		String                IdentiferComposite           { get; set; }
		AdjustementIdentifier Identifier                   { get; set; }
		Decimal               Amount                       { get; set; }
  }
  
}
