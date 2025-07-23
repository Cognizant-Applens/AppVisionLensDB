/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018]   [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE   PROCEDURE [dbo].[AlmTrnRelaeseDetailsLoad] (@ReleaseId NVARCHAR(100),  
      @ReleaseName NVARCHAR(250),  
      @ReleaseDescription NVARCHAR(MAX),  
      @StatusId INT,  
      @PlannedStartDate DATETIME,  
      @PlannedEndDate DATETIME,  
      @ProjectId BIGINT,  
      @IsDeleted BIT,  
      @UserId NVARCHAR(50))  
AS   

BEGIN TRY  

	Declare @isReleaseDetailCheck NVARCHAR(250) 
	SET @isReleaseDetailCheck = (SELECT top 1 ReleaseId FROM ADM.ALM_TRN_Release_Details WITH(NOLOCK) 
										WHERE ReleaseId =@ReleaseId 
											AND IsDeleted = @IsDeleted 
											AND ProjectId = @ProjectId)  
	if (@isReleaseDetailCheck is null)  
	BEGIN  
	  INSERT INTO ADM.ALM_TRN_Release_Details (ReleaseId,  
		   ReleaseName,  
		   ReleaseDescription,  
		   StatusId,  
		   PlannedStartDate,  
		   PlannedEndDate,  
		   ProjectId,  
		   IsDeleted,  
		   CreatedBy,  
		   CreatedDate)  
		VALUES (@ReleaseId,  
		  @ReleaseName,  
		  @ReleaseDescription,  
		  @StatusId,  
		  CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, @PlannedStartDate))),  
		  CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, @PlannedEndDate))),  
		  @ProjectId,  
		  @IsDeleted,  
		  @UserId,  
		  GETDATE())  
   
  END  
  ELSE  
  BEGIN 
	
	   UPDATE ADM.ALM_TRN_Release_Details SET   
		 ReleaseId = @ReleaseId,  
		 ReleaseName = @ReleaseName,  
		 ReleaseDescription = @ReleaseDescription,  
		 StatusId = @StatusId,  
		 PlannedStartDate = CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, @PlannedStartDate))),  
		 PlannedEndDate = CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, @PlannedEndDate))),  
		 ProjectId= @ProjectId,  
		 IsDeleted= @IsDeleted,  
		 ModifiedBy = @UserId,  
		 ModifiedDate =GETDATE()  
		WHERE ReleaseId =@ReleaseId 
			AND IsDeleted = @IsDeleted 
			AND ProjectId = @ProjectId 
		
  END  
 END TRY
 BEGIN CATCH    

  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AlmTrnRelaeseDetailsLoad] ', @ErrorMessage, @ProjectID  
    
END CATCH
