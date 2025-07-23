/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
CREATE PROCEDURE [AVL].[GetAddNewUserDetails]  --12885,136409
(      
 @CustomerID VARCHAR(20) = NULL,      
 @ProjectID  VARCHAR(20) = NULL       
)      
AS      
BEGIN      
       
 SET NOCOUNT ON; 
   CREATE TABLE #UserDetails    
   (    
   EmployeeID NVARCHAR(100),    
   EmployeeName NVARCHAR(200),
   EmployeeEmail NVARCHAR(200),
   ClientUserID NVARCHAR(100),    
   TimeZoneId INT,    
   TimeZoneName NVARCHAR(200),     
   TSApproverID NVARCHAR(100),    
   TSApproverName NVARCHAR(200),    
   MandatoryHours DECIMAL(6,2),   
   IsDeleted BIT  ,
   UserId BIGINT,
   IsEmployeeEditable BIT 
   )   
  INSERT INTO #UserDetails   
  SELECT DISTINCT   
  LM.EmployeeID,      
  LM.EmployeeName,    
  LM.EmployeeEmail,
  CASE WHEN LM.ClientUserID = '' OR LM.ClientUserID IS NULL THEN '0' ELSE LM.ClientUserID END AS ClientUserID,      
  LM.TimeZoneId,      
  TZ.TimeZoneName,      
  CASE WHEN LM.TSApproverID IS NULL OR LM.TSApproverID = '' THEN LM.HcmSupervisorID ELSE LM.TSApproverID END TSApproverID, 
  NULL,
  CASE WHEN LM.MandatoryHours IS NULL THEN 8 ELSE LM.MandatoryHours END AS MandatoryHours,  
  ISNULL (LM.IsDeleted,0)  AS IsDeleted,
  LM.UserId,
  NULL
 FROM [AVL].[MAS_LoginMaster](NOLOCK) LM         
 LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) TZ 
	ON TZ.TimeZoneID = LM.TimeZoneId      
 WHERE LM.customerid = @CustomerID AND LM.ProjectID = @ProjectID  

        
 UPDATE T       
 SET t.TSApproverName = l.EmployeeName      
 FROM #UserDetails t       
 INNER JOIN AVL.MAS_LoginMaster(NOLOCK) l       
  ON l.EmployeeID = t.TSApproverID    

  CREATE TABLE #TicketCount(
   EmployeeId nvarchar(50),
   COUN INT
  )
  INSERT INTO #TicketCount
  SELECT t.EmployeeID,Count(TicketId) AS COUN 
  FROM  #UserDetails t
  JOIN AVL.TK_TRN_TicketDetail(NOLOCK) td
  ON (td.assignedto = t.UserId or td.createdby = t.EmployeeID)
  AND td.projectid = @ProjectID 
  GROUP BY t.EmployeeID

  INSERT INTO #TicketCount
  SELECT t.EmployeeID,Count(TicketId) AS COUN 
  FROM  #UserDetails t
  JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) td
  ON (td.assignedto = t.UserId or td.createdby = t.EmployeeID)
  AND td.projectid = @ProjectID 
  GROUP BY t.EmployeeID

  SELECT DISTINCT EmployeeId,SUM(COUN) AS Sums
  INTO #TicketCounts
  FROM #TicketCount 
  GROUP BY EmployeeId

  UPDATE #UserDetails SET IsEmployeeEditable = 1

  UPDATE tc
  SET tc.IsEmployeeEditable = 0
  from #UserDetails tc
  join #TicketCounts t2
  ON t2.EmployeeID = tc.EmployeeID

  SELECT * FROM #UserDetails
    
    SET NOCOUNT OFF;       
END  