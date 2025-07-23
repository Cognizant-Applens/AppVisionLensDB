CREATE FUNCTION [PP].[GetALMConfigurationPercentage](@ProjectId BIGINT, @IsApplensAsALM BIT)
RETURNS INT
AS 
BEGIN
	
	DECLARE @ALMConfigPercentage INT = 0

	IF (@IsApplensAsALM = 0) -- If ALM selected as External Tool
	BEGIN

		DECLARE @CheckIncludePriority INT = 0
		DECLARE @CheckIncludeSeverity INT = 0
		DECLARE @SplitPercentValue DECIMAL(18, 2)
	
		IF EXISTS (SELECT 1 FROM PP.ALM_MAP_ColumnName 
					INNER JOIN [PP].[ALM_MAS_ColumnName] 
						ON [PP].[ALM_MAS_ColumnName].ALMColID = PP.ALM_MAP_ColumnName.ALMColID
					WHERE ProjectId = @ProjectID AND ALMColumnName = 'Priority' 
						AND PP.ALM_MAP_ColumnName.IsDeleted = 0)
		BEGIN

			SET @CheckIncludePriority = 1

		END

		IF EXISTS (SELECT 1 FROM PP.ALM_MAP_ColumnName 
			        INNER JOIN [PP].[ALM_MAS_ColumnName] 
						ON [PP].[ALM_MAS_ColumnName].ALMColID = PP.ALM_MAP_ColumnName.ALMColID
					WHERE ProjectId = @ProjectID AND ALMColumnName = 'Severity' 
						AND PP.ALM_MAP_ColumnName.IsDeleted = 0)
		BEGIN

			SET @CheckIncludeSeverity = 1

		END

		IF (@CheckIncludePriority = 1 AND @CheckIncludeSeverity = 1)  
		BEGIN

			SET @SplitPercentValue = CAST(CAST(100 AS DECIMAL(18, 2)) / CAST(5 AS DECIMAL(18, 2)) AS DECIMAL(18, 2))

		END
		ELSE IF((@CheckIncludePriority = 1 AND @CheckIncludeSeverity = 0) OR (@CheckIncludePriority = 0 AND @CheckIncludeSeverity = 1))   
		BEGIN	
				
			SET @SplitPercentValue = CAST(CAST(100 AS DECIMAL(18, 2)) / CAST(4 AS DECIMAL(18, 2)) AS DECIMAL(18, 2))

		END
		ELSE IF(@CheckIncludePriority = 0 AND @CheckIncludeSeverity = 0)  
		BEGIN

			SET @SplitPercentValue = CAST(CAST(100 AS DECIMAL(18, 2)) / CAST(3 AS DECIMAL(18, 2)) AS DECIMAL(18, 2))

		END

		IF EXISTS (SELECT 1 FROM PP.ALM_MAP_ColumnName WHERE ProjectId = @ProjectID AND IsDeleted = 0)
		BEGIN
			
			SET @ALMConfigPercentage += @SplitPercentValue
			
		END
		IF EXISTS (SELECT  1 FROM PP.ALM_MAP_WorkType WHERE ProjectId = @ProjectID AND IsDeleted = 0)
		BEGIN
		
			SET @ALMConfigPercentage += @SplitPercentValue
		
		END
		IF EXISTS (SELECT 1 FROM PP.ALM_MAP_Priority WHERE ProjectId = @ProjectID AND IsDeleted = 0 AND @CheckIncludePriority = 1)
		BEGIN

			SET @ALMConfigPercentage += @SplitPercentValue

		END
		IF EXISTS (SELECT  1 FROM PP.ALM_MAP_Severity WHERE ProjectId = @ProjectID AND IsDeleted = 0 AND @CheckIncludeSeverity = 1)
		BEGIN

			SET @ALMConfigPercentage += @SplitPercentValue

		END
		IF EXISTS (SELECT 1 FROM PP.ALM_MAP_Status WHERE ProjectId = @ProjectID AND IsDeleted = 0)
		BEGIN

			SET @ALMConfigPercentage += @SplitPercentValue

		END

		SET @ALMConfigPercentage = CASE WHEN ROUND(@ALMConfigPercentage, 0) = 99 THEN 100 ELSE ROUND(@ALMConfigPercentage, 0) END

	END
	ELSE
	BEGIN -- If Applens as ALM

		DECLARE @ExectionList TABLE  
		(     
			ExecutionID BIGINT  
		) 

		DECLARE @ExectionListWithEffortTracking TABLE  
		(     
			ExecutionID BIGINT  
		) 

		DECLARE @ExectionListWithEstimationPoint TABLE  
		(     
			ExecutionID BIGINT  
		)

		INSERT INTO @ExectionList(ExecutionID)  

		SELECT DISTINCT PPAV.AttributeValueID  
		FROM PP.ProjectAttributeValues PAV   
		JOIN MAS.PPAttributeValues PPAV 
			ON PAV.AttributeID = PPAV.AttributeID AND  PAV.AttributeValueID = PPAV.AttributeValueID  
		WHERE PAV.ProjectID = @ProjectID AND PAV.AttributeID = 3 AND PAV.IsDeleted = 0 
			AND PPAV.IsDeleted = 0

		INSERT INTO @ExectionListWithEffortTracking(ExecutionID)
			SELECT ExecutionID 
			FROM [PP].[ALM_MAP_GenericWorkItemConfig] 
			WHERE ProjectID = @ProjectID AND ISNULL(IsEffortTracking, 0) > 0 AND IsDeleted = 0 			

		INSERT INTO @ExectionListWithEstimationPoint(ExecutionID)
			SELECT ExecutionID 
			FROM [PP].[ALM_MAP_GenericWorkItemConfig] 
			WHERE ProjectID = @ProjectID AND ISNULL(IsEstimationPoints,0) > 0  AND IsDeleted = 0

		IF EXISTS (SELECT TOP 1 1 
				   FROM @ExectionList EL 
				   LEFT JOIN @ExectionListWithEffortTracking EFT ON EFT.ExecutionID = EL.ExecutionID
				   WHERE EFT.ExecutionID IS NULL)
		BEGIN

			SET @ALMConfigPercentage = 0 

		END
		ELSE IF EXISTS (SELECT TOP 1 1 
						FROM @ExectionList EL 
						LEFT JOIN @ExectionListWithEstimationPoint EET ON EET.ExecutionID = EL.ExecutionID 
						WHERE EET.ExecutionID IS NULL)
		BEGIN

			SET @ALMConfigPercentage = 0 

		END
		ELSE
		BEGIN
				
			SET @ALMConfigPercentage = 100 
			
		END

	END

	RETURN @ALMConfigPercentage;

END