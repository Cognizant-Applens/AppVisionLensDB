/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    
CREATE PROCEDURE [AVL].[GetTicketModuleUserDetails]      
(      
       @ProjectID NVARCHAR(20),      
       @CustomerID NVARCHAR(10)         
)      
AS      
BEGIN      
   BEGIN TRY      
DECLARE @COUNT  INT;      
 DECLARE @L1   CHAR(3)  ='L1'      
 DECLARE @L2   CHAR(3)  ='L2'      
 DECLARE @L3   CHAR(3)  ='L3'      
 DECLARE @L4   CHAR(3)  ='L4'      
 DECLARE @Others  CHAR(7)  ='Others'      
 DECLARE @Yes  CHAR(3)  ='Yes'      
 DECLARE @No   CHAR(3)  ='No'      
 DECLARE @SheetName VARCHAR(20) ='User Details -'      
 DECLARE @IsDeleted  INT   = 0      
 DECLARE @IsNonESAAuthorized INT =0      
 DECLARE @IsCognizant INT = 0      
      
 CREATE Table #JobGrade      
 (      
  EmployeeID nvarchar(100),      
  Grade nvarchar(4),      
 )      
      
 INSERT INTO #JobGrade     
 SELECT DISTINCT AssociateID,Grade FROM ESA.Associates(nolock)      
 WHERE Grade IN ('C33', 'C35', 'C40', 'C45', 'C50', 'C60','C65','C70','C75','C80','C85','C97',      
 'CC1','E60', 'E65', 'E70', 'E75', 'E80','E82','E85','E90','E95','E97','E99','N60',      
 'N65','N70','N75','N85','N90','N95','N98','NC1','NC2','NC3','NC4','NI1')      
       
 --gettting distinct employee id under the customer and the project      
      
 --SELECT DISTINCT LM.EmployeeID INTO #employeedetails FROM AVL.MAS_LoginMaster (NOLOCK) LM      
 --WHERE LM.ProjectID=@ProjectId AND LM.CustomerID=@CustomerID AND LM.IsDeleted=@IsDeleted      
      
 SET @IsCognizant = ( SELECT TOP 1 PM.IsCoginzant FROM AVL.MAS_ProjectMaster (NOLOCK) PM WHERE PM.ProjectID = @ProjectID AND IsDeleted = @IsDeleted )      
      
IF( @IsCognizant = 1 )      
 BEGIN      
      
 --getting Project access under customer      
      
 SELECT DISTINCT PM.EsaProjectID,      
      PM.ProjectID,       
      PM.ProjectName,      
      LM.UserID,      
      LM.EmployeeID ,       
      LM.EmployeeName AS EmployeeName,      
      LM.ClientUserID,      
      LM.TimeZoneId ,      
      TZ.TimeZoneName,           
      LM.TSApproverID,      
      CASE WHEN ISNULL(JG.Grade,'') <> '' AND LM.MandatoryHours IS NULL THEN 8 ELSE LM.MandatoryHours END AS MandatoryHours,      
      LM.TicketingModuleEnabled,      
      LM.IsNonESAAuthorized      
      --,CAST(NULL AS NVARCHAR (250)) AS PODName      
  INTO #ProjectemployeedataCognizant      
  FROM AVL.MAS_LoginMaster (NOLOCK) LM         
  LEFT JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ProjectID=LM.ProjectID      
  LEFT JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ ON TZ.TimeZoneID=LM.TimeZoneId      
  LEFT JOIN  ESA.[LocationMaster](NOLOCK) L ON L.ID=LM.LocationID      
  LEFT JOIN ESA.Associates(NOLOCK) E ON LM.EmployeeID=E.AssociateID      
  LEFT JOIN #JobGrade (NOLOCK) JG ON JG.EmployeeID=E.AssociateID      
  AND JG.Grade=E.Grade      
  WHERE  LM.CustomerID=@CustomerID       
  AND LM.IsDeleted=@IsDeleted AND isnull(LM.IsNonESAAuthorized,0)=@IsNonESAAuthorized AND LM.ProjectID=@ProjectID      
      
      
 -- Select * from 'ProjectemployeedataCognizant'      
      
  --UPDATE PMC SET PMC.PODName = PD.PODName FROM  #ProjectemployeedataCognizant PMC      
  --LEFT JOIN  ADM.AssociateAttributes (NOLOCK) AA ON PMC.UserID=AA.UserId      
  --LEFT JOIN PP.Project_PODDetails (NOLOCK) PD ON AA.PODDetailID=PD.PODDetailID       
  --WHERE PD.ProjectID= @ProjectID AND PD.IsDeleted=@IsDeleted AND AA.IsDeleted=@IsDeleted    
      
  --getting servicelevel access data for each project and employeeid      
      
   SELECT DISTINCT PED.ProjectID,PED.Employeeid,      
    SL.ServiceLevelName AS serviceData,     
    SL.ServiceLevelName AS servicecolumnname      
   INTO #ServiceDataCognizant       
   FROM #ProjectemployeedataCognizant (NOLOCK) PED       
   JOIN AVL.UserServiceLevelMapping (NOLOCK) SLM       
  ON SLM.EmployeeID=PED.EmployeeID       
  AND SLM.ProjectID=PED.ProjectID      
   JOIN AVL.MAS_ServiceLevel (NOLOCK) SL       
  ON SL.ServiceLevelID=SLM.ServiceLevelID      
   WHERE SLM.CustomerID=@CustomerID      
   ORDER BY employeeid,projectid      
      
      
  --coverting the service level name to columns using pivot      
      
 SELECT DISTINCT ProjectID,Employeeid,L1, L2, L3, L4, Others INTO #ServicelstDataCognizant      
 FROM      
 (      
   SELECT Employeeid,ProjectID,serviceData,servicecolumnname      
   FROM #ServiceDataCognizant (NOLOCK)      
 ) d      
 pivot      
 (      
   MAX(serviceData)      
   FOR servicecolumnname IN (L1, L2, L3, L4, Others)       
 ) piv ORDER by Employeeid;      
      
 --Multi  Select POD Details      
