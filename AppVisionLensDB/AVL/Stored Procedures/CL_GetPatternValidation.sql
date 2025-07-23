/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CL_GetPatternValidation] 
(
	@ProjectID NVARCHAR(200)
)
AS
BEGIN   
BEGIN TRY  
 SET NOCOUNT ON; 
 
 DECLARE @ISMLSignedOff INT  
 DECLARE @TicketCount INT  
 DECLARE @JobID INT  
 DECLARE @JobFromDate NVARCHAR(100)  
 DECLARE @JobToDate NVARCHAR(100) 
 
 SET @ISMLSignedOff = (SELECT TOP 1 ProjectDebtId FROM AVL.MAS_ProjectDebtDetails  
					   WHERE ProjectID = @ProjectID AND IsDeleted = 0 AND IsMLSignOff = '1' 
						AND MLSignOffDate IS NOT NULL)  
 
 SET @JobID = (SELECT TOP 1 ID FROM avl.CL_ProjectJobDetails WHERE ProjectID = @ProjectID ORDER BY ID)   
 
 SELECT TOP 1 @JobFromDate=PJD.StartDateTime ,@JobToDate=PJD.JobDate
					 FROM AVL.CL_ProjectJobDetails PJD  
					 INNER JOIN AVL.CL_PRJ_ContLearningState PCS 
						ON PCS.ProjectJobID = PJD.ID AND PCS.ProjectID = PJD.ProjectID  
					 WHERE PJD.ProjectID = @ProjectID AND PJD.ID = @JobID
  
  SELECT   
	  TPV.ID  
	  ,TPV.ContLearningID  
	  ,TPV.ApplicationID AS ApplicationID  
	  ,AD.ApplicationName AS ApplicationName  
	  ,AT.ApplicationTypeID AS ApplicationTypeID  
	  ,AT.ApplicationTypename AS ApplicationTypeName  
	  ,MT.PrimaryTechnologyID AS TechnologyID  
	  ,MT.PrimaryTechnologyName AS TechnologyName  
	  ,CASE WHEN ISNULL(TPV.TicketPattern,'0') = '0' THEN 'N/A' ELSE TPV.TicketPattern  
	  END AS TicketPattern  
	  ,TPV.MLDebtClassificationID AS MLDebtClassificationID   
	  ,MDC.DebtClassificationName AS MLDebtClassificationName  
	  ,TPV.MLResidualFlagID  
	  ,MRD.ResidualDebtName AS MLResidualFlagName  
	  ,TPV.MLAvoidableFlagID   
	  ,MFV.AvoidableFlagName AS MLAvoidableFlagName  
	  ,TPV.MLCauseCodeID  
	  ,DCC.CauseCode AS MLCauseCodeName  
	  ,TPV.MLAccuracy  
	  ,TPV.TicketOccurence  
	  ,TPV.MLResolutionCodeID  
	  ,DRC.ResolutionCode AS MLResolutionCodeName   
	  ,ISNULL(TPV.IsApprovedOrMute,0) IsApprovedOrMute  
	  ,CASE WHEN ISNULL(TPV.TicketSubPattern,'0') = '0' THEN '' ELSE TPV.TicketSubPattern  
		END AS TicketSubPattern  
	  ,CASE WHEN ISNULL(TPV.AdditionalPattern,'0') = '0' THEN '' ELSE TPV.AdditionalPattern  
		END AS AdditionalPattern  
	  ,CASE WHEN ISNULL(TPV.AdditionalSubPattern,'0') = '0' THEN '' ELSE TPV.AdditionalSubPattern  
		END AS AdditionalSubPattern   
	  ,TPV.IsCLSignOff  
	  ,TPV.PatternsOrigin   
	  ,TPV.IsDefaultRuleSelected  
	  ,ISNULL(TPV.IsApprovedPatternsConflict,0) IsApprovedPatternsConflict  
	  ,CASE WHEN TPV.IsApprovedOrMute = 1 THEN 'Approved'  
		    WHEN TPV.IsApprovedOrMute = 2 THEN 'Mute'  
		    WHEN ISNULL(TPV.IsApprovedOrMute,0) = 0 THEN 'PendingReview'  
	   END AS ApprovedFlag  
   FROM [AVL].[CL_TRN_PatternValidation] (NOLOCK) TPV    
   LEFT JOIN AVL.[APP_MAS_ApplicationDetails] (NOLOCK) AD  
	ON TPV.ApplicationID = AD.ApplicationID  
   LEFT JOIN AVL.[APP_MAS_OwnershipDetails] (NOLOCK) AT 
	ON AD.CodeOwnerShip = AT.ApplicationTypeID  
   LEFT JOIN AVL.[APP_MAS_PrimaryTechnology] (NOLOCK) MT 
	ON AD.[PrimaryTechnologyID] = MT.[PrimaryTechnologyID]  
   LEFT JOIN [AVL].[DEBT_MAP_CauseCode] (NOLOCK) DCC 
	ON TPV.MLCauseCodeID = DCC.CauseID AND DCC.ProjectID = @ProjectID AND DCC.IsDeleted=0  
   LEFT JOIN [AVL].[DEBT_MAP_ResolutionCode] (NOLOCK) DRC 
	ON TPV.MLResolutionCodeID=DRC.ResolutionID AND DRC.ProjectID=@ProjectID AND DRC.IsDeleted=0  
   LEFT JOIN [AVL].[DEBT_MAS_DebtClassification] (NOLOCK) MDC 
	ON TPV.MLDebtClassificationID= MDC.DebtClassificationID  
   LEFT JOIN [AVL].[DEBT_MAS_AvoidableFlag] (NOLOCK) MFV 
	ON TPV.MLAvoidableFlagID= MFV.AvoidableFlagID  
   LEFT JOIN [AVL].[DEBT_MAS_ResidualDebt] (NOLOCK) MRD 
	ON TPV.MLResidualFlagID= MRD.ResidualDebtID  
   WHERE TPV.ProjectID = @ProjectID AND TPV.IsDeleted = 0 AND TPV.IsDefaultRuleSelected = 1   
	AND ISNULL(TPV.TicketPattern,'0') <> '0'
    AND ISNULL(TPV.MLDebtClassificationID,0) <> 0 AND ISNULL(TPV.MLAvoidableFlagID,0) <> 0 AND ISNULL(TPV.MLResidualFlagID,0) <> 0
	AND ISNULL(TPV.MLCauseCodeID,0) <> 0 AND ISNULL(TPV.MLResolutionCodeID,0) <> 0

 IF (@ISMLSignedOff > 0)  
 BEGIN  
						
    IF EXISTS (SELECT ProjectID FROM AVL.CL_PRJ_ContLearningState (NOLOCK) WHERE ProjectID = @ProjectID) 
    BEGIN 
	     SET @TicketCount = (SELECT TOP 1 ID FROM  [AVL].[CL_TRN_PatternValidation] (NOLOCK) TPV 
						WHERE TPV.ProjectID = @ProjectID AND TPV.IsDeleted = 0 AND TPV.IsDefaultRuleSelected = 1)

	     IF @TicketCount > 0   
	     BEGIN 
	
	     SELECT JSM.JobStatusMessage, @JobFromDate AS JobFromDate, @JobToDate AS JobToDate  
	     FROM AVL.CL_PRJ_ContLearningState (NOLOCK) CLS 
	     INNER JOIN AVL.CL_MAS_JobStatusMaster (NOLOCK) JSM  
		   ON CLS.PresentStatus = JSM.JobStatusID   
	     WHERE CLS.ProjectID = @ProjectID AND CLS.IsDeleted = 0 AND JSM.JobStatusID != 4  
	     ORDER BY CLS.ContLearningID DESC  

	     END  
	     ELSE   
	     BEGIN  

		    DECLARE @JobMessage VARCHAR(500)  
  
	        SELECT @JobMessage = JSM.JobStatusMessage   
	        FROM AVL.CL_PRJ_ContLearningState (NOLOCK) CLS 
		    INNER JOIN AVL.CL_MAS_JobStatusMaster (NOLOCK) JSM  
			    ON CLS.PresentStatus = JSM.JobStatusID   
	        WHERE CLS.ProjectID = @ProjectID AND CLS.IsDeleted = 0   
	        ORDER BY CLS.ContLearningID DESC  
		
		 IF ISNULL(@JobMessage, '') = ''   
		 BEGIN  

			SELECT JSM.JobStatusMessage, @JobFromDate AS JobFromDate, @JobToDate AS JobToDate 
			FROM AVL.CL_MAS_JobStatusMaster (NOLOCK) JSM 
			WHERE JSM.JobStatusID  = 10  

		 END 
		 ELSE
		 BEGIN

			SELECT @JobMessage AS JobStatusMessage
		
		END
	END  
 END
 ELSE
	   BEGIN
	       SELECT JobStatusMessage FROM AVL.CL_MAS_JobStatusMaster (NOLOCK) WHERE JobStatusID = 10
       END
 END 

 ELSE  
 BEGIN   
  
  SELECT JobStatusMessage  
  FROM AVL.CL_MAS_JobStatusMaster (NOLOCK)   
  WHERE IsDeleted = 0 AND JobStatusID = 9  
   
 END  
    
END TRY  
    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[dbo].[CL_GetPatternValidation] ', @ErrorMessage, @ProjectID  
    
END CATCH     
END  
SET ANSI_NULLS ON
