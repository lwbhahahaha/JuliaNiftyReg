# Table of Contents

1. [Project Overview](#project-overview)
2. [Installation Instructions](#installation-instructions)
3. [Running Instructions](#running-instructions)
4. [Retrieving Results](#retrieving-results)

# Project Overview

This repository serves as a wrapper for the [Nifty Reg](http://cmictig.cs.ucl.ac.uk/wiki/index.php/NiftyReg). We extend our profound gratitude to the original authors from [CMIC](http://cmictig.cs.ucl.ac.uk/wiki/index.php/Main_Page) and Dr.Molloi's Imaging Physics Laboratory at UC Irvine.

This program is specifically designed to tackle issues related to object motion during two CT scans - non-contrast and with-contrast. As the object might move between these scans, resulting images often portray some degree of motion between v1 and v2. This motion can cause difficulties while analyzing the images. To mitigate these challenges, this program registers these images in a way that effectively cancels the motion, making the image analysis much more precise.

While using this program, a user should have one reference acquisition that exhibits zero (or near zero) motion between v1 and v2, and several acquisitions that show motion between v1 and v2. The program will register all v1 images of with-motion acquisitions to the v1 of the reference acquisition. Simultaneously, it will register all v2 images of with-motion acquisitions to the v2 of the reference acquisition.

This approach is necessary because the image quality aspects like contrast, pixel values, etc. can differ significantly between v1 and v2. Directly registering v1 to v2 can introduce errors due to these differences. Therefore, we designate one acquisition with zero motion as the reference, and then register all other acquisitions to this reference. This improves the accuracy of the registration process.

This project functions without the requirement for a GPU, as the current version of `Nifty Reg` no longer includes GPU support. Therefore, no CUDA toolkit or Nvidia GPUs are needed.

On an average, a PC with an Intel 13900k CPU(16 cores, 32 threads) would require approximately 40 minutes to register one acquisition (v1 and v2).

*Please note, Wenbo is currently working on parts of the code. Updates to this Github repository and the README are to be expected.*

# Installation Instructions

To install this program, follow the steps below:

1. **Download Project:** Click on `Code` (The green button on this page), then select `Download ZIP`. Unzip this program to a location of your choice. Please avoid unzipping this folder to a remote location (like a shared drive). Instead, choose local drives to avoid significant reduction in file read/write speed.
    <p align="center">
      <img src=".\readme_files\1.png" width="85%">
    </p>

2. **Install Julia:** Navigate to the [Julia download page](https://julialang.org/downloads/) and download the **64-bit installer**. Version v1.9.1 is preferred. Note that other versions may cause compatibility issues. Run the installer and **ensure to select "Add Julia to PATH"**.
    <p align="center">
      <img src=".\readme_files\2.png" width="60%">
    </p>

3. **Run Setup:** Navigate to the unzipped folder and run `setup` or `setup.bat`. If you are installing this program for the first time, it might take up to 5 minutes to finish. After installation, you will notice the creation of some new folders.
    <p align="center">
      <img src=".\readme_files\3.png" width="40%">
    </p>

# Running Instructions

To run this program, follow the steps below:

1. **Prepare Acquisitions:** Copy and paste the acquisition with zero (or almost zero) motion into the `.\input\reference_acq` folder. Use only ONE acquisition as the reference (master) acquisition.
    <p align="center">
      <img src=".\readme_files\4.png" width="60%">
    </p>

    Copy and paste the acquisitions with motion that need to be registered into the `.\input\with_motion` folder. You can add one or more acquisitions here.
    <p align="center">
      <img src=".\readme_files\5.png" width="75%">
    </p>

2. **Run the Program:** Navigate back to the main folder and run `run` or `run.bat`. The command window should display an output confirming that all acquisitions have been successfully located by the program. Please wait for the program to finish its execution.
    <p align="center">
      <img src=".\readme_files\6.png" width="80%">
    </p>

# Retrieving Results

Upon successful execution, the command window should display a message indicating the program's completion.
    <p align="center">
      <img src=".\readme_files\7.png" width="60%">
    </p>

To retrieve the registered images, navigate to the `output` folder.
