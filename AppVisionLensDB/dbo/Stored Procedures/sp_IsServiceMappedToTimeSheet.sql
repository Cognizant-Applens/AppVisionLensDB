/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[sp_IsServiceMappedToTimeSheet]  
    @ServiceId VARCHAR(MAX) ,        
    @Projectid INT        
AS         
    BEGIN                 
  SET NOCOUNT ON;   
 SELECT CASE WHEN (EXISTS (SELECT 1 from AVL.TM_TRN_TimesheetDetail TSD (NOLOCK)    
     where ProjectId = @Projectid and     
     TSD.ServiceId IN (select * from dbo.Split(@ServiceId, ','))))     
     THEN 1   
     ELSE 0  
     END AS IsServiceMappedToTimeSheet    
  SET NOCOUNT OFF;    
    END
