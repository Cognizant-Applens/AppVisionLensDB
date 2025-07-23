/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Debt_SaveAutoClassifiedDebtFields_Upload]
@PROJECTID INT,  
@CogID VARCHAR(50),
@lstTicketsCollection TVP_TicketDetails READONLY,
@IsAutoClassified VARCHAR(2), 
@IsDDAutoClassified VARCHAR(2) 

AS  
BEGIN  
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;  

CREATE TABLE #TempDebtClassifiedTable
(
ID INT IDENTITY(1,1),
TicketID VARCHAR(MAX) NULL,
TicketDescription VARCHAR(MAX) NULL,
ApplicationID VARCHAR(MAX) NULL,
ApplicationName VARCHAR(MAX) NULL,
DebtClassificationID INT NULL,
AvoidableFlagID INT NULL,
ResidualFlagID INT NULL,
ResolutionCodeID INT NULL,
CauseCodeID INT NULL
)

INSERT INTO #TempDebtClassifiedTable(TicketID,TicketDescription,ApplicationName,ApplicationID)
SELECT TicketID,TicketDescription,ApplicationName AS ApplicationName,
ApplicationID AS ApplicationID 
FROM @lstTicketsCollection

--Select STM.CauseCodeID, STM.ResolutionID from PRJ.SSISImportTicketMaster STM Inner join 
--#TempDebtClassifiedTable DCT on STM.TicketID = DCT.TicketID and STM.ProjectID = @PROJECTID

SELECT A.* INTO #AppInfo  FROM  (
Select  ApplicationID, ApplicationName from AVL.APP_MAS_ApplicationDetails where ApplicationID in 
(Select ApplicationID from AVL.APP_MAP_ApplicationProjectMapping where ProjectID = @projectid))AS A   


UPDATE TD SET TD.ApplicationID=AI.ApplicationID
FROM  #TempDebtClassifiedTable TD
INNER JOIN #AppInfo AI
ON TD.ApplicationName=AI.ApplicationName

DECLARE @MinID INT
DECLARE @MaxID INT
SET @MinID=(SELECT MIN(ID) FROM #TempDebtClassifiedTable)
SET @MaxID=(SELECT MAX(ID) FROM #TempDebtClassifiedTable)
WHILE @MinID <= @MaxID
	BEGIN
		DECLARE @ApplicationID INT
		DECLARE @TicketID VARCHAR(MAX)
		DECLARE @ApplicationName VARCHAR(MAX)
		DECLARE @TicketDescription VARCHAR(MAX)
		SET @TicketID=(SELECT TicketID FROM #TempDebtClassifiedTable WHERE ID=@MinID)
		SET @ApplicationID=(SELECT ApplicationID FROM #TempDebtClassifiedTable WHERE ID=@MinID)
		SET @TicketDescription=(SELECT TicketDescription FROM #TempDebtClassifiedTable WHERE ID=@MinID)
		SET @ApplicationName=(SELECT ApplicationName FROM #TempDebtClassifiedTable WHERE ID=@MinID)
		
		EXEC dbo.[Debt_GetAutoClassifiedDebtFildsBulk] @TicketID,@CogID,@PROJECTID,@ApplicationID,@TicketDescription, @IsAutoClassified ,@IsDDAutoClassified ;
		
		SET @MinID=@MinID+1

	END
--End

Select ProjectID, EmployeeID, [Ticket ID] ,[Debt Classification] as DebtClassification,[Avoidable Flag] as AvoidableFlag ,[Residual Debt] as ResidualDebt,Reviewer, 
TicketLocation into #Tmp_debtUpdate  
from [AVL].[TK_ImportTicketDumpDetails] where ProjectID = ProjectID and EmployeeID = @COGID

		UPDATE TDU
		SET TDU.DebtClassification = DCM.DebtClassificationName
		FROM  #Tmp_debtUpdate TDU INNER JOIN AVL.[TempDebtFieldsBulkUpload] GK ON GK.TicketID = TDU.[Ticket ID]
		INNER JOIN AVL.DEBT_MAS_DebtClassification DCM ON DCM.DebtClassificationID = GK.DebtClassificationID
		WHERE TDU.ProjectID= @PROJECTID 

		UPDATE TDU
		SET TDU.AvoidableFlag=AFM.AvoidableFlagName
		FROM  #Tmp_debtUpdate TDU INNER JOIN AVL.[TempDebtFieldsBulkUpload] GK ON GK.TicketID = TDU.[Ticket ID]
		INNER JOIN AVL.DEBT_MAS_AvoidableFlag AFM ON AFM.AvoidableFlagID = GK.AvoidableFlagID 
		WHERE TDU.ProjectID=@PROJECTID 

		UPDATE TDU
		SET TDU.ResidualDebt=RDM.ResidualDebtName
		FROM  #Tmp_debtUpdate TDU INNER JOIN AVL.[TempDebtFieldsBulkUpload] GK ON GK.TicketID = TDU.[Ticket ID]
		INNER JOIN AVL.DEBT_MAS_ResidualDebt RDM ON RDM.ResidualDebtID = gk.ResidualFlagID
		WHERE TDU.ProjectID= @PROJECTID 

		UPDATE TDU
		SET TDU.Reviewer= MRC.ResolutionCode
		FROM  #Tmp_debtUpdate TDU INNER JOIN AVL.[TempDebtFieldsBulkUpload] GK ON GK.TicketID = TDU.[Ticket ID]
		INNER JOIN AVL.DEBT_MAP_ResolutionCode MRC
		ON MRC.ResolutionID = gk.ResolutionCodeID
		WHERE TDU.ProjectID=  @PROJECTID and MRC.ProjectID = TDU.ProjectID

	    UPDATE TDU
		SET TDU.TicketLocation= MCC.CauseCode
		FROM  #Tmp_debtUpdate TDU INNER JOIN AVL.[TempDebtFieldsBulkUpload] GK ON GK.TicketID = TDU.[Ticket ID]
		INNER JOIN AVL.DEBT_MAP_CauseCode MCC
		ON MCC.CauseID = gk.CauseCodeID
		WHERE TDU.ProjectID=  @PROJECTID and MCC.ProjectID = TDU.ProjectID


UPDATE SSIM 
SET SSIM.[Debt Classification] = TDU.DebtClassification , SSIM.[Avoidable Flag] = TDU.AvoidableFlag , SSIM.[Residual Debt] = TDU. ResidualDebt
FROM  [AVL].[TK_ImportTicketDumpDetails]  SSIM INNER JOIN #Tmp_debtUpdate TDU  ON
SSIM.[Ticket ID] = TDU. [Ticket ID] where SSIM.[Debt Classification] is null and SSIM.[Avoidable Flag] is null and SSIM.[Residual Debt] is NULL
		
SELECT * FROM [AVL].[TK_ImportTicketDumpDetails] WHERE PROJECTID=@PROJECTID AND EmployeeID=@CogID

SELECT * FROM AVL.[TempDebtFieldsBulkUpload] WHERE PROJECTID=@PROJECTID AND CogID=@CogID

SET NOCOUNT OFF;  
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'dbo.Debt_SaveAutoClassifiedDebtFields_Upload', @ErrorMessage, @CogID ,0
		
	END CATCH  
END
