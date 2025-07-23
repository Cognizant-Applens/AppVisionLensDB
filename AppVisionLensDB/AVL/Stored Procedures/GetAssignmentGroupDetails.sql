/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[GetAssignmentGroupDetails]  
@ProjectID bigint,  
@EmployeeID varchar(20),  
@CustomerID varchar(20)  
AS  
BEGIN 
SET NOCOUNT OFF;
BEGIN TRY  
   
 exec [AVL].[GetAssignamentGroupMasterData]  
 --drop TABLE #TicketCountTemp  
 select  
 (CASE WHEN (COUNT(TD.TimeTickerID)>0 or COUNT(ITD.TimeTickerID)>0 or COUNT(BTD.TimeTickerID)>0) THEN 1 ELSE 0 END) as 'TicketCount'  
 ,AGM.AssignmentGroupMapID as 'AssignmentGroupMapID'  
 into #TicketCountTemp  
  from AVL.BOTAssignmentGroupMapping AGM (NOLOCK)   
 left join AVL.TK_TRN_TicketDetail TD (NOLOCK)  on TD.AssignmentGroupID=AGM.AssignmentGroupMapID and TD.IsDeleted=0  
 left join AVL.TK_TRN_InfraTicketDetail ITD (NOLOCK)  on ITD.AssignmentGroupID=AGM.AssignmentGroupMapID and ITD.IsDeleted=0  
 left join AVL.TK_TRN_BOTTicketDetail BTD (NOLOCK)  on BTD.AssignmentGroupID=AGM.AssignmentGroupMapID and BTD.IsDeleted=0  
 where AGM.ProjectID=@ProjectID and AGM.IsDeleted=0   
 GROUP by AGM.AssignmentGroupMapID  
  
 SELECT   
 COUNT(UAG.ID) as 'UserCount'  
 ,temp.TicketCount as 'TicketCount'--(CASE WHEN (COUNT(TD.TimeTickerID)>0 or COUNT(ITD.TimeTickerID)>0 or COUNT(BTD.TimeTickerID)>0) THEN 1 ELSE 0 END) as 'TicketCount'  
 ,AGM.AssignmentGroupMapID  
 ,AGM.ProjectID  
 ,AGM.AssignmentGroupName  
 ,MAG.AssignmentGroupTypeID as CategoryID  
 ,MAG.AssignmentGroupTypeName as CategoryName  
 ,STM.SupportTypeId as SupportTypeID  
 ,STM.SupportTypeName as SupportTypeName  
 ,AGM.IsBotGroup  
 FROM AVL.BOTAssignmentGroupMapping AGM (NOLOCK)  
 join AVL.MAS_AssignmentGroupType MAG (NOLOCK) on MAG.AssignmentGroupTypeID=AGM.AssignmentGroupCategoryTypeID  
 join AVL.SupportTypeMaster STM (NOLOCK) on STM.SupportTypeId=AGM.SupportTypeID  
 LEFT JOIN AVL.UserAssignmentGroupMapping UAG (NOLOCK) on UAG.AssignmentGroupMapID=AGM.AssignmentGroupMapID and UAG.IsDeleted=0  
 join #TicketCountTemp temp (NOLOCK) on temp.AssignmentGroupMapID=AGM.AssignmentGroupMapID  
 where AGM.ProjectID=@ProjectID and AGM.IsDeleted=0 and MAG.IsDeleted=0 and STM.IsDeleted=0  
 GROUP BY  
 AGM.AssignmentGroupMapID  
 ,AGM.ProjectID  
 ,AGM.AssignmentGroupName  
 ,MAG.AssignmentGroupTypeID   
 ,MAG.AssignmentGroupTypeName  
 ,STM.SupportTypeId  
 ,STM.SupportTypeName  
 ,AGM.IsBotGroup  
 ,temp.TicketCount  
END TRY  
    
BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[GetAssignmentGroupDetails]', @ErrorMessage, 0,0  
 END CATCH   
 SET NOCOUNT OFF;
END
