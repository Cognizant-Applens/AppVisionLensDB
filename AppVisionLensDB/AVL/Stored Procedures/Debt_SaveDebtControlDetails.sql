/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Ram kumar>
-- Modified date: <09/23/2019>
-- Description:	[AVL].[Debt_SaveDebtControlDetails]
-- =============================================
--EXEC [AVL].[Debt_SaveDebtControlDetails] 'M','2018-08-01','0','','11','22','33','116','445713','113'

CREATE PROCEDURE [AVL].[Debt_SaveDebtControlDetails]		 
(
@DebtControlMethod NVARCHAR(50),
@DebtControldate VARCHAR(50),
@ThresholdCount NVARCHAR(50),
@DDThresholdCount INT,
@Columnselected NVARCHAR(50),
@SimpleCount DECIMAL(25,2),
@MediumCount DECIMAL(25,2),
@ComplexCount DECIMAL(25,2),
@ProjectID NVARCHAR(50),
@EmployeeID NVARCHAR(50),
@CustomerID NVARCHAR(50),
@OptionalAttributeType INT,
@GracePeriod SMALLINT,
@SimpleCountInfra DECIMAL(25,2),
@MediumCountInfra DECIMAL(25,2),
@ComplexCountInfra DECIMAL(25,2),
@SupportTypeId INT,
@IsRequireHistoricIncidents NVARCHAR(2),
@AHEffectiveDate NVARCHAR(50)
)

AS
BEGIN
BEGIN TRY
BEGIN TRAN

IF(@OptionalAttributeType = 0)
BEGIN
SET @OptionalAttributeType = NULL
END 
update AVL.MAS_ProjectDebtDetails 
SET DebtControlDate=@DebtControldate,DDThresholdCount= @DDThresholdCount,GracePeriod=@GracePeriod,DebtControlMethod=ISNULL(@DebtControlMethod,DebtControlMethod), OptionalAttributeType = @OptionalAttributeType,
IncidentHistoricDate = case @IsRequireHistoricIncidents when 1 then @AHEffectiveDate else NULL END,
IsRequireHistoricIncidents = case @IsRequireHistoricIncidents when '1' then 1 else 0 end
WHERE ProjectId=@ProjectID and IsDeleted=0

IF EXISTS(SELECT 1 FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted = 0 AND DebtControlFlag IS NULL )
BEGIN
	UPDATE AVL.MAS_ProjectDebtDetails SET DebtControlFlag = 'Y' WHERE ProjectID=@ProjectID AND IsDeleted = 0 AND DebtControlFlag IS NULL OR DebtControlFlag = ''
END


IF NOT EXISTS(SELECT 1 FROM AVL.DEBT_MAS_HealProjectThresholdMaster (NOLOCK)  WHERE ProjectID=@ProjectID AND IsDeleted=0)
BEGIN
	INSERT INTO AVL.DEBT_MAS_HealProjectThresholdMaster(ProjectID,ThresholdCount,IsDeleted,CreatedBy,CreatedDate)
	VALUES(@ProjectID,@ThresholdCount,0,@EmployeeID,GETDATE())
END
ELSE
BEGIN
	update AVL.DEBT_MAS_HealProjectThresholdMaster 
	set ThresholdCount =@ThresholdCount,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE()
	where ProjectId=@ProjectID
END

CREATE TABLE #Temp (ColumnID INT )
INSERT INTO #Temp
SELECT * FROM Split(@Columnselected, ',')

--select ColumnID,ColumnName  into #Temp from AVL.DEBT_MAS_HealColumnMaster 
--where ColumnID in (7,8,9) 


