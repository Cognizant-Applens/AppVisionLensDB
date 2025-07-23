    
CREATE PROCEDURE [ML].[SaveTRN_ClusteringOutcomeUploadedData_Infra_CL]    
(    
 @JsonfileUploadOutcome nvarchar(max),    
 @ProjectID bigint,    
 @UserID bigint,    
 @MLTransactionId bigint,    
 @IsRegenerateorCL int=0,    
 @FromDate nvarchar(50)=null,    
 @ToDate nvarchar(50)=null    
)    
AS    
BEGIN    
    
SELECT A.*,@ProjectID as 'ProjectID',@MLTransactionId as 'MLTransactionId'     
INTO #ClusterOutcome FROM (SELECT T.* FROM OPENJSON(@JsonfileUploadOutcome)WITH (    
ApplicationID nvarchar(255)  '$.ApplicationID',    
DebtClassification nvarchar(255)  '$.DebtClassification',    
AvoidableFlag nvarchar(255)  '$.AvoidableFlag',    
ResidualDebt nvarchar(255)  '$.ResidualDebt',    
ClusterID_Desc nvarchar(255)  '$.IssueDescriptionClusterId',    
ClusterID_Resolution nvarchar(255)  '$.ResolutionProvidedClusterId'    
)T)A    
    
 IF(@IsRegenerateorCL=0 or @IsRegenerateorCL=1)    
BEGIN    
    
UPDATE TV SET TV.IsOverwrite=1  , TV.ModifiedBy = @UserId , TV.ModifiedDate= GetDate()    
FROM [ML].[TRN_ClusteringTicketValidation_Infra] TV       
JOIN #ClusterOutcome CO ON       
CO.MLTransactionId = TV.MLTransactionId and TV.ClusterID_Desc=CO.ClusterID_Desc     
and TV.ClusterID_Resolution=CO.ClusterID_Resolution    
INNER JOIN AVL.DEBT_MAS_DebtClassification DC ON DC.DebtClassificationName=CO.DebtClassification    
INNER JOIN AVL.DEBT_MAS_AvoidableFlag AF ON AF.AvoidableFlagName=CO.AvoidableFlag    
INNER JOIN AVL.DEBT_MAS_ResidualDebt RD ON RD.ResidualDebtName=CO.ResidualDebt    
AND CASE WHEN ISNULL(TV.DebtClassificationID,0)=0 THEN DC.DebtClassificationID     
ELSE TV.DebtClassificationID END <> DC.DebtClassificationID    
OR CASE WHEN ISNULL(TV.AvoidableFlagID,0)=0 THEN AF.AvoidableFlagID     
ELSE TV.AvoidableFlagID END <> AF.AvoidableFlagID    
OR CASE WHEN ISNULL(TV.ResidualDebtID,0)=0 THEN RD.ResidualDebtID     
ELSE TV.ResidualDebtID END <> RD.ResidualDebtID    
    
update T set T.DebtClassificationID=DC.DebtClassificationID,    
T.AvoidableFlagID=AF.AvoidableFlagID,    
T.ResidualDebtID=RD.ResidualDebtID,    
T.ModifiedBy= @UserId,T.ModifiedDate=GetDate(),    
T.CLOutcomeReviewDate=Getdate(),    
T.IsCLReviewCompleted=1,    
T.IsManualClassification=@IsRegenerateorCL    
    
from ML.TRN_ClusteringTicketValidation_infra T inner join #ClusterOutcome CO    
ON T.ClusterID_Desc=CO.ClusterID_Desc and T.ClusterID_Resolution=CO.ClusterID_Resolution    
INNER JOIN AVL.DEBT_MAS_DebtClassification DC ON DC.DebtClassificationName=CO.DebtClassification    
INNER JOIN AVL.DEBT_MAS_AvoidableFlag AF ON AF.AvoidableFlagName=CO.AvoidableFlag    
INNER JOIN AVL.DEBT_MAS_ResidualDebt RD ON RD.ResidualDebtName=CO.ResidualDebt    
WHERE T.MLTransactionId=CO.MLTransactionId    
    
UPDATE TV SET TV.DebtClassificationMapID=UD.DebtClassificationID,      
TV.AvoidableFlag = UD.AvoidableFlagID, TV.ResidualDebtMapID = UD.ResidualDebtID,    
TV.DebtClassificationMode=case when @IsRegenerateorCL=1 then 8 when @IsRegenerateorCL=0 then TV.DebtClassificationMode end ,    
TV.LastUpdatedDate=GetDate(),TV.ModifiedBy=@UserId,TV.ModifiedDate=GetDate(),TV.IsApproved=1    
FROM [AVL].[TK_TRN_InfraTicketDetail] TV       
JOIN [ML].TRN_ClusteringTicketValidation_Infra UD ON       
UD.TicketID = TV.TicketID AND UD.ProjectId=TV.ProjectId AND UD.TowerId=TV.TowerID      
WHERE TV.ProjectId=@projectId      
    
Delete from [ML].[CLandManualClassificationReviewDetails] where MLTransactionId=@MLTransactionId and IsManual=@IsRegenerateorCL    
    
Insert into [ML].[CLandManualClassificationReviewDetails] (MLTransactionId,ProjectID,FromDate,ToDate,IsManual,IsDeleted,CreatedBy,CreatedDate)    
SELECT @MLTransactionId,@projectId,convert(date,@FromDate,103),convert(date,@ToDate,103),@IsRegenerateorCL ,0,    
@UserID,Getdate()    
    
UPDATE [ML].[ClusteringCLProjects] SET JobStatusKey ='SK005', JobMessage ='',Modifiedby=@UserID,    
Modifieddate=GETDATE()    
WHERE Transactionid = @MLTransactionId    
    
END    
    
Drop table #ClusterOutcome    
END    
    