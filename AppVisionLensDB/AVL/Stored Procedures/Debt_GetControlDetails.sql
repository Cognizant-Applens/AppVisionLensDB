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
-- Author:		<Ram Kumar>
-- Modified date: <02/19/2019>
-- Description:	<[AVL].[Debt_GetControlDetails]>
-- =============================================
CREATE PROCEDURE [AVL].[Debt_GetControlDetails]
@CustomerID BIGINT,
@ProjectID BIGINT,
@SuportTypeID INT

AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;  
DECLARE @ModeOfDebtControl NVARCHAR(50)
DECLARE @ManualControlEffectiveDate DATETIME 
DECLARE @IsDebtControl NVARCHAR(50);
DECLARE @IsCognizant NVARCHAR(50);
DECLARE @ThresholdCount INT
DECLARE @DDThresholdCount INT
DECLARE @GracePeriod SMALLINT
DECLARE @SimpleCount DECIMAL(25,2)
DECLARE @MediumCount DECIMAL(25,2)
DECLARE @ComplexCount DECIMAL(25,2)
DECLARE @SimpleCountInfra DECIMAL(25,2)
DECLARE @MediumCountInfra DECIMAL(25,2)
DECLARE @ComplexCountInfra DECIMAL(25,2)
SET @IsCognizant=(SELECT ISNULL(IsCognizant,'0') AS IsCognizant
						 FROM AVL.Customer (NOLOCK) WHERE CustomerID=@CustomerID)
SET @ThresholdCount=(SELECT ISNULL(ThresholdCount,0) AS ThresholdCount FROM AVL.DEBT_MAS_HealProjectThresholdMaster (NOLOCK)
						WHERE ProjectID=@ProjectID AND IsDeleted=0)

					
SET @DDThresholdCount=(SELECT ISNULL(DDThresholdCount,0) AS DDThresholdCount FROM AVL.MAS_ProjectDebtDetails (NOLOCK)
WHERE ProjectID=@ProjectID AND IsDeleted=0)

SET @GracePeriod=(SELECT ISNULL(GracePeriod,7) AS GracePeriod FROM AVL.MAS_ProjectDebtDetails (NOLOCK)
                  WHERE ProjectID=@ProjectID AND IsDeleted=0)

SELECT ISNULL(DebtControlFlag,'N') AS DebtControlFlag,
ISNULL(DebtControlMethod,'') AS DebtControlMethod,DebtControldate,
ISNULL(@ThresholdCount,0) AS ThresholdCount,ISNULL(@DDThresholdCount,0) AS DDThresholdCount,ISNULL(@GracePeriod,7) AS GracePeriod,DebtControlDate
, DebtEnablementDate AS DebtEnablementDate, OptionalAttributeType, 
CASE WHEN @SuportTypeID = 1
	THEN IsMLSignOff
	WHEN @SuportTypeID = 2
	THEN IsMLSignOffInfra
	WHEN @SuportTypeID = 3
	THEN
		CASE WHEN (ISNULL(IsMLSignOff,'0') = '1' AND ISNULL(IsAutoClassified,'N') = 'Y') 
				OR (ISNULL(IsMLSignOffInfra,'0') = '1' AND ISNULL(IsAutoClassifiedInfra,'N') = 'Y')
		THEN '1'
		ELSE '0' END
END AS IsMLSignOff,
CASE WHEN CreatedDate > CONVERT(VARCHAR,'2018-12-31',1) THEN 'Y'
ELSE 'N' END AS IsOnBoardCurrentYear,
CASE WHEN @SuportTypeID = 1
	THEN IsAutoClassified
	WHEN @SuportTypeID = 2
	THEN IsAutoClassifiedInfra
	WHEN @SuportTypeID = 3
	THEN
		CASE WHEN (ISNULL(IsMLSignOff,'0') = '1' AND ISNULL(IsAutoClassified,'N') = 'Y') 
				OR (ISNULL(IsMLSignOffInfra,'0') = '1' AND ISNULL(IsAutoClassifiedInfra,'N') = 'Y')
		THEN 'Y'
		ELSE 'N' END
END AS IsAutoClassified,
IsRequireHistoricIncidents,
IncidentHistoricDate
FROM AVL.MAS_ProjectDebtDetails (NOLOCK) 
WHERE ProjectID=@ProjectID 

