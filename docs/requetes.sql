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
where prix_moyen is not null and discipline != 'Cérémonie'
group by session
order by nb desc, nbgenre desc


select *  from data.paris where session = 'TEN27'

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
SELECT json_build_object(
    'type', 'FeatureCollection',
    'features', json_agg(ST_AsGeoJSON(t.*)::json)
    )
from (
select max(geom)::geometry(POINT, 3857)  geom, lieu, max(ville) ville, count(distinct "session") nbsess, 
count(distinct discipline) nbdisc, count(distinct debut) nbdates, 
round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy, array_agg(distinct jeux) jeux,
array_agg(distinct discipline order by discipline) disc
from data.paris p
where enjeu = 'Médailles' and prix_moyen is not null
group by lieu 
order by prix_moy desc ) 
as t

-- Par site
select max(geom)::geometry(POINT, 3857)  geom, lieu, max(ville) ville, count(distinct "session") nbsess, 
count(distinct discipline) nbdisc, count(distinct debut) nbdates, 
round(sum(prix_moyen*capacite) / sum(capacite), 2) prix_moy, array_agg(distinct jeux) jeux,
array_agg(distinct discipline order by discipline) disc
from data.paris p
where enjeu = 'Médailles' and prix_moyen is not null and jeux = 'Olympiques' 
group by lieu 
order by prix_moy desc