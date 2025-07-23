/***************************************************************************    
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET    
*Copyright [2018] – [2021] Cognizant. All rights reserved.    
*NOTICE: This unpublished material is proprietary to Cognizant and    
*its suppliers, if any. The methods, techniques and technical    
  concepts herein are considered Cognizant confidential and/or trade secret information.     
      
*This material may be covered by U.S. and/or foreign patents or patent applications.     
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.    
***************************************************************************/    
    

CREATE PROCEDURE [AVL].[GetTicketModuleAddNewUserDetails]  --136408,12885   
(      
       @ProjectID NVARCHAR(20),       
       @CustomerID NVARCHAR(10)         
)      
AS      
BEGIN      
   BEGIN TRY          
      
  SELECT DISTINCT PM.EsaProjectID,      
      PM.ProjectID,       
      PM.ProjectName,      
      LM.UserID,      
      LM.EmployeeID , 
      LM.EmployeeName AS EmployeeName,
	  LM.EmployeeEmail,
      LM.ClientUserID,      
      LM.TimeZoneId ,      
      TZ.TimeZoneName,           
      LM.TSApproverID,      
      CASE WHEN  LM.MandatoryHours IS NULL THEN 8 ELSE LM.MandatoryHours END AS MandatoryHours,      
      LM.IsDeleted,      
      LM.IsNonESAAuthorized,
	  NULL AS IsEmployeeEditable
  INTO #ProjectemployeedataCustomer      
  FROM AVL.MAS_LoginMaster (NOLOCK) LM         
  INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.ProjectID=LM.ProjectID      
  LEFT JOIN avl.MAS_TimeZoneMaster(NOLOCK) TZ ON TZ.TimeZoneID=LM.TimeZoneId      
  WHERE  LM.CustomerID=@CustomerID       
  AND LM.IsDeleted=0 AND ISNULL(LM.IsNonESAAuthorized,0)=0 AND LM.ProjectID=@ProjectID      
      
  CREATE TABLE #TicketCount(
   EmployeeId nvarchar(50),
   COUN INT
  )

  INSERT INTO #TicketCount
  SELECT t.EmployeeID,Count(TicketId) AS COUN 
  FROM  #ProjectemployeedataCustomer t
  JOIN AVL.TK_TRN_TicketDetail(NOLOCK) td
  ON (td.assignedto = t.UserId or td.createdby = t.EmployeeID)
  AND td.projectid = @ProjectID 
  GROUP BY t.EmployeeID

  INSERT INTO #TicketCount
  SELECT t.EmployeeID,Count(TicketId) AS COUN 
  FROM  #ProjectemployeedataCustomer t
  JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) td
  ON (td.assignedto = t.UserId or td.createdby = t.EmployeeID)
  AND td.projectid = @ProjectID 
  GROUP BY t.EmployeeID

  SELECT DISTINCT EmployeeId,SUM(COUN) AS Sums
  INTO #TicketCounts
  FROM #TicketCount 
  GROUP BY EmployeeId

  UPDATE #ProjectemployeedataCustomer SET IsEmployeeEditable = 1

  UPDATE tc
  SET tc.IsEmployeeEditable = 0
  from #ProjectemployeedataCustomer tc
  join #TicketCounts t2
  ON t2.EmployeeID = tc.EmployeeID
 
 SELECT  DISTINCT       
   PED.EmployeeID AS 'Employee ID',      
   PED.EmployeeName as 'Employee Name',
   PED.EmployeeEmail as 'Employee Email',
   PED.ClientUserID As 'External Login ID',        
   PED.TimeZoneName AS 'Time zone',         
   PED.TSApproverID as 'TSApproverID',        
   PED.MandatoryHours AS 'Mandatory Hours',
   PED.UserId 
 FROM #ProjectemployeedataCustomer (NOLOCK) PED      

    
 SELECT DISTINCT ClientUserID AS 'External Login ID',      
     EmployeeID AS 'TSApprover ID',      
     ProjectID as 'ProjectId'          
 FROM AVL.MAS_LoginMaster(NOLOCK)      
 WHERE  CustomerID=@CustomerID       
  AND IsDeleted=0      
      
 ---Get TimeZoneName name      
 SELECT TimeZoneName FROM  avl.MAS_TimeZoneMaster(NOLOCK) WHERE IsDeleted=0 
 
 
 SELECT DISTINCT EmployeeId,IsEmployeeEditable from #ProjectemployeedataCustomer

      
  END TRY      
  BEGIN CATCH         
      
  DECLARE @ErrorMessage VARCHAR(MAX);      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
      
  --- Insert Error Message ---      
  EXEC AVL_InsertError '[AVL].[GetTicketModuleUserDetails]', @ErrorMessage, 0, 0      
                     
  END CATCH      
END 