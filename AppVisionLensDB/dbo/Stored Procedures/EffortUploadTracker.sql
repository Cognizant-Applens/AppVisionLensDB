/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE proc [dbo].[EffortUploadTracker]  --EXEC [dbo].[EffortUploadTracker] 12,"","10569","asa.xlsx","asa_Eror.xlsx",'1',"","",""

@ID int                                = null,
@EmployeeID nvarchar(100)              = null,
@ProjectID nvarchar(100)               = null,
@EffortUploadDumpFileName varchar(max) = null,
@EffortUploadErrorDumpFile varchar(max)= null,
@Status char(2)                           = null,
@FilePickedTime datetime               = null,
@APIRequestedTime datetime             = null,
@APIRespondedTime datetime             = null,
@Remarks varchar(max)				   = null					


as
BEGIN
SET NOCOUNT ON;
BEGIN TRY

MERGE EffortUploadTrack AS EUP

USING (VALUES (@ID)) AS eu(ID)

ON eu.ID = EUP.ID

WHEN MATCHED THEN
  
  UPDATE SET EUP.EffortUploadDumpFileName = isnull(@EffortUploadDumpFileName,EUP.EffortUploadDumpFileName),
			 EUP.EffortUploadErrorDumpFile = isnull(@EffortUploadErrorDumpFile,EUP.EffortUploadErrorDumpFile),
			 EUP.Status = isnull(@Status,EUP.Status),
			 EUP.FilePickedTime = ISNULL(@FilePickedTime, EUP.FilePickedTime),
			 EUP.APIRequestedTime = ISNULL(@APIRequestedTime,EUP.APIRequestedTime),
			 EUP.APIRespondedTime = ISNULL(@APIRespondedTime, EUP.APIRespondedTime),
			 EUP.Remarks = ISNULL(@Remarks,EUP.Remarks)
	
WHEN NOT MATCHED THEN
 
  INSERT(
			ProjectID,
			EffortUploadDumpFileName ,
			EffortUploadErrorDumpFile ,
			Status ,
			FilePickedTime ,
			APIRequestedTime ,
			APIRespondedTime ,
			IsActive ,
			Remarks,
			CreatedBy ,
			CreatedDate ,
			ModifiedBy ,
			ModifiedDate 
		)
  VALUES(
			@ProjectID ,
			@EffortUploadDumpFileName ,
			@EffortUploadErrorDumpFile,
			@Status ,
			@FilePickedTime ,
			@APIRequestedTime ,
			@APIRespondedTime ,
			1,
			@Remarks,
			@EmployeeID,
			GetDate(),
			'',
			''
		 ); 



IF(@id is null)
set @id = @@identity



select 
ID ,
ProjectID ,
EffortUploadDumpFileName ,
EffortUploadErrorDumpFile,
Status,
FilePickedTime ,
APIRequestedTime ,
APIRespondedTime ,
IsActive ,
Remarks,
CreatedBy ,
CreatedDate,
ModifiedBy ,
ModifiedDate  from EffortUploadTrack (NOLOCK) where ID=@id and IsActive = 1 
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);
 
		EXEC AVL_InsertError '[dbo].[[EffortUploadTracker]]', 

		@ErrorMessage, @EmployeeID ,@ProjectID
		
	END CATCH 
	SET NOCOUNT OFF;
end
