/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/ 

CREATE PROCEDURE [dbo].[ITSM_AssignmentGroupDownloadExcel]
@ProjectID BIGINT,
@EmployeeID NVARCHAR(50),
@ProjectScope INT
AS  
BEGIN  
SET NOCOUNT ON;  
BEGIN TRY 
SELECT Associateid, Esaprojectid into #tempAssociate from         
  RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)        
  Where AssociateId = @EmployeeID 

 SELECT DISTINCT AGM.AssignmentGroupName, MAG.AssignmentGroupTypeName as CategoryName, 
 STM.SupportTypeName as SupportTypeName,CASE WHEN AGM.IsBotGroup = 1 THEN 'Yes' ELSE 'No' END as IsBotGroup, NULL as [Delete]   
 FROM AVL.BOTAssignmentGroupMapping AGM (NOLOCK)    
 JOIN AVL.MAS_AssignmentGroupType MAG (NOLOCK) on MAG.AssignmentGroupTypeID=AGM.AssignmentGroupCategoryTypeID    
 JOIN AVL.SupportTypeMaster STM (NOLOCK) on STM.SupportTypeId=AGM.SupportTypeID 
 JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON AGM.ProjectID = PM.ProjectID and PM.IsDeleted=0              
 JOIN #tempAssociate ecpm (NOLOCK) on ecpm.ESAProjectId=PM.EsaProjectId                       
 WHERE ecpm.Associateid=@EmployeeID and AGM.ProjectID=@ProjectId and AGM.IsDeleted=0 and MAG.IsDeleted=0 and STM.IsDeleted=0    
 --order by AGM.AssignmentGroupMapID desc

 SELECT ProjectId, ProjectName FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE ProjectID = @ProjectId

 SELECT AssignmentGroupTypeName as CategoryName   
 FROM AVL.MAS_AssignmentGroupType (NOLOCK)  
 WHERE IsDeleted=0  
 
 IF @ProjectScope = 1 OR @ProjectScope = 2
 BEGIN
	SELECT SupportTypeName   
	FROM AVL.SupportTypeMaster (NOLOCK)
	WHERE IsDeleted=0 AND SupportTypeId = @ProjectScope
 END
 ELSE
 BEGIN
	SELECT SupportTypeName   
	FROM AVL.SupportTypeMaster (NOLOCK)
	WHERE IsDeleted=0 AND SupportTypeId<>3  
 END

 DROP TABLE #tempAssociate

END TRY  
    
BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC AVL_InsertError '[dbo].[ITSM_AssignmentGroupDownloadExcel]', @ErrorMessage, 0, 0  
END CATCH    
SET NOCOUNT OFF;  
END
