/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[CSVdatatable_ML_TicketUpload_SharePath] 
@projectID int
AS
BEGIN
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @CountForAddPattern BIGINT
	DECLARE @AdditionalText NVARCHAR(MAX);

select @CountForAddPattern=COUNT(DISTINCT ID) from AVL.ML_TRN_MLPatternValidation where ProjectID=@projectid and IsDeleted=0 and IsApprovedOrMute=1
and additionalPattern<>'0'
IF(@CountForAddPattern>0)
BEGIN

SELECT  @AdditionalText=OptionalFields FROM AVL.ML_MAS_OptionalFields WHERE ID=1 AND IsDeleted=0
END
ELSE
BEGIN
SELECT @AdditionalText='NA' 
--AS optionalfields
END


	--DECLARE @AdditionalText NVARCHAR(MAX);
	--SET @AdditionalText= (SELECT OP.OptionalFields FROM AVL.ML_MAP_OptionalProjMapping OPM 
	--JOIN AVL.ML_MAS_OptionalFields OP ON OPM.OptionalFieldID=OP.ID WHERE OPM.ProjectId=@projectID AND OPM.IsActive=1)

	
	SELECT td.ProjectID AS ProjectID ,TD.ApplicationID,TD.TicketID AS [TicketID],
	CASE WHEN TD.TicketDescription = NULL THEN '' ELSE TD.TicketDescription  END AS TicketDescription,

	CASE WHEN @AdditionalText='Resolution Remarks' THEN TD.ResolutionRemarks 
		WHEN @AdditionalText='Ticket Summary' THEN TD.TicketSummary
			 WHEN @AdditionalText='Comments' THEN TD.Comments 
				 WHEN @AdditionalText='NA' THEN 'NA' END AS AdditionalText,

	CASE WHEN CP.IsOptionalField = 1 THEN 'Resolution Remarks' ELSE 'NA' END AS AdditionalTextFlag,	    
	TD.CauseCodeMapID AS CauseCodeID,TD.ResolutionCodeMapID AS ResolutionCodeID 
	from AVL.TK_TRN_TicketDetail AS TD	
	INNER JOIN ML.InfraConfigurationProgress CP ON TD.ProjectID = CP.ProjectID AND CP.IsDeleted = 0 
	INNER JOIN AVL.TK_MLClassification_TicketUpload AS MLC
	ON MLC.[Ticket ID] = TD.TicketID AND MLC.ProjectID =  TD.ProjectID AND TD.IsDeleted=0
	WHERE TD.ProjectID = @projectID


	--SELECT td.ProjectID AS EsaProjectID ,TD.ApplicationID,TD.TicketID AS [Ticket ID],
	--CASE WHEN TD.TicketDescription = NULL THEN '' ELSE TD.TicketDescription  END AS TicketDescription,
	--CASE WHEN OFS.OptionalFields = '' THEN 'NA' ELSE OFS.OptionalFields END AS AdditionalText,
	--TD.CauseCodeMapID AS CauseCodeID,TD.ResolutionCodeMapID AS ResolutionCodeID 
	
	--from AVL.TK_TRN_TicketDetail AS TD	
	--INNER join AVL.ML_MAP_OptionalProjMapping AS OPM on OPM.ProjectId = TD.ProjectID and OPM.IsActive =  1
	--INNER JOIN AVL.ML_MAS_OptionalFields AS OFS on OFS.ID = OPM.OptionalFieldID 
	--INNER JOIN AVL.TK_MLClassification_TicketUpload AS MLC ON MLC.[Ticket ID] = TD.TicketID AND MLC.ProjectID =  TD.ProjectID AND MLC.ISApprover=0
	
	--WHERE TD.ProjectID = @projectID


END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[CSVdatatable_ML_TicketUpload]', @ErrorMessage,@projectID 
END CATCH
END