CREATE TABLE  #Temp 
(
ColumnID INT,
ColumnName NVARCHAR(100),
IsSelected INT
)
IF @IsCognizant = '1'
	BEGIN

	INSERT INTO #Temp 
		SELECT  HCM.ColumnID,SCM.ProjectColumn, HP.ProjectPatternColumnMapID AS IsSelected FROM AVL.DEBT_MAS_HealColumnMaster (NOLOCK) HCM
		LEFT JOIN AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK) HP ON HCM.ColumnID = HP.ColumnID AND HP.IsActive = 1 AND HP.ProjectID=@ProjectID
		INNER JOIN AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) SCM ON HCM.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '') 
		AND SCM.ProjectID=@ProjectID  and HCM.IsActive=1
		where HCM.COlumnID in (11,12,13,14) AND SCM.IsDeleted = 0
		
		UPDATE #Temp SET IsSelected=1 WHERE IsSelected>0 
		
		SELECT DISTINCT ColumnID,ColumnName,IsSelected FROM #Temp
		
	END
	ELSE
	BEGIN

	INSERT INTO #Temp 
		SELECT  HCM.ColumnID,SCM.ProjectColumn, HP.ProjectPatternColumnMapID AS IsSelected FROM AVL.DEBT_MAS_HealColumnMaster (NOLOCK) HCM
		LEFT JOIN AVL.DEBT_PRJ_HealProjectPatternColumnMapping (NOLOCK) HP ON HCM.ColumnID = HP.ColumnID AND HP.IsActive = 1 AND HP.ProjectID=@ProjectID
		INNER JOIN AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) SCM ON HCM.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '') 
		AND SCM.ProjectID=@ProjectID  and HCM.IsActive=1
		where HCM.COlumnID in (11,12,13,14) AND SCM.IsDeleted = 0
		
		UPDATE #Temp SET IsSelected=1 WHERE IsSelected>0 
		
		SELECT DISTINCT ColumnID,ColumnName,IsSelected FROM #Temp
		
	END
	IF(@SuportTypeID = 3 AND EXISTS (SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID AND IsDeleted = 0 AND IsAppOrInfra = 1)
	AND NOT EXISTS (SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID AND IsDeleted = 0 AND IsAppOrInfra = 2))
	BEGIN
	    SET @SimpleCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 1 AND IsAppOrInfra = 1 AND IsDeleted = 0)	
		SET @MediumCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 2 AND IsAppOrInfra = 1 AND IsDeleted = 0)	 
		SET @ComplexCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 3 AND IsAppOrInfra = 1 AND IsDeleted = 0)	 
		SET @SimpleCountInfra =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 1)
		SET @MediumCountInfra =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 2)
		SET @ComplexCountInfra = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 3)
	END
	ELSE IF(@SuportTypeID = 3 AND EXISTS (SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID AND IsDeleted = 0 AND IsAppOrInfra = 2)
	AND NOT EXISTS (SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID AND IsDeleted = 0 AND IsAppOrInfra = 1))
	BEGIN
	    SET @SimpleCount =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 1)
		SET @MediumCount =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 2)
		SET @ComplexCount = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 3)
	    SET @SimpleCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 1 AND IsAppOrInfra = 2 AND IsDeleted = 0)	
		SET @MediumCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 2 AND IsAppOrInfra = 2 AND IsDeleted = 0)	 
		SET @ComplexCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 3 AND IsAppOrInfra = 2 AND IsDeleted = 0)	 
	END
	ELSE IF(@SuportTypeID = 3 AND EXISTS (SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID AND IsDeleted = 0 AND IsAppOrInfra =1) 
	AND EXISTS(SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID AND IsDeleted = 0 AND IsAppOrInfra =2 ))
	BEGIN
	    SET @SimpleCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 1 AND IsAppOrInfra = 1 AND IsDeleted = 0)	
		SET @MediumCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 2 AND IsAppOrInfra = 1 AND IsDeleted = 0)	 
		SET @ComplexCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 3 AND IsAppOrInfra = 1 AND IsDeleted = 0)	 
	    SET @SimpleCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 1 AND IsAppOrInfra = 2 AND IsDeleted = 0)	
		SET @MediumCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 2 AND IsAppOrInfra = 2 AND IsDeleted = 0)	 
		SET @ComplexCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 3 AND IsAppOrInfra = 2 AND IsDeleted = 0)	 
	END
	ELSE IF (@SuportTypeID = 3 AND NOT EXISTS (SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID))
	BEGIN	
		SET @SimpleCount = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 1)
		SET @MediumCount = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 2)
		SET @ComplexCount = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 3)
		SET @SimpleCountInfra =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 1)
		SET @MediumCountInfra =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 2)
		SET @ComplexCountInfra = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 3)
	END
	ELSE
	BEGIN
	IF NOT EXISTS (SELECT HealTypeId FROM  AVL.Heal_EffortConfigureState (NOLOCK) where ProjectID=@ProjectID)
	BEGIN	
		SET @SimpleCount = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 1)
		SET @MediumCount = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 2)
		SET @ComplexCount = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 3)
		SET @SimpleCountInfra =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 1)
		SET @MediumCountInfra =(SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 2)
		SET @ComplexCountInfra = (SELECT HealTypeNumber FROM AVL.HealTypeMaster (NOLOCK) WHERE  ID = 3)
	END
	ELSE
	BEGIN
	 SET @SimpleCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 1 AND IsAppOrInfra = 1 AND IsDeleted = 0)	
		SET @MediumCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 2 AND IsAppOrInfra = 1 AND IsDeleted = 0)	 
		SET @ComplexCount=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 3 AND IsAppOrInfra = 1 AND IsDeleted = 0)	 
	    SET @SimpleCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 1 AND IsAppOrInfra = 2 AND IsDeleted = 0)	
		SET @MediumCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 2 AND IsAppOrInfra = 2 AND IsDeleted = 0)	 
		SET @ComplexCountInfra=(SELECT HealValue FROM AVL.Heal_EffortConfigureState (NOLOCK) 
			WHERE ProjectID=@ProjectID AND HealMasterId = 3 AND IsAppOrInfra = 2 AND IsDeleted = 0)	 
		
	END
	END

	SELECT @SimpleCount AS SimpleCount,@MediumCount AS MediumCount,@ComplexCount AS ComplexCount,
		   @SimpleCountInfra AS SimpleCountInfra,@MediumCountInfra AS MediumCountInfra,@ComplexCountInfra AS ComplexCountInfra

	SELECT IsDebtEnabled FROM AVL.MAS_ProjectMaster (NOLOCK)  WHERE ProjectID = @ProjectID

	
SET NOCOUNT OFF; 
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Debt_GetControlDetails]', @ErrorMessage, @ProjectID,@CustomerID
		
	END CATCH  

     
END
