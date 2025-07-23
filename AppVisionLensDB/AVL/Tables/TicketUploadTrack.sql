CREATE TABLE [AVL].[TicketUploadTrack] (
    [TicketUploadTrackID]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]                   BIGINT        NULL,
    [EmployeeID]                  VARCHAR (50)  NULL,
    [Mode]                        INT           NULL,
    [FileName]                    VARCHAR (MAX) NULL,
    [IsColumnMappingValidated]    BIT           NULL,
    [MndColValBeginTime]          DATETIME      NULL,
    [MndColValEndTime]            DATETIME      NULL,
    [NonMndColValBeginTime]       DATETIME      NULL,
    [NonMndColValEndTime]         DATETIME      NULL,
    [NullValUpdateBeginTime]      DATETIME      NULL,
    [NullValUpdateEndTime]        DATETIME      NULL,
    [MasterValuesUpdateBeginTime] DATETIME      NULL,
    [MasterValuesUpdateEndTime]   DATETIME      NULL,
    [BLErrorMessage]              VARCHAR (MAX) NULL,
    [DBErrorMessage]              VARCHAR (MAX) NULL,
    [TotalRecordsInExcel]         INT           NULL,
    [TotalValidRecords]           INT           NULL,
    [TotalDuplicateRecords]       INT           NULL,
    [TotalRejectedRecords]        INT           NULL,
    [IsActive]                    BIT           NULL,
    [CreatedBy]                   VARCHAR (50)  NULL,
    [CreatedDate]                 DATETIME      NULL,
    [ModifiedBy]                  VARCHAR (50)  NULL,
    [ModifiedDate]                DATETIME      NULL,
    [StoredProcedureStartTime]    DATETIME      NULL,
    [StoredProcedureEndTime]      DATETIME      NULL
);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex5]
    ON [AVL].[TicketUploadTrack]([TicketUploadTrackID] ASC);

