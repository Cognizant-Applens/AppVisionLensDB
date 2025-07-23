/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		201422
-- Create date: 11-FEB-2019
-- Description:	 SP for Ticket Module user details
-- dbo.GetRHMSUserServiceLevelData 7097,10337
-- =============================================
CREATE PROC [dbo].[GetRHMSUserServiceLevelData](
@CustomerID nvarchar(50),
@ProjectId nvarchar(50))
AS
BEGIN
BEGIN TRY
--gettting distinct employee id under the customer and the project

 select DISTINCT LM.EmployeeID into #employeedetails from AVL.MAS_LoginMaster (NOLOCK) LM
 where LM.ProjectID=@ProjectId and LM.CustomerID=@CustomerID and LM.IsDeleted=0

--getting Project access under customer

 select Distinct PM.EsaProjectID,PM.ProjectID, PM.ProjectName,LM.EmployeeID, E.AssociateName as EmployeeName,
 LM.ClientUserID,TZ.TimeZoneName,L.City AS LocationName,LM.TSApproverID,
 A.AssociateName as TSApproverName,
 LM.MandatoryHours,
 LM.TicketingModuleEnabled,
 LM.IsNonESAAuthorized
 into #Projectemployeedata
 from AVL.MAS_LoginMaster (NOLOCK) LM  
 LEFT JOIN AVL.MAS_ProjectMaster(NOLOCK) PM on PM.ProjectID=LM.ProjectID
 LEFT JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ on TZ.TimeZoneID=LM.TimeZoneId
 LEFT JOIN  ESA.[LocationMaster](NOLOCK) L on L.ID=LM.LocationID
 LEFT JOIN ESA.Associates(NOLOCK) E on Lm.EmployeeID=E.AssociateID
 LEFT JOIN ESA.Associates(NOLOCK) A on LM.TSApproverID=A.AssociateID
 where  LM.CustomerID=@CustomerID and
 LM.EmployeeID in (Select EmployeeID from #employeedetails) and lm.IsDeleted=0

 --getting servicelevel access data for each project and employeeid

  select PED.ProjectID,PED.Employeeid,SL.ServiceLevelName AS serviceData,SL.ServiceLevelName AS servicecolumnname
  into #ServiceData 
  from #Projectemployeedata PED 
  JOIN AVL.UserServiceLevelMapping SLM on SLM.EmployeeID=PED.EmployeeID and SLM.ProjectID=PED.ProjectID
  JOIN AVL.MAS_ServiceLevel SL on SL.ServiceLevelID=SLM.ServiceLevelID
  WHERE SLM.CustomerID=@CustomerID
  order by employeeid,projectid


--coverting the service level name to columns using pivot

select DISTINCT ProjectID,Employeeid,L1, L2, L3, L4, Others into #ServicelstData
from
(
  select Employeeid,ProjectID,serviceData,servicecolumnname
  from #ServiceData
) d
pivot
(
  max(serviceData)
  for servicecolumnname in (L1, L2, L3, L4, Others) 
) piv ORDER by Employeeid;

--Result based on the requirement

select DISTINCT  
	PED.EsaProjectID AS [ProjectID],
	PED.ProjectName,
	PED.EmployeeID,
	PED.EmployeeName,
	PED.ClientUserID As ExternalLoginID,
	PED.TimeZoneName,
	PED.LocationName,
	PED.TSApproverID,
	PED.TSApproverName,
	PED.MandatoryHours,
	CASE WHEN PED.TicketingModuleEnabled=1 THEN 'Y' ELSE 'N' END AS IsEffortTracking,
	CASE WHEN SD.L1='L1' THEN 'Y' ELSE 'N' END AS L1,
	CASE WHEN SD.L2='L2' THEN 'Y' ELSE 'N' END AS L2,
	CASE WHEN SD.L3='L3' THEN 'Y' ELSE 'N' END AS L3,
	CASE WHEN SD.L4='L4' THEN 'Y' ELSE 'N' END AS L4,
	CASE WHEN SD.Others='Others' THEN 'Y' ELSE 'N' END AS Others,
	CASE WHEN PED.IsNonESAAuthorized = 1 THEN 'N' ELSE 'Y' END AS IsESAAllocated
	from #Projectemployeedata PED 
	LEFT JOIN #ServicelstData SD on PED.Employeeid=SD.Employeeid AND PED.ProjectID=SD.ProjectID
	ORDER By employeeid

--dropping the hashTables

 Drop table #employeedetails
 Drop Table #Projectemployeedata
 Drop table #ServiceData
 Drop table #ServicelstData

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'dbo.GetRHMSUserServiceLevelData',@ErrorMessage,0,@CustomerID

END CATCH
END
