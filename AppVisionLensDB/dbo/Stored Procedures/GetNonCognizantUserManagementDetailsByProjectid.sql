/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROCEDURE [dbo].[GetNonCognizantUserManagementDetailsByProjectid]       
(      
 @CustomerID VARCHAR(20) = NULL,      
 @ProjectID  VARCHAR(20) = NULL      
)      
AS      
BEGIN      
       
 SET NOCOUNT ON;        
      
 DECLARE @EsaProjectID varchar(10)      
 DECLARE @ESA_AccountID varchar(10)      
      
     SET @EsaProjectID = (SELECT EsaProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID = @ProjectID)        
  SET @ESA_AccountID = (SELECT ESA_AccountID FROM AVL.Customer(NOLOCK) WHERE CustomerID = @CustomerID)       
          
       
 CREATE Table #JobGrade      
 (      
   EmployeeID NVARCHAR(100),      
   Grade  NVARCHAR(4)      
 )      
      
 INSERT INTO #JobGrade       
      
  SELECT DISTINCT ESA.AssociateID, ESA.Grade       
  FROM ESA.Associates (NOLOCK) ESA INNER JOIN ESA.ProjectAssociates(NOLOCK) ESP      
  ON ESA.AssociateID = ESP.AssociateID AND ESP.ACCOUNT_ID = @ESA_AccountID      
  WHERE ESA.Grade IN ('C33', 'C35', 'C40', 'C45', 'C50', 'C60','C65','C70','C75','C80','C85','C97',      
   'CC1','E60', 'E65', 'E70', 'E75', 'E80','E82','E85','E90','E95','E97','E99','N60',      
   'N65','N70','N75','N85','N90','N95','N98','NC1','NC2','NC3','NC4','NI1')      
       
   Create table #temp2    
   (    
   EmployeeID nvarchar(100),    
   EmployeeName nvarchar(200),    
   ClientUserID nvarchar(100),    
   TimeZoneId int,    
   TimeZoneName nvarchar(200),    
   LocationID int,    
   LocationName nvarchar(100),  
    PODDetailID varchar(100),  
   PODName nvarchar(100),    
   RoleID int,  
   RoleName nvarchar(100),  
   TSApproverID nvarchar(100),    
   TSApproverName nvarchar(200),    
   MandatoryHours decimal(6,2),    
   IsDeleted bit    
   )    
       
Select UserId,CAST(PODDetailID AS varchar) AS PODDetailID Into #TPOD  
From  ADM.AssociateAttributes WHERE IsDeleted=0  
  
   SELECT [UserId], PODDetailID =   
    STUFF((SELECT ', ' + PODDetailID  
        FROM #TPOD b   
        WHERE b.[UserId] = a.[UserId]   
       FOR XML PATH('')), 1, 2, '') into #TPODDetails  
   FROM #TPOD a  
   GROUP BY [UserId]  
    
 Insert into #temp2    
 SELECT DISTINCT       
  LM1.EmployeeID,      
  LM1.EmployeeName,      
  CASE WHEN LM1.ClientUserID = '' OR LM1.ClientUserID IS NULL THEN '0' ELSE LM1.ClientUserID END AS ClientUserID,      
  LM1.TimeZoneId,      
  TZ.TimeZoneName,      
  LM1.LocationID,      
  L.City as LocationName,     
  PD.PODDetailID,  
  POD.PODName,   
  RM.RoleID,  
  RM.RoleName,  
  CASE WHEN LM1.TSApproverID IS NULL OR LM1.TSApproverID = ''       
   THEN LM1.HcmSupervisorID       
   ELSE LM1.TSApproverID       
  END TSApproverID,      
  null,      
  CASE WHEN ISNULL(JG.Grade, '') <> '' AND LM1.MandatoryHours IS NULL THEN 8 ELSE LM1.MandatoryHours END AS MandatoryHours,      
  ISNULL (LM1.IsDeleted     ,0)  
 --INTO #temp2       
 FROM [AVL].[MAS_LoginMaster](NOLOCK) LM1         
 LEFT JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ ON TZ.TimeZoneID = LM1.TimeZoneId      
 LEFT JOIN  ESA.[LocationMaster](NOLOCK) L ON L.ID = LM1.LocationID   
 LEFT JOIN ADM.AssociateAttributes (NOLOCK) ADM ON ADM.UserId=LM1.UserID  
 LEFT JOIN PP.Project_PODDetails (NOLOCK) POD on POD.ProjectID = LM1.ProjectID and POD.PODDetailID = ADM.PODDetailID AND POD.IsDeleted=0   
 LEFT JOIN [PP].[ALM_MAP_UserRoles] (NOLOCK) UR  ON LM1.EmployeeID = UR.EmployeeID  
 LEFT JOIN [PP].[ALM_RoleMaster](NOLOCK) RM ON RM.RoleID=UR.RoleID  
 --LEFT JOIN ESA.Associates(NOLOCK) E ON LM1.EmployeeID = E.AssociateID      
 LEFT JOIN #JobGrade(NOLOCK) JG ON JG.EmployeeID = LM1.EmployeeID --AND JG.Grade = E.Grade  
 LEFT JOIN #TPODDetails PD on ADM.UserId=PD.UserId  
 WHERE LM1.customerid = @CustomerID AND LM1.ProjectID = @ProjectID -- AND LM1.isdeleted = 0 ----1053     
    
    
       
 UPDATE T       
 SET t.TSApproverName = l.EmployeeName      
 FROM #temp2 t       
 INNER JOIN AVL.MAS_LoginMaster(NOLOCK) l       
  ON l.EmployeeID = t.TSApproverID      
  
  
 SELECT * FROM   #temp2      
 DROP TABLE #temp2        
   
        
    SET NOCOUNT OFF;       
END
