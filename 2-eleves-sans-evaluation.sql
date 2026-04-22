-- =============================================================================
-- Requête 2 : Élèves actifs sans données d'évaluation
-- 'Dépistage précoce de la lecture / Early reading screening'
-- =============================================================================
WITH ctx AS (
    SELECT
        CTX_START_DATE
    FROM [DISTRICT_SCHOOL_YEAR_CONTEXT]
    WHERE CTX_OID = (SELECT ORG_CTX_OID_CURRENT FROM [ORGANIZATION])
),
depistage AS (
    SELECT DISTINCT ASM_STD_OID AS STD_OID
    FROM [STUDENT_ASSESSMENT]
    CROSS JOIN ctx
    WHERE ASM_DATE >= ctx.CTX_START_DATE
        AND ASM_GRADE_LEVEL_CODE IN ('SK', '01', '02')
        AND ASM_ASD_OID = 'asd00000000ERS' -- Dépistage précoce de la lecture / Early reading screening
)
SELECT
    SKL_SCHOOL_ID         AS [école],
    STD_GRADE_LEVEL       AS [niveau],
    STD_OID               AS [STD_OID],
    STD_NAME_VIEW         AS [élève],
    STD_ENROLLMENT_STATUS AS [statut]
FROM [STUDENT]
    INNER JOIN [SCHOOL] ON SKL_OID = STD_SKL_OID
WHERE STD_ENROLLMENT_STATUS = 'Active' -- Exclut PreReg
    AND STD_GRADE_LEVEL IN ('SK', '01', '02')
    AND STD_SKL_OID != 'SKL000OnSISOOB'
    AND NOT EXISTS (SELECT 1 FROM depistage WHERE depistage.STD_OID = STD_OID)
ORDER BY [école], [niveau], [élève];
