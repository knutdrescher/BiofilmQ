==========================================
Download and Installation
==========================================


Installation Video Tutorial

.. raw:: html

	<iframe width="560" height="315" src="https://www.youtube.com/embed/pmNLJQI3ryM" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Downloads
==================

.. list-table:: 
   :widths: 35 10 10 15 30
   :header-rows: 1

   * - Program
     - Version
     - Size
     - Operation System
     - Comments
   * - `BiofilmQ-1.0.2.zip <https://github.com/knutdrescher/BiofilmQ/archive/refs/tags/v1.0.2.zip>`_ (recommended\ :sup:`1`)
     - v1.0.2
     - 87 Mb
     - Windows 10, MacOSX, Linux
     - Requires MATLAB R2017b or later with the **Image Processing Toolbox**, **Curve Fitting Toolbox**, and **Statistics and Machine Learning Toolbox**. The **Parallel Computing Toolbox** is optional.
   * - `BiofilmQ-installer-v1.0.2.exe <https://github.com/knutdrescher/BiofilmQ/releases/download/v1.0.2/BiofilmQ-installer-v1.0.2.exe>`_ (without MATLAB\ :sup:`2`)
     - v1.0.2
     - 65 Mb
     - Windows 10
     - **Internet connection required** for MCR download.
   * - `BiofilmQ_MCR-installer-v1.0.2.zip <https://drescherlab.org/data/biofilmQ/BiofilmQ_MCR-installer-v1.0.2.zip>`_ (without MATLAB\ :sup:`2`)
     - v1.0.2
     - 2.31 GB
     - Windows 10
     - MCR included.
   * - `Sample_data.zip <https://github.com/knutdrescher/BiofilmQ/releases/download/v1.0.0/Sample_data_v1.0.0.zip>`_ 
     - v1.0.0
     - 737 Mb
     - Windows 10, MaxOSX, Linux
     - Sample data for BiofilmQ Tutorials
	 
\ :sup:`1` requires a valid MATLAB license

\ :sup:`2` does **not** require MATLAB licence

We recommend the BiofilmQ.zip-based installation for users that have a MATLAB installation with the appropriate toolboxes listed above. For older versions see the `list of releases <https://github.com/knutdrescher/BiofilmQ/releases>`_.

System Requirements
=====================

.. list-table::
   :widths: 18 41 41
   :header-rows: 1

   * - 
     - **Recommended**
     - **Minimal**
   * - **CPU**
     - We use Intel i7 (4th generation or later)
     - Intel i5
   * - **RAM**
     - We use 64GB or 32GB
     - 16GB
   * - **Screen resolution**
     - We use 4K screens
     - 1600px x 1200px
   * - **Operating system**
     - Windows 7, Windows 10, Windows 11
     - Windows 7, 10, Linux, MacOSX
   * - **Hard drive**
     - Depends on your image sizes. We typically use an SSD drive for fast data access.
     - Depends on your image sizes.
   * - **MATLAB version**
     - BiofilmQ was developed with MATLAB R2017b or later
     - MATLAB 2017b, but should also be compatible with at least MATLAB 2016a
   * - **MATLAB toolboxes**
     - Image Processing Toolbox (required), Curve Fitting Toolbox (required), Statistics and Machine Learning Toolbox (required), Parallel Computing Toolbox (optional, speeds up computations)
     - Image Processing Toolbox (required), Curve Fitting Toolbox (required), Statistics and Machine Learning Toolbox (required)
	 

.. note::

	* You can change the font size in the menu bar: :guilabel:`View` -> :guilabel:`Increase font size` or :guilabel:`View` -> :guilabel:`Decrease font size`.

     
Installation from BiofilmQ.zip
===============================

1. Extract *BiofilmQ.zip*.
2. Open MATLAB. 
3. In MATLAB, change the current path to the folder BiofilmQ was extracted into.
4. Type the following command into the *Command Window* to launch BiofilmQ:

.. code:: matlab
	
	BiofilmQ
	
	
Installation from BiofilmQ.exe
================================

#. Change to your Download folder
#. To start the installation double-click on BiofilmQ.exe
#. In some cases a warning dialogue "Windows protected your PC" appears. Click on 'more information' and 'Run anyway'.
#. Next a user account control Window pops-up: "Do you want to allow this app from an unknown publisher to make changes to your device". Click Yes.
#. The BiofilmQ installer starts. Click on 'next'.
#. In the install options, you can pick the file path. The default settings should be alright. Click on 'next'.
#. If you do not have an already installed MATLAB Runtime, you have to download it. Read the licence agreement and click on 'next'
#. Finally you can click 'Install' to start the installation.
#. Once the installation has finished, click onn 'finish'.
#. You can find BiofilmQ in your Start menu.

.. note::

	Starting the BiofilmQ from a binary executable can take a while, don't worry. It does work.






