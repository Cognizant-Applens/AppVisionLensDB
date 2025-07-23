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
-- Author      : Sathyanarayanan B
-- Create date : June 12, 2020
-- Description : Service Catalog Save
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [PP].[SaveServiceCatalogDetail]
@ProjectID BIGINT,
@EmployeeID NVARCHAR(50),
@FTEDetails as [PP].[TVP_FTEDetails] READONLY,
@ActivityDetails as [PP].[TVP_ActivityDetails] READONLY
AS 
  BEGIN 
	BEGIN TRY  

		SET NOCOUNT ON;

		BEGIN TRAN

--FTE Value Save 
		CREATE TABLE #FTEDetails
			(
				[FTEValue] [decimal](10,2) NULL,
				[ServiceCategoryID] [int] NULL,
			)
		INSERT INTO #FTEDetails
		SELECT TEMP.FTEValue, TEMP.ServiceCategoryID FROM  @FTEDetails TEMP INNER JOIN MAS.ServiceCategory(NOLOCK) SC ON SC.CategoryID=TEMP.ServiceCategoryID AND SC.IsDeleted=0

		UPDATE  AVL.ProjectServiceTypeFTE SET IsDeleted=1,ModifiedBy=@EmployeeID,ModifiedDate=getdate() WHERE ProjectID = @ProjectID
							
		MERGE AVL.ProjectServiceTypeFTE FTE   
			USING #FTEDetails AS TEMP ON FTE.ProjectID = @ProjectID  AND FTE.ServiceTypeID = TEMP.ServiceCategoryID  
			WHEN matched THEN   
			UPDATE SET FTE.FTEPercenatge = Temp.FTEValue, FTE.ModifiedBy  = @EmployeeID, 
			FTE.ModifiedDate = getdate(), FTE.IsDeleted = 0 
		    WHEN NOT matched THEN   
			INSERT 
			(   
				[ProjectID],[ServiceTypeID],[FTEPercenatge],[IsDeleted],[CreatedBy],[CreatedDate],
				[ModifiedBy],[ModifiedDate] 
		    )  
			values  
			(   
				@ProjectID, Temp.ServiceCategoryID, Temp.FTEValue, 0, @EmployeeID, GETDATE(),   
				null  ,null  
			);	

--Activity Save   
					
		CREATE TABLE #ServiceMapID
		(
			ServiceMappingID INT NULL
		)
		INSERT INTO #ServiceMapID
		SELECT DISTINCT MAS.ServiceMappingID  FROM AVL.TK_MAS_ServiceActivityMapping(NOLOCK) MAS
		INNER JOIN @ActivityDetails TAD ON MAS.ActivityID=TAD.ActivityID AND MAS.ServiceID=TAD.ServiceID 
		AND MAS.IsDeleted=0 

		UPDATE AVL.TK_PRJ_ProjectServiceActivityMapping  SET IsDeleted=1,ModifiedBy=@EmployeeID,ModifiedDateTime=GETDATE() WHERE ProjectID = @ProjectID

		MERGE AVL.TK_PRJ_ProjectServiceActivityMapping PSM 
		USING #ServiceMapID AS Temp 
		ON PSM.ProjectID = @ProjectID AND PSM.ServiceMapID=Temp.ServiceMappingID
		WHEN matched THEN 
		  UPDATE SET PSM.IsDeleted					= 0,
					 PSM.ModifiedBy                 = @EmployeeID,
					 PSM.ModifiedDateTime           = GETDATE()
		WHEN NOT matched THEN 
		INSERT (ServiceMapID,ProjectID,IsDeleted,CreatedDateTime,CreatedBY,ModifiedDateTime,ModifiedBY,IsHidden,EffectiveDate,IsMainspringData)            
		VALUES (Temp.ServiceMappingID,@ProjectID ,0,GETDATE(),@EmployeeID,NULL,NULL,NULL,NULL,NULL);
		
		UPDATE PSM    
		SET PSM.IsMainspringData='Y' FROM    
		AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSM    
		INNER JOIN AVL.MAS_PROJECTMASTER PMAS ON PMAS.PROJECTID=PSM.PROJECTID AND PMAS.ISDELETED=0 AND PSM.ISDELETED=0    
		INNER JOIN MS.MPs_staging_table_eform_view SMPB ON PMAS.ESAPROJECTID=SMPB.DN_PROJECTID    
		INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON SMPB.DN_ServiceOfferingLEvel3=MS.ServiceName AND MS.isdeleted=0                 
		INNER JOIN avl.TK_MAS_ServiceActivityMapping MAS ON PSM.ServiceMapID=MAS.ServiceMappingID AND MS.ServiceID=MAS.ServiceID AND MAS.ISDELETED=0    
		INNER JOIN #ServiceMapID SMTVP ON SMTVP.ServiceMappingID=PSM.ServiceMapID  
		WHERE PMAS.PROJECTID=@ProjectID 

