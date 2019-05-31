#!/bin/bash
#Author : Prasenjit Roy
#set -x
######## Check Variables###############
vmsize="$2"
#get the VM size via the instance api
#VMSIZE=`curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/vmsize?api-version=2017-08-01&format=text"`

# Check if mount points already exists
mcount1=$(mount -t xfs | grep -i hana | wc -l)
if [ $mcount1 != 0 ] ;then
   echo "HANA filesystems exist"
   exit
fi
case $vmsize in DEMO)
    echo "Configuration for $vmsize"
    # Check luns are available and create PVs
    for i in 0 1 2 3 4 5 6
    do
      echo "Checking existence of LUNs"
      if [ ! -L "/dev/disk/azure/scsi1/lun${i}" ]; then
      echo "Lun ${i} not added"
      exit
      echo "pvcreate /dev/disk/azure/scsi1/lun${i}"
      pvcreate -ff -y "/dev/disk/azure/scsi1/lun${i}"
        if [ $? != 0 ];then
        exit
        fi 
      fi
    done
    echo " PV created"
       # Creation of directories
    if [ ! -d "/hana/data/" ];then
        mkdir -p /hana/data/
    else
        echo "Data directory exists"
    fi
    if [ ! -d "/hana/log/" ];then
        mkdir -p /hana/log/
    else
        echo "Log directory exists"
    fi
    if [ ! -d "/hana/shared/" ];then
        mkdir -p /hana/shared/
    else
        echo "Shared directory exists"
    fi
    if [ ! -d "/hana/backup/" ];then
        mkdir -p /hana/backup/
    else
        echo "Backup directory exists"
    fi
    if [ ! -d "/usr/sap/" ];then
        mkdir -p /usr/sap/
    else
        echo "/usr/sap directory exists"
    fi
    echo "Directories created"
    # Create a backup of /etc/fstab
    cp /etc/fstab /etc/fstab.orig
    if [ $? != 0 ];then
     echo "Couldnt backup fstab. Please check why"
     exit
    fi
    # Creating VGs
    flag=1
        echo "Creating VGs,LVs and filesystems"
        datavg1lun="/dev/disk/azure/scsi1/lun0"
        datavg2lun="/dev/disk/azure/scsi1/lun1"
        datavg3lun="/dev/disk/azure/scsi1/lun2"
        datavg4lun="/dev/disk/azure/scsi1/lun3"
        vgcreate datavg $datavg1lun $datavg2lun $datavg3lun $datavg4lun
        PHYSVOLUMES=4
        STRIPESIZE=64
        lvcreate -i$PHYSVOLUMES -I$STRIPESIZE -l 75%FREE -n datalv datavg
        lvcreate -i$PHYSVOLUMES -I$STRIPESIZE -l 100%FREE -n loglv datavg
        mkfs.xfs /dev/datavg/datalv
        mkfs.xfs /dev/datavg/loglv
        echo "/dev/mapper/datavg-datalv /hana/data/ xfs defaults  0  0"  >> /etc/fstab
        echo "/dev/mapper/datavg-loglv /hana/log/ xfs defaults  0  0"  >> /etc/fstab
        if [ $? = 0 ];then
        sharedvglun="/dev/disk/azure/scsi1/lun4"
        vgcreate sharedvg $sharedvglun 
        lvcreate -l 100%FREE -n sharedlv sharedvg
        mkfs -t xfs /dev/sharedvg/sharedlv
        echo "/dev/mapper/sharedvg-sharedlv /hana/shared/ xfs defaults  0  0"  >> /etc/fstab
        if [ $? = 0 ];then
        usrsapvglun="/dev/disk/azure/scsi1/lun5"
        vgcreate usrsapvg $usrsapvglun 
        lvcreate -l 100%FREE -n usrsaplv usrsapvg
        mkfs -t xfs /dev/usrsapvg/usrsaplv
        echo "/dev/mapper/usrsapvg-usrsaplv /usr/sap/ xfs defaults  0  0"  >> /etc/fstab
        if [ $? = 0 ];then
        backupvglun="/dev/disk/azure/scsi1/lun6"
        vgcreate backupvg $backupvglun 
        lvcreate -l 100%FREE -n backuplv backupvg
        mkfs -t xfs /dev/backupvg/backuplv
        echo "/dev/mapper/backupvg-backuplv /hana/backup/ xfs defaults  0  0"  >> /etc/fstab
        if [ $? = 0 ];then
        echo "VGs and LVs created successfully"
        flag=0
        fi 
        fi
        fi
        fi
    if [ $flag != 0 ]; then
       echo "VGs not created"
       exit
    fi
    echo "Filesystems created successfully"
    mount -a
    echo "Filesystems mounted"
    #install hana prereqs
    zypper install -y glibc-2.22-51.6
    zypper install -y systemd-228-142.1
    zypper install -y unrar
    zypper install -y sapconf
    zypper install -y saptune
    mkdir /etc/systemd/login.conf.d
    zypper in -t pattern -y sap-hana
    saptune solution apply HANA
    saptune daemon start
    #Agent Configuration
    cp -f /etc/waagent.conf /etc/waagent.conf.orig
    sedcmd="s/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/g"
    sedcmd2="s/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=2048/g"
    cat /etc/waagent.conf | sed $sedcmd | sed $sedcmd2 > /etc/waagent.conf.new
    cp -f /etc/waagent.conf.new /etc/waagent.conf
esac