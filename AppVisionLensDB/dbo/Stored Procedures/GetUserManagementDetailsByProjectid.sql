
CREATE PROCEDURE [dbo].[GetUserManagementDetailsByProjectid]   
(  
 @CustomerID VARCHAR(20) = null,  
 @ProjectID  VARCHAR(20) = null  
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
   Designation nvarchar(100),
   PODDetailID varchar(100),
   PODName nvarchar(100),  
   RoleID int,
   RoleName nvarchar(100),
   LocationName nvarchar(100),
   TSApproverID nvarchar(100),
   TSApproverName nvarchar(200),
   MandatoryHours decimal(6,2),
   TicketingModuleEnabled bit
   )
   
 --SELECT DISTINCT   
 -- LM1.EmployeeID,  
 -- LM1.EmployeeName,  
 -- CASE WHEN LM1.ClientUserID = '' OR LM1.ClientUserID IS NULL THEN '0' ELSE LM1.ClientUserID END AS ClientUserID,  
 -- LM1.TimeZoneId,  
 -- TZ.TimeZoneName,  
 -- LM1.LocationID,  
 -- L.City LocationName,  
 -- CASE WHEN LM1.TSApproverID IS NULL OR LM1.TSApproverID = ''   
 --  THEN LM1.HcmSupervisorID   
 --  ELSE LM1.TSApproverID   
 -- END TSApproverID,  
 -- '                                                   ' TSApproverName,  
 -- CASE WHEN ISNULL(JG.Grade, '') <> '' AND LM1.MandatoryHours IS NULL THEN 8 ELSE LM1.MandatoryHours END AS MandatoryHours,  
 -- LM1.TicketingModuleEnabled   
 --INTO #temp2   
 --FROM [AVL].[MAS_LoginMaster](NOLOCK) LM1     
 --LEFT JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ ON TZ.TimeZoneID = LM1.TimeZoneId  
 --LEFT JOIN  ESA.[LocationMaster](NOLOCK) L ON L.ID = LM1.LocationID  
 ----LEFT JOIN ESA.Associates(NOLOCK) E ON LM1.EmployeeID = E.AssociateID  
 --LEFT JOIN #JobGrade(NOLOCK) JG ON JG.EmployeeID = LM1.EmployeeID --AND JG.Grade = E.Grade  
 --WHERE LM1.customerid = @CustomerID AND LM1.ProjectID = @ProjectID AND LM1.isdeleted = 0 ----1053  

 --Multi  Select POD Details
Select UserId,CAST(PODDetailID AS varchar) AS PODDetailID Into #TPOD
From  ADM.AssociateAttributes WHERE IsDeleted=0

			SELECT [UserId], PODDetailID = 
				STUFF((SELECT ', ' + PODDetailID
					   FROM #TPOD b 
					   WHERE b.[UserId] = a.[UserId] 
					  FOR XML PATH('')), 1, 2, '') into #TPODDetails
			FROM #TPOD a
			GROUP BY [UserId]

--Updated TimeZone for dropdown not selected manually
UPDATE LM1   
 SET LM1.TimeZoneId = MTZL.TimeZoneID, LM1.ModifiedDate=GETDATE()
FROM [AVL].[MAS_LoginMaster](NOLOCK) LM1     
  INNER JOIN ESA.[LocationMaster](NOLOCK) L ON L.ID = LM1.LocationID
INNER JOIN [AVL].[Map_TimeZone_Location](NOLOCK) MTZL ON MTZL.Country = L.Country
INNER JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ ON TZ.TimeZoneID = MTZL.TimeZoneId 
 where LM1.customerid = @CustomerID AND LM1.ProjectID = @ProjectID AND LM1.isdeleted = 0 AND
