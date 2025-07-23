  
/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
-- ====================================================================================  
-- Author:  Kumuthini   
-- Create date: 5/22/2018  
-- Description: Procedure to get the filter details required for Search Tickets like  
--    Projects, Hierarchies with Applications.  
-- EXEC [AVL].[Effort_GetSearchTicketProjectApplicationHierarchyFilter_TEST] 2, '800308'  
-- ====================================================================================  
  
CREATE PROCEDURE [AVL].[Effort_GetSearchTicketProjectApplicationHierarchyFilter]  
(  
 @CustomerID BIGINT,  
  
 @AssociateID VARCHAR(100)  
)  
AS  
  
BEGIN  
  
 BEGIN TRY  
  
IF OBJECT_ID('tempdb..#SupportDetail') IS NOT NULL  
begin  
    DROP TABLE #SupportDetail  
End   
IF OBJECT_ID('tempdb..#InfraHierarchyMappingDetail') IS NOT NULL  
begin  
    DROP TABLE #InfraHierarchyMappingDetail  
End   
IF OBJECT_ID('tempdb..#AppHierarchyData') IS NOT NULL  
begin  
    DROP TABLE #AppHierarchyData  
End   
IF OBJECT_ID('tempdb..#InfraHierarchyData') IS NOT NULL  
begin  
    DROP TABLE #InfraHierarchyData  
End   
IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL  
begin  
    DROP TABLE #TEMP  
