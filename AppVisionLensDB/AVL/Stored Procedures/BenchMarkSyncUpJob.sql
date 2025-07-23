/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =========================================================================================
-- Author      : Dhivya Bharathi M
-- Create date : Jan 22, 2020
-- Description :          
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [AVL].[BenchMarkSyncUpJob]
@BMAnalysisTVP AVL.TVP_BMAnalysis READONLY,
@BMAnalysisWorkbenchTVP AVL.TVP_BMAnalysisWorkbench READONLY,
@BMBenchmarkvaluesTVP AVL.TVP_BMBenchmarkvalues READONLY,
@BMSubOfferingMappingTVP AVL.TVP_BMSubOfferingMapping READONLY,
@BMMasParameterTVP AVL.TVP_BMMasParameter READONLY

AS 
  BEGIN 
	BEGIN TRY 
		SET NOCOUNT ON;

		DECLARE @SqlBMAnalysis NVARCHAR(4000);
		DECLARE @SqlBMAnalysis_Workbench NVARCHAR(4000);
		DECLARE @SqlBMBenchmark_values NVARCHAR(4000);
		DECLARE @SqlBMSubOfferingMapping NVARCHAR(4000);
		DECLARE @SqlBMMas_Parameter NVARCHAR(4000);
		DECLARE @MasterJobID BIGINT;
		DECLARE @RecentJobID BIGINT;
		DECLARE @JobName NVARCHAR(100)='BenchMark SyncUp Job';
		DECLARE @JobStatusSuccess NVARCHAR(10)='Success'
		DECLARE @JobStatusFailed NVARCHAR(10)='Failed'
		DECLARE @OrgParamName NVARCHAR(10) ='Org';
		DECLARE @BUParamName NVARCHAR(10) ='BU';
		DECLARE @ServiceIdentification NVARCHAR(50) ='Service';
		DECLARE @SubOfferingIdentification NVARCHAR(50) ='SubOffering';
		DECLARE @AnalysisID BIGINT;
		DECLARE @OrgParameterID INT;
		DECLARE @BUParameterID INT;
		DECLARE @OrgParameterIDAppLens INT;
		DECLARE @BUParameterIDAppLens INT;
		DECLARE @AnalysisWorkTrackId INT;
		CREATE TABLE #BMAnalysis(
			[Analysis_Id] [bigint] NOT NULL,
			[Start_date] [date] NULL,
			[End_date] [date] NULL,
			[Effective_date] [date] NULL,
			[Status] [int] NULL,
			[IsBenchmark] [bit] NULL)
		CREATE TABLE #BMAnalysis_Workbench(
			[Analysis_Bench_Id] [bigint] NOT NULL,
			[Analysis_Id] [bigint] NOT NULL,
			[Parameter_Id] [int] NOT NULL,
			[Parameter_value] [int] NULL,
			[Detail_Id] [int] NULL,
			[Status_Id] [int] NULL)
		CREATE TABLE #BMBenchmark_values(
			[Analysis_Bench_Id] [bigint] NOT NULL,
			[Service_level] [varchar](255) NULL,
			[Service_Id] [int] NULL,
			[Value] [decimal](18, 2) NULL,
			[Status] [int] NULL)
		CREATE TABLE #BMSubOfferingMapping(
			[Sub_offeringID] [int] NOT NULL,
			[ServiceId] [int] NOT NULL,
			[Sub_Offering] [varchar](80) NOT NULL)
		CREATE TABLE #BMMas_Parameter(
			[Parameter_Id] [int] NOT NULL,
			[Parameter_name] [varchar](255) NOT NULL
			)
	   CREATE TABLE #DataTemp
		(
			ParameterID INT NOT NULL,
			BUId INT NULL,
			Analysis_Bench_Id INT NULL,
			Service_Level NVARCHAR(100) NULL,
			Service_Id INT NULL,
			Value DECIMAL(18,2) NULL
		)
		CREATE TABLE #BenchMarkValuesByService
		(
			[AnalysisTrackID] [bigint] NOT NULL,
			[BenchMarkParameterID] [int] NOT NULL,
			[ParameterValue] DECIMAL(5,2) NULL,
			[ServiceID] [int] NOT NULL,
			[BenchMarkLevel] [int] NULL,
			[BenchMarkValue] [decimal](18, 2) NULL
		)
		CREATE TABLE #SubOfferingNames
		 (
			 Sub_offeringID INT NOT NULL,
			 ServiceID INT NOT NULL,
			 Sub_Offering NVARCHAR(500) NOT NULL,
			 Sub_OfferingSplit NVARCHAR(50)  NULL,
			 LevelID INT  NULL
		 )


		INSERT INTO #BMAnalysis(Analysis_Id,Start_date,End_date,Effective_date,Status,IsBenchmark) 
		SELECT Analysis_Id,Start_date,End_date,Effective_date,Status,IsBenchmark FROM @BMAnalysisTVP

		INSERT INTO #BMAnalysis_Workbench (Analysis_Bench_Id,Analysis_Id,Parameter_Id,Parameter_value,
		Detail_Id,Status_Id)
		SELECT Analysis_Bench_Id,Analysis_Id,Parameter_Id,Parameter_value,
		Detail_Id,Status_Id FROM @BMAnalysisWorkbenchTVP

		INSERT INTO #BMBenchmark_values (Analysis_Bench_Id,Service_level,Service_Id,Value,Status)
		SELECT Analysis_Bench_Id,Service_level,Service_Id,Value,Status FROM @BMBenchmarkvaluesTVP
		WHERE Status =4

		INSERT INTO #BMSubOfferingMapping (Sub_offeringID,ServiceId,Sub_Offering)
		SELECT Sub_offeringID,ServiceId,Sub_Offering FROM @BMSubOfferingMappingTVP

		INSERT INTO #BMMas_Parameter (Parameter_Id,Parameter_name)
		SELECT Parameter_Id,Parameter_name FROM @BMMasParameterTVP

		SET @MasterJobID=(SELECT JobID FROM [MAS].[JobMaster] WHERE JobName=@JobName)
		SET @OrgParameterID=(SELECT TOP 1 Parameter_Id FROM #BMMas_Parameter
						  WHERE Parameter_name =@OrgParamName ORDER BY Parameter_Id DESC)
		SET @BUParameterID=(SELECT TOP 1 Parameter_Id FROM #BMMas_Parameter
						  WHERE Parameter_name =@BUParamName ORDER BY Parameter_Id DESC)
		SET @OrgParameterIDAppLens=(SELECT BenchMarkParameterID FROM MAS.BenchMarkParameter
						  WHERE BenchMarkParameterName =@OrgParamName)
		SET @BUParameterIDAppLens=(SELECT BenchMarkParameterID FROM MAS.BenchMarkParameter
						  WHERE BenchMarkParameterName =@BUParamName)

		 SET @AnalysisID=(SELECT TOP 1 AN.Analysis_Id
						FROM #BMAnalysis  AN
						INNER JOIN #BMAnalysis_Workbench AW ON AN.Analysis_Id=AW.Analysis_Id AND AW.Detail_Id=1
						AND AW.Parameter_Id in(@OrgParameterID,@BUParameterID) AND AW.Status_Id=4
						INNER JOIN #BMBenchmark_values BV ON AW.Analysis_Bench_Id = BV.Analysis_Bench_Id 
						AND BV.Status=4
						WHERE AN.[Status] =4 AND AN.IsBenchMark =1 
						ORDER BY AN.Analysis_Id DESC)

		INSERT INTO  MAS.JobStatus(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate) 
		VALUES (@MasterJobID,GETDATE(),'','',GETDATE(),0,@JobName,GETDATE())
		SET @RecentJobID  = SCOPE_IDENTITY();
		IF NOT EXISTS (SELECT 1 FROM AVL.BenchMarkAnalysisTrack(NOLOCK) WHERE AnalysisID=@AnalysisID)
		BEGIN
			INSERT INTO AVL.BenchMarkAnalysisTrack(AnalysisID,StartDate,EndDate,EffectiveDate,IsDeleted,
			CreatedBy,CreatedDate)
			SELECT TOP 1 Analysis_Id,Start_date,End_date,Effective_date,0,
			'Job',GETDATE() FROM #BMAnalysis
			WHERE Analysis_Id=@AnalysisID
			AND Status =4 AND IsBenchMark =1
		END
		SET @AnalysisWorkTrackId=(SELECT TOP 1 ID FROM AVL.BenchMarkAnalysisTrack(NOLOCK) 
								  WHERE AnalysisID=@AnalysisID
								   ORDER BY ID DESC)

		SELECT DISTINCT Analysis_Bench_Id,Parameter_Id,Parameter_value AS BUId  INTO #AnalysisBUBenchIds 
		FROM #BMAnalysis_Workbench 
		WHERE Parameter_Id =@BUParameterID
		AND Status_Id=4 AND Analysis_Id=@AnalysisID AND Detail_Id=1

		INSERT INTO #DataTemp
		SELECT @BUParameterIDAppLens AS BUParameterID,BT.BUId,BV.Analysis_Bench_Id,BV.Service_level,Service_Id,[Value] 
		FROM #BMBenchmark_values  BV
		INNER JOIN #AnalysisBUBenchIds BT ON BV.Analysis_Bench_Id = BT.Analysis_Bench_Id
		INNER JOIN AVL.BusinessUnit(NOLOCK) BU ON BT.BUId= BU.BUID
		WHERE BV.Service_level IN(@ServiceIdentification,@SubOfferingIdentification)

		SELECT Analysis_Bench_Id,Parameter_Id,Parameter_value
		INTO #AnalysisOrgBenchIds
		FROM #BMAnalysis_Workbench 
		WHERE Parameter_Id =@OrgParameterID
		AND Status_Id=4 AND Analysis_Id=@AnalysisID AND Detail_Id=1


		INSERT INTO #DataTemp
		SELECT @OrgParameterIDAppLens AS BUParameterID,NULL as BUId,BV.Analysis_Bench_Id,BV.Service_level,Service_Id,[Value] 
		FROM #BMBenchmark_values  BV
		INNER JOIN #AnalysisOrgBenchIds BT ON BV.Analysis_Bench_Id = BT.Analysis_Bench_Id
		WHERE BV.Service_level IN(@ServiceIdentification,@SubOfferingIdentification)

		INSERT INTO #BenchMarkValuesByService(AnalysisTrackID,BenchMarkParameterID,ParameterValue,
		ServiceID,BenchMarkValue)
		SELECT @AnalysisWorkTrackId,ParameterID,OT.BUId,Service_ID,[Value]
		FROM #DataTemp OT
		WHERE Service_level=@ServiceIdentification

		 INSERT INTO #SubOfferingNames
		 select  Sub_offeringID,ServiceID,Sub_Offering,
		 CASE WHEN charindex('_',Sub_Offering) >0 THEN
		 right(Sub_Offering, charindex('_', reverse(Sub_Offering)) - 1)
		 ELSE '' END AS Sub_OfferingSplit,
		 0
		 FROM #BMSubOfferingMapping

		UPDATE #SubOfferingNames SET Sub_OfferingSplit='Very Complex' WHERE Sub_Offering LIKE '%Very_Complex%'
		
		UPDATE T1 SET T1.LevelID=SOM.BenchMarkLevelID FROM #SubOfferingNames T1
		INNER JOIN MAS.BenchMarkLevels SOM
		ON T1.Sub_OfferingSplit=SOM.BenchMarkLevelName

		INSERT INTO #BenchMarkValuesByService(AnalysisTrackID,BenchMarkParameterID,ParameterValue,
		ServiceID,BenchMarkLevel,BenchMarkValue)
		SELECT @AnalysisWorkTrackId as AnalysisID,DT.ParameterID,DT.BUId,SOM.ServiceId,SOM.LevelID,[Value]
		FROM #DataTemp DT
		INNER JOIN #SubOfferingNames SOM ON DT.Service_Id=SOM.Sub_offeringID
		WHERE Service_level=@SubOfferingIdentification

		CREATE TABLE #BenchMarkValuesByServiceFiltered
		(
		AnalysisTrackID BIGINT NOT NULL,
		ServiceID INT NOT NULL,
		BenchMarkParameterID INT NOT NULL,
		BenchMarkLevel INT NULL,
		ParameterValue INT NULL,
		BenchMarkValue DECIMAL(18,2) NULL
		)
		INSERT INTO #BenchMarkValuesByServiceFiltered 
		SELECT DISTINCT AnalysisTrackID,ServiceID,BenchMarkParameterID,BenchMarkLevel,ParameterValue,NULL AS
		BenchMarkValue
		FROM #BenchMarkValuesByService

		UPDATE BF 
		SET BF.BenchMarkValue=BS.BenchMarkValue
		FROM #BenchMarkValuesByService BS
		INNER JOIN #BenchMarkValuesByServiceFiltered BF
		ON BS.AnalysisTrackID=BF.AnalysisTrackID AND
		ISNULL(BS.ServiceID,0)=ISNULL(BF.ServiceID,0) AND
		ISNULL(BS.BenchMarkParameterID,0)=ISNULL(BF.BenchMarkParameterID,0)  AND
		ISNULL(BS.BenchMarkLevel,0)=ISNULL(BF.BenchMarkLevel,0) AND
		ISNULL(BS.ParameterValue,0)=ISNULL(BF.ParameterValue,0) 

		MERGE AVL.BenchMarkValuesByService bi
		USING #BenchMarkValuesByServiceFiltered bo
		ON bi.AnalysisTrackID = @AnalysisWorkTrackId AND bi.ServiceID=bo.ServiceID
		AND bi.BenchMarkParameterID=bo.BenchMarkParameterID AND ISNULL(bi.BenchMarkLevel,0)=ISNULL(bo.BenchMarkLevel,0)
		AND ISNULL(bi.ParameterValue,0)=ISNULL(bo.ParameterValue,0)
		WHEN MATCHED THEN
		UPDATE
		SET 
		bi.BenchMarkValue=bo.BenchMarkValue,
		bi.ModifiedBy='Job',
		bi.ModifiedDate=GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (AnalysisTrackID,BenchMarkParameterID,ParameterValue,
		ServiceID,BenchMarkLevel,BenchMarkValue,IsDeleted,CreatedBy,CreatedDate)
		VALUES( @AnalysisWorkTrackId,BenchMarkParameterID,ParameterValue,ServiceID,BenchMarkLevel,BenchMarkValue,0,'Job',GETDATE());

		IF ((SELECT COUNT(1) FROM #BenchMarkValuesByServiceFiltered) > 0)
			BEGIN
				DELETE FROM AVL.BenchMarkValuesByService  WHERE AnalysisTrackID !=@AnalysisWorkTrackId
			END

		IF OBJECT_ID('tempdb..#SubOfferingNames', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #SubOfferingNames
		END
		IF OBJECT_ID('tempdb..#DataTemp', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #DataTemp
		END
		IF OBJECT_ID('tempdb..#BenchMarkValuesByService', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #BenchMarkValuesByService
		END
		IF OBJECT_ID('tempdb..#AnalysisBUBenchIds', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #AnalysisBUBenchIds
		END
		IF OBJECT_ID('tempdb..#AnalysisOrgBenchIds', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #AnalysisOrgBenchIds
		END
		IF OBJECT_ID('tempdb..#BMAnalysis', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #BMAnalysis
		END
		IF OBJECT_ID('tempdb..#BMAnalysis_Workbench', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #BMAnalysis_Workbench
		END
		IF OBJECT_ID('tempdb..#BMBenchmark_values', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #BMBenchmark_values
		END
		IF OBJECT_ID('tempdb..#BMSubOfferingMapping', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #BMSubOfferingMapping
		END
		IF OBJECT_ID('tempdb..#BenchMarkValuesByServiceFiltered', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #BenchMarkValuesByServiceFiltered
		END
		
		UPDATE MAS.JobStatus SET EndDateTime = GETDATE(),JobStatus = @JobStatusSuccess
		WHERE ID  = @RecentJobID
	END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		UPDATE MAS.JobStatus set EndDateTime = GETDATE(),JobStatus = @JobStatusFailed where ID  = @RecentJobID
        --INSERT Error     
        EXEC AVL_INSERTERROR  '[AVL].[BenchMarkSyncUpJob]', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
