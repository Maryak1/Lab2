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
