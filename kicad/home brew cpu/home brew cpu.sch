EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L New_Library:RAM U?
U 1 1 5FB56106
P 5200 4750
F 0 "U?" H 5200 5556 50  0001 C CNN
F 1 "RAM B" H 5200 4800 50  0000 C CNN
F 2 "" H 5200 4750 50  0001 C CNN
F 3 "" H 5200 4750 50  0001 C CNN
	1    5200 4750
	1    0    0    -1  
$EndComp
$Comp
L New_Library:RAM U?
U 1 1 5FB5598F
P 5200 3250
F 0 "U?" H 5200 4056 50  0001 C CNN
F 1 "RAM A" H 5200 3300 50  0000 C CNN
F 2 "" H 5200 3250 50  0001 C CNN
F 3 "" H 5200 3250 50  0001 C CNN
	1    5200 3250
	1    0    0    -1  
$EndComp
$Comp
L New_Library:register U?
U 1 1 5FB550F6
P 3850 5750
F 0 "U?" H 3181 5771 50  0001 R CNN
F 1 "Valid C" H 3950 5750 50  0000 R CNN
F 2 "" H 3850 5750 50  0001 C CNN
F 3 "" H 3850 5750 50  0001 C CNN
	1    3850 5750
	1    0    0    -1  
$EndComp
$Comp
L New_Library:RAM U?
U 1 1 5FB547CA
P 3850 4750
F 0 "U?" H 3850 5556 50  0001 C CNN
F 1 "Valid B" H 3850 4800 50  0000 C CNN
F 2 "" H 3850 4750 50  0001 C CNN
F 3 "" H 3850 4750 50  0001 C CNN
	1    3850 4750
	1    0    0    -1  
$EndComp
$Comp
L New_Library:RAM U?
U 1 1 5FB541D3
P 3850 3250
F 0 "U?" H 3850 4056 50  0001 C CNN
F 1 "Valid A" H 3850 3300 50  0000 C CNN
F 2 "" H 3850 3250 50  0001 C CNN
F 3 "" H 3850 3250 50  0001 C CNN
	1    3850 3250
	1    0    0    -1  
$EndComp
$Comp
L New_Library:RAM U?
U 1 1 5FB53786
P 2400 4750
F 0 "U?" H 2400 5556 50  0001 C CNN
F 1 "TAG B" H 2400 4800 50  0000 C CNN
F 2 "" H 2400 4750 50  0001 C CNN
F 3 "" H 2400 4750 50  0001 C CNN
	1    2400 4750
	1    0    0    -1  
$EndComp
$Comp
L New_Library:RAM U?
U 1 1 5FB531D2
P 2400 3250
F 0 "U?" H 2400 4056 50  0001 C CNN
F 1 "TAG A" H 2400 3300 50  0000 C CNN
F 2 "" H 2400 3250 50  0001 C CNN
F 3 "" H 2400 3250 50  0001 C CNN
	1    2400 3250
	1    0    0    -1  
$EndComp
$Comp
L New_Library:register U?
U 1 1 5FB58CA7
P 1750 1400
F 0 "U?" H 1081 1421 50  0001 R CNN
F 1 "Addr Register" H 2000 1400 50  0000 R CNN
F 2 "" H 1750 1400 50  0001 C CNN
F 3 "" H 1750 1400 50  0001 C CNN
	1    1750 1400
	1    0    0    -1  
$EndComp
Text Notes 1750 900  0    50   ~ 0
Address
$Comp
L New_Library:register U?
U 1 1 5FB5A30A
P 3000 1400
F 0 "U?" H 2331 1421 50  0001 R CNN
F 1 "Data Register" H 3250 1400 50  0000 R CNN
F 2 "" H 3000 1400 50  0001 C CNN
F 3 "" H 3000 1400 50  0001 C CNN
	1    3000 1400
	1    0    0    -1  
$EndComp
Text Notes 3000 900  0    50   ~ 0
Data
Wire Wire Line
	3000 1350 3000 800 
$Comp
L New_Library:controlreg ds
U 1 1 5FB5B7B5
P 4250 1400
F 0 "ds" H 3581 1354 50  0001 R CNN
F 1 "controlreg" H 3771 1400 50  0001 R CNN
F 2 "" H 4250 1400 50  0001 C CNN
F 3 "" H 4250 1400 50  0001 C CNN
	1    4250 1400
	-1   0    0    1   
