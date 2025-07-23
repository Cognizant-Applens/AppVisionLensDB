CREATE TABLE [AVL].[ML_TRN_ErrorLog] (
    [ProjectId]    INT            NULL,
    [Step]         NVARCHAR (MAX) NULL,
    [ErrorMessage] NVARCHAR (MAX) NULL,
    [TimeStamp]    DATETIME       NULL,
    [UserID]       VARCHAR (250)  NULL
);

