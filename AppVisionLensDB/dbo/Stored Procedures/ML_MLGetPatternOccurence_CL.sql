/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_MLGetPatternOccurence_CL]

(

@TicketPattern NVARCHAR(200),

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

			ISNULL(MV.SMEDebtClassificationID,0) AS SMEDebtClassificationID,

			ISNULL(AFM.[DebtClassificationName],'') AS SMEDebtClassificationName,

			ISNULL(MV.SMEResidualCodeID,0) AS SMEResidualCodeID,

			ISNULL(AFMM.[ResidualDebtName],'') AS SMEResidualFlagName,

			ISNULL(MV.SMEAvoidableFlagID,0) AS SMEAvoidableFlagID,

			ISNULL(AFMF.[AvoidableFlagName],'') AS SMEAvoidableFlagName,

			

			ISNULL(MV.SMECauseCodeID,0) AS SMECauseCodeID,



			ISNULL(DCC.[CauseCode],'') AS SMECauseCodeName,

			isnull(MV.SMEResolutionCodeID,'') AS SMEResolutionCodeID,

		

			PatternOccurence as 'TicketOccurence'	

				

	     	FROM AVL.CL_PatterOccurence(NOLOCK) MV

			LEFT JOIN AVL.[APP_MAS_ApplicationDetails] AM  ON MV.ApplicationID=AM.ApplicationID LEFT JOIN AVL.BusinessClusterMapping BCM

			ON AM.SubBusinessClusterMapID=BCM.BusinessClusterMapID AND BCM.IsDeleted=0 

			INNER JOIN #tempid t ON t.item = MV.ApplicationID

			--INNER JOIN AVL.ML_TRN_MLPatternValidation_CL cl ON 	ltrim(rtrim(cl.TicketPattern)) = ltrim(rtrim(mv.TicketPattern)) 
			-- and cl.isdeleted = 0 and cl.ApplicationID = mv.ApplicationID and cl.ProjectID = mv.ProjectID 

		

			--Left join [AVL].[APP_MAP_ApplicationProjectMapping] AP ON  MV.ProjectID=AP.ProjectID AND AP.APPLICATIONID=MV.APPLICATIONID



		



			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM ON MV.SMEDebtClassificationID= AFM.[DebtClassificationID]

			LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMM ON MV.SMEResidualCodeID= AFMM.[ResidualDebtID]



			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF ON MV.SMEAvoidableFlagId= AFMF.[AvoidableFlagID]



			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC ON MV.SMECauseCodeID=DCC.CauseID AND DCC.ProjectID=@ProjectID AND DCC.IsDeleted=0

			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC2 ON MV.SMECauseCodeID=DCC2.[CauseID] AND DCC2.ProjectID=@ProjectID AND DCC2.IsDeleted=0

			

			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM1 ON MV.SMEDebtClassificationID= AFM1.[DebtClassificationID]

			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF2 ON MV.SMEAvoidableFlagID= AFMF2.[AvoidableFlagID]

			LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] AFM3 ON MV.SMEDebtClassificationID= AFM3.[DebtClassificationID]

			LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] AFMF4 ON MV.SMEAvoidableFlagID= AFMF4.[AvoidableFlagID]

			LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] AFMF5 ON MV.SMEResidualCodeID= AFMF5.[ResidualDebtID]

			LEFT JOIN [AVL].[DEBT_MAP_CauseCode] DCC1 ON MV.SMECauseCodeID=DCC1.[CauseID] AND DCC1.ProjectID=@ProjectID AND DCC1.IsDeleted=0

			--LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] DRC ON MV.MLResolutionCodeID=DRC.[ResolutionID] AND DRC.ProjectID=@ProjectID AND DRC.IsDeleted=0

			where MV.projectid = @ProjectID AND MV.IsDeleted=0 AND 
        	ltrim(rtrim(MV.TicketPattern)) = ltrim(rtrim(@TicketPattern)) and mv.SMECauseCodeID = @causeCodeId and mv.SMEResolutionCodeID = @ResolutionCodeID

			--AND MV.TicketOccurence >0

			--and BCM.CustomerID=@CustomerID 

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
