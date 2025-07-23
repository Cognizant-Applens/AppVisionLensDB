/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[GetProjectForAutoClassification]     
@IsMultilingualEnabled int    
AS    
BEGIN    
BEGIN TRY    
 SET NOCOUNT ON;     
--DECLARE @IsMultilingualEnabled BIT = 0;    
SELECT DISTINCT    
PMC.AutoClassificationDetailsID,    
PMC.ProjectID       ,    
PMC.EmployeeID       ,    
PMC.IsAutoClassified     ,    
PMC.IsDDAutoClassified     ,    
PMC.DDAutoClassificationDate   ,    
PMC.AutoClassificationDate    ,    
PMC.InputFileName      ,    
PMC.AutoClassificationStatus   ,    
PMC.APIRequestedTime     ,    
PMC.APIRespondedTime     ,    
PMC.OutputFileName      ,    
PMC.CreatedBy       ,    
PMC.CreatedDate       ,    
PMC.ModifiedBy       ,    
PMC.ModifiedDate      ,    
PMC.IsAutoClassifiedInfra    ,    
PMC.IsDDAutoClassifiedInfra    ,    
PMC.DDAutoClassificationDateInfra,    
PMC.AutoClassificationDateInfra,    
ISNULL(CP.DebtAttributeId,0) AutoClassificationType,    
ISNULL(CP.IsTicketDescriptionOpted,0) IsTicketDescBaseClassify,    
ISNULL(ICP.DebtAttributeId,0) AutoClassificationTypeInfra,    
ISNULL(ICP.IsTicketDescriptionOpted,0) IsTicketDescBaseClassifyInfra    
INTO #OMLData   
FROM AVL.TK_ProjectForMLClassification PMC    
INNER JOIN AVL.MAS_ProjectMaster PM ON PMC.ProjectID = PM.ProjectID    
LEFT JOIN  [ML].[ConfigurationProgress] CP ON CP.ProjectID = PM.ProjectID AND CP.IsDeleted = 0    
LEFT JOIN  [ML].[InfraConfigurationProgress] ICP ON ICP.ProjectID = PM.ProjectID AND ICP.IsDeleted = 0    
WHERE (PMC.AutoClassificationStatus = 0 or PMC.AutoClassificationStatus is Null)
AND (PMC.IsAutoClassified = 'Y' OR PMC.IsAutoClassifiedInfra = 'Y')
AND ((@IsMultilingualEnabled = 0 AND (PM.IsMultilingualEnabled = @IsMultilingualEnabled OR PM.IsMultilingualEnabled IS NULL)) OR    
(PM.IsMultilingualEnabled = @IsMultilingualEnabled))  -- and PMC.EmployeeID= '587567' --and PMC.AutoClassificationDetailsID in (565912,565913)
    
--DROP TABLE #NMLData    
    
SELECT  DISTINCT OD.ProjectId,Supporttype ,MAX(AutoClassificationDetailsId) AS AutoClassificationDetailsId,    
 CASE WHEN (ISNULL(OD.IsTicketDescBaseClassify,0) = 1 AND OD.AutoClassificationType = 2 AND Supporttype = 1) THEN 8    
      WHEN (ISNULL(OD.IsTicketDescBaseClassify,0) = 1 AND OD.AutoClassificationType <> 2 AND Supporttype = 1) THEN 7    
      WHEN (ISNULL(OD.IsTicketDescBaseClassify,0) = 0 AND OD.AutoClassificationType = 2 AND Supporttype = 1) THEN 10    
      WHEN (ISNULL(OD.IsTicketDescBaseClassify,0) = 0 AND OD.AutoClassificationType <> 2 AND Supporttype = 1) THEN 9    
   WHEN (ISNULL(OD.IsTicketDescBaseClassifyInfra,0) = 1 AND OD.AutoClassificationTypeInfra = 2 AND Supporttype = 2) THEN 12      
      WHEN (ISNULL(OD.IsTicketDescBaseClassifyInfra,0) = 1 AND OD.AutoClassificationTypeInfra <> 2 AND Supporttype = 2) THEN 11      
   END as ClassificationTypeId,    
CASE WHEN OD.CreatedBy <> 'SharePath' THEN 'TicketUpload' ELSE CreatedBy END AS CreatedBy    
INTO #NMLData    
from #OMLData(NOLOCK) OD    
JOIN AVL.TK_MLClassification_TicketUpload(NOLOCK) MTU    
ON MTU.ProjectID = OD.ProjectID    
group by OD.ProjectId,SupportType,CreatedBy,IsTicketDescBaseClassify,AutoClassificationType,IsTicketDescBaseClassifyInfra,AutoClassificationTypeInfra    
order by ProjectId, SupportType    
    
--Insert Part    
    
Insert into ML.DebtAutoClassificationBatchProcess (    
 ProjectId    
,SupportTypeId    
,AutoClassificationDetailsId    
,ClassificationTypeId    
,StatusId    
,ProcessStartDateTime    
,ProcessEndDateTime    
,Message    
,IsDeleted   
,CreatedBy    
,CreatedDate    
,ModifiedBy    
,ModifiedDate)    
SELECT ProjectId,SupportType,AutoClassificationDetailsId,    
ClassificationTypeId,13 as StatusId,NULL,NULL,NULL,0 as Isdeleted,CreatedBy,    
GETDATE() AS CreatedDate, NULL AS ModifiedBy, NULL AS ModifiedDate     
FROM #NMLData(NOLOCK)    
    
    
    
--Update Part     
UPDATE  PML     
SET PML.AutoClassificationStatus = 1    
FROM AVL.TK_ProjectForMLClassification PML    
JOIN #OMLData(NOLOCK) OML    
ON OML.AutoClassificationDetailsID = PML.AutoClassificationDetailsID    
    
    
--Data return to code    
select     
AutoClassificationDetailsID,    
ProjectID       ,    
EmployeeID       ,    
IsAutoClassified     ,    
IsDDAutoClassified     ,    
DDAutoClassificationDate   ,    
AutoClassificationDate    ,    
InputFileName      ,    
AutoClassificationStatus   ,    
APIRequestedTime     ,    
APIRespondedTime     ,    
OutputFileName      ,    
CreatedBy       ,    
CreatedDate       ,    
ModifiedBy       ,    
ModifiedDate      ,    
IsAutoClassifiedInfra    ,    
IsDDAutoClassifiedInfra    ,    
DDAutoClassificationDateInfra,    
AutoClassificationDateInfra,    
AutoClassificationType,    
IsTicketDescBaseClassify,  
IsTicketDescBaseClassifyInfra  
from #OMLData     
    
     
select     
BatchProcessId    
,ProjectId    
,SupportTypeId    
,AutoClassificationDetailsId    
,ClassificationTypeId    
,StatusId    
,Message    
,IsDeleted    
from ML.DebtAutoClassificationBatchProcess where StatusId = 13 and IsDeleted = 0 -- and ProjectId=242330  
    
    
END TRY    
BEGIN CATCH    
DECLARE @ErrorMessage VARCHAR(MAX);    
    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
    
  --INSERT Error        
  EXEC AVL_InsertError '[dbo].[GetProjectForAutoClassification]', @ErrorMessage ,''    
END CATCH       
END
