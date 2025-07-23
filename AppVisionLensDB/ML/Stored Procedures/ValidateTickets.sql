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
-- Author      : Shobana
-- Create date : 3 Dec 2019
-- Description : Procedure to Validate Ticket               
-- Test        : [ML].[ValidateTickets] 105188,'2019-01-01','2019-12-12','471742' 
-- Revision    :
-- Revised By  :
-- =========================================================================================

CREATE PROCEDURE [ML].[ValidateTickets]
		@ID BIGINT, --ProjectID
		@FromDate  DATE, 
		@ToDate   DATE, 
		@UserID    NVARCHAR(10)
AS 
  BEGIN 
      BEGIN TRY 
	     BEGIN TRAN
        SET NOCOUNT ON; 
		DECLARE @CustomerID BIGINT;
		DECLARE @IsCognizant INT;
		SET @CustomerID =(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ID AND ISNULL(IsDeleted,0)=0)
		SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) FROM AVL.Customer(NOLOCK)  WHERE CustomerID=@CustomerID)
      

---------------------------------------------------------------------------------------

		 CREATE TABLE #ML_TRN_TicketValidation(
			[ProjectID] [bigint] NOT NULL,
			[TicketID] [nvarchar](50) NULL,
			[TicketDescription] [nvarchar](max) NULL,
			[ApplicationID] [bigint] NULL,
			[ESAProjectID] [bigint] NULL,
			[DebtClassificationID] [int] NULL,
			[AvoidableFlagID] [int] NULL,
			[ResidualDebtID] [int] NULL,
			[CauseCodeID] [bigint] NULL,
			[ResolutionCodeID] [bigint] NULL,
			[CreatedBy] [nvarchar](50) NULL,
			[CreatedDate] DATETIME NULL,
			[IsDeleted] BIT NULL,
			[OptionalFieldProj] [nvarchar](max) NULL,
			TicketTypeID BIGINT NULL,
			ServiceID INT NULL,
			ID BIGINT NULL
			)

		    INSERT INTO  #ML_TRN_TicketValidation
            SELECT TD.ProjectID,TD.TicketID, 
              TD.TicketDescription AS TicketDescription, 
              ApplicationID, 
			  PM.EsaProjectID,
              [DebtClassificationMapID] AS DebtClassificationID, 
              AvoidableFlag             AS [AvoidableFlagID], 
              [ResidualDebtMapID]       AS [ResidualDebtID], 
              [CauseCodeMapID]          AS CauseCodeID, 
              [ResolutionCodeMapID]     AS ResolutionCodeID, 
			  @UserID, 
              Getdate(), 
              0,
              TD.ResolutionRemarks AS OptionalFieldProj,
	          TD.TicketTypeMapID,TD.ServiceID ,IL.ID
              FROM   [AVL].[TK_TRN_TICKETDETAIL] TD(NOLOCK) 
			  JOIN ML.ConfigurationProgress(NOLOCK) IL
			  ON IL.ProjectID = TD.ProjectID AND IL.IsDeleted = 0 AND  TD.IsDeleted =  0
			  JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID = TD.ProjectID 
              WHERE  TD.ProjectID = @ID
              AND ((DARTStatusID = 8 AND ClosedDate BETWEEN @FromDate AND @ToDate) OR
			  (DARTStatusID = 9 AND CompletedDateTime BETWEEN @FromDate AND @ToDate))
					
			  IF @IsCognizant = 1
			  BEGIN
			  	DELETE  FROM #ML_TRN_TicketValidation
			  	WHERE ServiceID NOT IN (1,4,5,6,7,8,10) 
			  END
			  ELSE
			  BEGIN
			  	DELETE TV  FROM #ML_TRN_TicketValidation TV
			  	INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM
			  	ON TV.TicketTypeID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'
			  END	
			  
	 MERGE ML.TicketValidation  as ILC
	 USING  #ML_TRN_TicketValidation AS ILCC
	 ON ILCC.ProjectId = ILC.ProjectId AND ILC.TicketId = ILCC.TicketID
	 
		WHEN MATCHED THEN 
	    UPDATE 
		SET
		ILC.TicketDescription = ILCC.TicketDescription,
		ILC.ApplicationID = ILCC.ApplicationID,
		ILC.DebtClassificationID = ILCC.DebtClassificationID,
		ILC.AvoidableFlagID = ILCC.AvoidableFlagID,
		ILC.ResidualDebtID = ILCC.ResidualDebtID,
		ILC.CauseCodeID = ILCC.CauseCodeID,
        ILC.ResolutionCodeID = ILCC.ResolutionCodeID,
		ILC.CreatedBy = ILCC.CreatedBy,
		ILC.CreatedDate = ILCC.CreatedDate,
	    ILC.IsDeleted = ILCC.IsDeleted,
		ILC.OptionalField = ILCC.OptionalFieldProj,
		ILC.ModifiedBy = @UserId,
		ILC.ModifiedDate = GetDate()

		WHEN NOT MATCHED BY TARGET THEN
			  
              INSERT 
                    (ProjectID, 
                     TicketID, 
                     TicketDescription, 
                     ApplicationID, 
                     DebtClassificationID, 
                     AvoidableFlagID, 
                     ResidualDebtID, 
                     CauseCodeID, 
                     ResolutionCodeID, 
                     CreatedBy, 
                     CreatedDate,
					 ModifiedBy,
					 ModifiedDate,
                     IsDeleted, 
                     OptionalField) 
              VALUES (ILCC.ProjectID, 
                     ILCC.TicketID, 
                     ILCC.TicketDescription, 
                     ILCC.ApplicationID, 
                     ILCC.DebtClassificationID, 
                     ILCC.AvoidableFlagID, 
                     ILCC.[ResidualDebtID], 
                     ILCC.CauseCodeID, 
                     ILCC.ResolutionCodeID, 
                     @UserId, 
                     Getdate(), 
					 NULL,
					 NULL,
                     0,
					 ILCC.OptionalFieldProj);

		      SELECT 
			          ID,
                      TD.TicketID, 
					  TD.ESAProjectID,
                      TicketDescription as TicketDecryptedDescription,  
                      OptionalFieldProj AS ResolutionRemarks
                      FROM   #ML_TRN_TicketValidation TD
		COMMIT TRAN
    END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

		  ROLLBACK TRAN

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[ML].[ValidateTickets]', 
            @ErrorMessage, 
            @ID, 
            0 
      END CATCH 
  END
