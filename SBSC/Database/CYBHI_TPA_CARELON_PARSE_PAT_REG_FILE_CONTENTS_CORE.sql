USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_TPA_CARELON_PARSE_PAT_REG_FILE_CONTENTS_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CYBHI_TPA_CARELON_PARSE_PAT_REG_FILE_CONTENTS_CORE
GO

/*-------------------------------
 * Create Procedure
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CYBHI_TPA_CARELON_PARSE_PAT_REG_FILE_CONTENTS_CORE] (
    @fileClass                tinyint = 2 
  , @fileContentsIn           varchar(max)      
  , @fileContentsJSONOut      varchar(max)  output )    
AS    
BEGIN     
    
/***************************************************************************    
 * CYBHI_TPA_CARELON_PARSE_PAT_REG_FILE_CONTENTS_CORE */    
/**    
 *   
 ***************************************************************************/         
     
SET NOCOUNT ON    

/*============================================================
 * Init output parameters and worker variables
 *===========================================================*/  

set @fileContentsJSONOut = '{"patients":[]}'

BEGIN TRY

IF (@fileContentsIn IS NULL) RAISERROR ('File contents required',  11, 1)

declare @lineIn            as varchar(max) = ''
declare @lineOut           as varchar(max) = ''
declare @startPos          as int          = 0
declare @size              as int          = 0
declare @cellNameOut       as varchar(max) = ''
declare @cellValueOut      as varchar(max) = ''
declare @cellOut           as varchar(max) = ''

declare @curIdxLayout      as int = 0
declare @maxIdxLayout      as int = 0
declare @curIdxFileLinesIn as int = 0
declare @maxIdxFileLinesIn as int = 0

declare @layout as table (
    idx        int identity(1,1) not null
  , fieldNum   int
  , fieldName  varchar(512)
  , size       int
  , startPos   int
  , endPos     int 
  , visible    bit
  , padRight   bit default(1)
  unique clustered (idx)
)

declare @fileLinesIn as table (       
    idx  int          identity (1,1) not null
  , line varchar(max)
  unique clustered (idx)
)

declare @fileLinesOut as table (
  line varchar(max)
)

declare @cellsOut as table (
  cellOut varchar(max)
)

insert into @fileLinesIn (
  line
)
select
  line
from
(
  select 
    line = replace(t1.[value],char(13),'') 
  from STRING_SPLIT (@fileContentsIn,char(10)) as t1
) as q1
where 
  (q1.line != '')


/*============================================================
 * If there are no lines to process then exit
 *============================================================*/  

if not exists (select top 1 * from @fileLinesIn)
begin
  return(0)
end

/*============================================================
 * Get layout
 *============================================================*/  

insert into @layout (
    fieldNum
  , fieldName 
  , size       
  , startPos   
  , endPos     
  , visible    
  , padRight   
)
select 
    t1.fieldNum
  , t1.fieldName 
  , t1.size       
  , t1.startPos   
  , t1.endPos     
  , t1.visible    
  , t1.padRight   
from dbo.CYBHI_TPA_CARELON_GET_PAT_REG_FILE_LAYOUT (@fileClass) as t1

/*============================================================
 * If layout not found exit
 *============================================================*/  

if not exists (select top 1 * from @layout) 
begin
  return(0)
end

/*============================================================
 * Get data we need to control loops
 *============================================================*/  

select @maxIdxLayout         = max(l.idx)   from @layout      as l
select @maxIdxFileLinesIn    = max(fli.idx) from @fileLinesIn as fli
set    @curIdxLayout         = 1 
set    @curIdxFileLinesIn    = 1

/*============================================================
 * For each line in
 *============================================================*/  

while (@curIdxFileLinesIn <= @maxIdxFileLinesIn)
begin

  
  set @curIdxLayout = 1
  select top 1 @lineIn = fli.line from @fileLinesIn as fli where (fli.idx = @curIdxFileLinesIn)
 
  /*============================================================
   * For each line part
   *============================================================*/  
 
  while (@curIdxLayout <= @maxIdxLayout)
  begin

    set @cellNameOut = ''
	set @startPos    = -1
	set @size        = -1
	 
	/*============================================================
     * Get field name and position of its value in the line
     *============================================================*/  
 
    select top 1 
	    @cellNameOut = string_escape(l.fieldName,'json')
	  , @startPos    = l.startPos
	  , @size        = l.size
	from @layout as l 
	where 
	  (l.idx = @curIdxLayout)
	
	/*============================================================
     * Extract value
     *============================================================*/  

    set @cellValueOut = string_escape((trim(substring (@lineIn, @startPos, @size))),'json')

	/*============================================================
     * Build the "name":"value" pair
     *============================================================*/  

	set @cellOut = '"' + @cellNameOut + '":"' + @cellValueOut + '"'
	insert into @cellsOut (cellOut) values (@cellOut)
	set @curIdxLayout = @curIdxLayout + 1
  end  /* layout */  
  
  set @lineOut = ''
  
  /*============================================================
    * Build the
	*
	* { "name":"value", "name":"value", ... "name":"value" }
	*
	* object string
    *============================================================*/  
  
  select @lineOut = '{' + string_agg(t1.cellOut,',') + '}' from @cellsOut as t1   
  insert into @fileLinesOut (line) values (@lineOut)

  delete @cellsOut

  set @curIdxFileLinesIn = @curIdxFileLinesIn + 1  
  
end /* lines in */ 

/*============================================================
  * Build the return json string  
  *============================================================*/  

select @fileContentsJSONOut = '{"patients":[' + string_agg(t1.line,',') + ']}' from @fileLinesOut as t1

/*============================================================
 * All done
 *============================================================*/  

RETURN(0)    

END TRY

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CYBHI_TPA_CARELON_PARSE_PAT_REG_FILE_CONTENTS_CORE] TO [webuser]
GO
