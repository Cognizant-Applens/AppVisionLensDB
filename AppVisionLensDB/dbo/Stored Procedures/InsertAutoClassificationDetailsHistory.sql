/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[InsertAutoClassificationDetailsHistory]
(
@AutoClassificationDetailsHistoryID INT,
@Remarks VARCHAR(MAX),
@CreatedBy VARCHAR(100),
@CreatedDate DATETIME
)
AS
BEGIN
INSERT INTO [dbo].[AutoClassificationDetailsHistory]
           ([AutoClassificationDetailsID]
           ,[Remarks]
           ,[CreatedBy]
           ,[CreatedDate]
       )
     VALUES
         (@AutoClassificationDetailsHistoryID,
		 @Remarks,
		 @CreatedBy,
		 @CreatedDate
		 )
END
