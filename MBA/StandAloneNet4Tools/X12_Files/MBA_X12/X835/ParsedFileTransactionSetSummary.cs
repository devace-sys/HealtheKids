using System;
using System.Collections.Generic;
using System.Linq;

namespace MBA.X12.X835
{
 
  /// <summary>
  /// Summary of data in 835 
  /// </summary>
  
  public class TransactionSetSummary
  {

    public TransactionSetSummary(   long     idx
                                  , string   tsControlNumber  
                                  , string   providerName
                                  , string   providerNPI
                                  , string   warrantNumber
                                  , DateTime? warrantDate
                                  , Decimal?  warrantAmount
                                  , Decimal  totalClaimsPaidAmountAll
                                  , Decimal  totalClaimsPaidAmountUs
                                  , Decimal  totalClaimsPaidAmountOther
                                  , Decimal  totalAdjustmentsAmount
                                  , List<IPlbAdjustment> provLevelAdjustments)
    {
      this.IDX             = idx;
      this.TSControlNumber = tsControlNumber;
      this.ProviderName    = providerName;
      this.ProviderNPI     = providerNPI;
      this.WarrantNumber   = warrantNumber;
      this.WarrantDate     = warrantDate.HasValue   ? warrantDate.Value   : DateTime.Today;
      this.WarrantAmount   = warrantAmount.HasValue ? warrantAmount.Value : 0;
      
      this.TotalClaimsPaidAmountAll   = totalClaimsPaidAmountAll;
      this.TotalClaimsPaidAmountUs    = totalClaimsPaidAmountUs;
      this.TotalClaimsPaidAmountOther = totalClaimsPaidAmountOther;
      this.TotalAdjustmentsAmount     = totalAdjustmentsAmount;
      this.ProviderLevelAdjustments   = provLevelAdjustments;
    }
    
    public long     IDX              { get; private set; }
    public String   TSControlNumber  { get; private set; }
    public String   ProviderName     { get; private set; }
    public String   ProviderNPI      { get; private set; }
    
    public string   WarrantNumber    { get; private set; }
    public DateTime WarrantDate      { get; private set; }
    public Decimal  WarrantAmount    { get; private set; }
    
    public Decimal  TotalClaimsPaidAmountAll   { get; private set;}
    public Decimal  TotalClaimsPaidAmountUs    { get; private set;}
    public Decimal  TotalClaimsPaidAmountOther { get; private set;}
    public Decimal  TotalAdjustmentsAmount     { get; private set;}
    
    /// <summary>
    /// All provider level adjustements 
    /// </summary>
    
    public List<IPlbAdjustment> ProviderLevelAdjustments { get; private set; }
    
    /// <summary>
    /// Total (NET) amount of all provider level adjustements that are identified as processing fees
    /// </summary>

    public Decimal TotalAdjustmentsAmountProcessingFees
    {
      get
      {
        return this.ProviderLevelAdjustments
          .AsParallel()
          .OfType<ProviderLevelAdjustmentProcessingFee>()
          .Sum(a => a.Amount);
      }
    }
   
    /// <summary>
    /// Total (NET) amount of all provider level adjustements that are not processing fees
    /// </summary>
 
    public Decimal TotalAdjustmentsAmountNonProcessingFees
    {
      get
      {
         return (this.TotalAdjustmentsAmount - this.TotalAdjustmentsAmountProcessingFees);
      }
    }
 
    /// <summary>
    /// Percentage of amount deducted from each paid claim for processing fees
    /// </summary>
    
    public Decimal ProcessingFeePercentagePerClaimFromUs
    {
      get
      {
        
        Decimal pct = 0;
        if (WarrantAmount > 0) /* If the client is getting money */
          if (TotalAdjustmentsAmountProcessingFees > 0) /* And DHCS withheld fees */
            pct = (WarrantAmount / (WarrantAmount + TotalAdjustmentsAmountProcessingFees)); /* Calculate an ajustment percentage */            
        return pct;
      }
    }    
  }       
}
