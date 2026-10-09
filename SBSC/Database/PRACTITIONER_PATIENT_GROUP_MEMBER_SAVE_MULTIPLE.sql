USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS ( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE_MULTIPLE')  AND type IN (N'P', N'PC'))
  DROP PROCEDURE dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE_MULTIPLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE PROCEDURE dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE_MULTIPLE
(
    @userID         BIGINT,
    @userGroup      INT,
    @userRank       INT,
    @editDelReason  VARCHAR(7000),
    @validateRec    BIT,
    @saveType       INT,
    @clientID       BIGINT,      
    @pracID         BIGINT,       
    @groupID        BIGINT,      
    @patSelectedJSON VARCHAR(MAX),-- array JSON [{ "patID": 123 }, … ]
	@recID          INT,
    @MsgNoRec       VARCHAR(1000),
    @MsgNoEdit      VARCHAR(1000),
    @MsgDupRec      VARCHAR(1000),
    @MsgDataError   VARCHAR(1000),
    @MsgNotActive   VARCHAR(1000),
    @spDetails      VARCHAR(8000) OUTPUT,
    @recordID		BIGINT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @tranOpen     BIT            = 0,
        @maxIdx       INT,
        @curIdx       INT            = 1,
        @patID        BIGINT,
        @recIDOut     BIGINT,
		@jsonDataOut  VARCHAR(MAX),
        @spDetailsOut VARCHAR(8000),
		@recordCount  INT;
    
    DECLARE @Items TABLE (
        idx   INT IDENTITY(1,1) PRIMARY KEY,
        patID BIGINT
    );

    BEGIN TRY
        /*-------------------------------
         * Init outputs
         *------------------------------*/
        SET @spDetails		= ''
        SET @recordCount	= 0
		SET @recordID		= 0

        /*-------------------------------
         * Param validation
         *------------------------------*/
        IF @userID      IS NULL RAISERROR('userID is required',       11, 1);
        IF @userGroup   IS NULL RAISERROR('userGroup is required',    11, 1);
        IF @userRank    IS NULL RAISERROR('userRank is required',     11, 1);
        IF @validateRec IS NULL RAISERROR('Validate flag required',   11, 1);
        IF @saveType    IS NULL RAISERROR('Save type is required',    11, 1);
        IF @clientID    IS NULL RAISERROR('clientID is required',     11, 1);
        IF @pracID      IS NULL RAISERROR('pracID is required',       11, 1);
        IF @groupID     IS NULL RAISERROR('groupID is required',      11, 1);

        /*-------------------------------
         * Parse JSON into @Items
         *------------------------------*/
        INSERT INTO @Items(patID)
        SELECT
          patID
        FROM openjson(@patSelectedJSON)
        WITH (
          patID BIGINT '$.patID'
        );

        SELECT @maxIdx = COUNT(*) FROM @Items;
        IF @maxIdx = 0
        BEGIN
          RETURN(0);
        END

        IF @validateRec = 1
        BEGIN          
          RETURN(0);
        END
        
        BEGIN TRANSACTION;
          SET @tranOpen = 1;

          WHILE @curIdx <= @maxIdx
          BEGIN
            SELECT @patID = patID
              FROM @Items
             WHERE idx = @curIdx;

            EXEC dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE
              @userID         = @userID,
              @userGroup      = @userGroup,
              @userRank       = @userRank,
              @clientID       = @clientID,
              @pracID         = @pracID,
              @pracPatGroupID = @groupID,
              @patID          = @patID,
              @editDelReason  = @editDelReason,
              @validateRec    = @validateRec,
              @saveType       = @saveType,
              @recID          = @recID,
              @MsgNoRec       = @MsgNoRec,
              @MsgNoEdit      = @MsgNoEdit,
              @MsgDupRec      = @MsgDupRec,
              @MsgDataError   = @MsgDataError,
              @MsgNotActive   = @MsgNotActive,
              @spDetails      = @spDetailsOut OUTPUT,
              @recordID       = @recIDOut OUTPUT,
			  @jsonData       = @jsonDataOut  OUTPUT; 

            SET @curIdx = @curIdx + 1;
          END

          SET @recordCount = @maxIdx;
        COMMIT TRANSACTION;
        SET @tranOpen = 0;
		set @recIDOut = @recordCount
        RETURN(0);
    END TRY

    BEGIN CATCH
        IF @tranOpen = 1
            ROLLBACK TRANSACTION;

        DECLARE
          @ErrorMessage  NVARCHAR(4000),
          @ErrorSeverity INT,
          @ErrorState    INT;

        SELECT
          @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON dbo.PRACTITIONER_PATIENT_GROUP_MEMBER_SAVE_MULTIPLE TO webuser;
GO
