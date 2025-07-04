CREATE TABLE IF NOT EXISTS t_resume (
name varchar(200)
);

ALTER TABLE t_resume
ADD COLUMN surname varchar(200);

ALTER TABLE t_resume
ADD COLUMN birthday date;

ALTER TABLE t_resume
DROP COLUMN surname;

INSERT INTO t_resume (name, birthday)
VALUES ('Natalie', '04_03_2000');

ALTER TABLE t_resume
ADD COLUMN job varchar(200),
ADD COLUMN start_date date,
ADD COLUMN end_date date;

INSERT INTO t_resume (name, birthday, job, start_date, end_date)
VALUES ('Natalie', '2000-03-04', 'reporting', '2024-10-01', NULL);

UPDATE t_resume
SET end_date = '2025-09-01'
WHERE end_date IS NULL;

SELECT * FROM t_resume;
