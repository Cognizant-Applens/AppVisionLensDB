/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE Procedure [dbo].[SaveServiceLevelDetails]     
(    
@ServiceLevelDetails [dbo].[TVP_SaveProjectServiceLevelDetails] Readonly    
)    
AS    
BEGIN    
DECLARE @result bit    
declare @CustomerID bigint    
declare @IsCognizant int     
declare @IsNonEsaMapAllowed int    
    
set @CustomerID=(select DISTINCT CustomerID from @ServiceLevelDetails)    
set @IsCognizant=(select IsCognizant from AVL.Customer where CustomerID=@CustomerID and IsDeleted=0)    
set @IsNonEsaMapAllowed=(select IsNonESAMappingAllowed from AVL.Customer where CustomerID=@CustomerID and IsDeleted=0)    
     
 select * into #TVP from @ServiceLevelDetails    
    
 DELETE B    
FROM @ServiceLevelDetails T INNER JOIN [AVL].[UserServiceLevelMapping] B    
ON B.EmployeeID=T.EmployeeID and B.CustomerID=T.CustomerID;    
    
--DELETE from @ServiceLevelDetails where IsESAAllocated=4    
delete from #TVP where [IsESAAllocated] = 4    
    
INSERT INTO [AVL].[UserServiceLevelMapping]    
(EmployeeID,CustomerID,ServiceLevelID,CreatedBy,CreatedDate,ProjectID)    
SELECT DISTINCT t.EmployeeID,t.CustomerID,t.ServiceLevelID,t.EmployeeID,getdate(),ProjectID FROM #TVP t--@ServiceLevelDetails t    
where t.ServiceLevelID!=''    
     
 if(@IsCognizant=1) -- and @IsNonEsaMapAllowed=1)    
 BEGIN    
create table #LoginTemp    
 (EmployeeID Varchar(20),    
   ClientUserID Varchar(20),    
  EmployeeName Varchar(200),    
  EmployeeEmail Varchar(200),    
  ProjectID Varchar(20),    
  CustomerID Varchar(20),    
  HcmSupervisorID Varchar(20),    
  TSApproverID Varchar(20),    
  EffectiveDate datetime,    
  TimeZoneId  Varchar(20),    
  MandatoryHours int,    
  EffectiveEndDate datetime,    
  Billability_type  Varchar(20),    
  RoleID int,    
  IsAutoassignedTicket varchar(20),    
  ServiceLevelID  Varchar(20),    
  CreatedDate datetime,    
  CreatedBy  Varchar(20),    
  TicketingModuleEnabled  Varchar(20),    
  IsDefaultProject int,    
  IsEffortTrackingEnabled int,    
  IsESAAllocated int)    
    
CREATE table #TempTVP    
(    
[EmployeeID] [nvarchar](100) NULL,    
 [CustomerID] [nvarchar](100) NULL,    
 [IsESAAllocated] [nvarchar](100) NULL,    
 [ProjectID] [nvarchar](100) NULL    
)    
    
    
insert into #TempTVP    
select DISTINCT EmployeeID,CustomerID,IsESAAllocated,ProjectID from #TVP where IsESAAllocated not in (3,4)    
    
--SELECT * from #TempTVP    
 --Moving existing employee details based on customer and employee from loginmaster to temp table    
     
select top 1 T.EmployeeID,    
   T.EmployeeID as clientID,    
  LMas.EmployeeName,    
  LMas.EmployeeEmail,    
 T.ProjectID,    
  T.CustomerID,    
  LMas.HcmSupervisorID,    
  LMas.TSApproverID,    
  LMas.EffectiveDate,    
  LMas.TimeZoneId,    
  LMas.MandatoryHours,    
  LMas.EffectiveEndDate,    
  LMas.Billability_type,    
  LMas.RoleID,    
  LMas.IsAutoassignedTicket,    
  LMAS.ServiceLevelID,    
  getdate() as CreatedDate,    
  T.EmployeeID as employee,    
  LMas.TicketingModuleEnabled,    
  LMas.IsDefaultProject,    
  LMas.IsEffortTrackingEnabled,    
  T.IsESAAllocated into #loginMas    
  from AVL.MAS_LoginMaster LMas    
join #TempTVP T on LMas.EmployeeID=T.EmployeeID and LMas.CustomerID=T.CustomerID and LMas.IsDeleted=0 --and LMas.ProjectID=T.ProjectID --and LMas.IsDeleted=0)    
    
SELECT * FROM #LoginMas    
    
insert into #LoginTemp    
select DISTINCT    
 T.EmployeeID,    
   T.EmployeeID,    
  LMas.EmployeeName,    
  LMas.EmployeeEmail,    
 T.ProjectID,    
  T.CustomerID,    
  LMas.HcmSupervisorID,    
  LMas.TSApproverID,    
  LMas.EffectiveDate,    
  LMas.TimeZoneId,    
  LMas.MandatoryHours,    
  LMas.EffectiveEndDate,    
  LMas.Billability_type,    
  LMas.RoleID,    
  LMas.IsAutoassignedTicket,    
  LMAS.ServiceLevelID,    
  getdate(),    
  T.EmployeeID,    
  LMas.TicketingModuleEnabled,    
  LMas.IsDefaultProject,    
  LMas.IsEffortTrackingEnabled,    
  T.IsESAAllocated    
   from #loginMas LMas    
