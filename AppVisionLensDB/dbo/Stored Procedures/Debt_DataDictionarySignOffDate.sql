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
-- Author:		<Ram kumar>
-- Modified date: <02/15/2019>
-- Description:	<[dbo].[Debt_DataDictionarySignOffDate]>
-- =============================================
--Exec [dbo].[Debt_DataDictionarySignOffDate] 4,11,'04/19/2018'
CREATE Procedure [dbo].[Debt_DataDictionarySignOffDate] 
(
@ProjectID int,
@ApplicationID int,
--@PortfolioID int,
@EffectiveDate Datetime,
@EmployeeID varchar(100)


)
AS
BEGIN
 SET NOCOUNT ON;  
	DECLARE @result bit
	DECLARE @DDDate varchar(100)
		BEGIN TRY
	  BEGIN TRANSACTION
	  --Update [AVL].[Debt_MAS_ProjectDataDictionary]  set EffectiveDate=@EffectiveDate,ModifiedDate=getdate(), ModifiedBy = @EmployeeID where ProjectID=@ProjectID and ApplicationID=@ApplicationID and IsDeleted=0
	  Update [AVL].[Debt_MAS_ProjectDataDictionary]  set EffectiveDate=@EffectiveDate,ModifiedDate=getdate(), ModifiedBy = @EmployeeID where ProjectID=@ProjectID and IsDeleted=0
	  --SET @result= 1
	  --Select top 1 ModifiedDate, @result as Result from [AVL].[Debt_MAS_ProjectDataDictionary] where ProjectID=@ProjectID and ApplicationID=@ApplicationID
		set @DDDate = (select IsDDAutoClassifiedDate from AVL.MAS_ProjectDebtDetails where ProjectID = @ProjectID)
		--if(ISNULL(@DDDate,0) = '0')
		--BEGIN
			UPDATE AVL.MAS_ProjectDebtDetails set IsDDAutoClassifiedDate = @EffectiveDate where ProjectID = @ProjectID
		--END
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
END
