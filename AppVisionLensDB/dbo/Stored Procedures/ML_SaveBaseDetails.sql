/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_SaveBaseDetails] (@ProjectID NVARCHAR(200), 
                                           @MLBaseDetails ML_MLBaseDetails READONLY)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

     declare @InitialLearningID bigint
    set @InitialLearningID=(select top 1 ID from AVL.ML_PRJ_InitialLearningState where ProjectID=@ProjectID and IsDeleted=0 ORDER by ID DESC)

	DELETE A
FROM ML_MLBaseDetails A
WHERE  EXISTS (
        SELECT *
        FROM @MLBaseDetails MD
        WHERE MD.TicketID = A.TicketID and   A.ProjectID=@ProjectID and MD.ApplicationName=A.ApplicationName
        )
	

          INSERT INTO ML_MLBaseDetails(InitialLearningID,
ProjectID,
TicketID,
ApplicationName,
DebtClassification,
AvoidableFlag,
ResidualDebt,
CauseCode,
ResolutionCode,
TicketDescriptionPattern,
TicketDescriptionSubPattern,
OptionalFieldpattern,
OptionalFieldSubPattern,
Isdeleted)
          SELECT @InitialLearningID,
@ProjectID,
TicketID,
ApplicationName,
DebtClassification,
AvoidableFlag,
ResidualDebt,
CauseCode,
ResolutionCode,
TicketDescriptionPattern,
TicketDescriptionSubPattern,
OptionalFieldpattern,
OptionalFieldSubPattern,
0
          FROM   @MLBaseDetails 


          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_MLBaseDetails] ', 
            @ErrorMessage, 
            @ProjectID
      END CATCH 
  END
