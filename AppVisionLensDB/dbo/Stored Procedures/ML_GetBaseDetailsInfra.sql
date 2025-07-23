/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_GetBaseDetailsInfra] (@ProjectID bigint)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

     declare @InitialLearningID bigint
	 declare @IsRegenerate bit
	 DECLARE @CustomerID BIGINT

	 declare @IsMLSignOff BIT

    select top 1 @InitialLearningID=ID,@IsRegenerate=isnull(IsRegenerated,0) from AVL.ML_PRJ_InitialLearningStateInfra where ProjectID=@ProjectID and IsDeleted=0 ORDER by ID DESC
	SELECT @CustomerID=CustomerID FROM AVL.MAS_ProjectMaster WHERE ProjectID=@ProjectID AND IsDeleted=0

	IF(@IsRegenerate=1)
	BEGIN

set  @IsMLSignOff=	(SELECT top 1 IsMLSignOff from AVL.ML_TRN_RegeneratedTowerDetails where ProjectID=@ProjectID and IsDeleted=0 and InitialLearningID=@InitialLearningID )


	END
	ELSE
	BEGIN
	SELECT @IsMLSignOff=IsMLSignOffInfra from AVL.MAS_ProjectDebtDetails where ProjectID=@ProjectID and IsDeleted=0
	END
    SELECT DISTINCT
TicketID,
MBD.TowerName,
DebtClassification,
AvoidableFlag,
ResidualDebt,
CauseCode,
ResolutionCode,
TicketDescriptionPattern,
TicketDescriptionSubPattern,
OptionalFieldpattern,
OptionalFieldSubPattern from  AVL.ML_MLBaseDetailsInfra MBD 
JOIN AVL.InfraTowerDetailsTransaction TD ON TD.TowerName=MBD.TowerName AND MBD.ProjectID=@ProjectID AND TD.CustomerID=@CustomerID
JOIN AVL.InfraTowerProjectMapping TPM ON TPM.TowerID=TD.InfraTowerTransactionID AND MBD.ProjectID=TPM.ProjectID  AND TPM.IsEnabled=1  AND TPM.IsDeleted=0
--JOIN AVL.APP_MAP_ApplicationProjectMapping AP ON AP.ProjectID=MBD.ProjectID
AND TPM.ProjectID=@ProjectID 

LEFT JOIN AVL.ML_TRN_RegeneratedTowerDetails RAD
ON RAD.TowerID=TD.InfraTowerTransactionID AND RAD.IsDeleted=0 AND RAD.InitialLearningID=@InitialLearningID AND RAD.ProjectID=@PROJECTID 
WHERE ((@IsRegenerate=1 AND @IsMLSignOff=0 and RAD.ID is not NULL) OR (@IsRegenerate=1 and @IsMLSignOff=1) OR (@IsRegenerate=0))

  
          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_GetBaseDetailsInfra]', 
            @ErrorMessage, 
            @ProjectID
      END CATCH 
  END
