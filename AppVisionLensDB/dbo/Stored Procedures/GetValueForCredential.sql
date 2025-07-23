
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[GetValueForCredential]
(
	@Name NVARCHAR(50),
	@Value NVARCHAR(100) Output
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--Open MasterKey
	OPEN MASTER KEY DECRYPTION BY PASSWORD = '1keyMa$tter1dD';
	--Open Symmetric key
	OPEN SYMMETRIC KEY symKeyDD DECRYPTION BY CERTIFICATE CertificateDDKey;

	SET @Value =(SELECT 
	CAST(DecryptByKey([Value]) as nvarchar(max)) as Credential
	FROM MAS.Credentials
	WHERE Name=@Name and IsDeleted=0)
	--Close Symmetric key
	CLOSE SYMMETRIC KEY symKeyDD
    --Close Master key
	CLOSE MASTER KEY

	SELECT @Value
END
