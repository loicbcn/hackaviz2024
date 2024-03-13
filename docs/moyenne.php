<?php
//die('Eteint');
date_default_timezone_set ('Europe/Paris');
// Pas de limite de mémoire
ini_set('memory_limit','-1');
// 2 heures avant que ne survienne un timeout
set_time_limit (7200);
// Voir toutes les erreurs
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$PDO = getpdo();

$cats = ['categorie_first', 'categorie_a', 'categorie_b', 'categorie_c', 'categorie_d'];
$cat_pond = [10, 35, 30, 15, 10];

$compets = $PDO->query("select * from data.paris");

$sql = "UPDATE data.paris
        SET prix_moyen = :moy 
        WHERE id = :id";
$upd = $PDO->prepare($sql);

foreach ( $compets as $c) {
	$sum = 0;
	$div = 0;
	foreach ( $cats as $kcat => $cat ) {
		if ( $c[$cat] ) {
		$sum += $c[$cat]*$cat_pond[$kcat];
			$div += $cat_pond[$kcat];
		}
	}
	
	$moy = $sum * $div > 0 ? round($sum/$div,2) : NULL;
	
    $to_update = array(
        'moy' => $moy,
        'id' => $c['id']
    );
	
    $upd->execute($to_update);

	echo '<table><tr>
	<tr><th>First</th><th>A</th><th>B</th><th>C</th><th>D</th><th>sum</th><th>div</th><th>moy</th></tr>
	<td>'.$c['categorie_first'].'</td><td>'.$c['categorie_a'].'</td><td>'.$c['categorie_b'].'</td>
	<td>'.$c['categorie_c'].'</td><td>'.$c['categorie_d'].'</td>
	<td>'.$sum.'</td><td>'.$div.'</td><td>'.$moy.'</td>
	</tr></table>';
	
	
}





// Fonction de connection à la base postgre
function getpdo() {
    return new PDO('pgsql:host=localhost;dbname=hacka24', 'postgres', 'root',[
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false
    ]);
}