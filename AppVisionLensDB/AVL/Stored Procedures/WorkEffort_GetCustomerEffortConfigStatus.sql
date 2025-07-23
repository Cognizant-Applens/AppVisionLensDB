/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ====================================================================    
-- author:      
-- create date:     
-- Modified by : 835658    
-- Modified For:  RHMS New Role API      
-- description: getting customer effort config status using employeeid and projectId    
-- ====================================================================      
-- EXEC [AVL].[WorkEffort_GetCustomerEffortConfigStatus] '104559',90524    
    
CREATE PROCEDURE  [AVL].[WorkEffort_GetCustomerEffortConfigStatus]    
(    
@EmployeeId VARCHAR(20),    
@ProjectID BIGINT    
)    
AS    
BEGIN      
BEGIN TRY     
  SET NOCOUNT ON;    
    
  SELECT    
    DISTINCT     
	ISNULL(CAST(C.IsEffortConfigured AS INT),0) AS 'IsEffortConfigured',    
	CASE WHEN CM.ServiceDartColumn is not null THEN 1 ELSE 0 END AS 'ITSMEffort',    
	p.EsaProjectID    
      
  FROM     
  RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)PRA      
  INNER JOIN AVL.Customer (NOLOCK) C ON PRA.ESACustomerID= C.ESA_AccountId AND C.IsDeleted<>1       
  INNER JOIN AVL.MAS_ProjectMaster (NOLOCK) P ON P.ESAProjectID = PRA.ESAProjectID AND P.IsDeleted<>1 and p.IsDebtEnabled='Y'    
  LEFT JOIN AVL.ITSM_PRJ_SSISColumnMapping (NOLOCK) CM ON CM.ProjectID=P.ProjectID     
         AND CM.IsDeleted<>1 AND CM.ServiceDartColumn='ITSM Effort'    
  WHERE     
   PRA.AssociateId = @EmployeeId AND P.ProjectId=@ProjectID    
    
     SET NOCOUNT OFF;     
  END TRY    
  BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(MAX);    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
  --INSERT Error        
  EXEC AVL_InsertError '[AVL].[WorkEffort_GetCustomerEffortConfigStatus] ', @ErrorMessage, @ProjectID    
  RETURN @ErrorMessage    
  END CATCH     
    
END
