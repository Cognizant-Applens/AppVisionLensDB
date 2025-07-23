/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GetDebtUnClassifiedTickets]        
@ProjectID BIGINT,        
@ClosedDateFrom DateTime,        
@ClosedDateTo DateTime,        
@SupportType Int,        
@ApplicationTowerID NVARCHAR(MAX)=null        
AS     
BEGIN        
BEGIN TRY     

IF OBJECT_ID('tempdb..#UnClassifiedTicketDetails') IS NOT NULL
BEGIN
	DROP TABLE #UnClassifiedTicketDetails
END
IF OBJECT_ID('tempdb..#UnClassifiedDetails') IS NOT NULL
BEGIN
	DROP TABLE #UnClassifiedDetails
END


 DECLARE @BeginDate DATETIME;              
 DECLARE @EndDate DATETIME;             
 DECLARE @flag INT;         
 IF (@ApplicationTowerID <> '')                 
   SET @flag = 1                                                
  ELSE                 
   SET @flag = 2          
 SET @BeginDate = CONVERT(DATETIME, @ClosedDateFrom) + '00:00:00'                    
 SET @EndDate = CONVERT(DATETIME, @ClosedDateTo) + '23:59:59'                
                     
DECLARE @FlexField1 VARCHAR(100),@FlexField2 VARCHAR(100),@FlexField3 VARCHAR(100),@FlexField4 VARCHAR(100)        
        
SET @FlexField1 = (SELECT TOP 1        
  SCM.ProjectColumn        
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP        
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC        
  ON HPP.ColumnID = MC.ColumnID        
  AND MC.IsActive = 1        
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM        
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')        
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0        
 WHERE HPP.ColumnID = 11        
 AND HPP.IsActive = 1        
 AND HPP.ProjectID = @ProjectID);        
        
SET @FlexField2 = (SELECT TOP 1        
  SCM.ProjectColumn        
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP        
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC        
  ON HPP.ColumnID = MC.ColumnID        
 AND MC.IsActive = 1         
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM        
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')        
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0        
 WHERE HPP.ColumnID = 12        
 AND HPP.IsActive = 1         
 AND HPP.ProjectID = @ProjectID);        
        
SET @FlexField3 = (SELECT TOP 1        
  SCM.ProjectColumn        
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP        
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC        
  ON HPP.ColumnID = MC.ColumnID        
  AND MC.IsActive = 1        
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM        
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')        
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0        
 WHERE HPP.ColumnID = 13        
 AND HPP.IsActive = 1         
 AND HPP.ProjectID = @ProjectID);        
        
SET @FlexField4 = (SELECT TOP 1        
  SCM.ProjectColumn        
 FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP        
 JOIN AVL.DEBT_MAS_HealColumnMaster(NOLOCK) MC        
  ON HPP.ColumnID = MC.ColumnID        
  AND MC.IsActive = 1        
 JOIN AVL.ITSM_PRJ_SSISColumnMapping(NOLOCK) SCM        
  ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '')        
  AND SCM.ProjectID = @ProjectID AND IsDeleted = 0        
 WHERE HPP.ColumnID = 14        
 AND HPP.IsActive = 1        
 AND HPP.ProjectID = @ProjectID);        
    
 CREATE TABLE #UnClassifiedTicketDetails(        
   [Ticket ID] NVARCHAR(100),        
   [Ticket Description] NVARCHAR(Max),        
   [Resolution Remarks] NVARCHAR(Max),          
   [Debt Classification] NVARCHAR(Max),        
   [Cause Code] NVARCHAR(Max),        
   [Resolution Code] NVARCHAR(Max),          
   [Avoidable Flag] NVARCHAR(Max),        
   [Residual Debt] NVARCHAR(Max)       
 )      
      
  CREATE TABLE #UnClassifiedDetails(        
   [Ticket ID] NVARCHAR(100),        
   [Ticket Description] NVARCHAR(Max),        
   [Resolution Remarks] NVARCHAR(Max),         
   [Debt Classification] NVARCHAR(Max),        
   [Cause Code] NVARCHAR(Max),        
   [Resolution Code] NVARCHAR(Max),          
   [Avoidable Flag] NVARCHAR(Max),        
   [Residual Debt] NVARCHAR(Max),        
   FlexField1 NVARCHAR(Max),        
   FlexField2 NVARCHAR(Max),        
   FlexField3 NVARCHAR(Max),        
   FlexField4 NVARCHAR(Max)        
 )      
      
DECLARE @ColName1 nvarchar(Max)      
DECLARE @DynamicSQL1 nvarchar(Max)      
SET @ColName1=@FlexField1      
SET @DynamicSQL1 = 'ALTER TABLE #UnClassifiedTicketDetails ADD ['+ CAST(@ColName1 AS NVARCHAR(100)) +'] NVARCHAR(Max) NULL'      
EXEC(@DynamicSQL1)      
      
      
DECLARE @ColName2 nvarchar(Max)      
DECLARE @DynamicSQL2 nvarchar(Max)      
SET @ColName2=@FlexField2      
SET @DynamicSQL2 = 'ALTER TABLE #UnClassifiedTicketDetails ADD ['+ CAST(@ColName2 AS NVARCHAR(100)) +'] NVARCHAR(Max) NULL'      
EXEC(@DynamicSQL2)      
      
