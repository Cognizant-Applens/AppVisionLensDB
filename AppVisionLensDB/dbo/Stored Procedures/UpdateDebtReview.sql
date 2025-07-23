/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--Exec [UpdateDebtReview] 1,'NiviTest1',52,34,2,3,2,'04-06-2018'
CREATE proc [dbo].[UpdateDebtReview]
(
@DebtClassificationID bigint,
@TicketID varchar(100),
@ResolutionID bigint,
@CauseID bigint,
@ResidualDebtID bigint,
@AvoidableFlag int,
@ReasonResiID bigint,
@ExCompDate datetime

)
AS
BEGIN
 SET NOCOUNT ON;  
	DECLARE @result bit
	BEGIN TRY
	  BEGIN TRANSACTION
update AVL.[TK_TRN_TicketDetail_Debt] set DebtClassificationMapID=@DebtClassificationID,ResidualDebtMapID=@ResidualDebtID,
AvoidableFlag=@AvoidableFlag,ReasonResidualMapID=@ReasonResiID,ExpectedCompletionDate=@ExCompDate
,ResolutionCodeMapID=@ResolutionID,CauseCodeMapID=@CauseID where TicketID=@TicketID
 COMMIT TRANSACTION
	  SET @result= 1
     END TRY
	 BEGIN CATCH
	      IF @@TRANCOUNT > 0
		    BEGIN
			   ROLLBACK TRANSACTION
			   SET @result= 0 
		    END
	 END CATCH
	 SELECT @result AS RESULT
	  SET NOCOUNT OFF; 
--Select 'Debt Review updated sucessfully' As 'Result'
END
