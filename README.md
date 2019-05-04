# OnlineLatentStateLearning
Code and data to accompany manuscript on a model for online latent state learning
Please cite the accompanying paper by Cochran and Cisler ("A flexible and generalizable model for online latent-state learining").
Do not hestitate to email cochran4@wisc.edu if you have any questions. 

Folders are divided as follows:

- Approaches: contains learning models used in the paper (e.g., LatentState is the complete latent-state model presented in the paper). 

- Common Files: contains all the files that are used by simulation examples

- Example-specific folders contain details of specific simulation experiments (e.g., PREE Example reproduces the partial reinforcement extinction effect simulations)


Within each example-specific folder, you can run a simulation experiment (and generate figures) by running the command RunXXX in matlab were XXX is a label of the simulation example. 

Within the Common Files folder, 

- EstimateLogLike: used for parameter fitting, returns log-likelihood (among other things) for a given model and experiment

- PatientParameters: returns a structure of common parameters that are used throughout the experiment

- PrettyFig: formatting for figures

- RunExample: common code to run a simulation example

- RunTask: common code to perform one run of a task, called by RunExample

- Colors: color scheme for figures

- HistogramWMean: display a histogram (with estimated mean)

- ScatterPlot: display a scatter plot of two variables

