
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE proc [dbo].[ITSM_CalculateWPProgressBar]-- 10038 --51 --83,5497

@ProjectID int,
@CustomerID INT=NULL
as
begin
BEGIN TRY

declare @progrespercentage int;

select @progrespercentage=tileprogresspercentage from PP.ProjectProfilingTileProgress where tileid=11 and projectid=@ProjectID 
select isnull(@progrespercentage,0) as tileprogresspercentage

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ITSM_CalculateWPProgressBar]', @ErrorMessage, @ProjectID,@CustomerID
		
	END CATCH  
	SET NOCOUNT OFF;

end
