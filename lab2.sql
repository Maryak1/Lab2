select * 
from public.employment_paths 
where date_and_time_start::date = current_date;
