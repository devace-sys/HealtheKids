USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_EXCEPTIONS_APPLY') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIMS_EXCEPTIONS_APPLY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLAIMS_EXCEPTIONS_APPLY]    
 (@clientID            BIGINT )    
AS    
BEGIN    
   
/***************************************************************************    
 * CLAIMS_EXCEPTIONS_APPLY*/    
/**    
 * Updates the non-billable claims in CLAIMS_Claim table and SERVICE_RECORDS 
 * table to billable claims that are associted with the practitioners who  
 * are in CLAIM_PROCESSING_EXCEPTIONS TABLE.
 *
 * @param  clientID    Client id to apply exceptions to or null for all             
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
DECLARE @TranOpen        bit   
DECLARE @pracID          bigint 
DECLARE @count           int
DECLARE @startdate       datetime
DECLARE @enddate         datetime
DECLARE @id              int
DECLARE @claimID         bigint
DECLARE @billableProcID  int
DECLARE @billableNameID  int
DECLARE @procID          int
DECLARE @procmod1        varchar(10)
DECLARE @procmod2        varchar(10)
DECLARE @procmod3        varchar(10)
DECLARE @procCode        varchar(10)
DECLARE @exceptionNote   varchar(max)
DECLARE @dateCreated     datetime

/*---------------------------------------------------------				      
 * Temp table to store claims that have exceptions
 *--------------------------------------------------------*/

create table #claims_list(id          bigint IDENTITY(1,1),
                          claimid     bigint,
                          procid      int,
                          datecreated datetime)    
                          
/*---------------------------------------------------------				      
 * Temp table to store data from CLAIM_Procedures table
 * to avoid exceptions while comparing nulls in procedure
 * modifiers.
 *--------------------------------------------------------*/
 
declare @procedures table (procid     bigint,
                           proccode   varchar(10),
                           procmod1   varchar(10),
                           procmod2   varchar(10),
                           procmod3   varchar(10),
                           noplanname int,
                           iep_ifsp   int,
                           PUT_IN_837 BIT)   

insert into @procedures 
 select PROCEDURE_ID,PROCEDURE_CODE,  
        isnull(PROCEDURE_MODIFIER_1,''),
	    isnull(PROCEDURE_MODIFIER_2,''),
	    isnull(PROCEDURE_MODIFIER_3,''),
	    NO_PLAN_NAME,IEP_IFSP_NAME,
	    PUT_IN_837 
   from CLAIM_Procedures 
  where PROCEDURE_CODE in ('QT1017','T1017')

/*---------------------------------------------------------				      
 * Temp table to store active rows in CLAIMS_PROCESSING_EXCEPTIONS table
 *--------------------------------------------------------*/
 
declare @claimProcessingExceptions table (id          bigint IDENTITY(1,1),
                                          pracid      bigint,
                                          startdate   datetime,
                                          enddate     datetime,
                                          exceptionID int)   

insert into @claimProcessingExceptions
  select PRACTITIONER_ID,START_DATE,END_DATE,EXCEPTION_ID 
    from CLAIMS_PROCESSING_EXCEPTIONS
   where ACTIVE = 1 and ((@clientID is null) or (CLIENT_ID = @clientID))                                           

BEGIN TRY    
   
	select @count = COUNT(*) from @claimProcessingExceptions	
    print 'Number of practitioners who have MAA-TCM exceptions: ' + convert(varchar(50),@count)
	set @id = 1

 BEGIN TRANSACTION    
	   
	  SET @TranOpen = 1	  

 /*---------------------------------------------------------				      
  * Loop through CLAIMS_PROCESSING_EXCEPTIONS table and insert
  * the list of claims associted with each practitioner into
  * #claims_list table
  *--------------------------------------------------------*/
	   
	 while (@id<=@count)
	  begin
	    
	    select 
	      @pracID    = pracid,
	      @startdate = startdate,
	      @enddate   = enddate 
	    from @claimProcessingExceptions
	    where id = @id
	    
	    insert into #claims_list
	      select
	        CLAIM_ID,
	        PROCEDURE_ID,
	        ENTRY_DATE 
	      from CLAIM_Claim
	      where ((@clientID is null) or (CLIENT_ID = @clientID)) and
	             PRACTITIONER_ID = @pracID and
	             PROCEDURE_ID in (select procid from @procedures where proccode = 'QT1017' AND PUT_IN_837 = 0) and	             
	             SERVICE_DATE between @startdate and @enddate
	           
	             	
	    set @id = @id +1  
	  end

 /*---------------------------------------------------------				      
  * Loop through #claims_list table and update CLAIM_Claim,
  * SERVICE_RECORD AND CLAIM_Claim_Notes tables
  *--------------------------------------------------------*/
  	  
	 select @count = COUNT(*) from #claims_list
     print 'Number of outstanding claims MAA-TCM exception applies to: ' + convert(varchar(50),@count)

	 set @id = 1
	 	 
	 while (@id<=@count)
	  begin
	    
	    select 
	      @claimID = claimid,
	      @procID  = procid,
	      @dateCreated = datecreated
	    from #claims_list
	    where id = @id
	     
	     /*---------------------------------------------------------				      
          * Get the procedure code and modifiers to find the related
          * billable procedureID and store it in @billableProcID
          *--------------------------------------------------------*/
	     
	     select @procmod1 = procmod1,@procmod2 = procmod2,
	            @procmod3 = procmod3,@procCode = proccode
	       from @procedures
	      where procid = @procid
	      
	      set @procCode = substring(@procCode,2,len(@procCode)-1)
	    
	     select @billableProcID = procid,
	            @billableNameID = Coalesce(noplanname,iep_ifsp) 
	       from @procedures	        
	      where proccode = @procCode and
	            procmod1 = @procmod1 and
	            procmod2 = @procmod2 and
	            procmod3 = @procmod3	            
	    
	    /*----------------------------------------------------------------
         * Get the note from name field in CLAIMS_PROCESSING_EXCEPTION_LIST 
         * table to insert into CLAIM_Claim_Notes table
         *----------------------------------------------------------------*/ 
               
	     select @exceptionNote = name from CLAIMS_PROCESSING_EXCEPTION_LIST   
	     
	     update CLAIM_Claim
	        set PROCEDURE_ID = @billableProcID,LAST_UPDATED = GETDATE()
	      where CLAIM_ID = @claimID    
	      	      
	     update SERVICE_RECORDS
	        set nameID = @billableNameID,lastmodified = GETDATE()
	      where ((claimID1 = @claimID) or (claimID2 = @claimID) or (claimID3 = @claimID))
	      
	     insert into CLAIM_Claim_Notes
	          values (@claimID,@exceptionNote,@dateCreated,GETDATE())    	 
	          
	     set @id = @id +1     	  
	  end
	     
 COMMIT TRANSACTION  
 
  /*-------------------------------
   * Post cleanup,drop temp tables
   *------------------------------*/ 
   
 if OBJECT_ID('tempdb..#claims_list') IS NOT NULL
   drop table #claims_list
   
  /*-------------------------------    
   * Reset our transaction flag and
   * retry counter
   *------------------------------*/  

	SET @TranOpen = 0    
	RETURN(0)    

END TRY    
   
BEGIN CATCH   

 /*-------------------------------
   * Post cleanup,drop temp tables
   *------------------------------*/ 
   
  if OBJECT_ID('tempdb..#claims_list') IS NOT NULL
   drop table #claims_list
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)  
     
   
END CATCH    
END    
GO

