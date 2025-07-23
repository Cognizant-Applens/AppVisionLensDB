/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[SetInfraprogress] 
	
	@CustomerID bigint,
	@USERID nvarchar(50),
	@ScreenID int ,
	@CompletionPercentage bigint,
	@ProjectID bigint=NULL,
	@ITSMScreenID int = Null
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	MERGE INTO avl.prj_configurationprogress CP
	USING (select @ProjectID AS ProjectID,@CustomerID AS CustomerID,@ScreenID AS ScreenID,@ITSMScreenID AS ITSMScreenID) CP1
	ON CP.CustomerID = CP1.CustomerID and  CP.PROJECTID = CP1.ProjectID AND CP.ScreenID = CP1.ScreenID AND CP.ITSMScreenId = CP1.ITSMScreenID
	WHEN MATCHED THEN
	UPDATE SET 
	CompletionPercentage                = ISNULL(@CompletionPercentage,CP.CompletionPercentage),
	ModifiedBy                          = @USERID,
	ModifiedDate                        = GETDATE()			   

	WHEN NOT MATCHED THEN

	INSERT(
	CustomerID,
	ProjectID,
	ScreenID,
	ITSMScreenId,
	CompletionPercentage,
	IsDeleted,
	CreatedBy,
	CreatedDate,
	ModifiedBy,
	ModifiedDate,
	IsSeverity,
	IsDefaultPriority
	) 
	VALUES
	(
		@CustomerID,
		@ProjectID,
		@ScreenID,
		@ITSMScreenID,
		@CompletionPercentage,
		0,
		@USERID,
		GETDATE(),
		NULL,
		NULL,
		NULL,
		NULL

	);

END TRY  

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError '[AVL].[SetInfraprogress]', @ErrorMessage, @ProjectID, @CustomerID 
		
	END CATCH  

END
