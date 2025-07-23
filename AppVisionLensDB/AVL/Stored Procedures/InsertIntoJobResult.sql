


 
CREATE   PROCEDURE [AVL].[InsertIntoJobResult]
    @ID INT,
    @ModuleType VARCHAR(255),
    @SharedPath VARCHAR(500),
    @SharedPathType VARCHAR(100),
    @ProjectID INT = NULL,
    @EmployeeID INT = NULL,
    @Result VARCHAR(255) = NULL,
    @ErrorMessage VARCHAR(MAX) = NULL
AS
BEGIN
    -- Insert query
    INSERT INTO [AVL].[SharePointMigarationJobResult] (ID,  SharedPath, SharedPathType, ProjectID, EmployeeID, Result, ErrorMessage)
    VALUES (@ID,  @SharedPath, @SharedPathType, @ProjectID, @EmployeeID, @Result, @ErrorMessage);
    
END;
