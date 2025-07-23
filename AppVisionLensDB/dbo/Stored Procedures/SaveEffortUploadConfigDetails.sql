/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[SaveEffortUploadConfigDetails] 

@EmployeeID varchar(20)=null,
@ProjectID bigint=null,
@IsmanualOrAuto char=null,
@SharePath nvarchar(200)=null,
@Ismailer char=NULL,
@EffortSharePathUsers varchar(50)=null

as
BEGIN
BEGIN TRY

MERGE AVL.EffortUploadConfiguration AS EU

USING (VALUES (@ProjectID)) AS s(ProjectID)
ON eu.ProjectID = s.ProjectID

WHEN MATCHED THEN
  
  UPDATE SET EU.SharePathName = @SharePath,
			 EU.EffortUploadType = @IsmanualOrAuto,
			 EU.IsMailEnabled = @Ismailer,
			 EU.ModifiedBy = @EmployeeID,
			 EU.ModifiedDate = Getdate(),
			 EU.IsActive = CASE WHEN @IsmanualOrAuto='A' THEN 1 else 0 End

	
WHEN NOT MATCHED THEN
 
  INSERT(
			ProjectID,
			SharePathName,
			EffortUploadType,
			IsMailEnabled,
			IsActive,
			CreatedBy,
			CreatedDate
		)
  VALUES(@ProjectID,
		 @SharePath,
         @IsmanualOrAuto,
         @Ismailer,
		 1,
		 @EmployeeID,
		 GETDATE()
		 ); 

select ProjectID from TicketUploadProjectConfiguration where ProjectID=@ProjectID and IsDeleted=0

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);
 
		EXEC AVL_InsertError '[dbo].[SaveEffortUploadConfigDetails]', 

		@ErrorMessage, @EmployeeID ,@ProjectID
		
	END CATCH  
end
