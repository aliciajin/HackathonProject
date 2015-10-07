d3.json("jsondata.json", function(error, json){


	var colorScale = d3.scale.category20c();
	console.log('print')
	data=json;
	console.log(data);
	console.log(data.length);
	data.forEach(function (d){
		d.creationtime2=Date.parse(d.creationtime2);
	});

	ndx=crossfilter(data);
	dateDim=ndx.dimension(function (d){
		return d.creationtime2;
	});
	dateGroup=dateDim.group();
	minDate=dateDim.bottom(1)[0].creationtime2;
	maxDate=dateDim.top(1)[0].creationtime2;
	console.log(minDate.maxDate);
	var dateDim_monthly = ndx.dimension(function (d){ 
		var tmp = new Date(d.creationtime2);
		var month = tmp.getMonth()+1;
		var newdate = month+'-'+'01-'+tmp.getFullYear();
		//console.log(Date.parse(newdate));
		return Date.parse(newdate);  });
	var dateGroup_monthly=dateDim_monthly.group();

	var creationtime=dc.barChart('#date-barchart');
	creationtime.width(600)
			   .height(300)
			   .dimension(dateDim_monthly)
			   .group(dateGroup_monthly)
			   .transitionDuration(1000)
			   .gap(-10)
			   .x(d3.time.scale().domain([minDate, maxDate]));



	quarterDim=ndx.dimension(function(d){
		return d.Creation_Hour_Range;
	});
	quarterGroup=quarterDim.group();
	console.log(quarterGroup.all());
	var quarter = dc.rowChart('#quarter-rowchart');
	var quarter_range=['0:00-6:00: ', '6:00-12:00: ', '12:00-18:00: ', '18:00-24:00: ']
	quarter.width(200)
		  .height(250)
		  .margins({top: 0, left: 5, right: 10, bottom: 30})
		  .transitionDuration(1000)
		  .ordering(function(d) { return d.key; })
		  .dimension(quarterDim)
		  .group(quarterGroup)
		  .colors(colorScale)
		  .label(function (d){ return quarter_range[d.key-1] + d.value; });


// for pie
	weekendDim=ndx.dimension(function(d){
		return d.weekend;
	});
	weekendGroup=weekendDim.group();
	pie1=dc.pieChart('#weekend-pie')
	pie1.width(200)
		 .height(200)
		 .radius(60)
		 .innerRadius(20)
		 .transitionDuration(1000)
		 .dimension(weekendDim)
		 .group(weekendGroup)
		 .colors(colorScale);

	rainDim=ndx.dimension(function(d){
		return d.rain;
	});
	rainGroup=rainDim.group();
	pie2=dc.pieChart('#rain-pie')
	pie2.width(200)
		 .height(200)
		 .radius(70)
		 .innerRadius(20)
		 .transitionDuration(1000)
		 .dimension(rainDim)
		 .group(rainGroup)
		 .colors(colorScale);

	typeDim=ndx.dimension(function(d){
		return d.Type2;
	});
	typeGroup=typeDim.group();
	var typeChart = dc.rowChart('#type-chart');
	typeChart.width(300)
		  .height(700)
		  .margins({top: 0, left: 5, right: 10, bottom: 30})
		  .transitionDuration(1000)
		  //.ordering(function(d) { return d.key; })
		  .ordering(function(d) { return -d.value; })
		  .dimension(typeDim)
		  .group(typeGroup)
		  .colors(colorScale)
		  .label(function (d){ return d.key+' : '+d.value; });



	boroughDim=ndx.dimension(function(d){
		a=d.Borough;
		a=a.toLowerCase();
		return a;
	});
	boroughGroup=boroughDim.group();
	console.log(boroughGroup.all());
	var boroughChart = dc.rowChart('#borough-chart');
	boroughChart.width(300)
		  .height(500)
		  .margins({top: 0, left: 5, right: 10, bottom: 30})
		  .transitionDuration(1000)
		  //.ordering(function(d) { return d.key; })
		  .ordering(function(d) { return -d.value; })
		  .dimension(boroughDim)
		  .group(boroughGroup)
		  .colors(colorScale)
		  .label(function (d){ return d.key+' : '+d.value; });

	levelDim=ndx.dimension(function(d){
		return d.nondetailed_hour;
	});
	levelGroup=levelDim.group();
	console.log(levelGroup.all());
	var levelChart = dc.rowChart('#level-chart');
	levelChart.width(500)
		  .height(340)
		  .margins({top: 0, left: 5, right: 10, bottom: 30})
		  .transitionDuration(1000)
		  //.ordering(function(d) { return d.key; })
		  .ordering(function(d) { return -d.value; })
		  .dimension(levelDim)
		  .group(levelGroup)
		  .colors(colorScale)
		  .label(function (d){ return 'category: '+d.key+' : '+d.value; });

	// var scatterchart = dc.scatterPlot("#scatter-chart");







	dc.renderAll();

});
