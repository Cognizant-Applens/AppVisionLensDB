/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


--[debt_getautoclassifiedfieldforsharepathchange] 19100

CREATE Proc [dbo].[AVL_debt_getautoclassifiedfieldforsharepathchange] --4

@ProjectId varchar(max)



as

begin

BEGIN TRY

declare @IsAutoClassified varchar(2)

declare @MLSignOffDate datetime

declare @IsDDAutoClassified varchar(2)

declare @DDClassifiedDate datetime

declare @DDDateCheck varchar(2)



Select @IsAutoClassified=IsAutoClassified , @MLSignOffDate=MLSignOffDate, @IsDDAutoClassified = IsDDAutoClassified, @DDClassifiedDate =IsDDAutoClassifiedDate

from AVL.MAS_ProjectDebtDetails where 

ProjectID =  @ProjectID 



if(@DDClassifiedDate<= getdate())

begin 

SET @DDDateCheck = 'Y';

SET @IsDDAutoClassified = 'Y';

END

ELSE

begin

SET @DDDateCheck = 'N';

SET @IsDDAutoClassified = 'N';

End



if(@MLSignOffDate<= getdate())

begin

select  @IsAutoClassified as IsAutoClassified ,@MLSignOffDate as AutoClassificationDate, 

@IsDDAutoClassified as IsDDAutoClassified, @DDDateCheck as DDClassifiedDate

end

else

begin

select  'N' as IsAutoClassified ,@MLSignOffDate as AutoClassificationDate, @IsDDAutoClassified as IsDDAutoClassified, @DDDateCheck as DDClassifiedDate

end



END TRY  

BEGIN CATCH  



		DECLARE @ErrorMessage VARCHAR(MAX);



		SELECT @ErrorMessage = ERROR_MESSAGE()



		--INSERT Error    

		EXEC AVL_InsertError '[dbo].[AVL_debt_getautoclassifiedfieldforsharepathchange] ', @ErrorMessage, @ProjectId,0

	END CATCH  







end
