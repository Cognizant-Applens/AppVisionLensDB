/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--sp_helptext 'AVL_CL_UpdateMLFlag'



CREATE proc [dbo].[AVL_CL_UpdateMLFlag]

@ProjectID bigint



as

begin
BEGIN TRY
BEGIN TRAN
declare @UserID nvarchar(max);

set @UserID=(select CreatedBy from  AVL.CL_ProjectJobDetails where ProjectID=@ProjectID and statusForJOB=0 and IsDeleted=0)

update AVL.CL_PRJ_ContLearningState set [SentBy]=@UserID,[SentOn]=getdate(),ModifiedBy=@UserID,ModifiedDate=getdate() where ProjectID=@ProjectID and [IsDeleted]=0

 --select   [IsMLSentOrReceived] as MLStatus,[StartDate],[EndDate],IsSDTicket,IsDartTicket   from AVL.CL_PRJ_ContLearningState where ProjectID=@ProjectID  and [IsDeleted]=0 
 
 COMMIT TRAN
 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[AVL_CL_UpdateMLFlag] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



end
