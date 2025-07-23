-- =============================================
-- Author:		587567
-- Create date: 03-02-2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [BOT].[GetBOTFilters]
	@Flag INT,
	@ID INT
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @Flag = 1 --TargetApplication
	BEGIN
	SELECT Id ID,TargetApplicationName [Name] FROM BOT.TargetApplication where IsDeleted=0 order by TargetApplicationName asc
	END
	IF @Flag = 2 --Technology
	BEGIN
	SELECT PrimaryTechnologyID ID,PrimaryTechnologyName [Name]  FROM avl.APP_MAS_PrimaryTechnology where IsDeleted=0 order by PrimaryTechnologyName asc 
	END
	IF @Flag = 3 --Category
	BEGIN
	SELECT Id ID,CategoryName [Name]  FROM BOT.Category where IsDeleted=0 order by CategoryName asc
	END
	IF @Flag = 4 --Nature
	BEGIN
	SELECT Id ID,Nature [Name]  FROM BOT.Nature where IsDeleted=0 order by Nature asc
	END
	IF @Flag = 5 --BOTType
	BEGIN
	SELECT Id ID ,Type [Name]  FROM BOT.BOTType where IsDeleted=0 order by Type asc
	END
	IF @Flag = 6 --Reusability
	BEGIN
	SELECT Id ID,Reusability [Name]   FROM BOT.Reusability where IsDeleted=0
	END
	IF @Flag = 7 -- Buisness PRocess
		BEGIN
			SELECT DISTINCT
				BPM.BusinessProcessId AS ID,
				BPM.BusinessProcessName AS [Name]
			FROM 
				BusinessOutCome.[MAP].[BUServiceTracks] BST
				JOIN BusinessOutCome.[MAS].[LOBMaster] LM ON BST.ServiceTrackID = LM.ServiceTrackID
				JOIN BusinessOutCome.MAS.BusinessProcessMaster BPM ON BPM.LobId = LM.LOBId
			WHERE LM.IsActive = 1 AND BPM.IsActive = 1 AND BPM.BusinessProcessParentId IS NULL
			
			and LM.IsDecommisioned = 0
			ORDER BY BPM.BusinessProcessName
		END
	IF @Flag = 8 -- SUB Buisness PRocess
		BEGIN
		--@Id --BUISNESSPROCESSID
			SELECT DISTINCT
                    MP.BusinessProcessId AS ID,
                    MP.BusinessProcessName AS [Name]
            FROM 
                    BusinessOutCome.[MAP].[BUServiceTracks] BST
                    JOIN BusinessOutCome.[MAS].[LOBMaster] LM ON BST.ServiceTrackID = LM.ServiceTrackID
                    JOIN BusinessOutCome.MAS.BusinessProcessMaster BPM ON BPM.LobId = LM.LOBId
                   LEFT JOIN BusinessOutCome.mas.BusinessProcessMaster MP ON mp.BusinessProcessParentId = bpm.BusinessProcessId                        
            WHERE LM.IsActive = 1 AND BPM.IsActive = 1 and mp.IsActive = 1
                    AND MP.BusinessProcessParentId = @ID   
            ORDER BY MP.BusinessProcessName

		END
	IF @Flag = 9 --Reusability
		BEGIN
			SELECT ServiceID AS ID,
			ServiceName AS [Name]
			FROM avl.TK_MAS_Service WHERE IsDeleted=0 AND ServiceID in (7,1,38,5,6,2,8,11,10,3,15,13,14) ORDER BY ServiceName ASC	
		END

	IF @Flag = 10 --Automation Technology
		BEGIN
			SELECT ID AS ID,
			AutomationTechnology AS [Name]
			FROM [BOTAutomationTechnology] WHERE IsDeleted=0 ORDER BY [AutomationTechnology] ASC
		END
	IF @Flag = 11 --Domain
		BEGIN
			SELECT Id AS ID,
			[Domain] AS [Name]
			FROM [BOT].[Domain] WHERE IsDeleted=0 ORDER BY [Domain] ASC
		END

		IF @Flag = 12 --ProblemType
		BEGIN
			SELECT Id AS ID,
			ProblemType AS [Name]
			FROM [BOT].ProblemType WHERE IsDeleted=0 ORDER BY ProblemType ASC
		END
		IF @Flag = 13 --ActionType
		BEGIN
			SELECT Id AS ID,
			ActionType AS [Name]
			FROM [BOT].ActionType WHERE IsDeleted=0 ORDER BY ActionType ASC
		END
		IF @Flag = 14 --ExecutionSubType
		BEGIN
			SELECT Id AS ID,
			ExecutionSubType AS [Name]
			FROM [BOT].ExecutionSubType WHERE IsDeleted=0 ORDER BY ExecutionSubType ASC	
		END

END
