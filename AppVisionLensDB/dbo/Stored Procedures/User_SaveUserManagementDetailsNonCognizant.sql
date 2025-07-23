/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure User_SaveUserManagementDetailsNonCognizant    
(    
@CustomerID varchar(20),  
@ProjectID int,  
@UserDetails1 [dbo].[TVP_UpdateUserManagementDetailsNonCognizant] READONLY    
)    
AS    
BEGIN          
DECLARE @result bit          
      
SELECT LM.UserID,D.EmployeeID,D.PODid INTO #PODDetails FROM [AVL].MAS_LoginMaster LM      
INNER JOIN (SELECT UD1.EmployeeID,CAST(SD.Value AS BIGINT) PODid FROM @UserDetails1 UD1 CROSS APPLY STRING_SPLIT (UD1.PODDetailID, ',') SD) D ON D.EmployeeID=LM.EmployeeID      
WHERE LM.ProjectID=@ProjectID AND LM.CustomerID=@CustomerID          
          
          
UPDATE B          
SET B.TSApproverID=T.TSApproverID,          
B.ClientUserID=rtrim(ltrim(T.ClientUserID)),          
B.TimezoneID=T.TimezoneId,          
B.MandatoryHours=T.MandatoryHours,          
B.ModifiedDate=getdate()
        
FROM @UserDetails1 T INNER JOIN [AVL].MAS_LoginMaster B          
ON B.EmployeeID=T.EmployeeID and B.CustomerID=T.CustomerID --and B.ProjectID=@ProjectID --where B.IsDeleted=0;         
      
      
UPDATE B          
SET           
B.isdeleted= case t.[IsDeleted]  when 1 then 0        
        when 0 then 1        
        end        
        
FROM @UserDetails1 T INNER JOIN [AVL].MAS_LoginMaster B          
ON B.EmployeeID=T.EmployeeID and B.CustomerID=T.CustomerID and B.ProjectID=@ProjectID      
      
      
UPDATE AD SET AD.IsDeleted = 1      
FROM ADM.AssociateAttributes AD       
INNER JOIN [AVL].MAS_LoginMaster LM ON LM.UserID = AD.UserId AND LM.ProjectID=@ProjectID AND LM.CustomerID=@CustomerID      
INNER JOIN #PODDetails PD1 ON PD1.UserID=AD.UserId      
WHERE        
NOT EXISTS (SELECT AD.UserId, AD.PODDetailID      
                   FROM   #PODDetails PD      
                   WHERE  PD.UserID=AD.UserId AND PD.PODid= AD.PODDetailID)      
      
MERGE ADM.AssociateAttributes T      
USING #PODDetails S      
ON (S.UserID = T.UserID AND S.PODid=T.PODDetailID)        
WHEN MATCHED       
     THEN UPDATE      
     SET    T.IsDeleted=0      
WHEN NOT MATCHED BY TARGET      
THEN INSERT (UserId,PODDetailID,IsDeleted,CreatedDate,CreatedBy,ModifiedDate,ModifiedBy)      
     VALUES (S.UserID,NULL,0,getdate(),S.EmployeeID,getdate(),S.EmployeeID );      
      
      
 MERGE [PP].[ALM_MAP_UserRoles]  as ILC      
     USING @UserDetails1      
     as ILCC      
     ON ILCC.EmployeeID = ILC.EmployeeID AND ILC.isDeleted =0      
          
        WHEN MATCHED AND ILCC.RoleId <> 0  THEN      
        UPDATE      
        SET ILC.RoleID =  ILCC.RoleID,      
        ILC.ModifiedBy =ILCC.EmployeeID,      
        ILC.ModifiedDate = GetDate()      
             
                     
        WHEN NOT MATCHED BY TARGET AND ILCC.RoleId <> 0      
        THEN      
                   
        INSERT      
        (EmployeeID,RoleID,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)      
        VALUES(ILCC.EmployeeID,ILCC.RoleID,0,ILCC.EmployeeID,GETDATE(),NULL,NULL)      
             
        WHEN MATCHED AND ILCC.RoleId = 0  THEN      
        DELETE;      
      
      
      
 SET @result= 1          
  SELECT @result AS RESULT          
END
