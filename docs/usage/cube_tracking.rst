.. _cube_tracking:

========================
Cube Tracking
========================

.. raw:: html

	<iframe width="560" height="315" src="https://www.youtube.com/embed/xB2wNUxMJUg" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

:program:`BiofilmQ` offers the option to track cubes within a time series. For each lineage a separate *TrackID* is assigned.
The ancestor cube of the cube in the current time frame is called *Parent*.
The ancestor of the parent is called *Grandparent*. The *GrowthRate* is calculated by comparing the volume
of all objects originating from the same parent with the volume of the parent itself and dividing by the number of offspring.

Additionally the *VolumeLossDispersingCells* is calculated and assigned to the nearest remaining cube.

If you have not tracked cubes in the current dataset before, you can start the tracking by using the button
:guilabel:`Track cubes`. If you have already tracked cubes in the dataset, and you want to 
start a new tracking analysis that uses a different frame as the initial frame for tracking, you have to use the checkbox :guilabel:`Start new series`. Otherwise the tracking will continue with the previously defined TrackIDs.

.. note:: 

    Cube tracking is a powerful tool to investigate clonal cluster sizes in experiments with multiple strains which share the 
	**same** fluorescent label. 
    By acquiring time series starting with well-separated clonal clusters, the strains can still be separated
	using the cube tracking algorithm  (by assigning different *TrackIDs*).
    
    .. raw:: html

		<p align="center"><video width="480" height="270" controls src="../_static/tracked_biovolume.mp4"></video></p>

Tracking algorithm
-----------------------

The tracking algorithm has 3 to 4 different stages. In each stage another method is used to find a (grand-)parent object.

#. Test whether a cube position was occupied in the previous frame. If yes, assign previous object as parent.
#. Test whether a cube position was occupied two frames before the current one. If yes, assign the object as grandparent and set parent parameter to the value "not a number" (NaN).
#. If steps 1 and 2 do not yield a parent/ grand-parent, search in the distance defined by :guilabel:`Search Radius` for cubes in the previous frame.

	a. If only a single cube can be found, assign it as new parent.
	b. If multiple objects can be found, calculate the volume overlap. You can increase the overlap by dilating each cube by the pixel value given in the :guilabel:`Options`-panel.
 
		#. If more than one overlapping objects are found, assign the object with the largest overlap as parent.
		#. If no overlappingobjects can be found or the checkbox :guilabel:`Dilate cubes` is disabled, assign the object with the smallest distance as parent.
	
#. (Optional) If the option :guilabel:`Assign same TrackID to connected clusters` is enabled, group all not yet assigned objects in the distance defined by :guilabel:`Search radius` together.

	a. If one of the grouped objects has a parent, it is assigned as parent of all other objects in the cluster.
	b. If no object within a cluster has a parent, they are all assigned to the same new trackID.
	

Track IDs in the first frame
------------------------------

In the dropdown menu :guilabel:`Tracking Method`, two options are available for the first frame:

* *All objects get the same trackID*. (This is a good starting condition if you want to investigate invasions of colonies by cubes outside the field of view.)
* *Different trackID for all cubes in the first frame*. (This is a starting condition if you want to capture growing subpopulations inside the colony starting from the first frame.)