DECLARE @ColName3 nvarchar(Max)      
DECLARE @DynamicSQL3 nvarchar(Max)      
SET @ColName3=@FlexField3      
SET @DynamicSQL3 = 'ALTER TABLE #UnClassifiedTicketDetails ADD ['+ CAST(@ColName3 AS NVARCHAR(100)) +'] NVARCHAR(Max) NULL'      
EXEC(@DynamicSQL3)      
      
DECLARE @ColName4 nvarchar(Max)      
DECLARE @DynamicSQL4 nvarchar(Max)      
SET @ColName4=@FlexField4      
SET @DynamicSQL4 = 'ALTER TABLE #UnClassifiedTicketDetails ADD ['+ CAST(@ColName4 AS NVARCHAR(100)) +'] NVARCHAR(Max) NULL'      
EXEC(@DynamicSQL4)      
      
      
IF (@SupportType = 1)        
BEGIN        
INSERT INTO #UnClassifiedDetails         
SELECT  DISTINCT  TOP 2000    
     TicketId  AS [Ticket ID],        
  TicketDescription AS [Ticket Description],        
  ResolutionRemarks AS [Resolution Remarks],          
  DC.DebtClassificationName AS [Debt Classification],        
  CC.CauseCode AS [Cause Code],        
  RC.ResolutionCode AS [Resolution Code],          
  AF.AvoidableFlagName AS [Avoidable Flag],        
  RD.ResidualDebtName  AS [Residual Debt],        
  TD.FlexField1,        
  TD.FlexField2,        
  TD.FlexField3,        
  TD.FlexField4        
 FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD        
 LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CC         
  ON CC.CauseID=ISNULL(TD.CauseCodeMapID,0) AND CC.ProjectId = TD.ProjectId AND CC.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC         
  ON RC.ResolutionID=ISNULL(TD.ResolutionCodeMapID,0) AND RC.ProjectId = TD.ProjectId AND RC.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD         
  ON RD.ResidualDebtID=ISNULL(TD.ResidualDebtMapID,0) AND RD.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DC         
  ON DC.DebtClassificationID = ISNULL(TD.DebtClassificationMapID,0) AND DC.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF         
  ON AF.AvoidableFlagID = ISNULL(TD.AvoidableFlag,0) AND AF.Isdeleted = 0        
 WHERE  TD.ProjectId = @ProjectID AND TD.IsDeleted = 0 AND TD.DARTStatusID in (8,9)     
  AND TD.ClosedDate BETWEEN @BeginDate AND @EndDate        
  AND ((@flag = 1 AND (EXISTS (SELECT 1 FROM dbo.Split(@ApplicationTowerID,',') WHERE TD.ApplicationID = Item)))         
  OR @flag = 2) AND    
  (ISNULL(TD.CauseCodeMapID,0) = 0 OR        
  ISNULL(TD.ResolutionCodeMapID,0)  = 0 OR        
  ISNULL(TD.ResidualDebtMapID,0) = 0 OR        
  ISNULL(TD.DebtClassificationMapID,0) = 0 OR        
  ISNULL(TD.AvoidableFlag,0) = 0      
  OR ((@FlexField1 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField1)),'') =''))        
  OR ((@FlexField2 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField2)),'') =''))        
  OR ((@FlexField3 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField3)),'') =''))        
  OR ((@FlexField4 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField4)),'') ='')))      
 END        
 ELSE        
 BEGIN        
 INSERT INTO #UnClassifiedDetails         
 SELECT DISTINCT  TOP 2000      
     TicketId  AS [Ticket ID],        
  TicketDescription AS [Ticket Description],        
  ResolutionRemarks AS [Resolution Remarks],          
  DC.DebtClassificationName AS [Debt Classification],        
  CC.CauseCode AS [Cause Code],        
  RC.ResolutionCode AS [Resolution Code],          
  AF.AvoidableFlagName AS [Avoidable Flag],        
  RD.ResidualDebtName  AS [Residual Debt],        
  TD.FlexField1,        
  TD.FlexField2,        
  TD.FlexField3,        
  TD.FlexField4        
 FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD        
 LEFT JOIN AVL.DEBT_MAP_CauseCode (NOLOCK) CC         
  ON CC.CauseID=ISNULL(TD.CauseCodeMapID,0) AND CC.ProjectId = TD.ProjectId AND CC.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAP_ResolutionCode (NOLOCK) RC         
  ON RC.ResolutionID=ISNULL(TD.ResolutionCodeMapID,0) AND RC.ProjectId = TD.ProjectId AND RC.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAS_ResidualDebt (NOLOCK) RD         
  ON RD.ResidualDebtID=ISNULL(TD.ResidualDebtMapID,0) AND RD.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAS_DebtClassification (NOLOCK) DC         
  ON DC.DebtClassificationID = ISNULL(TD.DebtClassificationMapID,0) AND DC.Isdeleted = 0        
 LEFT JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF         
  ON AF.AvoidableFlagID = ISNULL(TD.AvoidableFlag,0) AND AF.Isdeleted = 0        
 WHERE  TD.ProjectId = @ProjectID AND TD.IsDeleted = 0 AND TD.DARTStatusID in (8,9)     
  AND TD.ClosedDate BETWEEN @BeginDate AND @EndDate        
  AND ((@flag = 1 AND (EXISTS (SELECT 1 FROM dbo.Split(@ApplicationTowerID,',') WHERE TD.TowerId = Item)))         
  OR @flag = 2)  AND    
  (ISNULL(TD.CauseCodeMapID,0) = 0 OR        
  ISNULL(TD.ResolutionCodeMapID,0)  = 0 OR        
  ISNULL(TD.ResidualDebtMapID,0) = 0 OR        
  ISNULL(TD.DebtClassificationMapID,0) = 0 OR        
  ISNULL(TD.AvoidableFlag,0) = 0        
  OR ((@FlexField1 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField1)),'') =''))        
  OR ((@FlexField2 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField2)),'') =''))        
  OR ((@FlexField3 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField3)),'') =''))        
  OR ((@FlexField4 IS NOT NULL AND ISNULL(LTRIM(RTRIM(TD.FlexField4)),'') ='')))       
 END        
