/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[DataDictionaryDetailsToTemp]
	 @ProjectID int =null,
	 @ApplicationID int =null,
	  @EmployeeID nvarchar(50),
	 @DataDictionaryDetailsUpload DataDictionaryDetailsUpload READONLY  
AS
BEGIN
		SET NOCOUNT ON;
	TRUNCATE TABLE [dbo].[DataDictionaryTemp]
	--select * from DataDictionaryTemp
	INSERT INTO [dbo].[DataDictionaryTemp]
	( 
	ApplicationName,
	CauseCode,
	ResolutionCode,
	DebtCategory,
	AvoidableFlag,
	ResidualFlag,
	ReasonForResidual,
	ExpectedCompletionDate,
	ProjectID,
	ApplicationID
	)
	SELECT
	ApplicationName,
	CauseCode,
	ResolutionCode,
	DebtCategory,
	AvoidableFlag,
	ResidualFlag,
	ReasonForResidual,
	ExpectedCompletionDate,
	ProjectID,
	ApplicationID

	from @DataDictionaryDetailsUpload
	WHERE ApplicationName IS NOT NULL AND CauseCode IS NOT NULL AND ResolutionCode IS NOT NULL
	AND DebtCategory IS NOT NULL AND AvoidableFlag IS NOT NULL AND ResidualFlag IS NOT NULL

	Exec [AVL].[UploadAndUpdateDataDictionary] @ProjectID ,null,@EmployeeID
	SET NOCOUNT OFF;
	 
END
