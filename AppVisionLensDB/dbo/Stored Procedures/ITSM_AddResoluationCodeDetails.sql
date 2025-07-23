/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ITSM_AddResoluationCodeDetails] 
(	     
@ProjectID INT,
@ITSMResoluationCodeList TVP_ITSMResoluationCodeList READONLY,
@CustomerID int=null,
@CreatedBy VARCHAR(100)=NULL,
@RCItsmTool VARCHAR(5) = NULL
)
AS

BEGIN
DECLARE @result bit=0,@ITSMScreenId INT=8,@IsCognizant INT,@ClusterID INT,@ITSMRC BIT = 1;;
    SET NOCOUNT ON; 
	BEGIN TRY
	  BEGIN TRANSACTION

	   SELECT @ClusterID=ClusterID FROM MAS.Cluster(NOLOCK) WHERE ClusterName='NA' AND CategoryID = 2

	   SELECT 	@IsCognizant=C.IsCognizant FROM AVL.Customer C WHERE CustomerID=@CustomerID

	   SELECT [ResolutionID], [ResolutionStatusID], [ResolutionCode], [MResolutionCode] INTO #ResolutionCodeList FROM @ITSMResoluationCodeList

	    SELECT @ITSMRC = 0 FROM #ResolutionCodeList WHERE @RCItsmTool = 'N'

	   UPDATE #ResolutionCodeList SET [ResolutionStatusID] = @ClusterID WHERE [ResolutionStatusID] IS NULL OR [ResolutionStatusID] = 0 

 IF @IsCognizant=1
	   BEGIN 
	   SET @ITSMScreenId=9
	   END
	   ELSE
	     BEGIN
		 SET @ITSMScreenId=8
		 END
	    IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=@ITSMScreenId and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
begin
INSERT INTO [AVL].[PRJ_ConfigurationProgress] (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
values(@CustomerID,@ProjectID,2,@ITSMScreenId,100,0,@CreatedBy,getdate())
end  
else
begin
update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@CreatedBy,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=@ITSMScreenId and customerid=@CustomerID and screenid=2 and IsDeleted=0 

end

 
	  INSERT INTO [AVL].[DEBT_MAP_ResolutionCode] 
		 (ResolutionCode,MResolutionCode,ResolutionStatusID,ProjectID,IsDeleted,CreatedDate,CreatedBy)
		   SELECT ResolutionCode,[MResolutionCode],ResolutionStatusID,@ProjectID,0,GETDATE(),@CreatedBy
		    FROM #ResolutionCodeList WHERE ResolutionId=0


       UPDATE [AVL].[DEBT_MAP_ResolutionCode]
	   SET ResolutionCode=t2.ResolutionCode,MResolutionCode=t2.[MResolutionCode],
	   ResolutionStatusID=t2.ResolutionStatusID,
	   ModifiedDate=GETDATE(),ModifiedBy=@CreatedBy
	         FROM [AVL].[DEBT_MAP_ResolutionCode] t1
			 JOIN #ResolutionCodeList t2 ON t1.ResolutionID=t2.ResolutionId AND  t2.ResolutionId<>0


	UPDATE RC
		SET ResolutionStatusID = @ClusterID
	FROM [AVL].[DEBT_MAP_ResolutionCode]  RC	
		WHERE RC.ProjectID=@ProjectID
		AND RC.ResolutionStatusID IS NULL


	UPDATE AVL.MAS_ProjectMaster set HasRCITSMTool = @ITSMRC WHERE ProjectID = @ProjectID

		
	 SET @result=1
	 COMMIT TRANSACTION
     END TRY

	 BEGIN CATCH
	     DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError ' [dbo].[ITSM_AddResoluationCodeDetails]', @ErrorMessage, 0 ,@CustomerID
		  SET @result=1
	 END CATCH
	
	SET NOCOUNT OFF;
	SELECT @result AS 'Result'
END
