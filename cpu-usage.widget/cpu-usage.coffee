# cpu-usage.coffee
#
# Displays logical cpu usage as bars and percentage
# Bars change to red if usage is over 75%
#
# Author: Aram Avila-Herrera
# Date: February 22, 2015
#
# License: Released under the GNU GPL v3 license (See ../LICENSE)

# These control the dimensions of the widget
width: 500
barHeight: 15
margin:
  right: 0
  left: 70

command: "~/bin/cpu_usage | tail -n +2 | cut -f2"
refreshFrequency: 2000

# Runs once
render: (output) ->
  """
  <svg class="cpu-usage-chart"></svg>
  """

# Draw non-changing text (e.g. "cpu N:")
#afterRender: (domEl) ->

# Draw rectangular bars
update: (output, domEl) ->
  cpu_usage_l = output.trim()
    .split /[\s\n]+/
    .map parseFloat

  barHeight = @barHeight
  width = @width
  margin = @margin
  height = (barHeight * cpu_usage_l.length)

  $.getScript 'd3js/d3.min.js.lib', ->

    # define the x-axis scale: x(data) maps data to x-axis
    x = d3.scale.linear()
      .domain [0, 100]
      .range [0, width - margin.left - margin.right]

    # define the y-axis scale: y(data) maps data to y-axis
    # d := list element, i := built-in counter
    y = d3.scale.ordinal()
        .domain cpu_usage_l.map((d,i) -> "cpu #{i}:")
        .rangeRoundBands [0, height], .1

    # define the y-axis
    yAxis = d3.svg.axis()
      .scale y
      .orient 'left'

    # set the chart dimensions
    chart = d3.select '.cpu-usage-chart'
      .attr 'width', width + margin.left + margin.right
      .attr 'height', height

    # add y-axis to the chart here
    chart.select '.y.axis'
      .remove()
    chart.append 'g'
      .attr 'class', 'y axis'
      .attr 'transform', "translate(#{margin.left},0)"
      .call yAxis
    chart.selectAll('.y.axis text')
      .data cpu_usage_l
      .attr 'dy', '.25em'
      .attr 'load', (d) -> if d > 70 then 'high' else 'normal'

    # initialize bars
    bar = chart.selectAll '.bar.container'
      .data cpu_usage_l
      .enter()
      .append 'g'
      .attr 'class', 'bar container'
      .attr 'transform', (d, i) -> "translate(#{margin.left},#{y("cpu #{i}:")})"
    bar
      .append 'rect'
      .attr 'class', 'bar obj'
      .attr 'width', (d) -> x(d)
      .attr 'height', y.rangeBand()
    bar
      .append 'text'
      .attr 'class', 'bar txt'
      .attr 'x', (d) -> x(d) + 2
      .attr 'y', y.rangeBand() / 2
      .attr 'dy', '.25em'
      .text (d) -> "#{d}%"

    # update bars
    chart.selectAll '.bar.txt'
      .data cpu_usage_l
      .attr 'x', (d) -> x(d) + 2
      .text (d) -> "#{d}%"
    chart.selectAll '.bar.obj'
      .data cpu_usage_l
      .attr 'width', (d) -> x(d)
    chart.selectAll '.bar.container'
      .data cpu_usage_l
      .attr 'load', (d) -> if d > 70 then 'high' else 'normal'

# CSS in stylus
style: """
  opacity 0.3
  bottom 20%
  box-sizing border-box

  text
    font-family Courier
    font-size 15px

  .domain
    visibility hidden

  [load='normal']
    fill white
    opacity 0.8 !important
  [load='high']
    fill pink
    font-weight 900

"""