End   
   
  
  
 SET NOCOUNT ON;   
  -- Get all projects under the selected Account / Customer and Employee.  
   -- Get all projects under the selected Account / Customer and Employee.  
                                SELECT DISTINCT PM.ProjectId, PM.ProjectName, PC.SupportTypeId INTO  #SupportDetail  
  
                                FROM AVL.MAS_LoginMaster (NOLOCK) LM  
                  
                                JOIN AVL.MAS_ProjectMaster (NOLOCK) PM  
                  
                                                ON PM.ProjectID = LM.ProjectID AND PM.CustomerID = LM.CustomerID  
  
                                                JOIN [AVL].[MAP_ProjectConfig] (NOLOCK) PC  
  
                                                ON PM.ProjectID=PC.ProjectID  
  
                                                                AND PM.IsDeleted = 0  
  
                                WHERE LM.CustomerID = @CustomerID AND LM.EmployeeID = @AssociateID  
  
                                                AND LM.IsDeleted = 0  
  
                                select ProjectId,ProjectName,SupportTypeId from #SupportDetail (NOLOCK)  
  
                                DECLARE @TempBC TABLE   
                                (  
  
                                                ProjectID BIGINT,  
                                  
                                                BusinessClusterMapID BIGINT,  
  
                                                BusinessClusterBaseName NVARCHAR(100) NOT NULL,  
  
                                                BusinessClusterID BIGINT,  
  
                                                ParentBusinessClusterMapID BIGINT  
  
                                )  
  
                                -- Get the Last Level Cluster Details which is tagged to applications for the   
                                -- project (s) under the selected Account / Customer and Employee.  
                                INSERT INTO @TempBC  
                  
                                                SELECT DISTINCT APM.ProjectID,  
                                  
                                        BM.BusinessClusterMapID,   
                                  
                                                                                                                BM.BusinessClusterBaseName,   
                                  
                                                                                                                BM.BusinessClusterID,   
                  
                                                                                                                BM.ParentBusinessClusterMapID  
  
                                                FROM [AVL].MAS_LoginMaster (NOLOCK) LM  
                  
                                                JOIN [AVL].MAS_ProjectMaster (NOLOCK) PM  
                  
                                                                ON PM.ProjectID = LM.ProjectID AND PM.CustomerID = LM.CustomerID  
  
                                                                                AND PM.IsDeleted = 0  
                  
                                                JOIN [AVL].APP_MAP_ApplicationProjectMapping (NOLOCK) APM  
  
                                                                ON APM.ProjectID = PM.ProjectID AND APM.IsDeleted = 0   
  
                                                JOIN [AVL].APP_MAS_ApplicationDetails (NOLOCK) AD   
  
                                                                ON AD.ApplicationId = APM.ApplicationID AND AD.IsActive = 1  
                  
                                                JOIN [AVL].BusinessClusterMapping (NOLOCK) BM  
  
                                                                ON BM.BusinessClusterMapID = AD.SubBusinessClusterMapID   
                                                                  
                                                                                AND BM.CustomerID = LM.CustomerID   
                                                                                  
                                                                                AND BM.IsDeleted = 0  
  
                                                WHERE LM.CustomerID = @CustomerID AND LM.EmployeeID = @AssociateID  
  
                                                                AND LM.IsDeleted = 0  
  
                                                                  
                                -- Recursive Function to get all levels of parent hierachies for the project(s)  
                                -- under the selected Account / Customer and Employee.  
                                ;WITH CTE   
                                AS  
                                (  
                                                SELECT  ProjectID,  
                                  
                                                                                BusinessClusterMapID,   
  
                                                                                CAST(BusinessClusterBaseName AS NVARCHAR(100)) AS BusinessClusterBaseName,   
  
                                                                                BusinessClusterID,   
                                                                  
                                                                                ParentBusinessClusterMapID   
                                  
                                                FROM @TempBC  
                                  
                                                UNION ALL  
                                  
                                                SELECT  CTE.ProjectID,  
                                  
                                                                                BCM.BusinessClusterMapID,   
                                  
                                                                                CAST(BCM.BusinessClusterBaseName AS NVARCHAR(100)) AS BusinessClusterBaseName,   
  
                                                  BCM.BusinessClusterID,   
                                                                  
                                                                                BCM.ParentBusinessClusterMapID   
  
                                                FROM AVL.BusinessClusterMapping (NOLOCK) BCM  
  
                                                JOIN CTE ON BCM.BusinessClusterMapID = CTE.ParentBusinessClusterMapID  
  
                                                WHERE BCM.IsDeleted = 0  
                                )  
                                SELECT DISTINCT ProjectID, BusinessClusterMapID, BusinessClusterBaseName,  
  
                                                BusinessClusterID, ParentBusinessClusterMapID  
  
                                INTO #TempBusinessCluster  
  
                                FROM CTE ORDER BY ProjectID, BusinessClusterMapID  
  
  
                                -- Get the hierachy label names for the selected account.  
                                SELECT    
                                                                BusinessClusterID,  
                                                  
                                                                BusinessClusterName   
  
                                INTO #AppHierarchyLabel  
  
                                FROM AVL.BusinessCluster (NOLOCK)  
                                                  
                                WHERE CustomerID = @CustomerID   
                  
                                                AND BusinessClusterID IN (SELECT DISTINCT BusinessClusterID FROM #TempBusinessCluster)  
  
                                select 1 as BusinessClusterId,HierarchyOneDefinition as BusinessClusterName into #InfraHierarchyLabel from AVL.InfraClusterDefinition (NOLOCK) where CustomerId=@CustomerID  
                                UNION ALL   
                                select 2, HierarchyTwoDefinition from AVL.InfraClusterDefinition (NOLOCK) where CustomerId=@CustomerID  
                                UNION ALL   
                                select 3, HierarchyThreeDefinition from AVL.InfraClusterDefinition (NOLOCK) where CustomerId=@CustomerID  
                                UNION ALL   
                                select 4, HierarchyFourDefinition from AVL.InfraClusterDefinition (NOLOCK) where CustomerId=@CustomerID  
                                UNION ALL   
                                select 5, HierarchyFiveDefinition from AVL.InfraClusterDefinition (NOLOCK) where CustomerId=@CustomerID  
                                UNION ALL   
                                select 6, HierarchySixDefinition from AVL.InfraClusterDefinition (NOLOCK) where CustomerId=@CustomerID  
  
  
                                select ROW_NUMBER() OVER (ORDER BY BusinessClusterId ASC) AS RowNumber, BusinessClusterId,BusinessClusterName, 0 as IsInfra into #AppInfraHierarchyLable from #AppHierarchyLabel (NOLOCK) UNION ALL   
                                select ROW_NUMBER() OVER (ORDER BY BusinessClusterId ASC) AS RowNumber, BusinessClusterId,BusinessClusterName, 1 as IsInfra from #InfraHierarchyLabel (NOLOCK)  
                                where ISNULL(BusinessClusterName,'') <> ''  
  
                                select  RowNumber, BusinessClusterId, BusinessClusterName, IsInfra   
                                                       from #AppInfraHierarchyLable (NOLOCK) ORDER BY IsInfra, BusinessClusterId  
  
  
                                -- Add applications as last level in hierarchy for each projects.  
  
                                DECLARE @MaxBusinessClusterID AS BIGINT  
                  
                                SELECT @MaxBusinessClusterID = MAX(BusinessClusterID) + 1 FROM #TempBusinessCluster  
  
  
                                INSERT INTO #TempBusinessCluster  
                                  
                                                SELECT DISTINCT              LM.ProjectID,  
  
                                                                                AD.ApplicationId,  
  
                                                                                AD.ApplicationName,  
  
                                                                                @MaxBusinessClusterID,  
  
                                                                                AD.SubBusinessClusterMapID  
  
                                                FROM [AVL].MAS_LoginMaster (NOLOCK) LM  
                  
                                                JOIN [AVL].MAS_ProjectMaster (NOLOCK) PM  
                  
                                                                ON PM.ProjectID = LM.ProjectID AND PM.CustomerID = LM.CustomerID  
  
                                                                                AND PM.IsDeleted = 0  
                  
                                                JOIN [AVL].APP_MAP_ApplicationProjectMapping (NOLOCK) APM  
  
                                                                ON APM.ProjectID = PM.ProjectID AND APM.IsDeleted = 0   
  
                                                JOIN [AVL].APP_MAS_ApplicationDetails (NOLOCK) AD   
  
                                                                ON AD.ApplicationId = APM.ApplicationID AND AD.IsActive = 1  
  
                                                WHERE LM.CustomerID = @CustomerID AND LM.EmployeeID = @AssociateID  
  
                                                                AND LM.IsDeleted = 0  
  
                                                  
                                -- Rank and fetch all levels of hierachies for the project(s) under the selected   
                                -- Account / Customer and Employee.  
                                SELECT ProjectID, SubClusterID, BusinessClusterBaseName,   
                                  
                                                CASE WHEN BusinessClusterID = @MaxBusinessClusterID THEN 7   
                                                  
                                                                 ELSE BusinessClusterID END AS BusinessClusterID,   
                  
                                                ParentBusinessClusterMapID, RANK1, Row# , 0 as IsInfra INTO #AppHierarchyData  
  
                                FROM  
                                (  
                  
                                                SELECT  ProjectID, BusinessClusterMapID AS SubClusterID,   
                                  
                                                                                BusinessClusterBaseName, BusinessClusterID,   
                                                                  
                                                                                ISNULL(ParentBusinessClusterMapID, 0) AS ParentBusinessClusterMapID,  
  
                                                                                DENSE_RANK() OVER ( ORDER BY BusinessClusterID ASC) AS RANK1,  
  
                                                                                ROW_NUMBER() OVER ( ORDER BY BusinessClusterID ASC) AS Row#   
  
                                                FROM #TempBusinessCluster  
                  
                                ) AS T  
                  
                                ORDER BY ProjectID, Row# ASC   
                                  
                                DROP TABLE #TempBusinessCluster  
  
        SELECT DISTINCT ITPM.ProjectID,One.HierarchyOneTransactionID,One.HierarchyName AS HierarchyOneName,  
                        two.HierarchyTwoTransactionID,two.HierarchyName HierarchyTwoName,  
                        three.HierarchyThreeTransactionID,three.HierarchyName HierarchyThreeName,  
                        four.HierarchyFourTransactionID,four.HierarchyName HierarchyFourName,  
                        IFVM.HierarchyFiveTransactionID,IFVM.HierarchyName HierarchyFiveName,  
                        ISM.HierarchySixTransactionID,ISM.HierarchyName HierarchySixName,  
                        ITPM.TowerID,ITDT.TowerName  
        INTO #InfraHierarchyMappingDetail  
        FROM avl.InfraHierarchyMappingTransaction A (NOLOCK)  
        LEFT JOIN AVL.InfraHierarchyOneTransaction One (NOLOCK) ON A.HierarchyOneTransactionID=One.HierarchyOneTransactionID  
        LEFT JOIN AVL.InfraHierarchyTwoTransaction two (NOLOCK) ON A.HierarchyTwoTransactionID = two.HierarchyTwoTransactionID  
        LEFT JOIN AVL.InfraHierarchyThreeTransaction three (NOLOCK) ON A.HierarchyThreeTransactionID = three.HierarchyThreeTransactionID  
        LEFT JOIN AVL.InfraHierarchyFourTransaction four (NOLOCK) ON A.HierarchyFourTransactionID = four.HierarchyFourTransactionID  
        LEFT JOIN AVL.InfraHierarchyFiveTransaction(NOLOCK) IFVM ON A.HierarchyFiveTransactionID=IFVM.HierarchyFiveTransactionID AND IFVM.IsDeleted=0  
        LEFT JOIN AVL.InfraHierarchySixTransaction(NOLOCK) ISM ON A.HierarchySixTransactionID=ISM.HierarchySixTransactionID AND ISM.IsDeleted=0  
        LEFT JOIN AVL.InfraTowerDetailsTransaction ITDT (NOLOCK) ON ITDT.InfraTransMappingID=A.InfraTransMappingID AND ITDT.IsDeleted=0  
        LEFT JOIN AVL.InfraTowerProjectMapping ITPM (NOLOCK) ON ITPM.TowerID=ITDT.InfraTowerTransactionID AND ITPM.IsDeleted=0 AND ITPM.IsEnabled=1  
        INNER JOIN #SupportDetail SD ON SD.ProjectId = ITPM.ProjectID  
        where A.CustomerID = @CustomerID   
  
                
  
        CREATE TABLE #TEMP (  
                        RowID INT IDENTITY(1,1) primary key,  
                        ProjectID VARCHAR(20),  
                        HierarchyTransactionID INT,   
                        HierarchyName VARCHAR(200),  
                        ParentHierarchyId VARCHAR(15),  
                        Hierarchy INT  
        )  
                         
        INSERT INTO #TEMP  
                     SELECT DISTINCT ProjectiD, HierarchyOneTransactionID, HierarchyOneName, 0 AS ParentHierarchyId, 1 AS Hierarchy  
                     FROM #InfraHierarchyMappingDetail (NOLOCK)  
                  
        INSERT INTO #TEMP  
                     SELECT DISTINCT A.ProjectiD,HierarchyTwoTransactionID,HierarchyTwoName,'H1-'+CONVERT(varchar(15), HierarchyOneTransactionID) AS ParentHierarchyId,2 AS Hierarchy  
                     FROM #InfraHierarchyMappingDetail A (NOLOCK)  
                     INNER JOIN #TEMP B ON A.HierarchyOneTransactionID = B.HierarchyTransactionID AND B.Hierarchy = 1  
                           AND A.ProjectID = B.ProjectID  
                  
        INSERT INTO #TEMP  
                     SELECT DISTINCT A.ProjectiD,HierarchyThreeTransactionID,HierarchyThreeName,'H2-'+CONVERT(varchar(15),HierarchyTwoTransactionID) AS ParentHierarchyId,3 AS Hierarchy  
                     FROM #InfraHierarchyMappingDetail A (NOLOCK)  
                     INNER JOIN #TEMP B (NOLOCK) ON A.HierarchyTwoTransactionID = B.HierarchyTransactionID AND B.Hierarchy = 2  
                           AND A.ProjectID = B.ProjectID  
  
        INSERT INTO #TEMP  
                     SELECT DISTINCT A.ProjectiD,HierarchyFourTransactionID,HierarchyFourName,'H3-'+CONVERT(varchar(15),HierarchyThreeTransactionID) AS ParentHierarchyId,4 AS Hierarchy  
                     FROM #InfraHierarchyMappingDetail A (NOLOCK)  
                     INNER JOIN #TEMP B (NOLOCK) ON A.HierarchyThreeTransactionID = B.HierarchyTransactionID AND B.Hierarchy = 3 AND A.ProjectID = B.ProjectID  
                     WHERE HierarchyFourTransactionID IS NOT NULL  
                  
        INSERT INTO #TEMP  
                     SELECT DISTINCT A.ProjectiD,HierarchyFiveTransactionID,HierarchyFiveName,'H4-'+CONVERT(varchar(15),HierarchyFourTransactionID) AS ParentHierarchyId,5 AS Hierarchy  
                     FROM #InfraHierarchyMappingDetail A (NOLOCK)  
                     INNER JOIN #TEMP B (NOLOCK) ON A.HierarchyFourTransactionID = B.HierarchyTransactionID AND B.Hierarchy = 4 AND A.ProjectID = B.ProjectID  
                     WHERE HierarchyFiveTransactionID IS NOT NULL  
                  
        INSERT INTO #TEMP  
                     SELECT DISTINCT A.ProjectiD,HierarchySixTransactionID,HierarchySixName,'H5'+CONVERT(varchar(15),HierarchyFiveTransactionID) AS ParentHierarchyId,6 AS Hierarchy  
                     FROM #InfraHierarchyMappingDetail A (NOLOCK)  
                     INNER JOIN #TEMP B (NOLOCK) ON A.HierarchyFiveTransactionID = B.HierarchyTransactionID AND B.Hierarchy = 5 AND A.ProjectID = B.ProjectID  
                     WHERE HierarchySixTransactionID IS NOT NULL  
  
  
        INSERT INTO #TEMP  
            SELECT DISTINCT  A.ProjectiD,TowerID,TowerName,  
        CASE WHEN A.HierarchySixTransactionID IS NOT NULL THEN 'H6-'+CONVERT(varchar(15),A.HierarchySixTransactionID)  
                WHEN A.HierarchyFiveTransactionID IS NOT NULL THEN 'H5-'+CONVERT(varchar(15),A.HierarchyFiveTransactionID)  
                WHEN A.HierarchyFourTransactionID IS NOT NULL THEN 'H4-'+CONVERT(varchar(15),A.HierarchyFourTransactionID)  
                WHEN A.HierarchyThreeTransactionID IS NOT NULL THEN 'H3-'+CONVERT(varchar(15),A.HierarchyThreeTransactionID)  
        END AS ParentHierarchyId, 7 AS Hierarchy  
       FROM  #InfraHierarchyMappingDetail A (NOLOCK)  
       LEFT JOIN #TEMP SIX (NOLOCK) ON A.ProjectID = SIX.ProjectID  AND A.HierarchySixTransactionID = SIX.HierarchyTransactionID AND SIX.Hierarchy = 6  
       LEFT JOIN  #TEMP FIVE (NOLOCK) ON A.ProjectID = FiVE.ProjectID  AND A.HierarchyFiveTransactionID = FiVE.HierarchyTransactionID AND FiVE.Hierarchy = 5  
       LEFT JOIN  #TEMP FOUR (NOLOCK) ON A.ProjectID = FOUR.ProjectID  AND A.HierarchyFourTransactionID = FOUR.HierarchyTransactionID AND FOUR.Hierarchy = 4  
       LEFT JOIN  #TEMP THREE (NOLOCK) ON A.ProjectID = THREE.ProjectID  AND A.HierarchyThreeTransactionID = THREE.HierarchyTransactionID AND THREE.Hierarchy = 3                                                                 
                                 
  
                                ALTER TABLE #temp  
                                ALTER COLUMN HierarchyTransactionID varchar(15);  
  
                                SELECT ProjectID, CASE   
                                WHEN Hierarchy = 7 THEN HierarchyTransactionID  
                                WHEN Hierarchy=1 THEN 'H1-'+HierarchyTransactionID   
                                WHEN Hierarchy=2 THEN 'H2-'+HierarchyTransactionID   
                                WHEN Hierarchy=3 THEN 'H3-'+HierarchyTransactionID   
                                WHEN Hierarchy=4 THEN 'H4-'+HierarchyTransactionID   
                                WHEN Hierarchy=5 THEN 'H5-'+HierarchyTransactionID   
                                WHEN Hierarchy=6 THEN 'H6-'+HierarchyTransactionID   
                                 END AS SubClusterID,  HierarchyName AS BusinessClusterBaseName,  
                                                                                                Hierarchy AS BusinessClusterID,  
                                                                                                ParentHierarchyId AS ParentBusinessClusterMapID,   
                                                                                                DENSE_RANK() OVER ( ORDER BY Hierarchy ASC) AS RANK1,  
                                                                                                ROW_NUMBER() OVER ( ORDER BY RowID ASC) AS Row#,   
                        1 as IsInfra   
                        INTO #InfraHierarchyData  
                                FROM #TEMP (NOLOCK) ORDER BY IsInfra  
  
                                  
                  
                ALTER TABLE #AppHierarchyData  
                                ALTER COLUMN SubClusterID varchar(15);  
                                ALTER TABLE #AppHierarchyData  
                                ALTER COLUMN ParentBusinessClusterMapID varchar(15);  
  
               SELECT   
                                ProjectID,  
                                SubClusterID,  
                                BusinessClusterBaseName,  
                                BusinessClusterID,  
                                ParentBusinessClusterMapID,  
                                RANK1,  
                                Row#,  
                                IsInfra  
                FROM #AppHierarchyData (NOLOCK)  
                UNION ALL   
                SELECT   
                                ProjectID,  
                                SubClusterID,  
                                BusinessClusterBaseName,  
                                BusinessClusterID,  
                                ParentBusinessClusterMapID,  
                                RANK1,  
                                Row#,  
                                IsInfra  
                FROM #InfraHierarchyData (NOLOCK)  
  
  
   END TRY    
  
   BEGIN CATCH    
  
  DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --Insert Error      
  EXEC AVL_InsertError '[AVL].[Effort_GetSearchTicketProjectApplicationHierarchyFilter]',   
    
   @ErrorMessage, 0, @CustomerID  
  
  RETURN @@ERROR  
   
   END CATCH    
  
 END
