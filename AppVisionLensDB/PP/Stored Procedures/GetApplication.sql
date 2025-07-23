/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
   
CREATE PROCEDURE [PP].[GetApplication]  

@CustomerID varchar(250)

AS
BEGIN     
BEGIN TRY    
SET nocount ON;      

set @CustomerID = (Select ESA_AccountID from Avl.Customer where customerID = @CustomerID)

SELECT C.ESA_AccountID,C.CustomerID,C.CustomerName,
LOB.BusinessClusterMapID As LOB_BusinessClusterMapID,LOB.BusinessClusterID As LOB_BusinessClusterID ,
LOB.ParentBusinessClusterMapID As LOB_ParentBusinessClusterMapID,LOB.BusinessClusterBaseName AS LOB,
TRK.BusinessClusterMapID As TRK_BusinessClusterMapID,TRK.BusinessClusterID As TRK_BusinessClusterID ,
TRK.ParentBusinessClusterMapID As TRK_ParentBusinessClusterMapID,TRK.BusinessClusterBaseName AS TRACK,
APPGRP.BusinessClusterMapID As APPGRP_BusinessClusterMapID,APPGRP.BusinessClusterID As APPGRP_BusinessClusterID ,
APPGRP.ParentBusinessClusterMapID As APPGRP_ParentBusinessClusterMapID,APPGRP.BusinessClusterBaseName AS APPGROUP,
AD.ApplicationID, AD.ApplicationName,AD.ApplicationShortName
FROM AVL.Customer(NOLOCK) C
INNER JOIN AVL.BusinessCluster(NOLOCK) BC 
ON C.CustomerID=BC.CustomerID
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) LOB
ON BC.BusinessClusterID=LOB.BusinessClusterID
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) TRK ON TRK.ParentBusinessClusterMapID = LOB.BusinessClusterMapID 
AND  LOB.ParentBusinessClusterMapID IS NULL 
INNER JOIN AVL.BusinessClusterMapping (NOLOCK) APPGRP ON APPGRP.ParentBusinessClusterMapID = TRK.BusinessClusterMapID 
AND APPGRP.IsHavingSubBusinesss = 0
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON AD.SubBusinessClusterMapID=APPGRP.BusinessClusterMapID 
WHERE AD.IsActive=1 and ESA_AccountID =@CustomerID order by ApplicationName

 END TRY      
 BEGIN CATCH      
  
   DECLARE @ErrorMessage VARCHAR(MAX);    
  
   SELECT @ErrorMessage = ERROR_MESSAGE()    

   --INSERT Error        
   EXEC AVL_InsertError '[PP].[GetApplication] ', @ErrorMessage    
  
    
 END CATCH      
  
END
