# Water Tank Device

Replacement Water Tank Plugin for use in measuring water tank levels based on a distance sensor.

Scene triggers for capacity and volume are coded so that you can enable notifications or trigger scenes or other automation based on what's in the tanks.

The plugin uses some variables that modify its behaviour:

    Debug - 0 = off, 1 = on. Adds more info to Vera's log for troubleshooting.
    SurfaceArea (cm2 / square centimeters) - calculated surface area of your tanks.
    MaxLevel - the level sensor reading that indicates full/100%
    MinLevel - the level sensor reading that indicates empty/0% (probably the level where your outlet pipe is).
    DistanceDeviceID - the distance sensor Device# to use as input for the calculations
    
Installation:

    On Vera, go to Apps -> Develop Apps -> Luup Files
    Drag and drop all .json, .xml and .lua files to the Upload box
    Go to Create Device
    Set Upnp Device Filename to D_LiveHouseWaterTank1.xml
    Set Upnp Implementation Filename to I_LiveHouseWaterTank1.xml
    Click Create Device
    Restart the Luup Engine
    Go to Devices
    After Vera has restarted, refresh browser and new device should be visible.
    Go to Properties -> Advanced -> Variables of the Water Tank Device and set the values as per list above.
    Go to New service and click Reload Engine for the changes to take effect.
    
    