let data_sp = [];

for ( let sp in sites_prix ) {
    const current = sites_prix[sp];
    data_sp.push({
        lieu: current['lieu'] + '(' + get_dept(current['ville']) + ')',
        A: current['prix_moy'],
        B: current['nm_prix_moy']
    });
}
new roughViz.StackedBar(
    {
      element: '#sites_prix_medals',
      data: data_sp,
      labels: "lieu",
      roughness: 3,
      font: 1,
      highlight: 'black',
      margin: { top: 10, left: 90, right: 20, bottom: 200 },
      stroke: 1,
      strokeWidth: 1.5,
      axisStrokeWidth: 1,
      innerStrokeWidth: 1,
      tooltipFontSize: '1rem',
      axisRoughness: 1,
    }
  );


  new roughViz.Scatter(
    {
      element: '#scatter_prix_discip',
      data: 'data/disciplines_prix.csv?5',
      x: 'capa_moy',
      y: 'prix_moy',
      colorVar: 'has_medal',
      highlightLabel: 'labels',
      labels: 'labels',
      fillWeight: 2,
      fillStyle:'hachure',
      //radius:'logsess',
      colors: ['skyblue', 'coral'],
      stroke: 'black',
      strokeWidth: 0.4,
      roughness: 1,
      font: 0,
      xLabel: 'Capacité moyenne du lieu de l\'épreuve (en millier de spectateurs)',
      yLabel: 'Prix moyens des billets (€)',
      margin: { top: 0, left: 100, right: 20, bottom: 50 },
      //curbZero: false,
  });  


function get_dept(str) {
    const regExp = /\(([^)]+)\)/;
    return regExp.exec(str)[1];
}