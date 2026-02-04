# meta-ky-sensor-integration

This project demonstrates a **full-stack OpenBMC sensor integration** by adding a **TMP105 temperature sensor** on an I2C bus, covering the complete path from **Linux kernel support** to **OpenBMC D-Bus–exposed sensor objects**, and finally retrieving temperature values via **Redfish**.

## Repository Structure

```
.
├── conf
│   └── layer.conf
├── COPYING.MIT
├── recipes-kernel
│   └── linux
│       ├── linux-aspeed
│       │   ├── 0001-add-tmp105-sensor-on-i2c2.patch
│       │   └── romulus-tmp105.cfg
│       └── linux-aspeed_%.bbappend
└── recipes-phosphor
    ├── inventory
    │   ├── phosphor-inventory-manager
    │   │   └── associations.json
    │   └── phosphor-inventory-manager_%.bbappend
    └── sensors
        ├── phosphor-hwmon
        │   └── obmc
        │       └── hwmon
        │           └── ahb
        │               └── apb@1e780000
        │                   └── bus@1e78a000
        │                       └── i2c@c0
        │                           └── tmp105@48.conf
        └── phosphor-hwmon_%.bbappend
```

## Architecture

TMP105 (I2C)  -->  kernel I2C driver  -->  sysfs (/sys/class/hwmon)  -->  phosphor-hwmon  -->  D-Bus (/xyz/openbmc_project/sensors/temperature/*)  -->  bmcweb  -->  Redfish

## Key Highlights

* Applied `0001-add-tmp105-sensor-on-i2c2.patch` to register the TMP105 device via DTS

* Enabled required kernel drivers via Yocto kernel configuration

* Exposed sensor via **phosphor-hwmon**  

* Created OpenBMC sensor config to publish data on **D-Bus**  
* Integrated the sensor with **hwmon** and **phosphor-inventory-manager (PIM)** to ensure it can be discovered and reported through **Redfish APIs**

* Verified sensor behavior using  Redfish

* No upstream source code modification, only Yocto bbappend-based customization



## Verification
### 1. Run QEMU
```
yc@yc-VMware-Virtual-Platform:~/openbmc$ ./qemu-system-arm \
-M romulus-bmc -nographic \ 
-m 256 \ 
-drive file=~/openbmc/build/romulus/tmp/deploy/images/romulus/obmc-phosphor-image-romulus.static.mtd,format=raw,if=mtd \
-net nic \
-net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostfwd=udp:127.0.0.1:2623-:623,hostname=qemu \
-device tmp105,bus=aspeed.i2c.bus.2,address=0x48 \
-qmp unix:$PWD/qmp.sock,server,nowait    
```
<img width="1913" height="242" alt="upload_17c57b7c7cfcaa3f68aa1e9a69a3be5e" src="https://github.com/user-attachments/assets/ac9bd624-e020-485e-8666-43048f1c9964" />


### 2. Modify sensor value via QEMU QOM (low-level simulation)
<img width="947" height="184" alt="upload_aa3e60f11a793b0f50af1dc69bd8cbcc" src="https://github.com/user-attachments/assets/a19cd7ed-e213-4a84-ab4d-2110c085b2e4" />

---

### 3. Read sensor data from D-Bus

- List sensor objects:
`busctl tree`

    <img width="1546" height="320" alt="upload_0819dac3caf182b127e914d485077f5f" src="https://github.com/user-attachments/assets/401fc435-b65b-42c2-94ba-e001c7a64004" />

- Inspect sensor interface:
`busctl introspect <service> <object-path>`

    <img width="1170" height="263" alt="upload_ef2f173d41cd5edc0b049fb21c945d10" src="https://github.com/user-attachments/assets/20ab1bba-b6a5-40af-a8bf-635811153c25" />

- Read sensor value:
`busctl get-property`
    <img width="1170" height="99" alt="upload_c8cf58d17c7a7419f4d69bb01dc2f8df" src="https://github.com/user-attachments/assets/387959cc-6a37-4fd9-9a6b-e9d42668d792" />
    <img width="1170" height="103" alt="upload_054bbfe21ab589a97d61ce6d2399b6ef" src="https://github.com/user-attachments/assets/c9f77f19-76ef-473a-8d1f-43bded88dfc3" />


---

### 4. Read temperature via Redfish

<img width="952" height="450" alt="upload_99a6fd4ddab31e2ac99c00a2664cb0dc" src="https://github.com/user-attachments/assets/886a0837-6f2a-46b1-84aa-b9a10d0ea606" />

