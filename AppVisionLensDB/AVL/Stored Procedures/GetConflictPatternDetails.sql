/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetConflictPatternDetails] @ProjectId INT 
AS  
BEGIN  
 BEGIN TRANSACTION;  
 BEGIN TRY  
 
--Declaring variable to get startdate and previous fourth week start date
DECLARE @WeekStartDate date,@lastWeekStartDate date

SET @WeekStartDate=(SELECT DATEADD(dd, DATEPART(DW,GETDATE())*-1-27, GETDATE()))

SET @lastWeekStartDate=(SELECT DATEADD(wk, 0, DATEADD(wk, DATEDIFF(wk, 0,GETDATE()), -2)))

  -- TO Get Conflict Patterns form the Conflict Table
  SELECT DISTINCT
     DCP.[ProjectID]
	,DCP.ApplicationID
	,AD.ApplicationName As [ApplicationName]
	,DCP.CauseCodeID
	,CC.CauseCode  AS [CauseCode]
	,DCP.ResolutionCodeID
	,RC.ResolutionCode AS  [ResolutionCode]
	,DCP.DebtClassificationID
	,DC.DebtClassificationName AS [DebtCategory]
	,DCP.AvoidableFlagID
	,AF.AvoidableFlagName AS [AvoidableFlag]
	,DCP.ResidualDebtID
	,RD.ResidualDebtName AS [ResidualFlag]
	,'NULL' AS [ExistingPattern]
	,DCP.NoOfOccurence AS [TicketCount]	
	,DCP.CreatedDate AS [Period]
	into #ConflictDetails
    from avl.DDConflictPatterns DCP
    INNER JOIN avl.APP_MAS_ApplicationDetails(NOLOCK) AD ON DCP.ApplicationID=AD.ApplicationID and IsActive=1
	INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping] APM ON DCP.ProjectID=APM.ProjectID
	INNER JOIN avl.DEBT_MAP_ResolutionCode(NOLOCK) RC on DCP.ResolutionCodeID =RC.ResolutionID
	INNER JOIN avl.DEBT_MAP_CauseCode(NOLOCK) CC on   DCP.CauseCodeID  =CC.CauseID
    INNER JOIN AVl.DEBT_MAS_DebtClassification(NOLOCK) DC on DCP.DebtClassificationID =DC.DebtClassificationID
	AND ISNULL(DC.IsDeleted,0)=0
	INNER JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF on DCP.AvoidableFlagID=AF.AvoidableFlagID AND ISNULL(AF.IsDeleted,0)=0
	INNER JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD on DCP.ResidualDebtID=RD.ResidualDebtID AND ISNULL(RD.IsDeleted,0)=0
	AND ISNULL(RD.IsDeleted,0)=0
	WHERE DCP.ProjectID=@ProjectId 	AND 
	ISNULL(DCP.IsDeleted,0)=0
	AND (CAST(DCP.CreatedDate AS DATE)>=@WeekStartDate AND CAST(DCP.CreatedDate AS DATE)<= @lastWeekStartDate
	OR CAST(DCP.ModifiedDate AS DATE)>=@WeekStartDate AND CAST(DCP.ModifiedDate AS DATE)<=@lastWeekStartDate)
	ORDER BY AD.ApplicationName

	
	--Updating the Existing pattern column to Yes based on the Debt fields exists in DD pattern table

	UPDATE CD
    SET CD.ExistingPattern='Yes'
    FROM #ConflictDetails AS CD
    INNER JOIN avl.[Debt_MAS_ProjectDataDictionary]  PDD 
    on PDD.ApplicationID=CD.ApplicationID AND
	PDD.CauseCodeID=CD.CauseCodeID AND
	PDD.ResolutionCodeID=CD.ResolutionCodeID AND
	PDD.DebtClassificationID=CD.DebtClassificationID AND
	PDD.AvoidableFlagID=CD.AvoidableFlagID AND
	PDD.ResidualDebtID=CD.ResidualDebtID
	 
	 --Updating the Existing pattern column to No based on the Debt fields not exists in DD pattern table

	UPDATE #ConflictDetails
    SET ExistingPattern=''
    WHERE ExistingPattern!='Yes'   
	
	--Query to get the Conflict pattern details for download
    select
	 ApplicationName
	,CauseCode
	,ResolutionCode
	,DebtCategory
	,AvoidableFlag
	,ResidualFlag
	,ExistingPattern
	,TicketCount
	,[Period] AS [Period]
	FROM #ConflictDetails
	ORDER BY ApplicationName 

 END TRY  
 BEGIN CATCH  
  SELECT   
   ERROR_NUMBER() AS ErrorNumber  
   ,ERROR_SEVERITY() AS ErrorSeverity  
   ,ERROR_STATE() AS ErrorState  
   ,ERROR_PROCEDURE() AS ErrorProcedure  
   ,ERROR_LINE() AS ErrorLine  
   ,ERROR_MESSAGE() AS ErrorMessage;  
  
  IF @@TRANCOUNT > 0  
   ROLLBACK TRANSACTION;  
 END CATCH;  
  
 IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION;  
END
