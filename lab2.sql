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
-- добавить в созданную таблицу пути для ремонта, занимавшиеся по выходным
 INSERT INTO public.tram_paths_29
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
FROM public.paths p
JOIN public.employment_paths ep
    ON p.depot_number = ep.depot_number
    AND p.path_number = ep.path_number
WHERE p.purpose ILIKE '%ремонт%'
    AND EXTRACT(ISODOW FROM ep.date_and_time_start) IN (6, 7);
INSERT INTO public.tram_paths_29 (
    depot_number,
    path_number,
    purpose,
    path_length,
    path_is_clear,
    path_is_electrified,
    date_and_time_start,
    date_and_time_end,
    tram_number,
    additional_information
)
VALUES (
    2,
    202,
    'Ремонтный маршрут',
    15,
    TRUE,
    FALSE,
    '2026-10-31 05:00:00+03',
    '2026-10-31 05:10:00+03',
    8002,
    'Возврат в депо после ремонта'
);
-- в созданной таблице освободить все электрофицированные пути.
UPDATE public.tram_paths_29
SET
    path_is_clear = TRUE,
    tram_number = NULL,
    date_and_time_start = NULL,
    date_and_time_end = NULL,
    additional_information = NULL
WHERE path_is_electrified = TRUE;
