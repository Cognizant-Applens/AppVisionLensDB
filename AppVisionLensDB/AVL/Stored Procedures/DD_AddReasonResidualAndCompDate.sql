/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--EXEC [AVL].[DD_AddReasonResidualAndCompDate] 149,154,251,249,4,2,2,89401,'687596',1,'23/01/2018'

CREATE PROCEDURE [AVL].[DD_AddReasonResidualAndCompDate]
(
@empIds int,
@applicationIds int,
@causeIds int, 
@resolutionIds int,
@debtclassiIds int,
@avoidIds int, 
@resiIds int,
@Projectid int,  
@employeeID varchar(100), 
@reasonResiValueId int ,
@compDateValue DATE
)
AS
BEGIN
DECLARE @Result NVARCHAR(100)
DECLARE @ExpectedCompletionDate date
IF(@compDateValue IS NOT NULL AND @compDateValue != '')
BEGIN
SET @ExpectedCompletionDate=convert(date, @compDateValue,102)
END
ELSE
BEGIN
SET @ExpectedCompletionDate=NULL
END

UPDATE AVL.Debt_MAS_ProjectDataDictionary SET ReasonForResidual=@reasonResiValueId ,ExpectedCompletionDate=@ExpectedCompletionDate,
ModifiedBy=@employeeID,ModifiedDate=GETDATE() WHERE ProjectID=@Projectid AND ApplicationID=@applicationIds AND ID=@empIds
AND CauseCodeID=@causeIds AND ResolutionCodeID=@resolutionIds AND DebtClassificationID=@debtclassiIds
SET @Result='Added Successfully'
SELECT @Result AS RESULT
END
