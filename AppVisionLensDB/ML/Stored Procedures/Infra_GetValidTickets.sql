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
-- Test        : [ML].[Infra_GetValidTickets] 10337,'2020-02-16','2020-03-19','683989',1 
-- Revision    :
-- Revised By  :
-- =========================================================================================
CREATE PROCEDURE [ML].[Infra_GetValidTickets]
		@ID BIGINT, --ProjectID
		@FromDate  DATE, 
		@ToDate   DATE, 
		@UserID    NVARCHAR(10),
		@IsRegenerate BIT
AS 
  BEGIN 
      BEGIN TRY 
	     BEGIN TRAN
        SET NOCOUNT ON; 
		DECLARE @CustomerID BIGINT;
		DECLARE @IsCognizant INT;		
		DECLARE @InitialID INT;
		SET @CustomerID =(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ID AND ISNULL(IsDeleted,0)=0)
		SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) FROM AVL.Customer(NOLOCK)  WHERE CustomerID=@CustomerID)	
      
	  
		
		SET @InitialID = (CASE 
										WHEN @IsRegenerate = 0 THEN ( SELECT TOP 1 ID FROM   ML.InfraConfigurationProgress
																		WHERE  projectid = @ID 
																		AND IsDeleted = 0 ORDER  BY ID ASC )
										ELSE ( SELECT Max(ID) FROM   ML.InfraConfigurationProgress 
																		WHERE  projectid = @ID AND IsDeleted = 0 
																		AND ISNULL(IsMLSentOrReceived,'') <>'Received' )
										END
										)

