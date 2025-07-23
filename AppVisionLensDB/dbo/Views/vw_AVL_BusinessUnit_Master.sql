/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[vw_AVL_BusinessUnit_Master]
AS 

	SELECT [BUID]			[MBUId],
		   [BUName],
		   [BUCode]			[BUPracticeCode],
		   [IsHorizontal],
		   [IsDeleted],
		   [CreatedBy],
		   [CreatedDate],
		   [ModifiedBy],
		   [ModifiedDate]
	FROM [AVL].[BusinessUnit]
