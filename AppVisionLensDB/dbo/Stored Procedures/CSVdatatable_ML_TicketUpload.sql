/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[CSVdatatable_ML_TicketUpload]-- 44637,1
@projectID int,
@supportType int,
@BatchProcessApp bigint = null,
@BatchProcessInfra bigint = null
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	
	Declare @CountForAddPattern BIGINT
	Declare @MlDebtAttributes INT = 0 
	Declare @MlInfraDebtAttributes INT = 0 
	DECLARE @AdditionalText NVARCHAR(MAX);
	DECLARE @AdditionalTextFlag NVARCHAR(MAX);
	DECLARE @AdditionalTextFlagInfra NVARCHAR(MAX);
	SET @AdditionalTextFlag = (SELECT  TOP 1 CASE WHEN IsOptionalField = 1 THEN 'Resolution Remarks' ELSE 'NA' END
	FROM ML.ConfigurationProgress(NOLOCK) WHERE ProjectId = @ProjectId AND Isdeleted = 0)
	SET @AdditionalTextFlagInfra = (SELECT  TOP 1 CASE WHEN IsOptionalField = 1 THEN 'Resolution Remarks' ELSE 'NA' END
	FROM ML.InfraConfigurationProgress(NOLOCK) WHERE ProjectId = @ProjectId AND Isdeleted = 0)


	set @CountForAddPattern=  CASE WHEN (@supportType = 1) THEN (select COUNT(DISTINCT ID) from ML.TRN_PatternValidation where ProjectID=@projectid and IsDeleted=0 and IsApprovedOrMute=1
		and additionalPattern<>'0')			
		ELSE
		(select COUNT(DISTINCT ID) from ML.InfraTRN_PatternValidation where ProjectID=@projectid and IsDeleted=0 and IsApprovedOrMute=1
		and additionalPattern<>'0'	)	END

	IF(@CountForAddPattern>0)
	BEGIN
		IF(@supportType = 1 OR @supportType=2)
		BEGIN
			SET @AdditionalText ='Resolution Remarks'
		END
		
	END
	ELSE
	BEGIN
	SELECT @AdditionalText='NA' 
	END

	SET @MlDebtAttributes= (SELECT TOP 1 DebtAttributeId FROM ML.ConfigurationProgress where ProjectID=@projectid and IsDeleted=0)  
	SET @MlInfraDebtAttributes = (SELECT TOP 1 DebtAttributeId FROM ML.InfraConfigurationProgress where ProjectID=@projectid and IsDeleted=0)  

	DECLARE @isMultiLingual INT=0;
	DECLARE @TicketDescription [BIT]=0,
			@ResolutionRemarks [BIT]=0,
			@TicketSummary [BIT]=0,
			@Comments [BIT]=0;

	SELECT @isMultiLingual = 1 FROM AVL.MAS_ProjectMaster WITH (NOLOCK) WHERE ProjectID=@projectID AND
	IsDeleted = 0 AND IsMultilingualEnabled = 1;

	SELECT DISTINCT MCM.ColumnID INTO #Columns FROM AVL.MAS_MultilingualColumnMaster MCM WITH (NOLOCK) 
	JOIN AVL.PRJ_MultilingualColumnMapping MCP WITH(NOLOCK) ON MCM.ColumnID=MCP.ColumnID
	WHERE MCM.IsActive=1 AND MCP.IsActive=1
	AND MCP.ProjectID=@projectID;

	SELECT @TicketDescription=1 FROM #Columns WHERE ColumnID=1;
	SELECT @TicketSummary=1 FROM #Columns WHERE ColumnID=2;
	SELECT @ResolutionRemarks=1 FROM #Columns WHERE ColumnID=3;	
	SELECT @Comments=1 FROM #Columns WHERE ColumnID=4;

