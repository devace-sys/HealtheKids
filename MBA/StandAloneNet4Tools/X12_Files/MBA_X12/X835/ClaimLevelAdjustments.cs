using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using OopFactory.X12.Parsing;
using OopFactory.X12.Parsing.Model;

namespace MBA.X12.X835
{
  
  public enum CasAdjustmentLevel
  {
      CLAIM
    , SERVICE
  }
  
  /// <summary>
  /// Claim level adjustement interface.
  /// </summary>
  
  public interface ICasAdjustment
  {
    String   GroupCode    { get; set; }
    String   ReasonCode   { get; set; }
    Decimal? Amount       { get; set; }
    Decimal? Quantity     { get; set; }
  }
  
  
  public class CasAdjustement: ICasAdjustment
  {
    public CasAdjustement (   string groupCode
                            , string reasonCode
                            , Decimal? amount
                            , Decimal? quantity)
    {
      this.GroupCode  = groupCode;
      this.ReasonCode = reasonCode;
      this.Amount     = amount;
      this.Quantity   = quantity;
    }

    public String   GroupCode    { get; set; }
    public String   ReasonCode   { get; set; }
    public Decimal? Amount       { get; set; }
    public Decimal? Quantity     { get; set; }  
  }
  
  public class ClaimLevelAdjustment: CasAdjustement
  {
    public ClaimLevelAdjustment (  string groupCode
                                 , string reasonCode
                                 , Decimal? amount
                                 , Decimal? quantity) : base(groupCode, reasonCode, amount, quantity)     
    {
    }
    
  }
  
  public class ServiceLevelAdjustment: CasAdjustement
  {
    public ServiceLevelAdjustment (  string groupCode
                                  , string reasonCode
                                  , Decimal? amount
                                  , Decimal? quantity) : base(groupCode, reasonCode, amount, quantity)     
    {
    }
    
  }
 
  
  public static class CASAdjustments
  {
   
    
    public static ICasAdjustment CASAdjustmentFactory (  CasAdjustmentLevel level
                                                       , string groupCode
                                                       , string reasonCode
                                                       , Decimal? amount
                                                       , Decimal? quantity)
    {
      if      (level == CasAdjustmentLevel.CLAIM)   return new ClaimLevelAdjustment (groupCode,reasonCode,amount,quantity);
      else if (level == CasAdjustmentLevel.SERVICE) return new ServiceLevelAdjustment (groupCode,reasonCode,amount,quantity);
      else return new CasAdjustement(groupCode, reasonCode, amount, quantity);
    }
    
    public static void ExtractClaimAdjustmentsFromSegmentAndAddToList (   CasAdjustmentLevel level
                                                                        , ref Segment cas
                                                                        , ref List<ICasAdjustment> adjustmentList 
                                                                     )
      {               
        
        /* 6 possible claim level adjustements per segment */
        
        if (cas != null)
        {
          if (cas.ElementCount >= 3)   adjustmentList.Add ( CASAdjustmentFactory (level, cas.GetElement(1),  cas.GetElement(2), cas.GetDecimalElement(3), cas.GetDecimalElement(4)));
          if (cas.ElementCount >= 5)   adjustmentList.Add ( CASAdjustmentFactory (level, cas.GetElement(1),  cas.GetElement(5), cas.GetDecimalElement(6), cas.GetDecimalElement(7)));         
          if (cas.ElementCount >= 8)   adjustmentList.Add ( CASAdjustmentFactory (level, cas.GetElement(1),  cas.GetElement(8), cas.GetDecimalElement(9), cas.GetDecimalElement(10)));
          if (cas.ElementCount >= 11)  adjustmentList.Add ( CASAdjustmentFactory (level, cas.GetElement(1),  cas.GetElement(11), cas.GetDecimalElement(12), cas.GetDecimalElement(13)));          
          if (cas.ElementCount >= 14)  adjustmentList.Add ( CASAdjustmentFactory (level, cas.GetElement(1),  cas.GetElement(14), cas.GetDecimalElement(15), cas.GetDecimalElement(16)));         
          if (cas.ElementCount >= 17)  adjustmentList.Add ( CASAdjustmentFactory (level, cas.GetElement(1),  cas.GetElement(17), cas.GetDecimalElement(18), cas.GetDecimalElement(19)));                                                          
        }
      }
  }
}
