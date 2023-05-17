---
title: Home
type: docs
---

# FPGA Accelerated Thread Art

## Project Introduction
We create a parallel implementation of "thread art" algorithm that simulates rendering an image by wrapping single piece of string around hooks placed in a circle.

<div align="center">
  <figure>
    <img src="circle_filled.png" alt="circle" width="500">
    <figcaption>Example Execution Progress</figcaption>
  </figure>
  <figure style="display: inline-block;">
    <img src="butterfly_output_20.jpg" alt="Alt text" width="120">
    <figcaption>20%</figcaption>
  </figure>
  <figure style="display: inline-block;">
    <img src="butterfly_output_40.jpg" alt="Alt text" width="120">
    <figcaption>40%</figcaption>
  </figure>
  <figure style="display: inline-block;">
    <img src="butterfly_output_60.jpg" alt="Alt text" width="120">
    <figcaption>60%</figcaption>
  </figure>
  <figure style="display: inline-block;">
    <img src="butterfly_output_80.jpg" alt="Alt text" width="120">
    <figcaption>80%</figcaption>
  </figure>
  <figure style="display: inline-block;">
    <img src="butterfly_output_100.jpg" alt="Alt text" width="120">
    <figcaption>100%</figcaption>
  </figure>
  <figure style="display: inline-block;">
    <img src="butterfly.png" alt="Alt text" width="150">
    <figcaption>ref</figcaption>
  </figure>
</div>



## High Level Design
We utilize a simplified version of the algorithm from [this](https://github.com/callummcdougall/computational-thread-art) github repository. 

There are many similar implementations, but we found that the optimizations introduced here resulted in better quality images.  

At a high level, all the different algorithms aim to try possible lines from a given starting hook, and pick the resulting line that results in greatest similarity to the original image.  

In order to compute similarity, a penalty is formally defined below as:  

![Equation Description](eq1.png)

For ease of computation, images are first inverted, with 255 representing complete darkness, and 0 representing complete brightness. 

A paramterized value *Line Darkness* set as 150 by default represents the darkness of a line. If a line is drawn through a sets of points, all points in the set have their inverted pixel value subtracted by 150.

***p<sub>i</sub>*** represents the inverted pixel value.

***w<sub>i</sub>*** represents the corresponding weight value, which applies a multiplier between 0 and 1, allowing for some pixels to contribute more to overall penalty and therefore be prioritized. 

***L*** represents the lightness penalty, another value between 0 and 1 that allows for negative values to contribute less to overall penalty, therefore increasing the algorithms willingness to draw more lines.

At each step, the algorithm computes possible lines from a starting point and calculates the penalty through those points with (pixel values subtracted by *Line Darkness*) and without (original pixel values). It then selects the line the reduces the penalty by the greatest amount. 

From there, the chosen point because the starting point at the next step.

The most important additions here are pixel weightings and parameterized lightness penalty. This allows for more detailed images.



    var panel = ram_design;
    if (backup + system) {
        file.readPoint = network_native;
        sidebar_engine_device(cell_tftp_raster,
                dual_login_paper.adf_vci.application_reader_design(
                graphicsNvramCdma, lpi_footer_snmp, integer_model));
    }

## Locis suis novi cum suoque decidit eadem

Idmoniae ripis, at aves, ali missa adest, ut _et autem_, et ab?