IF(@supportType = 1)
BEGIN
	
	IF (@isMultiLingual = 1 AND (@TicketDescription = 1 OR @TicketSummary = 1 OR @ResolutionRemarks = 1 OR @Comments = 1))		
	BEGIN
		SELECT DISTINCT td.ProjectID,TD.ApplicationID,TD.TicketID,
		CASE WHEN @TicketDescription = 1 THEN
				 CASE WHEN MTTD.TicketDescription = NULL THEN '' 
				 ELSE
					MTTD.TicketDescription  
				 END
		ELSE
				CASE WHEN TD.TicketDescription = NULL THEN ''
				ELSE 
					TD.TicketDescription  
				END
		END AS TicketDescription,

		CASE WHEN @AdditionalText='Resolution Remarks' THEN 
			CASE WHEN @ResolutionRemarks = 1 THEN
				MTTD.ResolutionRemarks 
			ELSE
				TD.ResolutionRemarks 
			END
			WHEN @AdditionalText='Ticket Summary' THEN 
			CASE WHEN @TicketSummary = 1 THEN
				MTTD.TicketSummary
			ELSE
				TD.TicketSummary
			END
			WHEN @AdditionalText='Comments' THEN 
			CASE WHEN @Comments = 1 THEN
				MTTD.Comments 
			ELSE
				TD.Comments 
			END
			WHEN @AdditionalText='NA' THEN 'NA' END AS AdditionalText,
			
		CASE WHEN CP.IsOptionalField = 1 THEN 'Resolution Remarks' ELSE 'NA' END AS AdditionalTextFlag,		    
		CASE WHEN @MlDebtAttributes = 1   
		THEN TD.CauseCodeMapID  
		ELSE NULL  
		END AS CauseCodeID,  
		CASE WHEN @MlDebtAttributes = 1  
		THEN TD.ResolutionCodeMapID   
		ELSE NULL  
		END AS ResolutionCodeID,    
		ISNULL(MLC.DescWorkPattern,'0') AS DescWorkPattern,
		ISNULL(MLC.DescSubWorkPattern,'0') AS DescSubWorkPattern,
		CASE WHEN CP.IsOptionalField = 1 THEN ISNULL(MLC.ResolutionWorkPattern,'0') ELSE '0' END AS ResolutionWorkPattern, 
		CASE WHEN CP.IsOptionalField = 1 THEN ISNULL(MLC.ResolutionSubWorkPattern,'0') ELSE '0' END AS ResolutionSubWorkPattern
		into #tickettempMLAPP from AVL.TK_TRN_TicketDetail  AS TD 		
		LEFT JOIN ML.ConfigurationProgress CP ON TD.ProjectID = CP.ProjectID AND CP.IsDeleted = 0   
		INNER JOIN AVL.TK_MLClassification_TicketUpload AS MLC
		ON MLC.[Ticket ID] = TD.TicketID AND MLC.ProjectID =  TD.ProjectID AND TD.IsDeleted=0
		INNER JOIN AVL.TK_TRN_Multilingual_TranslatedTicketDetails MTTD ON TD.TimeTickerID = MTTD.TimeTickerID AND MTTD.Isdeleted = 0
		AND (@TicketDescription = 0 OR (@TicketDescription = 1 AND MTTD.IsTicketDescriptionUpdated = 0))
		AND (@TicketSummary = 0 OR (@TicketSummary = 1 AND MTTD.IsTicketSummaryUpdated = 0))
		AND (@ResolutionRemarks = 0 OR (@ResolutionRemarks = 1 AND MTTD.IsResolutionRemarksUpdated = 0))
		AND (@Comments = 0 OR (@Comments = 1 AND MTTD.IsCommentsUpdated = 0))
		WHERE TD.ProjectID = @projectID and MLC.SupportType = 1
		
		IF NOT EXISTS (select BatchProcessId from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessApp)
		BEGIN 
			insert into [ML].[TicketsForClassification]
			select @BatchProcessApp,ApplicationID,TicketID,TicketDescription,AdditionalText,CauseCodeID,ResolutionCodeID,DescWorkPattern,DescSubWorkPattern,
			ResolutionWorkPattern,ResolutionSubWorkPattern,null,null,null,null,null,null,13,0,'BatchProcess',getdate(),null,null from #tickettempMLAPP
		END 
		select BatchProcessId,TicketId,@projectID as projectID,TicketDescription,AdditionalText,@AdditionalTextFlag AS AdditionalTextFlag  from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessApp

	END
	ELSE
	BEGIN
		SELECT DISTINCT td.ProjectID,TD.ApplicationID,TD.TicketID,
		CASE WHEN TD.TicketDescription = NULL THEN '' ELSE TD.TicketDescription  END AS TicketDescription,

		CASE WHEN @AdditionalText='Resolution Remarks' THEN TD.ResolutionRemarks 
			WHEN @AdditionalText='Ticket Summary' THEN TD.TicketSummary
				 WHEN @AdditionalText='Comments' THEN TD.Comments 
					 WHEN @AdditionalText='NA' THEN 'NA' END AS AdditionalText,

		CASE WHEN CP.IsOptionalField = 1 THEN 'Resolution Remarks' ELSE 'NA' END AS AdditionalTextFlag,		    
		CASE WHEN @MlDebtAttributes = 1   
		THEN TD.CauseCodeMapID  
		ELSE NULL  
		END AS CauseCodeID,  
		CASE WHEN @MlDebtAttributes = 1  
		THEN TD.ResolutionCodeMapID   
		ELSE NULL  
		END AS ResolutionCodeID,   
		ISNULL(MLC.DescWorkPattern,'0') AS DescWorkPattern,
		ISNULL(MLC.DescSubWorkPattern,'0') AS DescSubWorkPattern,
		CASE WHEN CP.IsOptionalField = 1 THEN ISNULL(MLC.ResolutionWorkPattern,'0') ELSE '0' END AS ResolutionWorkPattern,
		CASE WHEN CP.IsOptionalField = 1 THEN ISNULL(MLC.ResolutionSubWorkPattern,'0') ELSE '0' END AS ResolutionSubWorkPattern
			into #tickettempAPP from AVL.TK_TRN_TicketDetail  AS TD
		LEFT JOIN ML.ConfigurationProgress CP ON TD.ProjectID = CP.ProjectID AND CP.IsDeleted = 0   
		INNER JOIN AVL.TK_MLClassification_TicketUpload AS MLC
		ON MLC.[Ticket ID] = TD.TicketID AND MLC.ProjectID =  TD.ProjectID AND TD.IsDeleted=0
		WHERE TD.ProjectID = @projectID and MLC.SupportType = 1
		
		IF NOT EXISTS (select BatchProcessId from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessApp)
		BEGIN 
			insert into [ML].[TicketsForClassification]
			select @BatchProcessApp,ApplicationID,TicketID,TicketDescription,AdditionalText,CauseCodeID,ResolutionCodeID,DescWorkPattern,DescSubWorkPattern,
			ResolutionWorkPattern,ResolutionSubWorkPattern,null,null,null,null,null,null,13,0,'BatchProcess',getdate(),null,null from #tickettempAPP
		END
		select BatchProcessId,TicketId,@projectID as projectID,TicketDescription,AdditionalText,@AdditionalTextFlag AS AdditionalTextFlag from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessApp
	END