$EndComp
Text Notes 3900 900  0    50   ~ 0
RW
Text Notes 4200 900  0    50   ~ 0
Req
Text Notes 4500 950  0    50   ~ 0
cache\nClr
Text Notes 1100 900  0    50   ~ 0
no_stall
Wire Wire Line
	1100 1400 1400 1400
Wire Wire Line
	1100 1400 1100 1650
Wire Wire Line
	1100 1650 2500 1650
Wire Wire Line
	2500 1650 2500 1400
Wire Wire Line
	2500 1400 2650 1400
Wire Wire Line
	2500 1650 4750 1650
Wire Wire Line
	4750 1650 4750 1400
Wire Wire Line
	4750 1400 4600 1400
Connection ~ 2500 1650
$Comp
L New_Library:PCregister U?
U 1 1 5FB5ED54
P 1750 2500
F 0 "U?" H 2128 2500 50  0001 L CNN
F 1 "PCregister" H 1271 2455 50  0001 R CNN
F 2 "" H 1750 2500 50  0001 C CNN
F 3 "" H 1750 2500 50  0001 C CNN
	1    1750 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	1750 3100 2150 3100
Wire Wire Line
	1750 3100 1750 4600
Wire Wire Line
	1750 4600 2150 4600
Connection ~ 1750 3100
Wire Wire Line
	1750 2700 3300 2700
Wire Wire Line
	3300 2700 3300 3100
Wire Wire Line
	3300 3100 3600 3100
Connection ~ 1750 2700
Wire Wire Line
	1750 2700 1750 3100
Wire Wire Line
	3300 3100 3300 4600
Wire Wire Line
	3300 4600 3600 4600
Connection ~ 3300 3100
Wire Wire Line
	3300 2700 4650 2700
Wire Wire Line
	4650 2700 4650 3100
Wire Wire Line
	4650 3100 4950 3100
Connection ~ 3300 2700
Wire Wire Line
	4650 3100 4650 4600
Wire Wire Line
	4650 4600 4950 4600
Connection ~ 4650 3100
Text Notes 1750 3100 0    50   ~ 0
index_reg
Text Notes 1750 4600 0    50   ~ 0
index_reg
Text Notes 3300 3100 0    50   ~ 0
index_reg
Text Notes 3300 4600 0    50   ~ 0
index_reg
Text Notes 4650 3100 0    50   ~ 0
index_reg
Text Notes 4650 4600 0    50   ~ 0
index_reg
$Comp
L New_Library:PCregister U?
U 1 1 5FB661BC
P 1300 2900
F 0 "U?" H 1678 2900 50  0001 L CNN
F 1 "PCregister" H 1678 2855 50  0001 L CNN
F 2 "" H 1300 2900 50  0001 C CNN
F 3 "" H 1300 2900 50  0001 C CNN
	1    1300 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	1300 2950 1300 3350
Wire Wire Line
	1300 3350 2150 3350
Wire Wire Line
	1300 3350 1300 3800
Wire Wire Line
	1300 4850 2150 4850
Connection ~ 1300 3350
Wire Wire Line
	1300 3800 3400 3800
Wire Wire Line
	3400 3800 3400 3350
Wire Wire Line
	3400 3350 3600 3350
Connection ~ 1300 3800
Wire Wire Line
	1300 3800 1300 4850
Wire Wire Line
	3400 3800 3400 4850
Wire Wire Line
	3400 4850 3600 4850
Connection ~ 3400 3800
Wire Wire Line
	3400 3800 4750 3800
Wire Wire Line
	4750 3800 4750 3350
Wire Wire Line
	4750 3350 4950 3350
Wire Wire Line
	4750 3800 4750 4850
Wire Wire Line
	4750 4850 4950 4850
Connection ~ 4750 3800
$Comp
L 4xxx:2-1 U?
U 1 1 5FB6CE49
P 1300 2250
F 0 "U?" H 1162 2254 50  0001 R CNN
F 1 "2-1" H 1162 2300 50  0001 R CNN
F 2 "" H 1300 2250 50  0001 C CNN
F 3 "" H 1300 2250 50  0001 C CNN
	1    1300 2250
	-1   0    0    1   
$EndComp
Wire Wire Line
	1750 800  1750 1150
