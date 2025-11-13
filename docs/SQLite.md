## SQLite

- Structured Query Language 
  - Daten speichern, abzurufen und zu verwalten
  - relationale Datenbanken

- Daten werden in Tabellen gespeichert 
  - Spalten -> Datenfelder
  - Zeilen -> einzelne Datensätze 


### Tabelle: `tasks`

| id | title              | done |
|---:|--------------------|-----:|
| 1  | Einkaufen          | 0    |
| 2  | Wäsche waschen     | 1    |
| 3  | Flutter üben       | 0    |

- done: 0 = false, 1 = true

---

### Basisabfragen

**Alle Spalten**
```sql
SELECT * FROM tasks ORDER BY id ASC;
```

**Output**

| id | title            | done |
|---:|------------------|-----:|
| 1  | Einkaufen        | 0    |
| 2  | Wäsche waschen   | 1    |
| 3  | Flutter üben     | 0    |

**Bestimmte Spalten + Filter + Sortierung + Limit**
```sql
SELECT id, title
FROM tasks
WHERE done = 0
ORDER BY id DESC
LIMIT 20 OFFSET 0;
```

**Output**

| id | title        |
|---:|---------------|
| 3  | Flutter üben |
| 1  | Einkaufen    |

**Titel mit Muster (LIKE)**
```sql
SELECT id, title
FROM tasks
WHERE title LIKE '%Flutter%';
```

**Output**

| id | title        |
|---:|---------------|
| 3  | Flutter üben |

---

### Bedingungen & Muster

**Mehrere Bedingungen**
```sql
SELECT id, title, done
FROM tasks
WHERE done = 0 AND title LIKE 'Eink%';
```

**Output**

| id | title     | done |
|---:|-----------|-----:|
| 1  | Einkaufen | 0    |

**Boolean lesbar machen (CASE)**
```sql
SELECT
  id,
  title,
  CASE done WHEN 1 THEN 'true' ELSE 'false' END AS done_label
FROM tasks
ORDER BY id;
```

**Output**

| id | title            | done_label |
|---:|------------------|------------|
| 1  | Einkaufen        | false      |
| 2  | Wäsche waschen   | true       |
| 3  | Flutter üben     | false      |

---

### Aggregation & Statistiken

**Anzahl aller/erledigter/offener Tasks**
```sql
SELECT
  COUNT(*)                                  AS total,
  SUM(CASE WHEN done = 1 THEN 1 ELSE 0 END) AS completed,
  SUM(CASE WHEN done = 0 THEN 1 ELSE 0 END) AS open
FROM tasks;
```

**Output**

| total | completed | open |
|------:|----------:|-----:|
| 3     | 1         | 2    |

**Gruppiert nach Status**
```sql
SELECT done, COUNT(*) AS cnt
FROM tasks
GROUP BY done
ORDER BY done;
```

**Output**

| done | cnt |
|-----:|----:|
| 0    | 2   |
| 1    | 1   |

---

###  Schreiben / Ändern / Löschen

**Einfügen**
```sql
INSERT INTO tasks (title, done) VALUES ('Neue Aufgabe', 0);
```

**Output**

```
-- 1 row affected
```

Resultierender Tabellenzustand (Beispiel, ausgehend von der Ausgangstabelle oben):

| id | title            | done |
|---:|------------------|-----:|
| 1  | Einkaufen        | 0    |
| 2  | Wäsche waschen   | 1    |
| 3  | Flutter üben     | 0    |
| 4  | Neue Aufgabe     | 0    |

**Mehrere Inserts in einer Transaktion**
```sql
BEGIN;
INSERT INTO tasks (title, done) VALUES ('Task A', 0);
INSERT INTO tasks (title, done) VALUES ('Task B', 1);
COMMIT;
```

**Output**

```
-- 2 rows affected
```

Resultierender Tabellenzustand (Beispiel):

| id | title            | done |
|---:|------------------|-----:|
| 1  | Einkaufen        | 0    |
| 2  | Wäsche waschen   | 1    |
| 3  | Flutter üben     | 0    |
| 4  | Task A           | 0    |
| 5  | Task B           | 1    |

**Update (als erledigt markieren)**
```sql
UPDATE tasks
SET done = 1
WHERE id = 3;
```

**Output**

```
-- 1 row affected
```

Resultierender Tabellenzustand (Beispiel):

| id | title            | done |
|---:|------------------|-----:|
| 1  | Einkaufen        | 0    |
| 2  | Wäsche waschen   | 1    |
| 3  | Flutter üben     | 1    |

**Toggle (0→1 bzw. 1→0) – SQLite‑Kurzform**
```sql
UPDATE tasks
SET done = 1 - done
WHERE id = 2;
```

**Output**

```
-- 1 row affected
```

Resultierender Tabellenzustand (Beispiel):

| id | title            | done |
|---:|------------------|-----:|
| 1  | Einkaufen        | 0    |
| 2  | Wäsche waschen   | 0    |
| 3  | Flutter üben     | 0    |

**Delete (eine Aufgabe)**
```sql
DELETE FROM tasks
WHERE id = 1;
```

**Output**

```
-- 1 row affected
```

Resultierender Tabellenzustand (Beispiel):

| id | title            | done |
|---:|------------------|-----:|
| 2  | Wäsche waschen   | 1    |
| 3  | Flutter üben     | 0    |

**Alle löschen**
```sql
DELETE FROM tasks;
```

**Output**

```
-- N rows affected (alle Zeilen gelöscht)
```

Resultierender Tabellenzustand:

| id | title | done |
|---:|-------|-----:|



## [sqflite](https://pub.dev/packages/sqflite)
- **Öffnen/Erstellen der DB**
  - Datei liegt im App‑Dokumentenordner (`getApplicationDocumentsDirectory()`).
  - `openDatabase(path, version: 1, onCreate: …)` legt `tasks` an:
    ```sql
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      done INTEGER NOT NULL
    )
    ```

- **CRUD‑API**
  - Insert: `db.insert('tasks', {'title': '...', 'done': 0})`
  - Read: `db.query('tasks', orderBy: 'id DESC')`
  - Update: `db.update('tasks', {'done': 1}, where: 'id = ?', whereArgs: [id])`
  - Delete: `db.delete('tasks', where: 'id = ?', whereArgs: [id])`




