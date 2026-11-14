-- =====================================================================
-- MANTENIMIENTO (no es una migración: el CLI no la ejecuta).
-- Repara texto con acentos dañados por una carga en la codificación equivocada
-- («PÃ©rez» -> «Pérez», «GuarniciÃ³n» -> «Guarnición», «CafÃ©» -> «Café»).
--
-- Cuándo usarla: si cargaste la semilla de la nube copiándola con
--   Get-Content ... -Raw | Set-Clipboard      (sin -Encoding UTF8)
-- Cómo: Supabase -> SQL Editor -> pega todo -> Run. Es seguro repetirla: solo toca
-- filas que contienen los caracteres dañados «Ã» o «Â».
-- =====================================================================

-- Se escribió UTF-8 pero se leyó como Windows-1252: se invierte esa conversión.
update public.platillo
   set nombre = convert_from(convert_to(nombre, 'WIN1252'), 'UTF8')
 where nombre ~ '[ÃÂ]';

update public.empleado
   set nombre = convert_from(convert_to(nombre, 'WIN1252'), 'UTF8')
 where nombre ~ '[ÃÂ]';

update public.cliente
   set nombre = convert_from(convert_to(nombre, 'WIN1252'), 'UTF8')
 where nombre ~ '[ÃÂ]';

-- Comprobación: debe devolver 0 filas.
select 'platillo' as tabla, nombre from public.platillo where nombre ~ '[ÃÂ]'
union all
select 'empleado', nombre from public.empleado where nombre ~ '[ÃÂ]'
union all
select 'cliente', nombre from public.cliente where nombre ~ '[ÃÂ]';