IF (ISNULL(@FlexField1,'') = '' AND ISNULL(@FlexField2,'') = '' AND ISNULL(@FlexField3,'') = '' AND ISNULL(@FlexField4,'') = '')        
 BEGIN        
 SELECT       
  [Ticket ID],        
  [Ticket Description],        
  [Resolution Remarks],          
  [Debt Classification],        
  [Cause Code],        
  [Resolution Code],          
  [Avoidable Flag],        
  [Residual Debt]        
 FROM #UnClassifiedDetails(NOLOCK)        
 END        
 ELSE        
 BEGIN        
 IF(ISNULL(@FlexField1,'') = '')        
 BEGIN        
 ALTER TABLE #UnClassifiedDetails        
    DROP COLUMN FlexField1        
 END        
 IF(ISNULL(@FlexField2,'') = '')        
 BEGIN        
  ALTER TABLE #UnClassifiedDetails        
    DROP COLUMN FlexField2        
 END        
 IF(ISNULL(@FlexField3,'') = '')        
 BEGIN        
  ALTER TABLE #UnClassifiedDetails        
    DROP COLUMN FlexField3        
 END        
 IF(ISNULL(@FlexField4,'') = '')        
 BEGIN        
  ALTER TABLE #UnClassifiedDetails        
    DROP COLUMN FlexField4        
 END        
 Insert into #UnClassifiedTicketDetails       
 select * from #UnClassifiedDetails      
      
 select * from #UnClassifiedTicketDetails      
 END        
         
-- Cause Code Details        
SELECT CauseID,CauseCode         
FROM [AVL].[DEBT_MAP_CauseCode] (NOLOCK)        
WHERE ProjectID = @ProjectID AND IsDeleted =0        
ORDER BY CauseCode ASC        
        
-- Resolution Code Details        
SELECT ResolutionID,ResolutionCode        
FROM [AVL].[DEBT_MAP_ResolutionCode] (NOLOCK)        
WHERE ProjectID = @ProjectID AND IsDeleted = 0        
ORDER BY ResolutionCode ASC        
        
-- Debt Classification Details        
IF @SupportType = 1      
BEGIN      
SELECT DebtClassificationID,DebtClassificationName         
FROM [AVL].[DEBT_MAS_DebtClassification](NOLOCK) WHERE IsDeleted =0        
END      
ELSE      
BEGIN      
SELECT DebtClassificationID,DebtClassificationName         
FROM [AVL].[DEBT_MAS_DebtClassificationInfra](NOLOCK) WHERE IsDeleted =0        
END      
        
--Avoidable Flag Details        
SELECT AvoidableFlagID ,AvoidableFlagName         
FROM [AVL].[DEBT_MAS_AvoidableFlag](NOLOCK) WHERE IsDeleted =0 and AvoidableFlagID!=1        
        
-- Residual Debt Details        
SELECT ResidualDebtID,ResidualDebtName         
FROM AVL.DEBT_MAS_ResidualDebt(NOLOCK) WHERE IsDeleted =0        
END TRY      
BEGIN CATCH      
        
  DECLARE @ErrorMessage VARCHAR(4000);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
        
  --INSERT Error                                            
  EXEC AVL_InsertError '[AVL].[UploadDebtUnClassifiedTickets]',@ErrorMessage,0        
        
END CATCH      
        
END
