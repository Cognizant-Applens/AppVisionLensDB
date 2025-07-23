/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_GetBaseDetails] (@ProjectID bigint)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

     declare @InitialLearningID bigint
	 declare @IsRegenerate bit
	 DECLARE @CustomerID BIGINT

	 declare @IsMLSignOff BIT

    select top 1 @InitialLearningID=ID,@IsRegenerate=isnull(IsRegenerated,0) from AVL.ML_PRJ_InitialLearningState where ProjectID=@ProjectID and IsDeleted=0 ORDER by ID DESC
	SELECT @CustomerID=CustomerID FROM AVL.MAS_ProjectMaster WHERE ProjectID=@ProjectID AND IsDeleted=0

	IF(@IsRegenerate=1)
	BEGIN

set  @IsMLSignOff=	(SELECT top 1 IsMLSignOff from AVL.ML_TRN_RegeneratedApplicationDetails where ProjectID=@ProjectID and IsDeleted=0 and InitialLearningID=@InitialLearningID )


	END
	ELSE
	BEGIN
	SELECT @IsMLSignOff=IsMLSignOff from AVL.MAS_ProjectDebtDetails where ProjectID=@ProjectID and IsDeleted=0
	END
    SELECT DISTINCT
TicketID,
MBD.ApplicationName,
DebtClassification,
AvoidableFlag,
ResidualDebt,
CauseCode,
ResolutionCode,
TicketDescriptionPattern,
TicketDescriptionSubPattern,
OptionalFieldpattern,
OptionalFieldSubPattern from  ML_MLBaseDetails MBD
JOIN AVL.APP_MAS_ApplicationDetails AD ON AD.ApplicationName=MBD.ApplicationName AND AD.IsActive=1 AND MBD.ProjectID=@ProjectID AND MBD.Isdeleted=0
JOIN AVL.BusinessClusterMapping BCM ON BCM.BusinessClusterMapID=AD.SubBusinessClusterMapID AND BCM.CustomerID=@CustomerID AND BCM.IsDeleted=0
JOIN AVL.APP_MAP_ApplicationProjectMapping APM ON APM.ApplicationID=AD.ApplicationID AND APM.ProjectID=MBD.ProjectID AND APM.IsDeleted=0 
LEFT JOIN AVL.ML_TRN_RegeneratedApplicationDetails RAD ON RAD.ApplicationID=AD.ApplicationID AND RAD.InitialLearningID=@InitialLearningID AND RAD.ProjectID=MBD.ProjectID


 WHERE 
 ((@IsRegenerate=1 AND @IsMLSignOff=0 and RAD.ID is not NULL) OR (@IsRegenerate=1 and @IsMLSignOff=1) OR (@IsRegenerate=0))
 --ProjectID=@ProjectID and Isdeleted=0
          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_GetBaseDetails]', 
            @ErrorMessage, 
            @ProjectID
      END CATCH 
  END
