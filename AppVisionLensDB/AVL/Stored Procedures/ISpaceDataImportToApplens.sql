/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[ISpaceDataImportToApplens]
(
@TVP_ISpaceIdeaDetails TVP_ISpaceIdeaDetails readonly,
@TVP_ISpaceOpportunityDetails TVP_ISpaceOpportunityDetails readonly,
@IspaceJobDate DateTime=null
)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON; 

Update HTD set HTD.ImplementationStatus=TVP.Status,HTD.ISpaceIdeaId=TVP.ISpaceIdeaId from @TVP_ISpaceIdeaDetails TVP INNER JOIN AVL.DEBT_TRN_HealTicketDetails HTD on HTD.Id=TVP.ApplensTicketId  
Update HTD set HTD.ISpaceStatus=CAse when (TVP.Status ='Open' or TVP.Status ='Active') then 'Active' else 'Closed' end
,HTD.ISpaceOpportunityId=TVP.ISpaceOpportunityId from @TVP_ISpaceOpportunityDetails TVP INNER JOIN AVL.DEBT_MAS_ReleasePlanDetails HTD on HTD.Id=TVP.ApplensOpportunityId 

DECLARE @CURRENTDATE DATETIME
SELECT @CURRENTDATE=MAX(createddate) FROM AVL.ISpaceJobStatus where JobStatus=0
update AVL.ISpaceJobStatus set 
JobStatus=1,jobDate=getdate(),modifieddate=getdate()
 where createddate=@CURRENTDATE

SET NOCOUNT OFF; 	
	COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SET @ErrorMessage = ERROR_MESSAGE()

		SELECT @ErrorMessage
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[ISpaceDataImportToApplens]', @ErrorMessage, 0,0
END CATCH  

END