Select PD.PODName,AA.UserId,A.PODDetailID Into #TPOD      
From  ADM.AssociateAttributes (NOLOCK) A      
LEFT JOIN  ADM.AssociateAttributes (NOLOCK) AA on A.Id = AA.Id      
LEFT JOIN PP.Project_PODDetails (NOLOCK) PD on PD.PODDetailID=AA.PODDetailID      
      
   SELECT [UserId], PODName =       
    STUFF((SELECT ', ' + PODName      
        FROM #TPOD (NOLOCK) b       
        WHERE b.[UserId] = a.[UserId]       
       FOR XML PATH('')), 1, 2, '') into #TPODDetails      
   FROM #TPOD (NOLOCK) a      
   GROUP BY [UserId]      
      
 --Result based on the requirement      
 --The below code is used to get User Details from login master account wise      
 --Employee ID Employee Name External Login ID Time zone TSApproverID Mandatory Hours Is Tracking L1 L2 L3 L4 Others      
        
 SELECT  DISTINCT       
   PED.EmployeeID AS 'Employee ID',      
   PED.EmployeeName as 'Employee Name',      
   PED.ClientUserID As 'External Login ID',        
   PED.TimeZoneName AS 'Time zone',         
   PED.TSApproverID as 'TSApproverID',        
   PED.MandatoryHours AS 'Mandatory Hours',      
   CASE WHEN PED.TicketingModuleEnabled=1 THEN @Yes ELSE @No END AS [Is Tracking],      
   CASE WHEN SD.L1=@L1 THEN @Yes ELSE @No END AS L1,      
   CASE WHEN SD.L2=@L2 THEN @Yes ELSE @No END AS L2,      
   CASE WHEN SD.L3=@L3 THEN @Yes ELSE @No END AS L3,      
   CASE WHEN SD.L4=@L4 THEN @Yes ELSE @No END AS L4,      
   CASE WHEN SD.Others=@Others THEN @Yes ELSE @No END AS Others,      
   PD.PODName AS 'POD Details',      
   RM.RoleName AS 'Role Details'      
      
 FROM #ProjectemployeedataCognizant (NOLOCK) PED       
 LEFT JOIN #ServicelstDataCognizant (NOLOCK) SD ON PED.Employeeid=SD.Employeeid AND PED.ProjectID=SD.ProjectID       
 LEFT JOIN #TPODDetails (NOLOCK) PD ON PD.UserId=PED.UserID      
  LEFT JOIN [PP].[ALM_MAP_UserRoles] (NOLOCK) UR  ON PED.EmployeeID = UR.EmployeeID      
 left join [PP].[ALM_RoleMaster](NOLOCK) RM ON UR.RoleID=RM.RoleID      
 END      
