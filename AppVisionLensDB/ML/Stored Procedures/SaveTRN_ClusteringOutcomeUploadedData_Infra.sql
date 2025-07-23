CREATE PROCEDURE [ML].[SaveTRN_ClusteringOutcomeUploadedData_Infra]    
(    
 @JsonfileUploadOutcome nvarchar(max),    
 @ProjectID bigint,    
 @UserID bigint,    
 @MLTransactionId bigint,    
 @IsRegenerate int=0    
     
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
IF(@IsRegenerate=0)    
BEGIN    
SELECT distinct CTA.MLTransactionId,CTA.ProjectID,CTA.TicketID,CTA.TowerId,CTA.DebtClassificationID,    
CTA.AvoidableFlagID,CTA.ResidualDebtID,CTA.ClusterID_Desc,CTA.ClusterID_Resolution    
into #Temp_Cluster    
FROM ML.TRN_ClusteringTicketValidation_infra CTA    
inner join #ClusterOutcome CO ON CTA.TowerId=CO.ApplicationID and     
CTA.MLTransactionId=CO.MLTransactionId and CTA.ProjectID=CO.ProjectID and CTA.ClusterID_Desc=CO.ClusterID_Desc    
and CTA.ClusterID_Resolution=CO.ClusterID_Resolution    
WHERE  CTA.Isdeleted=0    
    
Insert into #Temp_Cluster    
SELECT distinct MLTransactionId,ProjectID,TicketID,TowerId,DebtClassificationID,    
AvoidableFlagID,ResidualDebtID,ClusterID_Desc,ClusterID_Resolution    
FROM ML.TRN_ClusteringTicketValidation_infra WHERE MLTransactionId=@MLTransactionId and ClusterID_Desc=0    
and ClusterID_Resolution=0 and Isdeleted = 0  
    
update T set T.DebtClassificationID=DC.DebtClassificationID,    
T.AvoidableFlagID=AF.AvoidableFlagID,    
T.ResidualDebtID=RD.ResidualDebtID    
from #Temp_Cluster T inner join #ClusterOutcome CO    
ON T.ClusterID_Desc=CO.ClusterID_Desc and T.ClusterID_Resolution=CO.ClusterID_Resolution    
INNER JOIN AVL.DEBT_MAS_DebtClassification DC ON DC.DebtClassificationName=CO.DebtClassification    
INNER JOIN AVL.DEBT_MAS_AvoidableFlag AF ON AF.AvoidableFlagName=CO.AvoidableFlag    
INNER JOIN AVL.DEBT_MAS_ResidualDebt RD ON RD.ResidualDebtName=CO.ResidualDebt    
    
DELETE FROM ML.TRN_ClusteringOutcomeUploadedData_Infra WHERE MLTransactionId = @MLTransactionId    
    
INSERT INTO ML.TRN_ClusteringOutcomeUploadedData_Infra    
(MLTransactionId,ProjectID,TicketID,TowerId,DebtClassificationID,    
AvoidableFlagID,ResidualDebtID,ClusterID_Desc,ClusterID_Resolution,IsActive    
,CreatedBy,CreatedDate)    
SELECT distinct MLTransactionId,ProjectID,CO.TicketID,CO.TowerId,DebtClassificationID,    
AvoidableFlagID,ResidualDebtID,CO.ClusterID_Desc,CO.ClusterID_Resolution,1,    
@UserID,GETDATE()    
FROM #Temp_Cluster CO    
    
UPDATE [ML].[TRN_MLTransaction] SET JobStatusKey ='SK005', JobMessage ='',Modifiedby=@UserID,    
Modifieddate=GETDATE()    
WHERE Transactionid = @MLTransactionId    
drop table #Temp_Cluster    
END    
    
ELSE IF(@IsRegenerate=1)    
BEGIN    
    
UPDATE TV SET TV.IsOverwrite=1  , TV.ModifiedBy = @UserId , TV.ModifiedDate= GetDate()    
FROM [ML].[TRN_ClusteringTicketValidation_Infra] TV       
JOIN #ClusterOutcome CO ON       
CO.MLTransactionId = TV.MLTransactionId and TV.ClusterID_Desc=CO.ClusterID_Desc     
and TV.ClusterID_Resolution=CO.ClusterID_Resolution    
INNER JOIN AVL.DEBT_MAS_DebtClassification DC ON DC.DebtClassificationName=CO.DebtClassification    
INNER JOIN AVL.DEBT_MAS_AvoidableFlag AF ON AF.AvoidableFlagName=CO.AvoidableFlag    
INNER JOIN AVL.DEBT_MAS_ResidualDebt RD ON RD.ResidualDebtName=CO.ResidualDebt    
AND ((CASE WHEN ISNULL(TV.DebtClassificationID,0)=0 THEN DC.DebtClassificationID     
ELSE TV.DebtClassificationID END) <> DC.DebtClassificationID    
OR (CASE WHEN ISNULL(TV.AvoidableFlagID,0)=0 THEN AF.AvoidableFlagID     
ELSE TV.AvoidableFlagID END) <> AF.AvoidableFlagID    
OR (CASE WHEN ISNULL(TV.ResidualDebtID,0)=0 THEN RD.ResidualDebtID     
ELSE TV.ResidualDebtID END) <> RD.ResidualDebtID)   
    
update T set T.DebtClassificationID=DC.DebtClassificationID,    
T.AvoidableFlagID=AF.AvoidableFlagID,    
T.ResidualDebtID=RD.ResidualDebtID,    
T.ModifiedBy= @UserId,T.ModifiedDate=GetDate(),  
T.IsCLReviewCompleted=1  
from ML.TRN_ClusteringTicketValidation_infra T inner join #ClusterOutcome CO    
ON T.ClusterID_Desc=CO.ClusterID_Desc and T.ClusterID_Resolution=CO.ClusterID_Resolution    
INNER JOIN AVL.DEBT_MAS_DebtClassification DC ON DC.DebtClassificationName=CO.DebtClassification    
INNER JOIN AVL.DEBT_MAS_AvoidableFlag AF ON AF.AvoidableFlagName=CO.AvoidableFlag    
INNER JOIN AVL.DEBT_MAS_ResidualDebt RD ON RD.ResidualDebtName=CO.ResidualDebt    
WHERE T.MLTransactionId=CO.MLTransactionId    
    
UPDATE TV SET TV.DebtClassificationMapID=UD.DebtClassificationID,      
TV.AvoidableFlag = UD.AvoidableFlagID, TV.ResidualDebtMapID = UD.ResidualDebtID,    
TV.LastUpdatedDate=GetDate(),TV.ModifiedBy=@UserId,TV.ModifiedDate=GetDate()    
,TV.DebtClassificationMode = CASE WHEN (ISNULL(UD.DebtClassificationID,0) <> 0 AND ISNULL(UD.AvoidableFlagID,0)<>0 AND ISNULL(ResidualDebtID,0) <> 0)  
THEN 5 ELSE TV.DebtClassificationMode END,   
TV.IsApproved=1   
FROM [AVL].[TK_TRN_InfraTicketDetail] TV       
JOIN [ML].TRN_ClusteringTicketValidation_infra UD ON       
UD.TicketID = TV.TicketID AND UD.ProjectId=TV.ProjectId AND UD.TowerId=TV.TowerID      
WHERE TV.ProjectId=@projectId      
    
UPDATE [ML].[ClusteringCLProjects] SET JobStatusKey ='SK005', JobMessage ='',Modifiedby=@UserID,    
Modifieddate=GETDATE()    
WHERE Transactionid = @MLTransactionId    
    
END    
    
    
Drop table #ClusterOutcome    
END    
    