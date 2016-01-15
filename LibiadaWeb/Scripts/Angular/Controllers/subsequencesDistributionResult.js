﻿function SubsequencesDistributionResultController(data) {
    "use strict";

    function subsequencesDistributionResult($scope) {
        MapModelFromJson($scope, data);

        // initializes data for genes map 
        function fillPoints() {
            var id = 0;
            for (var i = 0; i < $scope.result.length; i++) {
                var sequenceData = $scope.result[i];
                $scope.matters.push({ id: sequenceData.MatterId, name: sequenceData.MatterName });

                for (var j = 0; j < sequenceData.SubsequencesData.length; j++) {
                    var subsequenceData = sequenceData.SubsequencesData[j];
                    $scope.points.push({
                        id: id,
                        matterId: sequenceData.MatterId,
                        name: sequenceData.MatterName,
                        sequenceWebApiId: sequenceData.WebApiId,
                        attributes: subsequenceData.Attributes,
                        complement: subsequenceData.Complement,
                        partial: subsequenceData.partial,
                        featureId: subsequenceData.FeatureId,
                        positions: subsequenceData.Starts,
                        lengths: subsequenceData.Lengths,
                        subsequenceWebApiId: subsequenceData.WebApiId,
                        numericX: i + 1,
                        x: sequenceData.Characteristic,
                        y: subsequenceData.CharacteristicsValues[0],
                        featureVisible: true,
                        matterVisible: true
                    });

                    id++;
                }
            }
        }

        // filters dots by subsequences feature
        function filterByFeature(feature) {
            d3.selectAll(".dot")
                .filter(function (dot) { return dot.featureId === feature.Value })
                .attr("rx", function (d) {
                    d.featureVisible = feature.Selected;
                    return $scope.dotVisible(d) ? $scope.dotRadius : 0;
                });
        }

        // checks if dot is visible
        function dotVisible(dot) {
            return dot.featureVisible && dot.matterVisible;
        }

        // constructs string representing tooltip text (inner html)
        function fillPointTooltip(d) {
            var tooltipContent = [];
            var genBankLink = "<a target='_blank' href='http://www.ncbi.nlm.nih.gov/nuccore/";

            var header = d.sequenceWebApiId ? genBankLink + d.sequenceWebApiId + "'>" + d.name + "</a>" : d.name;
            tooltipContent.push(header);

            if (d.subsequenceWebApiId) {
                var peptideGenbankLink = genBankLink + d.subsequenceWebApiId + "'>Peptide ncbi page</a>";
                tooltipContent.push(peptideGenbankLink);
            }

            tooltipContent.push($scope.featuresNames[d.featureId]);

            if (d.attributes.length > 0) {
                tooltipContent.push(d.attributes.join("<br/>"));
            }

            if (d.complement) {
                tooltipContent.push("complement");
            }

            if (d.partial) {
                tooltipContent.push("partial");
            }

            var start = d.positions[0] + 1;
            var end = d.positions[0] + d.lengths[0];
            var positionGenbankLink = d.sequenceWebApiId ?
                                      genBankLink + d.sequenceWebApiId + "?from=" + start + "&to=" + end + "'>" + d.positions.join(", ") + "</a>" :
                                      d.positions.join(", ");
            tooltipContent.push("Position: " + positionGenbankLink);
            tooltipContent.push("(" + d.x + ", " + d.y + ")");

            return tooltipContent.join("</br>");
        }

        function showTooltip(d, tooltip, newSelectedDot, svg) {
            $scope.clearTooltip(tooltip);

            tooltip.style("opacity", .9);

            var tooltipHtml = [];

            tooltip.selectedDots = svg.selectAll(".dot")
                    .filter(function (dot) {
                        if (dot.matterId === d.matterId && dot.y === d.y && $scope.dotVisible(dot)) {
                            tooltipHtml.push($scope.fillPointTooltip(dot));
                            return true;
                        } else {
                            return false;
                        }
                    })
                    .attr("rx", function (dot) {
                        return $scope.dotVisible(dot) ? $scope.selectedDotRadius : 0;
                    });

            if ($scope.highlight) {
                tooltip.similarDots = svg.selectAll(".dot")
                    .filter(function (dot) {
                        if (dot.matterId !== d.matterId && Math.abs(dot.y - d.y) <= ($scope.precision) && $scope.dotVisible(dot)) {
                            tooltipHtml.push($scope.fillPointTooltip(dot));
                            return true;
                        } else {
                            return false;
                        }
                    })
                    .attr("rx", function (dot) {
                        return $scope.dotVisible(dot) ? $scope.selectedDotRadius : 0;
                    });
            }

            tooltip.html(tooltipHtml.join("</br></br>"));

            tooltip.style("background", "#000")
                .style("color", "#fff")
                .style("border-radius", "5px")
                .style("font-family", "monospace")
                .style("padding", "5px")
                .style("left", (d3.event.pageX + 18) + "px")
                .style("top", (d3.event.pageY + 18) + "px");

            tooltip.hideTooltip = false;
        }

        function clearTooltip(tooltip) {
            if (tooltip) {
                if (tooltip.hideTooltip) {
                    tooltip.html("").style("opacity", 0);

                    if (tooltip.selectedDots) {
                        tooltip.selectedDots.attr("rx", function (dot) { return $scope.dotVisible(dot) ? $scope.dotRadius : 0; });
                    }

                    if (tooltip.similarDots) {
                        tooltip.similarDots.attr("rx", function (dot) { return $scope.dotVisible(dot) ? $scope.dotRadius : 0; });
                    }
                }

                tooltip.hideTooltip = true;
            }
        }

        function drawGenesMap() {
            // removing previous chart and tooltip if any
            d3.select(".tooltip").remove();
            d3.select("svg").remove();

            // all organisms are visible after redrawing
            $scope.points.forEach(function (point) {
                point.matterVisible = true;
                for (var i = 0; i < $scope.features.length; i++) {
                    if ($scope.features[i].Value === point.featureId) {
                        point.featureVisible = $scope.features[i].Selected;
                        break;
                    }
                }
            });

            // chart size and margin settings
            var margin = { top: 30 + $scope.legendHeight, right: 30, bottom: 30, left: 60 };
            var width = $scope.width - margin.left - margin.right;
            var height = $scope.hight - margin.top - margin.bottom;

            // setup x 
            var xValue = function (d) { return $scope.numericXAxis ? d.numericX : d.x; }; // data -> value
            var xScale = d3.scale.linear().range([0, width]); // value -> display
            var xMap = function (d) { return xScale(xValue(d)); }; // data -> display
            var xAxis = d3.svg.axis().scale(xScale).orient("bottom");
            xAxis.innerTickSize(-height).outerTickSize(0).tickPadding(10);

            // setup y
            var yValue = function (d) { return d.y; }; // data -> value
            var yScale = d3.scale.linear().range([height, 0]); // value -> display
            var yMap = function (d) { return yScale(yValue(d)); }; // data -> display
            var yAxis = d3.svg.axis().scale(yScale).orient("left");
            yAxis.innerTickSize(-width).outerTickSize(0).tickPadding(10);

            // setup fill color
            var cValue = function (d) { return d.matterId; };
            var color = d3.scale.category20();

            // add the graph canvas to the body of the webpage
            var svg = d3.select("#chart").append("svg")
                .attr("width", $scope.width)
                .attr("height", $scope.hight)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            // add the tooltip area to the webpage
            var tooltip = d3.select("#chart").append("div")
                .attr("class", "tooltip")
                .style("opacity", 0);

            // preventing tooltip hiding if dot clicked
            tooltip.on("click", function (d) { tooltip.hideTooltip = false; });

            // hiding tooltip
            d3.select("#chart").on("click", function (d) { $scope.clearTooltip(tooltip); });

            // calculating margins for dots
            var xMin = d3.min($scope.points, xValue);
            var xMax = d3.max($scope.points, xValue);
            var xMargin = (xMax - xMin) * 0.05;
            var yMax = d3.max($scope.points, yValue);
            var yMin = d3.min($scope.points, yValue);
            var yMargin = (yMax - yMin) * 0.05;

            // don't want dots overlapping axis, so add in buffer to data domain
            xScale.domain([xMin - xMargin, xMax + xMargin]);
            yScale.domain([yMin - yMargin, yMax + yMargin]);

            // x-axis
            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis)
                .append("text")
                .attr("class", "label")
                .attr("x", width)
                .attr("y", -6)
                .style("text-anchor", "end")
                .text($scope.sequenceCharacteristicName)
                .style("font-size", "12pt");

            // y-axis
            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis)
                .append("text")
                .attr("class", "label")
                .attr("transform", "rotate(-90)")
                .attr("y", 6)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text($scope.subsequencesCharacteristicName)
                .style("font-size", "12pt");

            // draw dots
            svg.selectAll(".dot")
                .data($scope.points)
                .enter()
                .append("ellipse")
                .attr("class", "dot")
                .attr("rx", function (d) { return $scope.dotVisible(d) ? $scope.dotRadius : 0; })
                .attr("ry", function (d) { return $scope.dotVisible(d) ? $scope.dotRadius : 0; })
                .attr("cx", xMap)
                .attr("cy", yMap)
                .style("fill", function (d) { return color(cValue(d)); })
                .on("click", function (d) { return $scope.showTooltip(d, tooltip, d3.select(this), svg); });

            // draw legend
            var legend = svg.selectAll(".legend")
                .data($scope.matters)
                .enter().append("g")
                .attr("class", "legend")
                .attr("transform", function (d, i) { return "translate(0," + i * 20 + ")"; })
                .on("click", function (d) {
                    var legendEntry = d3.select(this);
                    legendEntry.style("opacity", function (d) { return legendEntry.style("opacity") == 1 ? .5 : 1; });

                    svg.selectAll(".dot")
                        .filter(function (dot) { return dot.matterId === d.id })
                        .attr("rx", function (d) {
                            d.matterVisible = legendEntry.style("opacity") == 1;
                            return $scope.dotVisible(d) ? $scope.dotRadius : 0;
                        });
                });

            // draw legend colored rectangles
            legend.append("rect")
                .attr("x", width - 18)
                .attr("width", 18)
                .attr("height", 18)
                .style("fill", function (d) { return color(d.id); })
                .attr("transform", "translate(0, -" + $scope.legendHeight + ")");

            // draw legend text
            legend.append("text")
                .attr("x", width - 24)
                .attr("y", 9)
                .attr("dy", ".35em")
                .attr("transform", "translate(0, -" + $scope.legendHeight + ")")
                .style("text-anchor", "end")
                .text(function (d) { return d.name; })
                .style("font-size", "9pt");
        }

        $scope.setCheckBoxesState = SetCheckBoxesState;

        $scope.drawGenesMap = drawGenesMap;
        $scope.dotVisible = dotVisible;
        $scope.filterByFeature = filterByFeature;
        $scope.fillPoints = fillPoints;
        $scope.fillPointTooltip = fillPointTooltip;
        $scope.showTooltip = showTooltip;
        $scope.clearTooltip = clearTooltip;

        $scope.legendHeight = $scope.result.length * 20;
        $scope.hight = 800 + $scope.legendHeight;
        $scope.width = 800;
        $scope.dotRadius = 4;
        $scope.selectedDotRadius = $scope.dotRadius * 3;
        $scope.precision = 0;
        $scope.points = [];
        $scope.matters = [];
        $scope.fillPoints();

    }

    angular.module("SubsequencesDistributionResult", []).controller("SubsequencesDistributionResultCtrl", ["$scope", subsequencesDistributionResult]);
}