ELSE      
 BEGIN      
 --getting Project access under customer      
      
  SELECT DISTINCT PM.EsaProjectID,      
      PM.ProjectID,       
      PM.ProjectName,      
      LM.UserID,      
      LM.EmployeeID ,       
      LM.EmployeeName AS EmployeeName,      
      LM.ClientUserID,      
      LM.TimeZoneId ,      
      TZ.TimeZoneName,           
      LM.TSApproverID,      
      CASE WHEN ISNULL(JG.Grade,'') <> '' AND LM.MandatoryHours IS NULL THEN 8 ELSE LM.MandatoryHours END AS MandatoryHours,      
      LM.TicketingModuleEnabled,      
      LM.IsNonESAAuthorized      
  INTO #ProjectemployeedataCustomer      
  FROM AVL.MAS_LoginMaster (NOLOCK) LM         
  LEFT JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ProjectID=LM.ProjectID      
  LEFT JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ ON TZ.TimeZoneID=LM.TimeZoneId      
  LEFT JOIN  ESA.[LocationMaster](NOLOCK) L ON L.ID=LM.LocationID      
  LEFT JOIN ESA.Associates(NOLOCK) E ON LM.EmployeeID=E.AssociateID      
  LEFT JOIN #JobGrade(NOLOCK) JG ON JG.EmployeeID=E.AssociateID      
  AND JG.Grade=E.Grade      
  WHERE  LM.CustomerID=@CustomerID       
  AND LM.IsDeleted=@IsDeleted AND ISNULL(LM.IsNonESAAuthorized,0)=@IsNonESAAuthorized AND LM.ProjectID=@ProjectID      
      
      
  --getting servicelevel access data for each project and employeeid      
      
   SELECT DISTINCT PED.ProjectID,PED.Employeeid,      
    SL.ServiceLevelName AS serviceData,      
    SL.ServiceLevelName AS servicecolumnname      
   INTO #ServiceDataCustomer      
   FROM #ProjectemployeedataCustomer (NOLOCK) PED       
   JOIN AVL.UserServiceLevelMapping (NOLOCK) SLM       
  ON SLM.EmployeeID=PED.EmployeeID       
  AND SLM.ProjectID=PED.ProjectID      
   JOIN AVL.MAS_ServiceLevel (NOLOCK) SL       
  ON SL.ServiceLevelID=SLM.ServiceLevelID      
   WHERE SLM.CustomerID=@CustomerID      
   ORDER BY employeeid,projectid      
      
      
  --coverting the service level name to columns using pivot      
      
 SELECT DISTINCT ProjectID,Employeeid,L1, L2, L3, L4, Others INTO #ServicelstDataCustomer      
 FROM      
 (      
   SELECT Employeeid,ProjectID,serviceData,servicecolumnname      
   FROM #ServiceDataCustomer (NOLOCK)      
 ) d      
 pivot      
 (      
   MAX(serviceData)      
   FOR servicecolumnname IN (L1, L2, L3, L4, Others)       
 ) piv ORDER by Employeeid;      
      
 Select PD.PODName,AA.UserId,A.PODDetailID Into #CTPOD      
 From  ADM.AssociateAttributes (NOLOCK) A      
 LEFT JOIN  ADM.AssociateAttributes (NOLOCK) AA on A.Id = AA.Id      
 LEFT JOIN PP.Project_PODDetails (NOLOCK) PD on PD.PODDetailID=AA.PODDetailID      
      
 SELECT [UserId], PODName =       
  STUFF((SELECT ', ' + PODName      
    FROM #CTPOD (NOLOCK) b       
    WHERE b.[UserId] = a.[UserId]       
    FOR XML PATH('')), 1, 2, '') into #CTPODDetails      
 FROM #CTPOD (NOLOCK) a      
 GROUP BY [UserId]      
 --Result based on the requirement      
 --The below code is used to get User Details from login master account wise      
 --Employee ID Employee Name External Login ID Time zone TSApproverID Mandatory Hours Is Tracking L1 L2 L3 L4 Others      
        
 SELECT  DISTINCT       
   PED.EmployeeID AS 'Employee ID',      
   PED.EmployeeName as 'Employee Name',      
   PED.ClientUserID As 'External Login ID',        
   PED.TimeZoneName AS 'Time zone',         
   PED.TSApproverID as 'TSApproverID',        
   PED.MandatoryHours AS 'Mandatory Hours',      
   CASE WHEN PED.TicketingModuleEnabled=1 THEN @Yes ELSE @No END AS [Is Tracking],      
   CASE WHEN SD.L1=@L1 THEN @Yes ELSE @No END AS L1,      
   CASE WHEN SD.L2=@L2 THEN @Yes ELSE @No END AS L2,      
   CASE WHEN SD.L3=@L3 THEN @Yes ELSE @No END AS L3,      
   CASE WHEN SD.L4=@L4 THEN @Yes ELSE @No END AS L4,      
   CASE WHEN SD.Others=@Others THEN @Yes ELSE @No END AS Others,      
   PD.PODName AS 'POD Details',      
   RM.RoleName AS 'Role Details'      
 FROM #ProjectemployeedataCustomer (NOLOCK) PED       
 LEFT JOIN #ServicelstDataCustomer (NOLOCK) SD ON PED.Employeeid=SD.Employeeid       
  AND PED.ProjectID=SD.ProjectID       
 LEFT JOIN #CTPODDetails (NOLOCK) PD ON PD.UserId=PED.UserID      
 LEFT JOIN [PP].[ALM_MAP_UserRoles] (NOLOCK) UR  ON PED.EmployeeID = UR.EmployeeID      
 left join [PP].[ALM_RoleMaster](NOLOCK) RM ON UR.RoleID=RM.RoleID      
 END      
       
      
 --The below code is to used to get Enternal Login ID, TSApprover ID, ProjectId from Login Master      
 SELECT DISTINCT ClientUserID AS 'External Login ID',      
     EmployeeID AS 'TSApprover ID',      
     ProjectID as 'ProjectId'          
 FROM AVL.MAS_LoginMaster(NOLOCK)      
 WHERE  CustomerID=@CustomerID       
  AND IsDeleted=@IsDeleted      
      
 ---Get TimeZoneName name      
 SELECT TimeZoneName FROM  avl.MAS_TimeZoneMaster(NOLOCK) WHERE IsDeleted=@IsDeleted       
      
      
 ---Get Pod Names      
 SELECT PODName FROM  PP.Project_PODDetails(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=@IsDeleted ORDER BY PODName ASC      
      
 ---Get Role Names      
 SELECT RoleName FROM  [PP].[ALM_RoleMaster](NOLOCK) WHERE IsDeleted=@IsDeleted       
      
        
        
      
 IF OBJECT_ID('tempdb..#ProjectemployeedataCognizant', 'U') IS NOT NULL      
 BEGIN      
           DROP TABLE #ProjectemployeedataCognizant      
 END       
       
 IF OBJECT_ID('tempdb..#ServiceDataCognizant', 'U') IS NOT NULL      
 BEGIN      
           DROP TABLE #ServiceDataCognizant      
 END       
       
 IF OBJECT_ID('tempdb..#ServicelstDataCognizant', 'U') IS NOT NULL      
 BEGIN      
           DROP TABLE #ServicelstDataCognizant      
 END       
 IF OBJECT_ID('tempdb..#ProjectemployeedataCustomer', 'U') IS NOT NULL      
 BEGIN      
           DROP TABLE #ProjectemployeedataCustomer      
 END       
       
 IF OBJECT_ID('tempdb..#ServiceDataCustomer', 'U') IS NOT NULL      
 BEGIN      
           DROP TABLE #ServiceDataCustomer      
 END       
       
 IF OBJECT_ID('tempdb..#ServicelstDataCustomer', 'U') IS NOT NULL      
 BEGIN      
           DROP TABLE #ServicelstDataCustomer      
 END       
 IF OBJECT_ID('tempdb..#JobGrade', 'U') IS NOT NULL      
 BEGIN      
           DROP TABLE #JobGrade      
 END       
      
 IF OBJECT_ID('tempdb..#employeedetails', 'U') IS NOT NULL      
 BEGIN      
  DROP TABLE #employeedetails      
 END      
      
      
  END TRY      
  BEGIN CATCH         
      
  DECLARE @ErrorMessage VARCHAR(MAX);      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
      
  --- Insert Error Message ---      
  EXEC AVL_InsertError '[AVL].[GetTicketModuleUserDetails]', @ErrorMessage, 0, 0      
                     
  END CATCH      
END
