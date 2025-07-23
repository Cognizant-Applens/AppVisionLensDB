/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- Author:		 Dhivya        
-- Create Date:  Jan 30 2019
-- Description:  Add a singlrData Dictionary pattern 
-- DB Name :     AppVisionlens
-- ============================================================================ 

CREATE PROCEDURE [AVL].[DD_AddDataDictionary]
(
 @applicationID INT, 
 @reasonForResidualID INT, 
 @avoidableFlagID INT, 
 @debtClassificationID INT,
 @residualDebtID INT, 
 @causeCodeID INT, 
 @resolutionCodeID INT,
 @expectedCompletionDate NVARCHAR(100),
 @customerID BIGINT,
 @employeeID NVARCHAR(50),
 @projectID INT,
 @EffectiveDate DATE
)
AS
BEGIN
BEGIN TRY
	DECLARE @Result NVARCHAR(100)
	DECLARE @EffDate DATE
	IF(@expectedCompletionDate ='')
	BEGIN
	SET @expectedCompletionDate=NULL
	END

	IF EXISTS (SELECT 1 FROM AVL.MAS_ProjectDebtDetails(NOLOCK) WHERE ProjectID=@ProjectID 
					   AND IsDDAutoClassifiedDate IS NOT NULL AND IsDeleted=0)
				BEGIN		
					SET @EffDate=GETDATE()
				END
			ELSE
				BEGIN
					SET @EffDate=NULL
				END

	IF EXISTS (SELECT
			1
		FROM AVL.Debt_MAS_ProjectDataDictionary PDD
		JOIN AVL.Customer C
			ON C.CustomerID = @customerID
			AND PDD.ApplicationID = @ApplicationID
			AND PDD.ProjectID = @projectID
			AND PDD.CauseCodeID = @causeCodeID
			AND PDD.ResolutionCodeID = @resolutionCodeID AND ISNULL(PDD.IsDeleted,0)=0) 		
			BEGIN
	SET @Result = 'Already Exists'
	END
	 ELSE 
	 BEGIN
	INSERT INTO AVL.Debt_MAS_ProjectDataDictionary (ApplicationID, ReasonForResidual, AvoidableFlagID, DebtClassificationID, ResidualDebtID, CauseCodeID, ResolutionCodeID, ExpectedCompletionDate, CreatedBy, CreatedDate, ProjectID, IsDeleted,EffectiveDate)
		VALUES (@applicationID, @reasonForResidualID, @avoidableFlagID, @debtClassificationID, @residualDebtID, @causeCodeID, @resolutionCodeID, @expectedCompletionDate, @employeeID, GETDATE(), @projectID, 0,
		@EffDate)
	SET @Result = 'Added Sucessfully'
	END
	SELECT @result AS RESULT

	DECLARE @SaveCauseCodeMapping AS [AVL].[SaveCauseCodeMapping] 
	INSERT INTO @SaveCauseCodeMapping
	SELECT  @causeCodeID ,@resolutionCodeID 
	WHERE  @causeCodeID IS NOT NULL AND @resolutionCodeID IS NOT NULL


	EXEC [AVL].[SaveCauseCodeMapingDetails] 'DD',@projectID,@SaveCauseCodeMapping,@employeeID

END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()

		EXEC AVL_InsertError '[AVL].[DD_AddDataDictionary]', @ErrorMessage, @employeeID, @customerID 
		
	END CATCH  
	END
