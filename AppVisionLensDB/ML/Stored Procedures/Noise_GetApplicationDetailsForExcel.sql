          
            
-- =============================================                
-- Author:  Siddhesh                
-- Create date: 18-04-2022                
-- Description: Get Application Details With Noise Words for excel where radio select is Application                
-- =============================================                
CREATE PROCEDURE [ML].[Noise_GetApplicationDetailsForExcel]      
 -- Add the parameters for the stored procedure here                        
 (      
 @ProjectId BIGINT      
 ,@downloadMode INT      
 )      
AS      
BEGIN      
 BEGIN TRY      
  -- SET NOCOUNT ON added to prevent extra result sets from                        
  -- interfering with SELECT statements.                        
  SET NOCOUNT ON;      
      
  CREATE TABLE #table1 (      
   [Name] [nvarchar](200) NULL      
   ,[TicketDescNoiseWord] [nvarchar](500) NULL      
   ,[Frequency] [int] NULL      
   ,[IsActive] [bit] NULL      
   ,[OptionalFieldNoiseWord] [nvarchar](500) NULL      
   ,[OptionalFieldFrequency] [int] NULL      
   ,[IsActiveResolution] [bit] NULL      
   ,      
   )      
      
  CREATE TABLE #table2 ([Name] [nvarchar](1000) NULL)      
      
  CREATE TABLE #table3 (      
   [ColumnName] [nvarchar](100) NULL      
   ,[Noise] [nvarchar](100) NULL      
   ,[Frequency] [nvarchar](100) NULL      
   ,[IsActive] [nvarchar](100) NULL      
   ,[OptionalFieldNoiseWord] [nvarchar](500) NULL      
   ,[OptionalFieldFrequency] [nvarchar](100) NULL      
   ,[IsActiveResolution] [nvarchar](100) NULL      
   ,      
   )      
      
  CREATE TABLE #table4 (      
   [FromDate] [datetime] NULL      
   ,[ToDate] [datetime] NULL      
   )      
      
  -- Insert statements for procedure here                        
  IF @downloadMode = 1 -- App Support                         
  BEGIN      
   -- Table 1                        
   INSERT INTO #table1      
   SELECT 'All' AS 'Name'      
    ,TicketDescNoiseWord      
    ,IIF(TicketDescNoiseWord IS NULL      
     OR TicketDescNoiseWord = '', NULL, Frequency)      
    ,IIF(TicketDescNoiseWord IS NULL      
     OR TicketDescNoiseWord = '', NULL, IsActive)      
    ,OptionalFieldNoiseWord      
    ,IIF(OptionalFieldNoiseWord IS NULL      
     OR OptionalFieldNoiseWord = '', NULL, OptionalFieldFrequency)      
    ,IIF(OptionalFieldNoiseWord IS NULL      
     OR OptionalFieldNoiseWord = '', NULL, IsActiveResolution)      
   FROM [ML].[TRN_AppInfraNoiseWords]      
   WHERE projectID = @ProjectId      
    AND IsAppInfra = 1      
    AND ApplicationId IS NULL      
      
   INSERT INTO #table1      
   SELECT AD.ApplicationName AS 'Name'      
    ,NW.TicketDescNoiseWord      
    ,IIF(NW.TicketDescNoiseWord IS NULL      
     OR NW.TicketDescNoiseWord = '', NULL, NW.Frequency)      
    ,IIF(NW.TicketDescNoiseWord IS NULL      
     OR NW.TicketDescNoiseWord = '', NULL, NW.IsActive)      
    ,NW.OptionalFieldNoiseWord      
    ,IIF(NW.OptionalFieldNoiseWord IS NULL      
     OR NW.OptionalFieldNoiseWord = '', NULL, NW.OptionalFieldFrequency)      
    ,IIF(NW.OptionalFieldNoiseWord IS NULL      
     OR NW.OptionalFieldNoiseWord = '', NULL, NW.IsActiveResolution)      
   FROM [ML].[TRN_AppInfraNoiseWords] NW      
   JOIN [AVL].[APP_MAS_ApplicationDetails] AD ON NW.ApplicationID = AD.ApplicationID      
   WHERE NW.projectID = @ProjectId      
    AND NW.isdeleted = 0      
      
   UPDATE #table1      
   SET OptionalFieldNoiseWord = NULL      
   WHERE OptionalFieldNoiseWord = '';      
      
   -- Table 2                        
   INSERT INTO #table2      
   SELECT 'All' AS 'Name'      
      
   INSERT INTO #table2      
   SELECT AD.ApplicationName AS 'Name'      
   FROM [AVL].[APP_MAP_ApplicationProjectMapping] APM      
   JOIN [AVL].[APP_MAS_ApplicationDetails] AD ON APM.ApplicationID = AD.ApplicationID      
   WHERE APM.projectID = @ProjectId      
    AND APM.isdeleted = 0      
      
   -- Table 3                        
   INSERT INTO #table3      
   SELECT 'Application Name*' AS 'Name'      
    ,'Stop Word for issue description'      
    ,'Frequency'      
    ,'IsStop*'      
    ,'Stop Word for Resolution Provided'      
    ,'FrequencyResoluion'      
    ,'IsStopResolution*'      
      
   -- Table 4                        
   INSERT INTO #table4      
   SELECT TOP (1) FromDate      
    ,ToDate      
   FROM [ML].[TRN_MLTransaction]      
   WHERE ProjectId = @ProjectId AND SupportTypeId=1     
   ORDER BY CreatedDate DESC      
  END      
      
  IF @downloadMode = 2 -- Infra Support                         
  BEGIN      
   -- Table 1                        
   INSERT INTO #table1      
   SELECT 'All' AS 'Name'      
    ,TicketDescNoiseWord      
    ,IIF(TicketDescNoiseWord IS NULL      
     OR TicketDescNoiseWord = '', NULL, Frequency)      
    ,IIF(TicketDescNoiseWord IS NULL      
     OR TicketDescNoiseWord = '', NULL, IsActive)      
    ,OptionalFieldNoiseWord      
    ,IIF(OptionalFieldNoiseWord IS NULL      
     OR OptionalFieldNoiseWord = '', NULL, OptionalFieldFrequency)      
    ,IIF(OptionalFieldNoiseWord IS NULL      
     OR OptionalFieldNoiseWord = '', NULL, IsActiveResolution)      
   FROM [ML].[TRN_AppInfraNoiseWords]      
   WHERE projectID = @ProjectId      
    AND IsAppInfra = 2      
    AND TowerId IS NULL      
      
   INSERT INTO #table1      
   SELECT TD.TowerName AS 'Name'      
    ,NW.TicketDescNoiseWord      
    ,IIF(NW.TicketDescNoiseWord IS NULL      
     OR NW.TicketDescNoiseWord = '', NULL, NW.Frequency)      
    ,IIF(NW.TicketDescNoiseWord IS NULL      
     OR NW.TicketDescNoiseWord = '', NULL, NW.IsActive)      
    ,NW.OptionalFieldNoiseWord      
    ,IIF(NW.OptionalFieldNoiseWord IS NULL      
     OR NW.OptionalFieldNoiseWord = '', NULL, NW.OptionalFieldFrequency)      
    ,IIF(NW.OptionalFieldNoiseWord IS NULL      
     OR NW.OptionalFieldNoiseWord = '', NULL, NW.IsActiveResolution)      
   FROM [ML].[TRN_AppInfraNoiseWords] NW      
   JOIN AVL.InfraTowerDetailsTransaction TD ON NW.TowerID = TD.InfraTowerTransactionID      
   WHERE NW.projectID = @ProjectId      
    AND NW.isdeleted = 0      
      
   UPDATE #table1      
   SET OptionalFieldNoiseWord = NULL      
   WHERE OptionalFieldNoiseWord = '';      
      
   -- Table 2                        
   INSERT INTO #table2      
   SELECT 'All' AS 'Name'      
      
   INSERT INTO #table2      
   SELECT TD.TowerName AS 'Name'      
   FROM [AVL].[InfraTowerProjectMapping] IPM      
   JOIN [AVL].[InfraTowerDetailsTransaction] TD ON IPM.TowerID = TD.InfraTowerTransactionID      
   WHERE IPM.projectID = @ProjectId      
    AND IPM.isdeleted = 0      
      
   -- Table 3                        
   INSERT INTO #table3      
   SELECT 'Tower Name*' AS 'Name'      
    ,'Stop Word for issue description'      
    ,'Frequency'      
    ,'IsStop*'      
    ,'Stop Word for Resolution Provided'      
    ,'FrequencyResoluion'      
    ,'IsStopResolution*'      
      
   -- Table 4                        
   INSERT INTO #table4      
   SELECT TOP (1) FromDate      
    ,ToDate      
   FROM [ML].[TRN_MLTransaction]      
   WHERE ProjectId = @ProjectId AND SupportTypeId=2     
   ORDER BY CreatedDate DESC      
  END      
      
  SELECT Name      
   ,TicketDescNoiseWord      
   ,SUM(Frequency) AS 'Frequency'      
   ,IsActive      
   ,OptionalFieldNoiseWord      
   ,OptionalFieldFrequency      
   ,IsActiveResolution      
  FROM #table1      
  GROUP BY TicketDescNoiseWord      
   ,Name      
   ,IsActive      
   ,OptionalFieldNoiseWord      
   ,OptionalFieldFrequency      
   ,IsActiveResolution;      
      
  SELECT Name      
  FROM #table2;      
      
  SELECT ColumnName      
   ,Noise      
   ,Frequency      
   ,IsActive      
   ,OptionalFieldNoiseWord      
   ,OptionalFieldFrequency      
   ,IsActiveResolution      
  FROM #table3;      
      
  SELECT FromDate      
   ,ToDate      
  FROM #table4;      
      
  DROP TABLE #table1;      
      
  DROP TABLE #table2;      
      
  DROP TABLE #table3;      
        
  DROP TABLE #table4;      
 END TRY      
      
 BEGIN CATCH      
  DECLARE @ErrorMessage VARCHAR(max);      
      
  SELECT @ErrorMessage = error_message()      
      
  EXEC AVL_InsertError '[ML].[Noise_GetApplicationDetailsForExcel] '      
   ,@ErrorMessage      
   ,@ProjectId      
   ,0      
 END CATCH      
      
 SET NOCOUNT OFF;      
END
