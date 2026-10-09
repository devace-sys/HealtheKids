USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_PROVIDER_LIST_AUDIT_RPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_PROVIDER_LIST_AUDIT_RPT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_PROVIDER_LIST_AUDIT_RPT] (
  @clientID  BIGINT
)

/***************************************************************************    
 * CYBHI_PROVIDER_LIST_AUDIT_RPT */    
/**    
 * Returns complete list of providers and if they can be included in
 * the TPA export and (if not) reasons why.
 * 
 * We pass the generateRosterMode value as 0 because this is called from
 * the cybhi dashboard and we need to keep that view partitioned
 ***************************************************************************/            

RETURNS TABLE

AS RETURN (
  select top (dbo.CONST_MAX_ROWS())
      RowNumber              
    , CanExportRow           
    , ProblemsDetected       
    , ChangeIndicator        
    , LocationID			   
    , ProviderID             
    , ProviderTypeID         
    , FirstName	           
    , LastName               
    , PrimaryDegree 
	, Degree2
    , Degree3         
    , ProvNPI                
    , ProvSSN                
    , ProvGender             
    /*
	, ProvDOB = dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER(try_convert(int,t1.ProvDOB))             
    */
	, t1.ProvDOB
	, StateLicense1          
    , License1State          
    /*
	, License1EffDt = dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER(try_convert(int,t1.License1EffDt))                  
    , License1ExpDt = dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER(try_convert(int,t1.License1ExpDt))         
    , ProviderEffDt = dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER(try_convert(int,t1.ProviderEffDt))         
    , ProviderExpDt = dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER(try_convert(int,t1.ProviderExpDt))         
    */
	, t1.License1EffDt                  
    , t1.License1ExpDt  

	, StateLicense2
    , License2State
    , t1.License2EffDt
    , t1.License2ExpDt

    , StateLicense3
    , License3State
    , t1.License3EffDt
    , t1.License3ExpDt
       
    , t1.ProviderEffDt         
    , t1.ProviderExpDt
	, MailAddr1              
    , MailCity               
    , MailState              
    , MailZip                
    , MailPhone              
    , ProviderEmail	
    , ProviderTaxID   
    , TaxIDType       
    , GroupName       
    , GroupNPI        
    , BillName        
    , BillAddr1       
    , BillCity        
    , BillState       
    , BillZip         
    , BillPhone       
    , PrimaryLocFlg   
    , HandicapFlg     
    
	/*
	, ServAddrEffDt = dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER(try_convert(int,t1.ServAddrEffDt))             
    , ServAddrExpDt = dbo.CALC_DATE_FROM_EXCEL_DATE_SERIAL_NUMBER(try_convert(int,t1.ServAddrExpDt))             
    */
	, t1.ServAddrEffDt
    , t1.ServAddrExpDt             

    , ServName        
    , ServAddr1       
    , ServCity        
    , ServState       
    , ServZip         
    , ServPhone       
    , LowAge          
    , HighAge         
    , FacilityName    
    , FacilityProviderType  
    , Plan01                
    , ProviderSpecialty1
    , ProviderSpecialty2
    , ProviderSpecialty3
    , ProviderSpecialty4    
  from dbo.CYBHI_PROVIDER_LIST_RPT_CORE (@clientID, 0) as t1 
  order by 
    t1.RowNumber
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_PROVIDER_LIST_AUDIT_RPT] TO [webuser]
GO