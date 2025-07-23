
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE  PROCEDURE [CS].[GetESAProjectDetails](@EmpID NVARCHAR(100))
    -- Add the parameters for the stored procedure here
AS
BEGIN
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
        -- Insert statements for procedure here
	


SELECT CAST(ES.ProjectID AS varchar(25)) AS 'ProjectId', ES.Project_Small_Desc AS 'ProjectName' from ESA.ProjectAssociates ES   where AssociateID=@EmpID order by ES.ProjectID asc;

END TRY
BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		EXEC [CS].[InsertErrorLog]  '[CS].[GetESAProjectDetails]', @ErrorMessage,  0
END CATCH
END
