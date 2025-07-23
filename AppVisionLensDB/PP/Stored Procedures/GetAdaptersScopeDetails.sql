/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ===========================================================================================  
-- Author      :   
-- Create date : 30/05/20200  
-- Description : Procedure to SourceColumn   
-- Revision    : Added Percentage calculation for IsApplens AS ALM - Generic Work Item Config.  
-- Revised By  : Karunapriya K  
-- ===========================================================================================  
CREATE PROCEDURE [PP].[GetAdaptersScopeDetails] --136408--, '371789'
(  
	 @ProjectID BIGINT,  
	 @EmployeeID NVARCHAR(50) = NULL  
)  
AS  
BEGIN    

	SET NOCOUNT ON;    
 
	BEGIN TRY    
		DECLARE @ShowALMConfig				BIT			= 0    
		DECLARE @ShowITSMConfig				BIT			= 0    
        DECLARE @IsApplens			        BIT			= 0
		DECLARE @ALMConfigTileID			SMALLINT	= 8 
		DECLARE @ITSMConfigTileID			SMALLINT	= 9
		DECLARE @WorkProfilerConfigTileID	SMALLINT	= 11
		DECLARE @ALMPerc					INT			= 0   
		DECLARE @ITSMPerc					INT			= 0   
		DECLARE @WorkProfilerPerc			INT			= 0 
 
        SELECT @IsApplens = ISNULL(IsApplensAsALM, 0) FROM pp.ScopeOfWork (NOLOCK) WHERE ProjectID = @ProjectID    
  
		/* AttributeID =1 = ProjectScope*/    
		SELECT PAV.AttributeValueID AS 'AttributeValueID', ppav.AttributeValueName AS 'AttributeValueName'    
		INTO #ScopeDetails    
		FROM PP.ProjectAttributeValues PAV  (NOLOCK) 
		JOIN MAS.PPAttributeValues ppav (NOLOCK)  ON pav.AttributeID = ppav.AttributeID     
			AND PAV.AttributeValueID = ppav.AttributeValueID AND ppav.AttributeID = 1 AND ppav.IsDeleted = 0   
		WHERE PAV.ProjectID = @ProjectID AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0   
  
		IF EXISTS ( SELECT TOP 1 1 FROM #ScopeDetails(NOLOCK) )    
		BEGIN    
    
			-- Check for either Development / Testing / Both Development & Testing
			IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails (NOLOCK)  WHERE AttributeValueID IN (1,4))    
			BEGIN    
  
				SET @ShowALMConfig = 1    
    
			END    
			-- Check for either Maintainence / CIS / Both Maintainence & CIS
			IF EXISTS(SELECT TOP 1 1 FROM #ScopeDetails (NOLOCK)  WHERE AttributeValueID IN (2,3))    
			BEGIN    
  
				SET @ShowITSMConfig = 1    
  
			END    
    
		 END    
  
		 DROP TABLE #ScopeDetails  
  
		 -- Get ITSM Tile Progress Percentage when selected scope is Maintainence, CIS   
		 IF (@ShowITSMConfig = 1) 
		 BEGIN     
  
			SELECT TOP 1 @ITSMPerc = ISNULL(TileProgressPercentage, 0)
			FROM PP.ProjectProfilingTileProgress (NOLOCK)  
			WHERE ProjectID = @ProjectID AND TileID = @ITSMConfigTileID AND IsDeleted = 0
    
		 END 
		 -- Get ALM Tile Progress Percentage when selected scope is Development, Testing 
		 IF (@IsApplens = 1 OR @ShowALMConfig = 1) 
		 BEGIN     
  
			SELECT TOP 1 @ALMPerc = ISNULL(TileProgressPercentage, 0)
			FROM PP.ProjectProfilingTileProgress (NOLOCK) 
			WHERE ProjectID = @ProjectID AND TileID = @ALMConfigTileID AND IsDeleted = 0
    
		 END    

		 -- Get Work Profiler Configuration Tile Progress Percentage
		 SELECT TOP 1 @WorkProfilerPerc = ISNULL(TileProgressPercentage, 0)
		 FROM PP.ProjectProfilingTileProgress (NOLOCK) 
		 WHERE ProjectID = @ProjectID AND TileID = @WorkProfilerConfigTileID AND IsDeleted = 0
  

		 SELECT CASE WHEN (@ShowITSMConfig = 1 AND @ShowALMConfig = 1) THEN (@ALMPerc + @ITSMPerc + @WorkProfilerPerc) / 3
										WHEN (@ShowITSMConfig = 0 AND @ShowALMConfig = 1) THEN (@ALMPerc + @WorkProfilerPerc) / 2
										WHEN (@ShowITSMConfig = 1 AND @ShowALMConfig = 0) THEN (@ITSMPerc + @WorkProfilerPerc) / 2
										ELSE (@ALMPerc + @WorkProfilerPerc) / 2 END  
			   AS tot
      
   

SET NOCOUNT OFF

 END TRY    
 BEGIN CATCH    

	DECLARE @ErrorMessage VARCHAR(MAX);    
	SELECT @ErrorMessage = ERROR_MESSAGE()  
	  
	EXEC AVL_InsertError '[PP].[GetAdaptersScopeDetails]', @ErrorMessage, 0 , ''  
   
 END CATCH   
END
