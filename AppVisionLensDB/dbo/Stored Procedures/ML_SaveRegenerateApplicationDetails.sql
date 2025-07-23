/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_SaveRegenerateApplicationDetails] (@ProjectID         INT, 
                                                             @lstRegenerateApps AVL.RegenerateApplicationDetails READONLY,
                                                             @UserId            NVARCHAR(10)=NULL,
                                                             @CustomerID        INT) 
AS 
  BEGIN
 
      BEGIN TRY 
          BEGIN TRAN
 

          DECLARE @initialLearningID INT

INSERT INTO [AVL].[ML_PRJ_INITIALLEARNINGSTATE] (ProjectID, SentBy, SentOn, CreatedBy, CreatedDate, IsDeleted, IsDartTicket, IsSDTicket)
	VALUES (@ProjectID, @UserId, GETDATE(), @UserId, GETDATE(), 0, 1, 1)
SET @InitialLearningID = (SELECT SCOPE_IDENTITY())

IF EXISTS (SELECT
		projectid
	FROM AVL.ML_TRN_RegeneratedApplicationDetails
	WHERE ProjectID = @ProjectID
	AND IsDeleted = 0) BEGIN
UPDATE AVL.ML_TRN_RegeneratedApplicationDetails
SET IsDeleted = 1
WHERE ProjectID = @ProjectID
END

--inserting selected app details from regenerate popup 
INSERT INTO AVL.ML_TRN_RegeneratedApplicationDetails (InitialLearningID,
CustomerID,
ProjectID,
ApplicationID,
PortfolioID,
AppGroupID,
CreatedBy,
CreatedDate,
IsDeleted,
IsMLSignOff,
FromDate,
ToDate)
	SELECT
		@initialLearningID
		,@CustomerID
		,@ProjectID
		,LRA.ApplicationID
		,Portfolio.BusinessClusterMapID AS PortfolioID
		,AG.BusinessClusterMapID AS AppGroupID
		,@UserId
		,GETDATE()
		,0
		,0
		,DATEADD(MONTH, -6, GETDATE() - 1)
		,GETDATE() - 1
	FROM @lstRegenerateApps LRA INNER JOIN AVL.APP_MAS_ApplicationDetails AD
	ON AD.ApplicationID= LRA.ApplicationID INNER JOIN AVL.BusinessClusterMapping AG
	ON AD.SubBusinessClusterMapID=AG.BusinessClusterMapID
	INNER JOIN AVL.BusinessClusterMapping Portfolio ON Portfolio.BusinessClusterMapID = AG.ParentBusinessClusterMapID

--Updating isregenerated flag and Initial Learning State Table Columns,startdate by default is updated as 6 months from getdate-1 which can be changed from ui 
UPDATE AVL.ML_PRJ_InitialLearningState
SET	IsRegenerated = 1
	,IsNoiseEliminationSentorReceived = NULL
	,IsMLSentOrReceived = NULL
	,IsSamplingInProgress = NULL
	,IsSamplingSentOrReceived = NULL
	,StartDate = DATEADD(MONTH, -6, GETDATE() - 1)
	,EndDate = GETDATE() - 1
WHERE ID = @initialLearningID
AND ProjectID = @ProjectID

COMMIT TRAN

END TRY BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

SELECT
	@ErrorMessage = ERROR_MESSAGE()

ROLLBACK TRAN

--INSERT Error     
EXEC Avl_inserterror	'[dbo].[ML_SaveRegenerateApplicationDetails]'
						,@ErrorMessage
						,@ProjectID
						,0
END CATCH
END
