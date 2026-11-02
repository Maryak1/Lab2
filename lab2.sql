-- вывести информацию обо всех путях, задействованных сегодня для выезда трамваев.
select * 
from public.employment_paths 
where date_and_time_start::date = current_date;
-- вывести номера трамваев, занимающих электрофицированные пути больше 1 месяца непрерывно в текущем году
SELECT DISTINCT ep.tram_number
FROM employment_paths ep
JOIN paths p
ON ep.depot_number = p.depot_number
AND ep.path_number = p.path_number
WHERE p.path_is_electrified = TRUE
AND ep.date_and_time_start >= DATE_TRUNC('year', CURRENT_DATE)
AND ep.date_and_time_end - ep.date_and_time_start > INTERVAL '1 month';
-- создать таблицу, содержащую данные 1 запроса с указанием даты и времени выезда трамваев
DROP TABLE IF EXISTS tram_paths_29;

SELECT
    p.depot_number,
    p.path_number,
    p.purpose,
    p.path_length,
    p.path_is_clear,
    p.path_is_electrified,
    ep.date_and_time_start,
    ep.date_and_time_end,
    ep.tram_number,
    ep.additional_information
INTO tram_paths_29
FROM public.paths p
JOIN public.employment_paths ep
    ON p.depot_number = ep.depot_number
    AND p.path_number = ep.path_number
WHERE ep.date_and_time_start::date = CURRENT_DATE;
