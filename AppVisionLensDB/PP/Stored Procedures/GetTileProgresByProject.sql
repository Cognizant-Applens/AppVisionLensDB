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
-- Author      : Dhivya Bharathi M
-- Create date : Feb 13, 2020
-- Description : Get the Progress for project profiling landing page      
-- Revision    :
-- Revised By  :[PP].[GetTileProgresByProject] 10337,'471742'
-- =========================================================================================
CREATE PROCEDURE [PP].[GetTileProgresByProject] 
@ProjectID BIGINT,
@EmployeeID NVARCHAR(50)
AS 
  BEGIN 
	BEGIN TRY 
	BEGIN TRAN
		SET NOCOUNT ON;
		    
   IF NOT EXISTS(SELECT TOP 1 1 FROM PP.ProjectProfilingTileProgress (NOLOCK) WHERE ProjectID = @ProjectID and TileID = 1)
   BEGIN
       
        SELECT scope.ProjectID,scope.ProjectScope AS AttributeValue,AttributeID,AttributeValueName
        INTO #PercentageCalculation
        FROM (
				SELECT DISTINCT ProjectID,ProjectScope,AttributeID,AttributeValueName from pp.OplEsaData(NOLOCK) OED
				JOIN MAS.PPAttributeValues(NOLOCK) PPAV ON PPAV.AttributeValueID = OED.ProjectScope
				WHERE projectID = @ProjectID and PPAV.AttributeID = 1 and PPAV.IsDeleted = 0 
				  UNION 
				SELECT DISTINCT ProjectID,ExecutionMethod,AttributeID,AttributeValueName from pp.OplEsaData(NOLOCK) OED
				JOIN MAS.PPAttributeValues(NOLOCK) PPAV ON PPAV.AttributeValueID = OED.ExecutionMethod
				WHERE projectID = @ProjectID and PPAV.AttributeID = 3 and PPAV.IsDeleted = 0 
				  UNION
				SELECT pav.ProjectID,pav.AttributeValueID,PPAV.AttributeID,AttributeValueName from mas.PPAttributeValues(NOLOCK) PPAV 
				JOIN pp.ProjectAttributeValues(NOLOCK)  PAV on PAV.AttributeValueID = ppav.AttributeValueID
				WHERE ProjectID = @ProjectID and PPAV.AttributeID = 1 and Pav.IsDeleted = 0 
       )scope
          DECLARE @Percentage INT = 0;
          DECLARE @Scope SMALLINT = 0;
          DECLARE @ScopeCount SMALLINT = 0;
          DECLARE @ExecCount SMALLINT = 0;
          DECLARE @DevScope SMALLINT = 0;
          DECLARE @AllScope SMALLINT = 0;
          DECLARE @Denominator SMALLINT = 0;
          DECLARE @Numerator SMALLINT = 0;
      IF EXISTS(SELECT TOP 1 1 FROM #PercentageCalculation(NOLOCK) WHERE AttributeID = 1) SET @ScopeCount  = 1;
      IF EXISTS(SELECT TOP 1 1 FROM #PercentageCalculation(NOLOCK) WHERE AttributeID = 3) SET @ExecCount  = 1;
      SET @AllScope = (SELECT COUNT(1) FROM MAS.PPAttributes(NOLOCK) WHERE IsMandatory = 1 AND ScopeID = 3)
      SET @DevScope = (SELECT COUNT(1) FROM MAS.PPAttributes(NOLOCK) WHERE IsMandatory = 1 )
      SET @Scope = (SELECT TOP 1 1 FROM #PercentageCalculation(NOLOCK) WHERE AttributeValue= 1)
      SET @Numerator = SUM(@ScopeCount+@ExecCount)
      IF @Scope = 1 SET @Denominator = @DevScope;
      ELSE SET @Denominator = @AllScope;
      IF @Numerator = 0 AND @Denominator = 0 SET @Percentage = 0;
      ELSE  SET @Percentage =  @Numerator * 100/@Denominator;
      INSERT INTO PP.ProjectProfilingTileProgress(ProjectID,TileID,TileProgressPercentage,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
      VALUES(@ProjectID,1,@Percentage,0,@EmployeeID,GetDate(),NULL,NULL)
      END 
    

	
	 --SELECT DISTINCT AttributeValueName AS Name from pp.OplEsaData(NOLOCK) OED
	 --JOIN MAS.PPAttributeValues(NOLOCK) PPAV ON PPAV.AttributeValueID = OED.ProjectScope
	 --WHERE projectID = @ProjectID and PPAV.AttributeID = 1 and PPAV.IsDeleted = 0 
	 --UNION 
	 --SELECT AttributeValueName  AS ScopeName from mas.PPAttributeValues PPAV 
	 --JOIN pp.ProjectAttributeValues(NOLOCK)  PAV on PAV.AttributeValueID = ppav.AttributeValueID
	 --WHERE ProjectID = @ProjectID and PPAV.AttributeID = 1 And pav.IsDeleted = 0

		IF EXISTS(SELECT TOP 1 1 FROM PP.ProjectAttributeValues(NOLOCK) WHERE ProjectID = @ProjectID  and AttributeID = 1 And IsDeleted = 0)
			BEGIN	
				SELECT DISTINCT AttributeValueName  AS Name from mas.PPAttributeValues(NOLOCK) PPAV 
				JOIN pp.ProjectAttributeValues(NOLOCK)  PAV on PAV.AttributeValueID = ppav.AttributeValueID
				WHERE ProjectID = @ProjectID and PPAV.AttributeID = 1 And pav.IsDeleted = 0
			END
		ELSE
			BEGIN
				SELECT DISTINCT AttributeValueName AS Name from pp.OplEsaData(NOLOCK) OED
				JOIN MAS.PPAttributeValues(NOLOCK) PPAV ON PPAV.AttributeValueID = OED.ProjectScope
				WHERE projectID = @ProjectID and PPAV.AttributeID = 1 and PPAV.IsDeleted = 0 
			END

	  DECLARE @IsInfra BIT;
	  DECLARE @CountInfra SMALLINT;
	  DECLARE @OPLCount SMALLINT;
	  DECLARE @ValuesCount SMALLINT;
	  DECLARE @OPLCISCount SMALLINT;
	  DECLARE @TotalCount SMALLINT;
	  DECLARE @TotalCISCount SMALLINT;
      SET @OPLCount = (SELECT COUNT(ProjectScope) FROM PP.OplEsaData(NOLOCK) where  ProjectId = @ProjectID AND IsDeleted = 0)
      SET @OPLCISCount = (SELECT count(ProjectScope) FROM PP.OplEsaData(NOLOCK) where  ProjectId = @ProjectID 
	  AND ProjectScope = 3 AND IsDeleted = 0)
	  SET @ValuesCount = (SELECT COUNT(ID) FROM PP.ProjectAttributeValues(NOLOCK) where ProjectId = @ProjectID 
	  AND AttributeID = 1 and IsDeleted=0)
	  SET @CountInfra = (SELECT COUNT(ID) FROM PP.ProjectAttributeValues(NOLOCK) where ProjectId = @ProjectID 
	  AND AttributeID = 1 and AttributeValueID = 3 AND IsDeleted=0)
	  SET @TotalCISCount = (@OPLCISCount + @CountInfra)
	  SET @TotalCount = (@OPLCount + @ValuesCount)
	  IF (@TotalCISCount = 1 AND @TotalCount =1)
	  BEGIN
	  SET @IsInfra = 1
	  END
	  ELSE
	  BEGIN
	  SET @IsInfra = 0
	  END
	  DECLARE @ServiceCount INT;
	  SET @ServiceCount=(SELECT COUNT(1) FROM AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) 
						WHERE ProjectID=@ProjectID
						AND ISNULL(IsDeleted,0)=0)

	 --INSERT OR UPDATE TILEID 6 PERCENTAGE
	IF EXISTS ( SELECT 1 FROM AVL.MAS_ProjectMaster amp WITH (NOLOCK )
				INNER JOIN ToolAccIDMapping tam WITH (NOLOCK)
				on amp.EsaProjectID = tam.projectid and tam.IsDeleted=0 
				WHERE amp.projectid = @ProjectID and amp.IsDeleted=0)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM [PP].[ProjectProfilingTileProgress] WITH (NOLOCK)
					   WHERE projectid = @ProjectID and TileID = 6 and IsDeleted=0)
		BEGIN
			 INSERT INTO PP.ProjectProfilingTileProgress(ProjectID,TileID,TileProgressPercentage,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
			 VALUES
				(@ProjectID,6,100,0,'System',GetDate(),NULL,NULL)
		END
	END
	--INSERT OR UPDATE TILEID 7 PERCENTAGE
	IF EXISTS ( SELECT 1 FROM AVL.MAS_ProjectMaster amp WITH (NOLOCK)
			   INNER JOIN BOM_BusinessProcessMapping bb WITH (NOLOCK) 
			   ON amp.customerid = bb.accountid and bb.IsActive=1 
			   WHERE amp.projectid = @ProjectID and amp.IsDeleted=0)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM [PP].[ProjectProfilingTileProgress] WITH (NOLOCK)
					   WHERE projectid = @ProjectID and TileID = 7and IsDeleted=0)
		BEGIN
			 INSERT INTO PP.ProjectProfilingTileProgress(ProjectID,TileID,TileProgressPercentage,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)
			  VALUES
				(@ProjectID,7,100,0,'System',GetDate(),NULL,NULL)
		END
	END
		
		

	 SELECT PT.TileID,PT.TileName,PT.TileDescription,ISNULL(TP.TileProgressPercentage,0) AS  TileProgressPercentage,
	 CASE WHEN PT.TileId = 4 then @IsInfra else EP.IsSubmitted end as IsSubmitted
	 INTO #Temp
	 FROM [MAS].[ProjectProfilingTiles](NOLOCK) PT
	 LEFT JOIN [PP].[ProjectProfilingTileProgress](NOLOCK)  TP ON PT.TileID=TP.TileID and TP.ProjectID=@ProjectID and TP.IsDeleted=0
	 LEFT JOIN [pp].[Extended_ProjectDetails] (Nolock) EP on EP.ProjectID = @ProjectID

	 --UPDATE #Temp SET TileProgressPercentage =100 WHERE TileID= 4 AND @ServiceCount >0
	 SELECT DISTINCT TileID,TileName,TileDescription,TileProgressPercentage,IsSubmitted FROM #Temp(NOLOCK)

	 DROP TABLE IF EXISTS #PercentageCalculation
     DROP TABLE IF EXISTS #Temp

	SET NOCOUNT OFF
	COMMIT TRAN
	END TRY 
	 
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		ROLLBACK TRAN 
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[PP].[GetTileProgresByProject]', @ErrorMessage,  0, 0 
    END CATCH 
  END