END
ELSE
BEGIN	
	IF (@isMultiLingual = 1 AND (@TicketDescription = 1 OR @TicketSummary = 1 OR @ResolutionRemarks = 1 OR @Comments = 1))		
	BEGIN
		SELECT DISTINCT td.ProjectID AS ProjectID ,TD.TowerID,TD.TicketID AS [TicketID],
		CASE WHEN @TicketDescription = 1 THEN
				 CASE WHEN MTTD.TicketDescription = NULL THEN '' 
				 ELSE
					MTTD.TicketDescription  
				 END
		ELSE
				CASE WHEN TD.TicketDescription = NULL THEN ''
				ELSE 
					TD.TicketDescription  
				END
		END AS TicketDescription,

		CASE WHEN @AdditionalText='Resolution Remarks' THEN 
			CASE WHEN @ResolutionRemarks = 1 THEN
				MTTD.ResolutionRemarks 
			ELSE
				TD.ResolutionRemarks 
			END
			WHEN @AdditionalText='Ticket Summary' THEN 
			CASE WHEN @TicketSummary = 1 THEN
				MTTD.TicketSummary
			ELSE
				TD.TicketSummary
			END
			WHEN @AdditionalText='Comments' THEN 
			CASE WHEN @Comments = 1 THEN
				MTTD.Comments 
			ELSE
				TD.Comments 
			END
			WHEN @AdditionalText='NA' THEN 'NA' END AS AdditionalText,
			CASE WHEN CP.IsOptionalField = 1 THEN 'Resolution Remarks' ELSE 'NA' END AS AdditionalTextFlag,			
			CASE WHEN @MlInfraDebtAttributes = 1   
			THEN TD.CauseCodeMapID  
			ELSE NULL  
			END AS CauseCodeID,  
			CASE WHEN @MlInfraDebtAttributes = 1  
			THEN TD.ResolutionCodeMapID   
			ELSE NULL  
			END AS ResolutionCodeID   
		into #tickettempMLInfra  from AVL.TK_TRN_InfraTicketDetail AS TD			
		LEFT JOIN ML.InfraConfigurationProgress CP ON TD.ProjectID = CP.ProjectID AND CP.IsDeleted = 0 
		INNER JOIN AVL.TK_MLClassification_TicketUpload AS MLC
		ON MLC.[Ticket ID] = TD.TicketID AND MLC.ProjectID =  TD.ProjectID AND TD.IsDeleted=0
		INNER JOIN AVL.TK_TRN_Multilingual_TranslatedTicketDetails MTTD ON TD.TimeTickerID = MTTD.TimeTickerID AND MTTD.Isdeleted = 0
		AND (@TicketDescription = 0 OR (@TicketDescription = 1 AND MTTD.IsTicketDescriptionUpdated = 0))
		AND (@TicketSummary = 0 OR (@TicketSummary = 1 AND MTTD.IsTicketSummaryUpdated = 0))
		AND (@ResolutionRemarks = 0 OR (@ResolutionRemarks = 1 AND MTTD.IsResolutionRemarksUpdated = 0))
		AND (@Comments = 0 OR (@Comments = 1 AND MTTD.IsCommentsUpdated = 0))
		WHERE TD.ProjectID = @projectID and MLC.SupportType = 2

		IF NOT EXISTS (select BatchProcessId from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessInfra)
		BEGIN 
			insert into [ML].[TicketsForClassification]
			select @BatchProcessInfra,TowerID,[TicketID] as TicketID,TicketDescription,AdditionalText,CauseCodeID,ResolutionCodeID,null,null,
			null,null,null,null,null,null,null,null,13,0,'BatchProcess',getdate(),null,null from #tickettempMLInfra
		END
		select BatchProcessId,TicketId,@projectID as projectID,TicketDescription,AdditionalText,@AdditionalTextFlagInfra AS AdditionalTextFlag from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessInfra

	END
	ELSE
	BEGIN
		SELECT DISTINCT td.ProjectID AS ProjectID ,TD.TowerID,TD.TicketID AS [TicketID],
		CASE WHEN TD.TicketDescription = NULL THEN '' ELSE TD.TicketDescription  END AS TicketDescription,

		CASE WHEN @AdditionalText='Resolution Remarks' THEN TD.ResolutionRemarks 
			WHEN @AdditionalText='Ticket Summary' THEN TD.TicketSummary
				 WHEN @AdditionalText='Comments' THEN TD.Comments 
					 WHEN @AdditionalText='NA' THEN 'NA' END AS AdditionalText,

		CASE WHEN CP.IsOptionalField = 1 THEN 'Resolution Remarks' ELSE 'NA' END AS AdditionalTextFlag,	    
		CASE WHEN @MlInfraDebtAttributes = 1   
		THEN TD.CauseCodeMapID  
		ELSE NULL  
		END AS CauseCodeID,  
		CASE WHEN @MlInfraDebtAttributes = 1  
		THEN TD.ResolutionCodeMapID   
		ELSE NULL  
		END AS ResolutionCodeID    
		into #tickettempInfra from AVL.TK_TRN_InfraTicketDetail AS TD	
		LEFT JOIN ML.InfraConfigurationProgress CP ON TD.ProjectID = CP.ProjectID AND CP.IsDeleted = 0 
		INNER JOIN AVL.TK_MLClassification_TicketUpload AS MLC
		ON MLC.[Ticket ID] = TD.TicketID AND MLC.ProjectID =  TD.ProjectID AND TD.IsDeleted=0
		WHERE TD.ProjectID = @projectID and MLC.SupportType = 2

		IF NOT EXISTS (select BatchProcessId from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessInfra)
		BEGIN 
			insert into [ML].[TicketsForClassification]
			select @BatchProcessInfra,TowerID,[TicketID] as TicketID,TicketDescription,AdditionalText,CauseCodeID,ResolutionCodeID,null,null,
			null,null,null,null,null,null,null,null,13,0,'BatchProcess',getdate(),null,null from #tickettempInfra
		END 
		select BatchProcessId,TicketId,@projectID as projectID,TicketDescription,AdditionalText,@AdditionalTextFlagInfra AS AdditionalTextFlag from [ML].[TicketsForClassification] where BatchProcessId = @BatchProcessInfra
	END
END


END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[CSVdatatable_ML_TicketUpload]', @ErrorMessage,@projectID 
END CATCH
END
