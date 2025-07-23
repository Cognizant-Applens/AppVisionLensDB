/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[GetEmployeeProjectDetails]



	@EmployeeID varchar(50),

	@CustomerID int



AS



BEGIN



BEGIN TRY







	SET NOCOUNT ON;







		Select PM.ProjectID,PM.ProjectName from [AVL].[MAS_LoginMaster] AS LM 



		Inner Join [AVL].[MAS_ProjectMaster] as PM on LM.ProjectID = PM.ProjectID



		where LM.EmployeeID = @EmployeeID and LM.isdeleted = 0 and LM.CustomerID = @CustomerID



		group by PM.ProjectID,PM.ProjectName



		







END TRY



BEGIN Catch







        DECLARE @ErrorMessage VARCHAR(MAX);







        SELECT @ErrorMessage = ERROR_MESSAGE()



                                



        --INSERT Error    



        EXEC AVL_InsertError '[dbo].[ML_MLPatternValidation] ', @ErrorMessage, 0,@EmployeeID



                                



End Catch







END
