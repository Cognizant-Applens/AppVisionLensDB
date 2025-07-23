/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[GETDROPDOWNDATA] @mode VARCHAR(100)    
        ,@lookup VARCHAR(1000) = NULL    
        ,@BUIDList VARCHAR(max) = NULL    
AS    
BEGIN    
Declare @IsANumeric char;  
        BEGIN TRY 
		SET NOCOUNT ON
		
		
               CREATE TABLE #Accomaster (    
                       EmployeeID NVARCHAR(100) NOT NULL    
                       ,AssociateName NVARCHAR(500) NOT NULL    
                       )    
    
               INSERT INTO #Accomaster (    
                       EmployeeID    
                       ,AssociateName    
                       ) (    
                       SELECT AssociateID    
                       ,AssociateName FROM [ESA].[Associates] With (NOLOCK)   
                       )    
    
               IF (@mode = 'RoleData')    
               BEGIN    
                       SELECT RLM.RoleId    
                               ,RLM.RoleName    
                               ,ALM.AccessLevel    
                       FROM avl.rolemaster RLM With (NOLOCK)   
                       LEFT JOIN avl.AccessLevelMapping ALM (NOLOCK) ON ALM.RoleName = RLM.RoleName    
                       WHERE RLM.Isactive = 1    
                               AND RLM.roleid != 8    
                       ORDER BY RoleName    
               END    
    
               IF (@mode = 'BUData')    
               BEGIN    
                       SELECT BUID    
                               ,BUName    
                       FROM avl.businessunit With (NOLOCK)   
                       WHERE isdeleted = 0    
                               AND ishorizontal = 'N'    
                       ORDER BY BUName    
               END    
    
               IF (@mode = 'CompentencyData')    
               BEGIN    
                       SELECT BUID    
                               ,BUName    
                       FROM avl.businessunit  With (NOLOCK)  
                       WHERE isdeleted = 0    
                               AND ishorizontal = 'Y'    
                       ORDER BY BUName    
               END    
    
               IF (@mode = 'AccountData')    
               BEGIN    
                       SELECT CustomerID    
                               ,CustomerName    
                               ,BUID  
          ,ESA_AccountID   
                       FROM avl.customer With (NOLOCK)   
                       WHERE isdeleted = 0    
               END    
    
               IF (@mode = 'ProjectData')    
               BEGIN    
                       SELECT ProjectID    
                               ,ProjectName    
                               ,CustomerID  
          ,EsaProjectID AS ESA_ProjectID  
                       FROM avl.MAS_ProjectMaster With (NOLOCK)   
                       WHERE isdeleted = 0    
               END    
    
               IF (@mode = 'AssociateData')    
               BEGIN    
                       SELECT DISTINCT urm.EmployeeID    
                               ,CONCAT (    
                                      urm.EmployeeID    
                                      ,'-'    
                                      ,acc.AssociateName    
                                      ) AS AssociateName    
                       FROM avl.UserRoleMapping urm  With (NOLOCK)   
                       INNER JOIN #Accomaster acc (NOLOCK) ON urm.EmployeeID = acc.EmployeeID    
                       ORDER BY Associatename    
               END    
    
               IF (@mode = 'SearchAssociateData')    
               BEGIN
			     Select @IsANumeric = ISNUMERIC(@lookup);
			   IF (@IsANumeric = 1)
			   BEGIN
                       SELECT DISTINCT urm.EmployeeID    
                               ,CONCAT (    
                                      urm.EmployeeID    
                                      ,'-'    
                                      ,acc.AssociateName    
                                      ) AS AssociateName    
                       FROM avl.UserRoleMapping urm With (NOLOCK)   
                       INNER JOIN #Accomaster acc (NOLOCK) ON urm.EmployeeID = acc.EmployeeID    
                       WHERE CONCAT (    
                                      urm.EmployeeID    
                                      ,'-'    
                                      ,acc.AssociateName    
                                      ) LIKE '%' + @lookup + '%'    
                       ORDER BY Associatename   
					   END 
               END    
    
               IF (@mode = 'abc')    
               BEGIN    
                       SELECT BU.BUID    
              ,BU.BUName    
                               ,customer.CustomerID    
                               ,CustomerName    
                               ,project.ProjectID    
                               ,project.ProjectName    
                       FROM AVL.BusinessUnit BU With (NOLOCK)   
                       INNER JOIN AVL.Customer customer (NOLOCK) ON BU.BUID = customer.BUID    
                       INNER JOIN AVL.MAS_ProjectMaster project (NOLOCK) ON customer.CustomerID = project.CustomerID    
                       WHERE BU.BUID IN (    
                                      SELECT CAST(Item AS INT)    
                                      FROM dbo.SplitString(@BUIDList, ',')    
                                      )    
               END    
    
               DROP TABLE #Accomaster
			   SET NOCOUNT OFF
        END TRY    
    
        BEGIN CATCH    
               DECLARE @ErrorMessage VARCHAR(MAX);    
    
               SELECT @ErrorMessage = ERROR_MESSAGE()    
    
               --INSERT Error      
               EXEC AVL_InsertError 'AVL.GETDROPDOWNDATA'    
                       ,@ErrorMessage    
                       ,0    
                       ,0    
        END CATCH    
END
