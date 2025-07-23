/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Audit_GetListTicketMasterDetailsForInitialLearning] 
--4615,'627384',''
@ProjectID BIGINT,
@UserID VARCHAR(1000),
@Type VARCHAR(MAX)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;
IF @Type='From'
	BEGIN
		SELECT DTV.PROJECTID,DTV.TICKETID,
		TM.[DebtClassificationMapID] AS DebtClassification,TM.AvoidableFlag AS AvoidableFlag,
		TM.[ResidualDebtMapID] AS ResidualDebt,
		TM.[CauseCodeMapID] AS CauseCode,TM.[ResolutionCodeMapID] AS ResolutionCode 
		FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) TM
		INNER JOIN [AVL].[ML_TRN_TicketValidation](NOLOCK) DTV
		ON TM.ProjectID=DTV.ProjectID AND TM.TicketID=DTV.TicketID
		WHERE DTV.PROJECTID=@ProjectID AND DTV.Createdby=@UserID
	END
ELSE
BEGIN
	SELECT ID,PROJECTID,TICKETID,TICKETDESCRIPTION,APPLICATIONID,DEBTCLASSIFICATIONID,AVOIDABLEFLAGID,RESIDUALDEBTID,
	CAUSECODEID,RESOLUTIONCODEID,CREATEDBY,CREATEDDATE,MODIFIEDBY,MODIFIEDDATE,ISDELETED INTO #DebtTicketsValidation
	FROM [AVL].[ML_TRN_TicketValidation] WHERE ProjectID=@ProjectID AND 
	Createdby=@UserID
  --DECLARE @AttributeFieldMaster AS TABLE                        
  --(                        
  -- Id INT,                         
  -- AttributeType Varchar(100),                        
  -- AttributeTypeValue Varchar(100)                        
  --)                         
                          
  --INSERT INTO @AttributeFieldMaster                         
  --SELECT Id, AttributeType,                         
  --       CASE WHEN CHARINDEX('(',AttributeTypeValue) > 0                                 
  --       THEN SUBSTRING(AttributeTypeValue,0,CHARINDEX('(',AttributeTypeValue))                              
  --       ELSE AttributeTypeValue END AS AttributeTypeValue                         
  --FROM MAS.AttributeFieldMAster                        
  --WHERE IsDeleted='N'  
	---- Debt Classification                               
	UPDATE  X2                                
	SET     X2.DebtClassificationId =x3.[DebtClassificationID]                                
	FROM   #DebtTicketsValidation X2                                
	JOIN  [AVL].[DEBT_MAS_DebtClassification] X3 ON                               
	X2.DebtClassificationID = X3.[DebtClassificationID]                               
	WHERE   x2.ProjectID = @projectid   
	
	
	                     
                                  

	---- Avoidable Flag                               
	UPDATE  X2                                
	SET     X2.AvoidableFlagID =x3.AvoidableFlagID                               
	FROM    #DebtTicketsValidation X2   join                             
    AVL.DEBT_MAS_AvoidableFlag  X3 ON                             
	X2.AvoidableFlagID = X3.AvoidableFlagID                              
	WHERE   x2.ProjectID = @projectid         

	---- Residual Debt                               
	UPDATE  X2                                
	SET     X2.ResidualDebtID =x3.[ResidualDebtID]                               
	FROM    #DebtTicketsValidation X2                                
	JOIN [AVL].[DEBT_MAS_ResidualDebt] X3 ON                                
	X2.ResidualDebtID = X3.[ResidualDebtID]                                  
	WHERE   x2.ProjectID = @projectid 

	---Cause Code  

	UPDATE  X2 SET X2.CauseCodeID =x3.CauseID         
	FROM #DebtTicketsValidation X2                              
	JOIN [AVL].[DEBT_MAP_CauseCode]  X3 ON  X2.CauseCodeID=X3.CauseID and                          
	X3.IsDeleted=0 and  X2.ProjectID =X3.ProjectID                            
	WHERE x2.ProjectID = @projectid   

	--Resolution Code  

	UPDATE  X2 SET X2.ResolutionCodeID =x3.ResolutionID         
	FROM #DebtTicketsValidation X2                              
	JOIN [AVL].[DEBT_MAP_ResolutionCode]   X3 ON  X2.ResolutionCodeID=X3.ResolutionID and                          
	X3.IsDeleted=0 and  X2.ProjectID =X3.ProjectID                            
	WHERE x2.ProjectID = @projectid   

	SELECT DTV.PROJECTID,DTV.TICKETID,
	DTV.DebtClassificationId AS DebtClassification,DTV.AvoidableFlagID AS AvoidableFlag,
	DTV.ResidualDebtID AS ResidualDebt,
	DTV.CauseCodeID AS CauseCode,DTV.ResolutionCodeID AS ResolutionCode 
	FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) TM
	INNER JOIN #DebtTicketsValidation DTV
	ON TM.ProjectID=DTV.ProjectID AND TM.TicketID=DTV.TicketID
	WHERE DTV.PROJECTID=@ProjectID AND DTV.Createdby=@UserID
	END	
	
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[Audit_GetListTicketMasterDetailsForInitialLearning] ', @ErrorMessage, @ProjectID,@UserID
		
	END CATCH  



END

--SELECT * FROM  PRJ.SSISImportTicketMaster
--WHERE ProjectID=14498
--select * from [TRN].[Debt_TicketsValidation]
--select * from [MAS].[DeptResolutionCode]