Wire Wire Line
	1300 2350 1300 2850
Wire Wire Line
	1350 2250 1350 2100
Wire Wire Line
	1250 1150 1750 1150
Connection ~ 1750 1150
Wire Wire Line
	1750 1150 1750 1350
Wire Wire Line
	1750 2550 1750 2700
Wire Wire Line
	1100 2300 1200 2300
Text Notes 1950 4850 0    50   ~ 0
index
Text Notes 1950 3350 0    50   ~ 0
index
Text Notes 3400 3350 0    50   ~ 0
index
Text Notes 3400 4850 0    50   ~ 0
index
Text Notes 4750 3350 0    50   ~ 0
index
Text Notes 4750 4850 0    50   ~ 0
index
Wire Wire Line
	1500 2550 1500 2800
Wire Wire Line
	1500 2800 2400 2800
Wire Wire Line
	2400 2800 2400 2950
Wire Wire Line
	2400 2800 2950 2800
Wire Wire Line
	2950 4300 2400 4300
Wire Wire Line
	2400 4300 2400 4450
Connection ~ 2400 2800
Text Notes 2400 2900 0    50   ~ 0
tag_reg
Text Notes 2450 4400 0    50   ~ 0
tag_reg
Wire Wire Line
	2650 3350 2800 3350
Wire Wire Line
	2800 3350 2800 3700
Wire Wire Line
	2800 3700 4250 3700
Wire Wire Line
	4250 3700 4250 3350
Wire Wire Line
	4250 3350 4100 3350
Wire Wire Line
	4250 3700 5600 3700
Wire Wire Line
	5600 3700 5600 3350
Wire Wire Line
	5600 3350 5450 3350
Connection ~ 4250 3700
Wire Wire Line
	5600 3700 7000 3700
Connection ~ 5600 3700
Text Notes 6800 3700 0    50   ~ 0
WE_A
Text Notes 5450 3350 0    50   ~ 0
WE_A
Text Notes 4100 3350 0    50   ~ 0
WE_A
Text Notes 2650 3350 0    50   ~ 0
WE_A
Wire Wire Line
	2650 4850 2800 4850
Wire Wire Line
	2800 4850 2800 5200
Wire Wire Line
	2800 5200 4250 5200
Wire Wire Line
	4250 5200 4250 4850
Wire Wire Line
	4250 4850 4100 4850
Wire Wire Line
	4250 5200 5600 5200
Wire Wire Line
	5600 5200 5600 4850
Wire Wire Line
	5600 4850 5450 4850
Connection ~ 4250 5200
Wire Wire Line
	5600 5200 7000 5200
Connection ~ 5600 5200
Text Notes 6750 5200 0    50   ~ 0
WE_B
Text Notes 5450 4850 0    50   ~ 0
WE_B
Text Notes 4100 4850 0    50   ~ 0
WE_B
Text Notes 2650 4850 0    50   ~ 0
WE_B
$Comp
L New_Library:1to1 U?
U 1 1 5FB81339
P 2550 2550
F 0 "U?" H 2550 2815 50  0001 C CNN
F 1 "no cache" H 2550 2600 50  0001 C CNN
F 2 "" H 2550 2550 50  0001 C CNN
F 3 "" H 2550 2550 50  0001 C CNN
	1    2550 2550
	1    0    0    -1  
$EndComp
Wire Wire Line
	1750 2350 2300 2350
Wire Wire Line
	2300 2350 2300 2550
Wire Wire Line
	2300 2550 2450 2550
Connection ~ 1750 2350
Wire Wire Line
	1750 2350 1750 2450
Wire Wire Line
	2650 2550 7000 2550
Text Notes 6550 2550 0    50   ~ 0
NO_CACHE
Wire Wire Line
	1350 2100 1750 2100
Connection ~ 1750 2100
Wire Wire Line
	1750 2100 1750 2350
Connection ~ 1100 1650
Text Notes 2450 2600 0    50   ~ 0
no \ncache?
$Comp
L 4xxx:2-1 U?
U 1 1 5FBA371F
P 3050 3950
F 0 "U?" H 2912 3954 50  0001 R CNN
F 1 "2-1" H 2912 4000 50  0001 R CNN
F 2 "" H 3050 3950 50  0001 C CNN
F 3 "" H 3050 3950 50  0001 C CNN
	1    3050 3950
	0    1    1    0   
