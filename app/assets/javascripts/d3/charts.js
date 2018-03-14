function renderCharts(dataset) {
  // get all unique years in dataset
  var years = d3.keys(dataset[0]).filter(function(key) { return key.startsWith('total_'); });

  var dataset_2 = [];
  var gridSpace = {};
  var today = new Date();
  var validDataPoint = false;

  years.forEach(function(key, index) {
    var year = key.replace(/total_/, '');
    gridSpace[year] = 0;
    dataset.forEach(function(d, i) {
      // Set flag when encounter first valid data point
      if (index == 0 && d[key] != null) {
        validDataPoint = true;
      }

      // Skip iteration if data point is invalid
      if (validDataPoint == false) {
        return;
      }

      var date = new Date(year,(d.month-1),1);
      // Do not include any future dates
      if (date <= today) {
        dataset_2.push({ date: date, total: d[key], avg_duration: d['avg_duration_' + year] });
        gridSpace[year] += 1;
      }
    });
  });

  // Decrement 1 for current year because the last data point
  // does not have a background grid of its own.
  gridSpace[today.getFullYear()] -= 1;

  // Total number of grid spaces across the chart
  var totalGridSpace = 0;
  Object.values(gridSpace).forEach(function(value) {
    totalGridSpace += value;
  });

  var months = { 1:'Jan', 2:'Feb', 3:'Mar', 4:'Apr', 5:'May', 6:'Jun', 7:'Jul', 8:'Aug', 9:'Sep', 10:'Oct', 11:'Nov', 12:'Dec' };

  var colors = ["#AF7AC5", "#EB984E", "#52BE80", "#5499C7"];

  var margin = { top: 20, right: 50, left: 50, bottom: 40 }, width, height, maxTotal;

  function renderGridlines(type, scale, numGrids) {
    if (type == 'horizontal') {
      return d3.axisLeft(scale).ticks(numGrids);
    } else {
      return d3.axisBottom(scale).ticks(numGrids);
    }
  }


  var Chart = (function(window,d3) {

    var data, svg, chartWrapper, xScale, yScale, xAxis, yAxis, yAxisLabel, xGrid, yGrid, legend, line_2015, line_2016, line_2017, maxTotalsByMonth = [];

    init(dataset); //load data, then initialize chart

    function init(dataset) {
      data = dataset;

      // format the data
      data.forEach(function(d) {
        d.month = months[d.month];
        d.total_2015 = +d.total_2015;
        d.total_2016 = +d.total_2016;
        d.total_2017 = +d.total_2017;
        d.total_2018 = +d.total_2018;

        d.totals = years.map(function(name) { return {name: name, total: +d[name]}; });
        maxTotalsByMonth.push(Math.max(d[years[0]], d[years[1]]));
      });

      maxTotal = d3.max(maxTotalsByMonth);

      // initialize scales
      xScale = d3.scaleBand().domain(data.map(function(d) { return d.month; }));
      yScale = d3.scaleLinear().domain([0, maxTotal]);
      color = d3.scaleOrdinal().range(colors);

      // initialize svg and other elements
      svg = d3.select('#chart-monthly-breakdown').append('svg');
      chartWrapper = svg.append('g');
      path_2015 = chartWrapper.append('path').datum(data).classed('line_2015', true);
      path_2016 = chartWrapper.append('path').datum(data).classed('line_2016', true);
      path_2017 = chartWrapper.append('path').datum(data).classed('line_2017', true);
      path_2018 = chartWrapper.append('path').datum(data).classed('line_2018', true);
      xAxis = chartWrapper.append('g').classed('x-axis', true);
      yAxis = chartWrapper.append('g').classed('y-axis', true);
      yAxisLabel = chartWrapper.select('.y-axis').append('text');
      xGrid = chartWrapper.append('g').classed('grid x-grid', true);
      yGrid = chartWrapper.append('g').classed('grid y-grid', true);

      // initialize legend
      legend = chartWrapper.selectAll(".legend")
            .data(years.slice())
          .enter().append("g")
            .attr("class", "legend")
            .attr("transform", function(d, i) {
              return "translate(0," + i * 20 + ")";
            });

      legendRect = legend.append("rect");
      legendText = legend.append("text");

      // the path generator for the line chart
      line_2015 = d3.line()
        .x(function(d) { return xScale(d.month) })
        .y(function(d) { return yScale(d.total_2015) });

      line_2016 = d3.line()
        .x(function(d) { return xScale(d.month) })
        .y(function(d) { return yScale(d.total_2016) });

      line_2017 = d3.line()
        .x(function(d) { return xScale(d.month) })
        .y(function(d) { return yScale(d.total_2017) });

      line_2018 = d3.line()
        .x(function(d) { return xScale(d.month) })
        .y(function(d) { return yScale(d.total_2018) });

      // render the chart
      render();
    }

    function render() {

      // get dimensions based on width of parent div
      var dw = getChartWidth();
      updateDimensions(dw);

      // update x and y scales to new dimensions
      xScale.range([0, width]).padding(1.0);
      yScale.range([height, 0]);

      // update svg elements to new dimensions
      svg.attr('width', width + margin.right + margin.left)
         .attr('height', height + margin.top + margin.bottom);
      chartWrapper.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

      // update the both axes
      xAxis.attr("transform", "translate(0," + height + ")")
          .call(d3.axisBottom(xScale));

      yAxis.call(d3.axisLeft(yScale).ticks(maxTotal));

      // update y-axis label
      yAxisLabel.attr("class", "axis-title")
        .attr("transform", "rotate(-90)")
        .attr("y", -margin.left+5)
        .attr("x", 0 - (height / 2))
        .attr("dy", ".71em")
        .style("text-anchor", "middle")
        .text("Monthly Total");

      // update x-axis grid lines
      xGrid.attr("transform", "translate(0," + height + ")")
        .transition().call(renderGridlines('vertical', xScale, data.length).tickSize(-height).tickFormat(""));

      // update y-axis grid lines
      yGrid.transition().call(renderGridlines('horizontal', yScale, maxTotal).tickSize(-width).tickFormat(""));

      // update lines
      path_2015.attr('d', line_2015)
          .attr("fill", "none")
          .attr("stroke", colors[0])
          .attr("stroke-width", 1.5);

      path_2016.attr('d', line_2016)
          .attr("fill", "none")
          .attr("stroke", colors[1])
          .attr("stroke-width", 1.5);

      path_2017.attr('d', line_2017)
          .attr("fill", "none")
          .attr("stroke", colors[2])
          .attr("stroke-width", 1.5);

      path_2018.attr('d', line_2018)
          .attr("fill", "none")
          .attr("stroke", colors[3])
          .attr("stroke-width", 1.5);

      // update legend
      legendRect.attr("x", width - 18)
        .attr("width", 16)
        .attr("height", 16)
        .style("fill", color);

      legendText.attr("x", width - 24)
        .attr("y", 10)
        .attr("dy", ".25em")
        .style("text-anchor", "end")
        .text(function(d) {
          return d.substr(d.length-4);
        });
    }

    return {
      render : render
    }

  })(window,d3);


  var Chart_2 = (function(window,d3) {

    var data_2, svg_2, chartWrapper_2, xScale_2, yScale_2a, yScale_2b, xAxis_2, yAxis_2a, yAxis_2b, yAxisLabel_2a, yAxisLabel_2b;
    var xGrid_2, yGrid_2, bkgdA, bkgdB, bkgdC, path_2a, path_2b, line_2a, line_2b;
    var bkgdColors = ["#F4ECF7", "#FDEBD0", "#D5F5E3", "#D6EAF8"];

    init(dataset_2); //load data, then initialize chart

    function init(dataset) {
      data_2 = dataset;

      // format the data
      data_2.forEach(function(d) {
        d.avg_duration = +d.avg_duration;
      });

      // initialize scales
      maxTotal = d3.max(data_2, function(d) { return d.total; });
      xScale_2 = d3.scaleTime().domain(d3.extent(data_2, function(d) { return d.date; }));
      yScale_2a = d3.scaleLinear().domain([0, maxTotal + 1]);
      yScale_2b = d3.scaleLinear().domain(d3.extent(data_2, function(d) { return d.avg_duration; }));

      svg_2 = d3.select("#chart-monthly-breakdown-2").append("svg");
      chartWrapper_2 = svg_2.append('g');
      bkgdA = chartWrapper_2.append("rect");
      bkgdB = chartWrapper_2.append("rect");
      bkgdC = chartWrapper_2.append("rect");
      bkgdD = chartWrapper_2.append("rect");
      path_2a = chartWrapper_2.append('path').datum(data_2).classed('line_2a', true);
      path_2b = chartWrapper_2.append('path').datum(data_2).style("stroke-dasharray", ("3, 3")).classed('line_2b', true);
      xAxis_2 = chartWrapper_2.append('g').classed('x-axis', true);
      yAxis_2a = chartWrapper_2.append('g').classed('axis y-axis-primary', true);
      yAxis_2b = chartWrapper_2.append('g').classed('axis y-axis-secondary', true);
      yAxisLabel_2a = chartWrapper_2.select('.y-axis-primary').append('text');
      yAxisLabel_2b = chartWrapper_2.select('.y-axis-secondary').append('text');
      xGrid_2 = chartWrapper_2.append('g').classed('grid x-grid', true);
      yGrid_2 = chartWrapper_2.append('g').classed('grid y-grid', true);

      // the path generator for the line chart
      line_2a = d3.line()
        .x(function(d) { return xScale_2(d.date) })
        .y(function(d) { return yScale_2a(d.total) });

      line_2b = d3.line()
        .x(function(d) { return xScale_2(d.date) })
        .y(function(d) { return yScale_2b(d.avg_duration) });

      // render the chart
      render();
    }

    function render() {

      // get dimensions based on width of parent div
      var dw = getChartWidth();
      updateDimensions(dw);

      // update x and y scales to new dimensions
      xScale_2.range([0, width]);
      yScale_2a.rangeRound([height, 0]);
      yScale_2b.rangeRound([height, 0]);

      // update svg elements to new dimensions
      svg_2.attr('width', width + margin.right + margin.left)
          .attr('height', height + margin.top + margin.bottom);
      chartWrapper_2.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

      // update all axes
      xAxis_2.attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(xScale_2).tickFormat(d3.timeFormat("%b %Y")));

      yAxis_2a.call(d3.axisLeft(yScale_2a).ticks(maxTotal));

      yAxis_2b.attr("transform", "translate(" + width + ",0)")
            .call(d3.axisRight(yScale_2b));

      // update y-axis labels
      yAxisLabel_2a.attr("class", "axis-title-primary")
        .attr("transform", "rotate(-90)")
        .attr("y", -margin.left+5)
        .attr("x", 0 - (height / 2))
        .attr("dy", ".71em")
        .style("text-anchor", "middle")
        .text("Monthly Total");

      yAxisLabel_2b.attr("class", "axis-title-secondary")
        .attr("transform", "rotate(-90)")
        .attr("y", (margin.right-10))
        .attr("x", 0 - (height / 2))
        .attr("dy", ".71em")
        .style("text-anchor", "middle")
        .text("Average Duration (minutes)");

      // update x-axis grid lines
      xGrid_2.attr("transform", "translate(0," + height + ")")
        .transition().call(renderGridlines('vertical', xScale_2, data_2.length).tickSize(-height).tickFormat(""));

      // update y-axis grid lines
      yGrid_2.transition().call(renderGridlines('horizontal', yScale_2a, maxTotal).tickSize(-width).tickFormat(""));

      // update backgrounds
      bkgdA.attr("x",0)
        .attr("y",0)
        .attr("width", (width * (gridSpace[today.getFullYear()-3]/totalGridSpace)))
        .attr("height",height)
        .style("fill", bkgdColors[0]);

      bkgdB.attr("x",(width * (gridSpace[today.getFullYear()-3]/totalGridSpace)))
        .attr("y",0)
        .attr("width", (width * (gridSpace[today.getFullYear()-1]/totalGridSpace)))
        .attr("height",height)
        .style("fill", bkgdColors[1]);

      bkgdC.attr("x",(width * ((gridSpace[today.getFullYear()-3]/totalGridSpace) + (gridSpace[today.getFullYear()-2]/totalGridSpace))))
        .attr("y",0)
        .attr("width", (width * (gridSpace[today.getFullYear()-1]/totalGridSpace)))
        .attr("height",height)
        .style("fill", bkgdColors[2]);

      bkgdD.attr("x",(width * ((gridSpace[today.getFullYear()-3]/totalGridSpace) + (gridSpace[today.getFullYear()-2]/totalGridSpace) + (gridSpace[today.getFullYear()-1]/totalGridSpace))))
        .attr("y",0)
        .attr("width", (width * (gridSpace[today.getFullYear()]/totalGridSpace)))
        .attr("height",height)
        .style("fill", bkgdColors[3]);

      // update lines
      path_2a.attr('d', line_2a)
          .attr("fill", "none")
          .attr("stroke", "#444")
          .attr("stroke-width", 1.0);

      path_2b.attr('d', line_2b)
          .attr("fill", "none")
          .attr("stroke", "#999")
          .attr("stroke-width", 1.5);
    }

    return {
      render : render
    }

  })(window,d3);


  function updateDimensions(chartParentWidth) {

    if (chartParentWidth < 600) {
      margin.left = 30;
      margin.right = 35;
    } else if (chartParentWidth < 690) {
      margin.left = 40;
      margin.right = 40;
    } else {
      margin.left = 50;
      margin.right = 50;
    }

    aspectRatio  = chartParentWidth < 500 ? 0.55 : 0.47;
    width = chartParentWidth - margin.left - margin.right;
    height = aspectRatio * width;
  }

  function getChartWidth() {
    if ($('#chart-monthly-breakdown').is(':visible')) {
      return document.getElementById("chart-monthly-breakdown").offsetWidth;
    } else if ($('#chart-monthly-breakdown-2').is(':visible')) {
      return document.getElementById("chart-monthly-breakdown-2").offsetWidth;
    }
  }


  window.addEventListener('resize', Chart.render);
  window.addEventListener('resize', Chart_2.render);

  $('.toggle-charts').click(function() {
    if ($('#chart-monthly-breakdown').is(':visible')) {
      $('#chart-monthly-breakdown').hide();
      $('#chart-monthly-breakdown-2').show();
    } else {
      $('#chart-monthly-breakdown').show();
      $('#chart-monthly-breakdown-2').hide();
    }
  });
}
