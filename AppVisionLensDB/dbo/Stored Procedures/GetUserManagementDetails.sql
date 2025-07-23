/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--exec [dbo].[GetUserManagementDetails]  6
CREATE Procedure [dbo].[GetUserManagementDetails] (
@CustomerID varchar(20)
)
AS
BEGIN
 SET NOCOUNT ON;  
	--DECLARE @result bit
	--BEGIN TRY
	
	select distinct 
	-- UserID, 
	LM1.EmployeeID,
	LM1.EmployeeName,
	CASE WHEN LM1.ClientUserID ='' OR LM1.ClientUserID IS NULL THEN '0' ELSE LM1.ClientUserID END AS ClientUserID,
	-- ServiceLevelID,
	--SL.ServiceLevelName,
	LM1.TimeZoneId,
	TZ.TimeZoneName,
	LM1.LocationID,
	L.City LocationName,
	case when LM1.TSApproverID is null or LM1.TSApproverID='' then Lm1.HcmSupervisorID else LM1.TSApproverID end TSApproverID ,
	--'                                                   ' TSApproverName ,
	Cast('' as Varchar(max)) TSApproverName,
	LM1.TicketingModuleEnabled into #temp2 from  [AVL].[MAS_LoginMaster] LM1	
		
		 
		left join avl.MAS_TimeZoneMaster TZ on TZ.TimeZoneID=LM1.TimeZoneId
		--inner join [AVL].[UserServiceLevelMapping] SM on SM.EmployeeID= LM1.EmployeeID
		--inner join #temp t1 on t1.EmployeeID=Sm.EmployeeID
		--inner join [AVL].[MAS_ServiceLevel] SL on SM.ServiceLevelID=SL.ServiceLevelID 
		left join  esa.LocationMaster L
		--[MAS].[LocationMaster] L 
		on L.ID=LM1.LocationID --and L.IsDeleted=0
		
		where LM1.customerid=@CustomerID and LM1.isdeleted=0 
		--and LM1.Roleid<>1
		uPDATE T SET t.TSApproverName=l.EmployeeName FROM #temp2 t INNER JOIN AVL.MAS_LoginMaster l ON l.EmployeeID=t.TSApproverID

	    select * from (select    row_number() over (
                    partition by EmployeeID
                    order by EmployeeID desc) as rn ,* from #temp2)T where T.rn=1 
		drop table #temp2

	 
    SET NOCOUNT OFF; 
END
