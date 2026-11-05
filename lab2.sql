-- 1. Вывести информацию обо всех путях, задействованных сегодня для выезда трамваев
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


-- 2. Вывести номера трамваев, занимавших электрифицированные пути больше 1 месяца непрерывно в текущем году
SELECT DISTINCT
    ep.tram_number
FROM employment_paths ep
JOIN paths p
    ON ep.depot_number = p.depot_number
   AND ep.path_number = p.path_number
WHERE p.path_is_electrified = TRUE
  AND ep.date_and_time_start >= DATE_TRUNC('year', CURRENT_DATE)
  AND ep.date_and_time_start < DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year'
  AND ep.date_and_time_end IS NOT NULL
  AND ep.date_and_time_end - ep.date_and_time_start > INTERVAL '1 month';


-- 3. Создать таблицу, содержащую данные 1 запроса с указанием даты и времени выезда трамваев
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


-- 4. Добавить в созданную таблицу пути для ремонта, занимавшиеся по выходным
INSERT INTO tram_paths_29
SELECT DISTINCT
    p.*,
    ep.date_and_time_start,
    ep.date_and_time_end,
    ep.tram_number,
    ep.additional_information
FROM paths p
JOIN employment_paths ep
    ON p.depot_number = ep.depot_number
   AND p.path_number = ep.path_number
WHERE LOWER(p.purpose) LIKE '%ремонт%'
  AND EXTRACT(DOW FROM ep.date_and_time_start) IN (0, 6);


-- 5. В созданной таблице освободить все электрифицированные пути
UPDATE tram_paths_29
SET path_is_clear = TRUE
WHERE path_is_electrified = TRUE;


-- 6. Удалить из созданной таблицы все пути, длина которых содержит больше двух цифр в дробной части
DELETE FROM tram_paths_29
WHERE path_length IS NOT NULL
  AND LENGTH(SPLIT_PART(path_length::text, '.', 2)) > 2;


-- 7. Посчитать среднее время занятости каждого пути в текущем году
SELECT
    depot_number,
    path_number,
    AVG(date_and_time_end - date_and_time_start) AS avg_occupation_time
FROM employment_paths
WHERE date_and_time_start >= DATE_TRUNC('year', CURRENT_DATE)
  AND date_and_time_start < DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year'
GROUP BY depot_number, path_number
ORDER BY depot_number, path_number;