--Service Catalog % Completion based on AD and AVM
		DECLARE @CheckIncludeAD INT = 0
		DECLARE @CheckIncludeAVM INT = 0
		DECLARE @SplitPercentValue DECIMAL(18, 2)
		DECLARE @ADServiceID INT = 0
		DECLARE @AVMServiceID INT = 0
		DECLARE @SerCatPerc DECIMAL(18,2) = 0.00
		DECLARE @TotMPerc int =0

		SELECT PAV.AttributeValueID as 'AttributeValueID', ppav.AttributeValueName as 'AttributeValueName'
		INTO #ScopeDetailsForServiceCatalog
		FROM PP.ProjectAttributeValues PAV
		JOIN MAS.PPAttributeValues ppav on pav.AttributeID=ppav.AttributeID 
		and PAV.AttributeValueID=ppav.AttributeValueID and ppav.IsDeleted=0 and ppav.AttributeID=1
		WHERE PAV.AttributeID=1 and PAV.ProjectID=@ProjectID AND PAV.IsDeleted=0

		IF EXISTS(SELECT 1 FROM #ScopeDetailsForServiceCatalog WHERE AttributeValueID in (1, 4))
		BEGIN 
			SET @CheckIncludeAD=1
		END
		IF EXISTS(SELECT 1 FROM #ScopeDetailsForServiceCatalog WHERE AttributeValueID in (2))
		BEGIN
			SET @CheckIncludeAVM=1
		END

		IF(@CheckIncludeAD = 1 AND @CheckIncludeAVM = 1)  
			SET @SplitPercentValue = CAST(CAST(100 AS DECIMAL(18, 2))/CAST(2 as DECIMAL(18, 2)) as DECIMAL(18, 2))
		ELSE IF((@CheckIncludeAD = 1 AND @CheckIncludeAVM = 0) OR (@CheckIncludeAD = 0 AND @CheckIncludeAVM = 1))   
			SET @SplitPercentValue = CAST(CAST(100 AS DECIMAL(18, 2))/CAST(1 as DECIMAL(18, 2)) as DECIMAL(18, 2))
		ELSE IF(@CheckIncludeAD = 0 AND @CheckIncludeAVM = 0)  
			SET @SplitPercentValue = 0

		SET @ADServiceID = (SELECT COUNT(1) from AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) MSAM ON MSAM.ServiceMappingID = PSAM.ServiceMapID 
		AND PSAM.IsDeleted=0 AND MSAM.IsDeleted=0
		INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON MSAM.ServiceID=MS.ServiceID AND MS.IsDeleted=0 AND MS.IsDeleted=0
		WHERE PSAM.ProjectID=@ProjectID AND MS.ScopeID IN (1,3))

		SET @AVMServiceID = (SELECT COUNT(1) from AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) PSAM
		INNER JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) MSAM ON MSAM.ServiceMappingID = PSAM.ServiceMapID 
		AND PSAM.IsDeleted=0 AND MSAM.IsDeleted=0
		INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON MSAM.ServiceID=MS.ServiceID AND MS.IsDeleted=0 AND MS.IsDeleted=0
		WHERE PSAM.ProjectID=@ProjectID AND MS.ScopeID IN (2,3))

		IF(@ADServiceID > 0 AND @CheckIncludeAD = 1)
		BEGIN
			SET @SerCatPerc +=@SplitPercentValue
		END
		IF(@AVMServiceID > 0 AND @CheckIncludeAVM = 1)
		BEGIN
			SET @SerCatPerc +=@SplitPercentValue
		END

		SET @TotMPerc =ROUND(@SerCatPerc, 0)

--Tile Progress
	IF EXISTS(SELECT COUNT(1) FROM AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) WHERE ProjectID=@ProjectID
				  AND IsDeleted=0)
		BEGIN
			 MERGE  PP.ProjectProfilingTileProgress PP
				 USING (VALUES (@ProjectID))   AS P(ProjectID)
				 ON P.ProjectID = PP.ProjectID AND PP.TileID = 4 AND PP.IsDeleted = 0
				 WHEN MATCHED THEN
				 UPDATE SET PP.TileProgressPercentage = @TotMPerc,
				        PP.ModifiedBy = @EmployeeID,
						PP.ModifiedDateTime = GETDATE()
				 WHEN NOT MATCHED BY TARGET THEN
				 INSERT (
				 ProjectID
				 ,TileID
				 ,TileProgressPercentage
				 ,IsDeleted
				 ,CreatedBy
				 ,CreatedDateTime
				 ,ModifiedBy
				 ,ModifiedDateTime)
                 VALUES(@ProjectID,4,@TotMPerc,0,@EmployeeID,GETDATE(),NULL,NULL);
		END
		
		DECLARE @ActiveCount INT=0 ;
		SET @ActiveCount=(SELECT COUNT(1) FROM AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) WHERE ProjectID=@ProjectID
						  AND ISNULL(IsDeleted,0)=0);
		IF @ActiveCount=0 OR @ActiveCount IS NULL
		BEGIN
			UPDATE  PP.ProjectProfilingTileProgress SET TileProgressPercentage=0,ModifiedBy=@EmployeeID,
			ModifiedDateTime=GETDATE() WHERE ProjectID=@ProjectID
			AND TileID=4
		END

		
		SELECT 1 AS Result
		COMMIT TRAN
	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[SaveServiceCatalogDetail]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
