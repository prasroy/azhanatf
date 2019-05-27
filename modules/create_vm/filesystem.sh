#!/bin/bash
#Author : Prasenjit Roy
#set -x
######## Check Variables###############
SID="$1"
SIZE="$2"
if [ -z "$SID" ];then 
echo "Parameter is empty" 
exit
fi
sid=`echo $SID | tr '[:upper:]' '[:lower:]'`
# Check if mount points already exists
mcount1=$(mount -t xfs | grep -i hana | wc -l)
mcount2=$(mount -t xfs | grep -i sap | wc -l)
if [ $mcount1 != 0 ] ;then
   echo "HANA filesystems exist"
   exit
  if [ $mcount2 != 0 ];then
  echo "SAP filesystems already exist"
  exit
  fi
fi
case $SIZE in DEMO)
    echo "Parameters passed are $SID and $SIZE"
    # Check luns are available and create PVs
    for i in 0 1 2 3 4 5 6 7
    do
      echo "Checking existence of LUNs"
      if [ ! -L "/dev/disk/azure/scsi1/lun${i}" ]; then
      echo "Lun ${i} not added"
      exit
      echo "pvcreate /dev/disk/azure/scsi1/lun${i}"
      pvcreate "/dev/disk/azure/scsi1/lun${i}"
        if [ $? != 0 ];then
        exit
        fi 
      fi
    done
    echo " PV created"
       # Creation of directories
    if [ ! -d "/hana/data/${SID}" ];then
        mkdir -p /hana/data/$SID
    else
        echo "Data directory exists"
    fi
    if [ ! -d "/hana/log/${SID}" ];then
        mkdir -p /hana/log/$SID
    else
        echo "Log directory exists"
    fi
    if [ ! -d "/hana/shared/${SID}" ];then
        mkdir -p /hana/shared/$SID
    else
        echo "Shared directory exists"
    fi
    if [ ! -d "/hana/backup/${SID}" ];then
        mkdir -p /hana/backup/$SID
    else
        echo "Backup directory exists"
    fi
    if [ ! -d "/usr/sap/${SID}" ];then
        mkdir -p /usr/sap/$SID
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
        vgcreate vg_hana_data_$SID /dev/disk/azure/scsi1/lun0 /dev/disk/azure/scsi1/lun1
        lvcreate -i 2 -l 100%FREE -n hana_data vg_hana_data_$SID
        mkfs.xfs /dev/vg_hana_data_$SID/hana_data
        echo "/dev/vg_hana_data_${SID}/hana_data /hana/data/${SID} xfs defaults,nofail  0  2"  >> /etc/fstab
        if [ $? = 0 ];then
        vgcreate vg_hana_log_$SID /dev/disk/azure/scsi1/lun2 /dev/disk/azure/scsi1/lun3
        lvcreate -i 2 -l 100%FREE -n hana_log vg_hana_log_$SID
        mkfs.xfs /dev/vg_hana_log_$SID/hana_log
        echo "/dev/vg_hana_log_${SID}/hana_log /hana/log/${SID} xfs defaults,nofail  0  2"  >> /etc/fstab
        if [ $? = 0 ];then
        vgcreate vg_hana_shared_$SID /dev/disk/azure/scsi1/lun4
        lvcreate -l 100%FREE -n hana_shared vg_hana_shared_$SID
        mkfs.xfs /dev/vg_hana_shared_$SID/hana_shared
        echo "/dev/vg_hana_shared_${SID}/hana_shared /hana/shared/${SID} xfs defaults,nofail  0  2"  >> /etc/fstab
        if [ $? = 0 ];then
        vgcreate vg_usr_sap_$SID /dev/disk/azure/scsi1/lun5
        lvcreate -l 100%FREE -n usr_sap vg_usr_sap_$SID
        mkfs.xfs /dev/vg_usr_sap_$SID/usr_sap
        echo "/dev/vg_usr_sap_${SID}/usr_sap /usr/sap/${SID} xfs defaults,nofail  0  2"  >> /etc/fstab
        if [ $? = 0 ];then
        vgcreate vg_hana_backup_$SID /dev/disk/azure/scsi1/lun6
        lvcreate -l 100%FREE -n hana_backup vg_hana_backup_$SID
        mkfs.xfs /dev/vg_hana_backup_$SID/hana_backup
        echo "/dev/vg_hana_backup_${SID}/hana_backup /hana/backup/${SID} xfs defaults,nofail  0  2"  >> /etc/fstab
        if [ $? = 0 ];then
        vgcreate vg_sapmnt_$SID /dev/disk/azure/scsi1/lun7
        lvcreate -l 100%FREE -n sapmnt vg_sapmnt_$SID
        mkfs.xfs /dev/vg_sapmnt_$SID/sapmnt
        echo "/dev/vg_sapmnt_${SID}/sapmnt /sapmnt/${SID} xfs defaults,nofail  0  2"  >> /etc/fstab
        if [ $? = 0 ];then
        echo "VGs and LVs created successfully"
        flag=0
        fi 
        fi
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
esac