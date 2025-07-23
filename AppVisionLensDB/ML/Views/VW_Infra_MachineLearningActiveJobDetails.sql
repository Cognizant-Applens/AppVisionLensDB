/***************************************************************************        
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET        
*Copyright [2018] – [2021] Cognizant. All rights reserved.        
*NOTICE: This unpublished material is proprietary to Cognizant and        
*its suppliers, if any. The methods, techniques and technical        
  concepts herein are considered Cognizant confidential and/or trade secret information.         
          
*This material may be covered by U.S. and/or foreign patents or patent applications.         
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.        
***************************************************************************/        
        
CREATE VIEW [ML].[VW_Infra_MachineLearningActiveJobDetails]            
AS        
WITH detailsfromRoleView (associateid,Projectid,projectname,esaprojectid)      
 AS(      
 SELECT DISTINCT associateid,Projectid,projectname,esaprojectid from RLE.VW_ProjectLevelRoleAccessDetails rle       
  WHERE rle.RoleKey in ('RLE003','RLE008') and rle.Projectid is not null       
 )      
 SELECT DISTINCT SJS.ID AS JobID,          
  STRING_AGG(rle.Associateid,',') as associateId,         
  rle.projectname,            
  rle.ESAProjectID            
  ,CP.ProjectID            
  ,SJS.InitialLearningID              
  ,CP.IsOptionalField            
  --,CASE WHEN ISNULL(CP.IsTicketDescriptionOpted,0) = 1 THEN 'NO' ELSE 'YES' END AS WorkPatternSharing,            
  ,CASE WHEN SJS.JobType = 'NoiseEl' THEN 1 WHEN  SJS.JobType = 'Sampling' THEN 2 WHEN SJS.JobType = 'ML' THEN 3 END AS JobType              
  ,CASE WHEN ISNULL(CP.IsSamplingSkipped,0) = 1 THEN 'YES' ELSE 'NO' END AS WithoutSampling            
  ,CASE WHEN ISNULL(CP.DebtAttributeId,1) = 1 THEN 3 ELSE 5 END AS OutputParameter            
  FROM ML.InfraConfigurationProgress CP            
 INNER JOIN ML.InfraTRN_MLJobStatus SJS            
 ON CP.ID = SJS.InitialLearningID AND CP.ProjectID = SJS.ProjectID            
 INNER JOIN detailsfromRoleView rle             
 ON rle.Projectid = CP.ProjectID            
 WHERE             
  CP.IsDeleted = 0 AND SJS.IsDeleted = 0            
  AND ((CP.IsNoiseEliminationSentorReceived = 'Sent' AND SJS.JobType = 'NoiseEl' AND SJS.JobMessage = 'Sent' )            
  OR (CP.IsSamplingSentOrReceived = 'Sent' AND SJS.JobType = 'Sampling' AND SJS.JobMessage = 'Sent')            
  OR (CP.IsMLSentOrReceived = 'Sent' AND SJS.JobType = 'ML' AND SJS.JobMessage = 'Sent'))      
  group by SJS.ID,rle.projectname,rle.ESAProjectID,CP.ProjectID,SJS.InitialLearningID,          
  CP.IsOptionalField,CP.IsSamplingSkipped,CP.DebtAttributeId,SJS.JobType
