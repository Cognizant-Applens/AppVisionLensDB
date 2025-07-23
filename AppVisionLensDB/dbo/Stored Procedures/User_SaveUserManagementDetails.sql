/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [dbo].[User_SaveUserManagementDetails] 
(
@CustomerID varchar(20),
@ProjectID varchar(20),
@UserDetails1 [dbo].[TVP_UpdateUserManagementDetails] READONLY
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @result bit


--DELETE B
--FROM @UserDetails1 T INNER JOIN [AVL].[UserServiceLevelMapping] B
--ON B.EmployeeID=T.EmployeeID and B.CustomerID=T.CustomerID;

--INSERT INTO [AVL].[UserServiceLevelMapping]
--(ServiceLevelID,EmployeeID,CustomerID,CreatedBy,CreatedDate,ProjectID)
--SELECT DISTINCT ServiceLevelID,EmployeeID,CustomerID,EmployeeID,getdate(),ProjectID FROM @UserDetails1

UPDATE B
SET B.TSApproverID=T.TSApproverID,
B.TicketingModuleEnabled= CASE WHEN T.TicketingModuleEnabled = 'True'  THEN 1 
                              WHEN T.TicketingModuleEnabled = 'False' THEN 0
							  WHEN T.TicketingModuleEnabled = NULL THEN NULL
							  END, 
B.ClientUserID=rtrim(ltrim(T.ClientUserID)),
B.TimezoneID=T.TimezoneId,
B.MandatoryHours=T.MandatoryHours,
B.ModifiedDate=getdate()
FROM @UserDetails1 T INNER JOIN [AVL].MAS_LoginMaster B
ON B.EmployeeID=T.EmployeeID and B.CustomerID=T.CustomerID where B.IsDeleted=0;


--INSERT INTO ADM.AssociateAttributes
--(UserId,PODDetailID,IsDeleted,CreatedDate,CreatedBy,ModifiedDate,ModifiedBy)
--select distinct LM.UserID,UD.PODDetailID,0,getdate(),UD.EmployeeID,getdate(),UD.EmployeeID 
--FROM @UserDetails1 UD 
--INNER JOIN [AVL].MAS_LoginMaster LM ON LM.EmployeeID = UD.EmployeeID AND LM.ProjectID=@ProjectID AND LM.CustomerID=@CustomerID
--WHERE LM.UserID NOT IN (SELECT DISTINCT USERID FROM ADM.AssociateAttributes  WITH(NOLOCK))

SELECT LM.UserID,D.EmployeeID,D.PODid INTO #PODDetails FROM [AVL].MAS_LoginMaster LM (NOLOCK)
INNER JOIN (SELECT UD1.EmployeeID,CAST(SD.Value AS BIGINT) PODid FROM @UserDetails1 UD1 
CROSS APPLY STRING_SPLIT (UD1.PODDetailID, ',') SD) D ON D.EmployeeID=LM.EmployeeID
INNER JOIN PP.Project_PODDetails PPD (NOLOCK) ON PPD.PODDetailID=D.PODid
WHERE LM.ProjectID=@ProjectID AND LM.CustomerID=@CustomerID

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
     VALUES (S.UserID, S.PODid,0,getdate(),S.EmployeeID,getdate(),S.EmployeeID );
           

--INSERT INTO ADM.AssociateAttributes
--(UserId,PODDetailID,IsDeleted,CreatedDate,CreatedBy,ModifiedDate,ModifiedBy)
--select distinct LM.UserID,D.PODid,0,getdate(),UD.EmployeeID,getdate(),UD.EmployeeID 
--FROM @UserDetails1 UD
--INNER JOIN [AVL].MAS_LoginMaster LM ON LM.EmployeeID = UD.EmployeeID AND LM.ProjectID=@ProjectID AND LM.CustomerID=@CustomerID
--LEFT JOIN ADM.AssociateAttributes AA on AA.UserId= LM.UserID
--RIGHT JOIN (SELECT UD1.EmployeeID,CAST(SD.Value AS BIGINT) PODid FROM @UserDetails1 UD1 CROSS APPLY STRING_SPLIT (UD1.PODDetailID, ',') SD) D ON D.EmployeeID=LM.EmployeeID AND D.PODid= AA.PODDetailID
--WHERE LM.IsDeleted=0 AND (LM.EmployeeID is NULL OR AA.PODDetailID is NULL)

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
 SET NOCOUNT OFF;
END
