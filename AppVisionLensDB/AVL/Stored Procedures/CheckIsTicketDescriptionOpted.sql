/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE AVL.CheckIsTicketDescriptionOpted 
(
@ProjectID varchar(50)
)
AS 
BEGIN

SELECT IsTicketDescriptionOpted as 'IsTicketDescriptionOpted',ProjectID as 'ProjectID'
	FROM [ML].[ConfigurationProgress] WHERE ProjectID=@ProjectID AND IsDeleted=0
	ORDER BY ID ASC
END