$EndComp
Text Notes 3050 3950 0    50   ~ 0
=
Wire Wire Line
	2400 3500 2400 4000
Wire Wire Line
	2400 4000 3050 4000
Wire Wire Line
	2950 2800 2950 3900
Wire Wire Line
	3050 3900 2950 3900
Connection ~ 2950 3900
Wire Wire Line
	2950 3900 2950 4300
$Comp
L 4xxx:2-1 U?
U 1 1 5FBAD85B
P 4000 3900
F 0 "U?" H 3862 3904 50  0001 R CNN
F 1 "2-1" H 3862 3950 50  0001 R CNN
F 2 "" H 4000 3900 50  0001 C CNN
F 3 "" H 4000 3900 50  0001 C CNN
	1    4000 3900
	0    1    1    0   
$EndComp
Text Notes 4000 3950 0    50   ~ 0
&
Wire Wire Line
	3150 3950 4000 3950
Wire Wire Line
	3850 3500 3850 3850
Wire Wire Line
	3850 3850 4000 3850
Wire Wire Line
	4100 3900 7000 3900
Text Notes 6800 3900 0    50   ~ 0
HIT_A
$Comp
L 4xxx:2-1 U?
U 1 1 5FBB4DE5
P 3050 5400
F 0 "U?" H 2912 5404 50  0001 R CNN
F 1 "2-1" H 2912 5450 50  0001 R CNN
F 2 "" H 3050 5400 50  0001 C CNN
F 3 "" H 3050 5400 50  0001 C CNN
	1    3050 5400
	0    1    1    0   
$EndComp
Wire Wire Line
	2400 5000 2400 5450
Wire Wire Line
	2400 5450 3050 5450
Wire Wire Line
	2950 5350 3050 5350
Connection ~ 2950 4300
Text Notes 3050 5400 0    50   ~ 0
=
$Comp
L 4xxx:2-1 U?
U 1 1 5FBBA56F
P 4050 5350
F 0 "U?" H 3912 5354 50  0001 R CNN
F 1 "2-1" H 3912 5400 50  0001 R CNN
F 2 "" H 4050 5350 50  0001 C CNN
F 3 "" H 4050 5350 50  0001 C CNN
	1    4050 5350
	0    1    1    0   
$EndComp
Text Notes 4050 5350 0    50   ~ 0
&
Wire Wire Line
	3150 5400 4050 5400
Wire Wire Line
	3850 5000 3850 5300
Wire Wire Line
	3850 5300 4050 5300
Wire Wire Line
	4150 5350 7000 5350
Text Notes 6750 5350 0    50   ~ 0
HIT_B
Wire Wire Line
	3850 5800 3850 6150
Wire Wire Line
	3850 6150 7000 6150
Text Notes 6750 6150 0    50   ~ 0
HIT_C
$Comp
L New_Library:register U?
U 1 1 5FB56EC0
P 5150 5750
F 0 "U?" H 4481 5771 50  0001 R CNN
F 1 "RAM C" H 5250 5750 50  0000 R CNN
F 2 "" H 5150 5750 50  0001 C CNN
F 3 "" H 5150 5750 50  0001 C CNN
	1    5150 5750
	-1   0    0    1   
$EndComp
Wire Wire Line
	4200 5750 4300 5750
Wire Wire Line
	4300 5750 4300 6000
Wire Wire Line
	4300 6000 5650 6000
Wire Wire Line
	5650 6000 5650 5750
Wire Wire Line
	5650 5750 5500 5750
Wire Wire Line
	5650 6000 7000 6000
Connection ~ 5650 6000
Text Notes 6750 6000 0    50   ~ 0
WE_C
Text Notes 3500 5750 0    50   ~ 0
clr
Wire Wire Line
	1100 5750 3500 5750
Connection ~ 1100 2300
Text Notes 3150 5750 0    50   ~ 0
no_stall
Wire Wire Line
	3850 5700 3850 5550
Wire Wire Line
	3850 4450 3850 4250
Wire Wire Line
	3850 4250 4000 4250
Wire Wire Line
	3850 5550 4000 5550
Wire Wire Line
	3850 2950 3850 2850
Wire Wire Line
	3850 2850 4000 2850
