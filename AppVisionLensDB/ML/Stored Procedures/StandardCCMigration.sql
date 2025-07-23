/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
-- =============================================
-- Author:		683989
-- Create date: 22-JUNE-2020
-- Description:	Update Standard CC and RC Migration
-- =============================================
CREATE PROCEDURE [ML].[StandardCCMigration] 
(	     
		@ProjectID INT,
		@ITSMCauseCodeList TVP_ITSMCauseCodeList READONLY
		
)
AS

BEGIN
DECLARE @result bit=0,@CCClusterID INT;
    SET NOCOUNT ON; 
	BEGIN TRY
	  

	   SELECT @CCClusterID=ClusterID FROM MAS.Cluster(NOLOCK) WHERE ClusterName='NA' AND CategoryID = 1

	   
	   SELECT [CauseId], [CauseStatusId], [CauseCodeName], [MCauseCode] INTO #CauseCodeList FROM @ITSMCauseCodeList

	   UPDATE #CauseCodeList SET [CauseStatusId] = @CCClusterID WHERE [CauseStatusId] IS NULL OR [CauseStatusId] = 0 	   
	   	
	   UPDATE [AVL].[DEBT_MAP_CauseCode] 
			SET
			CauseStatusID=t2.CauseStatusId,
			ModifiedDate=GETDATE(),
			ModifiedBy='System'
	    FROM [AVL].[DEBT_MAP_CauseCode] t1
		JOIN #CauseCodeList t2
			 ON t1.CauseID=t2.CauseId 
        JOIN avl.MAS_ProjectMaster(NOLOCK) PM
		ON PM.ProjectID=T1.ProjectID
	     where t1.IsDeleted = 0 AND PM.IsDeleted=0
		 AND ISNULL(PM.IsMultilingualEnabled,0) <> 1
		 and t1.ProjectID=@ProjectID 		      
		 		
		
		UPDATE CC 
			SET CauseStatusID = @CCClusterID
		FROM [AVL].[DEBT_MAP_CauseCode]  CC	
			JOIN avl.MAS_ProjectMaster(NOLOCK) PM
		ON PM.ProjectID=CC.ProjectID
	     where CC.IsDeleted = 0 AND PM.IsDeleted=0
		 AND ISNULL(PM.IsMultilingualEnabled,0) <> 1 
		 AND (CC.CauseStatusID IS NULL or CC.CauseStatusID = 0)
		 and CC.ProjectID=@ProjectID
		
	 SET @result=1
	
     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'ML.StandardCCRCMigration', @ErrorMessage, 0 ,@ProjectID
		  SET @result=1
	 END CATCH
	
	SET NOCOUNT OFF;
	SELECT @result AS 'Result'
END
