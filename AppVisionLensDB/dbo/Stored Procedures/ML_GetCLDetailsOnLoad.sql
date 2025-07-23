/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_GetCLDetailsOnLoad] --ML_GetMLDetailsOnLoad 687591,'AfterProcess'

@ProjectID int=null
as
BEGIN
BEGIN TRY
SELECT  convert(varchar(10),CLAutoClassifiedDate,110) AS CLAutoclassificationDate,ISNULL(IsCLAutoClassified ,'') AS IsCLAutoClassified , 
ISNULL(ISCLSIGNOFF,0) AS IsCLSignOff from [AVL].[MAS_ProjectDebtDetails] where ProjectID	= @ProjectID and isdeleted=0 
END TRY
BEGIN CATCH  

		DECLARE @ErrorMessage1 VARCHAR(MAX);

		SELECT @ErrorMessage1 = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_GetMLDetailsOnLoad] ', @ErrorMessage1, @ProjectID,0
		
	END CATCH  

END
