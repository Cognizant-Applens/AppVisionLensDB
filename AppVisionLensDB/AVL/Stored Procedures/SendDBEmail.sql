
/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [AVL].[SendDBEmail](
    @To NVARCHAR(MAX),
    @From NVARCHAR(MAX),
    @CC NVARCHAR(MAX) = NULL,
	@BCC NVARCHAR(MAX) = NULL,
    @Subject NVARCHAR(MAX),
    @Body NVARCHAR(MAX),
	@AttachmentName NVARCHAR(MAX) = NULL,
	@IsAttachmentPresent bit = 0,
	@AttachmentLink NVARCHAR(MAX) = NULL

)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Insert email details into AppLensMail table
        INSERT INTO [WISELOGICAPP].[WiseLogicApps].[dbo].[AppLensMail] (
            [To],
            [From],
            [CC],
			[BCC],
            [MailBody],
            [Subject],
            [Ismailsent],
            [CreatedDate],
            [CreatedBy],
            [IsAttachmentPresent],
            [AttachmentName],
            [AttachmentLink],
            [ContainerName],
            [RecipientDetails]
        )
        VALUES (
            @To,
            @From,
            @CC,
			@BCC,
            @Body,
            @Subject,
            0, -- Assuming 0 means not sent
            GETDATE(),
            NULL, -- Assuming CreatedBy is not provided
            @IsAttachmentPresent, -- Assuming no attachment
            @AttachmentName,
            @AttachmentLink,
            NULL,
            NULL
        );
    END TRY
BEGIN CATCH  
       DECLARE @errorMessage VARCHAR(MAX);  
       SELECT @errorMessage = ERROR_MESSAGE()    
         --INSERT Error      
         EXEC AVL_InsertError 'avl.SendDBEmail',@errorMessage,'',0  
       END CATCH  
End