(LM1.TimeZoneId = 0 OR LM1.TimeZoneId IS NULL) and (LocationID IS NOT NULL AND LocationID <> 0)

 Insert into #temp2
 SELECT DISTINCT   
  LM1.EmployeeID,  
  LM1.EmployeeName,  
  CASE WHEN LM1.ClientUserID = '' OR LM1.ClientUserID IS NULL THEN '0' ELSE LM1.ClientUserID END AS ClientUserID,  
  LM1.TimeZoneId,  
  TZ.TimeZoneName,  
  LM1.LocationID,
  AS1.Designation, 
  --ADM.PODDetailID,
  PD.PODDetailID,
  --ADM.CCARole,
  POD.PODName, 
  RM.RoleID,
  RM.RoleName,
  L.City as LocationName,  
  CASE WHEN LM1.TSApproverID IS NULL OR LM1.TSApproverID = ''   
   THEN LM1.HcmSupervisorID   
   ELSE LM1.TSApproverID   
  END TSApproverID,  
  null,  
 CASE WHEN ISNULL(JG.Grade, '') <> '' AND LM1.MandatoryHours IS NULL and L.Country='IND' and L.City not in('noida','Kolkata') THEN 9
   WHEN ISNULL(JG.Grade, '') <> '' AND LM1.MandatoryHours IS NULL and L.Country='IND' and L.City  in('noida','Kolkata') THEN 8
   WHEN ISNULL(JG.Grade, '') <> '' AND LM1.MandatoryHours IS NULL and L.Country<>'IND'  THEN 8 ELSE LM1.MandatoryHours END AS MandatoryHours, 
  LM1.TicketingModuleEnabled   
 --INTO #temp2   
 FROM [AVL].[MAS_LoginMaster](NOLOCK) LM1     
 LEFT JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ ON TZ.TimeZoneID = LM1.TimeZoneId 
 LEFT JOIN  ESA.[LocationMaster](NOLOCK) L ON L.ID = LM1.LocationID  
 LEFT JOIN ESA.Associates (NOLOCK) AS1 on AS1.AssociateID=LM1.EmployeeID
 LEFT JOIN ADM.AssociateAttributes (NOLOCK) ADM ON ADM.UserId=LM1.UserID
 LEFT JOIN PP.Project_PODDetails (NOLOCK) POD on POD.ProjectID = LM1.ProjectID and POD.PODDetailID = ADM.PODDetailID AND POD.IsDeleted=0 
 LEFT JOIN [PP].[ALM_MAP_UserRoles] (NOLOCK) UR  ON LM1.EmployeeID = UR.EmployeeID
 LEFT JOIN [PP].[ALM_RoleMaster](NOLOCK) RM ON RM.RoleID=UR.RoleID
 LEFT JOIN #JobGrade(NOLOCK) JG ON JG.EmployeeID = LM1.EmployeeID --AND JG.Grade = E.Grade  
 LEFT JOIN #TPODDetails PD on ADM.UserId=PD.UserId
 WHERE LM1.customerid = @CustomerID AND LM1.ProjectID = @ProjectID AND LM1.isdeleted = 0 ----1053 

 UPDATE T   
 SET t.TSApproverName = l.EmployeeName  
 FROM #temp2 t   
 INNER JOIN AVL.MAS_LoginMaster(NOLOCK) l   
  ON l.EmployeeID = t.TSApproverID  
  
 SELECT rn,EmployeeID,EmployeeName,ClientUserID,TimeZoneId,TimeZoneName,LocationID,Designation,
	PODDetailID,PODName,RoleID,RoleName,LocationName,TSApproverID,TSApproverName,MandatoryHours,TicketingModuleEnabled 
FROM ( SELECT ROW_NUMBER() OVER(  
                    PARTITION BY EmployeeID  
                    ORDER BY EmployeeID DESC) AS rn ,EmployeeID,
								EmployeeName,ClientUserID,
								TimeZoneId,TimeZoneName,
								LocationID,Designation,
								PODDetailID,PODName,
								RoleID,RoleName,LocationName,
								TSApproverID,TSApproverName,
								MandatoryHours,TicketingModuleEnabled FROM #temp2) T WHERE T.rn = 1   
 DROP TABLE #temp2  
 DROP TABLE #JobGrade
 DROP TABLE #TPODDetails
 DROP TABLE #TPOD

    
    SET NOCOUNT OFF;   
END

