/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[DebtReview_GetHealPatternByProjectId] --19645
	-- Add the parameters for the stored procedure here	
  (	                
    @ProjectID BIGINT 
  )
	
AS
BEGIN  
BEGIN TRY 
  SET NOCOUNT ON; 

 --  SELECT
	--	HC.ColumnName
	--FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HP
	--JOIN  AVL.DEBT_MAS_HealColumnMaster(NOLOCK) HC ON HP.ColumnID=HC.ColumnID
	--WHERE HP.ProjectID=@ProjectID AND HP.IsActive=1
	SELECT REPLACE(replace(MC.ColumnName,'(',''),')','') AS 'ServiceColumn',SCM.ProjectColumn AS 'ColumnName'
	FROM AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPP
	JOIN AVL.DEBT_MAS_HealColumnMaster MC ON HPP.ColumnID=MC.ColumnID AND MC.IsActive=1
	JOIN AVL.ITSM_PRJ_SSISColumnMapping SCM ON MC.ColumnName = REPLACE(SCM.ServiceDartColumn, ' ', '') and SCM.ProjectID=@ProjectID AND SCM.IsDeleted = 0
	WHERE HPP.ColumnID in( 11,12,13,14)
	AND HPP.IsActive = 1
	AND HPP.ProjectID = @ProjectID
 
  
  SET NOCOUNT OFF; 

  END TRY
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[DebtReview_GetHealPatternByProjectId]', @ErrorMessage, @ProjectID
  END CATCH   

END
