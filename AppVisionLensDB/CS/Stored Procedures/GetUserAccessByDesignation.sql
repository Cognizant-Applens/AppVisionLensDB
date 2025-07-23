/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

/****** Object:  StoredProcedure [CS].[GetUserAccessByDesignation]    Script Date: 7/8/2020 7:33:23 PM ******/
CREATE PROCEDURE [CS].[GetUserAccessByDesignation](@AssociateID VARCHAR(15))
    -- Add the parameters for the stored procedure here
AS
BEGIN
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
        -- Insert statements for procedure here

	SELECT 
		CASE WHEN A.GRADE IN ('C60', 'C77', 'C79', 'C81',
			'E10', 'E15', 'E20', 'E25', 'E30', 'E33', 'E35','E40', 'E45', 'E50', 'E51','E60','E77','E79',
			'N25','N30','N33','N35','N40','N45','N50','N60') 
		THEN 'Y' 
		ELSE 'N' 
		END AS 'Result'
	FROM ESA.Associates(nolock) A WHERE A.AssociateID = @AssociateId AND A.IsActive = 1
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
		EXEC [CS].[InsertErrorLog]  '[CS].[GetUserAccessByDesignation]', @ErrorMessage,  0
END CATCH
END