join #TempTVP T on LMas.EmployeeID=T.EmployeeID and LMas.CustomerID=T.CustomerID --and LMas.ProjectID=T.ProjectID --and LMas.IsDeleted=0)    
    
    
select * from #LoginTemp    
    
 INSERT INTO AVL.MAS_LoginMaster    
  (EmployeeID,    
   ClientUserID,    
  EmployeeName,    
  EmployeeEmail,    
  ProjectID,    
  CustomerID,    
  HcmSupervisorID,    
  TSApproverID,    
  EffectiveDate,    
  TimeZoneId,    
  MandatoryHours,    
  EffectiveEndDate,    
  Billability_type,    
  RoleID,    
  IsAutoassignedTicket,    
  ServiceLevelID,    
  CreatedDate,    
  CreatedBy,    
  TicketingModuleEnabled,    
  IsDefaultProject,    
  IsEffortTrackingEnabled,    
  IsNonESAAuthorized)    
  SELECT DISTINCT TRIM(LT.EmployeeID),LT.EmployeeID,LT.EmployeeName,LT.EmployeeEmail,LT.ProjectID,LT.CustomerID,    
  LT.HcmSupervisorID,LT.TSApproverID,LT.EffectiveDate,LT.TimeZoneId,LT.MandatoryHours,LT.EffectiveEndDate,    
  LT.Billability_type,LT.RoleID,LT.IsAutoassignedTicket,LT.ServiceLevelID,    
  GETDATE(),LT.CreatedBy,LT.TicketingModuleEnabled,LT.IsDefaultProject,LT.IsEffortTrackingEnabled,    
  LT.IsESAAllocated from #LoginTemp LT     
  WHERE  NOT EXISTS (SELECT 1 FROM AVL.MAS_LoginMaster LM     
  WHERE LT.ProjectID=LM.ProjectID and LT.EmployeeID=LM.EmployeeID     
  and LT.CustomerID=LM.CustomerID) --and LT.CustomerID=TVP.CustomerID and LT.EmployeeID=TVP.EMployeeID     
    
     
     
  UPDATE L    
  SET     
  ProjectID=TVP1.ProjectID,    
  CustomerID=TVP1.CustomerID,    
  IsNonESAAuthorized=TVP1.IsESAAllocated,    
  IsDeleted=0,    
  ModifiedBy= TVP1.EmployeeID,    
  ModifiedDate  = GetDate()    
  FROM AVL.MAS_LoginMaster L     
  INNER JOIN #TVP TVP1 ON TVP1.EMployeeID=L.EmployeeID    
  AND TVP1.CustomerID=L.CustomerID and TVP1.ProjectID=L.ProjectID    
  --where EXISTS(SELECT 1 FROM AVL.MAS_LoginMaster L1 WHERE TVP1.EMployeeID=L1.EmployeeID    
  --AND TVP1.CustomerID=L1.CustomerID and TVP1.ProjectID=L1.ProjectID and L1.IsDeleted=1)    
    
   UPDATE L    
  SET     
  ProjectID=TVP1.ProjectID,    
  CustomerID=TVP1.CustomerID,    
  IsNonESAAuthorized=TVP1.IsESAAllocated,    
  IsDeleted=1,    
  ModifiedBy= TVP1.EmployeeID,    
  ModifiedDate  = GetDate()    
  FROM AVL.MAS_LoginMaster L     
  INNER JOIN #TVP TVP1 ON TVP1.EMployeeID=L.EmployeeID    
  AND TVP1.CustomerID=L.CustomerID and TVP1.ProjectID=L.ProjectID    
  where EXISTS(SELECT 1 FROM AVL.MAS_LoginMaster L1 WHERE TVP1.EMployeeID=L1.EmployeeID    
  AND TVP1.CustomerID=L1.CustomerID and TVP1.ProjectID=L1.ProjectID and L1.IsDeleted=0 and TVP1.IsESAAllocated=3)    
    
END    
SET @result= 1    
  SELECT @result AS RESULT   
  IF EXISTS(Select Top 1 * from #TempTVP)  
  BEGIN   
 DROP TABLE #TempTVP  
  END  
   IF EXISTS(Select Top 1 * from #LoginTemp)  
  BEGIN  
 DROP TABLE #LoginTemp    
  END  
END    
    
--select * from [AVL].[UserServiceLevelMapping] where EmployeeID='515869'    
    
    
--select * from AVL.MAS_LoginMaster where CustomerID=203 and employeeid=548986    
    
    
--update AVL.MAS_LoginMaster set IsNonESAAuthorized=1 where ProjectID in (251) and UserID in (2627) 

