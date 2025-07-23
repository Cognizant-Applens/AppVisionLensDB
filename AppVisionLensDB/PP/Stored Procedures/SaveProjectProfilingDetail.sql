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
-- Author      : Praveen J
-- Create date : Feb 28, 2020
-- Description : Get the Project based All project profiling detail   
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [PP].[SaveProjectProfilingDetail]
@ProjectID BIGINT,
@EmployeeID NVARCHAR(20),
@TvpExtendedProjectDetails as [PP].[TVP_ExtendedProjectDetails] READONLY, 
@TvpProjectAttributeValues as [PP].[TVP_ProjectAttributeValues] READONLY,
@Percentage INT
AS 
  BEGIN 
	BEGIN TRY  
	   BEGIN TRAN
		SET NOCOUNT ON;
			
	DECLARE @Result BIT;
	IF @Percentage>100 SET @Percentage = 100 
	DECLARE @IsSubmitted bit;
	SET @IsSubmitted = (SELECT IsSubmitted FROM @TvpExtendedProjectDetails)
	IF(@IsSubmitted = 1 ) SET @Percentage = 100

	-- Audit Log 

	DECLARE @PreviousContractValue NVARCHAR(250);
	DECLARE @PreviousPOD NVARCHAR(250);
	DECLARE @CurrentContractValue NVARCHAR(250);
    DECLARE @CurrentPOD NVARCHAR(250);
	DECLARE @AuditContractID BIGINT;
	DECLARE @AuditPODID BIGINT;

	SET @AuditContractID = (SELECT TOP 1 AuditID  FROM PP.AuditLog where ProjectId = @ProjectID and AttributeId = 12 and Isdeleted = 0 
	ORDER BY createddate DESC)
	SET @AuditPODID = (SELECT TOP 1 AuditID  FROM PP.AuditLog where ProjectId = @ProjectID and AttributeId = 24 and Isdeleted = 0 
	ORDER BY createddate DESC)
	SET @PreviousContractValue = (SELECT ContractValue FROM PP.Extended_ProjectDetails WHERE ProjectId = @ProjectID and IsDeleted =0 ) 
	SET @PreviousPOD = (SELECT NoOfPODS FROM PP.Extended_ProjectDetails WHERE ProjectId = @ProjectID and IsDeleted =0 ) 
	SET @CurrentContractValue = (SELECT ContractValue FROM @TvpExtendedProjectDetails)
	SET @CurrentPOD = (SELECT NoOfPODS FROM @TvpExtendedProjectDetails)
	IF (@PreviousContractValue <> NULL)
	BEGIN 
	IF(@PreviousContractValue = @CurrentContractValue)
	BEGIN
	UPDATE PP.AuditLog SET ToValue = @CurrentContractValue ,ModifiedBy = @EmployeeID, ModifiedDate = GetDate()
	WHERE AuditID = @AuditContractID AND ProjectId = @ProjectID AND AttributeID = 12 AND IsDeleted = 0
	END
	END
	ELSE
	BEGIN
	INSERT INTO [PP].[AuditLog] (ProjectID,AttributeID,FromValue,ToValue,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
	Values(@ProjectID,12,@PreviousContractValue,@CurrentContractValue,0,@EmployeeID,GetDate(),NULL,NULL)
	END
	IF (@PreviousPOD <> NULL)
	BEGIN 
	IF(@PreviousPOD = @CurrentPOD)
	BEGIN
	UPDATE PP.AuditLog SET ToValue = @CurrentPOD ,ModifiedBy = @EmployeeID, ModifiedDate = GetDate()
	WHERE AuditID = @AuditPODID AND ProjectId = @ProjectID AND AttributeID = 24 AND IsDeleted = 0
	END
	END
	ELSE
	BEGIN
	INSERT INTO [PP].[AuditLog] (ProjectID,AttributeID,FromValue,ToValue,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)
	Values(@ProjectID,24,@PreviousPOD,@CurrentPOD,0,@EmployeeID,GetDate(),NULL,NULL)
	END			 

	MERGE PP.Extended_ProjectDetails PD 
    using @TvpExtendedProjectDetails AS Temp 
    ON PD.ProjectID = @ProjectID 
    WHEN matched THEN 
      UPDATE SET PD.ProjectType                = Temp.ProjectType               ,
				 PD.OtherProjectType		   = Temp.OtherProjectType			,
				 PD.ProjectShortDescription	   = Temp.ProjectShortDescription	,
				 PD.ContractValue			   = Temp.ContractValue				,
				 PD.BusinessDriver			   = Temp.BusinessDriver			,
				 PD.OtherBusinessDriver		   = Temp.OtherBusinessDriver		,
				 PD.TechnicalDriver			   = Temp.TechnicalDriver			,
				 PD.OtherTechnicalDriver	   = Temp.OtherTechnicalDriver		,
	 			 PD.IsKEDBOwned				   = Temp.IsKEDBOwned				,
				 PD.NoOfPODS				   = Temp.NoOfPODS					,
				 PD.WorkItemSize			   = Temp.WorkItemSize				,
				 PD.VendorPresence			   = Temp.VendorPresence			,
				 PD.IsSubmitted				   = Temp.IsSubmitted	,
				 PD.ModifiedBy                 = @EmployeeID,
				 PD.ModifiedDate               = getdate()
    WHEN NOT matched THEN 
      INSERT (ProjectID
	          ,ProjectType               
			  ,OtherProjectType			
			  ,ProjectShortDescription	
			  ,ContractValue				
			  ,BusinessDriver			
			  ,OtherBusinessDriver		
			  ,TechnicalDriver			
			  ,OtherTechnicalDriver		
			  ,IsKEDBOwned				
			  ,NoOfPODS					
			  ,WorkItemSize				
			  ,VendorPresence			
			  ,IsSubmitted	
			  ,[IsDeleted] 
	          ,[CreatedBy] 
	          ,[CreatedDate] 
	          ,[ModifiedBy]
	          ,[ModifiedDate]
			  )
			   values
			   ( 
				  @ProjectID
			     ,Temp.ProjectType            
				 ,Temp.OtherProjectType		
				 ,Temp.ProjectShortDescription
				 ,Temp.ContractValue			
				 ,Temp.BusinessDriver		
				 ,Temp.OtherBusinessDriver	
				 ,Temp.TechnicalDriver		
				 ,Temp.OtherTechnicalDriver	
				 ,Temp.IsKEDBOwned				
				 ,Temp.NoOfPODS					
				 ,Temp.WorkItemSize				
				 ,Temp.VendorPresence		
				 ,Temp.IsSubmitted	
				 ,0
				 ,@EmployeeID 
				 ,getdate() 
				 ,null
			     ,null
				 
				 );

	MERGE PP.ProjectAttributeValues PA 
    using @TvpProjectAttributeValues AS Temp 
    ON PA.ProjectID = @ProjectID  and PA.AttributeValueID = Temp.AttributeValueID and PA.AttributeID = Temp.AttributeID
    WHEN matched THEN 
      UPDATE SET PA.AttributeValueID           = Temp.AttributeValueID,
				 PA.ModifiedBy                 = @EmployeeID,
				 PA.ModifiedDate               = getdate(),
				 PA.IsDeleted					=0
    WHEN NOT matched THEN 
      INSERT ( 
			   ProjectID
	          ,AttributeValueID
	          ,AttributeID
			  ,IsDeleted
	          ,[CreatedBy] 
	          ,[CreatedDate] 
	          ,[ModifiedBy]
	          ,[ModifiedDate]
			  )
			   values
			   ( 
			      @ProjectID
			     ,Temp.AttributeValueID            
				 ,Temp.AttributeID	
				 ,0
				 ,@EmployeeID 
				 ,getdate() 
				 ,null
			     ,null
				 
				 );

			UPDATE PA
			SET PA.IsDeleted=1,ModifiedBy=@EmployeeID,ModifiedDate=GETDATE() 
			FROM  PP.ProjectAttributeValues PA 
			INNER JOIN @TvpProjectAttributeValues AS Temp 
			ON PA.ProjectID = @ProjectID 	and PA.AttributeID = Temp.AttributeID
			and PA.AttributeValueID NOT IN
			(SELECT AttributeValueID FROM @TvpProjectAttributeValues)
		

				 MERGE  PP.ProjectProfilingTileProgress PP
				 USING (VALUES (@ProjectID))   AS P(ProjectID)
				 ON P.ProjectID = PP.ProjectID AND PP.TileID = 1 AND PP.IsDeleted = 0
				 WHEN MATCHED THEN
				 UPDATE SET PP.TileProgressPercentage = @Percentage,
				        PP.ModifiedBy = @EmployeeID,
						PP.ModifiedDateTime = GetDate()
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
                 VALUES(@ProjectID,1,@Percentage,0,@EmployeeID,GetDate(),NULL,NULL);
				
				
				

			SET @Result = 1
			Select @Result as Result
		COMMIT TRAN
	END TRY 

    BEGIN CATCH 
		SET @Result = 0
		Select @Result as Result
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error   
		ROLLBACK TRAN
        EXEC AVL_INSERTERROR  '[PP].[SaveProjectProfilingDetail]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
