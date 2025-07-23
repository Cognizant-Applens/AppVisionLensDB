CREATE TYPE [dbo].[TVP_UpdateAttributeMasterDetails] AS TABLE (
    [ServiceID]     INT           NULL,
    [ServiceName]   VARCHAR (100) NULL,
    [AttributeID]   INT           NULL,
    [AttributeName] VARCHAR (100) NULL,
    [StatusID]      INT           NULL,
    [StatusName]    VARCHAR (100) NULL,
    [IsMandatory]   CHAR (1)      NULL,
    [ProjectID]     INT           NULL,
    [UserID]        VARCHAR (100) NULL);

