using System;
using System.Collections.Generic;
using System.Linq;

namespace MBA.X12.X835
{
  
  public class TransactionSetDetail
  {

    public TransactionSetDetail (    long     idx
                                   , string   tsControlNumber
                                   , string   providerName
                                   , string   providerNPI                                                                                                     
                                   , string   lx
                                   , string   claimIDRef
                                   , string   claimStatusCode
                                   , Decimal? claimAmountSubmitted
                                   , Decimal? claimAmountPaid
                                   , string   claimCtrlNum
                                   , string   patientLastName
                                   , string   patientFirstName
                                   , string   patientBIC
                                   , string   procSubElems
                                   , Decimal? svcAmountSub
                                   , Decimal? svcAmountPaid
                                   , long?    svcUnitsPaid
                                   , List<ICasAdjustment>       claimLevelAdjustments
                                   , List<ICasAdjustment>       serviceLevelAdjustments
                                   , List<HealthCareRemarkCode> healthCareRemarkCodes)
    {
      
      this.IDX                     = idx;
      this.TSControlNumber         = tsControlNumber;
      this.ProviderName            = providerName;
      this.ProviderNPI             = providerNPI;
      this.LX                      = lx;
      this.ClaimIDRef              = claimIDRef;
      this.ClaimStatusCode         = claimStatusCode;
      this.ClaimAmountSubmitted    = claimAmountSubmitted.HasValue ? claimAmountSubmitted.Value : 0m;
      this.ClaimAmountPaid         = claimAmountPaid.HasValue      ? claimAmountPaid.Value      : 0m;
      this.ClaimControlNumber      = claimCtrlNum;
      this.PatientLastName         = patientLastName;
      this.PatientFirstName        = patientFirstName;
      this.PatientBIC              = patientBIC;
      this.ProcedureSubElements    = procSubElems;
      this.SvcAmountSubmitted      = svcAmountSub.HasValue  ? svcAmountSub.Value  : 0m;
      this.SvcAmountPaid           = svcAmountPaid.HasValue ? svcAmountPaid.Value : 0m;
      this.SvcUnitsPaid            = svcUnitsPaid.HasValue  ? svcUnitsPaid.Value  : 0;      
      this.ClaimLevelAdjustments   = claimLevelAdjustments;
      this.ServiceLevelAdjustments = serviceLevelAdjustments;
      this.HealthCareRemarkCodes   = healthCareRemarkCodes;
    }
    
    public long     IDX                    { get; private set; }
    public String   TSControlNumber        { get; private set; }
    public String   ProviderName           { get; private set; }
    public String   ProviderNPI            { get; private set; }
    public String   LX                     { get; private set; }
    public String   ClaimIDRef             { get; private set; }
    public String   ClaimStatusCode        { get; private set; }
    public Decimal  ClaimAmountSubmitted   { get; private set; }
    public Decimal  ClaimAmountPaid        { get; private set; }
    public String   ClaimControlNumber     { get; private set; }
    public String   PatientLastName        { get; private set; }
    public String   PatientFirstName       { get; private set; }
    public String   PatientBIC             { get; private set; }
    public String   ProcedureSubElements   { get; private set; }
    public Decimal  SvcAmountSubmitted     { get; private set; }
    public Decimal  SvcAmountPaid          { get; private set; }
    public long     SvcUnitsPaid           { get; private set; }
    
    public List<ICasAdjustment>       ClaimLevelAdjustments   { get; private set; }
    public List<ICasAdjustment>       ServiceLevelAdjustments { get; private set; }
    public List<HealthCareRemarkCode> HealthCareRemarkCodes   { get; private set; }

  }

}
