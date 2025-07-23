/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
CREATE PROCEDURE [dbo].[ITSM_DownloadExcel] --'1', '674078'              
@ProjectId BIGINT,              
@EmployeeID NVARCHAR(50),
@CCItsmTool VARCHAR(5)=NULL
AS              
BEGIN       
SET NOCOUNT ON;    
BEGIN TRY              
        SELECT Associateid, Esaprojectid into #tempAssociate from       
  RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)      
  Where AssociateId = @EmployeeID      
--DECLARE @CCITSMEnabled BIT = 1;              
              
--SELECT @CCITSMEnabled = HasCCITSMTool FROM AVL.MAS_ProjectMaster  (NOLOCK) WHERE ProjectID = @ProjectId;              
              
       
SELECT DISTINCT CASE WHEN @CCItsmTool = 'Y' THEN CC.CauseCode ELSE MC.ClusterName END
	AS ITSMCauseCode,MC.ClusterName AS ApplensCauseCode, NULL AS [Delete]             
    from [AVL].[DEBT_MAP_CauseCode] CC (NOLOCK)            
             
    INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON CC.ProjectID = PM.ProjectID and PM.IsDeleted=0            
    INNER JOIN #tempAssociate ecpm (NOLOCK) on ecpm.ESAProjectId=PM.EsaProjectId                     
    INNER JOIN MAS.Cluster MC (NOLOCK) ON CC.CauseStatusID = MC.ClusterID AND MC.CategoryID = 1              
    where ecpm.Associateid=@EmployeeID AND PM.ProjectID=@ProjectId AND CC.IsDeleted=0                       
  
SELECT ProjectId, ProjectName FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE ProjectID = @ProjectId  
  
SELECT ClusterName AS ApplensCauseCode FROM MAS.Cluster (NOLOCK)   
WHERE IsDeleted = 0 AND CategoryID = 1 ORDER BY ClusterName  
  
SELECT @CCItsmTool AS CCItsmTool      

DROP TABLE #tempAssociate
END TRY                
BEGIN CATCH                
              
  DECLARE @ErrorMessage VARCHAR(MAX);              
              
  SELECT @ErrorMessage = ERROR_MESSAGE()              
              
  --INSERT Error                  
  EXEC AVL_InsertError '[dbo].[ITSM_DownloadExcel]  ', @ErrorMessage, 0,0              
                
 END CATCH            
 SET NOCOUNT OFF;    
END