Text Notes 3850 2850 0    50   ~ 0
HIGH
Text Notes 3850 4250 0    50   ~ 0
HIGH
Text Notes 3850 5550 0    50   ~ 0
HIGH
Wire Wire Line
	2950 4300 2950 5350
Text Notes 2800 5350 0    50   ~ 0
tag_reg
Text Notes 2800 3900 0    50   ~ 0
tag_reg
Text Notes 2500 4000 0    50   ~ 0
TAG_A_out
Text Notes 2550 5450 0    50   ~ 0
TAG_B_out
$Comp
L New_Library:4to1 U?
U 1 1 5FC0ADAE
P 6100 4400
F 0 "U?" V 5777 4400 50  0001 C CNN
F 1 "4to1" V 5776 4400 50  0001 C CNN
F 2 "" H 6100 4400 50  0001 C CNN
F 3 "" H 6100 4400 50  0001 C CNN
	1    6100 4400
	0    1    1    0   
$EndComp
Wire Wire Line
	5150 5800 5150 5900
Wire Wire Line
	5150 5900 5900 5900
Wire Wire Line
	5900 5900 5900 4550
Wire Wire Line
	5900 4550 6050 4550
Wire Wire Line
	5200 5000 5200 5450
Wire Wire Line
	5200 5450 5750 5450
Wire Wire Line
	5750 5450 5750 4450
Wire Wire Line
	5750 4450 6050 4450
Wire Wire Line
	5200 3500 5200 4000
Wire Wire Line
	5200 4000 5750 4000
Wire Wire Line
	5750 4000 5750 4350
Wire Wire Line
	5750 4350 6050 4350
Wire Wire Line
	6150 4400 6300 4400
Wire Wire Line
	6300 4400 6300 800 
Wire Wire Line
	1100 2300 1100 5750
Wire Wire Line
	6100 4650 6100 4850
Wire Wire Line
	6100 4850 7000 4850
Text Notes 6550 4850 0    50   ~ 0
Data_o_sel
Text Notes 6200 4500 0    50   ~ 0
data_o
Text Notes 6300 900  0    50   ~ 0
data_o
Wire Wire Line
	1750 1800 5400 1800
Wire Wire Line
	5400 1800 5400 800 
Text Notes 5400 900  0    50   ~ 0
addr_reg_o
Wire Wire Line
	4000 2400 7000 2400
Text Notes 6500 2400 0    50   ~ 0
CPU_RW_reg
Wire Wire Line
	4200 2250 7000 2250
Text Notes 6500 2250 0    50   ~ 0
CPU_req_reg
Wire Wire Line
	4500 2100 7000 2100
Text Notes 6500 2100 0    50   ~ 0
CPU_clr_reg
Wire Wire Line
	1250 1150 1250 2250
Wire Wire Line
	4200 1450 4200 2250
Wire Wire Line
	4500 1450 4500 2100
Wire Wire Line
	1750 1800 1750 2100
Wire Wire Line
	4200 800  4200 1350
Wire Wire Line
	4500 800  4500 1350
Wire Wire Line
	1100 1650 1100 2300
Wire Wire Line
	1750 1450 1750 1800
Connection ~ 1750 1800
Wire Wire Line
	1100 1400 1100 800 
Connection ~ 1100 1400
Wire Wire Line
	4000 1350 4000 800 
Wire Wire Line
	4000 1450 4000 2400
$Comp
L 4xxx:2-1 U?
U 1 1 5FCA2903
P 5800 1900
F 0 "U?" H 5662 1904 50  0001 R CNN
F 1 "2-1" H 5662 1950 50  0001 R CNN
F 2 "" H 5800 1900 50  0001 C CNN
F 3 "" H 5800 1900 50  0001 C CNN
	1    5800 1900
	-1   0    0    1   
$EndComp
Wire Wire Line
	5800 2750 5200 2750
Wire Wire Line
	5200 2750 5200 2950
Text Notes 5550 2050 0    50   ~ 0
RAM_in
Wire Wire Line
	5800 2750 5800 4150
Wire Wire Line
	5800 4150 5200 4150
Wire Wire Line
	5200 4150 5200 4450
Connection ~ 5800 2750
Wire Wire Line
	5800 4150 5800 5550
Wire Wire Line
	5800 5550 5150 5550
Wire Wire Line
	5150 5550 5150 5700
