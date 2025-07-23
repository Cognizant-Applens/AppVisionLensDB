/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[ML_MLGetPatternOccurence]

(

@TicketPattern NVARCHAR(200),
@subPattern NVARCHAR(200),
@AdditionalTextPattern NVARCHAR(200),
@AdditionalTextSubPattern NVARCHAR(200),
@projectID NVARCHAR(200 )=NULL,
@AppID NVARCHAR(MAX)=NULL,
@causeCodeId int = 0,
@ResolutionCodeID int = 0

)

AS
BEGIN
BEGIN TRY
SELECT ITEM INTO #tempid FROM split(@AppID,',')

SELECT distinct

	        0 as ID,
        	ISNULL(MV.ApplicationID,0) as ApplicationID,

			ISNULL(AM.ApplicationName,'') AS ApplicationName,

		    MV.TicketPattern,
			case when mv.subPattern = '0' then 'N/A' else ISNULL(mv.subPattern,'N/A') end AS subPattern,
						case when mv.additionalPattern = '0' then 'N/A' else ISNULL(mv.additionalPattern,'N/A') end AS additionalPattern,
			case when mv.additionalSubPattern ='0' then 'N/A' else ISNULL(mv.additionalSubPattern,'N/A') end AS additionalSubPattern,

			ISNULL(MV.MLDebtClassificationID,0) AS MLDebtClassificationID,

			ISNULL(AFM.[DebtClassificationName],'') AS MLDebtClassificationName,

			ISNULL(MV.MLResidualFlagID,0) AS MLResidualCodeID,

			ISNULL(AFMM.[ResidualDebtName],'') AS MLResidualFlagName,

			ISNULL(MV.MLAvoidableFlagID,0) AS MLAvoidableFlagID,

			ISNULL(AFMF.[AvoidableFlagName],'') AS MLAvoidableFlagName,

			

			ISNULL(MV.MLCauseCodeID,0) AS MLCauseCodeID,



			ISNULL(DCC.[CauseCode],'') AS MLCauseCodeName,

			isnull(MV.MLResolutionCode,'') AS MLResolutionCodeID,

			isnull(DRC.ResolutionCode,'') AS MLResolutionCodeName,
		

			MV.TicketOccurence as 'TicketOccurence'	,

			MV.MLAccuracy as 'MLAccuracy'

			FROM AVL.ML_TRN_MLPatternValidation MV

			LEFT JOIN AVL.[APP_MAS_ApplicationDetails] AM  ON MV.ApplicationID=AM.ApplicationID LEFT JOIN AVL.BusinessClusterMapping BCM

			ON AM.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND BCM.IsDeleted=0 

			INNER JOIN #tempid t ON t.item = MV.ApplicationID

			
			Left join [AVL].[APP_MAP_ApplicationProjectMapping] AP ON  MV.ProjectID=AP.ProjectID AND AP.APPLICATIONID=MV.APPLICATIONID

			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM ON MV.MLDebtClassificationID= AFM.[DebtClassificationID]

			LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMM ON MV.MLResidualFlagID= AFMM.[ResidualDebtID]



			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF ON MV.MLAvoidableFlagID= AFMF.[AvoidableFlagID]



			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC ON MV.MLCauseCodeID=DCC.CauseID AND DCC.ProjectID=@ProjectID AND DCC.IsDeleted=0

			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC2 ON MV.MLCauseCodeID=DCC2.[CauseID] AND DCC2.ProjectID=@ProjectID AND DCC2.IsDeleted=0

			

			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM1 ON MV.MLDebtClassificationID= AFM1.[DebtClassificationID]

			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF2 ON MV.MLAvoidableFlagID= AFMF2.[AvoidableFlagID]

			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM3 ON MV.MLDebtClassificationID= AFM3.[DebtClassificationID]

			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF4 ON MV.MLAvoidableFlagID= AFMF4.[AvoidableFlagID]

			LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMF5 ON MV.MLResidualFlagID= AFMF5.[ResidualDebtID]

			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC1 ON MV.MLCauseCodeID=DCC1.[CauseID] AND DCC1.ProjectID=@ProjectID AND DCC1.IsDeleted=0

			LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC ON MV.MLResolutionCode=DRC.[ResolutionID] AND DRC.ProjectID=@ProjectID AND DRC.IsDeleted=0

			where MV.projectid = @ProjectID AND MV.IsDeleted=0 AND 
       	ltrim(rtrim(MV.TicketPattern)) = ltrim(rtrim(@TicketPattern))
		and ltrim(rtrim(MV.subPattern)) = case when @subPattern = '' then '0'  else ltrim(rtrim(@subPattern)) end
		and   ltrim(rtrim(ISNULL(MV.additionalPattern,@AdditionalTextPattern))) = case when @AdditionalTextPattern = '' then '0'  else ltrim(rtrim(@AdditionalTextPattern)) end
			and ltrim(rtrim(ISNULL(MV.additionalSubPattern,@AdditionalTextSubPattern))) = case when @AdditionalTextSubPattern = '' then '0' else ltrim(rtrim(@AdditionalTextSubPattern)) end
		     and isnull(mv.MLCauseCodeID,0) = @causeCodeId 
			 and isnull(mv.MLResolutionCode,0) = @ResolutionCodeID

			--AND MV.TicketOccurence >0

		--	and BCM.CustomerID=@CustomerID 

			and AM.IsActive=1



			ORDER BY TicketOccurence DESC

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_MLGetPatternOccurence_CL] ', @ErrorMessage, @projectID,@AppID
		
END CATCH
END
