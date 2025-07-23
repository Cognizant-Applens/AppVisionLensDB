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
-- Author:		<>
-- Create date: <>
-- Description:	<>
-- Execution  : --[AVL].[GetHealticketdetailsList] '',''  
-- =============================================
CREATE PROCEDURE [AVL].[GetHealticketdetailsList]  
@FromDate NVARCHAR(50),  
@ToDate NVARCHAR(50)  
AS  
BEGIN  
 BEGIN TRY   
      SET @FromDate = @FromDate + ' 00:00:00.00'  
      SET @ToDate =  @ToDate + ' 23:59:59:000' 
		select 
		'Application Healing Solution' AS Category  
		,'The Iron Pillar' AS Award  
		,TTT.ProjectID
		,ML.EmployeeID
		,ML.EmployeeName
		,MP.EsaProjectID
		,MP.ProjectName
		,MP.CustomerID AS AccountId
		,AC.CustomerName AS AccountName
		,DATENAME(month, @FromDate) AS CertificationMonth
		,DATENAME(Year, @FromDate) AS CertificationYear
		,count(TTT.TicketID) as NoOfHTicketsClosed
		,count (DTH.SolutionType) AS SolutionIdentified
		,count(ISNULL(DTH.IncidentReductionMonth,0)) AS IncReductionMonth
		,count(ISNULL(DTH.EffortReductionMonth,0)) AS EffortReductionMonth
		into #temTran
		 from  [AVL].[TK_TRN_TicketDetail](nolock) AS TTT Left join AVL.TK_MAP_TicketTypeMapping(nolock) AS TMT on 
		TTT.TicketTypeMapID=TMT.TicketTypeMappingID join avl.debt_trn_HealTicketDetails  AS DTH on TTT.TicketID=DTH.HealingTicketID
		left join avl.MAS_LoginMaster(nolock) ML on TTT.AssignedTo=ML.UserID
		left join avl.MAS_ProjectMaster(nolock) MP on TTT.ProjectID =MP.ProjectID
		inner join  avl.customer(nolock) AS AC on MP.CustomerID=AC.CustomerID
		where TTT.Closeddate >= @FromDate
		and TTT.Closeddate <=  @ToDate and TTT.IsDeleted=0
		and TMT.AVMTicketType=10 group by TTT.AssignedTo,TTT.ProjectID
		,ML.EmployeeID
		,ML.EmployeeName
		,MP.EsaProjectID
		,MP.ProjectName
		,MP.CustomerID 
		,AC.CustomerName


		
		insert into #temTran select 
		'Application Healing Solution' AS Category  
		,'The Iron Pillar' AS Award  
		,TTT.ProjectID
		,ML.EmployeeID
		,ML.EmployeeName
		,MP.EsaProjectID
		,MP.ProjectName
		,MP.CustomerID AS AccountId
		,AC.CustomerName AS AccountName
		,DATENAME(month, @FromDate) AS CertificationMonth
		,DATENAME(Year, @FromDate) AS CertificationYear
		,count(TTT.TicketID) as NoOfHTicketsClosed
		,count (DTH.SolutionType) AS SolutionIdentified
		,0 AS IncReductionMonth
		,0 AS EffortReductionMonth
		 from  [AVL].[TK_TRN_infraTicketDetail](nolock) AS TTT Left join AVL.TK_MAP_TicketTypeMapping(nolock) AS TMT on 
		TTT.TicketTypeMapID=TMT.TicketTypeMappingID join avl.[DEBT_TRN_InfraHealTicketDetails]  AS DTH on TTT.TicketID=DTH.HealingTicketID
		left join avl.MAS_LoginMaster(nolock) ML on TTT.AssignedTo=ML.UserID
		left join avl.MAS_ProjectMaster(nolock) MP on TTT.ProjectID =MP.ProjectID
		inner join  avl.customer(nolock) AS AC on MP.CustomerID=AC.CustomerID
		where TTT.Closeddate >= @FromDate
		and TTT.Closeddate <=  @ToDate and TTT.IsDeleted=0
		and TMT.AVMTicketType=10 group by TTT.AssignedTo,TTT.ProjectID
		,ML.EmployeeID
		,ML.EmployeeName
		,MP.EsaProjectID
		,MP.ProjectName
		,MP.CustomerID 
		,AC.CustomerName


		select 
		'Application Healing Solution' as ModuleId 
		,ML.EmployeeID
		,TTT.ProjectID  
		,TTT.TicketID as ReferenceId
		INTO #tempRefer
		from  [AVL].[TK_TRN_TicketDetail](nolock) AS TTT Left join AVL.TK_MAP_TicketTypeMapping(nolock) AS TMT on 
		TTT.TicketTypeMapID=TMT.TicketTypeMappingID 
		join avl.debt_trn_HealTicketDetails  AS DTH on TTT.TicketID=DTH.HealingTicketID
		left join avl.MAS_LoginMaster(nolock) ML on TTT.AssignedTo=ML.UserID
		where TTT.Closeddate >= @FromDate
		and TTT.Closeddate <=  @ToDate and TTT.IsDeleted=0
		and TMT.AVMTicketType=10 group by TTT.AssignedTo,TTT.ProjectID,TTT.TicketID,ML.EmployeeID


		Insert into #tempRefer select 
		'Application Healing Solution' as ModuleId 
		,ML.EmployeeID
		,TTT.ProjectID  
		,TTT.TicketID as ReferenceId
		from  [AVL].[TK_TRN_infraTicketDetail](nolock) AS TTT Left join AVL.TK_MAP_TicketTypeMapping(nolock) AS TMT on 
		TTT.TicketTypeMapID=TMT.TicketTypeMappingID 
		join [AVL].[DEBT_TRN_InfraHealTicketDetails]  AS DTH on TTT.TicketID=DTH.HealingTicketID
		left join avl.MAS_LoginMaster(nolock) ML on TTT.AssignedTo=ML.UserID
		where TTT.Closeddate >= @FromDate
		and TTT.Closeddate <=  @ToDate and TTT.IsDeleted=0
		and TMT.AVMTicketType=10 group by TTT.AssignedTo,TTT.ProjectID,TTT.TicketID,ML.EmployeeID

		select Category,Award,ProjectID,EmployeeID,EmployeeName,EsaProjectID,
		ProjectName,AccountId,AccountName,CertificationMonth,CertificationYear,
		NoOfHTicketsClosed,SolutionIdentified,IncReductionMonth,EffortReductionMonth from #temTran

		select ModuleId,EmployeeID,ProjectID,ReferenceId from #tempRefer

		drop table #temTran
		drop table #tempRefer
  
  
  
 END TRY    
 BEGIN CATCH  
  DECLARE @ErrorMessage VARCHAR(4000);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error                                      
  EXEC AVL_InsertError '[AVL].[GetHealticketdetailsList]'  
   ,@ErrorMessage  
   ,0  
 END CATCH  
END