INSERT INTO AVL.DEBT_PRJ_HealProjectPatternColumnMapping 
	(ProjectID,ColumnID,IsActive,CreatedBy,CreatedDate)
	(SELECT @ProjectID,ColumnID,1,@EmployeeID, GETDATE() FROM #Temp
	WHERE ColumnID NOT IN(SELECT ColumnID FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK)
	WHERE ProjectID=@ProjectID AND IsActive=1))
	
	
	UPDATE AVL.DEBT_PRJ_HealProjectPatternColumnMapping  
	SET IsActive=0 WHERE ColumnID NOT IN(SELECT ColumnID FROM #Temp)
	AND ProjectID=@ProjectID


		IF (EXISTS(SELECT TOP 1 HealValue FROM AVL.Heal_EffortConfigureState(NOLOCK) WHERE IsDeleted = 0 AND ProjectID=@ProjectID) OR
              @SupportTypeId = 3)
        BEGIN
			Declare @SupportTypeLoop int;
			SET @SupportTypeLoop = CASE WHEN @SupportTypeId = 1
															THEN 1
															WHEN @SupportTypeId = 2
															THEN 2
															WHEN @SupportTypeId = 3
															THEN 1 
															ELSE 0 END
			WHILE(@SupportTypeLoop <= @SupportTypeId AND @SupportTypeLoop !=3)
			BEGIN
				IF EXISTS(SELECT TOP 1 HealValue FROM AVL.Heal_EffortConfigureState(NOLOCK) WHERE IsDeleted = 0 AND ProjectID=@ProjectID AND IsAppOrInfra = @SupportTypeLoop)
					BEGIN
					UPDATE AVL.Heal_EffortConfigureState SET HealValue = CASE WHEN @SupportTypeLoop =1 THEN  
						@SimpleCount ELSE @SimpleCountInfra END, ModifiedBY = @EmployeeID, LastModifiedDate = GETDATE() 
						WHERE ProjectID=@ProjectID AND HealType = 'Simple' AND IsAppOrInfra = @SupportTypeLoop AND IsDeleted = 0
					UPDATE AVL.Heal_EffortConfigureState SET HealValue = CASE WHEN @SupportTypeLoop =1 THEN  
						@MediumCount ELSE @MediumCountInfra END, ModifiedBY = @EmployeeID, LastModifiedDate = GETDATE() 
						 WHERE ProjectID=@ProjectID AND HealType = 'Medium' AND IsAppOrInfra = @SupportTypeLoop AND IsDeleted = 0
					UPDATE AVL.Heal_EffortConfigureState SET HealValue = CASE WHEN @SupportTypeLoop =1 THEN  
						@ComplexCount ELSE @ComplexCountInfra END, ModifiedBY = @EmployeeID, LastModifiedDate = GETDATE()  
						 WHERE ProjectID=@ProjectID AND HealType ='Complex' AND IsAppOrInfra = @SupportTypeLoop AND IsDeleted = 0
					END
				ELSE
				BEGIN
					INSERT INTO AVL.Heal_EffortConfigureState 
					(HealType,HealValue,HealMasterId,IsDeleted,ProjectID, CreatedBY, CreateDateTime, IsAppOrInfra)
					VALUES('Simple', CASE WHEN @SupportTypeLoop =1 THEN  @SimpleCount ELSE @SimpleCountInfra END,1,0, @projectid,@EmployeeID, GETDATE(),@SupportTypeLoop)   
                          
					INSERT INTO AVL.Heal_EffortConfigureState 
					(HealType,HealValue,HealMasterId,IsDeleted, ProjectID, CreatedBY,  CreateDateTime, IsAppOrInfra)
					VALUES('Medium',CASE WHEN @SupportTypeLoop =1 THEN  @MediumCount ELSE @MediumCountInfra END,2,0 ,@projectid,@EmployeeID,GETDATE(),@SupportTypeLoop)    

					INSERT INTO AVL.Heal_EffortConfigureState 
					(HealType,HealValue,HealMasterId,IsDeleted,ProjectID, CreatedBY,  CreateDateTime, IsAppOrInfra)
					VALUES('Complex',CASE WHEN @SupportTypeLoop =1 THEN  @ComplexCount ELSE @ComplexCountInfra END,3,0, @projectid,@EmployeeID,GETDATE(),@SupportTypeLoop)
				END
				SET @SupportTypeLoop = @SupportTypeLoop + 1
			END 
       END
       ELSE
       BEGIN
              IF(@SupportTypeId = 1 OR @SupportTypeId =2)
              BEGIN
                     INSERT INTO AVL.Heal_EffortConfigureState 
					 (HealType,HealValue,HealMasterId,IsDeleted,ProjectID, CreatedBY, CreateDateTime, IsAppOrInfra)
                     VALUES('Simple', CASE WHEN @SupportTypeId =1 THEN  @SimpleCount ELSE @SimpleCountInfra END,1,0, @projectid,@EmployeeID, GETDATE(), @SupportTypeId) 
                           
                     INSERT INTO AVL.Heal_EffortConfigureState 
					 (HealType,HealValue,HealMasterId,IsDeleted, ProjectID, CreatedBY,  CreateDateTime, IsAppOrInfra)
                     VALUES('Medium',CASE WHEN @SupportTypeId =1 THEN  @MediumCount ELSE @MediumCountInfra END,2,0 ,@projectid,@EmployeeID,GETDATE(), @SupportTypeId)  

                     INSERT INTO AVL.Heal_EffortConfigureState 
					 (HealType,HealValue,HealMasterId,IsDeleted,ProjectID, CreatedBY,  CreateDateTime, IsAppOrInfra)
                     VALUES('Complex',CASE WHEN @SupportTypeId =1 THEN  @ComplexCount ELSE @ComplexCountInfra END,3,0, @projectid,@EmployeeID,GETDATE(), @SupportTypeId)
              END
       END


-- added newly begin

	DECLARE @TotalValue INT = 0
	DECLARE @IsML VARCHAR(50) = (SELECT IsAutoClassified FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @IsDD VARCHAR(50) = (SELECT IsDDAutoClassified FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @IsManual VARCHAR(50) = (SELECT IsManual FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @MLDate VARCHAR(50) = (SELECT AutoClassificationDate FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @DDDate VARCHAR(50) = (SELECT IsDDAutoClassifiedDate FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @ManualDate VARCHAR(50) = (SELECT DebtEnablementDate FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @DebtEnablementDate VARCHAR(50) = (SELECT DebtEnablementDate FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @IsCostTracked VARCHAR(50) = (SELECT IsCostTracked FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)
	DECLARE @Hour VARCHAR(50) = (SELECT TOP 1 BlendedRate FROM AVL.Debt_BlendedRateCardDetails (NOLOCK) WHERE ProjectID = @projectid
															AND (((@SupportTypeId = 1 OR @SupportTypeId = 3) AND IsAppOrInfra = 1)
                                                            OR ((@SupportTypeId = 2 OR @SupportTypeId = 3) AND IsAppOrInfra = 2)) AND  IsDeleted = 0)
	DECLARE @DebtReview VARCHAR(50) = (SELECT IsTicketApprovalNeeded FROM AVL.MAS_ProjectDebtDetails (NOLOCK) WHERE ProjectID = @projectid AND IsDeleted = 0)


	IF((@IsML != NULL) OR (@IsML != '') OR @IsDD <> NULL OR @IsDD <> '' OR @IsManual <> NULL OR @IsManual <> '')
	BEGIN
	print '1'
		SET @TotalValue = @TotalValue + 1
	END
	IF(@IsCostTracked <> NULL OR @IsCostTracked <> '')
	BEGIN
		SET @TotalValue = @TotalValue + 1
	END
	IF(@Hour IS NOT NULL OR @Hour <> '')
	BEGIN
		SET @TotalValue = @TotalValue + 1
	END
	IF(@DebtReview <> NULL OR @DebtReview <> '')
	BEGIN
	SET @TotalValue = @TotalValue + 1
	END	
	IF(@DebtEnablementDate <> NULL OR @DebtEnablementDate <> '')
	BEGIN
		SET @TotalValue = @TotalValue + 1
	END
	PRINT @TotalValue

	DECLARE @Percentage BIGINT

	SET @Percentage = (@TotalValue*50)/5
	print @Percentage
	-- added newly end
	DECLARE @TotalValue1 INT = 0

	IF(@DebtControlMethod <> NULL OR @DebtControlMethod <> '')
	BEGIN
		SET @TotalValue1 = @TotalValue1 + 1
	END
	--IF(@DebtControldate <> NULL OR @DebtControldate <> '')
	--BEGIN
	--	SET @TotalValue1 = @TotalValue1 + 1
	--END
	IF(@ThresholdCount <> NULL OR @ThresholdCount <> '')
	BEGIN
		SET @TotalValue1 = @TotalValue1 + 1
	END
	--IF(@Columnselected <> NULL OR @Columnselected <> '')
	--BEGIN
	--	SET @TotalValue1 = @TotalValue1 + 1
	--END
	IF(@SimpleCount IS NOT NULL OR @SimpleCountInfra IS NOT NULL)
	BEGIN
		SET @TotalValue1 = @TotalValue1 + 1
	END
	IF(@MediumCount IS NOT NULL OR @MediumCountInfra IS NOT NULL)
	BEGIN
		SET @TotalValue1 = @TotalValue1 + 1
	END
	IF(@ComplexCount IS NOT NULL OR @ComplexCountInfra IS NOT NULL)
	BEGIN
		SET @TotalValue1 = @TotalValue1 + 1
	END
		

	SET @Percentage = @Percentage + (@TotalValue1*50)/5
	print @Percentage

	IF EXISTS (SELECT * FROM AVL.PRJ_ConfigurationProgress WHERE ProjectID = @ProjectID AND ScreenID = 5 AND ISdeleted = 0)
	BEGIN
		UPDATE AVL.PRJ_ConfigurationProgress SET CompletionPercentage = @Percentage,ModifiedBy = @EmployeeID , ModifiedDate = GETDATE()
		 WHERE projectID = @ProjectID AND ScreenID = 5 AND ISdeleted = 0
		select @Percentage = CompletionPercentage FROM AVL.PRJ_ConfigurationProgress(NOLOCK) WHERE ProjectID = @ProjectID AND ScreenID = 5 AND ISdeleted = 0
		IF(@Percentage = 100)
		BEGIN
			UPDATE AVL.MAS_ProjectMaster SET IsDebtEnabled = 'Y' WHERE ProjectID = @ProjectID AND IsDeleted = 0
			UPDATE AVL.MAS_ProjectDebtDetails SET NonDebtThresholdDays=60 WHERE ProjectId=@ProjectID
		END
	END
	ELSE
	BEGIN
		INSERT INTO AVL.PRJ_ConfigurationProgress VALUES(@CustomerID,@ProjectID,5,NULL,@Percentage,0,@EmployeeID,GETDATE(),NULL,NULL,NULL,NULL)
	END

	--EXEC [AVL].[DebtManualInsert] @ProjectID
	COMMIT TRAN
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Debt_SaveDDDebtControlDetails] ', @ErrorMessage, @ProjectID,@CustomerID
		
	END CATCH  

END
