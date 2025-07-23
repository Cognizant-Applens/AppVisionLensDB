/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[CL_InfraExportJobSuccess]
@ProjectID bigint,
@ContLearningID bigint,
@InputFilePath nvarchar(2000),
@InputFileName nvarchar(1000),
@PatternShare nvarchar(20)
AS
BEGIN
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
DECLARE @DebtAttributeType TINYINT;

SELECT TOP 1 @DebtAttributeType=(CASE DebtAttributeId WHEN 1 THEN 3 ELSE 5 END) FROM ML.InfraConfigurationProgress 
							WHERE ProjectID = @ProjectID 
							AND IsDeleted = 0 ORDER BY ID ASC								
IF EXISTS(SELECT TOP 1 ProjectID FROM [ML].[CL_InfraContLearningMLJobStatus]  WHERE  
ProjectID=@ProjectID AND ISNULL(IsDeleted,0) = 0 AND ContLearningID = @ContLearningID)
BEGIN
UPDATE [ML].[CL_InfraContLearningMLJobStatus] SET CLJobStatus = 1,dataPath=@InputFilePath,InputFileName=@InputFileName,ModifiedBy = 'SYSTEM',
ModifiedDate = GETDATE(), PatternSharing = @PatternShare WHERE ProjectID=@ProjectID AND ISNULL(IsDeleted,0) = 0 AND ContLearningID = @ContLearningID
END
ELSE
BEGIN
INSERT INTO [ML].[CL_InfraContLearningMLJobStatus](ProjectID,ContLearningID,InputFileName,DataPath,CreatedBy,CreatedDate,CLJobStatus,IsDeleted, PatternSharing, OutputParam) 
VALUES(@ProjectID,@ContLearningID,@InputFileName,@InputFilePath,'SYSTEM',GETDATE(),1,0, @PatternShare, @DebtAttributeType)
END
COMMIT TRAN
END TRY  
BEGIN CATCH           
        ROLLBACK TRAN
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()	
		--INSERT Error    
		EXEC AVL_InsertError 'CL_InfraExportJobSuccess', 
@ErrorMessage, @ProjectID 
		
	END CATCH  
END
