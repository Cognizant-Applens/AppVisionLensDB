CREATE PROCEDURE [AVL].[ReMap_GetHealAplicationDetails]
(
@ProjectID VARCHAR(200)
)
AS 
BEGIN
BEGIN TRY
		
	CREATE TABLE #Heal_ProjectPatternMapping(
	[ProjectPatternMapID] [int] NULL,
	[ProjectID] [int] NOT NULL,
	[ApplicationID] [int] NOT NULL,
	
	[ResolutionCode] [varchar](50) NULL,
	[CauseCode] [varchar](50) NULL,
	[DebtClassificationId] [int] NULL,
	[AvoidableFlag] [int] NULL,
	[ServiceID] INT NULL,
	[NatureOfTheTicket] INT NULL,
	[TechnologyId] BIGINT NULL,
	[KEDBPath] VARCHAR(1000) NULL,
	[TicketType] [char](1) NULL,
	[PatternFrequency] [int] NULL,
	[PatternStatus] [int] NULL,
	[IsDeleted] [char](1) NULL,
	[IsManual] [char](1) NULL
	)	
	INSERT INTO #Heal_ProjectPatternMapping
	Select ProjectPatternMapID,ProjectID,
	ApplicationID = xDim.value('/x[1]','varchar(max)') --could change to desired datatype (int ?)
      , ResolutionCode = xDim.value('/x[2]','varchar(max)') 
      ,CauseCode= xDim.value('/x[3]','varchar(max)')
      ,DebtClassificationId = xDim.value('/x[4]','varchar(max)')
      ,AvoidableFlag = xDim.value('/x[5]','varchar(max)')
      ,ServiceID = xDim.value('/x[6]','varchar(max)')
      ,NatureOfTheTicket = xDim.value('/x[7]','varchar(max)')
      ,TechnologyId = xDim.value('/x[8]','varchar(max)')
      ,KEDBPath = xDim.value('/x[9]','varchar(max)')
      ,A.TicketType
      ,A.PatternFrequency
      ,A.PatternStatus,
      A.IsDeleted
      ,A.IsManual
		 From  (Select ProjectPatternMapID AS ProjectPatternMapID,ProjectID AS ProjectID,Cast('<x>' + replace(HealPattern,'-','</x><x>')+'</x>' as xml) as xDim,
		 TicketType AS TicketType,PatternFrequency,PatternStatus,IsManual,IsDeleted
		 FROM [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] WHERE ProjectID=@ProjectID AND  ISNULL(ManualNonDebt,0) != 1 
		 ) as A 	
 	
	   SELECT DISTINCT HTD.ApplicationID,AM.ApplicationName 
      FROM [AVL].[DEBT_TRN_HealTicketDetails] HTD 
	   INNER JOIN #Heal_ProjectPatternMapping HPPM ON HTD.ProjectPatternMapID = HPPM.ProjectPatternMapID 
	   INNER JOIN  [AVL].[APP_MAS_ApplicationDetails] AM	ON HPPM.ApplicationID = AM.ApplicationID AND AM.IsActive=1
	
	    AND HPPM.IsDeleted = 0 
     WHERE  ISNULL(HTD.ManualNonDebt,0) != 1 

	DROP TABLE #Heal_ProjectPatternMapping

	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[ReMap_GetHealAplicationDetails] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



END