-- =============================================================
-- STAGING TABLES DDL - SQL SERVER
-- Generated from: dattes3_with_produit.xlsx, ho1.xlsx, prod_div2_final.xlsx
-- Separator: pipe (|)
-- Decimal: dot (.)
-- All columns NVARCHAR for maximum load flexibility
-- =============================================================

USE STAGING_E;
GO

-- -------------------------------------------------------------
-- 1. STG_DATTES3_WITH_PRODUIT
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.stg_dattes3_with_produit', 'U') IS NOT NULL
    DROP TABLE dbo.stg_dattes3_with_produit;
GO

CREATE TABLE dbo.stg_dattes3_with_produit (
    occ                 NVARCHAR(50)   NULL,
    date_exportation    NVARCHAR(50)   NULL,
    pays_exportation    NVARCHAR(100)  NULL,
    quantite            NVARCHAR(50)   NULL,
    pu                  NVARCHAR(50)   NULL,
    pt                  NVARCHAR(50)   NULL,
    eq_dt               NVARCHAR(50)   NULL,
    eq_eu               NVARCHAR(50)   NULL,
    devise              NVARCHAR(50)   NULL,
    produit             NVARCHAR(255)  NULL,

    -- Audit columns
    stg_loaded_at       DATETIME2      NOT NULL DEFAULT GETDATE(),
    stg_source_file     NVARCHAR(255)  NULL DEFAULT 'dattes3_with_produit.csv'
);
GO

-- -------------------------------------------------------------
-- 2. STG_HO1
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.stg_ho1', 'U') IS NOT NULL
    DROP TABLE dbo.stg_ho1;
GO

CREATE TABLE dbo.stg_ho1 (
    occ                 NVARCHAR(50)   NULL,
    date_exportation    NVARCHAR(50)   NULL,
    pays_exportation    NVARCHAR(100)  NULL,
    quantite            NVARCHAR(50)   NULL,
    pu                  NVARCHAR(50)   NULL,
    pt                  NVARCHAR(50)   NULL,
    devise              NVARCHAR(50)   NULL,
    eq_eu               NVARCHAR(50)   NULL,
    eq_dt               NVARCHAR(50)   NULL,
    produit             NVARCHAR(255)  NULL,

    -- Audit columns
    stg_loaded_at       DATETIME2      NOT NULL DEFAULT GETDATE(),
    stg_source_file     NVARCHAR(255)  NULL DEFAULT 'ho1.csv'
);
GO

-- -------------------------------------------------------------
-- 3. STG_PROD_DIV2_FINAL
-- -------------------------------------------------------------
IF OBJECT_ID('dbo.stg_prod_div2_final', 'U') IS NOT NULL
    DROP TABLE dbo.stg_prod_div2_final;
GO

CREATE TABLE dbo.stg_prod_div2_final (
    occ                 NVARCHAR(50)   NULL,
    date_exportation    NVARCHAR(50)   NULL,
    devise              NVARCHAR(50)   NULL,
    eq_dt               NVARCHAR(50)   NULL,
    eq_eu               NVARCHAR(50)   NULL,
    pt                  NVARCHAR(50)   NULL,
    pu                  NVARCHAR(50)   NULL,
    pays_exportation    NVARCHAR(100)  NULL,
    quantite            NVARCHAR(50)   NULL,
    produit             NVARCHAR(255)  NULL,

    -- Audit columns
    stg_loaded_at       DATETIME2      NOT NULL DEFAULT GETDATE(),
    stg_source_file     NVARCHAR(255)  NULL DEFAULT 'prod_div2_final.csv'
);
GO

-- =============================================================
-- BULK INSERT COMMANDS
-- =============================================================

-- BULK INSERT dbo.stg_dattes3_with_produit
-- FROM 'C:\path\to\dattes3_with_produit.csv'
-- WITH (
--     FIELDTERMINATOR = '|',
--     ROWTERMINATOR   = '\n',
--     FIRSTROW        = 2,
--     CODEPAGE        = '65001',
--     TABLOCK
-- );

-- BULK INSERT dbo.stg_ho1
-- FROM 'C:\path\to\ho1.csv'
-- WITH (
--     FIELDTERMINATOR = '|',
--     ROWTERMINATOR   = '\n',
--     FIRSTROW        = 2,
--     CODEPAGE        = '65001',
--     TABLOCK
-- );

-- BULK INSERT dbo.stg_prod_div2_final
-- FROM 'C:\path\to\prod_div2_final.csv'
-- WITH (
--     FIELDTERMINATOR = '|',
--     ROWTERMINATOR   = '\n',
--     FIRSTROW        = 2,
--     CODEPAGE        = '65001',
--     TABLOCK
-- );