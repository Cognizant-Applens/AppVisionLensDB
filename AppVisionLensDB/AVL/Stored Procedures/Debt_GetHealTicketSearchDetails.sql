/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[AVL].[Debt_GetHealTicketSearchDetails] '','19155','','','1/1/2018','1/31/2018'
CREATE PROCEDURE [AVL].[Debt_GetHealTicketSearchDetails]
	                
    @AppID NVARCHAR(MAX) ,                
    @ProjectID NVARCHAR(MAX)  ,
	@TopKvalue NVARCHAR(100),
	@KvalueOption NVARCHAR(50),
	@DateFrom DATETIME =NULL,
	@DateTo DATETIME=NULL

AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;  
                       
  DECLARE @cte_AppID AS TABLE(AppID NVARCHAR(MAX));                          
  DECLARE @cte_Project AS TABLE(ProjectID NVARCHAR(MAX));            
  DECLARE @XML XML  

 -- --split the dropdown values  
                 
               SELECT @xml = CONVERT(XML,'<AppID>'    
							+ REPLACE(@AppID,',', '</AppID><AppID>') + '</AppID>')  
					   ;WITH Split_AppID  
						AS  
						(  
							 SELECT  
							  x.value( '.', 'NVARCHAR(500)' ) AppID  
							 FROM @xml.nodes('AppID') a(x)       
						)  

			INSERT INTO @cte_AppID SELECT AppID  from Split_AppID      
			SELECT @xml = CONVERT(XML,'<ProjectID>'    
							+ REPLACE(@ProjectID,',', '</ProjectID><ProjectID>') + '</ProjectID>')  
					   ;WITH Split_ProjectID  
						AS  
						(  
							 SELECT  
							  x.value( '.', 'NVARCHAR(500)' ) ProjectID  
							 FROM @xml.nodes('ProjectID') a(x)       
						)  

			INSERT INTO @cte_Project SELECT ProjectID  from Split_ProjectID  
