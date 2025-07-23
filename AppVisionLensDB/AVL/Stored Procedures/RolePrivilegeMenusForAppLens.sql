/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
CREATE proc [AVL].[RolePrivilegeMenusForAppLens]--'215573',7432  
@EmployeeID NVARCHAR(50),    
@CustomerId bigint    
as    
BEGIN
SET NOCOUNT ON;  
BEGIN TRY    
 IF EXISTS(select TOP 1 HcmSupervisorID from AVL.MAS_LoginMaster (NOLOCK) WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID )   
   AND CustomerID=@CustomerId and isdeleted=0 )  
BEGIN  
DECLARE  @TmpSelect table  
(  
PrivilegeID int,  
MenuName Varchar(50),  
[Role] Varchar(50)  
)  
  if exists( select 1 from AVL.MAS_LoginMaster (NOLOCK) WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID ) AND CustomerID=@CustomerId and isdeleted=0  
  AND ProjectID in (SELECT  ProjectID  FROM  AVL.MAS_ProjectDebtDetails PDD (NOLOCK)  WHERE  (PDD.IsAutoClassified='Y' OR  PDD.IsAutoClassifiedInfra='Y')  
   AND PDD.IsDDAutoClassified='Y' AND  (PDD.IsDeleted=0 or PDD.IsDeleted is null) )  )  
   BEGIN  
     IF EXISTS(SELECT TOP 1 LM.ProjectID from AVL.MAS_LoginMaster LM (NOLOCK)  
      INNER JOIN AVL.MAS_ProjectDebtDetails PDD (NOLOCK) ON LM.ProjectID = PDD.ProjectID  
      INNER JOIN avl.MAP_ProjectConfig PC (NOLOCK) ON PDD.ProjectID = PC.ProjectID  
      WHERE (LM.TSApproverID = @EmployeeID OR LM.HcmSupervisorID=@EmployeeID)  
      AND (PDD.IsDeleted=0 OR PDD.IsDeleted IS NULL)  
      AND (PDD.IsAutoClassified='Y' OR  PDD.IsAutoClassifiedInfra='Y')  
      AND LM.CustomerID=@CustomerId AND LM.IsDeleted=0         
      AND PDD.IsDDAutoClassified='Y'   
      AND PC.SupportTypeId IN (2,3))  
        
             BEGIN  
                    INSERT INTO @TmpSelect       
                    select DISTINCT pm.PrivilegeID,pm.MenuName,'Lead' AS Role from AVL.MAS_PrivilegeMaster  pm (NOLOCK)  where PrivilegeID not in (4)  
             END  
             ELSE  
    BEGIN  
             INSERT INTO @TmpSelect       
                    select DISTINCT pm.PrivilegeID,pm.MenuName,'Lead' AS Role from AVL.MAS_PrivilegeMaster  pm (NOLOCK)  where PrivilegeID not in (4,1)  
             END   
  END  
      ELSE if exists( select 1 from AVL.MAS_LoginMaster (NOLOCK) WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID ) AND CustomerID=@CustomerId AND isdeleted=0  
  AND ProjectID in (SELECT  ProjectID  FROM  AVL.MAS_ProjectDebtDetails PDD (NOLOCK)  WHERE  (PDD.IsAutoClassified='Y' OR  PDD.IsAutoClassifiedInfra='Y')   
  AND PDD.IsDDAutoClassified='N' AND  PDD.IsDeleted=0  )  )  
  BEGIN  
    IF EXISTS(SELECT TOP 1 LM.ProjectID from AVL.MAS_LoginMaster LM (NOLOCK)  
      INNER JOIN AVL.MAS_ProjectDebtDetails PDD (NOLOCK) ON LM.ProjectID = PDD.ProjectID  
      INNER JOIN avl.MAP_ProjectConfig PC (NOLOCK) ON PDD.ProjectID = PC.ProjectID  
      WHERE (LM.TSApproverID = @EmployeeID OR LM.HcmSupervisorID=@EmployeeID)  
      AND (PDD.IsDeleted=0 OR PDD.IsDeleted IS NULL)  
      AND (PDD.IsAutoClassified='Y' OR  PDD.IsAutoClassifiedInfra='Y')  
      AND LM.CustomerID=@CustomerId AND LM.IsDeleted=0         
      AND PDD.IsDDAutoClassified='Y'   
      AND PC.SupportTypeId IN (2,3))  
        
             BEGIN  
                    INSERT INTO @TmpSelect       
                    select DISTINCT pm.PrivilegeID,pm.MenuName,'Lead' AS Role from AVL.MAS_PrivilegeMaster  pm (NOLOCK)  where PrivilegeID not in (7)  
             END  
             ELSE  
    BEGIN  
             INSERT INTO @TmpSelect       
                    select DISTINCT pm.PrivilegeID,pm.MenuName,'Lead' AS Role from AVL.MAS_PrivilegeMaster  pm (NOLOCK)  where PrivilegeID not in (7,1)  
             END   
  END  
 ELSE if exists(select 1 from AVL.MAS_LoginMaster (NOLOCK) WHERE ( TSApproverID=@EmployeeID or HcmSupervisorID=@EmployeeID ) AND CustomerID=@CustomerId AND isdeleted=0  
                AND ProjectID in (SELECT  ProjectID  FROM  AVL.MAS_ProjectDebtDetails PDD (NOLOCK)  WHERE  (PDD.IsAutoClassified='N' OR  PDD.IsAutoClassifiedInfra='N')   
                AND PDD.IsDDAutoClassified='Y' AND (PDD.IsDeleted=0 or PDD.IsDeleted is null)  ))  
    BEGIN  
    INSERT INTO @TmpSelect    
     select DISTINCT pm.PrivilegeID,pm.MenuName,'Lead' AS Role from AVL.MAS_PrivilegeMaster  pm (NOLOCK)  where PrivilegeID not in (1)  
    END  
       ELSE  
    BEGIN  
    INSERT INTO  @TmpSelect  
     select DISTINCT pm.PrivilegeID,pm.MenuName,'Lead' AS Role from AVL.MAS_PrivilegeMaster pm (NOLOCK) where PrivilegeID not in (1,7)  
    END    
  END  
          ELSE  
    BEGIN  
    INSERT INTO  @TmpSelect  
      select DISTINCT pm.PrivilegeID,pm.MenuName,'' AS Role from  AVL.MAS_PrivilegeMaster pm (NOLOCK) where pm.PrivilegeID=2  
    END  
IF EXISTS(Select 1 from AVL.Customer (NOLOCK) WHERE CustomerID=@CustomerId and IsEffortConfigured=1 )  
 BEGIN  
  SELECT DISTINCT pm.PrivilegeID,pm.MenuName,'Lead' AS Role from AVL.MAS_PrivilegeMaster  pm (NOLOCK) WHERE PM.PrivilegeID IN(4)  
  UNION  
  SELECT PrivilegeID,MenuName,[Role] FROM @TmpSelect WHERE PrivilegeID != 3  
 END  
ELSE  
 BEGIN  
  SELECT PrivilegeID,MenuName,[Role] FROM @TmpSelect WHERE PrivilegeID != 3  
 END  
END TRY      
BEGIN CATCH       
  DECLARE @ErrorMessage VARCHAR(MAX);      
  SELECT @ErrorMessage = ERROR_MESSAGE()         
  EXEC AVL_InsertError '[AVL].[RolePrivilegeMenus ', @ErrorMessage, @EmployeeID,0       
 END CATCH      
SET NOCOUNT OFF;           
END
