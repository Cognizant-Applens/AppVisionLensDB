/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
CREATE PROCEDURE [dbo].[sp_GetAVMProjectDetails]    
 @EmployeeID NVARCHAR(50),    
    
 @CustomerID INT,    
 @MenuRole NVARCHAR(10) = NULL      
    
AS    
    
BEGIN    
    
BEGIN TRY    
    
 SET NOCOUNT ON;    
    
   DECLARE @UserIDs AS TABLE    
    
   (UserID NVARCHAR(50),    
    
       CustomerID INT)    
    
    
    
   INSERT INTO @UserIDs    
    
   SELECT EmployeeID,CustomerID FROM [AVL].[MAS_LoginMaster] (NOLOCK)    
    
   WHERE EmployeeID=@EmployeeID AND isdeleted = 0 AND CustomerID = @CustomerID    
    
   SET @MenuRole=ISNULL(@MenuRole,'Lead');    
   IF(@MenuRole='Lead')        
   BEGIN        
    SELECT DISTINCT A.ProjectID,A.ProjectName,A.SupportTypeId FROM     
    
    (    
    
    SELECT PM.ProjectID,PM.ProjectName,PC.SupportTypeId FROM avl.MAS_LoginMaster L (NOLOCK)    
    
    INNER JOIN @UserIDs U ON (U.UserID=L.HcmSupervisorID OR  U.UserID= L.TSApproverID) AND  U.CustomerID = L.CustomerID    
    
    INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.ProjectID=L.ProjectID AND PM.CustomerID = U.CustomerID    
    
    LEFT JOIN AVL.MAP_ProjectConfig PC (NOLOCK) ON PC.ProjectID = PM.ProjectID     
    
    WHERE l.IsDeleted = 0 AND ISNULL(PM.IsDeleted,0)=0    
    
    ) A    
    
   END    
   ELSE        
    BEGIN        
    SELECT DISTINCT A.ProjectID,A.ProjectName,A.SupportTypeId FROM           
          
      (          
          
      SELECT PM.ProjectID,PM.ProjectName,PC.SupportTypeId FROM avl.MAS_LoginMaster L (NOLOCK)          
          
      INNER JOIN @UserIDs U ON U.UserID=L.EmployeeID AND (U.UserID<>ISNULL(L.HcmSupervisorID,0) AND  U.UserID<> ISNULL(L.TSApproverID,0)) AND U.CustomerID = L.CustomerID          
          
      INNER JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.ProjectID=L.ProjectID AND PM.CustomerID = U.CustomerID          
          
      LEFT JOIN AVL.MAP_ProjectConfig PC (NOLOCK) ON PC.ProjectID = PM.ProjectID           
          
      WHERE l.IsDeleted = 0 AND ISNULL(PM.IsDeleted,0)=0          
          
      ) A          
    END     
    
END TRY    
    
    
    
BEGIN CATCH    
    
    
   DECLARE @ErrorMessage VARCHAR(MAX);    
    
   SELECT @ErrorMessage = ERROR_MESSAGE()    
    
   --INSERT Error        
    
   EXEC AVL_InsertError '[dbo].[sp_GetAVMProjectDetails]', @ErrorMessage,@EmployeeID,@CustomerID    
    
    
    
END CATCH    
    
    
 SET NOCOUNT OFF;    
    
    
END
