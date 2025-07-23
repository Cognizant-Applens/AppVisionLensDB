/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [LW].[LW_GetCustomer]
@BUID SMALLINT
AS
BEGIN

SET NOCOUNT ON;

BEGIN TRY

Select distinct [AccountID] AS CustomerID,AccountName AS CustomerName,
[BUID] FROM [LW].[RuleStatistics] WITH (NOLOCK)
where [BUID] = @BUID AND [DeliveryOnpremiseInd] = 'd' AND
[IsActive] = 1;

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

              SELECT @ErrorMessage = ERROR_MESSAGE()

              --INSERT Error    
              EXEC AVL_InsertError  '[LW].[LW_GetCustomer]'
							,@ErrorMessage
							,''
							,0
END CATCH
END