--CREATE TABLE #Debt_Heal_ProjectPatternMapping(
--	[ProjectPatternMapID] bigint NULL,
--	[ProjectID] bigint NOT NULL,
--	[ApplicationID] bigint NOT NULL,
--	[ResolutionCode] int NULL,
--	[CauseCode] int NULL,
--	[DebtClassificationID] int NULL,
--    [AvoidableFlag] int NULL,
--    [TicketType] CHAR(1) NULL,
--	--[HealPattern] NVARCHAR NULL,
--	[PatternFrequency] [int] NULL,
--	[PatternStatus] [int] NULL,
--	[CreatedBy] VARCHAR NULL,
--	[CreatedDate] DATETIME NULL,
--	[ModifiedBy] VARCHAR NULL,
--	[ModifiedDate] DATETIME NULL,
--	[IsDeleted] bit NULL,
--	[IsManual] CHAR(1) NULL
--	)
	--drop table  #Debt_Heal_ProjectPatternMappingTemp
	--drop table  #Temp1
	--drop table  #TicketMaster1
	--------INSERT 


	Select 
	  ProjectPatternMapID,
	  ProjectID,
	   ApplicationID=xDim.value('/x[1]','int'), --could change to desired datatype (int ?)
	   ResolutionCode = xDim.value('/x[2]','int'),
	   CauseCode= xDim.value('/x[3]','int'),
	   DebtClassificationID = xDim.value('/x[4]','int'),
	   AvoidableFlag = xDim.value('/x[5]','int'),
       --A.TicketType, 
	  --A.HealPattern,
      A.PatternFrequency,
      A.PatternStatus,
	  A.CreatedBy,
	  A.CreatedDate,
	  A.ModifiedBy,
	  A.ModifiedDate,
      A.IsDeleted,
      A.IsManual
	INTO #Debt_Heal_ProjectPatternMappingTemp
 From  (Select ProjectPatternMapID AS ProjectPatternMapID,ProjectID AS ProjectID,
 Cast('<x>' + replace(HealPattern,'-','</x><x>')+'</x>' as xml) as xDim
 ,PatternFrequency,PatternStatus,CreatedBy,CreatedDate,ModifiedBy,
 ModifiedDate,IsDeleted,IsManual

 FROM [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) WHERE ProjectID=@ProjectID AND ISNULL(ManualNonDebt,0) != 1
 ) as A
 
  SELECT * INTO #TicketMaster1 FROM  [AVL].[TK_TRN_TicketDetail] TD WHERE ProjectID=@ProjectID
 
 
 
 --select * from #Temp1

 --drop table #Temp1
 	
 SELECT DHTD.HealingTicketID,AD.ApplicationID,
   AD.ApplicationName,
		--AGM.AppGroupID,   
		
		   CASE 
			   WHEN DHTD.Assignee IS NULL AND DHTD.IsMappedToProblemTicket = 1
				THEN 'Mapped to problem ticket'
			   WHEN DHTD.Assignee IS NULL AND DHTD.IsMappedToProblemTicket = 0
				 THEN ''
			  
			   ELSE 
				 
					(SELECT LM.EmployeeID+'-'+ LM.EmployeeName FROM [AVL].[MAS_LoginMaster] 
					(NOLOCK) LM  WHERE UserID=DHTD.Assignee
						AND DHPPM.ProjectID=LM.ProjectID AND LM.ProjectID=@ProjectID)
		    END AS Assignee,
		     DRC.ResolutionCodeName AS ResolutionCode,
		   MCC.CauseCodeName AS CauseCode,
		   DHPPM.AvoidableFlag,
		   MDC.DebtClassificationName AS DebtClassificationName,
		    MDC.DebtClassificationID,
		   DHTD.DARTStatusID,
		   
		 CASE WHEN DHTD.Assignee IS NULL AND DHTD.IsMappedToProblemTicket = 0
		 THEN 'Not Assigned' 
		 ELSE (SELECT DARTStatusName FROM [AVL].[TK_MAS_DARTTicketStatus] DTS 
		 WHERE DTS.DARTStatusID=DHTD.DARTStatusID ) 
		END AS [Status] ,
		MAF.AvoidableFlagname AS AvoidableFlagname,
		DHPPM.PatternFrequency,
		DHTD.ReleasePlanning,
		TM.EffortTillDate as EffortTillDate,
		0 AS ProjectID,	
	    DHTD.IsMappedToProblemTicket,
		DHTD.PlannedEffort,
		DHTD.PlannedStartDate,
		DHTD.PlannedEndDate,
		DHTD.HealTypeId,
		HEALM.HealTypeValue,
		DHTD.PriorityID,
		PRIORI.PriorityName

		--
		--select * from [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic]
		--select * from [AVL].[DEBT_TRN_HealTicketDetails]
		--select * from [AVL].[TK_MAS_DARTTicketStatus]
		--
		--select * from [AVL].[DEBT_MAS_DebtClassification]
		--select * from #Debt_Heal_ProjectPatternMappingTemp
		--select * from [AVL].[DEBT_TRN_HealTicketDetails]
		--select * from [AVL].[DEBT_MAS_CauseCode]
		--select * from [AVL].[DEBT_MAS_AvoidableFlag] 
		--select * from [AVL].[DEBT_PRJ_HealParentChild] 
		--select * from [AVL].[DEBT_MAP_CauseCode]
		--select * from [AVL].[APP_MAS_ApplicationDetails]
		--
		--select * from [AVL].[MAS_LoginMaster]
		INTO #Temp1
		
    FROM [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) DHTD
	   INNER JOIN #Debt_Heal_ProjectPatternMappingTemp DHPPM 
	   ON DHTD.ProjectPatternMapID=DHPPM.ProjectPatternMapID 
	   AND DHPPM.IsDeleted=0 AND ISNULL(DHTD.ManualNonDebt,0) != 1
	   INNER JOIN [AVL].[APP_MAS_ApplicationDetails] (NOLOCK) AD 
	   ON DHPPM.ApplicationID = AD.ApplicationID                                                
	   INNER JOIN [AVL].[DEBT_MAS_ResolutionCode] (NOLOCK) DRC 
	   ON DHPPM.ResolutionCode = DRC.ResolutionCodeID AND DRC.IsDeleted=0
	   INNER JOIN [AVL].[DEBT_MAS_CauseCode](NOLOCK) MCC  
	   ON DHPPM.CauseCode = MCC.CauseCodeID AND MCC.IsDeleted=0
	   INNER JOIN [AVL].[DEBT_MAS_AvoidableFlag]  (NOLOCK) MAF 
	   ON DHPPM.AvoidableFlag = MAF.AvoidableFlagID AND MAF.IsDeleted=0
	   INNER JOIN [AVL].[DEBT_MAS_DebtClassification] (NOLOCK) MDC 
	   ON DHPPM.DebtClassificationID = MDC.DebtClassificationID AND MDC.IsDeleted=0       
	 
	   INNER JOIN [AVL].[DEBT_PRJ_HealParentChild] (NOLOCK) HPC 
	   ON HPC.HealingTicketID = DHTD.HealingTicketID AND HPC.IsDeleted=0 AND HPC.MapStatus = 'Active'
	   
	   INNER JOIN #TicketMaster1(NOLOCK) TM 
	   ON TM.TicketID = HPC.DARTTicketID AND TM.IsDeleted = 0 AND TM.ProjectID = @ProjectID
	   AND(@ProjectID = '' OR EXISTS (SELECT ProjectID FROM @cte_Project 
	   WHERE ProjectID = DHPPM.ProjectID))
	   AND(@AppID = '' OR  EXISTS (SELECT AppID FROM @cte_AppID WHERE AppID = DHPPM.ApplicationID))
	   LEFT JOIN [AVL].[HealTypeMaster] (NOLOCK) HEALM ON HEALM.ID=DHTD.HealTypeId
	   LEFT JOIN [AVL].[TK_MAP_PriorityMapping] (NOLOCK) PRIORI ON PRIORI.PriorityID=DHTD.PriorityID

	   WHERE  CONVERT(DATE,DHTD.OpenDate) >= ISNULL(CONVERT(DATE,@DateFrom),CONVERT(DATE,DHTD.OpenDate)) AND 
	   CONVERT(DATE,DHTD.OpenDate) <= ISNULL(CONVERT(DATE,@DateTo),CONVERT(DATE,DHTD.OpenDate)) 
	    AND
		 DHTD.IsDeleted=0	  
	   ORDER BY DHPPM.PatternFrequency DESC
	   
	   
	   
	SELECT T.HealingTicketID,
	        T.ApplicationID,
			T.ApplicationName,
			--T.AppGroupID,
			T.Assignee,
			T.ResolutionCode,
			T.CauseCode,
			T.AvoidableFlagName,
			T.DebtClassificationName,
			T.DebtClassificationID,
			T.DARTStatusID,
			T.[Status],
			T.PatternFrequency  AS PatternFrequency,
			T.ReleasePlanning,
			SUM(T.EffortTillDate) AS OverallEffort
			,TM1.EffortTillDate AS ImplementationEffort
			,T.IsMappedToProblemTicket
			,TM1.ActualEnddateTime 
			,TM1.TicketDescription AS TicketDescription
			,4 AS ProjectID
			,'' AS ProblemTicketID,
			T.PlannedEffort,
		    T.PlannedStartDate,
		    T.PlannedEndDate,
			T.HealTypeId,
		    T.HealTypeValue,
		    T.PriorityID,
		    T.PriorityName
			FROM #Temp1 T
			LEFT JOIN #TicketMaster1 (NOLOCK) TM1 ON TM1.TicketID = T.HealingTicketID
			--select * from #Temp1 T
			--select * from #TicketMaster1 
			--drop table #TicketMaster1 


			GROUP BY T.HealingTicketID,
			T.ApplicationID,
			T.ApplicationName,
			--T.AppGroupID,
			T.Assignee,
			T.ResolutionCode,
			T.CauseCode,
			T.AvoidableFlag,
			T.DebtClassificationName,
			T.DebtClassificationID,
			T.DARTStatusID,
			T.[Status],
			T.AvoidableFlagname,
			T.PatternFrequency,
			T.ReleasePlanning,
			--T.EffortTillDate 
			TM1.EffortTillDate 
			,T.IsMappedToProblemTicket
			,TM1.ActualEnddateTime 
			,TM1.TicketDescription 
			--TM1.ProjectID
			,T.PlannedEffort
		    ,T.PlannedStartDate
		    ,T.PlannedEndDate
			,T.HealTypeId
		    ,T.HealTypeValue
		    ,T.PriorityID
		    ,T.PriorityName

 DROP TABLE	#TicketMaster1

  SET NOCOUNT OFF; 
     END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Debt_GetHealTicketSearchDetails]', @ErrorMessage, @AppID,@ProjectID
		
	END CATCH  

END


--select * from [AVL].[TK_TRN_TicketDetail]
