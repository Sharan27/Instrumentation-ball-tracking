# Instrumentation Ball Project

## Introduction

This project involves the creation of an instrumentation ball that collects data during motion, processes this data using various algorithms, and displays results on a web interface. The project uses a combination of Python, MATLAB, and Flask to handle data collection, processing, and visualization. Additionally, wireless communication is enabled through WebSockets, allowing live readings from the ball to be displayed on the webpage.

## Data Collection

Initially, data from the ball was collected using the `pyserial` library, which recorded sensor readings and stored them in the `LoggedData` folder. However, this method required a wired connection and multiple processors for handling the data. To enhance efficiency, the system was later upgraded to use WebSockets for data collection, enabling wireless communication. This improvement allowed for real-time data transfer over a local IP network, reducing the need for multiple processors and making the system more streamlined.

## Data Processing

The MATLAB script (`Script.m`) handles the processing of the collected data. It uses the quaternion library from the AHRS (Attitude and Heading Reference System) Algorithm to generate a 3D animation of the ball's movement. The processed output includes a 3D motion video (`MP4` files) and various plots that help analyze the ball's performance and dynamics.

## Website

A Flask-based webpage is created to display information about the ball's performance. The webpage is designed to communicate with the ball wirelessly via a local IP network using WebSockets. This allows real-time data from the ball to be viewed live on the webpage. Additionally, the webpage collects inputs from users, allowing them to control the type of analysis to be performed, and start or stop data collection.

## Data Analysis

Data analysis is performed using Python with the help of `numpy`. This script processes the collected data to rank each ball throw based on specific criteria. It also provides vital information about the ball's performance, which is then displayed on the webpage for further 
