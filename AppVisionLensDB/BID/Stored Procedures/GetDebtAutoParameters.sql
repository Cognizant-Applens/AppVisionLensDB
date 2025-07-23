/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [BID].[GetDebtAutoParameters]
@DealScope NVARCHAR(50),
@DescWorkPattern NVARCHAR(MAX),
@DescWorkSubPattern NVARCHAR(MAX),
@ResolutionWorkPattern NVARCHAR(MAX),
@ResolutionWorkSubPattern NVARCHAR(MAX),
@AccountName NVARCHAR(500),
@BUName NVARCHAR(50)

AS

BEGIN

SET NOCOUNT ON;

BEGIN TRY
IF EXISTS(SELECT RT.RecordID FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID]   
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern AND RT.AccountName = @AccountName AND RT.BUName = @BUName
AND RT.RuleLevel = 'Account' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0)
BEGIN
Select RT.RecordID AS RuleID,RM.[DealScope]
      ,RM.[UseCase]
      ,RM.[SubGroup]
      ,RM.[DescWorkPattern]
      ,RM.[DescWorkSubPattern]
      ,RM.[ResolutionWorkPattern]
      ,RM.[ResolutionWorkSubPattern]
      ,RM.[DebtClassification]
      ,RM.[AvoidableFlag]
      ,RM.[AutomationPossibility]
      ,RM.[ProposedAutomationTool]
      ,RM.[AutomationImplFeasibility]
      ,RM.[AutomationImplFeasibilityPercentage]
      ,RM.[EliminationFeasibilityPercentage]
      ,RM.[LeftShiftPercentage],RT.RuleLevel FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID] 
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern AND RT.AccountName = @AccountName AND RT.BUName = @BUName
AND RT.RuleLevel = 'Account' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0;
END
ELSE IF EXISTS(SELECT RT.RecordID FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID]   
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern AND RT.BUName = @BUName
AND RT.RuleLevel = 'Domain' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0)
BEGIN
Select RT.RecordID AS RuleID,RM.[DealScope]
      ,RM.[UseCase]
      ,RM.[SubGroup]
      ,RM.[DescWorkPattern]
      ,RM.[DescWorkSubPattern]
      ,RM.[ResolutionWorkPattern]
      ,RM.[ResolutionWorkSubPattern]
      ,RM.[DebtClassification]
      ,RM.[AvoidableFlag]
      ,RM.[AutomationPossibility]
      ,RM.[ProposedAutomationTool]
      ,RM.[AutomationImplFeasibility]
      ,RM.[AutomationImplFeasibilityPercentage]
      ,RM.[EliminationFeasibilityPercentage]
      ,RM.[LeftShiftPercentage],RT.RuleLevel FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID] 
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern AND RT.BUName = @BUName 
AND RT.RuleLevel = 'Domain' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0;
END
ELSE IF EXISTS(SELECT RT.RecordID FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID]   
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern
AND RT.RuleLevel = 'AVM' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0 AND BUName IS NOT NULL)
BEGIN
Select RT.RecordID AS RuleID,RM.[DealScope]
      ,RM.[UseCase]
      ,RM.[SubGroup]
      ,RM.[DescWorkPattern]
      ,RM.[DescWorkSubPattern]
      ,RM.[ResolutionWorkPattern]
      ,RM.[ResolutionWorkSubPattern]
      ,RM.[DebtClassification]
      ,RM.[AvoidableFlag]
      ,RM.[AutomationPossibility]
      ,RM.[ProposedAutomationTool]
      ,RM.[AutomationImplFeasibility]
      ,RM.[AutomationImplFeasibilityPercentage]
      ,RM.[EliminationFeasibilityPercentage]
      ,RM.[LeftShiftPercentage],RT.RuleLevel FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID] 
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern 
AND RT.RuleLevel = 'AVM' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0 AND BUName IS NOT NULL
END
ELSE IF EXISTS(SELECT RT.RecordID FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID]   
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern
AND RT.RuleLevel = 'AVM' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0 AND BUName IS NULL)
BEGIN
Select RT.RecordID AS RuleID,RM.[DealScope]
      ,RM.[UseCase]
      ,RM.[SubGroup]
      ,RM.[DescWorkPattern]
      ,RM.[DescWorkSubPattern]
      ,RM.[ResolutionWorkPattern]
      ,RM.[ResolutionWorkSubPattern]
      ,RM.[DebtClassification]
      ,RM.[AvoidableFlag]
      ,RM.[AutomationPossibility]
      ,RM.[ProposedAutomationTool]
      ,RM.[AutomationImplFeasibility]
      ,RM.[AutomationImplFeasibilityPercentage]
      ,RM.[EliminationFeasibilityPercentage]
      ,RM.[LeftShiftPercentage],RT.RuleLevel FROM [BID].[RulesMaster] RM WITH (NOLOCK)  INNER JOIN 
	   [BID].[RuleTransaction]  RT  ON RT.[RuleID] = RM.[RuleID] 
where RM.[DealScope] = @DealScope AND RM.[DescWorkPattern] = @DescWorkPattern AND
RM.[DescWorkSubPattern] = @DescWorkSubPattern AND RM.[ResolutionWorkPattern] = @ResolutionWorkPattern AND
RM.[ResolutionWorkSubPattern] = @ResolutionWorkSubPattern 
AND RT.RuleLevel = 'AVM' AND RT.IsDeleted = 0 AND RT.RuleStatusInd = 1 AND RM.IsDeleted = 0 AND BUName IS NULL
END
END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()

              --INSERT Error    
              EXEC AVL_InsertError  '[BID].[GetDebtAutoParameters]'
							,@ErrorMessage
							,''
							,0
END CATCH
END