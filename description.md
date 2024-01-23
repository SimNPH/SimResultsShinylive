## Introduction

This Shiny App presents the Results of a [Simulation Study](https://arxiv.org/abs/2310.05622) to Evaluate the Performance Characteristics of Statistical Methods for the Analysis of Time-To-Event Data Under Non-Proportional Hazards.

The application is organised into 3 sections.

### Introduction

This tab contains this text describing the app and the presented data.

### Scenarios

This tab allows users to display the underlying survival distribution that was used in the simulation.

 * A class of scenarios can be selected with the dropdown menu 'Scenarios'
 * Depending on the selected scenario values for different parameters can be selected.
 * In the plot panel the survival curves, hazard curves and hazard ratio of the current scenario and parameter settings are displayed.
 * A table of summary statistics of the current scenario and parameter settings is printed.
 * Note that not every combination of parameters was simulated. If the combination of parameters is not present in the results a note is displayed in the plot panel.
 
### Simulation Results

This tab allows users to explore the results of the simulation study. The data to be displayed can be selected as follows:

 * A class of scenarios can be selected with the dropdown menu 'Scenarios'
 * Methods to be compared can be added and removed. Methods can be added from the dropdown menu or by searching. Methods can be removed by placing the cursor and typing backspace.
 * The performance metrics, that should be compared for the methods can be selected with the dropdown menu 'y-Axis.'
 * Depending on the selected scenario different parameters can be displayed and used for filtering. The parameters can be arranged by drag and drop.
   * x-Axis: Parameters in this area are displayed on the x-axis of the plot in the manner of a nested loop plot. Parameters first in the list vary slowest parameters last vary fastest.
   * Facets, Columns: Parameters in this area are used to split the plot into panels horizontally. More than one parameter can be put here to create a column for each combination of parameters.
   * Facets, Columns: Parameters in this area are used to split the plot into panels vertically. More than one parameter can be put here to create a row for each combination of parameters.
   * Filter: For parmeters in this area a dropdown menu is displayed to to allow the data in the plot to be restricted to a certain parameter value.
 * Checkboxes for plot annotations: Horizontal lines and ribbons can be added to the plot at 
   * 0.025, the nominal Type I error rate for the tests
   * 0.031, the nominal Type I error rate plus the Monte Carlo confidence interval under the null of the method maintaining the nominal Type I error rate (95% of observations of the rejection rate of methods that control the Type I error rate at the nominal level should fall under this value.)
   * 0.95, the nominal CI coverage
   * From 0.9584 to 0.9412, the nominal CI coverage plus the Monte Carlo confidence interval under the null of the method maintaining the nominal coverage (95% of observations of the rejection rate of methods that control the Type I error rate at the nominal level should fall under this value.)


