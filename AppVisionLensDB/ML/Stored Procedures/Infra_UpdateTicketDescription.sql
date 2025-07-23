/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================= 
-- Author:    458788 
-- Create date: 16-Jul-2020
-- Description:   SP for Initial Learning 
-- [ML].[Infra_UpdateTicketDescription] '441778', 10569 ,'10/22/2018','1/21/2019','627384' 
-- =============================================  

CREATE PROCEDURE [ML].[Infra_UpdateTicketDescription]
(
@UserID NVARCHAR(10)= null,
@ProjectID BIGINT,
@lstDescriptiondetails  ML.UpdateTicketDescription READONLY
)
AS 
BEGIN
BEGIN TRY
BEGIN TRAN
	
	DECLARE @IsDeleted INT = 0 ,
			@Result BIT = 0,
			@InintialLearnId bigint = 0;
	
	CREATE TABLE #DescriptionValues
	(	
		[ProjectID] BIGINT,	
		[InintialLearnId] BIGINT,	
		[TicketID] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[TicketDescription] [varchar](max) NULL
	)

	SET @InintialLearnId = (SELECT TOP 1 ID FROM ML.InfraConfigurationProgress WHERE ProjectID = @ProjectID AND IsDeleted = @IsDeleted ORDER BY ID DESC)
	INSERT INTO #DescriptionValues
	SELECT 
		@ProjectID,	
		@InintialLearnId,
		TicketID,
		TicketDescription
	From @lstDescriptiondetails
	
	
	UPDATE TV SET TV.DescriptionText = DV.TicketDescription,
	   TV.ModifiedBy = @UserID,
	   TV.ModifiedDate = GETDATE()
	FROM ML.InfraTicketValidation TV
	JOIN #DescriptionValues(NOLOCK) DV
		ON DV.ProjectID = TV.ProjectID		
		AND DV.InintialLearnId = TV.InitialLearningID
		AND DV.TicketID = TV.TicketID
		AND TV.IsDeleted = @IsDeleted

	 SET @Result = 1
	SELECT @Result AS Result

	
	

COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[ML].[Infra_UpdateTicketDescription]', @ErrorMessage, '',0
		
	END CATCH  

END
