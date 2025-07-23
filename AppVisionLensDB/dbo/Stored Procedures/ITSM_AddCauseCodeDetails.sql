/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[ITSM_AddCauseCodeDetails] 
(	     
@ProjectID INT,
@ITSMCauseCodeList TVP_ITSMCauseCodeList READONLY,
@CustomerID int=null,
@CreatedBy VARCHAR(100)=NULL,
@CCItsmTool VARCHAR(5) = NULL
)
AS

BEGIN
DECLARE @result bit=0,@ITSMScreenId INT=7,@IsCognizant INT,@ClusterID INT,@ITSMCC BIT = 1;


    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	  SELECT @ClusterID=ClusterID FROM MAS.Cluster(NOLOCK) WHERE ClusterName='NA' AND CategoryID = 1

	   SELECT 	@IsCognizant=C.IsCognizant FROM AVL.Customer C (NOLOCK) WHERE CustomerID=@CustomerID

	   SELECT [CauseId], [CauseStatusId], [CauseCodeName], [MCauseCode] INTO #CauseCodeList FROM @ITSMCauseCodeList

	   SELECT @ITSMCC = 0 FROM #CauseCodeList (NOLOCK) WHERE @CCItsmTool = 'N'

	   UPDATE #CauseCodeList SET [CauseStatusId] = @ClusterID WHERE [CauseStatusId] IS NULL OR [CauseStatusId] = 0 

 IF @IsCognizant=1
	   BEGIN 
	   SET @ITSMScreenId=8
	   END
     ELSE 
	   BEGIN
	    SET @ITSMScreenId=7
	   END
	   IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] (NOLOCK) where ITSMScreenId=@ITSMScreenId and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
begin
      INSERT INTO [AVL].[PRJ_ConfigurationProgress] (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
	  values(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CreatedBy,getdate())
end  
else
begin

update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 
end


	  INSERT INTO [AVL].[DEBT_MAP_CauseCode] 
		 (CauseCode,CauseStatusID,MCauseCode,ProjectID,IsDeleted,CreatedDate,CreatedBy)
		   SELECT CauseCodeName,CauseStatusID,MCauseCode,@ProjectID,0,GETDATE(),@CreatedBy
		    FROM #CauseCodeList WHERE CauseId=0
		
       UPDATE [AVL].[DEBT_MAP_CauseCode] 
	   SET CauseCode=t2.[CauseCodeName],
		MCauseCode=t2.MCauseCode,
		CauseStatusID=t2.CauseStatusID,
		ModifiedDate=GETDATE(),ModifiedBy=@CreatedBy
	         FROM [AVL].[DEBT_MAP_CauseCode] t1
			 JOIN #CauseCodeList t2 ON t1.CauseID=t2.CauseId AND  t2.CauseId<>0

			
	UPDATE CC 
		SET CauseStatusID = @ClusterID
	FROM [AVL].[DEBT_MAP_CauseCode]  CC	
		WHERE CC.ProjectID=@ProjectID
		AND CC.CauseStatusID IS NULL

	UPDATE AVL.MAS_ProjectMaster set HasCCITSMTool = @ITSMCC WHERE ProjectID = @ProjectID
	
     
	
	 SET @result=1
	 COMMIT TRANSACTION
     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_AddCauseCodeDetails] ', @ErrorMessage, 0 ,@CustomerID
		  SET @result=1
	 END CATCH
	
	SET NOCOUNT OFF;
	SELECT @result AS 'Result'
END
