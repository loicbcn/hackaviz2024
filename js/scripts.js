console.log(sites_prix);

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
      labelFontSize: '14px',
      roughness: 3,
      font: 1,
      highlight: 'black',
      margin: { top: 10, left: 90, right: 20, bottom: 200 },
      stroke: 1,
      strokeWidth: 1.5,
      axisStrokeWidth: 1,
      innerStrokeWidth: 1,
      tooltipFontSize: '1.6rem',
      axisRoughness: 1,
    }
  );

function get_dept(str) {
    const regExp = /\(([^)]+)\)/;
    return regExp.exec(str)[1];
}