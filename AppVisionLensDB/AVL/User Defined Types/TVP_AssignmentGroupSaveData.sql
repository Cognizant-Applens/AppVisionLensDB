CREATE TYPE [AVL].[TVP_AssignmentGroupSaveData] AS TABLE (
    [AssignmentGroupMapID] BIGINT         NOT NULL,
    [AssignmentGroup]      NVARCHAR (200) NOT NULL,
    [CategoryID]           INT            NOT NULL,
    [SupportTypeID]        INT            NULL,
    [IsBoTGroup]           INT            NULL);

