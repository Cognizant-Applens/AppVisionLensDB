/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[UpdateAutoClassificationDetails]
(
@APIRequestedTime VARCHAR(MAX)=NULL,
@APIRespondedTime VARCHAR(100)=NULL,
@AutoClassificationDate VARCHAR(100)=NULL,
@AutoClassificationDetailsID INT,
@AutoClassificationStatus VARCHAR(100)=NULL,
@CreatedBy VARCHAR(100)=NULL,
@CreatedDate VARCHAR(100)=NULL,
@DDAutoClassificationDate VARCHAR(100)=NULL,
@EmployeeID VARCHAR(100)=NULL,
@InputFileName VARCHAR(100)=NULL,
@IsAutoClassified VARCHAR(100)=NULL,
@ModifiedBy VARCHAR(100)=NULL,
@ModifiedDate VARCHAR(100)=NULL,
@OutputFileName VARCHAR(100)=NULL,
@ProjectID BIGINT=0,
@IsDDAutoClassified VARCHAR(100)=NULL,
@IsDDAutoClassifiedInfra VARCHAR(100)=NULL,
@DDAutoClassificationDateInfra VARCHAR(100)=NULL,
@IsAutoClassifiedInfra VARCHAR(100)=NULL,
@AutoClassificationDateInfra VARCHAR(100)=NULL,
@APIRequestedTimeInfra VARCHAR(MAX)=NULL,
@APIRespondedTimeInfra VARCHAR(100)=NULL,
@InputFileNameinfra VARCHAR(100)=NULL,
@OutputFileNameInfra VARCHAR(100)=NULL
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;	

UPDATE AVL.TK_ProjectForMLClassification
set
 APIRequestedTime=@APIRequestedTime ,
 APIRespondedTime=@APIRespondedTime,
AutoClassificationDate=@AutoClassificationDate,
AutoClassificationStatus =@AutoClassificationStatus,
CreatedBy =@CreatedBy,
CreatedDate =@CreatedDate,
DDAutoClassificationDate =@DDAutoClassificationDate,
EmployeeID=@EmployeeID ,
InputFileName=@InputFileName ,
IsAutoClassified=@IsAutoClassified ,
ModifiedBy=@ModifiedBy ,
ModifiedDate=@ModifiedDate ,
OutputFileName=@OutputFileName ,
ProjectID=@ProjectID ,
IsDDAutoClassified=@IsDDAutoClassified ,
IsAutoClassifiedInfra = 	 @IsAutoClassifiedInfra ,
IsDDAutoClassifiedInfra	 =  @IsDDAutoClassifiedInfra,
DDAutoClassificationDateInfra = @DDAutoClassificationDateInfra,
AutoClassificationDateInfra	=  @AutoClassificationDateInfra,
InputFileNameInfra    = @InputFileNameinfra,
OutputFileNameInfra   = @OutputFileNameInfra,
APIRequestedTimeInfra = @APIRequestedTimeInfra,
APIRespondedTimeInfra = @APIRespondedTimeInfra
WHERE AutoClassificationDetailsID=@AutoClassificationDetailsID

END TRY
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
  
		EXEC AVL_InsertError '[dbo].[UpdateAutoClassificationDetails]', @ErrorMessage,@projectID 
END CATCH
END
