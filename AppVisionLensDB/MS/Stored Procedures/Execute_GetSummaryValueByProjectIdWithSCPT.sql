/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Saravanan.B>
-- Create date: <01/21/2019>
-- Description:	<Execute_GetSummaryValueByProjectIdWithSCPT>
-- =============================================
CREATE PROCEDURE [MS].[Execute_GetSummaryValueByProjectIdWithSCPT] 
    @ProjectID BIGINT,
	@ServiceID INT,
	@StartDate VARCHAR(50),
	@EndDate VARCHAR(50),
	@Priority INT=NULL,
	@SupportCategory INT=NULL,
	@SPName VARCHAR(100)=''
AS
BEGIN  
BEGIN TRY 
BEGIN TRAN
  SET NOCOUNT ON;  

  DECLARE @CallSP VARCHAR(2000)=''
	SET @CallSP=  @SPName  + ' @ProjectID=' +  ISNULL(CAST(@ProjectID AS VARCHAR(20)),'0') +','  
	              +' @ServiceID=' + ISNULL(CAST(@ServiceID AS VARCHAR(20)),'0')
	              +', @StartDate='''+ ISNULL(@StartDate,'')+''''
				  +', @EndDate='''+ISNULl(@EndDate,'')+''''
	              +', @Priority=' +ISNULL(CAST(@Priority AS VARCHAR(20)),'0')
				  +', @SupportCategory='+ISNULL(CAST(@SupportCategory AS VARCHAR(20)),'0')

	EXEC (@CallSP)

  SET NOCOUNT OFF; 
 COMMIT TRAN
  END TRY
  
  BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'Execute_GetSummaryValueByProjectIdWithSCPT', @ErrorMessage, @ProjectID
  END CATCH   

END
