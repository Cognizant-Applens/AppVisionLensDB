/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Effort_UpdateTrackActivityWise] 
	@CustomerID nvarchar(max),
	@IsTrackActivityWise bit,	
	@ProjectID int,
	@UserID NVARCHAR(50)
AS
BEGIN
	Update AVL.Customer set IsEffortTrackActivityWise = @IsTrackActivityWise, ModifiedDate = getdate(),ModifiedBy = @UserID
	where IsDeleted=0 and CustomerID = @CustomerID

	IF EXISTS (SELECT 1 FROM AVL.TK_PRJ_ProjectServiceActivityMapping WHERE ProjectID = @ProjectID AND IsDeleted = 0)
		BEGIN
			 IF(not EXISTS(SELECT ITSMScreenId from [AVL].[PRJ_ConfigurationProgress] where ITSMScreenId=3 and projectid=@ProjectID and IsDeleted=0 and  customerid=@CustomerID and screenid=2))
				begin
				  INSERT INTO [AVL].[PRJ_ConfigurationProgress] (CustomerID,ProjectID,ScreenID,ITSMScreenId,CompletionPercentage,IsDeleted,CreatedBy,CreatedDate)
				  values(@CustomerID,@ProjectID,2,3,100,0,@UserID,getdate())
				end  
			else
				begin
					update [AVL].[PRJ_ConfigurationProgress]  set ModifiedBy=@UserID,ModifiedDate=getdate() where ProjectID=@ProjectID and ITSMScreenId=3 and customerid=@CustomerID and screenid=2 and IsDeleted=0 
				end
		END
	SELECT 1 AS Result
END
