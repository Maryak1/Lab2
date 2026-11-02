-- вывести информацию обо всех путях, задействованных сегодня для выезда трамваев.
SELECT
    p.*,
    ep.date_and_time_start,
    ep.date_and_time_end,
    ep.tram_number,
    ep.additional_information
FROM paths p
JOIN employment_paths ep
    ON p.depot_number = ep.depot_number
    AND p.path_number = ep.path_number
WHERE ep.date_and_time_start::date = CURRENT_DATE;
-- вывести номера трамваев, занимающих электрофицированные пути больше 1 месяца непрерывно в текущем году
SELECT DISTINCT
    ep.tram_number
FROM employment_paths ep
JOIN paths p
    ON ep.depot_number = p.depot_number
    AND ep.path_number = p.path_number
WHERE p.path_is_electrified = TRUE
    AND ep.date_and_time_start >= DATE_TRUNC('year', CURRENT_DATE)
    AND ep.date_and_time_start < DATE_TRUNC('year', CURRENT_DATE)
        + INTERVAL '1 year'
    AND ep.date_and_time_end IS NOT NULL
    AND ep.date_and_time_end - ep.date_and_time_start
        > INTERVAL '1 month';
-- создать таблицу, содержащую данные 1 запроса с указанием даты и времени выезда трамваев
DROP TABLE IF EXISTS tram_paths_29;

SELECT
    p.*,
    ep.date_and_time_start,
    ep.date_and_time_end,
    ep.tram_number,
    ep.additional_information
INTO tram_paths_29
FROM paths p
JOIN employment_paths ep
    ON p.depot_number = ep.depot_number
    AND p.path_number = ep.path_number
WHERE ep.date_and_time_start::date = CURRENT_DATE;
-- добавить в созданную таблицу пути для ремонта, занимавшиеся по выходным
INSERT INTO tram_paths_29
SELECT
    p.*,
    ep.date_and_time_start,
    ep.date_and_time_end,
    ep.tram_number,
    ep.additional_information
FROM paths p
JOIN employment_paths ep
    ON p.depot_number = ep.depot_number
    AND p.path_number = ep.path_number
WHERE p.purpose ILIKE '%ремонт%'
    AND EXTRACT(ISODOW FROM ep.date_and_time_start) IN (6, 7);
-- в созданной таблице освободить все электрофицированные пути.
UPDATE tram_paths_29
SET path_is_clear = TRUE
WHERE path_is_electrified = TRUE;
-- удалить из созданной таблицы все пути, длина которых содержитбольше двух цифр в дробной части
DELETE FROM tram_paths_29
WHERE path_length::numeric <>
      ROUND(path_length::numeric, 2);
-- посчитать среднее время занятости каждого пути в текущем году
