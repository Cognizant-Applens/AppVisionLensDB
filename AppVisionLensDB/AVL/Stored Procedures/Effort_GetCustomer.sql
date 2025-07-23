/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
CREATE PROCEDURE [AVL].[Effort_GetCustomer]  
@EmployeeID NVARCHAR(50)  
as  
begin 
SET NOCOUNT ON;
BEGIN TRY  
   
  select Distinct C.CustomerID as CustomerID,C.CustomerName as CustomerName from AVL.Customer c (NOLOCK)  
       inner JOIN AVL.MAS_LoginMaster LM (NOLOCK) on LM.CustomerID=C.CustomerID  
       INNER join AVL.PRJ_ConfigurationProgress CP (NOLOCK) ON (c.IsCognizant =1 AND Cp.CustomerID=c.CustomerID  AND  cp.ScreenID=4 and CP.CompletionPercentage = 100 AND CP.IsDeleted=0)   
       OR (c.IsCognizant =0 AND Cp.CustomerID=c.CustomerID  AND CP.IsDeleted=0 and cp.ScreenID=4 and CP.CompletionPercentage = 100)  
       where  LM.IsDeleted=0 and LM.EmployeeID=@EmployeeID and C.IsDeleted=0   
       and (LM.IsNonESAAuthorized=0 or LM.IsNonESAAuthorized is NULL)  
       UNION  
       SELECT Distinct C.CustomerID as CustomerID,C.CustomerName as CustomerName from AVL.Customer(NOLOCK) c  
       INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM on LM.CustomerID=C.CustomerID  
       INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM on PM.CustomerID=c.CustomerID AND PM.ProjectID=LM.ProjectID AND PM.IsDeleted=0  
       WHERE  LM.IsDeleted=0 and LM.EmployeeID=@EmployeeID and C.IsDeleted=0 and PM.IsMainSpringConfigured='Y' AND PM.IsODCRestricted='Y'  
       and (LM.IsNonESAAuthorized=0 or LM.IsNonESAAuthorized is NULL)  
     union  
    SELECT distinct Cust.CustomerID,cust.CustomerName as CustomerName  
 FROM AVL.MAS_LoginMaster(NOLOCK) LM  
 JOIN AVL.MAS_ProjectMaster(NOLOCK) PM   
  ON PM.ProjectID=LM.ProjectID AND ISNULL(PM.IsDeleted,0)=0  
 JOIN AVL.Customer(NOLOCK) Cust   
  ON LM.CustomerID=Cust.CustomerID AND ISNULL(Cust.IsDeleted,0) = 0  
 LEFT JOIN PP.ScopeOfWork(NOLOCK) SW   
  ON SW.ProjectID = LM.ProjectID AND ISNULL(SW.IsDeleted,0) = 0  
  LEFT JOIN PP.ProjectAttributeValues(NOLOCK) PAV  
    ON PAV.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0  
  LEFT JOIN PP.ProjectProfilingTileProgress (NOLOCK) PTP  
    ON PTP.ProjectID = LM.ProjectID AND PAV.IsDeleted = 0  
 WHERE LM.EmployeeID=@EmployeeID AND ISNull(LM.IsDeleted,0) = 0   
 --AND ISNULL(IsApplensAsALM,0) <> 1   
 AND PAV.AttributeValueID IN(1,4)   
 AND PTP.TileID = 5 AND PTP.TileProgressPercentage = 100  
  
  
  END TRY    
BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[Effort_GetCustomer]', @ErrorMessage, @EmployeeID,0  
    
 END CATCH  
 SET NOCOUNT OFF;
end