Connection ~ 5800 4150
Text Notes 5200 2850 0    50   ~ 0
RAM_in
Text Notes 5200 4250 0    50   ~ 0
RAM_in
Text Notes 5150 5650 0    50   ~ 0
RAM_in
Wire Wire Line
	3000 1450 3000 1550
Wire Wire Line
	3000 1550 5750 1550
Text Notes 3000 1550 0    50   ~ 0
data_reg
Text Notes 5450 1550 0    50   ~ 0
data_reg
Wire Wire Line
	5900 1950 7000 1950
Text Notes 6550 1950 0    50   ~ 0
RAM_in_sel
Wire Wire Line
	4750 1650 7000 1650
Connection ~ 4750 1650
Wire Wire Line
	5750 1550 7000 1550
Connection ~ 5750 1550
Wire Wire Line
	5800 2000 5800 2750
Wire Wire Line
	5850 1800 5950 1800
Text Notes 6600 1800 0    50   ~ 0
BUS_data
Text Notes 6600 1550 0    50   ~ 0
data_reg
Text Notes 6600 1650 0    50   ~ 0
addr_reg
Wire Wire Line
	5850 1800 5850 1900
Wire Wire Line
	5750 1550 5750 1900
Text Notes 9550 2100 0    50   ~ 0
BUS_data
Wire Wire Line
	9300 2100 9900 2100
Text Notes 9550 2250 0    50   ~ 0
BUS_addr
Wire Wire Line
	9300 2250 9900 2250
Text Notes 9550 2400 0    50   ~ 0
BUS_req
Wire Wire Line
	9900 2400 9300 2400
Text Notes 9550 2550 0    50   ~ 0
BUS_grant
Wire Wire Line
	9300 2550 9900 2550
Text Notes 9550 2700 0    50   ~ 0
BUS_ready
Wire Wire Line
	9900 2700 9300 2700
Wire Notes Line
	9300 2800 8850 2800
Wire Notes Line
	8850 2800 8850 1950
Wire Notes Line
	8850 1950 9300 1950
Wire Notes Line
	9300 1950 9300 2800
Text Notes 8900 2250 0    50   ~ 0
Tri state\nBUS \ninterface
Wire Notes Line
	7000 1350 7000 6300
Wire Notes Line
	7000 6300 8350 6300
Wire Notes Line
	8350 6300 8350 1350
Wire Notes Line
	8350 1350 7000 1350
Wire Wire Line
	8850 2100 8350 2100
Wire Wire Line
	8850 2250 8350 2250
Wire Wire Line
	8850 2400 8350 2400
Wire Wire Line
	8850 2550 8350 2550
Wire Wire Line
	8850 2700 8350 2700
Text Notes 8350 2100 0    50   ~ 0
BUS_data
Text Notes 8350 2250 0    50   ~ 0
BUS_addr
Text Notes 8350 2400 0    50   ~ 0
BUS_req
Text Notes 8350 2550 0    50   ~ 0
BUS_grant
Text Notes 8350 2700 0    50   ~ 0
ready_in
Wire Wire Line
	7250 1350 7250 800 
Text Notes 7250 900  0    50   ~ 0
ready_o
Wire Notes Line
	7500 1500 8000 1500
Wire Notes Line
	8000 1500 8000 1650
Wire Notes Line
	8000 1650 7500 1650
Wire Notes Line
	7500 1500 7500 1650
Text Notes 7550 1600 0    50   ~ 0
ready_reg
Text Notes 7500 3400 0    79   ~ 0
cache\ncontrol\nunit
Wire Notes Line
	650  1050 8000 1050
Wire Notes Line
	8000 1050 8000 600 
Wire Notes Line
	8000 600  650  600 
Wire Notes Line
	650  600  650  1050
Wire Notes Line
	9500 1050 9500 3250
Wire Notes Line
	9500 3250 10050 3250
Wire Notes Line
	10050 3250 10050 1050
Wire Notes Line
	10050 1050 9500 1050
Text Notes 700  750  0    79   ~ 0
CPU
Text Notes 9550 1200 0    79   ~ 0
BUS
Wire Wire Line
	6050 4250 5950 4250
Wire Wire Line
	5950 4250 5950 1800
Connection ~ 5950 1800
Wire Wire Line
	5950 1800 7000 1800
$EndSCHEMATC
