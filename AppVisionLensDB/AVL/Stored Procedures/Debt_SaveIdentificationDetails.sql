/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Ram kumar>
-- Modified date: <02/15/2019>
-- Description:	<Debt_SaveIdentificationDetails>
-- =============================================
--EXEC [AVL].[Debt_SaveIdentificationDetails] 'on','','on','2019-05-02','on','2019-02-11','1','5.00','10337','627130','null','7079','N','2019-04-11','N'
CREATE PROCEDURE [AVL].[Debt_SaveIdentificationDetails] --'','','','','on','12-18-2018','0','10.00','22026','245829','','9032','N'
(
@IsML VARCHAR(50),
@MLDate VARCHAR(50),
@IsDD VARCHAR(50),
@DDDate VARCHAR(50),
@IsManual VARCHAR(50),
@ManualDate VARCHAR(50),
@IsCostTracked VARCHAR(50),
@Hour NUMERIC(10,2),
@ProjectID VARCHAR(50),
@UserID VARCHAR(50),
@DebtReview VARCHAR(50),
@CustomerID VARCHAR(50),
--@IsCL VARCHAR(30),
@IsTicketApprovalStatus VARCHAR(10),
@DebtEnablementDate VARCHAR(50),
@IsMLPatternNoNeed VARCHAR(50),
@IsMLinfra VARCHAR(50),
@MLDateinfra VARCHAR(50),
@InfraBlendedRate NUMERIC(10,2),
@SupportTypeId INT
)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	DECLARE @ESAProjectID VARCHAR(50)
	DECLARE @CompletionPercentage BIGINT
	SET @ESAProjectID =  (SELECT ESAProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted = 0)
	
	IF @IsManual = 'on'
	BEGIN
	
		IF EXISTS (SELECT 1 FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted=0)
		BEGIN
		print'manual1'
		--select @ProjectID as '1'
		--select @ManualDate as '2'
			UPDATE AVL.MAS_ProjectDebtDetails SET ManualDate = 	ISNULL(NULLIF(@ManualDate, ''), null),IsManual = 'Y', IsTicketApprovalNeeded=@IsTicketApprovalStatus,ModifiedBy=@UserID,ModifiedDate=GETDATE()
			   WHERE ProjectID = @ProjectID AND IsDeleted=0
			--IF((SELECT DebtEnablementDate FROM AVL.MAS_ProjectDebtDetails WHERE ProjectID = @ProjectID AND IsDeleted=0) IS NULL)
			--BEGIN
			--	UPDATE AVL.MAS_ProjectDebtDetails SET DebtEnablementDate = @DebtEnablementDate,IsTicketApprovalNeeded=@IsTicketApprovalStatus
			--	 WHERE ProjectID = @ProjectID AND IsDeleted=0 
			--END
			--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @ProjectID AND IsDeleted = 0
		END
		ELSE
		BEGIN
		print'manual2'
		INSERT INTO AVL.MAS_ProjectDebtDetails
		(
			ProjectID
			,EsaProjectID
			,DebtEnablementDate
			,IsDeleted
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,DebtControlDate
			,DebtControlFlag
			,IsTicketApprovalNeeded
			,EnablementSuperAdminId
			,ControlSuperAdminId
			,IsAutoClassified
			,AutoClassificationDate
			,IsMLSignOff
			,MLSignOffDate
			,MLSignOffUserId
			,AutoClassifiedBy
			,IsDDAutoClassified
			,IsDDAutoClassifiedDate
			,IsDDAutoClassifiedBy
			,IsCostTracked
			,DebtControlMethod
			,ISCLSIGNOFF
			,CLSIGNOFFDATE
			,CLSIGNOFFUSERID
			,IsManual
			,ManualDate
			,IsCLAutoClassified
			,CLAutoClassifiedDate
			,CLAutoClassifiedBy
			,OptionalAttributeType
			,IsAutoClassifiedInfra
			,AutoClassificationDateInfra
			,IsMLSignOffInfra
			,MLSignOffDateInfra
			,MLSignOffUserIdInfra
			,AutoClassifiedByInfra
			,IsDDAutoClassifiedInfra
			,IsDDAutoClassifiedDateInfra
			,IsDDAutoClassifiedByInfra
		)
		VALUES(@ProjectID,@ESAProjectID,@DebtEnablementDate,0,@UserID,GETDATE(),NULL,NULL,NULL,NULL,@IsTicketApprovalStatus
			,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y',ISNULL(NULLIF(@ManualDate, ''), null)
			,null,null,null,null,null,null,null,null,null,null,null,null,null)
		
		--	INSERT INTO AVL.MAS_ProjectDebtDetails VALUES (@ProjectID,@ESAProjectID,@DebtEnablementDate,0,@UserID,GETDATE(),NULL,NULL,NULL,NULL,@IsTicketApprovalStatus,NULL,
		--	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Y',ISNULL(NULLIF(@ManualDate, ''), null),null,null,null,null)
			--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @ProjectID AND IsDeleted = 0
		END
	END
	ELSE
	BEGIN
	print'manual3'
		--UPDATE AVL.MAS_ProjectDebtDetails SET IsManual = 'N',ManualDate = NULL ,IsTicketApprovalNeeded=@IsTicketApprovalStatus,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID AND IsDeleted = 0

		--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'N' WHERE ProjectID = @ProjectID AND IsDeleted = 0
	END
	IF @IsML = 'on' 
	BEGIN
		IF EXISTS (SELECT ProjectID FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted=0)
		BEGIN
		print 'ML1'
			UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassified = 'Y', AutoClassifiedBy = @UserID, 
			AutoClassificationDate = ISNULL(NULLIF(@MLDate, ''), null),ModifiedBy=@UserID,ModifiedDate=GETDATE()  WHERE ProjectID = @ProjectID  

			--IF((SELECT DebtEnablementDate FROM AVL.MAS_ProjectDebtDetails WHERE ProjectID = @ProjectID AND IsDeleted=0) IS NULL)
			--BEGIN
			--	UPDATE AVL.MAS_ProjectDebtDetails SET DebtEnablementDate = @DebtEnablementDate,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID AND IsDeleted=0 
			--END
		END
		ELSE
		BEGIN
		print 'ML2'
		  INSERT INTO AVL.MAS_ProjectDebtDetails
		(
			ProjectID
			,EsaProjectID
			,DebtEnablementDate
			,IsDeleted
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,DebtControlDate
			,DebtControlFlag
			,IsTicketApprovalNeeded
			,EnablementSuperAdminId
			,ControlSuperAdminId
			,IsAutoClassified
			,AutoClassificationDate
			,IsMLSignOff
			,MLSignOffDate
			,MLSignOffUserId
			,AutoClassifiedBy
			,IsDDAutoClassified
			,IsDDAutoClassifiedDate
			,IsDDAutoClassifiedBy
			,IsCostTracked
			,DebtControlMethod
			,ISCLSIGNOFF
			,CLSIGNOFFDATE
			,CLSIGNOFFUSERID
			,IsManual
			,ManualDate
			,IsCLAutoClassified
			,CLAutoClassifiedDate
			,CLAutoClassifiedBy
			,OptionalAttributeType
			,IsAutoClassifiedInfra
			,AutoClassificationDateInfra
			,IsMLSignOffInfra
			,MLSignOffDateInfra
			,MLSignOffUserIdInfra
			,AutoClassifiedByInfra
			,IsDDAutoClassifiedInfra
			,IsDDAutoClassifiedDateInfra
			,IsDDAutoClassifiedByInfra
		)
		VALUES(
			@ProjectID
			,@ESAProjectID
			,@DebtEnablementDate
			,0
			,@UserID
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			)
		
			--INSERT INTO AVL.MAS_ProjectDebtDetails VALUES (@ProjectID,@ESAProjectID,@DebtEnablementDate,0,@UserID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,
			--NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,null,null,null)

			UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassified = 'Y', AutoClassifiedBy = @UserID,AutoClassificationDate=ISNULL(NULLIF(@MLDate, ''), null) WHERE ProjectID = @ProjectID 
			--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @ProjectID AND IsDeleted = 0
		END
	END
	ELSE
	BEGIN
		--UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassified = 'N',AutoClassifiedBy = NULL,AutoClassificationDate=NULL,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID 
		UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassified = 'N',AutoClassifiedBy = NULL,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID 
	END
	IF @IsMLinfra = 'on' 
	BEGIN
	    IF EXISTS (SELECT ProjectID FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted=0)
	    BEGIN
	    print 'ML1'
	    	UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassifiedInfra = 'Y', AutoClassifiedBy = @UserID, 
	    	AutoClassificationDateInfra = GETDATE(),ModifiedBy=@UserID,ModifiedDate=GETDATE()  WHERE ProjectID = @ProjectID  

     		--IF((SELECT DebtEnablementDate FROM AVL.MAS_ProjectDebtDetails WHERE ProjectID = @ProjectID AND IsDeleted=0) IS NULL)
			--BEGIN
			--	UPDATE AVL.MAS_ProjectDebtDetails SET DebtEnablementDate = @DebtEnablementDate,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID AND IsDeleted=0 
			--END
		  END
		ELSE
		BEGIN
		print 'ML2'
		INSERT INTO AVL.MAS_ProjectDebtDetails
		(
		     ProjectID
			,EsaProjectID
			,DebtEnablementDate
			,IsDeleted
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,DebtControlDate
			,DebtControlFlag
			,IsTicketApprovalNeeded
			,EnablementSuperAdminId
			,ControlSuperAdminId
			,IsAutoClassified
			,AutoClassificationDate
			,IsMLSignOff
			,MLSignOffDate
			,MLSignOffUserId
			,AutoClassifiedBy
			,IsDDAutoClassified
			,IsDDAutoClassifiedDate
			,IsDDAutoClassifiedBy
			,IsCostTracked
			,DebtControlMethod
			,ISCLSIGNOFF
			,CLSIGNOFFDATE
			,CLSIGNOFFUSERID
			,IsManual
			,ManualDate
			,IsCLAutoClassified
			,CLAutoClassifiedDate
			,CLAutoClassifiedBy
			,OptionalAttributeType
			,IsAutoClassifiedInfra
			,AutoClassificationDateInfra
			,IsMLSignOffInfra
			,MLSignOffDateInfra
			,MLSignOffUserIdInfra
			,AutoClassifiedByInfra
			,IsDDAutoClassifiedInfra
			,IsDDAutoClassifiedDateInfra
			,IsDDAutoClassifiedByInfra
		)
		VALUES
		(
			@ProjectID
			,@ESAProjectID
			,@DebtEnablementDate
			,0
			,@UserID
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			)
			--INSERT INTO AVL.MAS_ProjectDebtDetails
			-- VALUES (@ProjectID,@ESAProjectID,@DebtEnablementDate,0,@UserID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,
			--NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,null,null,null)

		      UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassifiedInfra = 'Y', AutoClassifiedBy = @UserID,AutoClassificationDateInfra=GETDATE() WHERE ProjectID = @ProjectID 
			--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @ProjectID AND IsDeleted = 0
		END
	END
	ELSE
	BEGIN
    	--UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassified = 'N',AutoClassifiedBy = NULL,AutoClassificationDate=NULL,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID 
		  UPDATE AVL.MAS_ProjectDebtDetails SET IsAutoClassifiedInfra = 'N',AutoClassifiedBy = NULL,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID 
	END
	--IF(@DebtReview = 'on')
	--BEGIN
		IF EXISTS (SELECT ProjectID FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted=0)
		BEGIN
			UPDATE AVL.MAS_ProjectDebtDetails SET IsTicketApprovalNeeded = @IsTicketApprovalStatus,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID 
		END
		ELSE
		BEGIN
		INSERT INTO AVL.MAS_ProjectDebtDetails
		(
		     ProjectID
			,EsaProjectID
			,DebtEnablementDate
			,IsDeleted
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,DebtControlDate
			,DebtControlFlag
			,IsTicketApprovalNeeded
			,EnablementSuperAdminId
			,ControlSuperAdminId
			,IsAutoClassified
			,AutoClassificationDate
			,IsMLSignOff
			,MLSignOffDate
			,MLSignOffUserId
			,AutoClassifiedBy
			,IsDDAutoClassified
			,IsDDAutoClassifiedDate
			,IsDDAutoClassifiedBy
			,IsCostTracked
			,DebtControlMethod
			,ISCLSIGNOFF
			,CLSIGNOFFDATE
			,CLSIGNOFFUSERID
			,IsManual
			,ManualDate
			,IsCLAutoClassified
			,CLAutoClassifiedDate
			,CLAutoClassifiedBy
			,OptionalAttributeType
			,IsAutoClassifiedInfra
			,AutoClassificationDateInfra
			,IsMLSignOffInfra
			,MLSignOffDateInfra
			,MLSignOffUserIdInfra
			,AutoClassifiedByInfra
			,IsDDAutoClassifiedInfra
			,IsDDAutoClassifiedDateInfra
			,IsDDAutoClassifiedByInfra
		)
	      VALUES
	       (
			@ProjectID
			,@ESAProjectID
			,@DebtEnablementDate
			,0
			,@UserID
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			)
		
		--	INSERT INTO AVL.MAS_ProjectDebtDetails VALUES (@ProjectID,@ESAProjectID,@DebtEnablementDate,0,@UserID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,
		--	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null)
			UPDATE AVL.MAS_ProjectDebtDetails SET IsTicketApprovalNeeded = @IsTicketApprovalStatus,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID
		END
		--END
	--ELSE
	--BEGIN
	--	UPDATE AVL.MAS_ProjectDebtDetails SET IsTicketApprovalNeeded = 'N' WHERE ProjectID = @ProjectID
	--END
	IF @IsDD = 'on'
	BEGIN
		IF EXISTS (SELECT ProjectID FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID = @ProjectID AND IsDeleted=0)
		BEGIN
		print 'DD1'
			UPDATE AVL.MAS_ProjectDebtDetails SET IsDDAutoClassified = 'Y' ,  IsDDAutoClassifiedBy = @UserID, IsDDAutoClassifiedDate=ISNULL(NULLIF(@DDDate, ''), null)
			,ModifiedBy=@UserID,ModifiedDate=GETDATE()
			 WHERE ProjectID = @ProjectID
			--IF((SELECT DebtEnablementDate FROM AVL.MAS_ProjectDebtDetails WHERE ProjectID = @ProjectID AND IsDeleted=0) IS NULL)
			--BEGIN
			--	UPDATE AVL.MAS_ProjectDebtDetails SET DebtEnablementDate = @DebtEnablementDate,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID AND IsDeleted=0 
			--END
			--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @ProjectID AND IsDeleted = 0
			
		END
		ELSE
		BEGIN
		print 'DD2'
		INSERT INTO AVL.MAS_ProjectDebtDetails
		(
		     ProjectID
			,EsaProjectID
			,DebtEnablementDate
			,IsDeleted
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,DebtControlDate
			,DebtControlFlag
			,IsTicketApprovalNeeded
			,EnablementSuperAdminId
			,ControlSuperAdminId
			,IsAutoClassified
			,AutoClassificationDate
			,IsMLSignOff
			,MLSignOffDate
			,MLSignOffUserId
			,AutoClassifiedBy
			,IsDDAutoClassified
			,IsDDAutoClassifiedDate
			,IsDDAutoClassifiedBy
			,IsCostTracked
			,DebtControlMethod
			,ISCLSIGNOFF
			,CLSIGNOFFDATE
			,CLSIGNOFFUSERID
			,IsManual
			,ManualDate
			,IsCLAutoClassified
			,CLAutoClassifiedDate
			,CLAutoClassifiedBy
			,OptionalAttributeType
			,IsAutoClassifiedInfra
			,AutoClassificationDateInfra
			,IsMLSignOffInfra
			,MLSignOffDateInfra
			,MLSignOffUserIdInfra
			,AutoClassifiedByInfra
			,IsDDAutoClassifiedInfra
			,IsDDAutoClassifiedDateInfra
			,IsDDAutoClassifiedByInfra
		)
		VALUES
		(
			@ProjectID
			,@ESAProjectID
			,@DebtEnablementDate
			,0
			,@UserID
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			)
		
			--INSERT INTO AVL.MAS_ProjectDebtDetails VALUES (@ProjectID,@ESAProjectID,@DebtEnablementDate,0,@UserID,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,
			--NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,null,null)
			UPDATE AVL.MAS_ProjectDebtDetails SET IsDDAutoClassified = 'Y' ,  IsDDAutoClassifiedBy = @UserID,IsDDAutoClassifiedDate=ISNULL(NULLIF(@DDDate, ''), null) WHERE ProjectID = @ProjectID
			--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @ProjectID AND IsDeleted = 0
		
		END
	END
	ELSE
	BEGIN
		UPDATE AVL.MAS_ProjectDebtDetails SET IsDDAutoClassified = 'N' , IsDDAutoClassifiedBy = NULL,ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID
		--UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'N' WHERE ProjectID = @ProjectID AND IsDeleted = 0
	END
	IF @IsMLPatternNoNeed = 'Y'
	BEGIN
		UPDATE AVL.MAS_ProjectDebtDetails SET OptionalAttributeType = NULL WHERE ProjectID=@ProjectID AND IsDeleted=0
	END
	--IF @IsCL='on'
	-- BEGIN
	--  UPDATE AVL.MAS_ProjectDebtDetails SET IsCLAutoClassified='Y',CLAutoClassifiedDate=GETDATE(),CLAutoClassifiedBy=@UserID  WHERE ProjectID=@ProjectID AND IsDeleted=0
	-- END
 --   ELSE
	-- BEGIN
	-- 	  UPDATE AVL.MAS_ProjectDebtDetails SET IsCLAutoClassified='N',CLAutoClassifiedDate=NULL,CLAutoClassifiedBy=NULL WHERE ProjectID=@ProjectID AND IsDeleted=0
	-- END

	DECLARE @PreviousRateID INT,
	@PreviousDayDate DATETIME,
	@PreviousRate NUMERIC (10,2);

	IF  ((@SupportTypeId = 3)
	    OR (@SupportTypeId = 1 AND EXISTS(SELECT TOP 1 BlendedRate FROM AVL.Debt_BlendedRateCardDetails(NOLOCK) WHERE projectid = @ProjectID AND IsApporInfra =1)) 
		OR (@SupportTypeId = 2 AND EXISTS(SELECT TOP 1 BlendedRate FROM AVL.Debt_BlendedRateCardDetails(NOLOCK) WHERE projectid = @ProjectID AND IsApporInfra =2)))
	BEGIN
		DECLARE @SupportLoop int = CASE WHEN @SupportTypeId = 1  
									THEN 1
									WHEN  @SupportTypeId =2
									THEN 2
									ELSE 1 END
		WHILE(@SupportLoop <= @SupportTypeId AND @SupportLoop != 3)
		BEGIN

IF EXISTS(SELECT TOP 1 BlendedRate FROM AVL.Debt_BlendedRateCardDetails(NOLOCK) WHERE projectid = @ProjectID AND  IsApporInfra = @SupportLoop)
		BEGIN
					SELECT @PreviousRateID = MAX(BlendedRateID) FROM  AVL.Debt_BlendedRateCardDetails(NOLOCK) WHERE ProjectId = @ProjectID AND IsApporInfra = @SupportLoop
			
					SELECT @PreviousRate =  BlendedRate FROM AVL.Debt_BlendedRateCardDetails(NOLOCK) WHERE BlendedRateID = @PreviousRateID	AND IsApporInfra = @SupportLoop	
					IF((@SupportLoop = 1 AND  @Hour = @PreviousRate) OR (@SupportLoop = 2 AND  @InfraBlendedRate = @PreviousRate))
					BEGIN
						UPDATE AVL.Debt_BlendedRateCardDetails SET 
						BlendedRate = CASE WHEN @SupportLoop = 1 THEN @Hour ELSE @InfraBlendedRate END WHERE BlendedRateID = @PreviousRateID AND IsApporInfra = @SupportLoop
					END
					ELSE
					BEGIN
						SELECT @PreviousDayDate = DATEADD(MINUTE,-1,GETDATE())
						UPDATE AVL.Debt_BlendedRateCardDetails SET EffectiveToDate = @PreviousDayDate WHERE BlendedRateID = @PreviousRateID AND IsApporInfra = @SupportLoop
						INSERT INTO AVL.Debt_BlendedRateCardDetails
						(		
						ProjectId,
						EffectiveFromDate,
						EffectiveToDate,
						BlendedRate,
						IsDeleted,
						CreatedBy,
						CreatedDate,
						IsApporInfra
						)					
						VALUES 
						(@ProjectID
						,GETDATE()
						,NULL
						,CASE WHEN @SupportLoop = 1 THEN @Hour ELSE @InfraBlendedRate END
						,0
						,@UserID
						,GETDATE()
						,@SupportLoop)
					END
			END
			ELSE
			BEGIN
				INSERT INTO AVL.Debt_BlendedRateCardDetails(ProjectId,EffectiveFromDate,EffectiveToDate,BlendedRate,IsDeleted,
													CreatedBy,CreatedDate,IsApporInfra)			
						VALUES(@ProjectID,GETDATE(),NULL, CASE WHEN @SupportLoop = 1 THEN @Hour ELSE @InfraBlendedRate END,0,@UserID,GETDATE(),@SupportLoop)
			END
			SET @SupportLoop = @SupportLoop+1			
		END		
	END
	ELSE 
	BEGIN
		IF(@SupportTypeId = 1 OR @SupportTypeId = 2)
		BEGIN
			INSERT INTO AVL.Debt_BlendedRateCardDetails(ProjectId,EffectiveFromDate,EffectiveToDate,BlendedRate,IsDeleted,
														CreatedBy,CreatedDate,IsApporInfra)			
							VALUES(@ProjectID,GETDATE(),NULL,CASE WHEN @SupportTypeId = 1 THEN @Hour ELSE @InfraBlendedRate END
									,0,@UserID,GETDATE(),@SupportTypeId)
				 END
	END
	IF(@IsCostTracked = '1')
	BEGIN
		UPDATE AVL.MAS_ProjectDebtDetails SET IsCostTracked = 'Y',ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID
	END
	ELSE
	BEGIN
		UPDATE AVL.MAS_ProjectDebtDetails SET IsCostTracked = 'N',ModifiedBy=@UserID,ModifiedDate=GETDATE() WHERE ProjectID = @ProjectID
	END

	DECLARE @TotalValue INT = 0
	PRINT @IsML
	IF((@IsML != NULL) OR (@IsML != '') OR @IsDD <> NULL OR @IsDD <> '' OR @IsManual <> NULL OR @IsManual <> '')
	BEGIN
	print '1'
		SET @TotalValue = @TotalValue + 1
	END
	IF(@IsCostTracked <> NULL OR @IsCostTracked <> '')
	BEGIN
	print 'Cost'
		SET @TotalValue = @TotalValue + 1
	END
	IF (@Hour IS NOT NULL OR @InfraBlendedRate IS NOT NULL)
	BEGIN
		SET @TotalValue = @TotalValue + 1
	END
	IF(@DebtEnablementDate <> NULL OR @DebtEnablementDate <> '')
	BEGIN
		SET @TotalValue = @TotalValue + 1
	END
	--IF(@DebtReview <> NULL OR @DebtReview <> '')
	--BEGIN
	--SET @TotalValue = @TotalValue + 1
	--END	
	PRINT @TotalValue

	DECLARE @Percentage BIGINT

	SET @Percentage = (@TotalValue*50)/4
	print @Percentage

	IF EXISTS (SELECT Id,CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,
	CreatedDate,ModifiedBy,ModifiedDate FROM AVL.PRJ_ConfigurationProgress(NOLOCK) WHERE ProjectID = @ProjectID AND ScreenID = 5 AND ISdeleted = 0)
	BEGIN
		select @CompletionPercentage = CompletionPercentage FROM AVL.PRJ_ConfigurationProgress(NOLOCK) WHERE ProjectID = @ProjectID AND ScreenID = 5 AND ISdeleted = 0
		IF(@CompletionPercentage <> 100)
		BEGIN
			UPDATE AVL.PRJ_ConfigurationProgress SET CompletionPercentage = @Percentage,ModifiedBy = @UserID , ModifiedDate = GETDATE()
			WHERE projectID = @ProjectID AND ScreenID = 5 AND ISdeleted = 0
		END
	END
	ELSE
	BEGIN
		INSERT INTO AVL.PRJ_ConfigurationProgress VALUES(@CustomerID,@ProjectID,5,NULL,@Percentage,0,@UserID,GETDATE(),NULL,NULL,NULL,NULL)
	END

	IF NOT EXISTS(SELECT TicketTypeMappingID,TicketType,AVMTicketType,ProjectID,DebtConsidered,IsDeleted,
	CreatedDateTime,CreatedBY,ModifiedDateTime,ModifiedBY,IsDefaultTicketType,TicketTypeName FROM AVL.TK_MAP_TicketTypeMapping WHERE ProjectID = @ProjectID AND AVMTicketType IN (9,10) AND IsDeleted = 0)
	BEGIN
		INSERT INTO AVL.TK_MAP_TicketTypeMapping 
		(	TicketType,
			AVMTicketType,
			ProjectID,
			DebtConsidered,
			IsDeleted,
			CreatedDateTime,
			CreatedBY,
			ModifiedDateTime,
			ModifiedBY,
			IsDefaultTicketType,
			TicketTypeName)
		VALUES('A',9,@ProjectID,'Y',0,GETDATE(),@UserID,NULL,NULL,NULL,NULL)



		INSERT INTO AVL.TK_MAP_TicketTypeMapping
		(	TicketType,
			AVMTicketType,
			ProjectID,
			DebtConsidered,
			IsDeleted,
			CreatedDateTime,
			CreatedBY,
			ModifiedDateTime,
			ModifiedBY,
			IsDefaultTicketType,
			TicketTypeName)
		 VALUES('H',10,@ProjectID,'Y',0,GETDATE(),@UserID,NULL,NULL,NULL,NULL)

		INSERT INTO AVL.TK_MAP_TicketTypeMapping
		(	TicketType,
			AVMTicketType,
			ProjectID,
			DebtConsidered,
			IsDeleted,
			CreatedDateTime,
			CreatedBY,
			ModifiedDateTime,
			ModifiedBY,
			IsDefaultTicketType,
			TicketTypeName)
		 VALUES('K',20,@ProjectID,'Y',0,GETDATE(),@UserID,NULL,NULL,NULL,NULL)
	END

	--DECLARE @Iscognizant INT

	--SET @Iscognizant = (SELECT IsCognizant FROM AVL.Customer WHERE CustomerID = @CustomerID AND IsDeleted = 0)

	--IF(@Iscognizant = '1')
	--BEGIN
	--	EXEC AVL.DebtManualInsert @ProjectID
	--END
	COMMIT TRAN
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);
	
		SELECT @ErrorMessage = ERROR_MESSAGE()
			PRINT @ErrorMessage
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Debt_SaveIdentificationDetails] ', @ErrorMessage, 0,@CustomerID
		
	END CATCH  

END
