# Dépistage précoce de la lecture

Requêtes SQL pour le suivi du programme de **dépistage précoce de la lecture** (Early Reading Screening) dans le système Aspen. Ces requêtes ciblent les élèves des niveaux maternelle (SK), 1re et 2e année, et permettent d'identifier les anomalies de saisie dans les évaluations.

---

## Contexte

Les évaluations sont divisées en deux périodes au cours de l'année scolaire :

| Période | Plage de dates |
|---|---|
| **Hiver** | 1er septembre – 31 décembre |
| **Printemps** | 1er janvier – fin d'année scolaire |

L'année scolaire courante est déterminée dynamiquement à partir de la table `DISTRICT_SCHOOL_YEAR_CONTEXT`, ce qui évite d'avoir à modifier les requêtes chaque année.

---

## Colonnes retournées

| Colonne | Champ source | Valeurs |
|---|---|---|
| `école` | `SKL_SCHOOL_ID` | Identifiant de l'école |
| `niveau` | `ASM_GRADE_LEVEL_CODE` / `STD_GRADE_LEVEL` | `SK`, `01`, `02` |
| `STD_OID` | `ASM_STD_OID` / `STD_OID` | Identifiant unique de l'élève |
| `élève` | `STD_NAME_VIEW` | Nom complet de l'élève |
| `date` | `ASM_DATE` | Date de l'évaluation |
| `complète` | `ASM_FIELDA_001` | `0` = Non, `1` = Oui, `2` = S.O. |
| `norme_atteinte` | `ASM_FIELDA_002` | `0` = Non, `1` = Oui |
| `hiver` | `ASM_FIELDA_072` | `0` = Non, `1` = Oui |
| `printemps` | `ASM_FIELDA_073` | `0` = Non, `1` = Oui |

---

## Requêtes

### [`1-bulletins-non-coches.sql`](1-bulletins-non-coches.sql) — Bulletins non cochés (Hiver & Printemps)

Retourne les évaluations complétées où la case du bulletin de la période correspondante (`hiver` ou `printemps`) devrait être cochée **Oui**, mais ne l'est pas.

Une colonne `période` indique si l'évaluation appartient à la période **Hiver** ou **Printemps**.

### [`2-eleves-sans-evaluation.sql`](2-eleves-sans-evaluation.sql) — Élèves actifs sans évaluation

Retourne les élèves actifs (statut `Active`) des niveaux SK, 01 et 02 pour lesquels **aucune entrée** d'évaluation de dépistage précoce de la lecture n'existe pour l'année scolaire courante.

> L'école `SKL000OnSISOOB` est exclue des résultats.

### [`3-norme-atteinte-so-manquant.sql`](3-norme-atteinte-so-manquant.sql) — Norme atteinte en Hiver, S.O. manquant au Printemps

Retourne les élèves qui ont **atteint la norme** lors de l'évaluation d'hiver, mais dont l'évaluation de printemps n'est **pas marquée S.O.** (`complète <> '2'`), alors qu'elle devrait l'être.

---

## Utilisation

Les requêtes sont indépendantes et peuvent être exécutées séparément dans **SQL Server Management Studio** ou tout autre outil compatible T-SQL. Chaque fichier contient ses propres CTEs (`ctx`, `depistage`) et n'a pas besoin de configuration préalable.

---

## Tables utilisées

| Table | Description |
|---|---|
| `STUDENT_ASSESSMENT` | Évaluations des élèves |
| `STUDENT` | Informations sur les élèves |
| `SCHOOL` | Informations sur les écoles |
| `DISTRICT_SCHOOL_YEAR_CONTEXT` | Contexte de l'année scolaire courante |
| `ORGANIZATION` | Paramètres de l'organisation (année courante) |
