/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[BCS_ColumnMappingAvailable]
@userid INT,
@esaprojectid BIGINT
AS
if EXISTS(select ColumnMappingAvailable,DataMappingAvailable,IsDeleted from BCS.MAS_TicketTemplate where ESAProjectID=@esaprojectid )
BEGIN
UPDATE BCS.MAS_TicketTemplate SET ColumnMappingAvailable='Y', IsDeleted = 1 where UserID=@userid and ESAProjectID=@esaprojectid
END
ELSE
BEGIN
	INSERT INTO BCS.MAS_TicketTemplate values (@userid,@esaprojectid,'Y','N',0,GETDATE())
END