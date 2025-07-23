CREATE   PROCEDURE [RLE].[LP_GetUserName] --'674078'
(
@Employeeid NVARCHAR(50)
)
AS
BEGIN
 
 
SELECT DISTINCT TOP 1  AssociateName ,EA.Designation, EPA.Dept_Name AS DeptName
FROM ESA.Associates(NOLOCK) EA
JOIN [ESA].[ProjectAssociates](NOLOCK) EPA
ON EA.AssociateId = EPA.AssociateId
WHERE  EA.AssociateId = @Employeeid AND IsActive = 1
 
 
END
