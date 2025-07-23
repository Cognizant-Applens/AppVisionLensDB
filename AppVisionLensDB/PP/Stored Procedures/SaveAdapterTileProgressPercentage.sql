/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : 
-- Create date : 01/07/2020
-- Description : Procedure to SourceColumn
-- Revision    :
-- Revised By  :
-- ========================================================================================= 
CREATE PROCEDURE [PP].[SaveAdapterTileProgressPercentage]
(
	@ProjectID BIGINT,    
	@EmployeeID VARCHAR(100) NULL
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

	DECLARE @ALMConfigPerc		INT			= 0
	DECLARE @OnboardingTileID	SMALLINT	= 5 
	DECLARE @ALMConfigTileID	SMALLINT	= 8
	DECLARE @ShowALMConfig		BIT			= 0
	DECLARE @IsApplens			INT			= 0

	SELECT @IsApplens = IsApplensAsALM FROM pp.ScopeOfWork (NOLOCK) WHERE ProjectID = @ProjectID
	
	IF (@IsApplens = 0) -- ALM selected as External Tool
    BEGIN

		SELECT PAV.AttributeValueID AS 'AttributeValueID', ppav.AttributeValueName AS 'AttributeValueName'
		INTO #ScopeDetails
		FROM PP.ProjectAttributeValues PAV (NOLOCK)
		JOIN MAS.PPAttributeValues ppav (NOLOCK) ON pav.AttributeID = ppav.AttributeID 
			AND PAV.AttributeValueID = ppav.AttributeValueID AND ppav.AttributeID = 1 AND ppav.IsDeleted = 0 
		WHERE PAV.ProjectID = @ProjectID AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0

		IF EXISTS (SELECT TOP 1 1 FROM #ScopeDetails)
		BEGIN
		
			IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails (NOLOCK) WHERE AttributeValueID IN (1,4))
			BEGIN 

				SET @ShowALMConfig = 1	
				
			END

		END

		IF ( @ShowALMConfig = 1 )
		BEGIN

			SET @ALMConfigPerc = [PP].[GetALMConfigurationPercentage] (@ProjectID, 0)

		END
	END
	ELSE IF (@IsApplens = 1) -- Applens as ALM
	BEGIN 

	    -- Get Generic Work Item Configuration Percentage
		SET @ALMConfigPerc = [PP].[GetALMConfigurationPercentage] (@ProjectID, 1)

	END

	IF (@ALMConfigPerc > 0 OR 
			(@ALMConfigPerc = 0 AND 
				EXISTS (SELECT TOP 1 1 FROM PP.ProjectProfilingTileProgress (NOLOCK) 
				WHERE ProjectID = @ProjectID AND TileID = @ALMConfigTileID AND IsDeleted = 0))
	   )
	BEGIN

		-- Insert ALM Configuration Percentage in Project Profiling Tile Progress table.
		EXEC [PP].[SaveProjectProfilingTileProgress] @ProjectID, @ALMConfigTileID, @ALMConfigPerc, @EmployeeID
	
		-- Insert Onboarding Setup Percentage in Project Profiling Tile Progress table. 
		-- As of now, Adaptor percentage is stored until Yamuna team consumes the percentage API
		EXEC [PP].[SaveProjectProfilingTileProgress] @ProjectID, @OnboardingTileID, @ALMConfigPerc, @EmployeeID

	END

END TRY
BEGIN CATCH
	     
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		
	EXEC AVL_InsertError 'PP.SaveAdapterTileProgressPercentage', @ErrorMessage, 0 ,''
  
END CATCH

SET NOCOUNT OFF

END
