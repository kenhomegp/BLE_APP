//
//  BLEDefines.h
//  MerryBLEtool
//
//  Created by merry on 13-12-19.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#ifndef MerryBLEtool_BLEDefines_h
#define MerryBLEtool_BLEDefines_h

//Device Type
#define TI_keyfob                                           1
#define CSR_security_tag                                    2
#define Unknown_Device                                      100

// Defines for the TI CC2540 keyfob peripheral
#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      0x1802
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             0x2a06
#define TI_KEYFOB_PROXIMITY_ALERT_ON_VAL                    0x01
#define TI_KEYFOB_PROXIMITY_ALERT_OFF_VAL                   0x00
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID             0x1804
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID        0x2A07
#define TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN    1

#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_LEVEL_SERVICE_READ_LEN                    1

#define TI_KEYFOB_ACCEL_SERVICE_UUID                        0xFFA0
#define TI_KEYFOB_ACCEL_ENABLER_UUID                        0xFFA1
#define TI_KEYFOB_ACCEL_RANGE_UUID                          0xFFA2
#define TI_KEYFOB_ACCEL_READ_LEN                            1
#define TI_KEYFOB_ACCEL_X_UUID                              0xFFA3
#define TI_KEYFOB_ACCEL_Y_UUID                              0xFFA4
#define TI_KEYFOB_ACCEL_Z_UUID                              0xFFA5

#define TI_KEYFOB_KEYS_SERVICE_UUID                         0xFFE0
#define TI_KEYFOB_KEYS_NOTIFICATION_UUID                    0xFFE1
#define TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN                1

//GATT Services Specifications
//https://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx
#define GATT_Generic_Access_Service                         0x1800
#define GATT_Generic_Attribute_Service                      0x1801
#define GATT_Immediate_Alert_Service                        0x1802
#define GATT_Link_Loss_Service                              0x1803
#define GATT_Tx_Power_Service                               0x1804
#define GATT_Current_Time_Service                           0x1805
#define GATT_Reference_Time_Update_Service                  0x1806
#define GATT_Next_DST_Change_Service                        0x1807
#define GATT_Glucose_Service                                0x1808
#define GATT_Health_Thermometer_Service                     0x1809
#define GATT_Device_Information_Service                     0x180A
#define GATT_Heart_Rate_Service                             0x180D
#define GATT_Phone_Alert_Service                            0x180E
#define GATT_Battery_Service                                0x180F
#define GATT_Blood_Pressure_Service                         0x1810
#define GATT_Alert_Notification_Service                     0x1811
#define GATT_Human_Interface_Service                        0x1812
#define GATT_Scan_Parameters_Service                        0x1813
#define GATT_Running_Speed_Cadence_Service                  0x1814
#define GATT_Cycling_Speed_Cadence_Service                  0x1816
#define GATT_Cycling_Power_Service                          0x1818
#define GATT_Location_Navigation_Service                    0x1819

//https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicsHome.aspx
#endif
