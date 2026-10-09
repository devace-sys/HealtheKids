USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_VIEW_BY_PRAC_PAT_PLAN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_VIEW_BY_PRAC_PAT_PLAN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICES_VIEW_BY_PRAC_PAT_PLAN] (
   @clientID  INT
 , @pracID    INT
 , @patID     INT
 , @dos       DATE     
 , @planType  INT    
 , @nameID    INT    
 , @is22      BIT
 , @trnPrcNum SMALLINT
 , @isSvcSel  BIT )    

RETURNS 
TABLE 
AS 
RETURN 
(
  with
  cte_p1
  as
  (
     select           
        vpa.SERVICE_NAME_ID        as nameID
      , vpa.[SERVICE_NAME]         as name
      , vpa.GROUP_NAME             as groupname
      , vpa.PROCEDURE_MIN_UNITS    as minUnits    
      , vpa.PROCEDURE_MAX_UNITS    as maxUnits
      , vpa.SERVICE_TYPE_ID        as svcType    
      , vpa.SERVICE_PLAN_TYPE_ID   as planType
      , vpa.PROCEDURE_CLAIM_SPAN_2 as span2
      , vpa.PROCEDURE_ID           as procID
      , vpa.[PROCEDURE_NAME]       as procName
      , vpa.PROCEDURE_CODE         as procCode
      , vpa.PROCEDURE_MOD_1        as procMod1
      , vpa.PROCEDURE_MOD_2        as procMod2
      , vpa.PROCEDURE_MOD_3        as procMod3
      , vpa.PROCEDURE_MOD_4        as procMod4
      , pc.CLIENT_ID               as clientID    
      , pg.GROUP_ID                as groupID
      , gg.GROUP_BASE              as groupBase
      , vpa.SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_1 as showOptions1
      , vpa.SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_2 as showOptions2
	  , vpa.SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_3 as showOptions3  
      , vpa.GROUP_SERVICE_CLASS_NAME_ID                as groupServiceClassNameID
      , vpa.GROUP_SERVICE_CLASS_NAME_NAME              as groupServiceClassNameName
      , vpa.PROCEDURE_CODE_IS_Q                        as svcMayBeBillableInFuture
      , vpa.PROCEDURE_CODE_IS_QQ                       as svcIsNeverBillable
      , dbo.IS_AUTO_SELECT_ORP_DOC_POSSIBLE (vpa.GROUP_SERVICE_CLASS_NAME_ID) as isAutoSelectORPDocPossible
	  , vpa.SERVICE_RENDERED_VIA                       as svcRenderedVia
      
	  , vpa.SERVICE_PLAN_TYPE                          as svcPlanTypeName	  
	  , vpa.SERVICE_TYPE                               as svcTypeName
	  , vpa.SERVICE_SUB_TYPE_1                         as svcSubType1Name
	  , convert(varchar(50),isnull(vpa.SERVICE_SUB_TYPE_1_ID,''))  as svcSubType1IDStr
	  , vpa.CALPADS_SPED_SVC_CODE_NAME                             as calpadsCodeName
	  , vpa.CALPADS_SPED_SVC_CODE_VALUE_STR                        as calpadsCodeValueStr
	 
	  , selectionNameWithoutInPersonOrTelehealthText = vpa.[SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT]
      , selectionForModalityFlags                    = vpa.[SELECTION_FOR_MODALITY_FLAGS]
	  , selectionAltModalityNameID                   = vpa.[SERVICE_NAME_ID_ALT_MODALITY] 
      , procedureBillingProgramID                    = vpa.PROCEDURE_BILLING_PROGRAM_ID
	  , serviceEntryOrpDocumentRequired              = vpa.SERVICE_ENTRY_ORP_DOCUMENT_REQUIRED
    
	 from dbo.CLIENTS_Client            as cc
     join dbo.PRACTITIONER_Client       as pc   on  pc.CLIENT_ID       = cc.CLIENT_ID
     join dbo.PRACTITIONER_Practitioner as p    on  p.PRACTITIONER_ID  = pc.PRACTITIONER_ID
     join dbo.PRACTITIONER_GROUPS       as pg   on  pg.PRACTITIONER_ID = p.PRACTITIONER_ID
                                                and pg.GROUP_TYPE      in (1,2)  
     join dbo.GROUP_GROUP               as gg   on  gg.GROUP_ID        = pg.GROUP_ID
 
     cross apply (
        
       select 
         svac.* 
       from dbo.SERVICES_VIEW_ALL_CORE (  pc.CLIENT_ID
                                        , pg.GROUP_ID
                                        , @planType
                                        , null
                                        , @nameID
                                        , 1
                                        , 1
                                        , @dos
                                        , @isSvcSel ) as svac
       where ( 
              (GROUP_ID         = pg.GROUP_ID)
         and  (PROCEDURE_HAS_22 = @is22)
         and  ((@trnPrcNum IS NULL) or (PROCEDURE_TRANS_PROC_NUM = @trnPrcNum))
       )
     ) as vpa
  
 
     where (
             (cc.CLIENT_ID       = @clientID)
       and   (pc.CLIENT_ID       = @clientID)
       and   (pc.PRACTITIONER_ID = @pracID)
       and   (p.PRACTITIONER_ID  = @pracID)	   
     )
  )
  ,
  cte_p2
  as
  (
    select 
    
        nameID
      , name
      , groupname
      , minUnits    
      , maxUnits
      , svcType    
      , planType
      , span2
      , procID
      , procName
      , procCode
      , procMod1
      , procMod2
      , procMod3
      , procMod4
      , clientID    
      , groupID
      , groupBase
      , showOptions1
      , showOptions2 =  isnull(showOpts2.valueStr,'')
	  , showOptions3 
      , groupServiceClassNameID
      , groupServiceClassNameName
      , svcMayBeBillableInFuture
      , svcIsNeverBillable
      , isAutoSelectORPDocPossible
	  , svcRenderedVia
	  
	  , svcPlanTypeName	  
	  , svcTypeName
	  , svcSubType1Name
	  , svcSubType1IDStr
	  , calpadsCodeName
	  , calpadsCodeValueStr
	  , selectionNameWithoutInPersonOrTelehealthText
	  , selectionForModalityFlags
	  , selectionAltModalityNameID
	  , serviceEntryOrpDocumentRequired

    from cte_p1 as p1
        
    outer apply (                      
      
      select valueStr = 
      case                    
      
       /* 
        * If we are requiring a doc selection at this point then there
        * is no client wide "covering" document available.  
        * Determine if there is no individual document that would be autoselected
        * Note: The selection required logic is also performed in
        * PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_ON_DOS_VIEW.sql
		* and the logic needs to be kept in synch with any changes to that files logic.
        */
                                  
      when (p1.showOptions2 = 'SHOW_TREATMENT_ORP_DOC_SELECTION')
      then                      
        case when ( (select top 1 OrpDocumentID 
		from dbo.GET_ORP_PRAC_NPI_DATA (  
		  p1.svcIsNeverBillable
		, p1.svcType
		, @dos 
		, @clientID 
		, p1.groupID
		, null
		, @patID
		, p1.procedureBillingProgramID
		)) is not null ) 
        then ''               /* Override value because our routine would normally autoselect one */
        else p1.showOptions2  /* Otherwise pass original value on*/
        end       
      else 
        p1.showOptions2   /* Otherwise just pass original value through */ 
      end            
    ) as showOpts2  
  )
  
  select top (dbo.CONST_MAX_ROWS()) 
    p2.* 
  from cte_p2 as p2
  order by 
      p2.svcType
    , p2.svcSubType1IDStr
	, p2.name
)    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICES_VIEW_BY_PRAC_PAT_PLAN] TO [webuser]
GO
