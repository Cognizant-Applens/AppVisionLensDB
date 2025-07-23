/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE procedure [dbo].[debt_getautoclassifiedfieldforsharepathchange] 
@ProjectId varchar(max)

as
BEGIN
	
BEGIN TRY
SET NOCOUNT ON;

declare @IsAutoClassified varchar(2)
declare @MLSignOffDate datetime
declare @IsDDAutoClassified varchar(2)
declare @DDClassifiedDate datetime
declare @DDDateCheck varchar(2)
declare @IsAutoClassifiedInfra varchar(2)
declare @MLSignOffDateInfra datetime
declare @IsDDAutoClassifiedInfra varchar(2)
declare @DDClassifiedDateInfra datetime
declare @DDDateCheckInfra varchar(2)
	


	Select @IsAutoClassified=IsAutoClassified , @MLSignOffDate=MLSignOffDate, @IsDDAutoClassified = IsDDAutoClassified, @DDClassifiedDate =IsDDAutoClassifiedDate,
		   @IsAutoClassifiedInfra=IsAutoClassifiedInfra , @MLSignOffDateInfra=MLSignOffDateInfra, @IsDDAutoClassifiedInfra = IsDDAutoClassifiedInfra,
		   @DDClassifiedDateInfra =IsDDAutoClassifiedDateInfra
	from AVL.MAS_ProjectDebtDetails (NOLOCK) where ProjectID = @ProjectId and IsDeleted = 0


	--App Classifications
	SET @DDDateCheck = CASE WHEN (@DDClassifiedDate<= getdate() AND @IsDDAutoClassified='Y') THEN 'Y' ELSE 'N' END

	SET @IsDDAutoClassified = CASE WHEN (@DDClassifiedDate<= getdate() AND @IsDDAutoClassified='Y') THEN 'Y' ELSE 'N' END

	SET @IsAutoClassified = CASE WHEN (@MLSignOffDate<= getdate() AND @IsAutoClassified='Y') THEN 'Y' ELSE 'N' END


	--Infra Classsifications
	SET @DDDateCheckInfra = CASE WHEN (@DDClassifiedDateInfra<= getdate() AND @IsDDAutoClassifiedInfra='Y') THEN 'Y' ELSE 'N' END

	SET @IsDDAutoClassifiedInfra = CASE WHEN (@DDClassifiedDateInfra<= getdate() AND @IsDDAutoClassifiedInfra='Y') THEN 'Y' ELSE 'N' END

	SET @IsAutoClassifiedInfra = CASE WHEN (@MLSignOffDateInfra<= getdate() AND @IsAutoClassifiedInfra='Y') THEN 'Y' ELSE 'N' END

	--Result of O/P
	select @IsAutoClassified as IsAutoClassified ,@MLSignOffDate as AutoClassificationDate,@IsDDAutoClassified as IsDDAutoClassified, @DDDateCheck as DDClassifiedDate,
		   @IsAutoClassifiedInfra as IsAutoClassifiedInfra ,@MLSignOffDateInfra as AutoClassificationDateInfra,@IsDDAutoClassifiedInfra as IsDDAutoClassifiedInfra, 
		   @DDDateCheckInfra as DDClassifiedDateInfra

END TRY  

BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()   

		EXEC AVL_InsertError '[dbo].[debt_getautoclassifiedfieldforsharepathchange] ', @ErrorMessage, @ProjectId,0

	END CATCH  
	SET NOCOUNT OFF;
END
