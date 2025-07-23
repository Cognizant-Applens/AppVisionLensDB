/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_CL_UpdateMLPatternValidation]
(
@ProjectID NVARCHAR(200)
--@AppID nVARCHAR(MAX)

)
AS 
BEGIN 
BEGIN TRY
DECLARE @CustomerID INT=0;
			DECLARE @IsCognizantID INT;
			SET @CustomerID=(SELECT top 1 CustomerID FROM AVL.MAS_LoginMaster WHERE ProjectID=@ProjectID AND IsDeleted=0)
			SET @IsCognizantID=(SELECT top 1 IsCognizant FROM AVL.Customer WHERE CustomerID=@CustomerID AND IsDeleted=0)
DECLARE @ContLearningID INT;

SET @ContLearningID=(SELECT TOP 1 ContLearningID FROM AVL.CL_PRJ_ContLearningState
						WHERE ProjectID=@ProjectID and IsDeleted=0 ORDER BY ContLearningID DESC)

--SELECT ITEM INTO #tempid FROM split(@AppID,',')



SELECT  cl.ID,cl.InitialLearningID,cl.ProjectID,cl.ApplicationID,cl.ApplicationTypeID,cl.TechnologyID,cl.TicketPattern,cl.MLResidualFlagID,
cl.MLDebtClassificationID,cl.MLAvoidableFlagID,cl.MLCauseCodeID,cl.MLAccuracy,cl.TicketOccurence,cl.AnalystResidualFlagID,
cl.AnalystResolutionCodeID,cl.AnalystCauseCodeID,cl.AnalystDebtClassificationID,cl.AnalystAvoidableFlagID,cl.SMEComments,cl.SMEResidualFlagID,cl.SMEDebtClassificationID,
cl.SMEAvoidableFlagID,cl.SMECauseCodeID,cl.IsApprovedOrMute,cl.CreatedBy,cl.CreatedDate,cl.ModifiedBy,cl.ModifiedDate,cl.ReasonforResidual,cl.MLResolutionCodeID
INTO #tempContNewLearning FROM AVL.ML_TRN_MLPatternValidation_cl cl
inner join AVL.ML_TRN_MLPatternValidation ml ON ml.TicketPattern = cl.TicketPattern 
and cl.ApplicationID = ml.ApplicationID and ml.ProjectID = cl.ProjectID and cl.MLCauseCodeID = ml.MLCauseCodeID and cl.MLResolutionCodeID = ml.MLResolutionCode
--INNER JOIN #tempid t ON t.item = ML.ApplicationID
WHERE ml.projectid = @ProjectID and cl.TicketPattern <> '0' and cl.isdeleted = 0  ORDER BY  ml.ID

UPDATE AVL.ML_TRN_MLPatternValidation_CL SET IsDeleted = 1 WHERE ID IN (SELECT ID FROM  #tempContNewLearning)

CREATE TABLE #tmpILuniqueID
(
pattern VARCHAR(max),
ID int,
MLCauseCodeID int,
MLResolutionCode int,
ApplicationID int
)

Insert into #tmpILuniqueID
select   ticketpattern,min(id) as ID,MLCauseCodeID  ,MLResolutionCode ,ApplicationID
from AVL.ML_TRN_MLPatternValidation 
where projectid = @ProjectID and isdeleted = 0 and ticketpattern <> '0' and IsApprovedOrMute is not null
group by ticketpattern,MLCauseCodeID  ,MLResolutionCode ,ApplicationID


SELECT * INTO #tmpInitialLearnings FROM AVL.ML_TRN_MLPatternValidation WHERE ID IN (select ID from #tmpILuniqueID) 


INSERT INTO AVL.ML_TRN_MLPatternValidation_CL

SELECT IL.InitialLearningID,projectID,ApplicationID,ApplicationTypeID,TechnologyID,TicketPattern,MLResidualFlagID,
MLDebtClassificationID,MLAvoidableFlagID,MLCauseCodeID,MLAccuracy,TicketOccurence,AnalystResidualFlagID,AnalystResolutionCOdeID,AnalystCausecodeID,
AnalystDebtClassificationID,AnalystAvoidableFlagID,SMEComments,SMEResidualFlagID,SMEDebtClassificationID,SMEAvoidableFlagID,SMECauseCodeID,
IsApprovedorMUte,CreatedBY,getdate(),ModifiedBY,getdate(),IsDeleted,ClassifiedBY,null,ReasonforResidual,0,MLResolutionCode from #tmpInitialLearnings IL

IF EXISTS (SELECT * FROM AVL.CL_PatterOccurence O 
INNER JOIN #tmpInitialLearnings IL ON LTRIM(RTRIM(IL.TicketPattern)) = LTRIM(RTRIM(o.TicketPattern)) 
AND IL.PROJECTID = O.ProjectID AND IL.APPLICATIONID = O.ApplicationID AND IL.MLCauseCodeID = O.SMECauseCodeID 
AND IL.MLResolutionCode = O.SMEResolutionCodeID
WHERE O.ProjectID = @ProjectID AND O.IsDeleted = 0  )

BEGIN

UPDATE O SET O.IsDeleted = 1 from AVL.CL_PatterOccurence o
INNER JOIN #tmpInitialLearnings IL ON LTRIM(RTRIM(IL.TicketPattern)) = LTRIM(RTRIM(o.TicketPattern)) 
AND IL.PROJECTID = O.ProjectID AND IL.APPLICATIONID = O.ApplicationID AND IL.MLCauseCodeID = O.SMECauseCodeID
and il.MLResidualFlagID = o.SMEResidualCodeID
and il.MLDebtClassificationID = o.SMEDebtClassificationID and il.MLAvoidableFlagID = o.SMEAvoidableFlagID
AND IL.MLResolutionCode = O.SMEResolutionCodeID
WHERE O.ProjectID = @ProjectID and IL.projectid = @ProjectID and IL.isdeleted = 0 and  o.isdeleted = 0 

INSERT INTO AVL.CL_PatterOccurence 
SELECT @ContLearningID,IL.projectID,IL.ApplicationID,IL.TicketPattern,IL.TicketOccurence,IL.CreatedBY,getdate(),IL.ModifiedBY,getdate(),0,
IL.MLDebtClassificationID,IL.MLResidualFlagID,IL.MLCauseCodeID,IL.MLAvoidableFlagID,IL.MLResolutionCode 
from #tmpInitialLearnings IL
INNER JOIN AVL.CL_PatterOccurence O ON LTRIM(RTRIM(IL.TicketPattern)) = LTRIM(RTRIM(o.TicketPattern)) 
AND IL.PROJECTID = O.ProjectID AND IL.APPLICATIONID = O.ApplicationID AND IL.MLCauseCodeID = O.SMECauseCodeID 
AND IL.MLResolutionCode = O.SMEResolutionCodeID
WHERE O.ProjectID = @ProjectID and IL.isdeleted = 0 and  o.isdeleted = 0 


END
END TRY
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'ML_CL_UpdateMLPatternValidation ', @ErrorMessage, @ProjectID,0
		
	END CATCH  	
	END
