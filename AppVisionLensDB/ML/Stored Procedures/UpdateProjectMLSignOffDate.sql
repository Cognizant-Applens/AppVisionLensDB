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
-- Author:		663960
-- Create date: 03/19/2020
-- Description:	Update Project ML SignOff Date
-- =============================================
CREATE PROCEDURE [ML].[UpdateProjectMLSignOffDate]
@ProjectID BIGINT, 
@UserID NVARCHAR(50), 
@MLSignOffDate datetime
AS
BEGIN
DECLARE @NextDayID INT = 5;
DECLARE @JobDate datetime; 
UPDATE AVL.MAS_ProjectDebtDetails 
	SET MLSignOffDate=@MLSignOffDate,
		IsMLSignOff='1',
		AutoClassificationDate = @MLSignOffDate,ModifiedBy=@UserID,ModifiedDate=GETDATE()
	WHERE ProjectID=@ProjectID;
	 IF NOT EXISTS(SELECT 1 
                        FROM   ML.CL_PROJECTJOBDETAILS (NOLOCK) 
                        WHERE  ProjectID = @ProjectID) 
            BEGIN 			  
				SET @JobDate= DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, @MLSignOffDate) / 7) * 7 + 7, @NextDayID)
				INSERT INTO ML.CL_ProjectJobDetails (ProjectID,JobDate, StatusForJob, CreatedBy , CreatedDate , IsDeleted)
				VALUES(@ProjectID,@JobDate,0,'SYSTEM',GETDATE(),0);
			END 
END
