/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE Proc [dbo].[EffortBulk_InsertErrorLog]
@SuccessCount bigint,
@FailCount bigint,
@ProjectID bigint,
@TrackID nvarchar(max),
@EffortUploadErrorDumpFile nvarchar(max),
@Status nvarchar(max)
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY 

Declare @EffortUploadDumpFileName nvarchar(max)

SET @EffortUploadDumpFileName=(SELECT EffortUploadDumpFileName from EffortUploadTrack (NOLOCK) where ID=@TrackID and ProjectID=@ProjectID)

INSERT INTO AVL.EffortUploadErrorLog
(ProjectID,EffortUploadDumpName,ErrorFileName,TotalRecords,SuccessCount,FailedCount,UploadedEndDate,IsActive,CreatedBy,CreatedDate,Status)

VALUES
(@ProjectID,@EffortUploadDumpFileName,@EffortUploadErrorDumpFile,(@SuccessCount+@FailCount),@SuccessCount,@FailCount,GETDATE(),1,'System',GETDATE(),@Status)
update EffortUploadTrack set Status=1 where ID=@TrackID

SELECT top 1 * from AVL.EffortUploadErrorLog (NOLOCK) ORDER by CreatedDate DESC


END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SET @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC AVL_InsertError 'EffortBulk_InsertErrorLog', @ErrorMessage, 0,0
		
	END CATCH  

	SET NOCOUNT OFF;
END
