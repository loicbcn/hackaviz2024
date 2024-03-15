select ville, count(*) nb, 
min(least(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) min_pas_cher,
max(least(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) max_pas_cher,
min(greatest(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) min_cher,
max(greatest(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) max_cher,
sum(least(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e))/count(*) moy_pas_cher,
sum(greatest(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e))/count(*) moy_cher,
sum(
	coalesce(categorie_first, 0) + coalesce(categorie_a,0) + coalesce(categorie_b, 0) 
	+ coalesce(categorie_c,0) + coalesce(categorie_d, 0) + coalesce(categorie_e_plus, 0) + coalesce(categorie_e,0)
) tot_prix
from data.paris
where enjeu = 'Médailles' and (categorie_first is not null
or categorie_a is not null
or categorie_b is not null
or categorie_c is not null
or categorie_d is not null
or categorie_e_plus is not null
or categorie_e is not null)
group by ville
order by tot_prix

select coalesce(categorie_first, 0) + coalesce(categorie_a,0) + coalesce(categorie_b, 0) 
+ coalesce(categorie_c,0) + coalesce(categorie_d, 0) + coalesce(categorie_e_plus, 0) + coalesce(categorie_e,0) 
from data.paris

select phase, count(*) nb from data.paris where enjeu = 'Médailles' group by phase

select *  
from data.paris
where jeux = 'Paralympiques' and discipline = 'Para Athlétisme'

select jeux, discipline, session, genre, count(*) nb, array_agg(distinct enjeu) enjeu, min(debut), max(fin)
from data.paris
group by jeux, discipline, "session", genre 
order by jeux, discipline, session, genre

-- Par sessions
select session, max(jeux||'-'||discipline) , count(distinct genre) nbgenre, count(*) nb, 
round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy, array_agg(distinct ville) ville,
max(capacite) capacite
from data.paris
where prix_moyen is not null and discipline != 'Cérémonie' and enjeu = 'Médailles' and jeux = 'Olympiques' 
group by session
order by nb desc, nbgenre desc

select session, max(jeux||'-'||discipline) , count(distinct genre) nbgenre, count(*) nb, 
round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy, array_agg(distinct ville) ville,
max(capacite) capacite
from data.paris
where prix_moyen is not null and discipline != 'Cérémonie' and enjeu != 'Médailles' and jeux = 'Olympiques' 
group by session
order by nb desc, nbgenre desc

with datasmed as(
	select discipline, 1 as has_medal, round(avg(prix_moyen)) prix_moy, round(avg(capacite)) capa_moy, count(distinct session) sessions
	from data.paris 
	where discipline != 'Cérémonie' and jeux = 'Olympiques' and prix_moyen is not null and enjeu = 'Médailles'
	group by discipline 
), datasnomed as(
	select discipline, 0 as has_medal, round(avg(prix_moyen)) prix_moy, round(avg(capacite)) capa_moy, count(distinct session) sessions
	from data.paris 
	where discipline != 'Cérémonie' and jeux = 'Olympiques' and prix_moyen is not null and enjeu != 'Médailles'
	group by discipline 
)
select discipline, concat(discipline, ' - ',  prix_moy, '€<br>', 'Sessions:', sessions, '<br>Places moy: ', capa_moy) labels, 
has_medal, prix_moy, sessions,  round(capa_moy/1000) capa_moy, sessions*capa_moy capa, capa_moy capa_moy_full
from (
select * from datasmed
union
select * from datasnomed
) d order by prix_moy desc

-----------------------------------------

-- Epreuves par jeux discipline et genre -> prix 
select 
jeux, discipline, genre, 
min(debut) debut, max(fin) fin,
min(least(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) min_pas_cher,
max(least(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) max_pas_cher,
min(greatest(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) min_cher,
max(greatest(categorie_first,categorie_a,categorie_b,categorie_c,categorie_d,categorie_e_plus,categorie_e)) max_cher,
case when enjeu = 'Médailles' then 1 else 0 end has_medal,
round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy,
sum(capacite)/count(*) public,
count(*) nb
from data.paris p
where prix_moyen is not null and discipline != 'Cérémonie'
group by jeux, discipline, genre, has_medal
order by prix_moy  desc
-- where categorie_a = 190 and categorie_b = 145


select * from data.paris where ville = 'Marseille (13)'


-- Par site en geojson
with medals as (
		select max(geom)::geometry(POINT, 3857)  geom, lieu, max(ville) ville, count(distinct "session") nbsess,
		1 as hasmedal,
		count(distinct discipline) nbdisc, count(distinct debut) nbdates, 
		round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy, array_agg(distinct jeux) jeux, array_agg(distinct capacite) capacite,
		array_agg(distinct discipline order by discipline) disc
		from data.paris p
		where enjeu = 'Médailles' and prix_moyen is not null and jeux = 'Olympiques' 
		group by lieu 
), no_medals as( 
		select max(geom)::geometry(POINT, 3857)  geom, lieu, max(ville) ville, count(distinct "session") nbsess, 
		0 as hasmedal,
		count(distinct discipline) nbdisc, count(distinct debut) nbdates, 
		round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy, array_agg(distinct jeux) jeux, array_agg(distinct capacite) capacite,
		array_agg(distinct discipline order by discipline) disc
		from data.paris p
		where enjeu != 'Médailles' and prix_moyen is not null and jeux = 'Olympiques' 
		group by lieu 
)
--select json_agg(x)::json from(
select nm.ville, nm.lieu, m.prix_moy, nm.prix_moy nm_prix_moy, 
round(m.prix_moy/ nm.prix_moy,2) as rapport, round((m.prix_moy - nm.prix_moy)/nm.prix_moy,2) * 100 as tx_evol
from medals m 
inner join no_medals nm on nm.lieu = m.lieu
order by m.prix_moy + nm.prix_moy desc
--) x

-- Par site
select max(geom)::geometry(POINT, 3857)  geom, lieu, max(ville) ville, count(distinct "session") nbsess, 
count(distinct discipline) nbdisc, count(distinct debut) nbdates, 
round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy, array_agg(distinct jeux) jeux,
array_agg(distinct discipline order by discipline) disc
from data.paris p
where enjeu = 'Médailles' and prix_moyen is not null and jeux = 'Olympiques' 
group by lieu 
order by prix_moy desc


---------- Evol prix

with datasmed as(
	select discipline, 1 as has_medal, round(avg(prix_moyen)) prix_moy, round(avg(capacite)) capa_moy, count(distinct session) sessions
	from data.paris 
	where discipline != 'Cérémonie' and jeux = 'Olympiques' and prix_moyen is not null and enjeu = 'Médailles'
	group by discipline 
), datasnomed as(
	select discipline, 0 as has_medal, round(avg(prix_moyen)) prix_moy, round(avg(capacite)) capa_moy, count(distinct session) sessions
	from data.paris 
	where discipline != 'Cérémonie' and jeux = 'Olympiques' and prix_moyen is not null and enjeu != 'Médailles'
	group by discipline 
)
--select json_agg(z) from (
select case when has_medal = 1 then 'Médaille' else 'Pas de médaille' end medal, sum(case when prix_moy > 0 and prix_moy <= 50 then capa else 0 end) places_000_050, 
	   sum(case when prix_moy > 50 and prix_moy <= 100 then capa else 0 end) places_050_100,
	   sum(case when prix_moy > 100 and prix_moy <= 150 then capa else 0 end) places_100_150,
	   sum(case when prix_moy > 150 and prix_moy <= 200 then capa else 0 end) places_150_200,
	   sum(case when prix_moy > 200 and prix_moy <= 250 then capa else 0 end) places_200_250,
	   sum(case when prix_moy > 250 and prix_moy <= 300 then capa else 0 end) places_250_300,
	   sum(case when prix_moy > 300 and prix_moy <= 350  then capa else 0 end) places_300_350,
	   sum(case when prix_moy > 350 and prix_moy <= 400  then capa else 0 end) places_350_400,
	   sum(case when prix_moy > 400 and prix_moy <= 450  then capa else 0 end) places_400_450,
	   sum(case when prix_moy > 450 and prix_moy <= 500  then capa else 0 end) places_450_500
from (
	select discipline, concat(discipline, ' - ',  prix_moy, '€<br>', 'Sessions:', sessions, '<br>Places moy: ', capa_moy) labels, 
	has_medal, prix_moy, sessions,  round(capa_moy/1000) capa_moy, sessions*capa_moy capa, capa_moy capa_moy_full
	from (
	select * from datasmed
	union
	select * from datasnomed
	) d order by prix_moy desc
) t group by has_medal
--) z