CREATE TYPE [AVL].[APP_INV_AppCatInScopeList] AS TABLE (
    [AppID]     BIGINT NOT NULL,
    [CatID]     BIGINT NULL,
    [IsDeleted] BIT    NULL);

