CREATE TABLE professions(
    code_id INT PRIMARY KEY NOT NULL,
    name_prof VARCHAR(50) NOT NULL
);

CREATE TABLE uchastki(
    number_cex INT NOT NULL,
    number_uchastka INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    tab_number INT NOT NULL,
    PRIMARY KEY (number_cex, number_uchastka)
);

CREATE TABLE lichsostav(
    table_id INT PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    number_cex INT NOT NULL,
    number_uchastka INT NOT NULL,
    code INT NOT NULL,
    razryad INT NOT NULL CHECK(razryad>0 AND razryad<100),
    sem_poloz VARCHAR(20) NOT NULL DEFAULT 'не состоит в браке',
    familia VARCHAR(50) NOT NULL,
    FOREIGN KEY (code) REFERENCES professions (code_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (number_cex, number_uchastka) REFERENCES uchastki (number_cex, number_uchastka)
);

INSERT INTO professions (code_id, name_prof)
VALUES (1001, 'Профессия 1');
INSERT INTO professions (code_id, name_prof)
VALUES (1002, 'Профессия 2');
INSERT INTO professions (code_id, name_prof)
VALUES (1003, 'Профессия 3');
INSERT INTO professions (code_id, name_prof)
VALUES (1004, 'Профессия 4');
INSERT INTO professions (code_id, name_prof)
VALUES (1005, 'Профессия 5');
-- INSERT-запросы для таблицы uchastki
INSERT INTO uchastki (number_cex, number_uchastka, name, tab_number)
VALUES (1, 1, 'Участок 1', 101);
INSERT INTO uchastki (number_cex, number_uchastka, name, tab_number)
VALUES (2, 3, 'Участок 3', 102);
INSERT INTO uchastki (number_cex, number_uchastka, name, tab_number)
VALUES (1, 2, 'Участок 2', 103);
INSERT INTO uchastki (number_cex, number_uchastka, name, tab_number)
VALUES (3, 2, 'Участок 2', 104);
INSERT INTO uchastki (number_cex, number_uchastka, name, tab_number)
VALUES (2, 1, 'Участок 1', 105);

-- INSERT-запросы для таблицы lichsostav
INSERT INTO lichsostav (number_cex, number_uchastka, code, razryad, familia)
VALUES (1, 1, 1001, 5, 'Иванов');
INSERT INTO lichsostav (number_cex, number_uchastka, code, razryad, familia)
VALUES (2, 3, 1002, 3, 'Петров');
INSERT INTO lichsostav (number_cex, number_uchastka, code, razryad, familia)
VALUES (1, 2, 1003, 4, 'Сидоров');
INSERT INTO lichsostav (number_cex, number_uchastka, code, razryad, familia)
VALUES (3, 2, 1004, 6, 'Козлов');
INSERT INTO lichsostav (number_cex, number_uchastka, code, razryad, familia)
VALUES (2, 1, 1005, 5, 'Васильев');


SELECT * FROM uchastki;
SELECT * FROM professions;
SELECT * FROM lichsostav;

DELETE FROM professions WHERE code_id=1001;
SELECT * FROM professions;
SELECT * FROM lichsostav;

-- Создание функции "delete_from_lichsostav()"
CREATE OR REPLACE FUNCTION delete_from_lichsostav()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM lichsostav
    WHERE number_cex = OLD.number_cex AND number_uchastka = OLD.number_uchastka;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


-- Создание триггера на таблице "uchastki"
CREATE TRIGGER delete_uchastki
BEFORE DELETE ON uchastki
FOR EACH ROW
EXECUTE FUNCTION delete_from_lichsostav();


DELETE FROM uchastki WHERE number_uchastka=3;

SELECT * FROM uchastki;
SELECT * FROM lichsostav;


CREATE OR REPLACE FUNCTION update_razryad()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.razryad > 10 THEN
        NEW.razryad := 10;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_razryad_trigger
BEFORE INSERT OR UPDATE ON lichsostav
FOR EACH ROW
EXECUTE FUNCTION update_razryad();


INSERT INTO lichsostav (number_cex, number_uchastka, code, razryad, sem_poloz, familia)
VALUES (1, 1, 1003, 105, 'не состоит в браке', 'Иванов');

SELECT * FROM lichsostav;

CREATE OR REPLACE FUNCTION sred_razryad()
RETURNS numeric AS $$
BEGIN
    RETURN (
        SELECT ROUND(AVG(razryad)::numeric, 2) FROM lichsostav
    );
END;
$$ LANGUAGE plpgsql;

SELECT sred_razryad();

CREATE OR REPLACE FUNCTION get_uchastki()
RETURNS TABLE (
    number_cex INT,
    number_uchastka INT,
    name VARCHAR(50),
    tab_number INT
) AS $$
BEGIN
    RETURN QUERY (
        SELECT uchastki.number_cex, uchastki.number_uchastka, uchastki.name, uchastki.tab_number
        FROM uchastki
    );
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_uchastki();

CREATE OR REPLACE PROCEDURE insert_uchastok(
    number_cex_param INT,
    number_uchastka_param INT,
    name_param VARCHAR,
    tab_number_param INT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN
        INSERT INTO uchastki (number_cex, number_uchastka, name, tab_number)
        VALUES (number_cex_param, number_uchastka_param, name_param, tab_number_param);
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'Запись с ключом (%, %) уже существует', number_cex_param, number_uchastka_param;
    END;
END;
$$;

CALL insert_uchastok(1, 6, 'Участок 1', 106);

SELECT * FROM uchastki;