---------------------------------------------------------------------------------------

		 CREATE TABLE #ML_TRN_TicketValidation(
			[ProjectID] [bigint] NOT NULL,
			[TicketID] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			[TicketDescription] [nvarchar](max) NULL,
			[TowerID] [bigint] NULL,
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
			ID BIGINT NULL,
			InitialLearningID BIGINT NULL
			)

			IF(@IsRegenerate = 0)
			BEGIN
		    INSERT INTO  #ML_TRN_TicketValidation
            SELECT DISTINCT TD.ProjectID,TD.TicketID, 
              TD.TicketDescription AS TicketDescription, 
              TD.TowerID, 
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
	          TD.TicketTypeMapID,TD.ServiceID ,IL.ID,@InitialID
              FROM   AVL.TK_TRN_InfraTicketDetail TD(NOLOCK) 
			  JOIN ML.InfraConfigurationProgress(NOLOCK) IL			  
			  ON IL.ProjectID = TD.ProjectID AND IL.IsDeleted = 0 AND  TD.IsDeleted =  0
			  JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID = TD.ProjectID 
			  --JOIN AVL.APP_MAS_ApplicationDetails AD ON TD.ApplicationID = AD.ApplicationID AND AD.IsActive = 1
			  LEFT JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) AMR
			ON TD.TowerID = AMR.InfraTowerTransactionID
		INNER JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
			ON IHT.CustomerID=AMR.CustomerID
			AND IHT.InfraTransMappingID=AMR.InfraTransMappingID
			AND ISNULL(IHT.IsDeleted,0)=0  
		INNER JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT
			ON IHT.CustomerID=IOT.CustomerID 
			AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID 
			AND IOT.IsDeleted=0
		INNER JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT 
			ON IHT.CustomerID=ITT.CustomerID 
			AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID 
			AND ITT.IsDeleted=0 
		INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM  
			ON AMR.InfraTowerTransactionID=IPM.TowerID
              WHERE  TD.ProjectID = @ID
              AND ((DARTStatusID = 8 AND ClosedDate BETWEEN @FromDate AND @ToDate) OR
			  (DARTStatusID = 9 AND CompletedDateTime BETWEEN @FromDate AND @ToDate))
			  AND IL.ID = @InitialID
			  END
			  ELSE IF (@IsRegenerate=1)
			  BEGIN

			  INSERT INTO  #ML_TRN_TicketValidation
			  SELECT DISTINCT TD.ProjectID,TD.TicketID, 
              TD.TicketDescription AS TicketDescription, 
              TD.TowerID, 
			  PM.EsaProjectID,
              [DebtClassificationMapID] AS DebtClassificationID, 
              AvoidableFlag             AS [AvoidableFlagID], 
   [ResidualDebtMapID]       AS [ResidualDebtID], 
			  [CauseCodeMapID]         AS CauseCodeID, 
              [ResolutionCodeMapID]     AS ResolutionCodeID, 
			  @UserID, 
              Getdate(), 
              0,
              TD.ResolutionRemarks AS OptionalFieldProj,
	          TD.TicketTypeMapID,TD.ServiceID ,IL.ID,@InitialID
              FROM   AVL.TK_TRN_InfraTicketDetail TD(NOLOCK) 			  
			  JOIN ML.InfraConfigurationProgress(NOLOCK) IL
			  ON IL.ProjectID = TD.ProjectID AND IL.IsDeleted = 0 AND  TD.IsDeleted =  0
			  JOIN AVL.MAS_ProjectMaster PM ON PM.ProjectID = TD.ProjectID 
			  --JOIN AVL.APP_MAS_ApplicationDetails AD ON TD.ApplicationID = AD.ApplicationID AND AD.IsActive = 1
			  LEFT JOIN AVL.InfraTowerDetailsTransaction(NOLOCK) AMR
			ON TD.TowerID = AMR.InfraTowerTransactionID
		INNER JOIN AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
			ON IHT.CustomerID=AMR.CustomerID
			AND IHT.InfraTransMappingID=AMR.InfraTransMappingID
			AND ISNULL(IHT.IsDeleted,0)=0  
		INNER JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT
			ON IHT.CustomerID=IOT.CustomerID 
			AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID 
			AND IOT.IsDeleted=0
		INNER JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT 
			ON IHT.CustomerID=ITT.CustomerID 
			AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID 
			AND ITT.IsDeleted=0 
		INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) IPM  
			ON AMR.InfraTowerTransactionID=IPM.TowerID
              WHERE  TD.ProjectID = @ID
              AND ((DARTStatusID = 8 AND ClosedDate BETWEEN @FromDate AND @ToDate) OR
			  (DARTStatusID = 9 AND CompletedDateTime BETWEEN @FromDate AND @ToDate))
			  AND DebtClassificationMode IS NULL
			  AND IL.ID = @InitialID			  
			END
			

			  IF @IsCognizant = 0
			  --BEGIN
			  --	--DELETE  FROM #ML_TRN_TicketValidation
			  --	--WHERE ServiceID NOT IN (1,4,5,6,7,8,10) 
			  --END
			  --ELSE
			  BEGIN
			  	DELETE TV  FROM #ML_TRN_TicketValidation TV
			  	INNER JOIN AVL.TK_MAP_TicketTypeMapping TVM
			  	ON TV.TicketTypeID=TVM.TicketTypeMappingID AND TVM.DebtConsidered ! ='Y'
			  END	
			  
	 MERGE ML.InfraTicketValidation  as ILC
	 USING  #ML_TRN_TicketValidation AS ILCC
	 ON ILCC.ProjectId = ILC.ProjectId AND ILC.TicketId = ILCC.TicketID
	 AND ILC.InitialLearningID=ILCC.InitialLearningID
	 
	 
		WHEN MATCHED THEN 
	    UPDATE 
		SET
		ILC.TicketDescription = ILCC.TicketDescription,
		ILC.TowerID = ILCC.TowerID,
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
                     TowerID, 
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
                     OptionalField,
					 TicketSourceFrom,
					 InitialLearningID) 
            VALUES (ILCC.ProjectID, 
                     ILCC.TicketID, 
                     ILCC.TicketDescription, 
                     ILCC.TowerID, 
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
					 ILCC.OptionalFieldProj,
					 'ML',
					 @InitialID);

		     SELECT 'True' as Result
		COMMIT TRAN
    END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

		  ROLLBACK TRAN

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[ML].[Infra_GetValidTickets]', 
            @ErrorMessage, 
            @ID, 
            0 
      END CATCH 
  END
