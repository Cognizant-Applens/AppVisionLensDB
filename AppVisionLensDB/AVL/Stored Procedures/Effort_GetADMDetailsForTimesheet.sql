/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
  
-- ============================================================================------    
-- Author    :    Dhivya Bharathi M      
--  Create date:    May 18 , 2020      
-- ============================================================================    
  
--[AVL].[Effort_GetADMDetailsForTimesheet_ADM] 7097,'471742','05/12/2020','05/20/2020'  
CREATE Procedure [AVL].[Effort_GetADMDetailsForTimesheet]  
@CustomerID BIGINT,  
@EmployeeID NVARCHAR(50)=null   
AS   
BEGIN 
 SET NOCOUNT ON;  
BEGIN TRY  
 CREATE TABLE #MAS_LoginMaster  
 (  
  [UserID] [int]  NOT NULL,  
  [EmployeeID] [nvarchar](50) NOT NULL,  
  [EmployeeName] [nvarchar](100) NULL,  
  [ProjectID] [int] NOT NULL,  
  [CustomerID] [bigint] NOT NULL,  
  [TimeZoneId] [int] NULL  
 )  
 INSERT INTO #MAS_LoginMaster  
 ( UserID,EmployeeID,EmployeeName,ProjectID,CustomerID,TimeZoneId)  
 SELECT UserID,EmployeeID,EmployeeName,ProjectID,CustomerID,TimeZoneId   
 FROM [AVL].[MAS_LoginMaster](NOLOCK)   
 WHERE EmployeeID = @EmployeeID AND CustomerID=@CustomerID AND ISNULL(IsDeleted,0)=0  
  
 SELECT  LM.CustomerID,MS.ProjectId,MS.StatusId,MS.StatusMapId,MS.ProjectStatusName   
 FROM [PP].[ALM_MAP_Status](NOLOCK) MS  
 INNER JOIN #MAS_LoginMaster LM (NOLOCK) ON LM.ProjectID=MS.ProjectID  
 WHERE  LM.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID  
 AND ISNULL(MS.IsDeleted,0)=0  
  
 SELECT StatusId AS ID,ProjectStatusName AS [Name]  
 FROM [PP].[ALM_MAP_Status](NOLOCK) WHERE IsDefault='Y'  
  
 SELECT SW.ProjectId,SW.IsApplensAsALM FROM PP.ScopeOfWork SW (NOLOCK) 
 INNER JOIN #MAS_LoginMaster LM (NOLOCK) ON LM.ProjectID=SW.ProjectID  
 WHERE  LM.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID  
 AND ISNULL(SW.IsDeleted,0)=0  
  
   
 Select  PM.ProjectID AS ProjectId,PAV.AttributeValueID AS Scope   
 FROM PP.ProjectAttributeValues(NOLOCK) PAV  
 join AVL.MAS_ProjectMaster(NOLOCK) PM  
 ON PM.ProjectID = PAV.ProjectID AND PAV.IsDeleted = 0 AND PM.IsDeleted = 0  
 JOIN AVL.MAS_LoginMaster(NOLOCK) LM  
 ON LM.ProjectID = PM.ProjectID AND LM.IsDeleted = 0  
 WHERE  PAV.AttributeID = 1 and pm.CustomerID = @CustomerID AND LM.EmployeeID = @EmployeeID  
 GROUP BY PM.ProjectID,PAV.AttributeValueID  
  
IF OBJECT_ID('tempdb..#MAS_LoginMaster', 'U') IS NOT NULL  
BEGIN  
 DROP TABLE #MAS_LoginMaster  
END  
END TRY   
BEGIN CATCH    
  DECLARE @ErrorMessage VARCHAR(MAX);  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  EXEC AVL_InsertError '[AVL].[Effort_GetADMDetailsForTimesheet_ADM]', @ErrorMessage, @EmployeeID,0  
 END CATCH    
 SET NOCOUNT OFF;
END
