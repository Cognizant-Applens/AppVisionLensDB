/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[AVL_DebtGetAutoClassifiedDebtFilds_DD_sharepath] 
@ProjectID VARCHAR(MAX),
@ApplicationName VARCHAR(MAX),
@TicketDescription NVARCHAR(MAX),
@Causecode INT,
@Resolutioncode INT,
@IsAutoClassified CHAR,
@IsDDAutoClassified CHAR,
@ServiceID NVARCHAR(10)= NULL,
@TicketTypeID NVARCHAR(10)= NULL,
@TimeTickerID  nvarchar(max) = NULL,
@UserID nvarchar(max)
AS
BEGIN
BEGIN TRY
SET @TicketDescription=LTRIM(RTRIM(@TicketDescription));
delete from [AVL].[TRN_DebtClassificationModeDetails] where [TimeTickerID] = @TimeTickerID
DECLARE @IsDebtEnabled NVARCHAR(10);
DECLARE @CustomerID BIGINT;
DECLARE @IsCognizant INT;
SET @CustomerID=(SELECT CustomerID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0 )
SET @IsDebtEnabled=(SELECT IsDebtEnabled FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0)
SET @IsCognizant=(SELECT IsCognizant FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0)

DECLARE @IsserviceApplicable INT
DECLARE @ISTicketTypeApplicable INT

DECLARE @DebtClassificationflag NVARCHAR(max),@AvoidableFlag NVARCHAR(max),@ResidualFlag NVARCHAR(max)
SET @IsserviceApplicable =(Select cOUNT(ServiceID) from  AVL.TK_MAS_Service(NOLOCK) 
							where ServiceID in (1,4,5,6,7,8,10)  AND ServiceID=@ServiceID)
SET @ISTicketTypeApplicable=(sELECT cOUNT(TicketTypeMappingID)  FROM AVL.TK_MAP_TicketTypeMapping WHERE ProjectID=@ProjectID AND DebtConsidered='Y' AND TicketTypeMappingID=@TicketTypeID )

print @ISTicketTypeApplicable

IF  (@IsDebtEnabled ='Y' AND ((@IsCognizant=1) AND  (@IsserviceApplicable > 0)) OR (@ISTicketTypeApplicable > 0 AND @IsCognizant=0) )
BEGIN


DECLARE @ApplicationID  VARCHAR(MAX)

SET @ApplicationID =  (Select Top 1 ApplicationID from AVL.APP_MAS_ApplicationDetails(NOLOCK) where ApplicationID in 
(Select ApplicationID from AVL.APP_MAP_ApplicationProjectMapping(NOLOCK) where ProjectID = @ProjectID) and ApplicationName = @ApplicationName )

IF((@IsDDAutoClassified = 'Y')) --AND (@IsAutoClassified = 'N')) 
BEGIN


PRINT 'inside @IsDDAutoClassified=Y and @IsAutoClassified=N'

Select @ProjectID AS ProjectID ,@ApplicationID AS ApplicationID , @Causecode AS CausecodeID, @Resolutioncode AS ResolutioncodeID ,
 NULL AS DebtClassificationID, NULL AS AvoidableFlagID, NULL AS ResidualFlagID into #Tmp_DD

UPDATE TDF SET TDF.DebtClassificationID = DIC.DebtClassificationID, TDF.AvoidableFlagID = DIC.AvoidableFlagID,
TDF.ResidualFlagID = DIC.ResidualDebtID from [AVL].[Debt_MAS_ProjectDataDictionary] DIC Inner Join #Tmp_DD TDF
ON DIC.ProjectID = TDF.ProjectID AND DIC.ApplicationID = TDF.ApplicationID 
where DIC.CauseCodeID = @Causecode and DIC.ResolutionCodeID = @Resolutioncode

Select @DebtClassificationflag=isnull(DebtClassificationID,'0'),@AvoidableFlag= isnull(AvoidableFlagID,'0'), @ResidualFlag=isnull(ResidualFlagID,'0') from #Tmp_DD 

declare @countfordd int;

set @countfordd=(SELECT count(*) from #Tmp_DD )

Select DebtClassificationID, AvoidableFlagID, ResidualFlagID from #Tmp_DD 

if((@DebtClassificationflag='0' and @AvoidableFlag='0'AND @ResidualFlag='0') or (@DebtClassificationflag='' and @AvoidableFlag='' AND @ResidualFlag=''))
BEGIN
print 5
insert into [AVL].[TRN_DebtClassificationModeDetails]
--AVL.TRN_DebtClassificationModeDetails 
(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,NULL,NULL,NULL,NULL,null,NULL,1,0,@UserID,GETDATE(),5)
end
ELSE
begin
print 3
insert into [AVL].[TRN_DebtClassificationModeDetails]
-- AVL.TRN_DebtClassificationModeDetails 
(TimeTickerID,SystemDebtclassification,SystemAvoidableFlag,SystemResidualDebtFlag,
UserDebtClassificationFlag,UserAvoidableFlag,UserResidualDebtFlag,SourceForPattern,IsDeleted,CreatedBy,CreatedDate,DebtClassficationMode) 
 values(@TimeTickerID,@DebtClassificationflag,@AvoidableFlag,@ResidualFlag,NULL,null,NULL,1,0,@UserID,GETDATE(),3)
 end
END



END

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[AVL_DebtGetAutoClassifiedDebtFilds_DD] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  



END
