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
-- Author      : Ramesh kumar N
-- Create date : 30/12/2019 
-- Description : Procedure to GetUseCaseFilters
-- Revision    :
-- Revised By  :
-- ========================================================================================= 

CREATE  PROCEDURE [AVL].[GetUseCaseFilters]
(
@Flag INT -- Indicates the BU,Account,Technology,SupportLevel
,@TVP_UseCaseFilterID  [dbo].[TVP_UseCaseFilterID] READONLY -- Indicates the BUID/AccID/TechID/SLId
)
AS
BEGIN
BEGIN TRY
		BEGIN TRAN
		SET NOCOUNT ON;		
		--truncate table AVL.FilterID
		--insert into AVL.FilterID
		--select *,getdate() from @TVP_UseCaseFilterID


		--DROP TABLE tempTVP_UseCaseFilterID

		--select *,getdate() AS CurrDate
		--into tempTVP_UseCaseFilterID from @TVP_UseCaseFilterID

		DECLARE @TempList AS TABLE
		(
		id INT IDENTITY(1,1),
		[text] VARCHAR(MAX)
		)
		IF(@Flag = 1) -- For BU
		BEGIN
			INSERT INTO @TempList 
			SELECT DISTINCT BUName AS [text] FROM [AVL].[BusinessUnit] WHERE [IsDeleted] =0 and [IsHorizontal]='N' ORDER BY BUName

			SELECT DISTINCT * FROM @TempList
		END
		IF(@Flag = 2) -- For Account
		BEGIN
			INSERT INTO @TempList
			SELECT DISTINCT AccountName AS [text] 
			FROM [AVL].[Effort_UseCaseDetails] UC 
				INNER JOIN @TVP_UseCaseFilterID TCU ON UC.SBUName = TCU.text 
			WHERE UC.IsDeleted = 0 AND LTRIM(RTRIM(UC.SBUName)) = LTRIM(RTRIM(TCU.text))
			UNION
			SELECT DISTINCT CS.CustomerName AS [text] 
			FROM AVL.UseCaseDetails UC			
			JOIN ESA.BusinessUnits C ON UC.BUID=C.BUID			
			JOIN AVL.Customer CS ON CS.BUID = C.BUID 
			JOIN @TVP_UseCaseFilterID TCU ON C.BUName = TCU.text 
			AND CS.IsDeleted = 0 			
			
			SELECT DISTINCT * FROM @TempList ORDER BY [Text]
		END
		IF(@Flag = 3) -- For Technology
		BEGIN
			INSERT INTO @TempList
			SELECT DISTINCT Technology AS [text] FROM [AVL].[Effort_UseCaseDetails] UC 
			INNER JOIN @TVP_UseCaseFilterID TCU ON UC.AccountName = TCU.text  
			WHERE IsDeleted = 0 AND LTRIM(RTRIM(UC.AccountName)) = LTRIM(RTRIM(TCU.text))
			UNION
			SELECT DISTINCT T.PrimaryTechnologyName AS [text] 
			FROM
			AVL.UseCaseDetails UC
			JOIN AVL.APP_MAS_PrimaryTechnology(NOLOCK) T ON UC.TechnologyID = T.PrimaryTechnologyID AND T.IsDeleted = 0
			JOIN AVL.Customer CS ON CS.CustomerID = UC.CustomerID AND CS.IsDeleted = 0
			INNER JOIN @TVP_UseCaseFilterID TCU ON TCU.text  = CS.CustomerName

			SELECT DISTINCT * FROM @TempList ORDER BY [text]
		END
		IF(@Flag = 4) -- For ServiceLevel
		BEGIN
			INSERT INTO @TempList
			SELECT DISTINCT ServiceLevelName AS [text] FROM [AVL].[MAS_ServiceLevel] WHERE IsDeleted = 0 AND ServiceLevelID NOT IN(6) ORDER BY ServiceLevelName

			SELECT * FROM @TempList
		END		
		COMMIT TRAN
END TRY
BEGIN CATCH	

		SELECT ERROR_MESSAGE() AS Result

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO AVL.Errors VALUES(0,'AVL.GetUseCaseFilters',@ErrorMessage,'system',GETDATE())

		ROLLBACK TRAN	
		              
END CATCH

END
