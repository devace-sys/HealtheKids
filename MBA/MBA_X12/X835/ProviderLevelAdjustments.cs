using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OopFactory.X12.Parsing;
using OopFactory.X12.Parsing.Model;

namespace MBA.X12.X835
{

  /// <summary>
  /// Adjustement identifier broken up
  /// </summary>
  
  public struct AdjustementIdentifier
  {
    public AdjustementIdentifier(char delimiter, string identifierComposite)
    {
      var parts = identifierComposite.Split(delimiter);
      this.ReasonCode = parts[0];
      this.Reference  = parts[1];
    }
    
    public string ReasonCode;
    public string Reference;
  }
  
  /// <summary>
  /// Unclassified provider level adjustement
  /// </summary>
  /// <inheritdoc/>
  
  public class ProviderLevelAdjustment : IPlbAdjustment
	{
		public ProviderLevelAdjustment()
		{
		}

		public ProviderLevelAdjustment (Char delimiter, string identifierComposite, Decimal? amount)
		{
      this.Delimiter            = delimiter;
			this.IdentiferComposite   = identifierComposite;
			this.Identifier           = new AdjustementIdentifier(delimiter, identifierComposite);			
			this.Amount               = amount.Value;
		}

    public Char                  Delimiter            { get; set; }
		public String                IdentiferComposite   { get; set; }
		public AdjustementIdentifier Identifier           { get; set; }
		public Decimal               Amount               { get; set; }
  }

  /// <summary>
  /// Provider level adjustement classified as a processing fee
  /// </summary>

  public class ProviderLevelAdjustmentProcessingFee : ProviderLevelAdjustment
	{
		public ProviderLevelAdjustmentProcessingFee(Char delimiter, string identifier, Decimal? amount) : base(delimiter, identifier, amount) { }
	}

  /// <summary>
  /// Provider level adjustement classified as a forward balance
  /// </summary>

  public class ProviderLevelAdjustmentForwardBalance : ProviderLevelAdjustment
	{
		public ProviderLevelAdjustmentForwardBalance(Char delimiter, string identifier, Decimal? amount) : base(delimiter, identifier, amount) { }
	}

  /// <summary>
  /// Provider level adjustement classified as a CRCS adjustment
  /// </summary>

  public class ProviderLevelAdjustmentCRCS : ProviderLevelAdjustment
	{
		public ProviderLevelAdjustmentCRCS(Char delimiter, string identifier, Decimal? amount) : base(delimiter,identifier, amount) { }
	}

	/// <summary>
  /// Provider level adjustement classified as an extra adjustement
  /// </summary>

  public class ProviderLevelAdjustmentExtra : ProviderLevelAdjustment
	{
		public ProviderLevelAdjustmentExtra(Char delimiter, string identifier, Decimal? amount) : base(delimiter, identifier, amount) { }
	}

	/// <summary>
  /// Methods used to extact and classify adjustments
  /// </summary>

  public static class ProviderLevelAdjustments
	{

      /// <summary>
      /// Adjustment creation factory
      /// </summary>

      public static IPlbAdjustment AdjustmentFactory (   Char     subElementDelimiter
                                                                 , String   identifier
                                                                 , Decimal? amount ) 
      {
        
        if (identifier.StartsWith ("E3" + subElementDelimiter + "95"))
          return new ProviderLevelAdjustmentProcessingFee (subElementDelimiter, identifier, amount);
        
        if (identifier.StartsWith ("E3" + subElementDelimiter + "6"))   
          return new ProviderLevelAdjustmentCRCS (subElementDelimiter,identifier, amount);
        
        if (identifier.StartsWith ("E3" + subElementDelimiter + "373")) 
          return new ProviderLevelAdjustmentExtra (subElementDelimiter,identifier, amount);
        
        if (identifier.Equals("FB"))
          return new ProviderLevelAdjustmentForwardBalance(subElementDelimiter,identifier, amount);
      
        return new ProviderLevelAdjustment (subElementDelimiter, identifier, amount); 
      }
    
      
      /// <summary>
      /// 
      /// </summary>
      /// <param name="subElementDelimeter"></param>
      /// <param name="plb"></param>
      /// <param name="adjustmentList"></param>
      
      public static void ExtractFromSegmentAndAddToList (  char subElementDelimeter
                                                          , ref Segment plb
                                                          , ref List<IPlbAdjustment> adjustmentList 
                                                        )
      {               
        /* 6 possible provider level adjustements per segment */     

        if (plb != null)
        {
          if (plb.ElementCount >= 4)  adjustmentList.Add ( AdjustmentFactory (subElementDelimeter, plb.GetElement(3),  plb.GetDecimalElement(4)));
          if (plb.ElementCount >= 6)  adjustmentList.Add ( AdjustmentFactory (subElementDelimeter, plb.GetElement(5),  plb.GetDecimalElement(6)));
          if (plb.ElementCount >= 8)  adjustmentList.Add ( AdjustmentFactory (subElementDelimeter, plb.GetElement(7),  plb.GetDecimalElement(8)));
          if (plb.ElementCount >= 10) adjustmentList.Add ( AdjustmentFactory (subElementDelimeter, plb.GetElement(9),  plb.GetDecimalElement(10)));
          if (plb.ElementCount >= 12) adjustmentList.Add ( AdjustmentFactory (subElementDelimeter, plb.GetElement(11), plb.GetDecimalElement(12)));
          if (plb.ElementCount == 14) adjustmentList.Add ( AdjustmentFactory (subElementDelimeter, plb.GetElement(13), plb.GetDecimalElement(14)));  
        }
      }
  }
}
