/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CL_GetPatternOccurence] 

(
@projectID BIGINT,
@AppID BIGINT,
@causeCodeId BIGINT,
@ResolutionCodeID BIGINT,
@TicketPattern NVARCHAR(300),
@TicketSubPattern NVARCHAR(300)=NULL,
@AddiPattern NVARCHAR(300)=NULL,
@AddiSubPattern NVARCHAR(300)=NULL
)
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	SELECT TPV.ID
	,TPV.ContLearningID
	,ISNULL(MDC.DebtClassificationName,'') DebtClassificationName
	,ISNULL(MRD.ResidualDebtName,'') ResidualDebtName
	,ISNULL(MAF.AvoidableFlagName,'') AvoidableFlagName
	,TPV.TicketOccurence
	,TPV.MLAccuracy
	,ISNULL(TPV.MLDebtClassificationID,'0') MLDebtClassificationID
	,ISNULL(TPV.MLResidualFlagID,'0') MLResidualFlagID
	,ISNULL(TPV.MLAvoidableFlagID,'0') MLAvoidableFlagID
	,TPV.TicketPattern
	,CASE WHEN TPV.TicketSubPattern = '0' THEN 'N/A' ELSE ISNULL(TPV.TicketSubPattern,'N/A') END AS TicketSubPattern
	,CASE WHEN TPV.AdditionalPattern = '0' THEN 'N/A' ELSE ISNULL(TPV.AdditionalPattern,'N/A') END AS AdditionalPattern
	,CASE WHEN TPV.AdditionalSubPattern ='0' THEN 'N/A' ELSE ISNULL(TPV.AdditionalSubPattern,'N/A') END AS AdditionalSubPattern	
	,TPV.ApplicationID
	,TPV.MLResolutionCodeID
	,TPV.MLCauseCodeID
	,MCC.CauseCode AS MLCauseCodeName
	,MRC.ResolutionCode AS MLResolutionCodeName
	,AD.ApplicationName
	FROM [AVL].[CL_TRN_PatternValidation] (NOLOCK) TPV
	LEFT JOIN [AVL].[DEBT_MAS_DebtClassification](NOLOCK) MDC ON TPV.MLDebtClassificationID = MDC.DebtClassificationID
	LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] (NOLOCK) MRD ON TPV.MLResidualFlagID = MRD.ResidualDebtID
	LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] (NOLOCK) MAF ON TPV.MLAvoidableFlagID = MAF.AvoidableFlagID
	LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) MCC ON TPV.MLCauseCodeID = MCC.CauseID
	LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) MRC ON TPV.MLResolutionCodeID = MRC.ResolutionID
	LEFT JOIN AVL.APP_MAS_ApplicationDetails (NOLOCK) AD ON TPV.ApplicationID = AD.ApplicationID 
	 WHERE TPV.ProjectID = @projectID AND TPV.ApplicationID = @AppID
	AND MLCauseCodeID = @causeCodeId AND MLResolutionCodeID  = @ResolutionCodeID 
	AND TicketPattern = LTRIM(RTRIM(@TicketPattern)) 
	AND ISNULL(TicketSubPattern,'') = CASE WHEN @TicketSubPattern = '' THEN '0'  ELSE LTRIM(RTRIM(@TicketSubPattern)) END
	AND ISNULL(AdditionalPattern,'') = CASE WHEN @AddiPattern = '' THEN '0'  ELSE LTRIM(RTRIM(@AddiPattern)) END
	 AND ISNULL(AdditionalSubPattern,'') = CASE WHEN @AddiSubPattern = '' THEN '0'  ELSE LTRIM(RTRIM(@AddiSubPattern)) END
	AND TPV.IsDeleted = 0 AND TPV.TicketOccurence > 0
	AND ISNULL(TPV.MLDebtClassificationID,0) <> 0 AND ISNULL(TPV.MLAvoidableFlagID,0) <> 0 AND ISNULL(TPV.MLResidualFlagID,0) <> 0
	AND ISNULL(TPV.MLCauseCodeID,0) <> 0 AND ISNULL(TPV.MLResolutionCodeID,0) <> 0
	

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[CL_GetPatternOccurence]', @ErrorMessage, @projectID,@AppID
		
END CATCH
END
