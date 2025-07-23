/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
CREATE PROCEDURE [dbo].[ITSM_ResolutionCodeDownloadExcel]  --'10337', '827309'        
 @ProjectId BIGINT,                  
 @EmployeeId NVARCHAR(50),      
 @RCItsmTool VARCHAR(5)=NULL      
AS                  
 BEGIN                  
  SET NOCOUNT ON;          
  BEGIN TRY                  
            
 SELECT AssociateId, Esaprojectid into #tempAssociate from             
 RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)             
 where Associateid = @EmployeeId            
                  
--  DECLARE @RCITSMEnabled BIT = 1;                  
                  
--SELECT @RCITSMEnabled = HasRCITSMTool FROM AVL.MAS_ProjectMaster (NOLOCK)  WHERE ProjectID = @ProjectId;                  
                 
   SELECT DISTINCT CASE WHEN @RCItsmTool = 'Y' THEN RC.ResolutionCode ELSE MC.ClusterName END  
    AS [ITSM Resolution Code Name],                  
    MC.ClusterName AS [Applens Resolution Code Name],                  
    NULL AS [Delete]                  
   FROM [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) RC                   
   INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM                   
    ON PM.ProjectID=RC.ProjectID  and PM.isdeleted=0                
 INNER JOIN #tempAssociate(NOLOCK) ECPM                   
    ON ECPM.Esaprojectid=PM.EsaProjectid                 
   INNER JOIN [AVL].[CauseCodeResolutionCodeMapping] (NOLOCK) CRM                   
    ON CRM.ResolutionCodeMapID=RC.ResolutionID AND CRM.ProjectID=RC.ProjectID AND CRM.IsDeleted=0                  
    --  INNER JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC                   
    --ON CC.CauseID=CRM.CauseCodeMapID AND CC.IsDeleted=0                  
   INNER JOIN MAS.Cluster MC (NOLOCK)  ON RC.ResolutionStatusID = MC.ClusterID AND MC.CategoryID = 2                   
   WHERE ECPM.Associateid=@EmployeeId AND PM.ProjectID=@ProjectId                   
      AND CRM.IsDeleted=0                   
      --AND CC.IsDeleted=0                   
   UNION                  
                     
   SELECT DISTINCT CASE WHEN @RCItsmTool = 'Y' THEN RC.ResolutionCode ELSE MC.ClusterName END  
    AS [ITSM Resolution Code Name],                  
    MC.ClusterName AS [Applens Resolution Code Name],                  
    NULL AS [Delete]  
   FROM [AVL].[DEBT_MAP_ResolutionCode](NOLOCK) RC                   
   INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM                   
    ON PM.ProjectID=RC.ProjectID  and PM.isdeleted=0                
 INNER JOIN #tempAssociate(NOLOCK) ECPM                   
    ON ECPM.Esaprojectid=PM.EsaProjectid                 
   INNER JOIN MAS.Cluster MC (NOLOCK)  ON RC.ResolutionStatusID = MC.ClusterID AND MC.CategoryID = 2                   
   LEFT JOIN [AVL].[CauseCodeResolutionCodeMapping] (NOLOCK) CRM                   
    ON CRM.ResolutionCodeMapID=RC.ResolutionID AND CRM.ProjectID=RC.ProjectID AND CRM.IsDeleted=0                  
    --  LEFT JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC                   
    --ON CC.CauseID=CRM.CauseCodeMapID AND CC.IsDeleted=0                     
   WHERE ECPM.Associateid=@EmployeeId AND PM.ProjectID=@ProjectId and RC.IsDeleted=0                   
   GROUP BY PM.ProjectName ,RC.ResolutionCode,MC.ClusterName --CC.CauseCode                  
   HAVING count(CRM.CauseCodeResolutionCodeMapID )=0                   
      
SELECT ProjectId, ProjectName FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE ProjectID = @ProjectId      
      
SELECT ClusterName AS [Applens Resolution Code Name] FROM MAS.Cluster (NOLOCK)       
WHERE IsDeleted = 0 AND CategoryID = 2 ORDER BY ClusterName      
      
SELECT @RCItsmTool AS RCItsmTool      
  
--SELECT CauseCode FROM [AVL].[DEBT_MAP_CauseCode] (NOLOCK) WHERE ProjectID=@ProjectId AND IsDeleted=0  
      
 DROP TABLE #tempAssociate
 END TRY                  
  BEGIN CATCH                  
                  
 DECLARE @ErrorMessage VARCHAR(MAX);                  
                  
 SELECT @ErrorMessage = ERROR_MESSAGE()                  
                  
 --INSERT Error                  
                  
 EXEC AVL_InsertError 'dbo.ITSM_ResolutionCodeDownloadExcel',@ErrorMessage,0,0                  
                     
  END CATCH              
   SET NOCOUNT OFF;          
 END
